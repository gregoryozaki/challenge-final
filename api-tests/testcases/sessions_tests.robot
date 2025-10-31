*** Settings ***
Resource    ../resources/variables.robot
Resource    ../resources/keywords.robot
Library     RequestsLibrary

Test Setup    Login As Admin
Test Teardown    Full Cleanup Teardown  # Chamada correta para limpeza completa

*** Variables ***
${SESSION_ENDPOINT}    /sessions/

*** Keywords ***
# Keyword que cria Movie e Theater (dependências)
Create Session Dependencies
    Log    Criando Movie e Theater para dependência da Session.
    
    # 1. Cria um Movie 
    ${movie_random}=    Generate Random String    5    [LETTERS]
    Create Authorized Session    ${TOKEN_ADMIN}
    ${movie_body}=    Create Dictionary    title=Filme Teste Session ${movie_random}    release_date=2026-01-01    duration=90    genre=Comedy
    ${movie_response}=    POST On Session    api    /movies    json=${movie_body}
    ${movie_id}=    Get From Dictionary    ${movie_response.json()}    _id
    Set Global Variable    ${CREATED_MOVIE_ID}    ${movie_id}
    
    # 2. Cria um Theater
    ${theater_random}=    Generate Random String    4    [NUMBERS]
    ${theater_body}=    Create Dictionary    name=Teatro Teste Session ${theater_random}    location=East    capacity=100
    ${theater_response}=    POST On Session    api    /theaters    json=${theater_body}
    ${theater_id}=    Get From Dictionary    ${theater_response.json()}    _id
    Set Global Variable    ${CREATED_THEATER_ID}    ${theater_id}

*** Test Cases ***
CT28 - Listar todas as sessões (Público - 200)
    Create Unauthorized Session
    ${response}=    GET On Session    api    ${SESSION_ENDPOINT}
    Validate 200 OK Response    ${response}

CT27 - Criar uma nova sessão (Admin - POST)
    [Setup]    Run Keywords    Login As Admin    AND    Create Session Dependencies
    
    Create Authorized Session    ${TOKEN_ADMIN}
    ${session_body}=    Create Dictionary    movie_id=${CREATED_MOVIE_ID}    theater_id=${CREATED_THEATER_ID}    time=20:00    price=25.0
    ${response}=    POST On Session    api    ${SESSION_ENDPOINT}    json=${session_body}
    Validate 201 Created Response    ${response}
    
    ${session_id}=    Get From Dictionary    ${response.json()}    _id
    Set Global Variable    ${CREATED_SESSION_ID}    ${session_id}

CT32 - Tentativa de criar sessão com ID Inexistente (400)
    [Setup]    Login As Admin
    
    Create Authorized Session    ${TOKEN_ADMIN}
    # Tenta usar um ID de Movie inexistente
    ${session_body}=    Create Dictionary    movie_id=999999999999999999999999    theater_id=${CREATED_THEATER_ID}    time=10:00    price=15.0
    ${response}=    POST On Session    api    ${SESSION_ENDPOINT}    json=${session_body}
    Validate 400 Bad Request Response    ${response}
    
CT30 - Atualizar dados de uma sessão (Admin - PUT)
    [Setup]    Run Keywords    Login As Admin    AND    CT27 - Criar uma nova sessão (Admin - POST)

    Create Authorized Session    ${TOKEN_ADMIN}
    ${update_body}=    Create Dictionary    time=22:30    price=30.0
    ${response}=    PUT On Session    api    ${SESSION_ENDPOINT}${CREATED_SESSION_ID}    json=${update_body}
    Validate 200 OK Response    ${response}

CT31 - Excluir uma sessão (Admin - DELETE)
    [Setup]    Run Keywords    Login As Admin    AND    CT27 - Criar uma nova sessão (Admin - POST)

    Create Authorized Session    ${TOKEN_ADMIN}
    ${response}=    DELETE On Session    api    ${SESSION_ENDPOINT}${CREATED_SESSION_ID}
    Validate 200 OK Response    ${response}
    
    Set Global Variable    ${CREATED_SESSION_ID}    None