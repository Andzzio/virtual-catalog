from core.firebase import get_db

def get_business_credentials(business_id: str):
    """
    Returns a dictionary with izipayUsername, izipayPassword, izipayPublicKey.
    Raises Exception if not found or missing.
    """
    db = get_db()
    business_doc = db.collection("businesses").document(business_id).get()
    
    if not business_doc.exists:
        raise ValueError("Negocio no encontrado")
        
    business_data = business_doc.to_dict()
    
    username = str(business_data.get("izipayUsername", "")).strip()
    password = str(business_data.get("izipayPassword", "")).strip()
    public_key = str(business_data.get("izipayPublicKey", "FALTA_LLAVE_PUBLICA")).strip()
    
    if not username or not password:
        raise ValueError("Esta tienda no tiene configurado Izipay")
        
    return {
        "username": username,
        "password": password,
        "public_key": public_key
    }

def get_hmac_by_shop_id(shop_id: str):
    db = get_db()
    # Aseguramos que sea string para la búsqueda
    shop_id_str = str(shop_id)
    
    docs = db.collection("businesses").where("izipayUsername", "==", shop_id_str).limit(1).get()
    
    if not docs:
        raise ValueError(f"No se encontró ningún negocio con el shopId {shop_id_str}")
        
    doc_id = docs[0].id
    business_data = docs[0].to_dict()
    print(f"DEBUG: Negocio encontrado ID: {doc_id} para shopId: {shop_id_str}")
    
    # Para la IPN, Izipay firma con la Contraseña de la API (izipayPassword),
    # NO con la clave HMAC-SHA-256 (esa es solo para la vuelta a la tienda).
    hmac_key = str(business_data.get("izipayPassword", "")).strip()
    
    if not hmac_key:
        print(f"DEBUG: Campos disponibles en este doc: {list(business_data.keys())}")
        raise ValueError(f"El negocio (ID: {doc_id}) no tiene configurado el izipayPassword")
        
    return hmac_key, doc_id
