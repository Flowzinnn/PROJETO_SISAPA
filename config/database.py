"""
Configuração do banco de dados MySQL para SISAPA
"""

import os
from dotenv import load_dotenv
import mysql.connector
from mysql.connector import Error
import logging

# Carregar variáveis de ambiente
load_dotenv()

# Configurações do banco de dados
DATABASE_CONFIG = {
    'host': os.getenv('DB_HOST', 'localhost'),
    'port': int(os.getenv('DB_PORT', 3306)),
    'user': os.getenv('DB_USER', 'root'),
    'password': os.getenv('DB_PASSWORD', ''),
    'database': os.getenv('DB_NAME', 'sisapa_db'),
    'charset': 'utf8mb4',
    'autocommit': True,
    'time_zone': '-03:00'  # Horário de Brasília
}

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class DatabaseConnection:
    """Classe para gerenciar conexões com o banco de dados MySQL"""
    
    def __init__(self):
        self.connection = None
        self.cursor = None
    
    def connect(self):
        """Estabelecer conexão com o banco de dados"""
        try:
            self.connection = mysql.connector.connect(**DATABASE_CONFIG)
            
            if self.connection.is_connected():
                self.cursor = self.connection.cursor(dictionary=True)
                db_info = self.connection.get_server_info()
                logger.info(f"Conectado ao MySQL Server versão {db_info}")
                logger.info(f"Banco de dados: {DATABASE_CONFIG['database']}")
                return True
                
        except Error as e:
            logger.error(f"Erro ao conectar com MySQL: {e}")
            return False
    
    def disconnect(self):
        """Fechar conexão com o banco de dados"""
        try:
            if self.cursor:
                self.cursor.close()
            if self.connection and self.connection.is_connected():
                self.connection.close()
                logger.info("Conexão MySQL fechada")
        except Error as e:
            logger.error(f"Erro ao desconectar: {e}")
    
    def execute_query(self, query, params=None, fetch=True):
        """Executar query no banco de dados"""
        try:
            if not self.connection or not self.connection.is_connected():
                self.connect()
            
            self.cursor.execute(query, params)
            
            if fetch:
                if query.strip().upper().startswith('SELECT'):
                    return self.cursor.fetchall()
                else:
                    self.connection.commit()
                    return self.cursor.rowcount
            else:
                self.connection.commit()
                return True
                
        except Error as e:
            logger.error(f"Erro ao executar query: {e}")
            self.connection.rollback()
            return None
    
    def execute_many(self, query, data_list):
        """Executar múltiplas queries (útil para inserções em lote)"""
        try:
            if not self.connection or not self.connection.is_connected():
                self.connect()
            
            self.cursor.executemany(query, data_list)
            self.connection.commit()
            return self.cursor.rowcount
            
        except Error as e:
            logger.error(f"Erro ao executar multiple queries: {e}")
            self.connection.rollback()
            return None
    
    def check_connection(self):
        """Verificar se a conexão está ativa"""
        try:
            if self.connection and self.connection.is_connected():
                self.cursor.execute("SELECT 1")
                return True
            return False
        except Error:
            return False

# Instância global da conexão
db = DatabaseConnection()

def get_db_connection():
    """Obter conexão com o banco de dados"""
    if not db.check_connection():
        db.connect()
    return db

def init_database():
    """Inicializar banco de dados (criar se não existir)"""
    try:
        # Conectar sem especificar database para criar se necessário
        temp_config = DATABASE_CONFIG.copy()
        database_name = temp_config.pop('database')
        
        temp_connection = mysql.connector.connect(**temp_config)
        temp_cursor = temp_connection.cursor()
        
        # Criar database se não existir
        temp_cursor.execute(f"CREATE DATABASE IF NOT EXISTS {database_name} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci")
        temp_cursor.execute(f"USE {database_name}")
        
        temp_cursor.close()
        temp_connection.close()
        
        logger.info(f"Database '{database_name}' verificado/criado com sucesso")
        return True
        
    except Error as e:
        logger.error(f"Erro ao inicializar database: {e}")
        return False

def test_connection():
    """Testar conexão com o banco de dados"""
    try:
        connection = mysql.connector.connect(**DATABASE_CONFIG)
        
        if connection.is_connected():
            cursor = connection.cursor()
            cursor.execute("SELECT VERSION()")
            version = cursor.fetchone()
            logger.info(f"Conexão de teste bem-sucedida. MySQL versão: {version[0]}")
            
            cursor.close()
            connection.close()
            return True
            
    except Error as e:
        logger.error(f"Erro no teste de conexão: {e}")
        return False

if __name__ == "__main__":
    # Teste da conexão quando executado diretamente
    logger.info("Testando conexão com MySQL...")
    
    if init_database():
        if test_connection():
            logger.info("✅ Configuração do banco de dados OK!")
        else:
            logger.error("❌ Falha no teste de conexão")
    else:
        logger.error("❌ Falha na inicialização do banco de dados")