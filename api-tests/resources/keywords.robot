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


# ==========================================================
# AUTHENTICAÇÃO E SESSÕES
# ==========================================================
*** Keywords ***
Login As Admin
    ${token}=    Get Admin Token Manual
    Set Global Variable    ${TOKEN_ADMIN}    ${token}
    Log To Console    ✅ Token Admin Gerado com sucesso (WORKAROUND).

Login As User
    Create Session    api    ${BASE_URL}
    ${body}=    Create Dictionary    email=${USER_EMAIL}    password=${USER_PASSWORD}
    ${response}=    POST On Session    api    /auth/login    json=${body}
    Validate 200 OK Response    ${response}
    ${data}=     Get From Dictionary    ${response.json()}    data
    ${token}=    Get From Dictionary    ${data}    token
    Set Global Variable    ${TOKEN_USER}    ${token}
    Log To Console    ✅ Token User: ${token}

Create Authorized Session
    [Arguments]    ${token}
    ${auth_header}=    Catenate    SEPARATOR=    Bearer    ${token}
    Create Session    api    ${BASE_URL}    headers={"Authorization": "${auth_header}", "Content-Type": "application/json"}

Create Unauthorized Session
    Create Session    api    ${BASE_URL}    headers={"Content-Type": "application/json"}


# ==========================================================
# VALIDAÇÕES REUTILIZÁVEIS
# ==========================================================
Validate 200 OK Response
    [Arguments]    ${response}
    Should Be Equal As Integers    ${response.status_code}    200
    Log To Console    🟢 Status 200 OK validado.

Validate 201 Created Response
    [Arguments]    ${response}
    Should Be Equal As Integers    ${response.status_code}    201
    Log To Console    🟢 Status 201 Created validado.

Validate 400 Bad Request Response
    [Arguments]    ${response}
    Should Be Equal As Integers    ${response.status_code}    400
    Log To Console    🟠 Status 400 Bad Request validado.

Validate 401 Unauthorized Response
    [Arguments]    ${response}
    Should Be Equal As Integers    ${response.status_code}    401
    Log To Console    🔒 Status 401 Unauthorized validado.

Validate 403 Forbidden Response
    [Arguments]    ${response}
    Should Be Equal As Integers    ${response.status_code}    403
    Log To Console    🚫 Status 403 Forbidden validado.

Validate 404 Not Found Response
    [Arguments]    ${response}
    Should Be Equal As Integers    ${response.status_code}    404
    Log To Console    🔍 Status 404 Not Found validado.


# ==========================================================
# FILMES (MOVIES)
# ==========================================================
Create New Movie As Admin
    [Documentation]    Cria um filme via API autenticado como Admin e retorna o ID corretamente.
    Login As Admin
    Create Authorized Session    ${TOKEN_ADMIN}

    ${random_suffix}=    Generate Random String    5    [LETTERS]
    ${title}=    Catenate    SEPARATOR=    Novo Filme ${random_suffix}

    ${body}=    Create Dictionary
    ...    customId=${random_suffix}
    ...    title=${title}
    ...    synopsis=Filme criado automaticamente para testes.
    ...    director=John Doe
    ...    genres=["Action", "Adventure"]
    ...    duration=120
    ...    classification=PG-13
    ...    poster=poster_${random_suffix}.jpg
    ...    releaseDate=2025-01-01

    ${response}=    POST On Session    api    /movies/    json=${body}    expected_status=any
    Log To Console    🎬 Tentativa de criação de filme — Status: ${response.status_code}
    Validate 201 Created Response    ${response}

    ${json}=    Set Variable    ${response.json()}
    ${data}=    Get From Dictionary    ${json}    data
    ${movie_id}=    Get From Dictionary    ${data}    _id
    Log To Console    🎞️ Filme criado com ID: ${movie_id}

    RETURN    ${movie_id}

# ==========================================================
# TEATROS (THEATERS)
# ==========================================================
Create New Theater As Admin
    [Documentation]    Cria um teatro via API autenticado como Admin e retorna o ID.
    Login As Admin
    Create Authorized Session    ${TOKEN_ADMIN}

    ${random_suffix}=    Generate Random String    4    [NUMBERS]
    ${name}=    Catenate    SEPARATOR=    Teatro ${random_suffix}

    ${body}=    Create Dictionary
    ...    name=${name}
    ...    location=Centro
    ...    capacity=150

    ${response}=    POST On Session    api    /theaters/    json=${body}    expected_status=any
    Log To Console    🎭 Tentativa de criação de teatro — Status: ${response.status_code}
    Validate 201 Created Response    ${response}

    ${json}=    Set Variable    ${response.json()}
    ${data}=    Get From Dictionary    ${json}    data
    ${theater_id}=    Get From Dictionary    ${data}    _id
    Log To Console    🎟️ Teatro criado com ID: ${theater_id}

    RETURN    ${theater_id}


