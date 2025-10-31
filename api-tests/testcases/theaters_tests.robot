*** Settings ***
Resource    ../resources/variables.robot
Resource    ../resources/keywords.robot
Library     RequestsLibrary
Library     String

Test Setup       Login As Admin
Test Teardown    Cleanup Theater Teardown

*** Variables ***
${THEATER_ENDPOINT}    /theaters/
${NEW_THEATER_NAME_PREFIX}    Teatro Aurora

*** Test Cases ***
CT22 - Listar todos os teatros (Público - 200)
    [Documentation]    Lista todos os teatros sem autenticação.
    Create Unauthorized Session
    ${response}=    GET On Session    api    ${THEATER_ENDPOINT}
    Validate 200 OK Response    ${response}


CT21 - Criar um novo teatro (Admin - POST)
    [Documentation]    Cria um novo teatro com privilégios de Admin.
    ${theater_id}=    Create New Theater As Admin
    Should Not Be Equal As Strings    ${theater_id}    None
    Set Global Variable    ${CREATED_THEATER_ID}    ${theater_id}


CT26 - Tentativa de Criar Teatro (Usuário Padrão - 403)
    [Documentation]    Verifica se um usuário padrão é impedido de criar um teatro.
    Login As User
    Create Authorized Session    ${TOKEN_USER}
    ${body}=    Create Dictionary    name=Teatro Proibido    location=Bairro    capacity=50
    ${response}=    POST On Session    api    ${THEATER_ENDPOINT}    json=${body}    expected_status=any
    Run Keyword If    '${response.status_code}' == '401'    Validate 401 Unauthorized Response    ${response}
    ...    ELSE    Validate 403 Forbidden Response    ${response}


CT24 - Atualizar dados de um teatro (Admin - PUT)
    [Documentation]    Atualiza nome e capacidade de um teatro.
    ${theater_id}=    Create New Theater As Admin
    Create Authorized Session    ${TOKEN_ADMIN}
    ${update_body}=    Create Dictionary    name=Teatro Central    capacity=160
    ${response}=    PUT On Session    api    ${THEATER_ENDPOINT}${theater_id}    json=${update_body}
    Validate 200 OK Response    ${response}


CT25 - Excluir um teatro (Admin - DELETE)
    [Documentation]    Exclui um teatro criado anteriormente.
    ${theater_id}=    Create New Theater As Admin
    Create Authorized Session    ${TOKEN_ADMIN}
    ${response}=    DELETE On Session    api    ${THEATER_ENDPOINT}${theater_id}
    Validate 200 OK Response    ${response}
    Log To Console    🗑️ Teatro ${theater_id} excluído com sucesso.
    Set Global Variable    ${CREATED_THEATER_ID}    None
