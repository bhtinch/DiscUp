# Uncomment the next line to define a global platform for your project
 platform :ios, '15.0'

target 'DiscUP' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for DiscUP

  pod 'FirebaseCore'
  pod 'FirebaseAuth'
  pod 'FirebaseDatabase'
  pod 'FirebaseStorage'
  pod 'FirebaseFirestore'
  pod 'FirebaseFirestoreSwift'
  pod 'GeoFire/Utils'

  #MessageKit
  pod 'MessageKit'

end

post_install do |pi|
    pi.pods_project.targets.each do |t|
      t.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.4'
      end
    end
end
	
