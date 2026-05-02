import hmac
import hashlib
import json
from core.firebase import get_db
from data.business_repository import get_hmac_by_shop_id

def process_ipn_webhook(form_data: dict) -> str:
    """
    Procesa y valida el Webhook de Izipay.
    Retorna un string indicando éxito o lanza excepción.
    """
    kr_answer = form_data.get("kr-answer")
    kr_hash = form_data.get("kr-hash")
    
    if not kr_answer or not kr_hash:
        raise ValueError("Faltan parámetros kr-answer o kr-hash")
        
    try:
        answer_json = json.loads(kr_answer)
    except Exception:
        raise ValueError("kr-answer no es un JSON válido")
        
    shop_id = answer_json.get("shopId")
    order_status = answer_json.get("orderStatus")
    order_details = answer_json.get("orderDetails", {})
    order_id = order_details.get("orderId")
    
    if not shop_id or not order_id:
        raise ValueError("No se encontró shopId u orderId en la respuesta")
        
    hmac_key, business_id = get_hmac_by_shop_id(shop_id)
    
    calculated_hash = hmac.new(
        key=hmac_key.encode('utf-8'),
        msg=kr_answer.encode('utf-8'),
        digestmod=hashlib.sha256
    ).hexdigest()
    
    print(f"DEBUG: Validando Firma. Hash Calculado: {calculated_hash} vs Recibido: {kr_hash}")
    
    if not hmac.compare_digest(calculated_hash, kr_hash):
        raise ValueError("¡Firma criptográfica inválida! Posible intento de fraude.")
        
    print(f"DEBUG: Firma válida. Procesando orden: {order_id} con estado de pago: {order_status}")
    
    if order_status == "PAID":
        db = get_db()
        order_ref = db.collection("orders").document(order_id)
        if order_ref.get().exists:
            order_ref.update({"status": "paid", "paymentMethod": "izipay"})
        
        business_order_ref = db.collection("businesses").document(business_id).collection("orders").document(order_id)
        if business_order_ref.get().exists:
            business_order_ref.update({"status": "paid", "paymentMethod": "izipay"})
            
        return f"Pedido {order_id} pagado exitosamente"
    
    return f"Notificación recibida pero el estado es {order_status}"
