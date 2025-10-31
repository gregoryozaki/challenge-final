import jwt
from datetime import datetime, timedelta
from pymongo import MongoClient
import os

# Conexão e configuração base
MONGO_URI = os.environ.get('MONGODB_URI', 'mongodb://localhost:27017/cinema-app')
JWT_SECRET = os.environ.get('JWT_SECRET', 'supersecreto1234567890cinema')

def generate_admin_token():
    """
    Gera manualmente um token JWT válido para o usuário Admin do banco seedado.
    """
    client = MongoClient(MONGO_URI)
    db = client.get_database()
    users = db['users']

    # Busca o admin criado pelo seed
    admin_user = users.find_one({"email": "admin@example.com"})

    if not admin_user:
        raise Exception("Usuário Admin não encontrado no banco. Execute 'npm run seed' no backend.")

    admin_id = str(admin_user["_id"])

    payload = {
        "id": admin_id,
        "iat": datetime.utcnow(),
        "exp": datetime.utcnow() + timedelta(hours=1)
    }

    # Gera token JWT válido
    token = jwt.encode(payload, JWT_SECRET, algorithm="HS256")

    return f"Bearer {token}"


def get_admin_token_manual():
    """
    Wrapper simples para ser usado diretamente no Robot Framework.
    """
    return generate_admin_token()
