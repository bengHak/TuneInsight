import Foundation

public extension String {
    /// Returns the localized version of the string using the main app bundle.
    func localized(comment: String = "") -> String {
        Bundle.main.localizedString(forKey: self, value: nil, table: "Localizable")
    }
    
    /// Returns a localized string formatted with the provided arguments.
    func localizedFormat(_ arguments: CVarArg...) -> String {
        String(format: localized(), locale: Locale.current, arguments: arguments)
    }
}
