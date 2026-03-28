//
//  XcodeProjectPattern.swift
//  Industrial Builder
//
//  Created by Artem on 27.03.2026.
//

import Foundation

public func xcode_project_pattern(
    name: String,
    modules_func: @escaping (URL) -> Void
) -> FilePattern
{
    .init(
        name: name,
        children: [
            .init(
                name: name,
                children: [
                    .init(name: "Assets.xcassets"),
                    ContentView_file_pattern,
                    App_file_pattern(name: name),
                    .init(writing_func: modules_func)
                ]
            ),
            .init(
                name: "\(name).xcodeproj",
                children: [
                    project_file_pattern(name: name)//,
                    //.init(name: "Project.xcworkspace"),
                ]
            )
        ]
    )
}

private var ContentView_file_pattern: FilePattern = .init(
    name: "ContentView.swift",
    data:
"""
import SwiftUI
import RealityKit

import IndustrialKit
import IndustrialKitUI

struct ContentView: View
{
    var body: some View
    {
        VStack(spacing: 16)
        {
            Image(systemName: "gear")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Industrial App")
        }
    }
}
"""
)

public func App_file_pattern(name: String) -> FilePattern
{
    let name_coded = name.code_correct_format
    
    return .init(
        name: "\(name_coded)App.swift",
        data:
"""
//
//  \(name_coded)App.swift
//  \(name)
//

import SwiftUI

@main
struct \(name_coded)App: App
{
    var body: some Scene
    {
        WindowGroup
        {
            ContentView()
        }
    }
}
"""
    )
}

