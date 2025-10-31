*** Settings ***
Resource    ../resources/variables.robot
Resource    ../resources/keywords.robot
Library     RequestsLibrary
Library     String

Test Setup    Login As Admin
Test Teardown    Cleanup Movie    ${CREATED_MOVIE_ID}

*** Variables ***
${NEW_MOVIE_TITLE}    Filme de Teste ${random.string(5, [LETTERS])}
${UPDATED_MOVIE_TITLE}  Filme Atualizado ${random.string(5, [LETTERS])}

*** Test Cases ***
CT14 - Listar Filmes (Público)
    Create Unauthorized Session
    ${response}=    GET On Session    api    /movies
    Validate 200 OK Response    ${response}
    # Validação de conteúdo: deve ser uma lista
    Should Be True    len(${response.json()}) >= 0

CT16 - Criação de Filme (Admin)
    # Autenticado como Admin via Test Setup
    Create Authorized Session    ${TOKEN_ADMIN}
    ${body}=    Create Dictionary    title=${NEW_MOVIE_TITLE}    release_date=2025-01-01    duration=120    genre=Action
    ${response}=    POST On Session    api    /movies    json=${body}
    Validate 201 Created Response    ${response}
    
    # Manipulação de Dados: Capturar ID para uso futuro (PUT/DELETE e Teardown)
    ${movie_id}=    Get From Dictionary    ${response.json()}    _id
    Set Global Variable    ${CREATED_MOVIE_ID}    ${movie_id}
    
CT17 - Tentativa de Criar Filme (Usuário Padrão - 403)
    Login As User
    Create Authorized Session    ${TOKEN_USER}
    ${body}=    Create Dictionary    title=Filme Proibido    release_date=2025-01-01    duration=100    genre=Drama
    ${response}=    POST On Session    api    /movies    json=${body}
    Validate 403 Forbidden Response    ${response}
    
CT18 - Atualizar Filme (Admin - Após Criação)
    # Pré-requisito: CT16 deve ter rodado e criado o filme
    Run Keyword If    '${CREATED_MOVIE_ID}' == 'None'    Fail    msg=Filme não criado.
    Create Authorized Session    ${TOKEN_ADMIN}
    ${update_body}=    Create Dictionary    title=${UPDATED_MOVIE_TITLE}
    ${response}=    PUT On Session    api    /movies/${CREATED_MOVIE_ID}    json=${update_body}
    Validate 200 OK Response    ${response}
    
    # Validação: Buscar o filme e garantir que foi atualizado
    Create Unauthorized Session
    ${get_response}=    GET On Session    api    /movies/${CREATED_MOVIE_ID}
    ${updated_title}=    Get From Dictionary    ${get_response.json()}    title
    Should Be Equal    ${updated_title}    ${UPDATED_MOVIE_TITLE}

CT19 - Excluir Filme (Admin)
    # Pré-requisito: CT16 deve ter rodado e criado o filme
    Run Keyword If    '${CREATED_MOVIE_ID}' == 'None'    Fail    msg=Filme não criado.
    Create Authorized Session    ${TOKEN_ADMIN}
    ${response}=    DELETE On Session    api    /movies/${CREATED_MOVIE_ID}
    Validate 200 OK Response    ${response}
    
    # Limpeza de Variável Global para evitar erro no Teardown
    Set Global Variable    ${CREATED_MOVIE_ID}    None