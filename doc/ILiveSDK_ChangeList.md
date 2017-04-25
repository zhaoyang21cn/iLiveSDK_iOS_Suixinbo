## iOS_ILiveSDK_ChangeList


###### V1.4.0(2017－4-25)
* **特别注意：更新到ILiveSDK_1.4.0,QAVSDK1.9.0需要增加AssetsLibrary.framework**
* 1、跨房连麦功能
* 2、挂件(随心播中提供两个免费挂件体验)
* 3、滤镜(随心播中提供若干免费滤镜体验)
* 4、变声(SDK中提供若干免费变声效果)
* 5、增加发送在线消息接口
* 6、log主动上报，方便用户自己上传log，查找问题
* 7、修复美颜包在部分分辨率(960x540)下花屏以及绿边的问题
* 8、修复iOS7上打印log Crash问题（containsString 函数导致）
* 9、优化LOG打印频繁操作文件问题
* 10、优化登录时常出现“network not reachable”提示问题

###### V1.3.3(2017－3-24)
* 1、增加日志上报功能
* 2、增加腾讯云图API生成鉴权签名串接口
* 3、修复创建（进入）房间前添加renderview无效的问题
* 4、完善ilivesdk log
* 5、增加独立美颜包，优化美颜和滤镜效果。[具体参考这里](https://github.com/zhaoyang21cn/ILiveSDK_iOS_Demos/blob/master/TILFilterSDK-README.md)

###### V1.3.2(2017－3-8)
* 1、修复 打开扬声器接口失灵的问题
* 2、暴露 画面帧回调接口（预处理画面时需要用到）

###### V1.3.1(2017－3-8)
* 1、新增创建房间时是否创建音视频房间的配置项
* 2、修复网络模块符号冲突的问题

###### V1.3.0(2017－3-6)
* 1、测速接口改变：测速接口内部协议由二进制改成PB协议，测速接口和回调参数全部更新，详情参考ILiveSpeedTestManager.h文件。
* 2、推流接口参数改变，支持直播码模式的推流参数，详情请参考ILivePushOption.h文件
* 3、录制接口实现改变，录制接口的实现发生了改变。
* 4、修复退房间死锁问题，退房间会等待5s才能退出成功，已修复

###### V1.2.2(2017-2-13)
* 更新avsdk1.8.5
* 修复iLiveSDK停止录制时crash，以及开始推流和停止推流时crash问题
* 增加iLiveSDK独立日志打印模块，日志路径为../Library/Caches/ilivesdk_xxxxxxxx.log(xxxxxxxx是日期，比如ilivesdk_20170213.log)

###### V1.2.1(2017-1-19)
* 修复直播间内多次退后台崩溃的问题

###### V1.2.0(2017-1-16)
* 支持多View渲染
* 支持旋转模式可配，具体参考[旋转文档](https://github.com/zhaoyang21cn/suixinbo_doc/blob/master/doc2/rotate.md)
* 修复pc屏幕分享画面模糊的问题
* ILiveRoomManager去掉glBaseView接口，增加getFrameDispatcher接口
* 去掉ILiveBaseView类，增加ILiveFrameDispatcher类，所有有关渲染的接口从ILiveBaseView类转移到ILiveFrameDispatcher类

###### V1.1.2(2017-1-4)
* 修复不能同时拉主播屏幕分享画面和摄像头画面的问题

###### V1.1.1(2016-12-28)
* 修复交换渲染位置失败的bug

###### V1.1.0(2016-12-27)
* ILiveRoomOption配置项开放
* 支持同时显示pc的screen和camera两路视频
* 增加切换房间接口
* 修改以下接口（增加srcType参数，原对应旧接口将废弃）
  1.addRenderAt:forIdentifier:srcType
  2.removeRenderViewFor:srcType
  3.bringRenderViewToFront:srcType
  4.sendRenderViewToBack:srcType
  5.switchRenderViewOf:srcType:withRender:anotherSrcType
  6.getRenderView:srcType
* 修复用户被踢重新登录返回1003错误码的问题

###### V1.0.4(2016-12-14)
* 修复头文件引用问题

###### V1.0.3(2016-12-13)
* 增加关键路径日志
* 增加首帧回调接口

###### V1.0.2(2016-12-06)
* 修改频道参数类名冲突问题（增加前缀）
* 增加美颜，美白接口
* 完善主线流程日志

###### V1.0.1(2016-11-24)
* 修复打开/关闭麦克风时，如果已经是该状态，操作失败的问题
* 修复打开/关闭相机时，如果已经是该状态，操作失败的问题
* 将监听回调移动到初始化类中，增加监听调用顺序注释
* 增加音频场景配置，增加设置音频模式接口

###### V1.0.0(2016-11-21)
* 移出getAVRoom接口，新增getRoomId和getIMGroupId接口
* 调整相机切换接口（不需要再传入相机方位，直接进行前后切换）
* 更新渲染逻辑，兼容自动转置

---

###### V0.1.3(2016-11-15)
* 修复无法收到消息问题
* 修复用户被踢下线，再次登录时提示1003错误问题，增加互踢监听
* 将ILiveSDK日志打印到ImSDK日志文件中

###### V0.1.2(2016-11-14)
* 修复推流失败问题
* 修复录制失败问题

###### V0.1.1(2016-11-12)
* 新增直播质量参数接口
* 修复修改角色无回调问题
* 统一错误码

###### V0.1.0(2016-11-1)
* ILiveSDK第一个版本，实现互动直播主线流程以及主要接口的封装
* 主线流程：包括注册，登录，创建房间，加入房间，退出房间，画面渲染
* 主要接口：请求/取消画面，相机，麦克风，扬声器相关操作，角色、权限修改，群组消息、C2C消息收发，推流、录制相关操作
