# SISAPA - Sistema de Informação de Saúde e Assistência Pública

## 📋 Descrição do Projeto

O SISAPA é um sistema web desenvolvido para gerenciar informações de saúde e assistência pública, proporcionando uma interface intuitiva para usuários e administradores.

## 🚀 Tecnologias Utilizadas

### Frontend
- **HTML5** - Estrutura das páginas
- **CSS3** - Estilização e layout responsivo
- **JavaScript** - Interatividade e funcionalidades dinâmicas

### Backend
- **Python** - Linguagem principal do servidor
- **Flask/Django** - Framework web (a definir)
- **MySQL** - Banco de dados relacional

## 📁 Estrutura do Projeto

```
PROJETO_SISAPA/
│
├── frontend/           # Arquivos do frontend
│   ├── css/           # Folhas de estilo
│   ├── js/            # Scripts JavaScript
│   ├── images/        # Imagens e assets
│   └── index.html     # Página principal
│
├── backend/           # Código do servidor Python
│   ├── models/        # Modelos de dados
│   ├── routes/        # Rotas da aplicação
│   └── utils/         # Utilitários e helpers
│
├── database/          # Scripts e configurações do MySQL
│   ├── schema.sql     # Estrutura do banco
│   └── seed.sql       # Dados iniciais
│
├── config/            # Configurações da aplicação
│   └── database.py    # Configuração do banco
│
├── docs/              # Documentação do projeto
│
├── requirements.txt   # Dependências Python
└── README.md         # Este arquivo
```

## ⚙️ Instalação e Configuração

### Pré-requisitos
- Python 3.8 ou superior
- MySQL 8.0 ou superior
- Git

### 1. Clone o repositório
```bash
git clone https://github.com/Flowzinnn/PROJETO_SISAPA.git
cd PROJETO_SISAPA
```

### 2. Configurar ambiente Python
```bash
# Criar ambiente virtual
python -m venv venv

# Ativar ambiente virtual (Windows)
venv\Scripts\activate

# Instalar dependências
pip install -r requirements.txt
```

### 3. Configurar banco de dados MySQL
```bash
# Executar script de criação do banco
mysql -u root -p < database/schema.sql

# Inserir dados iniciais (opcional)
mysql -u root -p < database/seed.sql
```

### 4. Configurar variáveis de ambiente
Copie o arquivo `.env.example` para `.env` e configure as variáveis:
```
DB_HOST=localhost
DB_USER=seu_usuario
DB_PASSWORD=sua_senha
DB_NAME=sisapa_db
```

## 🏃‍♂️ Como Executar

### Desenvolvimento
```bash
# Ativar ambiente virtual
venv\Scripts\activate

# Executar servidor de desenvolvimento
python app.py
```

Acesse `http://localhost:5000` no seu navegador.

## 🤝 Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 👥 Equipe

- **Desenvolvedor Principal**: [Seu Nome]
- **Contato**: [seu-email@exemplo.com]

## 📝 Status do Projeto

🚧 **Em Desenvolvimento** 🚧

- [x] Estrutura inicial do projeto
- [ ] Interface do usuário
- [ ] Sistema de autenticação
- [ ] CRUD básico
- [ ] Relatórios
- [ ] Testes
- [ ] Deploy

---

*Última atualização: Outubro 2025*