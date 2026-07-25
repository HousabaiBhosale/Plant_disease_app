import pymysql
import sys

def test_host(host):
    print(f"Testing pymysql connection to {host}...", flush=True)
    try:
        conn = pymysql.connect(
            host=host,
            user="root",
            password="",
            database="plant_disease_db",
            connect_timeout=3
        )
        print(f"SUCCESS connecting to {host}!", flush=True)
        cursor = conn.cursor()
        cursor.execute("SELECT 1")
        print("Result:", cursor.fetchone(), flush=True)
        conn.close()
    except Exception as e:
        print(f"FAILED connecting to {host}: {e}", flush=True)

if __name__ == "__main__":
    hosts = ["127.0.0.1", "localhost", "::1"]
    for host in hosts:
        test_host(host)
