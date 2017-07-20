# ILiveSDK
ILiveSDK 提供了账号登录，音视频互动，文本互动等基础功能，顺利的话一天之内即可集成音视频能力。

支持以下场景     
>* [视频直播类]
类似now直播,映客 一人直播,多人观看,发文本消息,赞,送礼物。[具体参考TILLiveSDK](https://github.com/zhaoyang21cn/ILiveSDK_iOS_Demos/blob/master/TILLiveSDK-README.md)
>* [视频聊天类]
     类似微信视频通话功能呢,支持多人同时上麦(最多4路)。[具体参考TILCallSDK](https://github.com/zhaoyang21cn/CallSDK_iOS_Demo)

## SDK下载

|SDK|版本号|摘要|下载地址|
|--|--|--|--|
|QAVSDK|1.9.1.17.OpenSDK_1.9.1-26127|音视频SDK|[下载](http://dldir1.qq.com/hudongzhibo/ILiveSDK/AVSDK.zip)
|IMSDK|v2.5.4.10421.10420|即时通讯SDK|[下载](http://dldir1.qq.com/hudongzhibo/ILiveSDK/IMSDK.zip)
|ILiveSDK|1.5.2.11171|互动直播核心业务SDK|[下载](	http://dldir1.qq.com/hudongzhibo/ILiveSDK/ILiveSDK.framework.zip)
|TILLiveSDK|1.1.2|直播业务SDK|[下载](http://dldir1.qq.com/hudongzhibo/ILiveSDK/TILLiveSDK.framework.zip)
|QAVEffect|--|QAVSDK的内置美颜包|[下载](http://dldir1.qq.com/hudongzhibo/ILiveSDK/QAVEffect.zip)
|TILFilterSDK|1.2.3|插件美颜包|[下载](http://dldir1.qq.com/hudongzhibo/ILiveSDK/TILFilterSDK.zip)

## SDK最近更新说明

###### V1.5.2.11171(2017－7-20)
* 1、修复退出房间后，还能获取到房间号的问题
* 2、修复内部自动请求画面无回调问题(连续两次调用requestview导致)
* 3、推流失败时返回8052错误码(这个错误码不对，已经修正)
* 4、增加开播前预览兼容
* 5、增加是否自动接收屏幕分享画面的配置开关

[更多版本更新信息](https://github.com/zhaoyang21cn/ILiveSDK_iOS_Demos/blob/master/doc/ILiveSDK_ChangeList.md)

## ILiveSDK导入

[ILiveSDK导入参考在这里](https://github.com/zhaoyang21cn/ILiveSDK_iOS_Demos/blob/master/ILiveSDK-README.md)

## DEMO
有两个示例 <br />
1 随心播 ：基于ILiveSDK接口重构的随心播[运行配置参考](https://github.com/zhaoyang21cn/iLiveSDK_iOS_Suixinbo/tree/master/suixinbo)<br />
2 简单直播 ：直播功能模块演示[已迁移至这里](https://github.com/zhaoyang21cn/iLiveSDK_iOS_LiveDemo)  <br />

## API文档
[API文档](https://zhaoyang21cn.github.io/iLiveSDK_Help/ios_help/)

## 错误码
[错误码表](https://github.com/zhaoyang21cn/ILiveSDK_Android_Demos/blob/master/doc/ILiveSDK/error.md)

## 直播外延

[美颜滤镜](https://github.com/zhaoyang21cn/ILiveSDK_iOS_Demos/blob/master/TILFilterSDK-README.md)

[大咖模式](https://github.com/zhaoyang21cn/suixinbo_doc/blob/master/%E5%A4%A7%E5%92%96%E6%A8%A1%E5%BC%8F.md)

[跨房连麦](https://github.com/zhaoyang21cn/ILiveSDK_iOS_Demos/blob/master/doc/%E8%B7%A8%E6%88%BF%E8%BF%9E%E9%BA%A6.md)

[滤镜，挂件，变声等](https://github.com/zhaoyang21cn/ILiveSDK_iOS_Demos/blob/master/doc/%E7%89%B9%E8%89%B2%E5%8A%9F%E8%83%BD.md)

## 已知问题

## 关键路径LOG
[关键路径LOG 请遇到问题先自行对比](https://github.com/zhaoyang21cn/suixinbo_doc/blob/master/doc2/log.md)

## 联系我们
技术支持QQ群：594923937 207177891

技术需求反馈：https://github.com/zhaoyang21cn/ILiveSDK_iOS_Demos/issues 
