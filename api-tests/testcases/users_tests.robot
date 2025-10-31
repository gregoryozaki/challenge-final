*** Settings ***
Resource    ../resources/variables.robot
Resource    ../resources/keywords.robot
Library     RequestsLibrary
Library     String

Test Setup    Login As Admin
Test Teardown    Delete Resource By ID    ${CREATED_USER_ID}    /users/

*** Variables ***
${NEW_USER_EMAIL}    newuser${random.string(5, [LETTERS])}@cinema.com

*** Test Cases ***
CT08 - Listar todos os usuários (Admin - 200)
    # Autenticado como Admin via Test Setup
    Create Authorized Session    ${TOKEN_ADMIN}
    ${response}=    GET On Session    api    /users
    Validate 200 OK Response    ${response}
    # Validação: Deve retornar uma lista de usuários
    Should Be True    len(${response.json()}) >= 2

CT09 - Tentativa de listar usuários (Usuário Padrão - 403)
    Login As User
    Create Authorized Session    ${TOKEN_USER}
    ${response}=    GET On Session    api    /users
    Validate 403 Forbidden Response    ${response}
    
CT09 (b) - Tentativa de listar usuários (Sem Token - 401)
    Create Unauthorized Session
    ${response}=    GET On Session    api    /users
    Validate 401 Unauthorized Response    ${response}

CT11 - Atualizar dados de um usuário (Admin - PUT)
    # 1. Cria um usuário temporário (para o PUT)
    Create Unauthorized Session
    ${body}=    Create Dictionary    email=${NEW_USER_EMAIL}    password=senha123    name=Initial Name
    ${create_response}=    POST On Session    api    /auth/register    json=${body}
    ${user_id}=    Get From Dictionary    ${create_response.json()}    _id
    Set Global Variable    ${CREATED_USER_ID}    ${user_id}
    
    # 2. Executa o PUT como Admin
    Create Authorized Session    ${TOKEN_ADMIN}
    ${update_body}=    Create Dictionary    name=Updated Name
    ${update_response}=    PUT On Session    api    /users/${CREATED_USER_ID}    json=${update_body}
    Validate 200 OK Response    ${update_response}
    
    # Validação de Conteúdo: Busca e verifica a alteração
    ${get_response}=    GET On Session    api    /users/${CREATED_USER_ID}
    ${updated_name}=    Get From Dictionary    ${get_response.json()}    name
    Should Be Equal    ${updated_name}    Updated Name

CT12 - Excluir um usuário (Admin - DELETE)
    # Cria um usuário temporário para ser excluído
    Create Unauthorized Session
    ${body}=    Create Dictionary    email=todelete${random.string(5, [LETTERS])}@cinema.com    password=senha123    name=ToDelete
    ${create_response}=    POST On Session    api    /auth/register    json=${body}
    ${user_id}=    Get From Dictionary    ${create_response.json()}    _id
    
    # Executa o DELETE como Admin
    Create Authorized Session    ${TOKEN_ADMIN}
    ${delete_response}=    DELETE On Session    api    /users/${user_id}
    Validate 200 OK Response    ${delete_response}
    
    # Validação: Tenta buscar o usuário e espera 404 (Not Found) ou 403
    ${get_response}=    GET On Session    api    /users/${user_id}
    # A API deve retornar 403 (Forbidden) se a rota for de admin
    Validate 403 Forbidden Response    ${get_response}
    
CT13 - Tentativa de excluir usuário (Usuário Padrão - 403)
    # Cria um usuário para ser alvo
    Create Unauthorized Session
    ${body}=    Create Dictionary    email=alvo${random.string(5, [LETTERS])}@cinema.com    password=senha123    name=Alvo
    ${create_response}=    POST On Session    api    /auth/register    json=${body}
    ${user_id}=    Get From Dictionary    ${create_response.json()}    _id
    
    # Tenta excluir como usuário padrão
    Login As User
    Create Authorized Session    ${TOKEN_USER}
    ${response}=    DELETE On Session    api    /users/${user_id}
    Validate 403 Forbidden Response    ${response}
    
    # Limpeza manual do usuário criado pelo teste
    Delete Resource By ID    ${user_id}    /users/