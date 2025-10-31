*** Settings ***
Library    Browser
Library    Collections
Library    String
Library    FakerLibrary

*** Keywords ***
Open Cinema App
    New Browser    headless=False
    New Page    ${BASE_URL}

Login As User
    Click    text=Login
    Fill Text    input[name="email"]    ${USER_EMAIL}
    Fill Text    input[name="password"]    ${USER_PASS}
    Click    text=Entrar
    Wait For Elements State    text=Bem-vindo    visible    5s

Login As Admin
    Click    text=Login
    Fill Text    input[name="email"]    ${ADMIN_EMAIL}
    Fill Text    input[name="password"]    ${ADMIN_PASS}
    Click    text=Entrar
    Wait For Elements State    text=Dashboard    visible    5s

Logout
    Click    text=Sair
    Wait For Elements State    text=Login    visible    5s

Select Movie And Session
    Click    text=Filmes
    Click    css=.movie-card >> nth=0
    Click    text=Selecionar Sessão
    Click    css=.session-card >> nth=0

Reserve Seats
    Click    text=Assento A1
    Click    text=Assento A2
    Click    text=Confirmar Reserva
    Wait For Elements State    text=Reserva confirmada    visible    10s
