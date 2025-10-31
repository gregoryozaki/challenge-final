*** Settings ***
Resource    ../resources/variables.robot
Resource    ../resources/keywords.robot
Library     RequestsLibrary

# Teardown combinado com Run Keywords AND
Test Teardown    Run Keywords    Delete Resource By ID    ${CREATED_RESERVATION_ID}    /reservations/    AND
...              Delete Resource By ID    ${CREATED_MOVIE_ID}    /movies/    AND
...              Delete Resource By ID    ${CREATED_THEATER_ID}    /theaters/    AND
...              Delete Resource By ID    ${CREATED_SESSION_ID}    /sessions/
# Não precisa do Login As User no Teardown, pois as limpezas precisam do Admin

*** Variables ***
${RESERVATION_ENDPOINT}    /reservations/

*** Keywords ***
# Keyword que cria todas as dependências (Movie, Theater, Session)
Create Reservation Dependencies
    # Requer que o Admin esteja logado globalmente
    Login As Admin
    Log    Criando dependências para a Reserva (Movie, Theater, Session).
    
    # 1. Cria Movie, Theater e Session (Reutilizando a lógica de sessions_tests)
    ${movie_random}=    Generate Random String    5    [LETTERS]
    ${theater_random}=  Generate Random String    4    [NUMBERS]
    
    Create Authorized Session    ${TOKEN_ADMIN}
    ${movie_body}=    Create Dictionary    title=Filme Reserva Teste ${movie_random}    release_date=2026-02-01    duration=100    genre=Action
    ${movie_response}=    POST On Session    api    /movies    json=${movie_body}
    ${movie_id}=    Get From Dictionary    ${movie_response.json()}    _id
    Set Global Variable    ${CREATED_MOVIE_ID}    ${movie_id}
    
    ${theater_body}=    Create Dictionary    name=Teatro Reserva Teste ${theater_random}    location=South    capacity=10
    ${theater_response}=    POST On Session    api    /theaters    json=${theater_body}
    ${theater_id}=    Get From Dictionary    ${theater_response.json()}    _id
    Set Global Variable    ${CREATED_THEATER_ID}    ${theater_id}
    
    ${session_body}=    Create Dictionary    movie_id=${CREATED_MOVIE_ID}    theater_id=${CREATED_THEATER_ID}    time=18:00    price=20.0
    ${session_response}=    POST On Session    api    /sessions    json=${session_body}
    ${session_id}=    Get From Dictionary    ${session_response.json()}    _id
    Set Global Variable    ${CREATED_SESSION_ID}    ${session_id}


*** Test Cases ***
CT33 - Criação de Reserva (Usuário Padrão - POST)
    [Setup]    Run Keywords    Create Reservation Dependencies    AND    Login As User
    
    Create Authorized Session    ${TOKEN_USER}
    ${reservation_body}=    Create Dictionary    session_id=${CREATED_SESSION_ID}    seats=["A1", "A2"]
    ${response}=    POST On Session    api    ${RESERVATION_ENDPOINT}    json=${reservation_body}
    Validate 201 Created Response    ${response}
    
    ${reservation_id}=    Get From Dictionary    ${response.json()}    _id
    Set Global Variable    ${CREATED_RESERVATION_ID}    ${reservation_id}

CT34 - Listar Minhas Reservas (Usuário Padrão - /me)
    [Setup]    Run Keywords    CT33 - Criação de Reserva (Usuário Padrão - POST)    AND    Login As User
    
    Create Authorized Session    ${TOKEN_USER}
    ${response}=    GET On Session    api    ${RESERVATION_ENDPOINT}me
    Validate 200 OK Response    ${response}
    Should Be True    len(${response.json()}) >= 1

CT36 - Tentativa de Listar TODAS as Reservas (Usuário Padrão - 403)
    [Setup]    Login As User
    
    Create Authorized Session    ${TOKEN_USER}
    ${response}=    GET On Session    api    ${RESERVATION_ENDPOINT}
    Validate 403 Forbidden Response    ${response}

CT35 - Listar TODAS as Reservas (Admin - 200)
    [Setup]    Run Keywords    CT33 - Criação de Reserva (Usuário Padrão - POST)    AND    Login As Admin
    
    Create Authorized Session    ${TOKEN_ADMIN}
    ${response}=    GET On Session    api    ${RESERVATION_ENDPOINT}
    Validate 200 OK Response    ${response}

CT37 - Atualizar Reserva (Admin - PUT)
    [Setup]    Run Keywords    CT33 - Criação de Reserva (Usuário Padrão - POST)    AND    Login As Admin
    
    Create Authorized Session    ${TOKEN_ADMIN}
    ${update_body}=    Create Dictionary    status=confirmed
    ${response}=    PUT On Session    api    ${RESERVATION_ENDPOINT}${CREATED_RESERVATION_ID}    json=${update_body}
    Validate 200 OK Response    ${response}
    
CT38 - Excluir Reserva (Admin - DELETE)
    [Setup]    Run Keywords    CT33 - Criação de Reserva (Usuário Padrão - POST)    AND    Login As Admin
    
    Create Authorized Session    ${TOKEN_ADMIN}
    ${response}=    DELETE On Session    api    ${RESERVATION_ENDPOINT}${CREATED_RESERVATION_ID}
    Validate 200 OK Response    ${response}
    
    Set Global Variable    ${CREATED_RESERVATION_ID}    None