private func project_file_pattern(name: String) -> FilePattern
{
    .init(
        name: "project.pbxproj",
        data:
"""
// !$*UTF8*$!
{
    archiveVersion = 1;
    classes = {
    };
    objectVersion = 77;
    objects = {

/* Begin PBXBuildFile section */
        62FE5A1A2F76B5D5003BF06E /* IndustrialKit in Frameworks */ = {isa = PBXBuildFile; productRef = 62FE5A192F76B5D5003BF06E /* IndustrialKit */; };
        62FE5A1C2F76B5D5003BF06E /* IndustrialKitUI in Frameworks */ = {isa = PBXBuildFile; productRef = 62FE5A1B2F76B5D5003BF06E /* IndustrialKitUI */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
        62FE5A042F76B3CD003BF06E /* \(name).app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = "\(name).app"; sourceTree = BUILT_PRODUCTS_DIR; };
/* End PBXFileReference section */

/* Begin PBXFileSystemSynchronizedRootGroup section */
        62FE5A062F76B3CD003BF06E /* \(name) */ = {
            isa = PBXFileSystemSynchronizedRootGroup;
            path = "\(name)";
            sourceTree = "<group>";
        };
/* End PBXFileSystemSynchronizedRootGroup section */

/* Begin PBXFrameworksBuildPhase section */
        62FE5A012F76B3CD003BF06E /* Frameworks */ = {
            isa = PBXFrameworksBuildPhase;
            buildActionMask = 2147483647;
            files = (
                62FE5A1C2F76B5D5003BF06E /* IndustrialKitUI in Frameworks */,
                62FE5A1A2F76B5D5003BF06E /* IndustrialKit in Frameworks */,
            );
            runOnlyForDeploymentPostprocessing = 0;
        };
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
        62FE59FB2F76B3CD003BF06E = {
            isa = PBXGroup;
            children = (
                62FE5A062F76B3CD003BF06E /* \(name) */,
                62FE5A052F76B3CD003BF06E /* Products */,
            );
            sourceTree = "<group>";
        };
        62FE5A052F76B3CD003BF06E /* Products */ = {
            isa = PBXGroup;
            children = (
                62FE5A042F76B3CD003BF06E /* \(name).app */,
            );
            name = Products;
            sourceTree = "<group>";
        };
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
        62FE5A032F76B3CD003BF06E /* \(name) */ = {
            isa = PBXNativeTarget;
            buildConfigurationList = 62FE5A0F2F76B3CF003BF06E /* Build configuration list for PBXNativeTarget "\(name)" */;
            buildPhases = (
                62FE5A002F76B3CD003BF06E /* Sources */,
                62FE5A012F76B3CD003BF06E /* Frameworks */,
                62FE5A022F76B3CD003BF06E /* Resources */,
            );
            buildRules = (
            );
            dependencies = (
            );
            fileSystemSynchronizedGroups = (
                62FE5A062F76B3CD003BF06E /* \(name) */,
            );
            name = "\(name)";
            packageProductDependencies = (
                62FE5A192F76B5D5003BF06E /* IndustrialKit */,
                62FE5A1B2F76B5D5003BF06E /* IndustrialKitUI */,
            );
            productName = "\(name)";
            productReference = 62FE5A042F76B3CD003BF06E /* \(name).app */;
            productType = "com.apple.product-type.application";
        };
/* End PBXNativeTarget section */

/* Begin PBXProject section */
        62FE59FC2F76B3CD003BF06E /* Project object */ = {
            isa = PBXProject;
            attributes = {
                BuildIndependentTargetsInParallel = 1;
                LastSwiftUpdateCheck = 2640;
                LastUpgradeCheck = 2640;
                TargetAttributes = {
                    62FE5A032F76B3CD003BF06E = {
                        CreatedOnToolsVersion = 26.4;
                    };
                };
            };
            buildConfigurationList = 62FE59FF2F76B3CD003BF06E /* Build configuration list for PBXProject "\(name)" */;
            developmentRegion = en;
            hasScannedForEncodings = 0;
            knownRegions = (
                en,
                Base,
            );
            mainGroup = 62FE59FB2F76B3CD003BF06E;
            minimizedProjectReferenceProxies = 1;
            packageReferences = (
                62FE5A182F76B5D5003BF06E /* XCRemoteSwiftPackageReference "IndustrialKit" */,
            );
            preferredProjectObjectVersion = 77;
            productRefGroup = 62FE5A052F76B3CD003BF06E /* Products */;
            projectDirPath = "";
            projectRoot = "";
            targets = (
                62FE5A032F76B3CD003BF06E /* \(name) */,
            );
        };
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
        62FE5A022F76B3CD003BF06E /* Resources */ = {
            isa = PBXResourcesBuildPhase;
            buildActionMask = 2147483647;
            files = (
            );
            runOnlyForDeploymentPostprocessing = 0;
        };
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
        62FE5A002F76B3CD003BF06E /* Sources */ = {
            isa = PBXSourcesBuildPhase;
            buildActionMask = 2147483647;
            files = (
            );
            runOnlyForDeploymentPostprocessing = 0;
        };
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
        62FE5A0D2F76B3CF003BF06E /* Debug */ = {
            isa = XCBuildConfiguration;
            buildSettings = {
                ALWAYS_SEARCH_USER_PATHS = NO;
                ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
                CLANG_ANALYZER_NONNULL = YES;
                CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
                CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
                CLANG_ENABLE_MODULES = YES;
                CLANG_ENABLE_OBJC_ARC = YES;
                CLANG_ENABLE_OBJC_WEAK = YES;
                CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
                CLANG_WARN_BOOL_CONVERSION = YES;
                CLANG_WARN_COMMA = YES;
                CLANG_WARN_CONSTANT_CONVERSION = YES;
                CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
                CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
                CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
                CLANG_WARN_EMPTY_BODY = YES;
                CLANG_WARN_ENUM_CONVERSION = YES;
                CLANG_WARN_INFINITE_RECURSION = YES;
                CLANG_WARN_INT_CONVERSION = YES;
                CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
                CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
                CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
                CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
                CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
                CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
                CLANG_WARN_STRICT_PROTOTYPES = YES;
                CLANG_WARN_SUSPICIOUS_MOVE = YES;
                CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
                CLANG_WARN_UNREACHABLE_CODE = YES;
                CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
                COPY_PHASE_STRIP = NO;
                DEBUG_INFORMATION_FORMAT = dwarf;
                ENABLE_STRICT_OBJC_MSGSEND = YES;
                ENABLE_TESTABILITY = YES;
                ENABLE_USER_SCRIPT_SANDBOXING = YES;
                GCC_C_LANGUAGE_STANDARD = gnu17;
                GCC_DYNAMIC_NO_PIC = NO;
                GCC_NO_COMMON_BLOCKS = YES;
                GCC_OPTIMIZATION_LEVEL = 0;
                GCC_PREPROCESSOR_DEFINITIONS = (
                    "DEBUG=1",
                    "$(inherited)",
                );
                GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
                GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
                GCC_WARN_UNDECLARED_SELECTOR = YES;
                GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
                GCC_WARN_UNUSED_FUNCTION = YES;
                GCC_WARN_UNUSED_VARIABLE = YES;
                LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
                MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
                MTL_FAST_MATH = YES;
                ONLY_ACTIVE_ARCH = YES;
                SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
                SWIFT_OPTIMIZATION_LEVEL = "-Onone";
            };
            name = Debug;
        };
        62FE5A0E2F76B3CF003BF06E /* Release */ = {
            isa = XCBuildConfiguration;
            buildSettings = {
                ALWAYS_SEARCH_USER_PATHS = NO;
                ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
                CLANG_ANALYZER_NONNULL = YES;
                CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
                CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
                CLANG_ENABLE_MODULES = YES;
                CLANG_ENABLE_OBJC_ARC = YES;
                CLANG_ENABLE_OBJC_WEAK = YES;
                CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
                CLANG_WARN_BOOL_CONVERSION = YES;
                CLANG_WARN_COMMA = YES;
                CLANG_WARN_CONSTANT_CONVERSION = YES;
                CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
                CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
                CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
                CLANG_WARN_EMPTY_BODY = YES;
                CLANG_WARN_ENUM_CONVERSION = YES;
                CLANG_WARN_INFINITE_RECURSION = YES;
                CLANG_WARN_INT_CONVERSION = YES;
                CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
                CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
                CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
                CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
                CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
                CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
                CLANG_WARN_STRICT_PROTOTYPES = YES;
                CLANG_WARN_SUSPICIOUS_MOVE = YES;
                CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
                CLANG_WARN_UNREACHABLE_CODE = YES;
                CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
                COPY_PHASE_STRIP = NO;
                DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
                ENABLE_NS_ASSERTIONS = NO;
                ENABLE_STRICT_OBJC_MSGSEND = YES;
                ENABLE_USER_SCRIPT_SANDBOXING = YES;
                GCC_C_LANGUAGE_STANDARD = gnu17;
                GCC_NO_COMMON_BLOCKS = YES;
                GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
                GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
                GCC_WARN_UNDECLARED_SELECTOR = YES;
                GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
                GCC_WARN_UNUSED_FUNCTION = YES;
                GCC_WARN_UNUSED_VARIABLE = YES;
                LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
                MTL_ENABLE_DEBUG_INFO = NO;
                MTL_FAST_MATH = YES;
                SWIFT_COMPILATION_MODE = wholemodule;
            };
            name = Release;
        };
        62FE5A102F76B3CF003BF06E /* Debug */ = {
            isa = XCBuildConfiguration;
            buildSettings = {
                ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
                ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
                CODE_SIGN_STYLE = Automatic;
                CURRENT_PROJECT_VERSION = 1;
                ENABLE_APP_SANDBOX = NO;
                ENABLE_PREVIEWS = YES;
                GENERATE_INFOPLIST_FILE = YES;
                "INFOPLIST_KEY_UIApplicationSceneManifest_Generation[sdk=iphoneos*]" = YES;
                "INFOPLIST_KEY_UIApplicationSceneManifest_Generation[sdk=iphonesimulator*]" = YES;
                "INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents[sdk=iphoneos*]" = YES;
                "INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents[sdk=iphonesimulator*]" = YES;
                "INFOPLIST_KEY_UILaunchScreen_Generation[sdk=iphoneos*]" = YES;
                "INFOPLIST_KEY_UILaunchScreen_Generation[sdk=iphonesimulator*]" = YES;
                "INFOPLIST_KEY_UIStatusBarStyle[sdk=iphoneos*]" = UIStatusBarStyleDefault;
                "INFOPLIST_KEY_UIStatusBarStyle[sdk=iphonesimulator*]" = UIStatusBarStyleDefault;
                INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
                INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
                IPHONEOS_DEPLOYMENT_TARGET = 26.0;
                LD_RUNPATH_SEARCH_PATHS = "@executable_path/Frameworks";
                "LD_RUNPATH_SEARCH_PATHS[sdk=macosx*]" = "@executable_path/../Frameworks";
                MACOSX_DEPLOYMENT_TARGET = 26.0;
                MARKETING_VERSION = 1.0;
                PRODUCT_BUNDLE_IDENTIFIER = "org.celadon.Industrial-App";
                PRODUCT_NAME = "$(TARGET_NAME)";
                REGISTER_APP_GROUPS = YES;
                SDKROOT = auto;
                STRING_CATALOG_GENERATE_SYMBOLS = YES;
                SUPPORTED_PLATFORMS = "iphoneos iphonesimulator macosx xros xrsimulator";
                SWIFT_APPROACHABLE_CONCURRENCY = YES;
                SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor;
                SWIFT_EMIT_LOC_STRINGS = YES;
                SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY = YES;
                SWIFT_VERSION = 5.0;
                TARGETED_DEVICE_FAMILY = "1,2,7";
                XROS_DEPLOYMENT_TARGET = 26.0;
            };
            name = Debug;
        };
        62FE5A112F76B3CF003BF06E /* Release */ = {
            isa = XCBuildConfiguration;
            buildSettings = {
                ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
                ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
                CODE_SIGN_STYLE = Automatic;
                CURRENT_PROJECT_VERSION = 1;
                ENABLE_APP_SANDBOX = NO;
                ENABLE_PREVIEWS = YES;
                GENERATE_INFOPLIST_FILE = YES;
                "INFOPLIST_KEY_UIApplicationSceneManifest_Generation[sdk=iphoneos*]" = YES;
                "INFOPLIST_KEY_UIApplicationSceneManifest_Generation[sdk=iphonesimulator*]" = YES;
                "INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents[sdk=iphoneos*]" = YES;
                "INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents[sdk=iphonesimulator*]" = YES;
                "INFOPLIST_KEY_UILaunchScreen_Generation[sdk=iphoneos*]" = YES;
                "INFOPLIST_KEY_UILaunchScreen_Generation[sdk=iphonesimulator*]" = YES;
                "INFOPLIST_KEY_UIStatusBarStyle[sdk=iphoneos*]" = UIStatusBarStyleDefault;
                "INFOPLIST_KEY_UIStatusBarStyle[sdk=iphonesimulator*]" = UIStatusBarStyleDefault;
                INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
                INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
                IPHONEOS_DEPLOYMENT_TARGET = 26.0;
                LD_RUNPATH_SEARCH_PATHS = "@executable_path/Frameworks";
                "LD_RUNPATH_SEARCH_PATHS[sdk=macosx*]" = "@executable_path/../Frameworks";
                MACOSX_DEPLOYMENT_TARGET = 26.0;
                MARKETING_VERSION = 1.0;
                PRODUCT_BUNDLE_IDENTIFIER = "org.celadon.Industrial-App";
                PRODUCT_NAME = "$(TARGET_NAME)";
                REGISTER_APP_GROUPS = YES;
                SDKROOT = auto;
                STRING_CATALOG_GENERATE_SYMBOLS = YES;
                SUPPORTED_PLATFORMS = "iphoneos iphonesimulator macosx xros xrsimulator";
                SWIFT_APPROACHABLE_CONCURRENCY = YES;
                SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor;
                SWIFT_EMIT_LOC_STRINGS = YES;
                SWIFT_OPTIMIZATION_LEVEL = "-Onone";
                SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY = YES;
                SWIFT_VERSION = 5.0;
                TARGETED_DEVICE_FAMILY = "1,2,7";
                XROS_DEPLOYMENT_TARGET = 26.0;
            };
            name = Release;
        };
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
        62FE59FF2F76B3CD003BF06E /* Build configuration list for PBXProject "\(name)" */ = {
            isa = XCConfigurationList;
            buildConfigurations = (
                62FE5A0D2F76B3CF003BF06E /* Debug */,
                62FE5A0E2F76B3CF003BF06E /* Release */,
            );
            defaultConfigurationIsVisible = 0;
            defaultConfigurationName = Release;
        };
        62FE5A0F2F76B3CF003BF06E /* Build configuration list for PBXNativeTarget "\(name)" */ = {
            isa = XCConfigurationList;
            buildConfigurations = (
                62FE5A102F76B3CF003BF06E /* Debug */,
                62FE5A112F76B3CF003BF06E /* Release */,
            );
            defaultConfigurationIsVisible = 0;
            defaultConfigurationName = Release;
        };
/* End XCConfigurationList section */

/* Begin XCRemoteSwiftPackageReference section */
        62FE5A182F76B5D5003BF06E /* XCRemoteSwiftPackageReference "IndustrialKit" */ = {
            isa = XCRemoteSwiftPackageReference;
            repositoryURL = "https://github.com/MalkarovPark/IndustrialKit";
            requirement = {
                kind = upToNextMajorVersion;
                minimumVersion = 5.1.0;
            };
        };
/* End XCRemoteSwiftPackageReference section */

/* Begin XCSwiftPackageProductDependency section */
        62FE5A192F76B5D5003BF06E /* IndustrialKit */ = {
            isa = XCSwiftPackageProductDependency;
            package = 62FE5A182F76B5D5003BF06E /* XCRemoteSwiftPackageReference "IndustrialKit" */;
            productName = IndustrialKit;
        };
        62FE5A1B2F76B5D5003BF06E /* IndustrialKitUI */ = {
            isa = XCSwiftPackageProductDependency;
            package = 62FE5A182F76B5D5003BF06E /* XCRemoteSwiftPackageReference "IndustrialKit" */;
            productName = IndustrialKitUI;
        };
/* End XCSwiftPackageProductDependency section */
    };
    rootObject = 62FE59FC2F76B3CD003BF06E /* Project object */;
}
"""
    )
}
