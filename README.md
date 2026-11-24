# RaptureMac

一个原生 macOS 截图与贴图工具：点击窗口或拖拽区域后，截图会以可移动的浮动贴图保留在屏幕上。

> 非官方项目；灵感来自 Windows 版 Rapture。本项目与原软件作者没有隶属或授权关系。

## 功能

- 点击窗口：截取鼠标所在窗口；重叠窗口会按屏幕当前可见效果保留在截图中。
- 拖拽区域：截取自定义范围；点击空白桌面时截取当前屏幕。
- 浮动贴图：截图停留在原窗口位置，可从图像或标题栏自由拖动。
- 多张截图：可同时保留多张贴图；Dock 图标右键菜单提供“下一张截图”。
- 涂鸦：按住 `⌘` 拖拽绘制红色自由线；按住 `⌘⇧` 拖拽绘制水平或垂直红线。
- 编辑：支持撤销最后一笔涂鸦、右键复制、保存 PNG、关闭贴图。
- 双击关闭：双击贴图会先把包含涂鸦的结果复制到剪贴板，再关闭贴图。

## 本地构建

```zsh
git clone https://github.com/YOUR_ACCOUNT/RaptureMac.git
cd RaptureMac
./build-app.sh
open .build/RaptureMac.app
```

## License

[MIT](LICENSE)
