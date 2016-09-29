# 手动聚焦、缩放功能实现文档

------
因GitHub有文件大小限制，现将IMSDK以及AVSDK上传到腾讯云COS上。 更新时，请到对应的地址进行更新，并添加到工程下面对应的目录下

IMSDK : http://tcshowsdks-10022853.cos.myqcloud.com/20160830/IMSDK2.2.1.Release.zip 下载后解压，然后再放至对应放到工程目录 FocusDemo/TCAdapter/TIMAdapter/Framework/IMSDK

AVSDK：http://tcshowsdks-10022853.cos.myqcloud.com/20160902/AVSDK1.8.2.27.Release.zip 下载后解压，然后再放至对应放到工程目录 FocusDemo/TCAdapter/TCAVIMAdapter/Libs

------

AVSDK提供自动聚焦功能，用户不需要做任何操作。当用户需要对某一个感兴趣的点手动聚焦时，需要自己实现手动聚焦的功能。当用户希望放大看某一感兴趣点时，需要自己实现缩放功能。本文档提供手动聚焦和缩放功能的实现流程。
## 手动聚焦 ##
> **注：当前只支持后置摄像头手动聚焦**
> > 流程如下：
![](http://img.blog.csdn.net/20160921185424943)
> 
> 1、单击事件<br />
>  因为交互界面在最顶层，渲染界面在最底层，所以单击事件添加到交互界面上<br />
>  2、获取单击点坐标<br />
>  获取单击手势在视图上的坐标，此坐标是相对于交互视图的坐标<br />
>  3、将单击手势坐标转换为layer坐标<br />
>  步骤2获取的是相对于交互视图的坐标，要转换为画面渲染视图的坐标，将交互视图和渲染视图想对的屏幕的坐标同时计算出来，即可将交互视图坐标映射到渲染视图。见demo中layerPointOfInterestForPoint函数。<br />
>  4、获取AVCaptureSession并设置焦点<br />
>  通过AVSDK接口获取相机session，通过此session设置相机焦点，见demo 中onSingleTap函数<br />

## 缩放 ##
> 请参照demo中onDoubleTap函数