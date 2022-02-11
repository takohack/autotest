*** Settings ***
Suite Setup       rgstorsetup
Suite Teardown    rgstorteardown
Resource          ../rgstor.robot

*** Test Cases ***
创建卷
    log    创建vdisk
    ${vdisk_name}    Generate Random String    4
    write    curl -i -H "Content-Type: application/json" -X POST -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "AddVdisk", "params": { "PoolId": 0, "Name": "${vdisk_name}", "TierInfoList": [ { "Tier": "SATA_HDD", "Capacity": 1000, "EcType": "RAID1_1D0B" } ] } }' http://127.0.0.1:9300/p_api/v1/vdisks
    ${vdisk}    add_vdisk_parse_vdiskid    #这里成功才会返回id
    log    创建卷
    ${lun_name}    Generate Random String    5
    write    curl -i -H "Content-Type: application/json" -X POST -d '{"jsonrpc": "2.0", "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "method": "AddVolume" ,"params": {"Name": "${lun_name}", "Deduplication": false, "PoolId": 0,"VdiskId": ${vdisk}, "Compress": false, "Description": "vdisk1 desc", "Size": '100'}}' http://127.0.0.1:9300/p_api/v1/volumes
    ${volid}    add_volume_parse_volid
    log    删除卷
    write    curl -i -H "Content-Type: application/json" -X DELETE -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "DeleteVolume", "params": { \ "PoolId": 0,"VdiskId": ${vdisk} }}' http://127.0.0.1:9300/p_api/v1/volumes/${volid}
    ${output}    Read Until Prompt
    should contain    ${output}    result
    write    curl -i -H "Content-Type: application/json" -X GET -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "GetVolume", "params": { "PoolId": 0, "VdiskId": ${vdisk} }}' http://127.0.0.1:9300/p_api/v1/volumes/${volid}
    ${output}    Read Until Prompt
    should contain    ${output}    error
    write    curl \ -X GET http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}/volumes?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    result
    should not contain    ${output}    ${lun_name}
    log    删除vdisk
    write    curl -i -X DELETE \ http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    result
    write    curl -i -X GET http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    error

删除卷
    log    复用创建vdisk用例

扩容卷
    log    创建vdisk
    ${vdisk_name}    Generate Random String    4
    write    curl -i -H "Content-Type: application/json" -X POST -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "AddVdisk", "params": { "PoolId": 0, "Name": "${vdisk_name}", "TierInfoList": [ { "Tier": "SATA_HDD", "Capacity": 1000, "EcType": "RAID1_1D0B" } ] } }' http://127.0.0.1:9300/p_api/v1/vdisks
    ${vdisk}    add_vdisk_parse_vdiskid    #这里成功才会返回id
    log    创建卷
    ${lun_name}    Generate Random String    5
    write    curl -i -H "Content-Type: application/json" -X POST -d '{"jsonrpc": "2.0", "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "method": "AddVolume" ,"params": {"Name": "${lun_name}", "Deduplication": false, "PoolId": 0,"VdiskId": ${vdisk}, "Compress": false, "Description": "vdisk1 desc", "Size": '100'}}' http://127.0.0.1:9300/p_api/v1/volumes
    ${volid}    add_volume_parse_volid
    log    扩容卷
    write    curl -i -H "Content-Type: application/json" -X PUT -d '{"id":"5fb21aae-251a-11e9-ab14-d663bd873d93","jsonrpc":"2.0","method":"ResizeVolume","params":{"PoolId": 0,"VdiskId":${vdisk},"Size":200}}' http://127.0.0.1:9300/p_api/v1/volumes/${volid}
    ${output}    Read Until Prompt
    should contain    ${output}    result
    Comment    log    缩容卷，还不支持，不测试
    Comment    write    curl -i -H "Content-Type: application/json" -X PUT -d '{"id":"5fb21aae-251a-11e9-ab14-d663bd873d93","jsonrpc":"2.0","method":"ResizeVolume","params":{"PoolId": 0,"VdiskId":${vdisk},"Size":50}}' http://127.0.0.1:9300/p_api/v1/volumes/${volid}
    Comment    ${output}    Read Until Prompt
    Comment    should contain    ${output}    result
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

