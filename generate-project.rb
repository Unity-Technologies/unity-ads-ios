#!/usr/bin/env ruby

require 'bundler'
require 'fileutils'
Bundler.require(:default)

# Handle command line arguments
opts = Optimist::options do
  opt :configuration_type, "Type of configuration to use options: ['dev', 'library']",
      :type => :string, :default => 'dev'
  opt :test_target_name, "Name of the test target to build",
      :type => :string, :default => 'UnityAdsTests'
  opt :example_target_name, "Name of the example target to build",
      :type => :string, :default => 'UnityAdsExample'
end
project_configuration_type_name = opts[:configuration_type]
test_target_name = opts[:test_target_name]
example_target_name = opts[:example_target_name]

if ARGV.length > 0
  raise "Unkown arguments '#{ARGV}', check usage with '--help' flag!"
end

# create group for current dir_name
# add files from the current dir_name
# venture downwards if we have directories
def create_groups_from_dir(root_dir, parent_group, target, is_example_project = false)
  Dir.glob(root_dir).select{|d| File.directory? d}.each do |subdirectory|
    dir_name = File.basename(subdirectory)

    Dir.chdir(subdirectory)
    g = parent_group.new_group(dir_name)

    if !is_example_project
      Dir.glob("#{target}-Bridging-Header.h") do |f|
        file_to_add = g.new_file(Dir.pwd + '/' + f)
        target.build_configurations.each do |bc|
          bc.build_settings['SWIFT_OBJC_BRIDGING_HEADER'] = "#{target}/#{f}"
        end
      end
    end

    Dir.glob("*.pch") do |f|
      g.new_file(Dir.pwd + '/' + f)
      target.build_configurations.each  do |bc|
        bc.build_settings['GCC_PREFIX_HEADER'] = "#{target}/#{f}"
      end
    end

    Dir.glob("Info.plist") do |f|
      file_to_add = g.new_file(Dir.pwd + '/' + f)
      target.build_configurations.each  do |bc|
        bc.build_settings['INFOPLIST_FILE'] = "$(SRCROOT)/#{target}/#{f}"
      end
    end

    Dir.glob("*.xcassets") do |f|
      file_to_add = g.new_file(Dir.pwd + '/' + f)
      target.add_resources([file_to_add])
    end

    Dir.glob("*.storyboard") do |f|
      file_to_add = g.new_file(Dir.pwd + '/' + f)
      target.add_resources([file_to_add])
    end

    Dir.glob("*.swift") do |f|
      file_to_add = g.new_file(Dir.pwd + '/' + f)
      target.source_build_phase.add_file_reference(file_to_add, true)
    end

    if !is_example_project
      Dir.glob("*.m") do |f|
        file_to_add = g.new_file(Dir.pwd + '/' + f)
        target.source_build_phase.add_file_reference(file_to_add, true)
      end

      public_patterns = [
        # Core
        /UADS(.*)MetaData\.h/,
        /UnityServices\.h/,
        /USRVJsonStorage\.h/,

        # Ads
        /UnityAdsFinishState\.h/,
        /UnityAdsExtended\.h/,

        # Banners
        /UADSBanner\.h/,

        # Analytics
        /UANAApiAnalytics.h/,
        /UnityAnalytics(.*).h/,

        # Purchasing
        /UADSPurchasing\.h/,
        /USRVUnityPurchasing.h/,

        # BYOP
        /USRVUnityPurchasingDelegate.h/,
        /UPURProduct.h/,
        /UPURTransactionDetails.h/,
        /UPURTransactionError.h/,
        /UPURStore.h/,
        /UPURTransactionErrorDetails.h/,

        # Monetization
        /UnityMonetization.h/,
        /UnityMonetizationDelegate.h/,
        /UnityMonetizationPlacementContentState.h/,
        /UMONPlacementContent.h/,
        /UMONCustomEvent.h/,
        /UMONRewardablePlacementContent.h/,
        /UMONShowAdPlacementContent.h/,
        /UMONPromoAdPlacementContent.h/,
        /UMONPromoMetaData.h/,
        /UMONPromoProduct.h/,
        /UMONItem.h/,
        /UMONNativePromoAdapter.h/
      ]

      Dir.glob("*.h") do |f|
        file_to_add = g.new_file(Dir.pwd + '/' + f)
        added_file = target.headers_build_phase.add_file_reference(file_to_add, true)
        added_file.settings ||= {}
        if "#{f}" == "#{target}.h" or public_patterns.select{ |p| "#{f}" =~ p }.length != 0
          added_file.settings['ATTRIBUTES'] = ['Public']
        else
          added_file.settings['ATTRIBUTES'] = ['Project']
        end
      end
    end

    create_groups_from_dir("#{Dir.pwd}/*", g, target)

    Dir.chdir("../")
  end
