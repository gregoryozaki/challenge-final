*** Settings ***
Resource    ../resources/variables.robot
Resource    ../resources/keywords.robot
Library     Browser

*** Test Cases ***
CT05 - Navegação Completa
    Open Cinema App
    Click    text=Filmes
    Wait For Elements State    css=.movie-card    visible    5s
    Click    text=Detalhes
    Go Back
    Click    text=Login

CT07 - Logout e Acesso Protegido
    Open Cinema App
    Login As User
    Logout
    Go To    ${BASE_URL}/reservas
    Wait For Elements State    text=Login    visible    5s