获取vdisk下所有卷信息
    log    复用创建vdisk用例

获取单个卷信息
    log    复用创建vdisk用例

创建快照
    log    创建vdisk
    ${vdisk_name}    Generate Random String    4
    write    curl -i -H "Content-Type: application/json" -X POST -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "AddVdisk", "params": { "PoolId": 0, "Name": "${vdisk_name}", "TierInfoList": [ { "Tier": "SATA_HDD", "Capacity": 1000, "EcType": "RAID1_1D0B" } ] } }' http://127.0.0.1:9300/p_api/v1/vdisks
    ${vdisk}    add_vdisk_parse_vdiskid    #这里成功才会返回id
    write    curl -i -X GET \ http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    ${vdisk_name}
    log    创建卷
    write    curl -i -H "Content-Type: application/json" -X POST -d '{"jsonrpc": "2.0", "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "method": "AddVolume" ,"params": {"Name": "vol0-test", "Deduplication": false, "PoolId": 0,"VdiskId": ${vdisk}, "Compress": false, "Description": "vdisk1 desc", "Size": '100'}}' http://127.0.0.1:9300/p_api/v1/volumes
    ${volid}    add_volume_parse_volid
    log    创建快照
    write    curl -i -H "Content-Type: application/json" -X POST -d '{"id":"5fb21aae-251a-11e9-ab14-d663bd873d93","jsonrpc":"2.0","method":"AddSnapshot","params":{"PoolId": 0,"VdiskId":${vdisk}, "ReadOnly":true,"Name":"snapshot1","Description":"snapshot1 desc"}}' http://127.0.0.1:9300/p_api/v1/volumes/${volid}/snapshots
    ${output}    Read Until Prompt
    should contain    ${output}    result
    log    删除快照
    write    curl -i -H "Content-Type: application/json" -X DELETE -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "DeleteSnapshot", "params": {"PoolId": 0,"VdiskId": ${vdisk}}}' http://127.0.0.1:9300/p_api/v1/volumes/${volid}/snapshots/1
    ${output}    Read Until Prompt
    should contain    ${output}    result
    log    获取快照信息
    write    curl -i -H "Content-Type: application/json" -X GET -d '{"id":"5fb21aae-251a-11e9-ab14-d663bd873d93","jsonrpc":"2.0","method":"GetSnapshot","params":{"PoolId": 0,"VdiskId":${vdisk}}}' http://127.0.0.1:9300/p_api/v1/volumes/${volid}/snapshots/1
    ${output}    Read Until Prompt
    should contain    ${output}    error
    log    获取指定卷下快照信息
    write    curl -i -H "Content-Type: application/json" -X GET -d '{"id":"5fb21aae-251a-11e9-ab14-d663bd873d93","jsonrpc":"2.0","method":"GetSnapshots","params":{"PoolId": 0,"VdiskId":${vdisk}}}' http://127.0.0.1:9300/p_api/v1/volumes/${volid}/snapshots
    ${output}    Read Until Prompt
    should contain    ${output}    result
    log    删除卷
    write    curl -i -H "Content-Type: application/json" -X DELETE -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "DeleteVolume", "params": { \ "PoolId": 0,"VdiskId": ${vdisk} }}' http://127.0.0.1:9300/p_api/v1/volumes/${volid}
    ${output}    Read Until Prompt
    should contain    ${output}    result
    write    curl -i -H "Content-Type: application/json" -X GET -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "GetVolume", "params": { "PoolId": 0, "VdiskId": ${vdisk} }}' http://127.0.0.1:9300/p_api/v1/volumes/${volid}
    ${output}    Read Until Prompt
    should contain    ${output}    error
    write    curl \ -X GET \ http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}/volumes?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    result
    should not contain    ${output}    vol0-test
    log    删除vdisk
    write    curl -i -X DELETE \ http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    result
    write    curl -i -X GET http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    error

