import requests

def test_long_password():
    url = "http://127.0.0.1:8000/api/auth/login"
    # Password of 100 chars (over our 72 limit)
    payload = {
        "email": "test@example.com",
        "password": "a" * 100
    }
    
    print(f"Testing login with password length {len(payload['password'])}")
    try:
        response = requests.post(url, json=payload, timeout=5)
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.json()}")
        if response.status_code == 422:
            print("SUCCESS: Received validation error as expected.")
        elif response.status_code == 401:
            print("SUCCESS: Received unauthorized (wrong email/pass) as expected.")
    except Exception as e:
        print(f"FAILURE: Server may have crashed or timed out: {e}")

if __name__ == "__main__":
    test_long_password()
