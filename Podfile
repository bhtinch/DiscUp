# Uncomment the next line to define a global platform for your project
# platform :ios, '14.4'

target 'DiscUP' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for DiscUP

pod 'Firebase/Core'
pod 'Firebase/Auth'
pod 'Firebase/Database'
pod 'Firebase/Analytics'
pod 'Firebase/Crashlytics'
pod 'Firebase/Storage'

end

post_install do |pi|
    pi.pods_project.targets.each do |t|
      t.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.4'
      end
    end
end
