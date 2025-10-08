-- SISAPA - Schema do Banco de Dados MySQL
-- Execute este script para criar a estrutura inicial do banco

-- Criar banco de dados (se não existir)
CREATE DATABASE IF NOT EXISTS sisapa_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

-- Usar o banco de dados
USE sisapa_db;

-- ========== Tabela de Usuários ==========
CREATE TABLE IF NOT EXISTS usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    cpf VARCHAR(14) UNIQUE,
    telefone VARCHAR(15),
    senha_hash VARCHAR(255) NOT NULL,
    tipo_usuario ENUM('admin', 'funcionario', 'cidadao') DEFAULT 'cidadao',
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_email (email),
    INDEX idx_cpf (cpf),
    INDEX idx_tipo_usuario (tipo_usuario)
);

-- ========== Tabela de Endereços ==========
CREATE TABLE IF NOT EXISTS enderecos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT,
    cep VARCHAR(10),
    logradouro VARCHAR(200),
    numero VARCHAR(10),
    complemento VARCHAR(100),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    estado VARCHAR(2),
    pais VARCHAR(50) DEFAULT 'Brasil',
    principal BOOLEAN DEFAULT FALSE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    INDEX idx_usuario_id (usuario_id),
    INDEX idx_cep (cep)
);

-- ========== Tabela de Unidades de Saúde ==========
CREATE TABLE IF NOT EXISTS unidades_saude (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    tipo ENUM('ubs', 'hospital', 'clinica', 'laboratorio') NOT NULL,
    cnpj VARCHAR(18) UNIQUE,
    telefone VARCHAR(15),
    email VARCHAR(100),
    endereco_completo TEXT,
    cep VARCHAR(10),
    cidade VARCHAR(100),
    estado VARCHAR(2),
    horario_funcionamento JSON,
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_tipo (tipo),
    INDEX idx_cidade (cidade),
    INDEX idx_cep (cep)
);

-- ========== Tabela de Profissionais de Saúde ==========
CREATE TABLE IF NOT EXISTS profissionais_saude (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT,
    unidade_saude_id INT,
    especialidade VARCHAR(100),
    registro_profissional VARCHAR(50) NOT NULL UNIQUE,
    tipo_registro ENUM('CRM', 'CRE', 'CRF', 'CRO', 'COREN') NOT NULL,
    ativo BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (unidade_saude_id) REFERENCES unidades_saude(id) ON DELETE SET NULL,
    INDEX idx_especialidade (especialidade),
    INDEX idx_registro (registro_profissional)
);

-- ========== Tabela de Agendamentos ==========
CREATE TABLE IF NOT EXISTS agendamentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    profissional_id INT,
    unidade_saude_id INT NOT NULL,
    tipo_atendimento VARCHAR(100),
    data_agendamento DATETIME NOT NULL,
    duracao_minutos INT DEFAULT 30,
    status ENUM('agendado', 'confirmado', 'realizado', 'cancelado', 'faltou') DEFAULT 'agendado',
    observacoes TEXT,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (profissional_id) REFERENCES profissionais_saude(id) ON DELETE SET NULL,
    FOREIGN KEY (unidade_saude_id) REFERENCES unidades_saude(id) ON DELETE CASCADE,
    INDEX idx_data_agendamento (data_agendamento),
    INDEX idx_status (status),
    INDEX idx_usuario_id (usuario_id)
);

-- ========== Tabela de Prontuários ==========
CREATE TABLE IF NOT EXISTS prontuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    profissional_id INT,
    agendamento_id INT,
    tipo_atendimento VARCHAR(100),
    data_atendimento DATETIME NOT NULL,
    queixa_principal TEXT,
    historia_doenca_atual TEXT,
    exame_fisico TEXT,
    hipotese_diagnostica TEXT,
    conduta_tratamento TEXT,
    prescricoes TEXT,
    observacoes TEXT,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (profissional_id) REFERENCES profissionais_saude(id) ON DELETE SET NULL,
    FOREIGN KEY (agendamento_id) REFERENCES agendamentos(id) ON DELETE SET NULL,
    INDEX idx_usuario_id (usuario_id),
    INDEX idx_data_atendimento (data_atendimento)
);

-- ========== Tabela de Medicamentos ==========
CREATE TABLE IF NOT EXISTS medicamentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(200) NOT NULL,
    principio_ativo VARCHAR(200),
    forma_farmaceutica VARCHAR(50),
    concentracao VARCHAR(50),
    fabricante VARCHAR(100),
    codigo_ean VARCHAR(20),
    disponivel BOOLEAN DEFAULT TRUE,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_nome (nome),
    INDEX idx_principio_ativo (principio_ativo)
);

