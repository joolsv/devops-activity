import pytest
from app import app

@pytest.fixture
def client():
    with app.test_client() as client:
        yield client

def test_greetings(client):
    response = client.get('/')
    assert response.data == b'Hello, World!'
    assert response.status_code == 200

def test_page1(client):
    response = client.get('/page1')
    assert response.data == b'This is page 1'
    assert response.status_code == 200
