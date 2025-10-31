*** Settings ***
Resource    ../resources/variables.robot
Resource    ../resources/keywords.robot
Library     Browser

*** Test Cases ***
CT03 - Fluxo E2E Crítico: Compra de Ingressos
    Open Cinema App
    Login As User
    Select Movie And Session
    Reserve Seats
    Logout

CT04 - Tentativa de Reserva como Guest
    Open Cinema App
    Click    text=Filmes
    Click    css=.movie-card >> nth=0
    Click    text=Selecionar Sessão
    Click    text=Assento A1
    Click    text=Confirmar Reserva
    Wait For Elements State    text=Login    visible    5s
