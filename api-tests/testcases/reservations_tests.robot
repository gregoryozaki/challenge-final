*** Settings ***
Resource    ../resources/variables.robot
Resource    ../resources/keywords.robot
Library     RequestsLibrary

Test Teardown    Full Cleanup Teardown # Chamada correta para limpeza completa

*** Variables ***
${RESERVATION_ENDPOINT}    /reservations/

*** Keywords ***
# Keyword auxiliar para criar a Reserva (Pré-requisito)
Criar Reserva Pre-Requisito
    [Documentation]    Cria todas as dependências (Movie, Theater, Session) e faz a reserva como Usuário Padrão.
    Run Keywords    Create Session Dependencies    AND    Login As User
    
    Create Authorized Session    ${TOKEN_USER}
    ${reservation_body}=    Create Dictionary    session_id=${CREATED_SESSION_ID}    seats=["B1", "B2"]
    ${response}=    POST On Session    api    ${RESERVATION_ENDPOINT}    json=${reservation_body}
    Validate 201 Created Response    ${response}
    
    ${reservation_id}=    Get From Dictionary    ${response.json()}    _id
    Set Global Variable    ${CREATED_RESERVATION_ID}    ${reservation_id}
    Log    Reserva criada com ID: ${CREATED_RESERVATION_ID}


*** Test Cases ***
CT33 - Criação de Reserva (Usuário Padrão - POST)
    [Setup]    Run Keywords    Create Session Dependencies    AND    Login As User
    
    Create Authorized Session    ${TOKEN_USER}
    ${reservation_body}=    Create Dictionary    session_id=${CREATED_SESSION_ID}    seats=["A1", "A2"]
    ${response}=    POST On Session    api    ${RESERVATION_ENDPOINT}    json=${reservation_body}
    Validate 201 Created Response    ${response}
    
    ${reservation_id}=    Get From Dictionary    ${response.json()}    _id
    Set Global Variable    ${CREATED_RESERVATION_ID}    ${reservation_id}

CT34 - Listar Minhas Reservas (Usuário Padrão - /me)
    [Setup]    Run Keywords    Criar Reserva Pre-Requisito    AND    Login As User
    
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
    [Setup]    Run Keywords    Criar Reserva Pre-Requisito    AND    Login As Admin
    
    Create Authorized Session    ${TOKEN_ADMIN}
    ${response}=    GET On Session    api    ${RESERVATION_ENDPOINT}
    Validate 200 OK Response    ${response}

CT37 - Atualizar Reserva (Admin - PUT)
    [Setup]    Run Keywords    Criar Reserva Pre-Requisito    AND    Login As Admin
    
    Create Authorized Session    ${TOKEN_ADMIN}
    ${update_body}=    Create Dictionary    status=confirmed
    ${response}=    PUT On Session    api    ${RESERVATION_ENDPOINT}${CREATED_RESERVATION_ID}    json=${update_body}
    Validate 200 OK Response    ${response}
    
CT38 - Excluir Reserva (Admin - DELETE)
    [Setup]    Run Keywords    Criar Reserva Pre-Requisito    AND    Login As Admin
    
    Create Authorized Session    ${TOKEN_ADMIN}
    ${response}=    DELETE On Session    api    ${RESERVATION_ENDPOINT}${CREATED_RESERVATION_ID}
    Validate 200 OK Response    ${response}
    
    Set Global Variable    ${CREATED_RESERVATION_ID}    None