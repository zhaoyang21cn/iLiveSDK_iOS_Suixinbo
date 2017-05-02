

# TILFilterSDK使用文档

[美颜滤镜SDK下载](http://dldir1.qq.com/hudongzhibo/ILiveSDK/TILFilterSDK_1.0.7.zip)

TILFilterSDK是为ILiveSDK量身定做的视频帧预处理插件，目前提供美颜美白功能及其他常用滤镜功能。集成步骤如下：

## 1. 初始化TILFilter对象

```
self.tilFilter = [[TIFilter alloc] init];
```

## 2. 设置预处理回调
IOS需要升级到ILiveSDK1.3.2
```
[[ILiveRoomManager getInstance] setLocalVideoDelegate:self];
```

## 3. 处理数据
**注意:** IOS需要升级到ILiveSDK1.3.2

```
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


## 4. 设置滤镜

```
4.1 默认为美颜美白滤镜，可设置美颜美白
[self.tilFilter setWhite:value];
[self.tilFilter setBeauty:value];

4.2 设置其他滤镜（日系、怀旧、唯美等）
[self.tilFilter setFilter:TILFilterType_RiXi];
```
