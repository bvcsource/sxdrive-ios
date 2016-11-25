platform :ios, "8.0"
source 'https://github.com/CocoaPods/Specs.git'
inhibit_all_warnings!

target "SXDrive" do
	pod 'AFNetworking'
	pod 'SSKeychain'
	pod 'UIDevice-Helpers'
	pod 'JFBCrypt'
	pod 'RNCryptor'
end

target "SXDriveTests" do
	pod 'AFNetworking'
	pod 'SSKeychain'
	pod 'Kiwi'
end

post_install do |installer|
	installer.pods_project.targets.each do |target|
		target.build_configurations.each do |config|
			config.build_settings['FRAMEWORK_SEARCH_PATHS'] = [ '$(PLATFORM_DIR)/Developer/Library/Frameworks' ]
		end
	end
end
