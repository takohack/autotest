## 项目架构
```
.
├── README.md
├── papiserver        //papiserver相关测试代码
│   ├── 1.Pool相关接口测试.robot
│   ├── 2.Vdisk相关接口测试.robot
│   ├── 3.Journal相关接口测试.robot
│   ├── 4.卷相关接口测试.robot
│   ├── 5.Qos相关接口测试.robot
│   ├── 6.iscsi相关接口测试.robot
│   ├── 7.Vhost相关接口测试.robot
│   ├── 8.PDeployer相关接口测试.robot
│   ├── 9.亚健康相关接口测试.robot
│   └── __init__.robot
├── result         //测试结果
│   ├── log.html
│   ├── output.xml
│   └── report.html
└── rgstor.robot //初始化一些参数 定义一些keywords(类似函数                  封装一组过程)
```
### 记录
1. 每次执行Write后记得要Read Until掉 不然会留在缓冲区造成下一次读取错误数据
2.  Requests库里的 to json 关键字已经弃用 换成了新的方式
3.  add_vdisk_parse_vdiskid  add_volume_parse_volid  这两个关键字已经封装了验证是否获取成功 调用完后不用再验证
4. 当前的测试环境 ip nodemyid disk_serial_number 都需要自己先去获取 后续可以实习自动获取
