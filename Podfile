# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

target 'worddeposit' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for worddeposit
  pod 'Firebase/Core'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  # pod 'FirebaseFirestoreSwift'
  pod 'Firebase/Storage'
  pod 'IQKeyboardManagerSwift'
  pod 'Kingfisher'
  #  pod 'CodableFirebase'
  pod 'YPImagePicker'
  #  pod 'PryntTrimmerView', :git => 'https://github.com/HHK1/PryntTrimmerView.git'
  
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
    end
  end
end
