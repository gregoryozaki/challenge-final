*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    String
Library    ../resources/admin_token_helper.py

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

# IDs criados dinamicamente
${CREATED_USER_ID}          None
${CREATED_MOVIE_ID}         None
${CREATED_THEATER_ID}       None
${CREATED_SESSION_ID}       None
${CREATED_RESERVATION_ID}   None

# Prefixos para dados temporários
${NEW_USER_EMAIL_PREFIX}    testuser
${USER_EMAIL_TEMP}          temp.user@cinema.com



*** Keywords ***
# ==========================================================
# AUTHENTICAÇÃO E SESSÕES
# ==========================================================
Login As Admin
    ${token}=    Get Admin Token Manual
    Set Global Variable    ${TOKEN_ADMIN}    ${token}
    Log    Token Admin Gerado com sucesso (WORKAROUND).

Login As User
    Create Session    api    ${BASE_URL}
    ${body}=    Create Dictionary    email=${USER_EMAIL}    password=${USER_PASSWORD}
    ${response}=    POST On Session    api    /auth/login    json=${body}
    Validate 200 OK Response    ${response}
    ${data}=     Get From Dictionary    ${response.json()}    data
    ${token}=    Get From Dictionary    ${data}    token
    Set Global Variable    ${TOKEN_USER}    ${token}

Create Authorized Session
    [Arguments]    ${token}
    Create Session    api    ${BASE_URL}    headers={"Authorization": "${token}", "Content-Type": "application/json"}

Create Unauthorized Session
    Create Session    api    ${BASE_URL}    headers={"Content-Type": "application/json"}


# ==========================================================
# VALIDAÇÕES REUTILIZÁVEIS
# ==========================================================
Validate 200 OK Response
    [Arguments]    ${response}
    Should Be Equal As Integers    ${response.status_code}    200

Validate 201 Created Response
    [Arguments]    ${response}
    Should Be Equal As Integers    ${response.status_code}    201

Validate 400 Bad Request Response
    [Arguments]    ${response}
    Should Be Equal As Integers    ${response.status_code}    400
    Log    Status 400 (Bad Request) Validado.

Validate 401 Unauthorized Response
    [Arguments]    ${response}
    Should Be Equal As Integers    ${response.status_code}    401
    Log    Status 401 (Unauthorized) Validado.

Validate 403 Forbidden Response
    [Arguments]    ${response}
    Should Be Equal As Integers    ${response.status_code}    403
    Log    Status 403 (Forbidden) Validado.


# ==========================================================
# LIMPEZA DE DADOS (TEARDOWN)
# ==========================================================
*** Keywords ***
# Keyword genérica para deletar recursos criados
Delete Resource By ID
    [Arguments]    ${resource_id}    ${endpoint}
    Run Keyword If    '${resource_id}' != 'None' and '${TOKEN_ADMIN}' != 'None'
    ...    Run Keywords
    ...    Create Authorized Session    ${TOKEN_ADMIN}    AND
    ...    DELETE On Session    api    ${endpoint}${resource_id}

# Limpeza geral — chamada no Test Teardown
Full Cleanup Teardown
    Run Keywords
    ...    Delete Resource By ID    ${CREATED_RESERVATION_ID}    /reservations/    AND
    ...    Delete Resource By ID    ${CREATED_SESSION_ID}        /sessions/        AND
    ...    Delete Resource By ID    ${CREATED_MOVIE_ID}          /movies/          AND
    ...    Delete Resource By ID    ${CREATED_THEATER_ID}        /theaters/        AND
    ...    Delete Resource By ID    ${CREATED_USER_ID}           /users/
