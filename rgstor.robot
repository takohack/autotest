*** Settings ***
Library           SSHLibrary    #ssh连接测试机器
Library           Collections
Library           String    #主要用了里面的字符串切割

*** Variables ***
${host}           172.24.21.7    # 集群VIP 用于ssh登录
${user}           root    #user
${passwd}         ruijie1688    # password
${port}           9622
${node1myid}      3    # cat /opt/zookeeper/data/myid
${node2myid}      2    # cat /opt/zookeeper/data/myid
${node1disk1}     "d01f8b5b-4eed-4b7f-a4b1-b0ea4b7f241b"    # 172.24.21.8 /dev/sde serial number
${node1disk2}     "fd089f68-3c43-49bf-be3d-6d652d8edbd3"    # 172.24.21.8 /dev/sdf serial number
${node2disk1}     "20846137-2026-499b-823d-64966cdafae3"    # 172.24.21.9 /dev/sde serial number
${node2disk2}     "51acbcb3-288f-487f-aac3-83d1b4308b84"    # 172.24.21.9 /dev/sdf serial number

*** Keywords ***
rgstorsetup
    Open Connection    ${host}    alias=conf    port=${port}
    login    ${user}    ${passwd}
    Set Client Configuration    prompt=#    #定义 Read Until的停止位置 这里每次调用都会以#结尾
    Set Client Configuration    timeout=60

rgstorteardown
    Close All Connections

add_vdisk_parse_vdiskid
    #从调用它的上下文中获取输入 提取其中的json部分 并取出它的vdiskid
    ${output}    Read Until    "jsonrpc": "2.0", "
    ${output}    Read Until    }[
    should contain    ${output}    result    #确认调用成功 就不用在测试中判断
    ${output}    Get Substring    ${output}    9    -2
    Read Until Prompt
    #${ret_result}    to json    ${output}
    ${ret_result}=    evaluate    json.loads('''${output}''')    json
    ${id}    get from dictionary    ${ret_result}    VdiskId
    [Return]    ${id}

add_volume_parse_volid
    ${output}    Read Until    "jsonrpc": "2.0", "
    ${output}    Read Until    }[
    should contain    ${output}    result    #确认调用成功 就不用在测试中判断
    ${output}    Get Substring    ${output}    9    -2
    Read Until Prompt
    #${ret_result}    to json    ${output}
    ${ret_result}=    evaluate    json.loads('''${output}''')    json
    ${id}    get from dictionary    ${ret_result}    VolumeId
    [Return]    ${id}