删除快照
    log    复用创建快照用例

获取快照信息
    log    复用创建快照用例

启动快照回滚
    log    创建vdisk
    ${vdisk_name}    Generate Random String    4
    write    curl -i -H "Content-Type: application/json" -X POST -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "AddVdisk", "params": { "PoolId": 0, "Name": "${vdisk_name}", "TierInfoList": [ { "Tier": "SATA_HDD", "Capacity": 1000, "EcType": "RAID1_1D0B" } ] } }' http://127.0.0.1:9300/p_api/v1/vdisks
    ${vdisk}    add_vdisk_parse_vdiskid    #这里成功才会返回id
    write    curl -i -X GET \ http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    ${vdisk_name}
    log    创建卷
    write    curl -i -H "Content-Type: application/json" -X POST -d '{"jsonrpc": "2.0", "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "method": "AddVolume" ,"params": {"Name": "vol0-test", "Deduplication": false, "PoolId": 0,"VdiskId": ${vdisk}, "Compress": false, "Description": "vdisk1 desc", "Size": '100'}}' http://127.0.0.1:9300/p_api/v1/volumes
    ${volid}    add_volume_parse_volid
    log    创建快照
    write    curl -i -H "Content-Type: application/json" -X POST -d '{"id":"5fb21aae-251a-11e9-ab14-d663bd873d93","jsonrpc":"2.0","method":"AddSnapshot","params":{"PoolId": 0,"VdiskId":${vdisk}, "ReadOnly":true,"Name":"snapshot1","Description":"snapshot1 desc"}}' http://127.0.0.1:9300/p_api/v1/volumes/${volid}/snapshots
    ${output}    Read Until Prompt
    should contain    ${output}    result
    log    启动快照回滚
    write    curl -i -H "Content-Type: application/json" -X PUT -d '{"id":"5fb21aae-251a-11e9-ab14-d663bd873d93","jsonrpc":"2.0","method":"RollbackSnapshot","params":{"PoolId":0,"VdiskId":${vdisk}}}' http://127.0.0.1:9300/p_api/v1/volumes/${volid}/snapshots/1
    ${output}    Read Until Prompt
    should contain    ${output}    result
    log    终止快照回滚
    write    curl -i -H "Content-Type: application/json" -X PUT -d '{"id":"5fb21aae-251a-11e9-ab14-d663bd873d93","jsonrpc":"2.0","method":"StopRollback","params":{"PoolId":0,"VdiskId":${vdisk}}}' http://127.0.0.1:9300/p_api/v1/volumes/${volid}
    ${output}    Read Until Prompt
    comment    终止快照回滚结果判断TODO
    log    删除快照
    write    curl -i -H "Content-Type: application/json" -X DELETE -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "DeleteSnapshot", "params": {"PoolId": 0,"VdiskId": ${vdisk}}}' http://127.0.0.1:9300/p_api/v1/volumes/${volid}/snapshots/1
    ${output}    Read Until Prompt
    should contain    ${output}    result
    log    获取快照信息
    write    curl -i -H "Content-Type: application/json" -X GET -d '{"id":"5fb21aae-251a-11e9-ab14-d663bd873d93","jsonrpc":"2.0","method":"GetSnapshot","params":{"PoolId": 0,"VdiskId":${vdisk}}}' http://127.0.0.1:9300/p_api/v1/volumes/${volid}/snapshots/1
    ${output}    Read Until Prompt
    should contain    ${output}    error
    log    获取指定卷下快照信息
    write    curl -i -H "Content-Type: application/json" -X GET -d '{"id":"5fb21aae-251a-11e9-ab14-d663bd873d93","jsonrpc":"2.0","method":"GetSnapshots","params":{"PoolId": 0,"VdiskId":${vdisk}}}' http://127.0.0.1:9300/p_api/v1/volumes/${volid}/snapshots
    ${output}    Read Until Prompt
    should contain    ${output}    result
    log    删除卷
    write    curl -i -H "Content-Type: application/json" -X DELETE -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "DeleteVolume", "params": { \ "PoolId": 0,"VdiskId": ${vdisk} }}' http://127.0.0.1:9300/p_api/v1/volumes/${volid}
    ${output}    Read Until Prompt
    should contain    ${output}    result
    write    curl -i -H "Content-Type: application/json" -X GET -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "GetVolume", "params": { "PoolId": 0, "VdiskId": ${vdisk} }}' http://127.0.0.1:9300/p_api/v1/volumes/${volid}
    ${output}    Read Until Prompt
    should contain    ${output}    error
    write    curl \ -X GET \ http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}/volumes?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    result
    should not contain    ${output}    vol0-test
    log    删除vdisk
    write    curl -i -X DELETE \ http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    result
    write    curl -i -X GET http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    error

