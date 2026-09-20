#!/usr/bin/env python3
from pathlib import Path
import uuid

ROOT = Path(__file__).resolve().parents[1] / "TakaraSagashi"
APP = ROOT / "TakaraSagashi"
TESTS = ROOT / "TakaraSagashiTests"
PROJ = ROOT / "TakaraSagashi.xcodeproj"
PROJ.mkdir(parents=True, exist_ok=True)


def uid() -> str:
    return uuid.uuid4().hex[:24].upper()


app_files = sorted(p.relative_to(APP) for p in APP.rglob("*.swift"))
test_files = sorted(p.relative_to(TESTS) for p in TESTS.rglob("*.swift")) if TESTS.exists() else []

ids = {name: uid() for name in [
    "project", "appTarget", "testTarget", "appProduct", "testProduct",
    "appSources", "testSources", "resources", "frameworks",
    "appGroup", "testGroup", "productsGroup", "mainGroup",
    "sourcesBuild", "resourcesBuild", "frameworksBuild",
    "testSourcesBuild",
    "projectConfigList", "appConfigList", "testConfigList",
    "projectDebug", "projectRelease", "appDebug", "appRelease", "testDebug", "testRelease",
    "assets", "assetsBuild",
]}
file_ids = {str(path): {"ref": uid(), "build": uid()} for path in app_files}
test_ids = {str(path): {"ref": uid(), "build": uid()} for path in test_files}

app_build_files = "\n".join(
    f'\t\t{file_ids[str(path)]["build"]} /* {path.name} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_ids[str(path)]["ref"]} /* {path.name} */; }};'
    for path in app_files
)
test_build_files = "\n".join(
    f'\t\t{test_ids[str(path)]["build"]} /* {path.name} in Sources */ = {{isa = PBXBuildFile; fileRef = {test_ids[str(path)]["ref"]} /* {path.name} */; }};'
    for path in test_files
)
assets_build = f'\t\t{ids["assetsBuild"]} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {ids["assets"]} /* Assets.xcassets */; }};'

app_file_refs = "\n".join(
    f'\t\t{file_ids[str(path)]["ref"]} /* {path.name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {path.name}; sourceTree = "<group>"; }};'
    if path.parent == Path('.') else
    f'\t\t{file_ids[str(path)]["ref"]} /* {path.name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; name = {path.name}; path = {path.as_posix()}; sourceTree = "<group>"; }};'
    for path in app_files
)
# Always use path relative to group. Simpler: put all files in a flat group with path to nested file.
app_file_refs = "\n".join(
    f'\t\t{file_ids[str(path)]["ref"]} /* {path.as_posix()} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {path.as_posix()}; sourceTree = "<group>"; }};'
    for path in app_files
)
test_file_refs = "\n".join(
    f'\t\t{test_ids[str(path)]["ref"]} /* {path.as_posix()} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {path.as_posix()}; sourceTree = "<group>"; }};'
    for path in test_files
)

app_group_children = "\n".join(f'\t\t\t\t{file_ids[str(path)]["ref"]} /* {path.as_posix()} */,' for path in app_files)
test_group_children = "\n".join(f'\t\t\t\t{test_ids[str(path)]["ref"]} /* {path.as_posix()} */,' for path in test_files)
app_sources_list = "\n".join(f'\t\t\t\t{file_ids[str(path)]["build"]} /* {path.name} in Sources */,' for path in app_files)
test_sources_list = "\n".join(f'\t\t\t\t{test_ids[str(path)]["build"]} /* {path.name} in Sources */,' for path in test_files)

