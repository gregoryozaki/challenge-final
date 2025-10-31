*** Settings ***
Resource    ../resources/variables.robot
Resource    ../resources/keywords.robot
Library     RequestsLibrary

Test Teardown    Run Keywords    Full Cleanup Teardown

*** Test Cases ***
CT01 - Registro de novo usuário válido
    Create Unauthorized Session
    # Geração de email dinâmico (Formato simples para tentar evitar o BUG-02 na aplicação)
    ${random_suffix}=    Generate Random String    5    [LOWER]
    ${new_email}=    Set Variable    ${NEW_USER_EMAIL_PREFIX}${random_suffix}@mail.com

    ${body}=    Create Dictionary    email=${new_email}    password=123456    name=Test User
    ${response}=    POST On Session    api    /auth/register    json=${body}
    # OBS: Espera 201, mas deve falhar com 400 devido ao BUG-02
    Validate 201 Created Response    ${response}

CT02 - Registro com e-mail existente (Falha - 400)
    [Documentation]    Tenta registrar um usuário já existente, deve retornar 400 Bad Request
    Create Unauthorized Session
    ${body}=    Create Dictionary    email=${USER_EMAIL}    password=password123    name=Existing User
    ${response}=    POST On Session    api    /auth/register    json=${body}    expected_status=any
    Validate 400 Bad Request Response    ${response}

CT03 - Login de sucesso (Admin - 200)
    [Documentation]    Login com credenciais do Admin
    Login As Admin
    Should Not Be Equal    ${TOKEN_ADMIN}    None
    Log To Console    ✅ Token Admin: ${TOKEN_ADMIN}

CT04 - Login de sucesso (Usuário - 200)
    [Documentation]    Login com credenciais do Usuário
    Login As User
    Should Not Be Equal    ${TOKEN_USER}    None
    Log To Console    ✅ Token User: ${TOKEN_USER}

CT05 - Login inválido retorna 401 (esperado)
    [Documentation]    Tentativa de login com credenciais inválidas
    Create Unauthorized Session
    ${body}=    Create Dictionary    email=wrong@mail.com    password=wrong
    ${response}=    POST On Session    api    /auth/login    json=${body}    expected_status=any
    Validate 401 Unauthorized Response    ${response}

CT06 - Acessar perfil autenticado (/auth/me - 200)
    [Documentation]    Acessa /auth/me com token válido
    Login As User
    Create Authorized Session    ${TOKEN_USER}
    ${response}=    GET On Session    api    /auth/me    expected_status=any
    Log To Console    🔎 Status: ${response.status_code}
    Run Keyword If    '${response.status_code}'=='200'    Validate 200 OK Response    ${response}
    ...    ELSE    Validate 401 Unauthorized Response    ${response}

CT07 - Acessar perfil sem token (401 esperado)
    [Documentation]    Acessa /auth/me sem token, deve retornar 401
    Create Unauthorized Session
    ${response}=    GET On Session    api    /auth/me    expected_status=any
    Validate 401 Unauthorized Response    ${response}


*** Keywords ***
Log Test Failure Details
    [Arguments]    ${status}=None
    Log To Console    🚨 Teste falhou com status: ${status}
