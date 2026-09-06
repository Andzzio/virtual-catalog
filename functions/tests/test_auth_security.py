import pytest
from unittest.mock import MagicMock, patch
import json
from main import register_user, delete_user, upload_certificate

def test_register_user_no_auth():
    req = MagicMock()
    req.headers = {}
    response = register_user.__wrapped__(req)
    assert response.status_code == 401
    data = json.loads(response.data.decode("utf-8"))
    assert data["error"] == "Unauthorized"

def test_register_user_invalid_auth():
    req = MagicMock()
    req.headers = {"Authorization": "Bearer invalid_token"}
    with patch("firebase_admin.auth.verify_id_token", side_effect=ValueError("Invalid token")):
        response = register_user.__wrapped__(req)
        assert response.status_code == 401
        data = json.loads(response.data.decode("utf-8"))
        assert data["error"] == "Unauthorized"

def test_register_user_success_auth():
    req = MagicMock()
    req.headers = {"Authorization": "Bearer valid_token"}
    req.get_json.return_value = {
        "email": "test@example.com",
        "password": "password123",
        "name": "Test User",
        "businessId": "biz-123"
    }
    with patch("firebase_admin.auth.verify_id_token", return_value={"uid": "user-123"}), \
         patch("firebase_admin.auth.create_user") as mock_create, \
         patch("firebase_admin.firestore.client") as mock_firestore:
        mock_create.return_value = MagicMock(uid="user-123")
        response = register_user.__wrapped__(req)
        assert response.status_code == 200

def test_delete_user_no_auth():
    req = MagicMock()
    req.headers = {}
    response = delete_user.__wrapped__(req)
    assert response.status_code == 401

def test_delete_user_success_auth():
    req = MagicMock()
    req.headers = {"Authorization": "Bearer valid_token"}
    req.get_json.return_value = {"userId": "user-123"}
    with patch("firebase_admin.auth.verify_id_token", return_value={"uid": "admin-123"}), \
         patch("firebase_admin.auth.delete_user") as mock_delete, \
         patch("firebase_admin.firestore.client") as mock_firestore:
        response = delete_user.__wrapped__(req)
        assert response.status_code == 200

def test_upload_certificate_no_auth():
    req = MagicMock()
    req.headers = {}
    response = upload_certificate.__wrapped__(req)
    assert response.status_code == 401

def test_upload_certificate_success_auth():
    req = MagicMock()
    req.headers = {"Authorization": "Bearer valid_token"}
    req.get_json.return_value = {
        "ruc": "20123456789",
        "pfxBase64": "pfx_data",
        "password": "password",
        "environment": "beta"
    }
    with patch("firebase_admin.auth.verify_id_token", return_value={"uid": "user-123"}), \
         patch("main._get_cert_manager") as mock_get_manager:
        mock_manager = MagicMock()
        mock_manager.store_certificate.return_value = {"success": True}
        mock_get_manager.return_value = mock_manager
        response = upload_certificate.__wrapped__(req)
        assert response.status_code == 200
