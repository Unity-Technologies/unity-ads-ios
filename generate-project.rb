#!/usr/bin/env ruby

require 'xcodeproj'
require 'fileutils'

# Get test target name as arguement from command
test_target_name = ARGV[0]

# Set default test target name if it wasn't given in the command
if test_target_name.nil?
  test_target_name = "UnityAdsTests"
end

# Get example app target name as arguement from command
example_target_name = ARGV[1]

if example_target_name.nil?
  example_target_name = "UnityAdsExample"
end

IOS_VERSION = 9.3

xcode_project_name = "UnityAds.xcodeproj"
FileUtils.rm_rf(xcode_project_name)

project_name = "UnityAds"

target_directories = Dir['*/'].select do |sub_directory|
  sub_directory.index(project_name) == 0
end

p target_directories

project = Xcodeproj::Project.new(project_name)

# create group for current dir_name
# add files from the current dir_name
# venture downwards if we have directories
def create_groups_from_dir(root_dir, parent_group, target)
  Dir.glob(root_dir).select{|d| File.directory? d}.each do |subdirectory|
    dir_name = File.basename(subdirectory)
    
    Dir.chdir(subdirectory)
    g = parent_group.new_group(dir_name)
    
    Dir.glob("#{target}-Bridging-Header.h") do |f|
      file_to_add = g.new_file(Dir.pwd + '/' + f)
      target.build_configurations.each  do |bc| 
        bc.build_settings['SWIFT_OBJC_BRIDGING_HEADER'] = "#{target}/#{f}"
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
    
    Dir.glob("*.m") do |f|
      file_to_add = g.new_file(Dir.pwd + '/' + f)
      target.source_build_phase.add_file_reference(file_to_add, true)
    end
    
    Dir.glob("*.h") do |f|
      file_to_add = g.new_file(Dir.pwd + '/' + f)
      added_file = target.headers_build_phase.add_file_reference(file_to_add, true)
      added_file.settings ||= {}
      if "#{f}" == "#{target}.h" or "#{f}" =~ /UADS(.*)MetaData\.h/
        added_file.settings['ATTRIBUTES'] = ['Public']
      else
        added_file.settings['ATTRIBUTES'] = ['Project']
      end
    end
    
    create_groups_from_dir("#{Dir.pwd}/*", g, target)
      
    Dir.chdir("../")
  end
end

# Construct targets
framework_target = project.new_target(:framework, project_name, :ios) 
framework_test_target = project.new_target(:unit_test_bundle, project_name + "Tests", :ios)
@framework_example_target = project.new_target(:application, project_name + "Example", :ios)

# Use our function to add resources to targets from subdirectories
create_groups_from_dir("#{project_name}", project, framework_target)
create_groups_from_dir("#{test_target_name}", project, framework_test_target)
create_groups_from_dir("#{example_target_name}", project, @framework_example_target)

# Configure the framework target
framework_target.build_configurations.each  do |bc| 
  bc.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "com.unity3d.ads.UnityAds"
  bc.build_settings['CURRENT_PROJECT_VERSION'] = 1
  bc.build_settings['HEADER_SEARCH_PATHS'] = "UnityAds/"
  bc.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = "7.0"
  if bc.name == "Debug"  
    bc.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = ["UADSWEBVIEW_BRANCH=\"master\"", "DEBUG=1", "$(inherited)"]
  end
end

# Configure the example target
@framework_example_target.build_configurations.each  do |bc| 
  bc.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "com.unity3d.ads.example"
  bc.build_settings['CURRENT_PROJECT_VERSION'] = 1
  bc.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = "7.0"
  bc.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ["$(inherited)", "@executable_path/Frameworks", "@loader_path/Frameworks"]
end

# Configure the test target
framework_test_target.build_configurations.each  do |bc| 
  bc.build_settings['PRODUCT_BUNDLE_IDENTIFIER'] = "com.unity3d.ads.UnityAdsTests"
  bc.build_settings['FRAMEWORK_SEARCH_PATHS'] = ["$(PROJECT_DIR)/UnityAds", "$(inherited)"]
  bc.build_settings['HEADER_SEARCH_PATHS'] = ["$(TARGET_TEMP_DIR)/../$(PROJECT_NAME).build/DerivedSources", "$(PROJECT_DIR)/UnityAds"]
  bc.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ["$(inherited)", "@executable_path/Frameworks", "@loader_path/Frameworks"]
  bc.build_settings['TEST_HOST'] = "$(BUILT_PRODUCTS_DIR)/UnityAdsExample.app/UnityAdsExample"
end

# Add target dependencies
framework_test_target.add_dependency(framework_target)
framework_test_target.add_dependency(@framework_example_target)
@framework_example_target.add_dependency(framework_target)

# Add copy files build phase to example target build configuration
copy_framework_to_example_phase = project.new(Xcodeproj::Project::PBXCopyFilesBuildPhase)
copy_framework_to_example_phase.symbol_dst_subfolder_spec = :frameworks
framework_file = project.products[0]
copied_framework_file_reference = copy_framework_to_example_phase.add_file_reference(framework_file)
copied_framework_file_reference.settings ||= {}
copied_framework_file_reference.settings['ATTRIBUTES'] = ['CodeSignOnCopy']
@framework_example_target.build_phases << copy_framework_to_example_phase

# Configure the example target as the test host for the test target
project.root_object.attributes["TargetAttributes"] = Hash["#{framework_test_target.uuid}" => Hash["TestTargetID" => "#{@framework_example_target.uuid}"]]

# Load Saved Scheme
scheme_dir = 'xcschemes/'
scheme_name = 'UnityAds.xcscheme'
temp_file = File.join(scheme_dir, scheme_name)
scheme = Xcodeproj::XCScheme.new(temp_file)
          

# Serialize and save project
project.save(xcode_project_name)

# Serialize and save scheme
scheme.save_as(xcode_project_name, project_name, true)
