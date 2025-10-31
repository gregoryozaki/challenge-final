*** Settings ***
Resource    ../resources/variables.robot
Resource    ../resources/keywords.robot
Library     RequestsLibrary

*** Test Cases ***
CT01 - Registro de novo usuário válido
    Create Session    api    ${BASE_URL}
    ${email}=    Generate Random String    5    [LETTERS]
    ${body}=    Create Dictionary    email=test${email}@mail.com    password=123456
    ${response}=    POST On Session    api    /auth/register    json=${body}
    Should Be Equal As Integers    ${response.status_code}    201

CT02 - Registro com e-mail existente
    ${body}=    Create Dictionary    email=${USER_EMAIL}    password=123456
    ${response}=    POST On Session    api    /auth/register    json=${body}
    Should Be Equal As Integers    ${response.status_code}    400

CT03 - Login de sucesso (Admin)
    Login As Admin

CT04 - Login de sucesso (Usuário)
    Login As User

CT05 - Login inválido retorna 401
    Create Session    api    ${BASE_URL}
    ${body}=    Create Dictionary    email=wrong@mail.com    password=wrong
    ${response}=    POST On Session    api    /auth/login    json=${body}
    Should Be Equal As Integers    ${response.status_code}    401

CT06 - Acessar perfil autenticado
    Login As User
    Create Authorized Session    ${TOKEN_USER}
    ${response}=    GET On Session    api    /auth/me
    Should Be Equal As Integers    ${response.status_code}    200

CT07 - Acessar perfil sem token
    Create Session    api    ${BASE_URL}
    ${response}=    GET On Session    api    /auth/me
    Should Be Equal As Integers    ${response.status_code}    401