-- ========== Tabela de Estoque de Medicamentos ==========
CREATE TABLE IF NOT EXISTS estoque_medicamentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    medicamento_id INT NOT NULL,
    unidade_saude_id INT NOT NULL,
    quantidade_disponivel INT DEFAULT 0,
    quantidade_minima INT DEFAULT 10,
    lote VARCHAR(50),
    data_validade DATE,
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (medicamento_id) REFERENCES medicamentos(id) ON DELETE CASCADE,
    FOREIGN KEY (unidade_saude_id) REFERENCES unidades_saude(id) ON DELETE CASCADE,
    INDEX idx_medicamento_unidade (medicamento_id, unidade_saude_id),
    INDEX idx_data_validade (data_validade)
);

-- ========== Tabela de Retirada de Medicamentos ==========
CREATE TABLE IF NOT EXISTS retiradas_medicamentos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    medicamento_id INT NOT NULL,
    unidade_saude_id INT NOT NULL,
    quantidade_retirada INT NOT NULL,
    receita_medica VARCHAR(255),
    data_retirada TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    observacoes TEXT,
    
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (medicamento_id) REFERENCES medicamentos(id) ON DELETE CASCADE,
    FOREIGN KEY (unidade_saude_id) REFERENCES unidades_saude(id) ON DELETE CASCADE,
    INDEX idx_usuario_id (usuario_id),
    INDEX idx_data_retirada (data_retirada)
);

-- ========== Tabela de Logs do Sistema ==========
CREATE TABLE IF NOT EXISTS logs_sistema (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT,
    acao VARCHAR(100) NOT NULL,
    tabela_afetada VARCHAR(50),
    registro_id INT,
    dados_antigos JSON,
    dados_novos JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    data_criacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE SET NULL,
    INDEX idx_usuario_id (usuario_id),
    INDEX idx_acao (acao),
    INDEX idx_data_criacao (data_criacao)
);

-- ========== Inserir dados iniciais (opcional) ==========

-- Usuário administrador padrão (senha: admin123)
INSERT INTO usuarios (nome, email, cpf, senha_hash, tipo_usuario) VALUES 
('Administrador', 'admin@sisapa.gov.br', '000.000.000-00', '$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LeD4jnOOVrGP2HNIe', 'admin')
ON DUPLICATE KEY UPDATE email = email;

-- Exemplo de unidade de saúde
INSERT INTO unidades_saude (nome, tipo, telefone, endereco_completo, cidade, estado) VALUES 
('UBS Central', 'ubs', '(11) 1234-5678', 'Rua Principal, 123 - Centro', 'São Paulo', 'SP'),
('Hospital Municipal', 'hospital', '(11) 8765-4321', 'Av. Saúde, 456 - Centro', 'São Paulo', 'SP')
ON DUPLICATE KEY UPDATE nome = nome;

-- ========== Triggers para auditoria ==========

DELIMITER //

CREATE TRIGGER usuarios_audit_insert 
AFTER INSERT ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO logs_sistema (usuario_id, acao, tabela_afetada, registro_id, dados_novos) 
    VALUES (NEW.id, 'INSERT', 'usuarios', NEW.id, JSON_OBJECT('nome', NEW.nome, 'email', NEW.email));
END//

CREATE TRIGGER usuarios_audit_update 
AFTER UPDATE ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO logs_sistema (usuario_id, acao, tabela_afetada, registro_id, dados_antigos, dados_novos) 
    VALUES (NEW.id, 'UPDATE', 'usuarios', NEW.id, 
            JSON_OBJECT('nome', OLD.nome, 'email', OLD.email),
            JSON_OBJECT('nome', NEW.nome, 'email', NEW.email));
END//

DELIMITER ;

-- ========== Views úteis ==========

-- View para agendamentos com informações completas
CREATE OR REPLACE VIEW view_agendamentos_completos AS
SELECT 
    a.id,
    a.data_agendamento,
    a.status,
    a.tipo_atendimento,
    u.nome as usuario_nome,
    u.email as usuario_email,
    p.especialidade,
    ps.nome as profissional_nome,
    un.nome as unidade_nome,
    un.endereco_completo as unidade_endereco
FROM agendamentos a
JOIN usuarios u ON a.usuario_id = u.id
LEFT JOIN profissionais_saude p ON a.profissional_id = p.id
LEFT JOIN usuarios ps ON p.usuario_id = ps.id
JOIN unidades_saude un ON a.unidade_saude_id = un.id;

-- View para estoque baixo de medicamentos
CREATE OR REPLACE VIEW view_estoque_baixo AS
SELECT 
    m.nome as medicamento,
    m.principio_ativo,
    u.nome as unidade,
    e.quantidade_disponivel,
    e.quantidade_minima,
    e.data_validade
FROM estoque_medicamentos e
JOIN medicamentos m ON e.medicamento_id = m.id
JOIN unidades_saude u ON e.unidade_saude_id = u.id
WHERE e.quantidade_disponivel <= e.quantidade_minima
OR e.data_validade <= DATE_ADD(CURDATE(), INTERVAL 30 DAY);

-- Mostrar informações do banco criado
SELECT 'Schema SISAPA criado com sucesso!' as status;
SHOW TABLES;