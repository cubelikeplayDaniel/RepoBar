import Foundation

public enum RelativeFormatter {
    public static func string(from date: Date, relativeTo now: Date, preferredLanguages: [String] = Locale.preferredLanguages) -> String {
        let language = Bundle.preferredLocalizations(from: ["en", "tr", "zh-Hans"], forPreferences: preferredLanguages).first ?? "en"
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: language)
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: now)
    }
}
