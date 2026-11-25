# RaptureMac

[日本語](README.ja.md) · [English](README.en.md)

一个原生 macOS 截图与贴图工具：点击窗口或拖拽区域后，截图会以可移动的浮动贴图保留在屏幕上。

> 非官方项目；灵感来自 Windows 版 Rapture。本项目与原软件作者没有隶属或授权关系。

## 功能

- 点击窗口：截取鼠标所在窗口；重叠窗口会按屏幕当前可见效果保留在截图中。
- 拖拽区域：截取自定义范围；点击空白桌面时截取当前屏幕。
- 浮动贴图：截图停留在原窗口位置，可从图像或标题栏自由拖动。
- 多张截图：可同时保留多张贴图；Dock 图标右键菜单提供“下一张截图”。
- 涂鸦：按住 ⌘ 拖拽绘制红色自由线；按住 ⌘⇧ 拖拽绘制水平或垂直红线。
- 编辑：支持撤销最后一笔涂鸦、右键复制、保存 PNG、关闭贴图。
- 双击关闭：双击贴图会先把包含涂鸦的结果复制到剪贴板，再关闭贴图。
- 可选行为：功能设置可开关窗口点击、区域选择、置顶、移动、涂鸦与双击关闭。

## 使用方式

1. 从 [Releases](https://github.com/w252566747/RaptureMac/releases) 下载最新 ZIP 并解压。
2. 打开 `RaptureMac.app`，首次启动会进入截图模式。
3. 单击某个窗口，或拖拽选择区域。
4. 截图生成后可拖动它、涂鸦，或右键选择复制/保存。
5. 右键 Dock 中的 RaptureMac 图标，选择“下一张截图”可继续创建贴图。

## 权限

RaptureMac 需要 macOS 的“录屏与系统录音/屏幕录制”权限才能截图：

**系统设置 → 隐私与安全性 → 录屏与系统录音 → RaptureMac**

授权后请退出并重新打开应用。

## 本地构建

要求：macOS 14+、Xcode Command Line Tools、Swift 与 ScreenCaptureKit。

```zsh
git clone https://github.com/w252566747/RaptureMac.git
cd RaptureMac
./build-app.sh
open .build/RaptureMac.app
```

构建结果位于 `.build/RaptureMac.app`。此构建使用本机 ad-hoc 签名，不等于 Developer ID 签名或 Apple 公证。

## 安全提示：未签名与 Gatekeeper

当前 Release **未使用 Apple Developer ID 签名，也未经过 Apple 公证**。因此，macOS Gatekeeper 可能在第一次打开时显示“无法验证开发者”或“Apple 无法检查是否包含恶意软件”的提示。

- 请只从本项目的官方 GitHub Release 下载。
- 下载后请核对 Release 中提供的 SHA-256 校验值。
- 只有在确认来源和校验值可信时，才可在 **系统设置 → 隐私与安全性 → 仍要打开** 中手动允许该应用。
- 公司/学校受管理的 Mac 可能完全禁止打开未签名应用；此时请改为自行从源码构建，或等待后续签名和公证版本。

## 技术

- Swift + AppKit
- ScreenCaptureKit
- CoreGraphics
- 无第三方依赖

## License

[MIT](LICENSE)
