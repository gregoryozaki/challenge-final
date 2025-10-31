*** Settings ***
Resource    ../resources/variables.robot
Resource    ../resources/keywords.robot
Library     Browser

*** Test Cases ***
CT08 - Admin Acessa Dashboard
    Open Cinema App
    Login As Admin
    Wait For Elements State    text=Dashboard    visible    5s

CT09 - Admin Cria Novo Filme
    Login As Admin
    Click    text=Dashboard
    Click    text=Adicionar Filme
    Fill Text    input[name="title"]    Filme Robot Test
    Fill Text    input[name="director"]    QA Bot
    Click    text=Salvar
    Wait For Elements State    text=Filme criado com sucesso    visible    5s

CT10 - Admin Cria Filme Inválido
    Login As Admin
    Click    text=Dashboard
    Click    text=Adicionar Filme
    Fill Text    input[name="title"]    ${EMPTY}
    Click    text=Salvar
    Wait For Elements State    text=Campo obrigatório    visible    5s

CT11 - Admin Exclui Teatro
    Login As Admin
    Click    text=Dashboard
    Click    text=Teatros
    Click    css=.delete-button >> nth=0
    Wait For Elements State    text=Teatro removido    visible    5s