Cleanup Theater Teardown
    Log To Console    ...🧹 Limpando teatros criados no teste.
    Run Keyword If    '${CREATED_THEATER_ID}' != 'None'    Delete Theater By ID

Delete Theater By ID
    [Arguments]    ${theater_id}=${CREATED_THEATER_ID}
    Create Authorized Session    ${TOKEN_ADMIN}
    ${resp}=    DELETE On Session    api    /theaters/${theater_id}    expected_status=any
    Log To Console    ...🎭 Teatro ${theater_id} removido durante cleanup.


# ==========================================================
# SESSÕES (SESSIONS)

Create New Session As Admin
    [Documentation]    Cria uma sessão com Movie e Theater válidos e retorna o ID.
    ${movie_id}=    Create New Movie As Admin
    ${theater_id}=    Create New Theater As Admin

    Create Authorized Session    ${TOKEN_ADMIN}

    ${body}=    Create Dictionary
    ...    movie=${movie_id}
    ...    theater=${theater_id}
    ...    datetime=2025-12-31T20:00:00
    ...    fullPrice=25.0
    ...    halfPrice=12.5

    ${response}=    POST On Session    api    /sessions    json=${body}    expected_status=any
    Log To Console    🎬 Tentativa de criação de sessão — Status: ${response.status_code}
    Log To Console    💾 Body enviado: ${body}
    Log To Console    📡 Resposta: ${response.text}

    Validate 201 Created Response    ${response}

    ${data}=    Get From Dictionary    ${response.json()}    data
    ${session_id}=    Get From Dictionary    ${data}    _id
    Log To Console    🎟️ Sessão criada com ID: ${session_id}

    RETURN    ${session_id}

# ==========================================================
# DEPENDÊNCIAS DE RESERVAS
# ==========================================================
Create Session Dependencies
    [Documentation]    Cria Movie, Theater e Session válidos para uso em testes de reserva.
    ${movie_id}=    Create New Movie As Admin
    ${theater_id}=  Create New Theater As Admin

    Create Authorized Session    ${TOKEN_ADMIN}
    ${body}=    Create Dictionary
    ...    movie=${movie_id}
    ...    theater=${theater_id}
    ...    datetime=2025-12-31T20:00:00
    ...    fullPrice=25.0
    ...    halfPrice=12.5

    ${response}=    POST On Session    api    /sessions    json=${body}    expected_status=any
    Validate 201 Created Response    ${response}
    ${data}=    Get From Dictionary    ${response.json()}    data
    ${session_id}=    Get From Dictionary    ${data}    _id

    Set Global Variable    ${CREATED_MOVIE_ID}       ${movie_id}
    Set Global Variable    ${CREATED_THEATER_ID}     ${theater_id}
    Set Global Variable    ${CREATED_SESSION_ID}     ${session_id}

    Log To Console    🎬 Dependências criadas — Movie: ${movie_id}, Theater: ${theater_id}, Session: ${session_id}


# ==========================================================
# LIMPEZA DE DADOS (TEARDOWN)
# ==========================================================
Delete Resource By ID
    [Arguments]    ${resource_id}    ${endpoint}
    Run Keyword If    '${resource_id}' != 'None' and '${TOKEN_ADMIN}' != 'None'
    ...    Run Keywords
    ...    Create Authorized Session    ${TOKEN_ADMIN}    AND
    ...    DELETE On Session    api    ${endpoint}${resource_id}    expected_status=any

Full Cleanup Teardown
    Run Keywords
    ...    Delete Resource By ID    ${CREATED_RESERVATION_ID}    /reservations/    AND
    ...    Delete Resource By ID    ${CREATED_SESSION_ID}        /sessions/        AND
    ...    Delete Resource By ID    ${CREATED_MOVIE_ID}          /movies/          AND
    ...    Delete Resource By ID    ${CREATED_THEATER_ID}        /theaters/        AND
    ...    Delete Resource By ID    ${CREATED_USER_ID}           /users/

Cleanup Movie Teardown
    Log To Console    ...🧹 Limpando filmes criados no teste.
    Run Keyword If    '${CREATED_MOVIE_ID}' != 'None'    Delete Movie By ID

Delete Movie By ID
    [Arguments]    ${movie_id}=${CREATED_MOVIE_ID}
    Create Authorized Session    ${TOKEN_ADMIN}
    ${resp}=    DELETE On Session    api    /movies/${movie_id}    expected_status=any
    Log To Console    ...🎬 Filme ${movie_id} removido durante cleanup.
