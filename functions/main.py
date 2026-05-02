# Welcome to Cloud Functions for Firebase for Python!
# To get started, simply uncomment the below code or create your own.
# Deploy with `firebase deploy`
import base64
import requests
from firebase_functions import https_fn
from firebase_functions.options import set_global_options
from firebase_admin import initialize_app

# For cost control, you can set the maximum number of containers that can be
# running at the same time. This helps mitigate the impact of unexpected
# traffic spikes by instead downgrading performance. This limit is a per-function
# limit. You can override the limit for each function using the max_instances
# parameter in the decorator, e.g. @https_fn.on_request(max_instances=5).

set_global_options(max_instances=10)
import json
from firebase_functions import https_fn, options
from firebase_functions.options import set_global_options

from data.business_repository import get_business_credentials
from services.izipay_service import create_payment_form_url
from presentation.templates.izipay_checkout import get_checkout_html
from services.ipn_service import process_ipn_webhook

set_global_options(max_instances=10)

@https_fn.on_request(cors=options.CorsOptions(cors_origins="*", cors_methods=["get", "post"]))
def create_izipay_payment(req: https_fn.Request) -> https_fn.Response:
    try:
        body = req.get_json()
        if not body:
            return https_fn.Response(json.dumps({"error": "No data"}), status=400, content_type="application/json")

        amount = body.get("amount")
        order_id = body.get("orderId")
        business_id = body.get("businessId")
        
        if not amount or not order_id or not business_id:
            return https_fn.Response(json.dumps({"error": "Faltan parámetros: amount, orderId o businessId"}), status=400, content_type="application/json")

        try:
            creds = get_business_credentials(business_id)
        except ValueError as e:
            return https_fn.Response(json.dumps({"error": str(e)}), status=400, content_type="application/json")
            
        try:
            payment_url = create_payment_form_url(amount, order_id, creds)
            return https_fn.Response(json.dumps({
                "success": True,
                "paymentUrl": payment_url
            }), status=200, content_type="application/json")
        except Exception as e:
             return https_fn.Response(json.dumps({"success": False, "error": str(e)}), status=400, content_type="application/json")

    except Exception as e:
        return https_fn.Response(json.dumps({"error": str(e)}), status=500, content_type="application/json")

@https_fn.on_request()
def render_izipay_checkout(req: https_fn.Request) -> https_fn.Response:
    form_token = str(req.args.get("token", "")).strip()
    public_key = str(req.args.get("publicKey", "")).strip()
    
    if not form_token or not public_key:
        return https_fn.Response("Faltan datos de pago", status=400)
        
    html = get_checkout_html(form_token, public_key)
    return https_fn.Response(html, status=200, content_type="text/html; charset=utf-8")

@https_fn.on_request(cors=options.CorsOptions(cors_origins="*", cors_methods=["post"]))
def izipay_webhook(req: https_fn.Request) -> https_fn.Response:
    try:
        form_data = req.form.to_dict() if req.form else {}
        if not form_data and req.is_json:
            form_data = req.get_json() or {}
            
        if not form_data:
            return https_fn.Response("No payload", status=400)
            
        # DEBUG: Ver qué nos manda Izipay
        print(f"DEBUG: Webhook recibido. Data: {list(form_data.keys())}")
        if "kr-answer" in form_data:
             print(f"DEBUG: kr-answer: {form_data['kr-answer']}")
            
        result = process_ipn_webhook(form_data)
        return https_fn.Response(result, status=200, content_type="text/plain")
    except ValueError as e:
        print(f"Error de IPN: {e}")
        return https_fn.Response(str(e), status=400, content_type="text/plain")
    except Exception as e:
        print(f"Error inesperado en IPN: {e}")
        return https_fn.Response("Error interno", status=500, content_type="text/plain")


# initialize_app()
#
#
# @https_fn.on_request()
# def on_request_example(req: https_fn.Request) -> https_fn.Response:
#     return https_fn.Response("Hello world!")