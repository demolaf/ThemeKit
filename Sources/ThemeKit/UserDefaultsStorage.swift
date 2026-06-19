import Foundation

struct UserDefaultsStorage: ThemeStorage {
  private let defaults: UserDefaults

  init(_ defaults: UserDefaults) {
    self.defaults = defaults
  }

  func data(forKey key: String) -> Data? {
    defaults.data(forKey: key)
  }

  func set(_ value: Any?, forKey key: String) {
    defaults.set(value, forKey: key)
    defaults.synchronize()
  }
}
