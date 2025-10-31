*** Settings ***
Resource    ../resources/variables.robot
Resource    ../resources/keywords.robot
Library     RequestsLibrary
Library     String

Test Setup    Login As Admin
Test Teardown    Cleanup Movie    ${CREATED_MOVIE_ID}
Test Teardown    Delete Resource By ID    ${CREATED_THEATER_ID}    /theaters/
Test Teardown    Delete Resource By ID    ${CREATED_SESSION_ID}    /sessions/

*** Keywords ***
# Keyword para criar dependências necessárias (Filme e Teatro)
Create Session Dependencies
    # Cria um Movie para a Session
    Create Authorized Session    ${TOKEN_ADMIN}
    ${movie_body}=    Create Dictionary    title=Filme Teste Session    release_date=2026-01-01    duration=90    genre=Comedy
    ${movie_response}=    POST On Session    api    /movies    json=${movie_body}
    ${movie_id}=    Get From Dictionary    ${movie_response.json()}    _id
    Set Global Variable    ${CREATED_MOVIE_ID}    ${movie_id}
    
    # Cria um Theater para a Session
    ${theater_body}=    Create Dictionary    name=Teatro Teste Session    location=East    capacity=100
    ${theater_response}=    POST On Session    api    /theaters    json=${theater_body}
    ${theater_id}=    Get From Dictionary    ${theater_response.json()}    _id
    Set Global Variable    ${CREATED_THEATER_ID}    ${theater_id}

*** Test Cases ***
CT28 - Listar todas as sessões (Público - 200)
    Create Unauthorized Session
    ${response}=    GET On Session    api    /sessions
    Validate 200 OK Response    ${response}

CT27 - Criar uma nova sessão (Admin - POST)
    [Setup]    Create Session Dependencies
    # Autenticado como Admin via Test Setup
    Create Authorized Session    ${TOKEN_ADMIN}
    ${session_body}=    Create Dictionary    movie_id=${CREATED_MOVIE_ID}    theater_id=${CREATED_THEATER_ID}    time=20:00
    ${response}=    POST On Session    api    /sessions    json=${session_body}
    Validate 201 Created Response    ${response}
    
    # Manipulação de Dados: Capturar ID
    ${session_id}=    Get From Dictionary    ${response.json()}    _id
    Set Global Variable    ${CREATED_SESSION_ID}    ${session_id}

CT32 - Tentativa de criar sessão com ID Inexistente (400)
    # Tenta usar IDs que não existem
    Create Authorized Session    ${TOKEN_ADMIN}
    ${session_body}=    Create Dictionary    movie_id=999999999999999999999999    theater_id=${CREATED_THEATER_ID}    time=10:00
    ${response}=    POST On Session    api    /sessions    json=${session_body}
    Validate 400 Bad Request Response    ${response}
    
CT30 - Atualizar dados de uma sessão (Admin - PUT)
    [Setup]    Create Session Dependencies ; Run Keyword If    '${CREATED_SESSION_ID}' == 'None'    CT27 - Criar uma nova sessão (Admin - POST)
    # Pré-requisito: CT27 deve ter rodado e criado a sessão
    Create Authorized Session    ${TOKEN_ADMIN}
    ${update_body}=    Create Dictionary    time=22:30
    ${response}=    PUT On Session    api    /sessions/${CREATED_SESSION_ID}    json=${update_body}
    Validate 200 OK Response    ${response}

CT31 - Excluir uma sessão (Admin - DELETE)
    [Setup]    Create Session Dependencies ; Run Keyword If    '${CREATED_SESSION_ID}' == 'None'    CT27 - Criar uma nova sessão (Admin - POST)
    # Pré-requisito: CT27 deve ter rodado e criado a sessão
    Create Authorized Session    ${TOKEN_ADMIN}
    ${response}=    DELETE On Session    api    /sessions/${CREATED_SESSION_ID}
    Validate 200 OK Response    ${response}
    
    Set Global Variable    ${CREATED_SESSION_ID}    None