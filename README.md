# RepoBar 🚦 — 告别网页标签泛滥的 macOS GitHub 菜单栏客户端（简体中文完整汉化版）

[![Release Build](https://img.shields.io/github/actions/workflow/status/cubelikeplayDaniel/RepoBar/release.yml?branch=main&style=flat-square&label=release%20build)](https://github.com/cubelikeplayDaniel/RepoBar/actions/workflows/release.yml)
[![GitHub release](https://img.shields.io/github/v/release/cubelikeplayDaniel/RepoBar?style=flat-square&label=release)](https://github.com/cubelikeplayDaniel/RepoBar/releases/latest)
[![macOS 15+](https://img.shields.io/badge/macOS-15%2B-000000?style=flat-square&logo=apple)](https://github.com/cubelikeplayDaniel/RepoBar/releases/latest)
[![Swift 6.2](https://img.shields.io/badge/Swift-6.2-F05138?style=flat-square&logo=swift&logoColor=white)](https://www.swift.org/)
[![License](https://img.shields.io/github/license/cubelikeplayDaniel/RepoBar?style=flat-square)](LICENSE)

**RepoBar** 是一款基于 SwiftUI 与 AppKit 原生构建的 macOS 菜单栏 GitHub 客户端，专为需要同时追踪多个 GitHub 仓库的开发者与维护者设计。它将 Issue 与拉取请求（PR）数量、CI 状态、发布版本（Releases）、最新动态、API 速率限制以及本地代码仓库状态浓缩在同一个菜单栏图标中，随时一瞥即知。

本仓库基于上游 [`steipete/RepoBar`](https://github.com/steipete/RepoBar) 构建，提供 **100% 完整简体中文本地化支持** 与 **开箱即用的免钥匙串弹窗体验**，并由 GitHub Actions 全自动构建派发多架构安装包。

![RepoBar 仓库状态、本地 Git 状态与 Issues 子菜单展示](docs/assets/repobar.png)

---

## ✨ 中文发行版核心优化亮点

1. **全界面 100% 简体中文深度覆盖（共 420 项词条）**
   - **主菜单与仓库二级子菜单**：仓库卡片、CI 运行状态、Issues、拉取请求 (PR)、发布版本 (Releases)、讨论、分支、工作树 (Worktrees)、提交记录、贡献者、热力图以及 Actions/Runners 队列配额全面汉化。
   - **Issue 导航器（Issue Navigator）**：独立搜索窗口的搜索占位符、仓库范围下拉菜单、类型分段切换控件（`Issue + PR` / `Issue` / `拉取请求 (PR)`）、匹配计数徽标、剪贴板自动识别提示、空状态提示语与右键上下文菜单完整汉化。
   - **偏好设置全标签页**：通用、显示、仓库管理表格、账户管理、通知、高级设置、GitHub API 用量详情、GitHub 归档、调试诊断与关于页面全部汉化。
   - **相对时间多语言格式化**：全面接入系统级多语言时间格式（如 `45秒前`、`3分钟前`、`2小时前`）。
2. **原生接入 macOS 系统级语言切换**
   - 自动跟随 macOS 系统首选语言，同时支持在 **系统设置 → 通用 → 语言与地区 → 应用程序** 中为 RepoBar 单独指定语言（`简体中文` / `English` / `Türkçe`）。
3. **免钥匙串频繁授权弹窗加固与专属自动更新通道**
   - 针对非付费 Apple Developer ID 签名的独立分发场景，默认启用安全文件凭据存储（`0600` 权限，位于 `~/Library/Application Support/RepoBar/`），**彻底解决每次刷新或重启时 macOS 钥匙串重复弹窗要求输入密码的问题**。
   - 内置 Sparkle 自动更新通道已使用专属 Ed25519 密钥对重签并绑定至本中文仓库（`cubelikeplayDaniel/RepoBar` 的 `appcast.xml`），支持在 **偏好设置… → 关于** 中一键检查并平滑升级后续中文版本。

---

## 📦 下载与安装

请前往 [**GitHub Releases 最新发行版页面**](https://github.com/cubelikeplayDaniel/RepoBar/releases/latest) 根据您的 Mac 芯片类型下载对应的安装包（要求 **macOS 15.0** 及以上系统）：

| 适用设备 / 架构 | 图形化安装包 (DMG 拖拽安装) | 免安装压缩包 (ZIP) | 命令行工具 (CLI) |
| :--- | :--- | :--- | :--- |
| **Apple Silicon (M1 / M2 / M3 / M4)** | [`RepoBar-v0.10.4-zh-Hans-macOS-arm64.dmg`](https://github.com/cubelikeplayDaniel/RepoBar/releases/latest/download/RepoBar-v0.10.4-zh-Hans-macOS-arm64.dmg) | [`RepoBar-v0.10.4-zh-Hans-macOS-arm64.zip`](https://github.com/cubelikeplayDaniel/RepoBar/releases/latest/download/RepoBar-v0.10.4-zh-Hans-macOS-arm64.zip) | [`repobarcli-v0.10.4-zh-Hans-macOS-arm64.tar.gz`](https://github.com/cubelikeplayDaniel/RepoBar/releases/latest/download/repobarcli-v0.10.4-zh-Hans-macOS-arm64.tar.gz) |
| **Intel Mac (`x86_64`)** | [`RepoBar-v0.10.4-zh-Hans-macOS-x86_64.dmg`](https://github.com/cubelikeplayDaniel/RepoBar/releases/latest/download/RepoBar-v0.10.4-zh-Hans-macOS-x86_64.dmg) | [`RepoBar-v0.10.4-zh-Hans-macOS-x86_64.zip`](https://github.com/cubelikeplayDaniel/RepoBar/releases/latest/download/RepoBar-v0.10.4-zh-Hans-macOS-x86_64.zip) | [`repobarcli-v0.10.4-zh-Hans-macOS-x86_64.tar.gz`](https://github.com/cubelikeplayDaniel/RepoBar/releases/latest/download/repobarcli-v0.10.4-zh-Hans-macOS-x86_64.tar.gz) |
| **通用双架构 (Universal)** | [`RepoBar-v0.10.4-zh-Hans-macOS-universal.dmg`](https://github.com/cubelikeplayDaniel/RepoBar/releases/latest/download/RepoBar-v0.10.4-zh-Hans-macOS-universal.dmg) | [`RepoBar-v0.10.4-zh-Hans-macOS-universal.zip`](https://github.com/cubelikeplayDaniel/RepoBar/releases/latest/download/RepoBar-v0.10.4-zh-Hans-macOS-universal.zip) | [`repobarcli-v0.10.4-zh-Hans-macOS-universal.tar.gz`](https://github.com/cubelikeplayDaniel/RepoBar/releases/latest/download/repobarcli-v0.10.4-zh-Hans-macOS-universal.tar.gz) |

### 安装步骤
1. 下载上方对应的 `.dmg` 镜像并双击打开，将 `RepoBar.app` 拖拽到 `Applications`（应用程序）文件夹中。
2. 由于社区开源发行版未經過 Apple 公证（Notarization），首次启动若提示“无法验证开发者”或“已损坏”，请在终端（Terminal）运行以下命令移除隔离属性后即可正常打开：
   ```bash
   xattr -cr /Applications/RepoBar.app
   ```

---

## 🚀 快速上手

1. 从“应用程序”中启动 **RepoBar**，屏幕顶部菜单栏会出现红绿灯状态图标。
2. 点击菜单栏图标，选择 **登录到 GitHub** 并在浏览器中完成授权登录。
3. 打开 **偏好设置… → 仓库**，搜索并选择您需要设为 **已固定（Pinned）**、**可见（Visible）** 或 **已隐藏（Hidden）** 的仓库。
4. 在主菜单中将鼠标悬停在任意仓库上，即可直接在二级菜单中查看该仓库的 **Issue**、**拉取请求 (PR)**、**发布版本 (Releases)**、**CI 运行记录**、**分支**、**标签**、**提交记录** 与 **活动动态**。
5. 点击菜单中的 **Issue 导航器…**，可在独立分栏窗口中按标题、URL、`owner/repo#编号` 或提交哈希快速检索并预览 Issue 与 PR。

---

## 🖥️ 核心功能概览

### 1. 仓库动态仪表盘与外观自定义
- 主菜单直观展示各仓库的未决 Issue 与 PR 数量、Star/Fork 计数、最新事件、CI 状态、发布版本及提交贡献热力图。
- 支持顶部筛选标签，一键切换查看 **全部**、**已固定**、**本地** 或有活跃任务的仓库。
- 在 **偏好设置… → 通用 → 显示 → 外观** 中可选择 **浅色**、**深色** 或 **跟随系统**。
- 在 **偏好设置… → 显示** 中可自由拖拽调整主菜单和仓库子菜单的显示顺序，或隐藏不需要的菜单项。

### 2. 身份验证与私有仓库支持
- 支持 **GitHub.com**（内置 OAuth 应用 / 个人访问令牌 PAT）与 **GitHub Enterprise（企业版）**。
- 使用内置 GitHub.com OAuth 登录时，若需查看所属组织（Organization）下的私有仓库，请确保已在对应组织或仓库上安装 [RepoBar GitHub App](https://github.com/apps/repobar/installations/new)。
- 对于启用了 SAML SSO 的组织或需要细粒度权限的场景，可在 **偏好设置… → 账户** 中切换到 **个人访问令牌 (PAT)** 模式（需具备 `repo` 与 `read:org` 权限范围）。

### 3. 本地项目联动（Local Projects）
- 在 **偏好设置… → 高级 → 本地项目** 中设置您的本地代码根目录后，RepoBar 会自动扫描并将本地 Git 仓库与云端 GitHub 仓库关联。
- 在仓库子菜单中实时显示当前分支、上游同步状态（领先/落后提交数）、未提交修改文件列表以及 Git Worktree 工作树列表。
- 支持从菜单直接 **在访达 (Finder) 中打开** 或 **在终端中打开**（支持 Terminal、iTerm2、Ghostty、Warp、Kitty、Alacritty、WezTerm 等主流终端），并支持对干净的工作区执行自动快进同步（Fast-Forward Pull）。

### 4. 本地持久缓存、离线归档与剪贴板引用监控
- 启动时优先从本地 SQLite 持久缓存秒开渲染，并在后台异步刷新 GitHub 数据。
- 在主菜单 **GitHub API 状态** 中可随时查看 REST 核心请求配额、GraphQL 点数剩余预算及重置倒计时。
- 在 **偏好设置… → 高级 → GitHub 引用** 中开启 **监控复制的 GitHub 引用** 后，复制 GitHub 链接、Issue 编号或 Commit SHA 时会在菜单栏单独展示最佳匹配项。

### 5. 命令行工具（`repobar` CLI）
RepoBar 内置了配套的命令行工具 `repobarcli`，可在 **偏好设置… → 高级 → 命令行工具** 中点击 **安装命令行工具 (CLI)** 一键安装至 `/usr/local/bin` 与 `/opt/homebrew/bin`（或直接从 Release 页面下载独立的 `repobarcli-*.tar.gz`）：

```bash
repobar repos --sort prs --plain
repobar rate-limits --plain
repobar cache status --json
```

---

## 🛠️ 本地编译与二次开发

环境要求：macOS 15+、Xcode 26+（Swift 6.2）

```bash
# 运行完整单元测试套件（含多语言词条对齐校验）
./Scripts/test.sh

# 编译 Universal 双架构 Release 应用包 (.build/release/RepoBar.app)
./Scripts/package_app.sh release

# 一键生成全架构 DMG、ZIP、CLI tar.gz 安装包及 SHA256SUMS.txt (输出至 dist/)
./Scripts/package_release_assets.sh
```

更多架构与设计文档请参阅：
- [原始产品规范 (docs/spec.md)](docs/spec.md)
- [CLI 命令行参考 (docs/cli.md)](docs/cli.md)
- [缓存与归档架构 (docs/cache.md)](docs/cache.md)
- [凭据存储机制 (docs/auth-storage.md)](docs/auth-storage.md)
- [本地项目同步机制 (docs/reposync.md)](docs/reposync.md)

---

## 📄 开源协议与致谢

本项目基于 [MIT License](LICENSE) 开源。
- 原作者与上游仓库：[Peter Steinberger (`steipete/RepoBar`)](https://github.com/steipete/RepoBar)
- 简体中文完整本地化与多架构自动构建发行维护：[@cubelikeplayDaniel](https://github.com/cubelikeplayDaniel/RepoBar)
