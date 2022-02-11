*** Settings ***
Library           SSHLibrary    #ssh连接测试机器
Library           Collections    #json中查找指定标签
Library           String    #主要用了里面的字符串切割

*** Variables ***
${host}           172.24.37.21    # 集群VIP 用于ssh登录
${user}           root    #user
${passwd}         ruijie1688    # password
${port}           9622
${node1myid}      1    # cat /opt/zookeeper/data/myid
${node1disk1}     "WJG25F42"
${node1disk2}     "WJG270F6"

*** Keywords ***
rgstorsetup
    #每次测试前先建立连接
    Open Connection    ${host}    alias=conf    port=${port}
    login    ${user}    ${passwd}
    Set Client Configuration    prompt=#    #定义 Read Until的停止位置 这里每次调用都会以#结尾
    Set Client Configuration    timeout=60

rgstorteardown
    #每个测试结束后关闭连接
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
    #根据上下文输入 获取VolumeId
    ${output}    Read Until    "jsonrpc": "2.0", "
    ${output}    Read Until    }[
    should contain    ${output}    result    #确认调用成功 就不用在测试中判断
    ${output}    Get Substring    ${output}    9    -2
    Read Until Prompt
    #${ret_result}    to json    ${output}
    ${ret_result}=    evaluate    json.loads('''${output}''')    json
    ${id}    get from dictionary    ${ret_result}    VolumeId
    [Return]    ${id}
