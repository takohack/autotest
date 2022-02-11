*** Settings ***
Suite Setup       rgstorsetup
Suite Teardown    rgstorteardown
Resource          ../rgstor.robot

*** Test Cases ***
开启亚健康功能
    log    开启亚健康功能
    write    curl -i -H "Content-Type: application/json" -X POST -d '{"id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "SetSubhStatus", "params": {"enable": "true"}}' http://127.0.0.1:9300/p_api/v1/subhealth
    ${output}    Read Until Prompt
    should contain    ${output}    "result": "0"
    log    关闭亚健康功能
    write    curl -i -H "Content-Type: application/json" -X POST -d '{"id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "SetSubhStatus", "params": {"enable": "false"}}' http://127.0.0.1:9300/p_api/v1/subhealth
    ${output}    Read Until Prompt
    should contain    ${output}    "result": "0"

查询亚健康功能状态
    log    开启亚健康功能
    write    curl -i -H "Content-Type: application/json" -X POST -d '{"id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "SetSubhStatus", "params": {"enable": "true"}}' http://127.0.0.1:9300/p_api/v1/subhealth
    ${output}    Read Until Prompt
    should contain    ${output}    "result": "0"
    log    查询亚健康功能状态
    write    curl -i -H 'Content-Type: application/json' -X GET -d '{"id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "GetSubhStatus"}' http://127.0.0.1:9300/p_api/v1/subhealth
    ${output}    Read Until Prompt
    should contain    ${output}    "result": {"enable": "true"}
    log    关闭亚健康功能
    write    curl -i -H "Content-Type: application/json" -X POST -d '{"id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "SetSubhStatus", "params": {"enable": "false"}}' http://127.0.0.1:9300/p_api/v1/subhealth
    ${output}    Read Until Prompt
    should contain    ${output}    "result": "0"
    log    查询亚健康功能状态
    write    curl -i -H 'Content-Type: application/json' -X GET -d '{"id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "GetSubhStatus"}' http://127.0.0.1:9300/p_api/v1/subhealth
    ${output}    Read Until Prompt
    should contain    ${output}    "result": {"enable": "false"}
