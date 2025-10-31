*** Settings ***
Resource    ../resources/variables.robot
Resource    ../resources/keywords.robot
Library     RequestsLibrary

*** Test Cases ***
CT01 - Registro de novo usuário válido
    Create Unauthorized Session
    # Gera email dinamicamente
    ${random_suffix}=    Generate Random String    5    [LETTERS]
    ${new_email}=        Catenate    SEPARATOR=@mail.com    ${NEW_USER_EMAIL_PREFIX}    ${random_suffix}
    
    ${body}=    Create Dictionary    email=${new_email}    password=123456    name=Test User
    ${response}=    POST On Session    api    /auth/register    json=${body}
    Validate 201 Created Response    ${response}

CT02 - Registro com e-mail existente (Falha - 400)
    # Tenta usar um email do seed data que já existe
    Create Unauthorized Session
    ${body}=    Create Dictionary    email=${USER_EMAIL}    password=123456    name=Test User
    ${response}=    POST On Session    api    /auth/register    json=${body}
    Validate 400 Bad Request Response    ${response}

CT03 - Login de sucesso (Admin - 200)
    Login As Admin
    Should Not Be Equal    ${TOKEN_ADMIN}    None

CT04 - Login de sucesso (Usuário - 200)
    Login As User
    Should Not Be Equal    ${TOKEN_USER}    None

CT05 - Login inválido retorna 401
    Create Unauthorized Session
    ${body}=    Create Dictionary    email=wrong@mail.com    password=wrong
    ${response}=    POST On Session    api    /auth/login    json=${body}
    Validate 401 Unauthorized Response    ${response}

CT06 - Acessar perfil autenticado (/auth/me - 200)
    Login As User
    Create Authorized Session    ${TOKEN_USER}
    ${response}=    GET On Session    api    /auth/me
    Validate 200 OK Response    ${response}
    
    # Validação de conteúdo
    ${user_email_response}=    Get From Dictionary    ${response.json()}    email
    Should Be Equal    ${user_email_response}    ${USER_EMAIL}

CT07 - Acessar perfil sem token (401)
    Create Unauthorized Session
    ${response}=    GET On Session    api    /auth/me
    Validate 401 Unauthorized Response    ${response}