*** Settings ***
Suite Setup       rgstorsetup
Suite Teardown    rgstorteardown
Resource          ../rgstor.robot

*** Test Cases ***
启动器组配置
    [Documentation]    前置条件：
    ...    PAPI正常运行、POS正常运行
    ...
    ...    操作步骤：
    ...
    ...    1、删除tag2启动器组后重新创建，预期创建成功，可以获取到配置
    ...
    ...    2、删除tag2，预期成功，不能获取到配置
    [Setup]
    log    step1
    write    curl -i -X DELETE http://127.0.0.1:9300/p_api/v1/iscsi/initiatorgroups/2
    Read Until Prompt
    write    curl -i -H "Content-Type: application/json" -X POST -d '{"id":"5fb21aae-251a-11e9-ab14-d663bd873d93","method":"AddInitiatorGroup","jsonrpc":"2.0","params":{"Tag":2,"Initiators":["ANY"],"Netmasks":["ANY"]}}' http://127.0.0.1:9300/p_api/v1/iscsi/initiatorgroups
    ${output}    Read Until Prompt
    should contain    ${output}    "result": {"Tag": 2}
    write    curl -i -X GET \ http://127.0.0.1:9300/p_api/v1/iscsi/initiatorgroups
    ${output}    Read Until Prompt
    should contain    ${output}    {"Tag": 2, "Initiators": ["ANY"], "Netmasks": ["ANY"]}
    log    step2
    write    curl -i -X DELETE \ http://127.0.0.1:9300/p_api/v1/iscsi/initiatorgroups/2
    ${output}    Read Until Prompt
    should contain    ${output}    "result": {"Tag": 2}
    write    curl -i -X GET \ http://127.0.0.1:9300/p_api/v1/iscsi/initiatorgroups
    ${output}    Read Until Prompt
    should not contain    ${output}    {"Tag": 2, "Initiators": ["ANY"], "Netmasks": ["ANY"]}

target配置
    log    创建启动器组
    write    curl -i -X DELETE http://127.0.0.1:9300/p_api/v1/iscsi/initiatorgroups/2
    Read Until Prompt
    write    curl -i -H "Content-Type: application/json" -X POST -d '{"id":"5fb21aae-251a-11e9-ab14-d663bd873d93","method":"AddInitiatorGroup","jsonrpc":"2.0","params":{"Tag":2,"Initiators":["ANY"],"Netmasks":["ANY"]}}' http://127.0.0.1:9300/p_api/v1/iscsi/initiatorgroups
    ${output}    Read Until Prompt
    should contain    ${output}    "result": {"Tag": 2}
    log    创建vdisk
    ${vdisk_name}    Generate Random String    4
    write    curl -i -H "Content-Type: application/json" -X POST -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "AddVdisk", "params": { "PoolId": 0, "Name": "${vdisk_name}", "TierInfoList": [ { "Tier": "SATA_HDD", "Capacity": 1000, "EcType": "RAID1_1D0B" } ] } }' http://127.0.0.1:9300/p_api/v1/vdisks
    ${vdisk}    add_vdisk_parse_vdiskid    #这里成功才会返回id
    log    创建卷
    write    curl -i -H "Content-Type: application/json" -X POST -d '{"jsonrpc": "2.0", "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "method": "AddVolume" ,"params": {"Name": "vol-test", "Deduplication": false, "PoolId": 0,"VdiskId": ${vdisk}, "Compress": false, "Description": "vdisk1 desc", "Size": '100'}}' http://127.0.0.1:9300/p_api/v1/volumes
    ${volid}    add_volume_parse_volid
    log    创建target
    write    curl -i -H "Content-Type: application/json" -X POST -d '{"id":"5fb21aae-251a-11e9-ab14-d663bd873d93","method":"ConstructTargetNode","jsonrpc":"2.0","params":{"Name":"iqn.2019-06.io.ruijie:robottest","Luns":[{"PoolId":0,"VdiskId":${vdisk},"VolumeId":${volid}}],"IgTags":[{"IgTag":2}]}}' http://127.0.0.1:9300/p_api/v1/iscsi/targets
    ${output}    Read Until Prompt
    should contain    ${output}    result
    write    curl -i -X GET \ http://127.0.0.1:9300/p_api/v1/iscsi/targets
    ${output}    Read Until Prompt
    should contain    ${output}    robottest
    write    curl -i -X GET \ http://127.0.0.1:9300/p_api/v1/iscsi/targets/iqn.2019-06.io.ruijie:robottest
    ${output}    Read Until Prompt
    should contain    ${output}    robottest
    log    删除target
    write    curl -i -X DELETE http://127.0.0.1:9300/p_api/v1/iscsi/targets/iqn.2019-06.io.ruijie:robottest
    ${output}    Read Until Prompt
    should contain    ${output}    result
    write    curl -i -X GET \ http://127.0.0.1:9300/p_api/v1/iscsi/targets/iqn.2019-06.io.ruijie:robottest
    ${output}    Read Until Prompt
    should contain    ${output}    error
    log    删除卷
    write    curl -i -H "Content-Type: application/json" -X DELETE -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "DeleteVolume", "params": { \ "PoolId": 0,"VdiskId": ${vdisk} }}' http://127.0.0.1:9300/p_api/v1/volumes/${volid}
    ${output}    Read Until Prompt
    should contain    ${output}    result
    write    curl -i -H "Content-Type: application/json" -X GET -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "GetVolume", "params": { "PoolId": 0, "VdiskId": ${vdisk} }}' http://127.0.0.1:9300/p_api/v1/volumes/${volid}
    ${output}    Read Until Prompt
    should contain    ${output}    error
    log    删除vdisk
    write    curl -i -X DELETE \ http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    result
    write    curl -i -X GET http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    error
