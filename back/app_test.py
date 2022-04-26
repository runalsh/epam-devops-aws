from app import app
import pytest

def test_answer():
    response = app.test_client().get('http://localhost:8080/')

    assert response.status_code == 200