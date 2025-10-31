*** Settings ***
Library    Browser

*** Keywords ***
Open Login Page
    New Browser    ${BROWSER}    headless=true
    New Context
    New Page    ${BASE_URL}/login

Login As User
    [Arguments]    ${email}    ${password}
    Fill Text    input[name="email"]    ${email}
    Fill Text    input[name="password"]    ${password}
    Click    button[type="submit"]

Validate Login Success
    Wait For Elements State    text=Listagem de Filmes    visible
