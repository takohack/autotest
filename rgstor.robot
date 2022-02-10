*** Settings ***
Library           SSHLibrary       #ssh连接测试机器
Library           RequestsLibrary  #主要用到了里面的to json
Library           Collections
Library           String           #主要用了里面的字符串切割

*** Variables ***
${host}           172.24.21.7    # 集群VIP 用于ssh登录
${vmdir}          /home/cjw/vm
${user}           root    #user
${passwd}         ruijie1688    # password
${stordir}        /home/lfs/new0507/pos
${vm}             172.24.37.250
${devfeat}        RuiJie
${confdir}        ${stordir}/output/scripts
${rpcprefix}      ./rpc.py -s ${host} -p 5260
${rpcintv}        0.5
${port}           9622
${node1myid}      3    # cat /opt/zookeeper/data/myid
${node2myid}      2    # cat /opt/zookeeper/data/myid
${node1disk1}     "d01f8b5b-4eed-4b7f-a4b1-b0ea4b7f241b"    # 172.24.21.8 /dev/sde serial number
${node1disk2}     "fd089f68-3c43-49bf-be3d-6d652d8edbd3"    # 172.24.21.8 /dev/sdf serial number
${node2disk1}     "20846137-2026-499b-823d-64966cdafae3"    # 172.24.21.9 /dev/sde serial number
${node2disk2}     "51acbcb3-288f-487f-aac3-83d1b4308b84"    # 172.24.21.9 /dev/sdf serial number
${host2}          172.24.37.20
${host2_user}     root
${host2_passwd}    123456
${get_diskid}     lsscsi | grep RUIJIE | awk '{print $7}'
${mount_dir}      /home/chao/mount_tmp
${iscsi_target}    iqn.2020-11.io.ruijie:autotest

*** Keywords ***
rgstorsetup
    Open Connection    ${host}    alias=conf    port=${port}
    login    ${user}    ${passwd}
    Set Client Configuration    prompt=#
    Set Client Configuration    timeout=60

rgstorteardown
    Close All Connections

add_pool0
    write    curl -i -H "Content-Type: application/json" -X POST -d '{"jsonrpc":"2.0","method": "AddPool","id":"5fb21aae-251a-11e9-ab14-d663bd873d93","params":{"Name":"pool1","ConstructType":1,"Description":"","NodeNum":'1',"SasHotspareStrategy":"mid","SataHotspareStrategy":"mid","SsdHotspareStrategy":"mid","NodeInfoList":[{"NodeId":${node1myid},"DiskList":[${node1disk1},${node1disk2}]}]}}' http://127.0.0.1:9300/p_api/v1/pools
    ${output}    Read Until Prompt
    write    curl -i -X GET http://127.0.0.1:9300/p_api/v1/pools/0
    ${output}    Read Until Prompt
    should contain    ${output}    result

add_vdisk_parse_vdiskid
    ${output}    Read Until    "result":
    ${output}    Read Until    }[
    ${output}    Get Substring    ${output}    \    -2
    Read Until Prompt
    ${ret_result}    to json    ${output}
    ${id}    get from dictionary    ${ret_result}    VdiskId
    [Return]    ${id}