end

def generate_framework_project(xcode_project_name, project_name, test_target_name, example_target_name)
  FileUtils.rm_rf(xcode_project_name)
  project = Xcodeproj::Project.new(project_name)

  # Construct targets
  framework_target = project.new_target(:framework, project_name, :ios)
  framework_test_target = project.new_target(:unit_test_bundle, project_name + "Tests", :ios)
  @framework_example_target = project.new_target(:application, project_name + "Example", :ios)
  @framework_monetization_example_target = project.new_target(:application, "UnityMonetizationExample", :ios) # monetization

  # Use our function to add resources to targets from subdirectories
  create_groups_from_dir("#{project_name}", project, framework_target)
  # Just a hack now to add UnityServices to project generation
  create_groups_from_dir("UnityServices", project, framework_target)
  create_groups_from_dir("#{test_target_name}", project, framework_test_target)
  create_groups_from_dir("#{example_target_name}", project, @framework_example_target)
  create_groups_from_dir("UnityMonetizationExample", project, @framework_monetization_example_target) # monetization

  # Configure the framework target
  framework_target.build_configurations.each do |bc|
    bc.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "com.unity3d.ads.UnityAds"
    bc.build_settings['CURRENT_PROJECT_VERSION'] = 1
    bc.build_settings['HEADER_SEARCH_PATHS'] = ["UnityAds/", "UnityServices/"]
    bc.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = "7.0"
  end

  # Configure the example target
  @framework_example_target.build_configurations.each do |bc|
    bc.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "com.unity3d.ads.example"
    bc.build_settings['CURRENT_PROJECT_VERSION'] = 1
    bc.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = "7.0"
    bc.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ["$(inherited)", "@executable_path/Frameworks", "@loader_path/Frameworks"]
    bc.build_settings['DEVELOPMENT_TEAM'] = '4DZT52R2T5'
  end

    # Configure the monetization example target
  @framework_monetization_example_target.build_configurations.each do |bc|
    bc.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "com.unity3d.monetization.example"
    bc.build_settings['CURRENT_PROJECT_VERSION'] = 1
    bc.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = "7.0"
    bc.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ["$(inherited)", "@executable_path/Frameworks", "@loader_path/Frameworks"]
    bc.build_settings['DEVELOPMENT_TEAM'] = '4DZT52R2T5'
  end

  # Configure the test target
  framework_test_target.build_configurations.each do |bc|
    bc.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "com.unity3d.ads.UnityAdsTests"
    bc.build_settings['FRAMEWORK_SEARCH_PATHS'] = ["$(PROJECT_DIR)/UnityAds", "$(PROJECT_DIR)/UnityServices", "$(inherited)"]
    bc.build_settings['HEADER_SEARCH_PATHS'] = ["$(TARGET_TEMP_DIR)/../$(PROJECT_NAME).build/DerivedSources", "$(PROJECT_DIR)/UnityAds", "$(PROJECT_DIR)/UnityServices"]
    bc.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ["$(inherited)", "@executable_path/Frameworks", "@loader_path/Frameworks"]
    bc.build_settings['TEST_HOST'] = "$(BUILT_PRODUCTS_DIR)/UnityAdsExample.app/UnityAdsExample"
    bc.build_settings["CODE_SIGN_IDENTITY[sdk=iphoneos*]"] = "iPhone Developer"
    bc.build_settings['DEVELOPMENT_TEAM'] = '4DZT52R2T5'
  end

  # Add target dependencies
  framework_test_target.add_dependency(framework_target)
  framework_test_target.add_dependency(@framework_example_target)
  @framework_example_target.add_dependency(framework_target)
  @framework_monetization_example_target.add_dependency(framework_target)

  # Add copy files build phase to example target build configuration
  copy_framework_to_example_phase = project.new(Xcodeproj::Project::PBXCopyFilesBuildPhase)
  copy_framework_to_example_phase.symbol_dst_subfolder_spec = :frameworks
  framework_file = project.products[0]
  copied_framework_file_reference = copy_framework_to_example_phase.add_file_reference(framework_file)
  copied_framework_file_reference.settings ||= {}
  copied_framework_file_reference.settings['ATTRIBUTES'] = ['CodeSignOnCopy']
  @framework_example_target.build_phases << copy_framework_to_example_phase
  @framework_monetization_example_target.build_phases << copy_framework_to_example_phase

  # Configure the example target as the test host for the test target
  project.root_object.attributes["TargetAttributes"] = Hash["#{framework_test_target.uuid}" => Hash["TestTargetID" => "#{@framework_example_target.uuid}"]]

  # Load Saved Scheme
  scheme_dir = 'xcschemes/'
  scheme_name = 'UnityAds.xcscheme'
  temp_file = File.join(scheme_dir, scheme_name)
  scheme = Xcodeproj::XCScheme.new(temp_file)

  # Serialize and save project + scheme
  project.save(xcode_project_name)
  scheme.save_as(xcode_project_name, project_name, true)
