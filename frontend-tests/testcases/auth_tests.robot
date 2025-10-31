*** Settings ***
Resource    ../resources/variables.robot
Resource    ../resources/keywords.robot
Library     Browser

*** Test Cases ***
CT01 - Registro e Login de Novo Usuário
    Open Cinema App
    Click    text=Registrar
    ${new_email}=    FakerLibrary.Email
    Fill Text    input[name="email"]    ${new_email}
    Fill Text    input[name="password"]    password123
    Click    text=Registrar
    Wait For Elements State    text=Home    visible    5s
    Logout

CT02 - Tentativa de Login com Credenciais Inválidas
    Open Cinema App
    Click    text=Login
    Fill Text    input[name="email"]    fake@user.com
    Fill Text    input[name="password"]    wrongpass
    Click    text=Entrar
    Wait For Elements State    text=Credenciais inválidas    visible    5s
