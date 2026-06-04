import Foundation

extension String {
    func localized() -> String {
        self
    }

    func localizedFormat(_ arguments: CVarArg...) -> String {
        String(format: self, arguments: arguments)
    }
}
