import psycopg2
import time
import random
import os

# Usa variáveis de ambiente para conectar. Padrão: host="database"
DB_HOST = os.getenv("DB_HOST", "database")
DB_USER = os.getenv("DB_USER", "admin")
DB_PASS = os.getenv("DB_PASS", "admin")
DB_NAME = os.getenv("DB_NAME", "app_db")

def get_conn():
    try:
        return psycopg2.connect(host=DB_HOST, database=DB_NAME, user=DB_USER, password=DB_PASS)
    except Exception as e:
        print(f"Aguardando banco... {e}")
        return None

def run():
    conn = None
    while conn is None:
        time.sleep(5)
        conn = get_conn()
    
    # Cria tabela inicial
    with conn.cursor() as cur:
        cur.execute("CREATE TABLE IF NOT EXISTS cargas (id SERIAL PRIMARY KEY, info TEXT, valor INT);")
        conn.commit()
    print("Tabela criada/verificada. Iniciando carga...")

    while True:
        try:
            with conn.cursor() as cur:
                # INSERT (Gera escrita)
                cur.execute("INSERT INTO cargas (info, valor) VALUES (%s, %s)", ("teste", random.randint(1, 100)))
                # SELECT (Gera leitura)
                cur.execute("SELECT count(*) FROM cargas")
                conn.commit()
            time.sleep(0.5) # Espera meio segundo para não travar tudo
        except Exception as e:
            print(f"Erro: {e}")
            conn = get_conn()

if __name__ == "__main__":
    run()