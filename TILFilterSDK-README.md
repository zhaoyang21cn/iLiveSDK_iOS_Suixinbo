## 特效功能(美颜、美白、瘦脸、大眼、动效贴纸)

### 功能说明

sdK提供美颜、美白、滤镜、大眼、瘦脸、动效贴纸、绿幕等功能，其中大眼、瘦脸、动效贴纸是基于优图实验室的人脸识别技术和天天P图的美妆技术为基础开发的特权功能，通过跟优图和P图团队合作，将这些特效深度整合到图像处理流程中，以实现更好的视频特效。

### 费用说明

由于采用了优图实验室的专利技术，授权费用约 50W/年（目前国内同类图像处理产品授权均在百万左右）。如有需要可以提工单或客服电话（400-9100-100）联系我们，商务同学会提供P图SDK，并替您向优图实验室申请试用 License。

### Xcode工程设置

#### 1. 导入依赖包（framework、bundle、license、resource）

[点击此处下载最新版本TILFilterSDK](https://github.com/zhaoyang21cn/ILiveSDK_iOS_Suixinbo)

[查看SDK版本更新记录](https://github.com/zhaoyang21cn/ILiveSDK_iOS_Suixinbo/blob/master/doc/TILFilterSDK_ChangeList.md)

>* 高级版本（大眼、瘦脸、动效贴纸）需要集成p图sdk
>* 基础版本可以跳过此步骤。如需使用滤镜功能，只需加载TILFilterResource.bundle资源包

| | | 
:-----:|:-----:|
![](https://mc.qcloudimg.com/static/img/42f75e24f9dcfb82faf5681b853910e2/1.png)|![](https://mc.qcloudimg.com/static/img/9d80f889c53cd9ecf5ba8c67ef5ae3ef/2.png)|


#### 2. 设置编译选项

| |
:-----:|
![](https://mc.qcloudimg.com/static/img/3c1f508f3eb4a123f15e3b5dbbffcf39/3.png)|
![](https://mc.qcloudimg.com/static/img/4e9d4875e5c837866779ddda7dbc7167/4.png)|

### 功能调用

使用TILFilterSDK前，请集成ILiveSDK并完成以下三步曲。

>* IOS需要升级到ILiveSDK1.3.2

```object-c
//1.初始化对象
self.tilFilter = [[TIFilter alloc] init];

//2.设置回调
[[ILiveRoomManager getInstance] setLocalVideoDelegate:self];

//3.调用预处理接口
- (void)OnLocalVideoPreProcess:(QAVVideoFrame *)frame
{
    TILDataType type = TILDataType_NV12;
    switch (frame.frameDesc.color_format)
    {
        case AVCOLOR_FORMAT_I420:
            type = TILDataType_I420;
            break;
        case AVCOLOR_FORMAT_NV12:
            type = TILDataType_NV12;
            break;
        default:
            break;
    }
    [self.tilFilter processData:frame.data inType:type outType:type size:frame.dataSize width:frame.frameDesc.width height:frame.frameDesc.height];
}
```

```object-c
/*
 * 预处理数据
 * @param   data    帧数据
 * @param   inType  输入帧数据格式(nv12,i420)
 * @param   outType 输出帧数据格式(nv12,i420)
 * @param   size    帧数据大小
 * @param   width   帧宽
 * @param   height  帧高
 * @return  int     返回0处理成功
 */
- (int)processData:(uint8_t *)data inType:(TILDataType)inType outType:(TILDataType)outType size:(int)size width:(int)width height:(int)height;
```

#### 1. 基础功能

>* 美颜
>* 美白
>* 滤镜
>* 绿幕


```object-c
/*
 * 设置美颜（0-10）
 * @param   level    美颜程度，0表示原图
 */
- (void)setBeautyLevel:(NSInteger)level;

/*
 * 设置美白（0-10）
 * @param   level    美白程度，0表示原图
 */
- (void)setWhitenessLevel:(NSInteger)level;
```

可以使用sdk自带的滤镜资源，也可以自定义滤镜资源，通过设置融合度调整滤镜资源和图像的融合程度

```object-c
/*
 * 设置滤镜
 * @param   type  滤镜类型
 */
- (void)setFilterType:(TXEFilterType)type;

/*
 * 设置滤镜
 * @param   imagePath  滤镜资源路径
 */
- (void)setFilterImage:(NSString *)imagePath;

/*
 * 设置滤镜融合度（0-10）
 * @param   level    滤镜融合度
 */
- (void)setFilterMixLevel:(NSInteger)level;
```

使用绿幕需要先准备一个用于播放的mp4文件，通过调用以下接口即可开启绿幕效果（紧张开发中，敬请期待...）

```object-c
/*
 * 设置绿幕
 * @param   file  绿幕文件路径
 */
- (void)setGreenScreenFile:(NSString *)file;
```

#### 2. 高级功能

>* 大眼
>* 瘦脸
>* 动效


```object-c
/*
 * 设置大眼（0-10）
 * @param   level    大眼程度
 */
- (void)setEyeScaleLevel:(NSInteger)level;

/*
 * 设置瘦脸（0-10）
 * @param   level    瘦脸程度
 */
- (void)setFaceSlimLevel:(NSInteger)level;
```

将动效资源解压在Resource目录下，通过资源路径设置动效

```object-c
/*
 * 设置动效
 * @param   templatePath  动效资源路径
 */
- (void)setMotionTemplate:(NSString *)templatePath;
```


