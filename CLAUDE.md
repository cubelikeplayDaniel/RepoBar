# RepoBar 简体中文维护与协同规范

本项目是 [`steipete/RepoBar`](https://github.com/steipete/RepoBar) 的独立简体中文维护分支（[`cubelikeplayDaniel/RepoBar`](https://github.com/cubelikeplayDaniel/RepoBar)），由自动化流水线与轻量模型协同巡检更新。

为了确保在换用轻量/快速模型（如 `claude-sonnet-5-5`、`claude-haiku-5-5`）时能够稳定合并上游代码、补齐汉化并发布多架构安装包，所有维护与代码变更操作**必须严格遵循本规范**。

---

## 🛑 三大核心架构红线（严禁破坏）

在合并上游 `upstream/main` 产生冲突或修改打包脚本时，**绝对不可覆盖**以下三项定制：

### 1. 凭据存储免钥匙串弹窗（TokenStore = file）
- **背景**：开源分发版使用 ad-hoc 签名，缺乏 Apple Developer ID。macOS 默认将 GitHub Token 存入 Keychain 会导致每次应用启动或刷新时频繁弹窗索要密码。
- **红线**：`Info.plist` 中必须保留：
  ```xml
  <key>RepoBarTokenStore</key>
  <string>file</string>
  ```
  文件存储机制会将 Token 以 `0600` 权限安全保存在 `~/Library/Application Support/RepoBar/`。
- **保护文件**：`Scripts/package_app.sh`、`Scripts/package_release_assets.sh`。

### 2. Sparkle 自动更新通道与密钥隔离
- **背景**：原项目绑定原作者 Peter 的 Sparkle 签名与 Feed。如果被冲刷，用户在“偏好设置… → 关于”点击检查更新时会被引导安装回英文原版。
- **红线**：
  - 更新 Feed 地址必须为本仓库：`https://raw.githubusercontent.com/cubelikeplayDaniel/RepoBar/main/appcast.xml`
  - Ed25519 公钥必须为：`SUPublicEDKey = f5fic5IojIONW243GshTw1leInxU0Pag0FLFuzrONSA=`
  - `Sources/RepoBar/Support/SparkleController.swift` 中的 `canUseSparkle` 判断必须允许包含 `SUPublicEDKey` 的普通打包 App 启用更新检查，不强制要求 Apple Developer ID。
- **保护文件**：`Sources/RepoBar/Support/SparkleController.swift`、`Scripts/package_release_assets.sh`、`appcast.xml`。

### 3. 三语言字典 100% 键名对齐与 SwiftPM 本地化规范
- **背景**：上游作者明确拒绝了多语言支持，因此**上游所有新增功能 100% 会包含硬编码英文**。
- **红线**：
  - `Sources/RepoBar/Resources/Localizations/` 下的 `en.lproj`、`tr.lproj`、`zh-Hans.lproj` 三份 `Localizable.strings` **键名必须 1:1 完全对齐**。
  - AppKit 控件（如 `NSPopUpButton`、`NSMenuItem`、`NSSegmentedControl`）和模块内部无法自动寻址 `LocalizedStringKey`，必须使用 `AppLocalizer().string(...)` 提取并显示。
  - 严禁跳过 `./Scripts/test.sh`；测试用例包含本地化完整性校验（`RepoBarLocalizationTests`），若有缺失键测试会直接失败。

---

## 🔄 上游同步与增量汉化标准 SOP（轻量模型操作指南）

当定时任务或后台唤醒通知有上游新提交时，严格按以下步骤执行：

### 第一步：获取上游最新提交并对比
```bash
git fetch upstream main --tags
git rev-list HEAD..upstream/main --count
```
- 若计数为 0：直接说明“上游暂无新提交”，结束流程。
- 若计数大于 0：进入第二步。

### 第二步：合并分支并检查冲突
```bash
git checkout feat/chinese-localization
git merge upstream/main
```
- 若发生冲突：重点保护上述三大红线配置（`package_app.sh`、`SparkleController.swift`、`package_release_assets.sh`），其余业务逻辑以合并上游修复为主。

### 第三步：排查并提取新增 UI 硬编码字符串
检查上游在 `Sources/` 中新增的 Swift 代码：
```bash
git diff HEAD~1 Sources/
```
- 若发现新增了界面可见的硬编码英文字符串（例如 `Text("...")`、`NSMenuItem(title: "...")`、错误提示、按钮文案）：
  1. 使用 `AppLocalizer().string("键名", ...)` 替换硬编码。
  2. 将新键分别添加到 `en.lproj`、`tr.lproj` 以及 `zh-Hans.lproj`，并填入优雅准确的简体中文翻译。
  3. 涉及相对时间展示的，必须统一使用 `RelativeFormatter.string(from:relativeTo:)`。

### 第四步：执行自动化测试门禁
```bash
./Scripts/test.sh
```
- **门禁要求**：必须输出 `Test Suite 'All tests' passed` 且 0 失败。若有词条缺失，根据报错补齐后重新运行。

### 第五步：推送与多架构分发派发
```bash
git push origin feat/chinese-localization
git checkout main
git merge feat/chinese-localization
git push origin main
git checkout feat/chinese-localization
```
- **版本号变更处理**：如果上游在 `version.env` 中更新了版本号或发布了新 release tag（例如上游发布 `v0.11.0`）：
  1. 创建对应中文 Tag：`git tag v<MARKETING_VERSION>-zh-Hans`。
  2. 推送 Tag 触发 GitHub Actions 全架构打包流水线：`git push origin --tags`。
  3. 在本机编译并覆盖本地应用：
     ```bash
     ./Scripts/package_app.sh release
     pkill RepoBar || true
     cp -R .build/apple/Products/Release/RepoBar.app /Applications/
     open /Applications/RepoBar.app
     ```

---

## 🛠️ 常用开发与构建命令速查

| 操作目的 | 终端命令 | 说明 |
| :--- | :--- | :--- |
| **完整测试** | `./Scripts/test.sh` | 编译并运行所有单元测试与词条完整性校验 |
| **编译调试版** | `./Scripts/package_app.sh debug` | 快速单架构编译 `.build/debug/RepoBar.app` |
| **编译 Release 版** | `./Scripts/package_app.sh release` | 编译双架构 `.build/apple/Products/Release/RepoBar.app` |
| **全架构本地分发打包** | `./Scripts/package_release_assets.sh` | 产出 ARM64 / x86_64 / Universal DMG、ZIP、CLI 及 appcast.xml 至 `dist/` |
