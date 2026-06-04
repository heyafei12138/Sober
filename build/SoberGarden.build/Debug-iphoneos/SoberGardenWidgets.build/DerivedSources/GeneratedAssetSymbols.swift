import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

    /// The "WidgetBackground" asset catalog color resource.
    static let widgetBackground = DeveloperToolsSupport.ColorResource(name: "WidgetBackground", bundle: resourceBundle)

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "guider_icon_flower" asset catalog image resource.
    static let guiderIconFlower = DeveloperToolsSupport.ImageResource(name: "guider_icon_flower", bundle: resourceBundle)

    /// The "guider_icon_flower1" asset catalog image resource.
    static let guiderIconFlower1 = DeveloperToolsSupport.ImageResource(name: "guider_icon_flower1", bundle: resourceBundle)

    /// The "guider_icon_flowerpot" asset catalog image resource.
    static let guiderIconFlowerpot = DeveloperToolsSupport.ImageResource(name: "guider_icon_flowerpot", bundle: resourceBundle)

    /// The "guider_icon_grass" asset catalog image resource.
    static let guiderIconGrass = DeveloperToolsSupport.ImageResource(name: "guider_icon_grass", bundle: resourceBundle)

    /// The "guider_icon_kittle" asset catalog image resource.
    static let guiderIconKittle = DeveloperToolsSupport.ImageResource(name: "guider_icon_kittle", bundle: resourceBundle)

    /// The "guider_icon_singleFlower" asset catalog image resource.
    static let guiderIconSingleFlower = DeveloperToolsSupport.ImageResource(name: "guider_icon_singleFlower", bundle: resourceBundle)

    /// The "guider_icon_tree" asset catalog image resource.
    static let guiderIconTree = DeveloperToolsSupport.ImageResource(name: "guider_icon_tree", bundle: resourceBundle)

    /// The "guider_icon_tree1" asset catalog image resource.
    static let guiderIconTree1 = DeveloperToolsSupport.ImageResource(name: "guider_icon_tree1", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// The "WidgetBackground" asset catalog color.
    static var widgetBackground: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .widgetBackground)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// The "WidgetBackground" asset catalog color.
    static var widgetBackground: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .widgetBackground)
#else
        .init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    /// The "WidgetBackground" asset catalog color.
    static var widgetBackground: SwiftUI.Color { .init(.widgetBackground) }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    /// The "WidgetBackground" asset catalog color.
    static var widgetBackground: SwiftUI.Color { .init(.widgetBackground) }

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "guider_icon_flower" asset catalog image.
    static var guiderIconFlower: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .guiderIconFlower)
#else
        .init()
#endif
    }

    /// The "guider_icon_flower1" asset catalog image.
    static var guiderIconFlower1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .guiderIconFlower1)
#else
        .init()
#endif
    }

    /// The "guider_icon_flowerpot" asset catalog image.
    static var guiderIconFlowerpot: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .guiderIconFlowerpot)
#else
        .init()
#endif
    }

    /// The "guider_icon_grass" asset catalog image.
    static var guiderIconGrass: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .guiderIconGrass)
#else
        .init()
#endif
    }

    /// The "guider_icon_kittle" asset catalog image.
    static var guiderIconKittle: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .guiderIconKittle)
#else
        .init()
#endif
    }

    /// The "guider_icon_singleFlower" asset catalog image.
    static var guiderIconSingleFlower: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .guiderIconSingleFlower)
#else
        .init()
#endif
    }

    /// The "guider_icon_tree" asset catalog image.
    static var guiderIconTree: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .guiderIconTree)
#else
        .init()
#endif
    }

    /// The "guider_icon_tree1" asset catalog image.
    static var guiderIconTree1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .guiderIconTree1)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "guider_icon_flower" asset catalog image.
    static var guiderIconFlower: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .guiderIconFlower)
#else
        .init()
#endif
    }

    /// The "guider_icon_flower1" asset catalog image.
    static var guiderIconFlower1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .guiderIconFlower1)
#else
        .init()
#endif
    }

    /// The "guider_icon_flowerpot" asset catalog image.
    static var guiderIconFlowerpot: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .guiderIconFlowerpot)
#else
        .init()
#endif
    }

    /// The "guider_icon_grass" asset catalog image.
    static var guiderIconGrass: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .guiderIconGrass)
#else
        .init()
#endif
    }

    /// The "guider_icon_kittle" asset catalog image.
    static var guiderIconKittle: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .guiderIconKittle)
#else
        .init()
#endif
    }

    /// The "guider_icon_singleFlower" asset catalog image.
    static var guiderIconSingleFlower: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .guiderIconSingleFlower)
#else
        .init()
#endif
    }

    /// The "guider_icon_tree" asset catalog image.
    static var guiderIconTree: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .guiderIconTree)
#else
        .init()
#endif
    }

    /// The "guider_icon_tree1" asset catalog image.
    static var guiderIconTree1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .guiderIconTree1)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

