*** Settings ***
Resource    ../resources/variables.robot
Resource    ../resources/keywords.robot
Library     RequestsLibrary
Library     String

Test Setup    Create Session Dependencies ; Login As User
Test Teardown    Delete Resource By ID    ${CREATED_RESERVATION_ID}    /reservations/
Test Teardown    Cleanup Movie    ${CREATED_MOVIE_ID}
Test Teardown    Delete Resource By ID    ${CREATED_THEATER_ID}    /theaters/

*** Keywords ***
# Reutiliza a keyword de sessions_tests.robot (Se necessário, coloque em keywords.robot)
Create Session Dependencies
    # Cria um Movie para a Session
    Login As Admin
    Create Authorized Session    ${TOKEN_ADMIN}
    ${movie_body}=    Create Dictionary    title=Filme Reserva Teste    release_date=2026-02-01    duration=100    genre=Action
    ${movie_response}=    POST On Session    api    /movies    json=${movie_body}
    ${movie_id}=    Get From Dictionary    ${movie_response.json()}    _id
    Set Global Variable    ${CREATED_MOVIE_ID}    ${movie_id}
    
    # Cria um Theater para a Session
    ${theater_body}=    Create Dictionary    name=Teatro Reserva Teste    location=South    capacity=10
    ${theater_response}=    POST On Session    api    /theaters    json=${theater_body}
    ${theater_id}=    Get From Dictionary    ${theater_response.json()}    _id
    Set Global Variable    ${CREATED_THEATER_ID}    ${theater_id}
    
    # Cria uma Session para a Reserva
    ${session_body}=    Create Dictionary    movie_id=${CREATED_MOVIE_ID}    theater_id=${CREATED_THEATER_ID}    time=18:00
    ${session_response}=    POST On Session    api    /sessions    json=${session_body}
    ${session_id}=    Get From Dictionary    ${session_response.json()}    _id
    Set Global Variable    ${CREATED_SESSION_ID}    ${session_id}

*** Test Cases ***
CT33 - Criação de Reserva (Usuário Padrão - POST)
    [Setup]    Create Session Dependencies ; Login As User
    # Autenticado como Usuário Padrão via Test Setup
    Create Authorized Session    ${TOKEN_USER}
    ${reservation_body}=    Create Dictionary    session_id=${CREATED_SESSION_ID}    seats=["A1", "A2"]
    ${response}=    POST On Session    api    /reservations    json=${reservation_body}
    Validate 201 Created Response    ${response}
    
    # Manipulação de Dados: Capturar ID
    ${reservation_id}=    Get From Dictionary    ${response.json()}    _id
    Set Global Variable    ${CREATED_RESERVATION_ID}    ${reservation_id}

CT34 - Listar Minhas Reservas (Usuário Padrão - /me)
    # Pré-requisito: CT33 deve ter rodado e criado uma reserva
    Run Keyword If    '${CREATED_RESERVATION_ID}' == 'None'    Fail    msg=Reserva não criada.
    Create Authorized Session    ${TOKEN_USER}
    ${response}=    GET On Session    api    /reservations/me
    Validate 200 OK Response    ${response}
    # Validação: Deve haver pelo menos 1 reserva (a que acabamos de criar)
    Should Be True    len(${response.json()}) >= 1

CT36 - Tentativa de Listar TODAS as Reservas (Usuário Padrão - 403)
    Create Authorized Session    ${TOKEN_USER}
    ${response}=    GET On Session    api    /reservations
    Validate 403 Forbidden Response    ${response}

CT35 - Listar TODAS as Reservas (Admin - 200)
    Login As Admin
    Create Authorized Session    ${TOKEN_ADMIN}
    ${response}=    GET On Session    api    /reservations
    Validate 200 OK Response    ${response}

CT37 - Atualizar Reserva (Admin - PUT)
    [Setup]    Create Session Dependencies ; CT33 - Criação de Reserva (Usuário Padrão - POST) ; Login As Admin
    # Pré-requisito: Reserva criada e logado como Admin
    Run Keyword If    '${CREATED_RESERVATION_ID}' == 'None'    Fail    msg=Reserva não criada.
    Create Authorized Session    ${TOKEN_ADMIN}
    ${update_body}=    Create Dictionary    status=confirmed
    ${response}=    PUT On Session    api    /reservations/${CREATED_RESERVATION_ID}    json=${update_body}
    Validate 200 OK Response    ${response}
    
CT38 - Excluir Reserva (Admin - DELETE)
    [Setup]    Create Session Dependencies ; CT33 - Criação de Reserva (Usuário Padrão - POST) ; Login As Admin
    # Pré-requisito: Reserva criada e logado como Admin
    Run Keyword If    '${CREATED_RESERVATION_ID}' == 'None'    Fail    msg=Reserva não criada.
    Create Authorized Session    ${TOKEN_ADMIN}
    ${response}=    DELETE On Session    api    /reservations/${CREATED_RESERVATION_ID}
    Validate 200 OK Response    ${response}
    
    Set Global Variable    ${CREATED_RESERVATION_ID}    None