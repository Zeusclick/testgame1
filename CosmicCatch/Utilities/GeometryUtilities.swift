#if canImport(UIKit)
import UIKit
#endif
import SwiftUI

struct SafeAreaInsetsKey: PreferenceKey {
    static var defaultValue: EdgeInsets = .init()
    static func reduce(value: inout EdgeInsets, nextValue: () -> EdgeInsets) {
        let next = nextValue()
        value = EdgeInsets(
            top: max(value.top, next.top),
            leading: max(value.leading, next.leading),
            bottom: max(value.bottom, next.bottom),
            trailing: max(value.trailing, next.trailing)
        )
    }
}

struct SafeAreaReader: ViewModifier {
    var action: (EdgeInsets) -> Void
    func body(content: Content) -> some View {
        content
            .background(GeometryReader { proxy in
                Color.clear.preference(key: SafeAreaInsetsKey.self, value: proxy.safeAreaInsets)
            })
            .onPreferenceChange(SafeAreaInsetsKey.self, perform: action)
    }
}

extension View {
    func onSafeAreaChange(_ action: @escaping (EdgeInsets) -> Void) -> some View {
        modifier(SafeAreaReader(action: action))
    }
}

struct DeviceMetrics {
    static var isSmallDevice: Bool {
        #if os(iOS)
        guard let window = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first?.windows.first else { return false }
        return window.bounds.height < 700
        #else
        return false
        #endif
    }
}
