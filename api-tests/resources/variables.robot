*** Variables ***
# Configuração de Ambiente
${BASE_URL}          http://localhost:5000/api/v1
${BASE_URL_LOCAL}    http://localhost:5000/api/v1  # Útil se precisar testar o front/API separadamente

# Credenciais Iniciais (Seed Data)
${ADMIN_EMAIL}       admin@example.com
${ADMIN_PASSWORD}    password123
${USER_EMAIL}        user@example.com
${USER_PASSWORD}     password123

# Variáveis Globais de Controle de Estado
${TOKEN_ADMIN}       None
${TOKEN_USER}        None

# Variáveis para IDs Criados/Manipulados (Garantir Testes Independentes)
${CREATED_USER_ID}   None
${CREATED_MOVIE_ID}  None
${CREATED_THEATER_ID} None
${CREATED_SESSION_ID} None
${CREATED_RESERVATION_ID} None