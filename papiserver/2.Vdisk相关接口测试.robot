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
    log    创建2个vdisk
    ${vdisk_name}    Generate Random String    4
    write    curl -i -H "Content-Type: application/json" -X POST -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "AddVdisk", "params": { "PoolId": 0, "Name": "${vdisk_name}", "TierInfoList": [ { "Tier": "SATA_HDD", "Capacity": 1000, "EcType": "RAID1_1D0B" } ] } }' http://127.0.0.1:9300/p_api/v1/vdisks
    log    创建Vdisk成功
    ${vdisk1}    add_vdisk_parse_vdiskid
    ${vdisk_name2}    Generate Random String    4
    write    curl -i -H "Content-Type: application/json" -X POST -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "AddVdisk", "params": { "PoolId": 0, "Name": "${vdisk_name2}", "TierInfoList": [ { "Tier": "SATA_HDD", "Capacity": 1000, "EcType": "RAID1_1D0B" } ] } }' http://127.0.0.1:9300/p_api/v1/vdisks
    log    创建Vdisk成功
    ${vdisk2}    add_vdisk_parse_vdiskid
    comment    命令中需要增加\，否则RF会失败
    write    curl -i -X GET http://127.0.0.1:9300/p_api/v1/pools/0/vdisks?offset=${vdisk1}\\&count=2
    ${output}    Read Until Prompt
    should contain    ${output}    result
    should contain    ${output}    ${vdisk_name}
    should contain    ${output}    ${vdisk_name2}    #输出结果能正确包含创建的两个vdisk
    log    删除vdisk1、2
    write    curl -i -X DELETE \ http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk1}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    result
    write    curl -i -X DELETE \ http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk2}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    result
    write    curl -i -X GET http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk1}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    error
    write    curl -i -X GET http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk2}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    error

修改vdisk
    log    创建vdisk
    ${vdisk_name}    Generate Random String    4
    write    curl -i -H "Content-Type: application/json" -X POST -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "AddVdisk", "params": { "PoolId": 0, "Name": "${vdisk_name}", "TierInfoList": [ { "Tier": "SATA_HDD", "Capacity": 1000, "EcType": "RAID1_1D0B" } ] } }' http://127.0.0.1:9300/p_api/v1/vdisks
    log    创建Vdisk成功
    ${vdisk}    add_vdisk_parse_vdiskid
    write    curl -i -H "Content-Type: application/json" -X PUT -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "SetVdisk", "params": { "Name": "changed_name", "TierInfoList": [ { "Tier": "SATA_HDD", "Capacity": 1000 } ] } }' http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}?poolid=0
    ${output}    Read Until Prompt    #修改vdisk的name为changed_name
    should contain    ${output}    result
    write    curl -i -X GET \ http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    changed_name
    log    删除vdisk
    write    curl -i -X DELETE \ http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    result
    write    curl -i -X GET http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    error

查询指定vdisk的QoS策略
    log    创建vdisk
    ${vdisk_name}    Generate Random String    4
    write    curl -i -H "Content-Type: application/json" -X POST -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "AddVdisk", "params": { "PoolId": 0, "Name": "${vdisk_name}", "TierInfoList": [ { "Tier": "SATA_HDD", "Capacity": 1000, "EcType": "RAID1_1D0B" } ] } }' http://127.0.0.1:9300/p_api/v1/vdisks
    log    创建Vdisk成功
    ${vdisk}    add_vdisk_parse_vdiskid
    log    创建QoS策略
    ${qos_name}    Generate Random String    4
    write    curl -i -H "Content-Type: application/json" -X POST -d '{"id":"5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc":"2.0", "method":"AddQoSPolicy", "params": {"PolicyName":"${qos_name}", "IOPSLimit":3000, "IOPSReservation":0, "BandwidthLimit":0, "BandwidthReservation":0, "Priority":2 }}' http://127.0.0.1:9300/p_api/v1/qos
    ${output}    Read Until Prompt
    should contain    ${output}    ${qos_name}
    log    vdisk绑定QOS策略
    write    curl -i -H "Content-Type: application/json" -X PUT -d '{"id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "BindQoSPolicy", "params": {"PolicyName": "${qos_name}", "PoolId": 0, "VdiskId": ${vdisk}}}' http://127.0.0.1:9300/p_api/v1/qos
    ${output}    Read Until Prompt
    should contain    ${output}    ${qos_name}
    log    查询指定vdisk的QoS策略
    write    curl -i -H "Content-Type: application/json" -X GET -d '{"id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "GetQoSPolicyByVdiskId", "params": {"PoolId": 0, "VdiskId": ${vdisk}}}' http://127.0.0.1:9300/p_api/v1/qos
    ${output}    Read Until Prompt
    should contain    ${output}    ${qos_name}
    log    vdisk解除绑定QoS
    write    curl -i -H 'Content-Type: application/json' -X PUT -d '{"id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "UnbindQoSPolicy", "params": {"PoolId": 0, "VdiskId": ${vdisk}}}' http://127.0.0.1:9300/p_api/v1/qos
    ${output}    Read Until Prompt
    should contain    ${output}    result
    log    删除QoS策略
    write    curl -i -H "Content-Type: application/json" -X DELETE -d '{"id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "DeleteQoSPolicy", "params": {"PolicyName": "${qos_name}"}}' http://127.0.0.1:9300/p_api/v1/qos
    ${output}    Read Until Prompt
    should contain    ${output}    ${qos_name}
    log    删除vdisk
    write    curl -i -X DELETE \ http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    result
    write    curl -i -X GET http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    error