pbx = f'''// !$*UTF8*$!
{{
	archiveVersion = 1;
	classes = {{
	}};
	objectVersion = 56;
	objects = {{
{app_build_files}
{test_build_files}
{assets_build}
		{ids["appProduct"]} /* TakaraSagashi.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = TakaraSagashi.app; sourceTree = BUILT_PRODUCTS_DIR; }};
		{ids["testProduct"]} /* TakaraSagashiTests.xctest */ = {{isa = PBXFileReference; explicitFileType = wrapper.cfbundle; includeInIndex = 0; path = TakaraSagashiTests.xctest; sourceTree = BUILT_PRODUCTS_DIR; }};
		{ids["assets"]} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; }};
{app_file_refs}
{test_file_refs}
		{ids["mainGroup"]} = {{
			isa = PBXGroup;
			children = (
				{ids["appGroup"]} /* TakaraSagashi */,
				{ids["testGroup"]} /* TakaraSagashiTests */,
				{ids["productsGroup"]} /* Products */,
			);
			sourceTree = "<group>";
		}};
		{ids["appGroup"]} /* TakaraSagashi */ = {{
			isa = PBXGroup;
			children = (
{app_group_children}
				{ids["assets"]} /* Assets.xcassets */,
			);
			path = TakaraSagashi;
			sourceTree = "<group>";
		}};
		{ids["testGroup"]} /* TakaraSagashiTests */ = {{
			isa = PBXGroup;
			children = (
{test_group_children}
			);
			path = TakaraSagashiTests;
			sourceTree = "<group>";
		}};
		{ids["productsGroup"]} /* Products */ = {{
			isa = PBXGroup;
			children = (
				{ids["appProduct"]} /* TakaraSagashi.app */,
				{ids["testProduct"]} /* TakaraSagashiTests.xctest */,
			);
			name = Products;
			sourceTree = "<group>";
		}};
		{ids["appSources"]} /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
{app_sources_list}
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
		{ids["testSources"]} /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
{test_sources_list}
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
		{ids["resources"]} /* Resources */ = {{
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				{ids["assetsBuild"]} /* Assets.xcassets in Resources */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
		{ids["frameworks"]} /* Frameworks */ = {{
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
		{ids["appTarget"]} /* TakaraSagashi */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {ids["appConfigList"]} /* Build configuration list for PBXNativeTarget "TakaraSagashi" */;
			buildPhases = (
				{ids["appSources"]} /* Sources */,
				{ids["frameworks"]} /* Frameworks */,
				{ids["resources"]} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = TakaraSagashi;
			productName = TakaraSagashi;
			productReference = {ids["appProduct"]} /* TakaraSagashi.app */;
			productType = "com.apple.product-type.application";
		}};
		{ids["testTarget"]} /* TakaraSagashiTests */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {ids["testConfigList"]} /* Build configuration list for PBXNativeTarget "TakaraSagashiTests" */;
			buildPhases = (
				{ids["testSources"]} /* Sources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = TakaraSagashiTests;
			productName = TakaraSagashiTests;
			productReference = {ids["testProduct"]} /* TakaraSagashiTests.xctest */;
			productType = "com.apple.product-type.bundle.unit-test";
		}};
		{ids["project"]} /* Project object */ = {{
			isa = PBXProject;
			attributes = {{
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 2600;
				LastUpgradeCheck = 2600;
				TargetAttributes = {{
					{ids["appTarget"]} = {{
						CreatedOnToolsVersion = 26.0;
					}};
					{ids["testTarget"]} = {{
						CreatedOnToolsVersion = 26.0;
						TestTargetID = {ids["appTarget"]};
					}};
				}};
			}};
			buildConfigurationList = {ids["projectConfigList"]} /* Build configuration list for PBXProject "TakaraSagashi" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = ja;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				ja,
				Base,
			);
			mainGroup = {ids["mainGroup"]};
			productRefGroup = {ids["productsGroup"]} /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				{ids["appTarget"]} /* TakaraSagashi */,
				{ids["testTarget"]} /* TakaraSagashiTests */,
			);
		}};
		{ids["projectDebug"]} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_TESTABILITY = YES;
				GCC_DYNAMIC_NO_PIC = NO;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
				SWIFT_VERSION = 5.0;
			}};
			name = Debug;
		}};
		{ids["projectRelease"]} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_VERSION = 5.0;
				VALIDATE_PRODUCT = YES;
			}};
			name = Release;
		}};
		{ids["appDebug"]} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_CFBundleDisplayName = "たからさがし";
				INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO;
				INFOPLIST_KEY_NSCameraUsageDescription = "かくしたQRコードを読みとって、つぎのヒントを見つけるためにカメラを使います。";
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UIRequiresFullScreen = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				LD_RUNPATH_SEARCH_PATHS = "$(inherited) @executable_path/Frameworks";
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.cluegame.takarasagashi;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SUPPORTS_MACCATALYST = NO;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Debug;
		}};
		{ids["appRelease"]} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = YES;
				INFOPLIST_KEY_CFBundleDisplayName = "たからさがし";
				INFOPLIST_KEY_ITSAppUsesNonExemptEncryption = NO;
				INFOPLIST_KEY_NSCameraUsageDescription = "かくしたQRコードを読みとって、つぎのヒントを見つけるためにカメラを使います。";
				INFOPLIST_KEY_UIApplicationSceneManifest_Generation = YES;
				INFOPLIST_KEY_UIApplicationSupportsIndirectInputEvents = YES;
				INFOPLIST_KEY_UILaunchScreen_Generation = YES;
				INFOPLIST_KEY_UIRequiresFullScreen = YES;
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPad = "UIInterfaceOrientationPortrait UIInterfaceOrientationPortraitUpsideDown UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone = "UIInterfaceOrientationPortrait UIInterfaceOrientationLandscapeLeft UIInterfaceOrientationLandscapeRight";
				LD_RUNPATH_SEARCH_PATHS = "$(inherited) @executable_path/Frameworks";
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.cluegame.takarasagashi;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SUPPORTED_PLATFORMS = "iphoneos iphonesimulator";
				SUPPORTS_MACCATALYST = NO;
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Release;
		}};
		{ids["testDebug"]} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				BUNDLE_LOADER = "$(TEST_HOST)";
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.cluegame.takarasagashi.tests;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
				TEST_HOST = "$(BUILT_PRODUCTS_DIR)/TakaraSagashi.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/TakaraSagashi";
			}};
			name = Debug;
		}};
		{ids["testRelease"]} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				BUNDLE_LOADER = "$(TEST_HOST)";
				CODE_SIGN_STYLE = Automatic;
				CURRENT_PROJECT_VERSION = 1;
				GENERATE_INFOPLIST_FILE = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.cluegame.takarasagashi.tests;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
				TEST_HOST = "$(BUILT_PRODUCTS_DIR)/TakaraSagashi.app/$(BUNDLE_EXECUTABLE_FOLDER_PATH)/TakaraSagashi";
			}};
			name = Release;
		}};
		{ids["projectConfigList"]} /* Build configuration list for PBXProject "TakaraSagashi" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{ids["projectDebug"]} /* Debug */,
				{ids["projectRelease"]} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
		{ids["appConfigList"]} /* Build configuration list for PBXNativeTarget "TakaraSagashi" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{ids["appDebug"]} /* Debug */,
				{ids["appRelease"]} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
		{ids["testConfigList"]} /* Build configuration list for PBXNativeTarget "TakaraSagashiTests" */ = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{ids["testDebug"]} /* Debug */,
				{ids["testRelease"]} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
	}};
	rootObject = {ids["project"]} /* Project object */;
}}
'''

