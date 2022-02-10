*** Settings ***
Suite Setup       rgstorsetup
Suite Teardown    rgstorteardown
Resource          ../rgstor.robot

*** Test Cases ***
创建vdisk
    log    创建vdisk
    ${vdisk_name}    Generate Random String    4
    write    curl -i -H "Content-Type: application/json" -X POST -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "AddVdisk", "params": { "PoolId": 0, "Name": "${vdisk_name}", "TierInfoList": [ { "Tier": "SATA_HDD", "Capacity": 1000, "EcType": "RAID1_1D0B" } ] } }' http://127.0.0.1:9300/p_api/v1/vdisks
    log    创建Vdisk成功
    ${vdisk}    add_vdisk_parse_vdiskid
    log    ******创建的vdiskid为 ${vdisk}----根据vdiskid查询信息********
    write    curl -i -X GET \ http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    ${vdisk_name}
    log    ******创建的vdiskname为 ${vdisk_name}----根据vdiskid查询信息********
    write    curl -i -H "Content-Type: application/json" -X GET -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "GetVdiskByName", "params": { \ "PoolId": 0,"Name": "${vdisk_name}" }}' http://127.0.0.1:9300/p_api/v1/vdisks
    ${output}    Read Until Prompt
    should contain    ${output}    result
    should contain    ${output}    ${vdisk_name}
    log    删除vdisk(by id)
    write    curl -i -X DELETE \ http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    result
    write    curl -i -X GET http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    error

删除vdisk
    log    创建vdisk用例已覆盖

根据id获取vdisk信息
    log    创建vdisk用例已覆盖

根据name获取vdisk信息
    log    创建vdisk用例已覆盖

获取所有vdisk信息
    log    创建vdisk
    ${vdisk_name}    Generate Random String    4
    write    curl -i -H "Content-Type: application/json" -X POST -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "AddVdisk", "params": { "PoolId": 0, "Name": "${vdisk_name}", "TierInfoList": [ { "Tier": "SATA_HDD", "Capacity": 1000, "EcType": "RAID1_1D0B" } ] } }' http://127.0.0.1:9300/p_api/v1/vdisks
    log    创建Vdisk成功
    ${vdisk}    add_vdisk_parse_vdiskid