end

def generate_static_library_project(xcode_project_name, project_name)
  FileUtils.rm_rf(xcode_project_name)
  project = Xcodeproj::Project.new(project_name)

  # Construct targets
  framework_target = project.new_target(:bundle, project_name, :ios)

  # Use our function to add resources to targets from subdirectories
  create_groups_from_dir("#{project_name}", project, framework_target)
  # Just a hack now to add UnityServices to project generation
  create_groups_from_dir("UnityServices", project, framework_target)

  # Configure the example target
  framework_target.build_configurations.each do |bc|
    bc.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "com.unity3d.ads.UnityAds"
    bc.build_settings['CURRENT_PROJECT_VERSION'] = 1
    bc.build_settings['HEADER_SEARCH_PATHS'] = ["UnityAds/", "UnityServices/"]
    bc.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = "$(TARGET_$(CURRENT_ARCH))"
    bc.build_settings['SDKROOT'] = "iphoneos"

    bc.build_settings['ONLY_ACTIVE_ARCH'] = "NO"
    bc.build_settings['ENABLE_BITCODE'] = "YES"
    bc.build_settings['BITCODE_GENERATION_MODE'] = "bitcode"
    bc.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = "7.0"

    bc.build_settings['ARCHS'] = "$(ARCHS_$(XCODE_VERSION_MAJOR))"
    bc.build_settings['HIDE_BITCODE_SYMBOLS'] = "NO"
    bc.build_settings['STRIP_BITCODE_FROM_COPIED_FILES'] = "NO"
    bc.build_settings['CLANG_ENABLE_MODULES'] = "YES"

    bc.build_settings['ARCHS_1000'] = "$(ARCHS_STANDARD) armv7s"
    bc.build_settings['ARCHS_0900'] = "$(ARCHS_STANDARD) armv7s"
    bc.build_settings['ARCHS_0800'] = "$(ARCHS_STANDARD) armv7s"
    bc.build_settings['ARCHS_0700'] = "$(ARCHS_STANDARD) armv7s"
    bc.build_settings['ARCHS_0600'] = "$(ARCHS_STANDARD) armv7s"
    bc.build_settings['ARCHS_0500'] = "$(ARCHS_STANDARD_INCLUDING_64_BIT)"
    bc.build_settings['ARCHS_0400'] = "$(ARCHS_STANDARD_32_BIT)"
    bc.build_settings['TARGET_arm64'] = "7.0"
    bc.build_settings['TARGET_armv7'] = "7.0"
    bc.build_settings['TARGET_x86_64'] = "7.0"
    bc.build_settings['TARGET_i386'] = "7.0"
    bc.build_settings['TARGET_armv7s'] = "7.0"

    bc.build_settings['HIDE_BITCODE_SYMBOLS'] = "NO"
    bc.build_settings['STRIP_BITCODE_FROM_COPIED_FILES'] = "NO"
    bc.build_settings['CLANG_ENABLE_MODULES'] = "YES"

    bc.build_settings['WRAPPER_EXTENSION'] = "framework"
    bc.build_settings['FRAMEWORK_VERSION'] = "A"
    bc.build_settings['MACH_O_TYPE'] = "mh_object"
    bc.build_settings['DYLIB_CURRENT_VERSION'] = "1"

    bc.build_settings['DEAD_CODE_STRIPPING'] = "NO"
    bc.build_settings['SKIP_INSTALL'] = "NO"
    bc.build_settings['INSTALL_PATH'] = "$(BUILT_PRODUCTS_DIR)"
    bc.build_settings['DYLIB_COMPATIBILITY_VERSION'] = "1"
    bc.build_settings['LINK_WITH_STANDARD_LIBRARIES'] = "NO"
    bc.build_settings['GCC_PRECOMPILE_PREFIX_HEADER'] = "YES"
    bc.build_settings['BUILD_DIR'] = "$(SRCROOT)/build"
    bc.build_settings['CONTENTS_FOLDER_PATH'] = "$(WRAPPER_NAME)"
    bc.build_settings['FRAMEWORK_SEARCH_PATHS'] = ""
    bc.build_settings['GCC_PREFIX_HEADER'] = "UnityAds/PrefixHeader.pch"
    bc.build_settings['INFOPLIST_FILE'] = "UnityAds/Info.plist"
    bc.build_settings['INFOPLIST_PATH'] = "$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/Info.plist"
    bc.build_settings['PRODUCT_NAME'] = "$(TARGET_NAME)"
    bc.build_settings['COPY_PHASE_STRIP'] = "YES"

    if bc.name == "Debug"
      bc.build_settings['ENABLE_BITCODE'] = "NO"
    end
  end

  setup_build_phase = project.new(Xcodeproj::Project::Object::PBXShellScriptBuildPhase)
  setup_build_phase.shell_script = "./scripts/clean-framework.sh"
  framework_target.build_phases.unshift(setup_build_phase)

  header_build_phase = project.new(Xcodeproj::Project::Object::PBXShellScriptBuildPhase)
  header_build_phase.shell_script = "./scripts/export-framework.sh"
  framework_target.build_phases << header_build_phase


  # Load Saved Scheme
  scheme_dir = 'xcschemes/'
  scheme_name = 'UnityAdsStaticLibrary.xcscheme'
  temp_file = File.join(scheme_dir, scheme_name)
  scheme = Xcodeproj::XCScheme.new(temp_file)

  # Serialize and save project + scheme
  project.save(xcode_project_name)
  scheme.save_as(xcode_project_name, project_name, true)
end


if project_configuration_type_name == "dev"
  generate_framework_project("UnityAds.xcodeproj", "UnityAds", test_target_name, example_target_name)
end

if project_configuration_type_name == "library"
  generate_static_library_project("UnityAdsStaticLibrary.xcodeproj", "UnityAds")

end
