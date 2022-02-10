*** Settings ***
Library           SSHLibrary
Library           RequestsLibrary
Library           Collections

*** Variables ***
${host}           172.24.37.19    # 192.168.116.134
${vmdir}          /home/cjw/vm
${user}           root
${passwd}         ruijie    # 123456
${stordir}        /home/lfs/new0507/pos
${vm}             172.24.37.250
${devfeat}        RuiJie
${confdir}        ${stordir}/output/scripts
${rpcprefix}      ./rpc.py -s ${host} -p 5260
${rpcintv}        0.5
${port}           9622
${node1disk1}     "ZA21WYBN"    # 172.24.37.19"ZA21WYBN","ZA21VSFP"
${node1disk2}     "ZA21VSFP"
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
    add_pool0

rgstorteardown
    Close All Connections

add_pool0
    write    curl -i -H "Content-Type: application/json" -X POST -d '{"jsonrpc":"2.0","method": "AddPool","id":"5fb21aae-251a-11e9-ab14-d663bd873d93","params":{"Name":"pool1","ConstructType":1,"Description":"","NodeNum":'1',"SasHotspareStrategy":"mid","SataHotspareStrategy":"mid","SsdHotspareStrategy":"mid","NodeInfoList":[{"NodeId":1,"DiskList":[${node1disk1},${node1disk2}]}]}}' http://127.0.0.1:9300/p_api/v1/pools
    ${output}    Read Until Prompt
    write    curl -i -X GET http://127.0.0.1:9300/p_api/v1/pools/0
    ${output}    Read Until Prompt
    should contain    ${output}    result
