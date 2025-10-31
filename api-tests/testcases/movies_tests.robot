*** Settings ***
Resource    ../resources/variables.robot
Resource    ../resources/keywords.robot
Library     RequestsLibrary

Test Setup    Login As Admin
# Usando Run Keywords para combinar as ações de limpeza
Test Teardown    Run Keywords    Delete Resource By ID    ${CREATED_MOVIE_ID}    /movies/

*** Variables ***
${MOVIE_ENDPOINT}    /movies/
${UPDATED_MOVIE_TITLE_PREFIX}    Filme Atualizado

*** Test Cases ***
CT14 - Listar Filmes (Público - 200)
    Create Unauthorized Session
    ${response}=    GET On Session    api    ${MOVIE_ENDPOINT}
    Validate 200 OK Response    ${response}

CT16 - Criação de Filme (Admin - 201)
    # Autenticado como Admin via Test Setup
    ${random_suffix}=    Generate Random String    5    [LETTERS]
    ${new_title}=        Catenate    SEPARATOR=    Novo Filme    ${random_suffix}
    
    Create Authorized Session    ${TOKEN_ADMIN}
    ${body}=    Create Dictionary    title=${new_title}    release_date=2025-01-01    duration=120    genre=Action
    ${response}=    POST On Session    api    ${MOVIE_ENDPOINT}    json=${body}
    Validate 201 Created Response    ${response}
    
    # Capturar ID para PUT/DELETE e Teardown
    ${movie_id}=    Get From Dictionary    ${response.json()}    _id
    Set Global Variable    ${CREATED_MOVIE_ID}    ${movie_id}
    
CT17 - Tentativa de Criar Filme (Usuário Padrão - 403)
    Login As User
    Create Authorized Session    ${TOKEN_USER}
    ${body}=    Create Dictionary    title=Filme Proibido    release_date=2025-01-01    duration=100    genre=Drama
    ${response}=    POST On Session    api    ${MOVIE_ENDPOINT}    json=${body}
    Validate 403 Forbidden Response    ${response}
    
CT18 - Atualizar Filme (Admin - PUT)
    [Setup]    Run Keywords    Login As Admin    AND    CT16 - Criação de Filme (Admin - 201)
    
    ${random_suffix}=    Generate Random String    5    [NUMBERS]
    ${updated_title}=    Catenate    SEPARATOR=    ${UPDATED_MOVIE_TITLE_PREFIX}    ${random_suffix}

    Create Authorized Session    ${TOKEN_ADMIN}
    ${update_body}=    Create Dictionary    title=${updated_title}
    ${response}=    PUT On Session    api    ${MOVIE_ENDPOINT}${CREATED_MOVIE_ID}    json=${update_body}
    Validate 200 OK Response    ${response}
    
CT19 - Excluir Filme (Admin - DELETE)
    [Setup]    Run Keywords    Login As Admin    AND    CT16 - Criação de Filme (Admin - 201)

    Create Authorized Session    ${TOKEN_ADMIN}
    ${response}=    DELETE On Session    api    ${MOVIE_ENDPOINT}${CREATED_MOVIE_ID}
    Validate 200 OK Response    ${response}
    
    # Limpeza de Variável Global
    Set Global Variable    ${CREATED_MOVIE_ID}    None