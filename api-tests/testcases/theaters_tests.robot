*** Settings ***
Resource    ../resources/variables.robot
Resource    ../resources/keywords.robot
Library     RequestsLibrary

Test Setup    Login As Admin
Test Teardown    Cleanup Theater Teardown # Chamada correta

*** Variables ***
${THEATER_ENDPOINT}    /theaters/
${NEW_THEATER_NAME_PREFIX}    Teatro Aurora

*** Test Cases ***
CT22 - Listar todos os teatros (Público - 200)
    Create Unauthorized Session
    ${response}=    GET On Session    api    ${THEATER_ENDPOINT}
    Validate 200 OK Response    ${response}

CT21 - Criar um novo teatro (Admin - POST)
    [Documentation]    Criação de um novo teatro, testando privilégios de Admin.
    ${random_suffix}=    Generate Random String    4    [NUMBERS]
    ${new_name}=        Catenate    SEPARATOR=    ${NEW_THEATER_NAME_PREFIX}    ${random_suffix}
    
    Create Authorized Session    ${TOKEN_ADMIN}
    ${body}=    Create Dictionary    name=${new_name}    location=Centro    capacity=150
    ${response}=    POST On Session    api    ${THEATER_ENDPOINT}    json=${body}
    Validate 201 Created Response    ${response}
    
    ${theater_id}=    Get From Dictionary    ${response.json()}    _id
    Set Global Variable    ${CREATED_THEATER_ID}    ${theater_id}

CT26 - Tentativa de Criar Teatro (Usuário Padrão - 403)
    Login As User
    Create Authorized Session    ${TOKEN_USER}
    ${body}=    Create Dictionary    name=Teatro Proibido    location=Bairro    capacity=50
    ${response}=    POST On Session    api    ${THEATER_ENDPOINT}    json=${body}
    Validate 403 Forbidden Response    ${response}

CT24 - Atualizar dados de um teatro (Admin - PUT)
    [Setup]    Run Keywords    Login As Admin    AND    CT21 - Criar um novo teatro (Admin - POST)

    Create Authorized Session    ${TOKEN_ADMIN}
    ${update_body}=    Create Dictionary    name=Teatro Central    capacity=160
    ${response}=    PUT On Session    api    ${THEATER_ENDPOINT}${CREATED_THEATER_ID}    json=${update_body}
    Validate 200 OK Response    ${response}

CT25 - Excluir um teatro (Admin - DELETE)
    [Setup]    Run Keywords    Login As Admin    AND    CT21 - Criar um novo teatro (Admin - POST)

    Create Authorized Session    ${TOKEN_ADMIN}
    ${response}=    DELETE On Session    api    ${THEATER_ENDPOINT}${CREATED_THEATER_ID}
    Validate 200 OK Response    ${response}
    
    Set Global Variable    ${CREATED_THEATER_ID}    None