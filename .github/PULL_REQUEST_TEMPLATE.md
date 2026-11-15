### 变更概述
<!-- 简要说明本次 Pull Request 修改或新增的内容 -->

### 关联 Issue
<!-- 例如: Fixes #123 -->

### 贡献检查清单 (遵循 CLAUDE.md 规范)
- [ ] 若新增或修改了 UI 词条，已在 `en.lproj`、`tr.lproj` 和 `zh-Hans.lproj` 三处 1:1 键名同步更新
- [ ] 针对 AppKit / SwiftUI 视图使用了 `AppLocalizer().string(...)` 提取本地化字符串
- [ ] 本地运行 `./Scripts/test.sh` 单元测试与多语言门禁 100% 通过
- [ ] 未破坏 `RepoBarTokenStore = file`（钥匙串免弹窗）与个人 Sparkle 更新通道配置
