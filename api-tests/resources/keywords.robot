*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    String

*** Keywords ***
# --- Autenticação e Sessões ---
Login As Admin
    Create Session    api    ${BASE_URL}
    ${body}=    Create Dictionary    email=${ADMIN_EMAIL}    password=${ADMIN_PASSWORD}
    ${response}=    POST On Session    api    /auth/login    json=${body}
    Validate 200 OK Response    ${response}
    ${token}=    Get From Dictionary    ${response.json()}    token
    Set Global Variable    ${TOKEN_ADMIN}    ${token}

Login As User
    Create Session    api    ${BASE_URL}
    ${body}=    Create Dictionary    email=${USER_EMAIL}    password=${USER_PASSWORD}
    ${response}=    POST On Session    api    /auth/login    json=${body}
    Validate 200 OK Response    ${response}
    ${token}=    Get From Dictionary    ${response.json()}    token
    Set Global Variable    ${TOKEN_USER}    ${token}

Create Authorized Session
    [Arguments]    ${token}
    Create Session    api    ${BASE_URL}    headers={"Authorization": "Bearer ${token}", "Content-Type": "application/json"}

Create Unauthorized Session
    Create Session    api    ${BASE_URL}    headers={"Content-Type": "application/json"}

# --- Validações Reutilizáveis ---
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

# --- Keywords de Limpeza de Dados (Para Teardown) ---
Cleanup Movie
    [Arguments]    ${movie_id}
    Run Keyword If    '${movie_id}' != 'None' and '${TOKEN_ADMIN}' != 'None'
    ...    Delete Resource By ID    ${movie_id}    /movies/
    
Delete Resource By ID
    [Arguments]    ${resource_id}    ${endpoint}
    Create Authorized Session    ${TOKEN_ADMIN}
    ${response}=    DELETE On Session    api    ${endpoint}${resource_id}
    # Não valida status, apenas tenta limpar (pode falhar se o recurso já foi deletado)