*** Settings ***
Resource    ../resources/variables.robot
Resource    ../resources/keywords.robot
Library     RequestsLibrary
Library     String

Test Setup       Login As Admin
Test Teardown    Full Cleanup Teardown

*** Variables ***
${SESSION_ENDPOINT}    /sessions/

*** Test Cases ***
CT28 - Listar todas as sessões (Público - 200)
    [Documentation]    Lista todas as sessões disponíveis sem autenticação.
    Create Unauthorized Session
    ${response}=    GET On Session    api    ${SESSION_ENDPOINT}
    Validate 200 OK Response    ${response}


CT27 - Criar uma nova sessão (Admin - POST)
    [Documentation]    Cria uma nova sessão com Movie e Theater válidos.
    ${session_id}=    Create New Session As Admin
    Should Not Be Equal As Strings    ${session_id}    None
    Set Global Variable    ${CREATED_SESSION_ID}    ${session_id}


CT32 - Tentativa de criar sessão com ID Inexistente (400)
    [Documentation]    Testa erro ao tentar criar sessão com Movie inexistente.
    Login As Admin
    Create Authorized Session    ${TOKEN_ADMIN}

    ${fake_movie_id}=    Set Variable    000000000000000000000000
    ${fake_theater_id}=  Set Variable    000000000000000000000000

    ${body}=    Create Dictionary
    ...    movie=${fake_movie_id}
    ...    theater=${fake_theater_id}
    ...    startTime=2026-01-01T10:00:00Z
    ...    price=15.0

    ${response}=    POST On Session    api    ${SESSION_ENDPOINT}    json=${body}    expected_status=any
    Validate 404 Not Found Response    ${response}



CT30 - Atualizar dados de uma sessão (Admin - PUT)
    [Documentation]    Atualiza horário e preço de uma sessão existente.
    ${session_id}=    Create New Session As Admin
    Create Authorized Session    ${TOKEN_ADMIN}
    ${update_body}=    Create Dictionary    startTime=2025-12-31T22:30:00Z    price=30.0
    ${response}=    PUT On Session    api    ${SESSION_ENDPOINT}${session_id}    json=${update_body}
    Validate 200 OK Response    ${response}


CT31 - Excluir uma sessão (Admin - DELETE)
    [Documentation]    Exclui uma sessão existente.
    ${session_id}=    Create New Session As Admin
    Create Authorized Session    ${TOKEN_ADMIN}
    ${response}=    DELETE On Session    api    ${SESSION_ENDPOINT}${session_id}
    Validate 200 OK Response    ${response}
    Log To Console    🗑️ Sessão ${session_id} excluída com sucesso.
    Set Global Variable    ${CREATED_SESSION_ID}    None
