# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Culturist' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Culturist

  pod 'Kingfisher', '~> 7.0'
  pod 'MJRefresh'
  pod 'Alamofire'
  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'
  pod 'FirebaseStorage'
  pod 'SwiftLint'
  pod 'ARCL'
  pod 'FSCalendar+Persian'
  pod 'SnapKit'
  pod 'Gemini'
  pod 'Hero'
  pod 'NVActivityIndicatorView'
  pod 'lottie-ios'


  source 'https://github.com/CocoaPods/Specs.git'

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      end
    end
  end
end
end
