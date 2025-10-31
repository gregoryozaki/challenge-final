*** Settings ***
Resource    ../resources/variables.robot
Resource    ../resources/keywords.robot
Library     RequestsLibrary
Library     String

Test Setup       Login As Admin
Test Teardown    Cleanup Movie Teardown

*** Variables ***
${MOVIE_ENDPOINT}    /movies/
${UPDATED_MOVIE_TITLE_PREFIX}    Filme Atualizado

*** Test Cases ***
CT14 - Listar Filmes (Público - 200)
    [Documentation]    Lista todos os filmes disponíveis sem autenticação.
    Create Unauthorized Session
    ${response}=    GET On Session    api    ${MOVIE_ENDPOINT}
    Validate 200 OK Response    ${response}


CT16 - Criação de Filme (Admin - 201)
    [Documentation]    Cria um novo filme com privilégios de Admin.
    ${movie_id}=    Create New Movie As Admin
    Should Not Be Equal As Strings    ${movie_id}    None
    Set Global Variable    ${CREATED_MOVIE_ID}    ${movie_id}


CT17 - Tentativa de Criar Filme (Usuário Padrão - 403)
    [Documentation]    Verifica se um usuário padrão é impedido de criar um filme.
    Login As User
    Create Authorized Session    ${TOKEN_USER}

    ${body}=    Create Dictionary
    ...    title=Filme Proibido
    ...    releaseDate=2025-01-01
    ...    duration=100
    ...    genre=Drama

    ${response}=    POST On Session    api    ${MOVIE_ENDPOINT}    json=${body}    expected_status=any
    Log To Console    🔍 Status retornado: ${response.status_code}
    Run Keyword If    '${response.status_code}' == '401'    Validate 401 Unauthorized Response    ${response}
    ...    ELSE    Validate 403 Forbidden Response    ${response}


CT18 - Atualizar Filme (Admin - PUT)
    [Documentation]    Atualiza o título de um filme criado anteriormente.
    ${movie_id}=    Create New Movie As Admin
    ${random_suffix}=    Generate Random String    4    [NUMBERS]
    ${updated_title}=    Catenate    SEPARATOR=    ${UPDATED_MOVIE_TITLE_PREFIX} ${random_suffix}

    Create Authorized Session    ${TOKEN_ADMIN}
    ${update_body}=    Create Dictionary    title=${updated_title}
    ${response}=    PUT On Session    api    ${MOVIE_ENDPOINT}${movie_id}    json=${update_body}    expected_status=any
    Validate 200 OK Response    ${response}
    Log To Console    🔄 Filme atualizado com novo título: ${updated_title}


CT19 - Excluir Filme (Admin - DELETE)
    [Documentation]    Exclui um filme criado anteriormente.
    ${movie_id}=    Create New Movie As Admin
    Create Authorized Session    ${TOKEN_ADMIN}
    ${response}=    DELETE On Session    api    ${MOVIE_ENDPOINT}${movie_id}    expected_status=any
    Validate 200 OK Response    ${response}
    Log To Console    🗑️ Filme ${movie_id} excluído com sucesso.
    Set Global Variable    ${CREATED_MOVIE_ID}    None
