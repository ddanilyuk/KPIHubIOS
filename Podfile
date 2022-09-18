# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'KPIHubIOS' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for KPIHubIOS

  pod 'SwiftLint'

  target 'KPIHubIOSTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'KPIHubIOSUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
