*** Settings ***
Library    RequestsLibrary
Library    Collections

*** Keywords ***
Login As Admin
    Create Session    api    ${BASE_URL}
    ${body}=    Create Dictionary    email=${ADMIN_EMAIL}    password=${ADMIN_PASSWORD}
    ${response}=    POST On Session    api    /auth/login    json=${body}
    Should Be Equal As Integers    ${response.status_code}    200
    ${token}=    Get From Dictionary    ${response.json()}    token
    Set Global Variable    ${TOKEN_ADMIN}    ${token}

Login As User
    Create Session    api    ${BASE_URL}
    ${body}=    Create Dictionary    email=${USER_EMAIL}    password=${USER_PASSWORD}
    ${response}=    POST On Session    api    /auth/login    json=${body}
    Should Be Equal As Integers    ${response.status_code}    200
    ${token}=    Get From Dictionary    ${response.json()}    token
    Set Global Variable    ${TOKEN_USER}    ${token}

Create Authorized Session
    [Arguments]    ${token}
    Create Session    api    ${BASE_URL}    headers={"Authorization": "Bearer ${token}", "Content-Type": "application/json"}
