#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"com.Sober.SoberGarden.SoberGardenWidgets";

/// The "WidgetBackground" asset catalog color resource.
static NSString * const ACColorNameWidgetBackground AC_SWIFT_PRIVATE = @"WidgetBackground";

/// The "guider_icon_flower" asset catalog image resource.
static NSString * const ACImageNameGuiderIconFlower AC_SWIFT_PRIVATE = @"guider_icon_flower";

/// The "guider_icon_flower1" asset catalog image resource.
static NSString * const ACImageNameGuiderIconFlower1 AC_SWIFT_PRIVATE = @"guider_icon_flower1";

/// The "guider_icon_flowerpot" asset catalog image resource.
static NSString * const ACImageNameGuiderIconFlowerpot AC_SWIFT_PRIVATE = @"guider_icon_flowerpot";

/// The "guider_icon_grass" asset catalog image resource.
static NSString * const ACImageNameGuiderIconGrass AC_SWIFT_PRIVATE = @"guider_icon_grass";

/// The "guider_icon_kittle" asset catalog image resource.
static NSString * const ACImageNameGuiderIconKittle AC_SWIFT_PRIVATE = @"guider_icon_kittle";

/// The "guider_icon_singleFlower" asset catalog image resource.
static NSString * const ACImageNameGuiderIconSingleFlower AC_SWIFT_PRIVATE = @"guider_icon_singleFlower";

/// The "guider_icon_tree" asset catalog image resource.
static NSString * const ACImageNameGuiderIconTree AC_SWIFT_PRIVATE = @"guider_icon_tree";

/// The "guider_icon_tree1" asset catalog image resource.
static NSString * const ACImageNameGuiderIconTree1 AC_SWIFT_PRIVATE = @"guider_icon_tree1";

#undef AC_SWIFT_PRIVATE