终止快照回滚
    log    复用启动快照回滚用例

获取指定卷下快照信息
    log    复用创建快照用例

启动卷拷贝
    log    创建vdisk
    ${vdisk1_name}    Generate Random String    4
    write    curl -i -H "Content-Type: application/json" -X POST -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "AddVdisk", "params": { "PoolId": 0, "Name": "${vdisk1_name}", "TierInfoList": [ { "Tier": "SATA_HDD", "Capacity": 1000, "EcType": "RAID1_1D0B" } ] } }' http://127.0.0.1:9300/p_api/v1/vdisks
    ${vdisk}    add_vdisk_parse_vdiskid    #这里成功才会返回id
    write    curl -i -X GET \ http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    ${vdisk1_name}
    log    创建卷
    write    curl -i -H "Content-Type: application/json" -X POST -d '{"jsonrpc": "2.0", "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "method": "AddVolume" ,"params": {"Name": "vol0-test", "Deduplication": false, "PoolId": 0,"VdiskId": ${vdisk}, "Compress": false, "Description": "vdisk1 desc", "Size": '100'}}' http://127.0.0.1:9300/p_api/v1/volumes
    ${volid}    add_volume_parse_volid
    log    创建vdisk2
    ${vdisk2_name}    Generate Random String    4
    write    curl -i -H "Content-Type: application/json" -X POST -d '{"id":"5fb21aae-251a-11e9-ab14-d663bd873d93","jsonrpc":"2.0","method":"AddVdisk","params":{"PoolId":0,"Name":"${vdisk2_name}","Description":"desc","TierInfoList":[{"Tier":"SATA_HDD","Capacity":1000,"EcType":"CARBON_2B"}]}}' http://127.0.0.1:9300/p_api/v1/vdisks
    ${vdisk2}    add_vdisk_parse_vdiskid
    write    curl -i -X GET http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk2}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    ${vdisk2_name}
    log    创建卷2
    write    curl -i -H "Content-Type: application/json" -X POST -d '{"jsonrpc": "2.0", "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "method": "AddVolume" ,"params": {"Name": "vol0-test2", "Deduplication": false, "PoolId": 0,"VdiskId": ${vdisk2}, "Compress": false, "Description": "vdisk1 desc", "Size": '100'}}' http://127.0.0.1:9300/p_api/v1/volumes
    ${volid2}    add_volume_parse_volid
    log    启动卷拷贝
    write    curl -i -H "Content-Type: application/json" -X PUT -d '{"id":"5fb21aae-251a-11e9-ab14-d663bd873d93","jsonrpc":"2.0","method":"StartVolumeCopy","params":{"PoolId":0,"VdiskId":${vdisk2},"SourcePoolId":0,"SourceVdiskId":${vdisk},"SourceVolumeId":${volid},"CopyType":0}}' http://127.0.0.1:9300/p_api/v1/volumes/${volid2}
    ${output}    Read Until Prompt
    should contain    ${output}    result
    log    终止卷拷贝
    write    curl -i -H "Content-Type: application/json" -X PUT -d '{"id":"5fb21aae-251a-11e9-ab14-d663bd873d93","jsonrpc":"2.0","method":"StopVolumeCopy","params":{"PoolId":0,"VdiskId":${vdisk2}}}' http://127.0.0.1:9300/p_api/v1/volumes/${volid2}
    ${output}    Read Until Prompt
    comment    判断终止卷拷贝TODO
    log    删除卷
    write    curl -i -H "Content-Type: application/json" -X DELETE -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "DeleteVolume", "params": { \ "PoolId": 0,"VdiskId": ${vdisk} }}' http://127.0.0.1:9300/p_api/v1/volumes/${volid}
    ${output}    Read Until Prompt
    should contain    ${output}    result
    write    curl -i -H "Content-Type: application/json" -X GET -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "GetVolume", "params": { "PoolId": 0, "VdiskId": ${vdisk} }}' http://127.0.0.1:9300/p_api/v1/volumes/${volid}
    ${output}    Read Until Prompt
    should contain    ${output}    error
    write    curl \ -X GET http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}/volumes?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    result
    should not contain    ${output}    vol0-test
    log    删除vdisk
    write    curl -i -X DELETE \ http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    result
    write    curl -i -X GET http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    error
    log    删除卷2
    write    curl -i -H "Content-Type: application/json" -X DELETE -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "DeleteVolume", "params": { \ "PoolId": 0,"VdiskId": ${vdisk2} }}' http://127.0.0.1:9300/p_api/v1/volumes/${volid2}
    ${output}    Read Until Prompt
    should contain    ${output}    result
    write    curl -i -H "Content-Type: application/json" -X GET -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "GetVolume", "params": { "PoolId": 0, "VdiskId": ${vdisk2} }}' http://127.0.0.1:9300/p_api/v1/volumes/${volid2}
    ${output}    Read Until Prompt
    should contain    ${output}    error
    write    curl \ -X GET http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk2}/volumes?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    result
    should not contain    ${output}    vol0-test
    log    删除vdisk2
    write    curl -i -X DELETE \ http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk2}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    result
    write    curl -i -X GET http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk2}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    error

