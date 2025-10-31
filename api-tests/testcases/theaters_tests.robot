*** Settings ***
Resource    ../resources/variables.robot
Resource    ../resources/keywords.robot
Library     RequestsLibrary
Library     String

Test Setup    Login As Admin
Test Teardown    Delete Resource By ID    ${CREATED_THEATER_ID}    /theaters/

*** Variables ***
${NEW_THEATER_NAME}    Teatro Aurora ${random.string(5, [NUMBERS])}
${UPDATED_THEATER_NAME}  Teatro Moderno

*** Test Cases ***
CT22 - Listar todos os teatros (Público - 200)
    Create Unauthorized Session
    ${response}=    GET On Session    api    /theaters
    Validate 200 OK Response    ${response}

CT21 - Criar um novo teatro (Admin - POST)
    # Autenticado como Admin via Test Setup
    Create Authorized Session    ${TOKEN_ADMIN}
    ${body}=    Create Dictionary    name=${NEW_THEATER_NAME}    location=Centro    capacity=150
    ${response}=    POST On Session    api    /theaters    json=${body}
    Validate 201 Created Response    ${response}
    
    # Manipulação de Dados: Capturar ID
    ${theater_id}=    Get From Dictionary    ${response.json()}    _id
    Set Global Variable    ${CREATED_THEATER_ID}    ${theater_id}

CT26 - Tentativa de Criar Teatro (Usuário Padrão - 403)
    Login As User
    Create Authorized Session    ${TOKEN_USER}
    ${body}=    Create Dictionary    name=Teatro Proibido    location=Bairro    capacity=50
    ${response}=    POST On Session    api    /theaters    json=${body}
    Validate 403 Forbidden Response    ${response}

CT24 - Atualizar dados de um teatro (Admin - PUT)
    # Pré-requisito: CT21 deve ter criado o recurso
    Run Keyword If    '${CREATED_THEATER_ID}' == 'None'    Fail    msg=Teatro não criado.
    Create Authorized Session    ${TOKEN_ADMIN}
    ${update_body}=    Create Dictionary    name=${UPDATED_THEATER_NAME}    capacity=160
    ${response}=    PUT On Session    api    /theaters/${CREATED_THEATER_ID}    json=${update_body}
    Validate 200 OK Response    ${response}

CT25 - Excluir um teatro (Admin - DELETE)
    # Pré-requisito: CT21 deve ter criado o recurso
    Run Keyword If    '${CREATED_THEATER_ID}' == 'None'    Fail    msg=Teatro não criado.
    Create Authorized Session    ${TOKEN_ADMIN}
    ${response}=    DELETE On Session    api    /theaters/${CREATED_THEATER_ID}
    Validate 200 OK Response    ${response}
    
    # Limpeza de Variável Global para evitar erro no Teardown
    Set Global Variable    ${CREATED_THEATER_ID}    None