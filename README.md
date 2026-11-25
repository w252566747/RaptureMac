# RaptureMac

[日本語](README.ja.md) · [English](README.en.md)

一个原生 macOS 截图与贴图工具：点击窗口或拖拽区域后，截图会以可移动的浮动贴图保留在屏幕上。

> 非官方项目；灵感来自 Windows 版 Rapture。本项目与原软件作者没有隶属或授权关系。

## 功能

- 单击窗口截图；重叠窗口会按屏幕当前可见效果保留在截图中。
- 拖拽区域截图；点击空白桌面时截取当前屏幕。
- 截图停留在原窗口位置，可从图像或标题栏自由拖动。
- 可同时保留多张截图；右键 Dock 图标选择“下一张截图”。
- 按住 ⌘ 拖拽绘制红色自由线；按住 ⌘⇧ 拖拽绘制水平或垂直直线。
- 撤销最后一笔、右键复制与保存 PNG；双击截图会复制含涂鸦的图片并关闭。

## 权限

需要 macOS 屏幕录制权限：**系统设置 → 隐私与安全性 → 录屏与系统录音 → RaptureMac**。授权后请退出并重新打开应用。

## 本地构建

要求：macOS 14+、Xcode Command Line Tools、Swift、ScreenCaptureKit。

```zsh
git clone https://github.com/w252566747/RaptureMac.git
cd RaptureMac
./build-app.sh
open .build/RaptureMac.app
```

## 安全提示：未签名与 Gatekeeper

当前 Release **未使用 Apple Developer ID 签名，也未经过 Apple 公证**。macOS Gatekeeper 可能在首次打开时显示“无法验证开发者”或“Apple 无法检查是否包含恶意软件”的提示。

- 请只从本项目的官方 GitHub Release 下载，并核对 Release 提供的 SHA-256。
- 只有确认来源和校验值可信时，才在 **系统设置 → 隐私与安全性 → 仍要打开** 中手动允许。
- 公司/学校管理的 Mac 可能完全禁止打开未签名应用；可从源码构建，或等待后续签名公证版本。

## License

[MIT](LICENSE)
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
