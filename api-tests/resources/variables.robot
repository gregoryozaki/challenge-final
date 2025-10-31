*** Variables ***
# Configuração de Ambiente
${BASE_URL}          http://localhost:5000/api/v1
${BASE_URL_LOCAL}    http://localhost:5000/api/v1

# Credenciais Iniciais (Seed Data)
${ADMIN_EMAIL}       admin@example.com
${ADMIN_PASSWORD}    password123
${USER_EMAIL}        user@example.com
${USER_PASSWORD}     password123

# Variáveis Globais de Controle de Estado
${TOKEN_ADMIN}       None
${TOKEN_USER}        None

# Variáveis para IDs Criados/Manipulados (Corrigido com espaçamento)
${CREATED_USER_ID}     None
${CREATED_MOVIE_ID}    None
${CREATED_THEATER_ID}  None
${CREATED_SESSION_ID}  None
${CREATED_RESERVATION_ID} None

# Prefixo para geração de dados
${NEW_USER_EMAIL_PREFIX}    testuser