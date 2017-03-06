## IOS_TILLiveSDK_ChangeList

###### V1.0.5(2017-3-6)
* ILVLiveMessage类增加属性TIMUserProfile
* ILVLiveCustomMessage增加属性TIMUserProfile
* 增加TILLiveRoomOption类继承于ILiveRoomOption，可自定义custom消息封装格式。

###### V1.0.4(2017-1-16)
* 增加以下接口:
  * removeAllAVRenderViews
  * getAllAVRenderViews
  * bringAVRenderViewToFront:srcType
  * sendAVRenderViewToFront:srcType
  * sendOtherMessage:toUser:succ:failed
* ILVLiveTextMessage和ILVLiveCustomMessage消息类增加消息优先级字段
* ILVLiveIMListener回调增加onOtherMessage回调
* 开放内部消息接口封装格式
* 删除上版本标识废弃的接口
