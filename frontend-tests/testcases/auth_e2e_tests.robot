*** Settings ***
Resource    ../resources/variables.robot
Resource    ../pages/LoginPage.robot
Library     Browser

*** Test Cases ***
CTW01 - Registro e Login de Novo Usuário
    New Browser    ${BROWSER}    headless=true
    New Context
    New Page    ${BASE_URL}/register
    ${email}=    Generate Random String    5    [LETTERS]
    Fill Text    input[name="email"]    test${email}@mail.com
    Fill Text    input[name="password"]    123456
    Click    button[type="submit"]
    Wait For Elements State    text=Listagem de Filmes    visible
    Close Browser

CTW02 - Login com credenciais inválidas
    Open Login Page
    Login As User    invalid@mail.com    wrongpass
    Wait For Elements State    text=Credenciais inválidas    visible
    Close Browser
