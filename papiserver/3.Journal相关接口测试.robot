*** Settings ***
Suite Setup       rgstorsetup
Suite Teardown    rgstorteardown
Resource          ../rgstor.robot

*** Test Cases ***
恢复指定vdisk的镜像
    log    创建vdisk
    ${vdisk_name}    Generate Random String    4
    write    curl -i -H "Content-Type: application/json" -X POST -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "AddVdisk", "params": { "PoolId": 0, "Name": "${vdisk_name}", "TierInfoList": [ { "Tier": "SATA_HDD", "Capacity": 1000, "EcType": "RAID1_1D0B" } ] } }' http://127.0.0.1:9300/p_api/v1/vdisks
    ${vdisk}    add_vdisk_parse_vdiskid
    write    curl -i -X GET \ http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    ${vdisk_name}
    log    恢复指定vdisk的镜像
    write    curl -i -H "Content-Type: application/json" -X POST -d '{"id":"5fb21aae-251a-11e9-ab14-d663bd873d93","jsonrpc":"2.0","method":"RepairVdiskJournal","params":{"PoolId":0,"VdiskId":${vdisk}}}' http://127.0.0.1:9300/p_api/v1/journals
    ${output}    Read Until Prompt
    should contain    ${output}    result
    log    获取镜像到指定节点的vdisk列表
    write    curl -i -X GET http://127.0.0.1:9300/p_api/v1/journals/1
    ${output}    Read Until Prompt
    should contain    ${output}    result
    log    删除vdisk
    write    curl -i -X DELETE http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    result
    write    curl -i -X GET http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    error

查询镜像到指定节点的vdisk列表
    log    复用恢复指定vdisk的镜像的用例