终止卷拷贝
    log    复用启动卷拷贝用例

链接克隆卷rebase
    log    创建vdisk
    ${vdisk1_name}    Generate Random String    4
    write    curl -i -H "Content-Type: application/json" -X POST -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "AddVdisk", "params": { "PoolId": 0, "Name": "${vdisk1_name}", "TierInfoList": [ { "Tier": "SATA_HDD", "Capacity": 1000, "EcType": "RAID1_1D0B" } ] } }' http://127.0.0.1:9300/p_api/v1/vdisks
    ${vdisk}    add_vdisk_parse_vdiskid    #这里成功才会返回id
    write    curl -i -X GET \ http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    ${vdisk1_name}
    log    创建卷
    write    curl -i -H "Content-Type: application/json" -X POST -d '{"jsonrpc": "2.0", "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "method": "AddVolume" ,"params": {"Name": "vol0-test", "Deduplication": false, "PoolId": 0,"VdiskId": ${vdisk}, "Compress": false, "Description": "vdisk1 desc", "Size": '100'}}' http://127.0.0.1:9300/p_api/v1/volumes
    ${volid}    add_volume_parse_volid
    log    创建快照
    write    curl -i -H "Content-Type: application/json" -X POST -d '{"id":"5fb21aae-251a-11e9-ab14-d663bd873d93","jsonrpc":"2.0","method":"AddSnapshot","params":{"PoolId": 0,"VdiskId":${vdisk}, "ReadOnly":true,"Name":"snapshot1","Description":"snapshot1 desc"}}' http://127.0.0.1:9300/p_api/v1/volumes/${volid}/snapshots
    ${output}    Read Until Prompt
    should contain    ${output}    result
    log    创建vdisk2
    ${vdisk2_name}    Generate Random String    4
    write    curl -i -H "Content-Type: application/json" -X POST -d '{"id":"5fb21aae-251a-11e9-ab14-d663bd873d93","jsonrpc":"2.0","method":"AddVdisk","params":{"PoolId":0,"Name":"${vdisk2_name}","Description":"desc","TierInfoList":[{"Tier":"SATA_HDD","Capacity":1000,"EcType":"CARBON_2B"}]}}' http://127.0.0.1:9300/p_api/v1/vdisks
    ${vdisk2}    add_vdisk_parse_vdiskid
    write    curl -i -X GET http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk2}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    ${vdisk2_name}
    log    创建卷2
    write    curl -i -H "Content-Type: application/json" -X POST -d '{"jsonrpc": "2.0", "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "method": "AddVolume" ,"params": {"Name": "vol0-test2", "Deduplication": false, "PoolId": 0,"VdiskId": ${vdisk2}, "Compress": false, "Description": "vdisk1 desc", "Size": '100'}}' http://127.0.0.1:9300/p_api/v1/volumes
    ${volid2}    add_volume_parse_volid
    log    启动卷拷贝
    write    curl -i -H "Content-Type: application/json" -X PUT -d '{"id":"5fb21aae-251a-11e9-ab14-d663bd873d93","jsonrpc":"2.0","method":"StartVolumeCopy","params":{"PoolId":0,"VdiskId":${vdisk2},"SourcePoolId":0,"SourceVdiskId":${vdisk},"SourceVolumeId":${volid},"CopyType":0}}' http://127.0.0.1:9300/p_api/v1/volumes/${volid2}
    ${output}    Read Until Prompt
    should contain    ${output}    result
    log    终止卷拷贝
    write    curl -i -H "Content-Type: application/json" -X PUT -d '{"id":"5fb21aae-251a-11e9-ab14-d663bd873d93","jsonrpc":"2.0","method":"StopVolumeCopy","params":{"PoolId":0,"VdiskId":${vdisk2}}}' http://127.0.0.1:9300/p_api/v1/volumes/${volid2}
    ${output}    Read Until Prompt
    comment    判断终止卷拷贝TODO
    log    创建快照2
    write    curl -i -H "Content-Type: application/json" -X POST -d '{"id":"5fb21aae-251a-11e9-ab14-d663bd873d93","jsonrpc":"2.0","method":"AddSnapshot","params":{"PoolId": 0,"VdiskId":${vdisk2}, "ReadOnly":true,"Name":"snapshot1","Description":"snapshot1 desc"}}' http://127.0.0.1:9300/p_api/v1/volumes/${volid2}/snapshots
    ${output}    Read Until Prompt
    should contain    ${output}    result
    log    创建vdisk3用于创建链接克隆卷
    ${vdisk3_name}    Generate Random String    4
    write    curl -i -H "Content-Type: application/json" -X POST -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "AddVdisk", "params": { "PoolId": 0, "Name": "${vdisk3_name}", "TierInfoList": [ { "Tier": "SATA_HDD", "Capacity": 1000, "EcType": "RAID1_1D0B" } ] } }' http://127.0.0.1:9300/p_api/v1/vdisks
    ${vdisk3}    add_vdisk_parse_vdiskid    #这里成功才会返回id
    write    curl -i -X GET \ http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk3}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    ${vdisk3_name}
    log    基于快照创建链接克隆卷
    write    curl -i -H "Content-Type: application/json" -X POST -d '{"jsonrpc": "2.0", "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "method": "AddVolume" ,"params": {"Name": "vol0-lc", "Deduplication": false, "PoolId": 0,"VdiskId": ${vdisk3}, "Compress": false, "Description": "vdisk1 desc", "Size": '100', "Template":{"TemplatePoolId":0,"TemplateVdiskId":${vdisk},"TemplateVolumeId":${volid},"TemplateSnapshotId":1}}}' http://127.0.0.1:9300/p_api/v1/volumes
    ${volid3}    add_volume_parse_volid
    log    将链接克隆卷rebase到快照2
    write    curl -i -H "Content-Type: application/json" -X PUT -d '{"id":"5fb21aae-251a-11e9-ab14-d663bd873d93","jsonrpc":"2.0","method":"RebaseVolume","params":{"PoolId":0,"VdiskId":${vdisk3},"ParentPoolId":0,"ParentVdiskId":${vdisk2},"ParentVolumeId":${volid2},"ParentSnapshotId":1}}' http://127.0.0.1:9300/p_api/v1/volumes/${volid3}
    ${output}    Read Until Prompt
    should contain    ${output}    result
    log    删除链接克隆卷
    write    curl -i -H "Content-Type: application/json" -X DELETE -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "DeleteVolume", "params": { \ "PoolId": 0,"VdiskId": ${vdisk3} }}' http://127.0.0.1:9300/p_api/v1/volumes/${volid3}
    ${output}    Read Until Prompt
    should contain    ${output}    result
    log    删除链接克隆vdisk3
    write    curl -i -X DELETE \ http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk3}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    result
    write    curl -i -X GET http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk3}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    error
    log    删除快照
    write    curl -i -H "Content-Type: application/json" -X DELETE -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "DeleteSnapshot", "params": {"PoolId": 0,"VdiskId": ${vdisk}}}' http://127.0.0.1:9300/p_api/v1/volumes/${volid}/snapshots/1
    ${output}    Read Until Prompt
    should contain    ${output}    result
    log    删除快照2
    write    curl -i -H "Content-Type: application/json" -X DELETE -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "DeleteSnapshot", "params": {"PoolId": 0,"VdiskId": ${vdisk2}}}' http://127.0.0.1:9300/p_api/v1/volumes/${volid2}/snapshots/1
    ${output}    Read Until Prompt
    should contain    ${output}    result
    log    删除卷
    write    curl -i -H "Content-Type: application/json" -X DELETE -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "DeleteVolume", "params": { \ "PoolId": 0,"VdiskId": ${vdisk} }}' http://127.0.0.1:9300/p_api/v1/volumes/${volid}
    ${output}    Read Until Prompt
    should contain    ${output}    result
    write    curl -i -H "Content-Type: application/json" -X GET -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "GetVolume", "params": { "PoolId": 0, "VdiskId": ${vdisk} }}' http://127.0.0.1:9300/p_api/v1/volumes/${volid}
    ${output}    Read Until Prompt
    should contain    ${output}    error
    write    curl \ -X GET http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}/volumes?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    result
    should not contain    ${output}    vol0-test
    log    删除vdisk
    write    curl -i -X DELETE \ http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    result
    write    curl -i -X GET http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    error
    log    删除卷2
    write    curl -i -H "Content-Type: application/json" -X DELETE -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "DeleteVolume", "params": { \ "PoolId": 0,"VdiskId": ${vdisk2} }}' http://127.0.0.1:9300/p_api/v1/volumes/${volid2}
    ${output}    Read Until Prompt
    should contain    ${output}    result
    write    curl -i -H "Content-Type: application/json" -X GET -d '{ "id": "5fb21aae-251a-11e9-ab14-d663bd873d93", "jsonrpc": "2.0", "method": "GetVolume", "params": { "PoolId": 0, "VdiskId": ${vdisk2} }}' http://127.0.0.1:9300/p_api/v1/volumes/${volid2}
    ${output}    Read Until Prompt
    should contain    ${output}    error
    write    curl \ -X GET http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk2}/volumes?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    result
    should not contain    ${output}    vol0-test
    log    删除vdisk2
    write    curl -i -X DELETE \ http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk2}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    result
    write    curl -i -X GET http://127.0.0.1:9300/p_api/v1/vdisks/${vdisk2}?poolid=0
    ${output}    Read Until Prompt
    should contain    ${output}    error
