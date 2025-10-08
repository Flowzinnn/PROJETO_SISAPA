"""
SISAPA - Sistema de Informação de Saúde e Assistência Pública
Aplicação principal Flask
"""

from flask import Flask, render_template, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
import os
from dotenv import load_dotenv

# Carregar variáveis de ambiente
load_dotenv()

# Inicializar Flask
app = Flask(__name__)

# Configurações
app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'dev-secret-key-change-in-production')
app.config['SQLALCHEMY_DATABASE_URI'] = (
    f"mysql+pymysql://{os.getenv('DB_USER', 'root')}:"
    f"{os.getenv('DB_PASSWORD', '')}@"
    f"{os.getenv('DB_HOST', 'localhost')}/"
    f"{os.getenv('DB_NAME', 'sisapa_db')}"
)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Inicializar extensões
db = SQLAlchemy(app)
CORS(app)

# Importar modelos (quando criados)
# from backend.models import *

# Importar rotas (quando criadas)
# from backend.routes import *

@app.route('/')
def index():
    """Página principal"""
    return jsonify({
        'message': 'SISAPA API funcionando!',
        'version': '1.0.0',
        'status': 'ok'
    })

@app.route('/api/health')
def health_check():
    """Endpoint para verificar se a API está funcionando"""
    return jsonify({
        'status': 'ok',
        'message': 'SISAPA API está funcionando!',
        'version': '1.0.0'
    })

@app.errorhandler(404)
def not_found(error):
    """Página de erro 404"""
    return jsonify({'error': 'Página não encontrada'}), 404

@app.errorhandler(500)
def internal_error(error):
    """Página de erro 500"""
    return jsonify({'error': 'Erro interno do servidor'}), 500

if __name__ == '__main__':
    # Criar tabelas do banco (quando modelos forem criados)
    with app.app_context():
        db.create_all()
    
    # Executar aplicação
    debug_mode = os.getenv('FLASK_ENV') == 'development'
    app.run(
        host='0.0.0.0',
        port=int(os.getenv('PORT', 5000)),
        debug=debug_mode
    )