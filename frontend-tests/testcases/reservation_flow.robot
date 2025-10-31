*** Settings ***
Resource    ../resources/variables.robot
Library     Browser

*** Test Cases ***
CTW03 - Fluxo Completo de Compra
    New Browser    ${BROWSER}    headless=true
    New Context
    New Page    ${BASE_URL}/login
    Fill Text    input[name="email"]    ${USER_EMAIL}
    Fill Text    input[name="password"]    ${USER_PASS}
    Click    button[type="submit"]
    Wait For Elements State    text=Listagem de Filmes    visible
    Click    text=Filme 1
    Click    text=Reservar
    Click    text=Assento A1
    Click    text=Confirmar
    Wait For Elements State    text=Reserva confirmada    visible
    Close Browser
