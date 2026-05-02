import base64
import requests
import urllib.parse

def create_payment_form_url(amount: float, order_id: str, business_creds: dict, customer_email: str = "comprador@email.com") -> str:
    """
    Creates a payment in Izipay and returns the checkout URL.
    """
    username = business_creds["username"]
    password = business_creds["password"]
    public_key = business_creds["public_key"]
    
    # Auth
    auth_string = f"{username}:{password}"
    auth_bytes = base64.b64encode(auth_string.encode('utf-8')).decode('utf-8')
    headers = {
        "Authorization": f"Basic {auth_bytes}",
        "Content-Type": "application/json"
    }
    
    # Payload
    amount_in_cents = int(float(amount) * 100)
    payload = {
        "amount": amount_in_cents,
        "currency": "PEN",
        "orderId": str(order_id),
        "customer": {
            "email": customer_email
        }
    }
    
    url = "https://api.micuentaweb.pe/api-payment/V4/Charge/CreatePayment"
    response = requests.post(url, json=payload, headers=headers)
    
    if response.status_code == 200:
        data = response.json()
        if data.get("status") == "SUCCESS":
            form_token = data["answer"]["formToken"]
            
            form_token_encoded = urllib.parse.quote(form_token)
            public_key_encoded = urllib.parse.quote(public_key)
            
            payment_url = f"https://us-central1-catalogo-virtual-app.cloudfunctions.net/render_izipay_checkout?token={form_token_encoded}&publicKey={public_key_encoded}"
            return payment_url
        else:
            raise Exception(data.get("answer", {}).get("errorMessage", "Error Izipay"))
    else:
        raise Exception(f"Error HTTP {response.status_code} desde Izipay")
