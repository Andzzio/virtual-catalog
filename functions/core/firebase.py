from firebase_admin import initialize_app, firestore

try:
    initialize_app()
except ValueError:
    pass

def get_db():
    return firestore.client()
