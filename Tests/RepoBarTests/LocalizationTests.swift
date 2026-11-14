import Foundation
@testable import RepoBar
import RepoBarCore
import Testing

@Suite("Localization")
struct LocalizationTests {
    @Test(arguments: ["tr", "tr-TR", "tr_TR"])
    func `turkish language preferences`(language: String) {
        let localizer = AppLocalizer(preferredLanguages: [language])
        #expect(localizer.string("Preferences…") == "Ayarlar…")
        #expect(localizer.string("Notifications") == "Bildirimler")
        #expect(localizer.string("Search repositories") == "Depolarda ara")
        #expect(localizer.string("Pinned") == "Sabitlenmiş")
    }

    @Test(arguments: ["zh-Hans", "zh-CN", "zh_CN", "zh-Hans-CN"])
    func `simplified chinese language preferences`(language: String) {
        let localizer = AppLocalizer(preferredLanguages: [language])
        #expect(localizer.string("Preferences…") == "偏好设置…")
        #expect(localizer.string("Notifications") == "通知")
        #expect(localizer.string("Search repositories") == "搜索仓库")
        #expect(localizer.string("Pinned") == "已固定")
    }

    @Test func `credential attention strings are localized`() {
        let turkish = AppLocalizer(preferredLanguages: ["tr"])
        #expect(turkish.string("Relaunch RepoBar") == "RepoBar’ı Yeniden Başlat")
        #expect(turkish.string("Can’t read your saved GitHub credentials") == "Kayıtlı GitHub kimlik bilgileriniz okunamıyor")
        #expect(String(format: turkish.string("Relaunch to finish updating to %@."), "1.2")
            == "1.2 sürümüne güncellemeyi tamamlamak için yeniden başlatın.")

        let chinese = AppLocalizer(preferredLanguages: ["zh-Hans"])
        #expect(chinese.string("Relaunch RepoBar") == "重新启动 RepoBar")
        #expect(chinese.string("Can’t read your saved GitHub credentials") == "无法读取已保存的 GitHub 凭据")
        #expect(String(format: chinese.string("Relaunch to finish updating to %@."), "1.2")
            == "重新启动以完成更新至 1.2。")
    }

    @Test func `issue navigator and secondary views are localized`() {
        let chinese = AppLocalizer(preferredLanguages: ["zh-Hans"])
        #expect(chinese.string("Search issues and pull requests") == "搜索 Issue 与拉取请求")
        #expect(chinese.string("Pick a result") == "选择一个结果")
        #expect(chinese.string("Updated newest first") == "按最新更新排序")
        #expect(chinese.string("No matches") == "无匹配结果")
        #expect(chinese.string("Open in Browser") == "在浏览器中打开")
        #expect(chinese.string("Copy URL") == "复制 URL")
        #expect(chinese.string("Back") == "返回")
        #expect(chinese.string("Draft") == "草稿")
        #expect(chinese.string("Pre") == "预发布")
        #expect(chinese.string("Concurrent Jobs") == "并发作业")
        #expect(chinese.string("Runners") == "运行器 (Runners)")

        let turkish = AppLocalizer(preferredLanguages: ["tr"])
        #expect(turkish.string("Search issues and pull requests") == "Sorunları ve çekme isteklerini ara")
        #expect(turkish.string("Pick a result") == "Bir sonuç seçin")
        #expect(turkish.string("Updated newest first") == "En yeniye göre güncellendi")
        #expect(turkish.string("No matches") == "Eşleşme yok")
        #expect(turkish.string("Open in Browser") == "Tarayıcıda Aç")
    }

    @Test func `relative formatter is localized`() {
        let now = Date()
        let pastMinute = now.addingTimeInterval(-180)
        let formattedChinese = RelativeFormatter.string(from: pastMinute, relativeTo: now, preferredLanguages: ["zh-Hans"])
        #expect(formattedChinese == "3分钟前")

        let formattedTurkish = RelativeFormatter.string(from: pastMinute, relativeTo: now, preferredLanguages: ["tr"])
        #expect(formattedTurkish == "3 dk. önce")
    }

    @Test func `language priority and fallback`() {
        #expect(AppLocalizer(preferredLanguages: ["en-US", "tr"]).string("General") == "General")
        #expect(AppLocalizer(preferredLanguages: ["zh-Hans", "en"]).string("General") == "通用")
        #expect(AppLocalizer(preferredLanguages: ["fr", "tr"]).string("General") == "Genel")
        #expect(AppLocalizer(preferredLanguages: ["ja-JP"]).string("General") == "General")
        #expect(AppLocalizer(preferredLanguages: []).string("General") == "General")
    }

    @Test func `unknown text is literal`() {
        let localizer = AppLocalizer(preferredLanguages: ["tr"])
        #expect(localizer.string("Invalid backup 100% %@") == "Invalid backup 100% %@")
        #expect(localizer.string("example-org/demo#42") == "example-org/demo#42")
        let chineseLocalizer = AppLocalizer(preferredLanguages: ["zh-Hans"])
        #expect(chineseLocalizer.string("feature/branch-name") == "feature/branch-name")
        #expect(chineseLocalizer.string("worktree-name") == "worktree-name")
    }

    @Test func `catalogs have matching keys and translate display settings`() throws {
        let resources = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().appending(path: "Sources/RepoBar/Resources/Localizations")
        func catalog(_ language: String) throws -> [String: String] {
            let data = try Data(contentsOf: resources.appending(path: "\(language).lproj/Localizable.strings"))
            return try #require(PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String])
        }
        let english = try catalog("en")
        let turkish = try catalog("tr")
        let chinese = try catalog("zh-Hans")
        #expect(Set(english.keys) == Set(turkish.keys))
        #expect(Set(english.keys) == Set(chinese.keys))
        let titles = MainMenuItemID.allCases.map(\.title) + RepoSubmenuItemID.allCases.map(\.title)
        let subtitles = MainMenuItemID.allCases.compactMap(\.subtitle) + RepoSubmenuItemID.allCases.compactMap(\.subtitle)
        for key in titles + subtitles {
            #expect(english[key] == key)
            #expect(turkish[key] != nil)
            #expect(turkish[key] != key)
            #expect(chinese[key] != nil)
            #expect(chinese[key] != key)
        }
    }
}
