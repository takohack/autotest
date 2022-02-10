*** Settings ***
Resource          ../rgstor.robot

*** Test Cases ***
测试SSH连接
    [Documentation]    alias类似index
    ...    prompt defines the character sequence used by Read Until Prompt and must be set before that keyword can be used.
    ...    Argument timeout is used by Read Until variants. The default value is 3 seconds.
    [Setup]
    log    建立连接
    Open Connection    ${host}    alias=conf    port=${port}
    login    ${user}    ${passwd}
    log    登录成功
    Set Client Configuration    prompt=#
    Set Client Configuration    timeout=60

测试创建pool池
    [Documentation]    alias类似index
    ...    prompt defines the character sequence used by Read Until Prompt and must be set before that keyword can be used.
    ...    Argument timeout is used by Read Until variants. The default value is 3 seconds.
    [Setup]
    log    建立连接
    Open Connection    ${host}    alias=conf    port=${port}
    login    ${user}    ${passwd}
    log    登录成功
    Set Client Configuration    prompt=#
    Set Client Configuration    timeout=60
    write    curl -i -H "Content-Type: application/json" -X POST -d '{"jsonrpc":"2.0","method": "AddPool","id":"5fb21aae-251a-11e9-ab14-d663bd873d93","params":{"Name":"pool1","ConstructType":1,"Description":"","NodeNum":'1',"SasHotspareStrategy":"mid","SataHotspareStrategy":"mid","SsdHotspareStrategy":"mid","NodeInfoList":[{"NodeId":${node1myid},"DiskList":[${node1disk1},${node1disk2}]}]}}' http://127.0.0.1:9300/p_api/v1/pools
    ${output}    Read Until Prompt
    write    curl -i -X GET http://127.0.0.1:9300/p_api/v1/pools/0
    ${output}    Read Until Prompt
    should contain    ${output}    result
