# 🎬 Cinema App — Testes Automatizados de API (Robot Framework)

Este projeto implementa uma suíte completa de **testes automatizados** para a API **Cinema App**, utilizando o **Robot Framework** com a biblioteca **RequestsLibrary**.  
Os testes cobrem os módulos principais da aplicação (Auth, Users, Movies, Theaters, Sessions e Reservations), validando os fluxos de CRUD, autenticação, autorização e integrações entre entidades.

---

## 🧩 Estrutura Geral do Projeto

```
api-tests/
│
├── testcases/
│   ├── auth_tests.robot
│   ├── users_tests.robot
│   ├── movies_tests.robot
│   ├── theaters_tests.robot
│   ├── sessions_tests.robot
│   └── reservations_tests.robot
│
├── resources/
│   ├── variables.robot
│   ├── keywords.robot
│   └── admin_token_helper.py
│
├── output.xml
├── log.html
├── report.html
└── README.md
```

---

## ⚙️ Tecnologias e Ferramentas

| Componente | Descrição |
|-------------|------------|
| **Robot Framework** | Framework principal para automação de testes. |
| **RequestsLibrary** | Biblioteca para chamadas HTTP. |
| **Collections / String** | Manipulação de dicionários e strings no Robot. |
| **Python (helper)** | Script auxiliar para gerar token admin (`admin_token_helper.py`). |
| **MongoDB** | Banco de dados utilizado pela API. |
| **Node.js + Express** | Back-end do Cinema App. |
| **Nodemon** | Para execução contínua do servidor. |

---

## 🧰 Configuração do Ambiente

### 1. Clone o projeto principal

```bash
git clone https://github.com/<seu-repo>/cinema-challenge-back.git
cd cinema-challenge-back
```

### 2. Instale as dependências do back-end

```bash
npm install
```

### 3. Popule o banco de dados com dados iniciais

```bash
npm run seed
```
Saída esperada:
```
✅ Database seeded successfully
2 users created
3 movies created
3 theaters created
161 sessions created
```

### 4. Inicie o servidor local

```bash
npm run dev
```
Saída esperada:
```
Server is running on port 5000
API available at http://localhost:5000/api/v1
API documentation available at http://localhost:5000/api/v1/docs
```

---

### 5. Clone o projeto de testes

```bash
cd ..
git clone https://github.com/<seu-repo>/api-tests.git
cd api-tests
```

### 6. Crie e ative um ambiente virtual Python

```bash
python -m venv venv
source venv/bin/activate  # (Linux/macOS)
venv\Scripts\activate     # (Windows)
```

### 7. Instale as dependências do Robot

```bash
pip install -r requirements.txt
```

*(ou diretamente)*

```bash
pip install robotframework requests robotframework-requests
```

---

## 🧠 Estrutura dos Recursos

### `resources/variables.robot`

Define variáveis globais:
- URLs base (`BASE_URL`)
- Credenciais de login (`ADMIN_EMAIL`, `USER_EMAIL`)
- Tokens (`TOKEN_ADMIN`, `TOKEN_USER`)
- IDs criados dinamicamente (para limpeza automática)

---

### `resources/keywords.robot`

Arquivo principal com **todas as Keywords customizadas**:
- **Autenticação**
  - `Login As Admin`
  - `Login As User`
  - `Create Authorized Session` (corrigido — evita “Bearer Bearer” duplicado ✅)
- **Validações reutilizáveis**
  - `Validate 200 OK Response`, `Validate 400 Bad Request Response`, etc.
- **CRUD de entidades**
  - `Create New Movie As Admin`
  - `Create New Theater As Admin`
  - `Create New Session As Admin`
- **Dependências compostas**
  - `Create Session Dependencies` (cria movie + theater + session para reservas)
- **Teardown**
  - `Full Cleanup Teardown` (remove todos os recursos criados no teste)

#### 🧩 Correção importante aplicada
Anteriormente, o header de autenticação duplicava o prefixo **“Bearer”**, resultando em:
```
Authorization: Bearer Bearer eyJhbGciOi...
```
Isso causava erros **401 Unauthorized**.

✅ **Solução aplicada:**

```robot
Create Authorized Session
    [Arguments]    ${token}
    ${is_prefixed}=    Run Keyword And Return Status    Should Start With    ${token}    Bearer 
    Run Keyword If    ${is_prefixed}    Set Variable    ${auth_header}=${token}
    ...    ELSE    Set Variable    ${auth_header}=Bearer ${token}
    &{headers}=    Create Dictionary    Authorization=${auth_header}    Content-Type=application/json
    Create Session    api    ${BASE_URL}    headers=${headers}
    Log To Console    🔐 Sessão autorizada criada com header: ${auth_header}
```

---

### `resources/admin_token_helper.py`

Script Python auxiliar para gerar o **token Admin** via requisição direta.  
Usado pelo keyword `Get Admin Token Manual`.

---

## 🧪 Execução dos Testes

### Rodar um módulo específico
```bash
robot testcases/movies_tests.robot
```

### Rodar todos os testes
```bash
robot testcases/
```

Saída esperada (parcial):
```
Testcases.Auth Tests | PASS |
Testcases.Movies Tests | PASS |
Testcases.Theaters Tests | PASS |
Testcases.Sessions Tests | PASS |
Testcases.Reservations Tests | PASS |
Testcases.Users Tests | PASS |
```

Relatórios gerados:
- `output.xml`
- `log.html`
- `report.html`

Para visualizar:
```bash
open log.html
```

---

## 🔍 Logs de Diagnóstico

Durante a execução, o console exibe feedback visual:
```
✅ Token Admin Gerado com sucesso (WORKAROUND)
🎬 Tentativa de criação de filme — Status: 201
🟢 Status 201 Created validado.
🎟️ Sessão criada com ID: 6904cad4358627cee4894d8e
💾 Body enviado: {...}
📡 Resposta: {...}
```

---

## 🧹 Limpeza Automática (Teardown)

Cada teste finaliza executando:
```robot
Full Cleanup Teardown
```
Que remove:
- Reservas (`/reservations/`)
- Sessões (`/sessions/`)
- Filmes (`/movies/`)
- Teatros (`/theaters/`)
- Usuários (`/users/`)

Isso mantém o banco consistente após múltiplas execuções.

---

## ✅ Resultados Após Correção

Após corrigir o header `Bearer`, todos os módulos passaram com sucesso:

| Módulo | Status |
|---------|--------|
| Auth | 🟢 7/7 passed |
| Users | 🟢 passed |
| Movies | 🟢 passed |
| Theaters | 🟢 passed |
| Sessions | 🟢 passed |
| Reservations | 🟢 passed |

---

## 🚀 Próximos Passos

- [ ] Adicionar validação de schema (com JSON Schema).
- [ ] Gerar relatórios HTML detalhados (Allure ou Robot Rebot).
- [ ] Integração contínua (CI/CD) com GitHub Actions.
- [ ] Adicionar variáveis de ambiente (`.env`) para URLs e credenciais.

