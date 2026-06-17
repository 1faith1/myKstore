# 1、=============
```
# gitcode中存储的picture中的地址未使用：因无法通过api直接获取访问地址
当前自定义的source.txt_bak中，图标地址使用Kstore网站中存储图片的地址。

访问地址示例如下：
https://d.kstore.dev/download/9479/LOOK-TV/picture/CCTV1.png
https://d.kstore.dev/download/9479/LOOK-TV/picture/CCTV2.png
https://d.kstore.dev/download/9479/LOOK-TV/picture/CCTV3.png
。。。。。
https://d.kstore.dev/download/9479/LOOK-TV/picture/CCTV15.png
```

# 2、=============
```
新版本resource.txt中取消了图标地址使用

字段含义介绍：
  # 当前台名称
  tvg-name="CCTV1"
  #台标图片，如果不写则不显示(有些会显示默认图标)
  tvg-logo="https://d.kstore.dev/download/9479/LOOK-TV/picture/CCTV1.png"
  #分组标签(央视|卫视|动漫)
  group-title="央视频道"
  # 备注信息
  CCTV-1 综合

新旧版本中简介模版央视对比
  旧版本样式：
  #EXTINF:-1 tvg-name="CCTV1" tvg-logo="https://d.kstore.dev/download/9479/LOOK-TV/picture/CCTV1.png" group-title="央视频道",CCTV-1 综合

  新版本样式：
  #EXTINF:-1 tvg-name="CCTV1" group-title="央视频道",
```