(PROJ / "project.pbxproj").write_text(pbx)
scheme_dir = PROJ / "xcshareddata" / "xcschemes"
scheme_dir.mkdir(parents=True, exist_ok=True)
(scheme_dir / "TakaraSagashi.xcscheme").write_text(f'''<?xml version="1.0" encoding="UTF-8"?>
<Scheme LastUpgradeVersion="2600" version="1.7">
   <BuildAction parallelizeBuildables="YES" buildImplicitDependencies="YES">
      <BuildActionEntries>
         <BuildActionEntry buildForTesting="YES" buildForRunning="YES" buildForProfiling="YES" buildForArchiving="YES" buildForAnalyzing="YES">
            <BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{ids["appTarget"]}" BuildableName="TakaraSagashi.app" BlueprintName="TakaraSagashi" ReferencedContainer="container:TakaraSagashi.xcodeproj"/>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.DebuggerFoundation.Launcher.LLDB" shouldUseLaunchSchemeArgsEnv="YES">
      <Testables>
         <TestableReference skipped="NO">
            <BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{ids["testTarget"]}" BuildableName="TakaraSagashiTests.xctest" BlueprintName="TakaraSagashiTests" ReferencedContainer="container:TakaraSagashi.xcodeproj"/>
         </TestableReference>
      </Testables>
   </TestAction>
   <LaunchAction buildConfiguration="Debug" selectedDebuggerIdentifier="Xcode.DebuggerFoundation.Debugger.LLDB" selectedLauncherIdentifier="Xcode.DebuggerFoundation.Launcher.LLDB" launchStyle="0" useCustomWorkingDirectory="NO" ignoresPersistentStateOnLaunch="NO" debugDocumentVersioning="YES" debugServiceExtension="internal" allowLocationSimulation="YES">
      <BuildableProductRunnable runnableDebuggingMode="0">
         <BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{ids["appTarget"]}" BuildableName="TakaraSagashi.app" BlueprintName="TakaraSagashi" ReferencedContainer="container:TakaraSagashi.xcodeproj"/>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction buildConfiguration="Release" shouldUseLaunchSchemeArgsEnv="YES" savedToolIdentifier="" useCustomWorkingDirectory="NO" debugDocumentVersioning="YES">
      <BuildableProductRunnable runnableDebuggingMode="0">
         <BuildableReference BuildableIdentifier="primary" BlueprintIdentifier="{ids["appTarget"]}" BuildableName="TakaraSagashi.app" BlueprintName="TakaraSagashi" ReferencedContainer="container:TakaraSagashi.xcodeproj"/>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction buildConfiguration="Debug"/>
   <ArchiveAction buildConfiguration="Release" revealArchiveInOrganizer="YES"/>
</Scheme>
''')
print(f"Wrote project with {len(app_files)} app files and {len(test_files)} tests")
for path in app_files:
    print(" app", path)
for path in test_files:
    print(" test", path)
