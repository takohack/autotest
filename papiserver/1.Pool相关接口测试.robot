*** Settings ***
Suite Setup       rgstorsetup
Suite Teardown    rgstorteardown
Resource          ../rgstor.robot

*** Test Cases ***
XXX创建pool
    log    TODO

XXX删除pool
    #log    删除Pool
    #write    curl -i -X DELETE -d '{"jsonrpc":"2.0","method":"DeletePool","id":"5fb21aae-251a-11e9-ab14-d663bd873d93","params":{"Force":True,"AuthCode":"29d6c305-9eac-4a09-bf0f-5944e4a555b3"}}' http://127.0.0.1:9300/p_api/v1/pools/0
    #${output}    Read Until Prompt
    #should contain    ${output}    result
    log    TODO

获取单个pool信息
    write    curl -i -H "Content-Type: application/json" -X POST -d '{"jsonrpc":"2.0","method": "AddPool","id":"5fb21aae-251a-11e9-ab14-d663bd873d93","params":{"Name":"pool1","ConstructType":1,"Description":"","NodeNum":'1',"SasHotspareStrategy":"mid","SataHotspareStrategy":"mid","SsdHotspareStrategy":"mid","NodeInfoList":[{"NodeId":${node1myid},"DiskList":[${node1disk1},${node1disk2}]}]}}' http://127.0.0.1:9300/p_api/v1/pools
    ${output}    Read Until Prompt
    write    curl -i -X GET http://127.0.0.1:9300/p_api/v1/pools/0
    ${output}    Read Until Prompt
    should contain    ${output}    result

XXXpool中添加磁盘
    log    TODO

XXXpool中删除磁盘
    log    TODO

修改pool
    ${pool_name}    Generate Random String    4
    write    curl -i -H "Content-Type: application/json" -X PUT -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "SetPool", "params": { "Description": "${pool_name}", "CapWarn": [ { "Tier": "SATA_HDD", "CapWarnStrategy": "mid" } ], "HotspareInfo": [ { "Tier": "SATA_HDD", "HotspareDiskNum": 0 } ] } }' http://127.0.0.1:9300/p_api/v1/pools/0
    ${output}    Read Until Prompt
    should contain    ${output}    result
    write    curl -i -X GET http://127.0.0.1:9300/p_api/v1/pools/0
    ${output}    Read Until Prompt
    should contain    ${output}    ${pool_name}

查询Pool重构进度
    write    curl -i -X GET http://127.0.0.1:9300/p_api/v1/pools/0/poolreconstructschedule
    ${output}    Read Until Prompt
    should contain    ${output}    result

获取强制删除存储池的授权
    log    获取强制删除存储池授权码
    write    curl -i -H "Content-Type: application/json" -X GET -d '{"jsonrpc": "2.0","method": "GetForceDelPoolAuthCode","id": "5fb21aae-251a-11e9-ab14-d663bd873d93"}' http://127.0.0.1:9300/p_api/v1/pools/0
    ${output}    Read Until Prompt
    should contain    ${output}    AuthCode
