*** Settings ***
Resource    ../resources/variables.robot
Resource    ../resources/keywords.robot
Library     RequestsLibrary
Library     String

Test Setup       Login As Admin
Test Teardown    Run Keyword If    '${CREATED_USER_ID}' != 'None'    Safe Delete Created User

*** Variables ***
${USER_ENDPOINT}    /users/
${CREATED_USER_ID}  None

*** Keywords ***
Safe Delete Created User
    Log    🧹 Tentando deletar usuário criado: ${CREATED_USER_ID}
    Run Keyword And Ignore Error    Create Authorized Session    ${TOKEN_ADMIN}
    Run Keyword And Ignore Error    DELETE On Session    api    ${USER_ENDPOINT}${CREATED_USER_ID}
    Set Global Variable    ${CREATED_USER_ID}    None


*** Test Cases ***
CT08 - Listar todos os usuários (Admin - 200)
    [Documentation]  Deve retornar 200 e lista de usuários (mínimo 2 registros)
    Create Authorized Session    ${TOKEN_ADMIN}
    ${response}=    GET On Session    api    ${USER_ENDPOINT}
    Validate 200 OK Response    ${response}
    ${count}=    Get Length    ${response.json()["data"]}
    Should Be True    ${count} >= 2

CT09 - Tentativa de listar usuários (Usuário Padrão - 403)
    Login As User
    Create Authorized Session    Bearer ${TOKEN_USER}
    ${response}=    GET On Session    api    ${USER_ENDPOINT}    expected_status=any
    Validate 403 Forbidden Response    ${response}
    
CT10 (b) - Tentativa de listar usuários (Sem Token - 401)
    Create Unauthorized Session
    ${response}=    GET On Session    api    ${USER_ENDPOINT}    expected_status=any
    Validate 401 Unauthorized Response    ${response}


CT11 - Atualizar dados de um usuário (Admin - PUT)
    [Documentation]  Cria usuário temporário e atualiza nome via admin
    ${random_suffix}=    Generate Random String    5    [LETTERS]
    ${new_email}=   Set Variable    tempuser${random_suffix}@mail.com

    # Criação do usuário
    Create Unauthorized Session
    ${body}=    Create Dictionary    email=${new_email}    password=senha123    name=Initial Name
    ${create_response}=    POST On Session    api    /auth/register    json=${body}
    ${user_id}=    Get From Dictionary    ${create_response.json()["data"]}    _id
    Set Global Variable    ${CREATED_USER_ID}    ${user_id}

    # Atualiza como Admin
    Create Authorized Session    ${TOKEN_ADMIN}
    ${update_body}=    Create Dictionary    name=Updated Name
    ${update_response}=    PUT On Session    api    ${USER_ENDPOINT}${CREATED_USER_ID}    json=${update_body}
    Validate 200 OK Response    ${update_response}

    # Valida nome atualizado
    ${get_response}=    GET On Session    api    ${USER_ENDPOINT}${CREATED_USER_ID}
    ${updated_name}=    Get From Dictionary    ${get_response.json()["data"]}    name
    Should Be Equal    ${updated_name}    Updated Name

CT12 - Excluir um usuário (Admin - DELETE)
    [Documentation]  Cria usuário temporário e o exclui com sucesso
    ${random_suffix}=    Generate Random String    5    [LETTERS]
    ${email_to_delete}=  Set Variable    deletetest${random_suffix}@mail.com

    # Cria o usuário
    Create Unauthorized Session
    ${body}=    Create Dictionary    email=${email_to_delete}    password=senha123    name=DeleteMe
    ${create_response}=    POST On Session    api    /auth/register    json=${body}
    ${user_id}=    Get From Dictionary    ${create_response.json()["data"]}    _id
    Set Global Variable    ${CREATED_USER_ID}    ${user_id}

    # Deleta com Admin
    Create Authorized Session    ${TOKEN_ADMIN}
    ${delete_response}=    DELETE On Session    api    ${USER_ENDPOINT}${CREATED_USER_ID}
    Validate 200 OK Response    ${delete_response}

    # Verifica se foi removido
    ${get_response}=    GET On Session    api    ${USER_ENDPOINT}${CREATED_USER_ID}    expected_status=any
    Validate 404 Not Found Response    ${get_response}

    # Limpa a variável
    Set Global Variable    ${CREATED_USER_ID}    None
