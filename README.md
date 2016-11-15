
 因GitHub有文件大小限制，现将ILiveSDK、IMSDK、AVSDK以及相关Framework上传到腾讯云COS上。 更新时，请到对应的地址进行更新，并添加到工程下面对应的目录下.

Frameworks : http://dldir1.qq.com/hudongzhibo/ILiveSDK/Frameworks.zip 下载后解压，然后再放至对应放到工程目录 TILLiveSDKShow/

简介：ILiveSDK(全称:Interactive Live SDK)整合了互动直播SDK(AVSDK)，即时通讯SDK(IMSDK)，登录服务(TLSSDK)等几大模块，致力于提供一套完整的音视频即时通讯解决方案，提供“连麦”，“多画面特效”，打造跨平台一对多，多对多的酷炫直播场景。ILiveSDK旨在无限可能的降低用户接入成本，从用户角度考虑问题，全方位考虑用户接入体验，并提供接入服务专业定向支持，为用户应用上线保驾护航，本文档目的在于帮助用户快速接入使用ILiveSDK,达到主播端画面本地渲染，观众端可进入房间观看主播端画面的效果。

主要功能接口列表：

接口|所属类别|描述
---|---|---
initSdk:accountType|ILiveSDK|ILiveSDK初始化接口，传入appid和accountType
tlsLogin:pwd:succ:fail:|ILiveLoginManager|托管模式登录接口，传入用户名和密码
tlsLogout:succ:fail:|ILiveLoginManager	|托管模式登出接口
iLiveLogin:sig:succ:fail:|ILiveLoginManager|独立模式登录接口
iLiveLogout:succ:fail:|ILiveLoginManager|独立模式登出接口
createRoom:option:succ:fail:|ILiveRoomManager|创建直播间(主播调用)
joinRoom:iotion:succ:fail|ILiveRoomManager|加入直播间(观众调用)
quitRoom:succ:fail|ILiveRoomManager|退出直播间
createGLViewIn:|ILiveRoomManager|创建渲染根视图
addRenderAt:forKey:|ILiveGLBaseView	|创建渲染子视图

通过以上简单的接口，即可实现简易的直播方案。

本文档介绍3个SDK的集成和使用，分别是ILiveSDK，TILLiveSDK，TILCallSDK，架构关系如下：
![](http://img.blog.csdn.net/20161104170912962)

----------

请特别注意，这几个SDK是相互组合使用，不同场景使用不同的组合

直播场景：ILiveSDK+TILLiveSDK

可视电话：ILiveSDK+TILCallSDK

----------

# ILiveSDK(互动直播基础功能SDK)集成和使用

请参照这里 https://github.com/zhaoyang21cn/ILiveSDK_iOS_Demos/blob/master/ILiveSDK-README.md

------
# TILLiveSDK(直播)集成和使用

请参照这里 https://github.com/zhaoyang21cn/ILiveSDK_iOS_Demos/blob/master/TILLiveSDK-README.md

------

# TILCallSDK(多人通话)集成和使用

请参照这里 https://github.com/zhaoyang21cn/ILiveSDK_iOS_Demos/blob/master/TILCallSDK-README.md
