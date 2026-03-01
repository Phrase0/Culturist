platform :ios, '17.6'

target 'Culturist' do
  use_frameworks!

  pod 'Kingfisher', '~> 7.0'
  pod 'MJRefresh'
  pod 'Alamofire'
  pod 'FirebaseAuth', '~> 11.0'
  pod 'FirebaseFirestore', '~> 11.0'
  pod 'FirebaseStorage', '~> 11.0'
  pod 'Firebase/Crashlytics', '~> 11.0'
  pod 'SwiftLint'
  pod 'ARCL'
  pod 'FSCalendar+Persian'
  pod 'SnapKit'
  pod 'Gemini'
  pod 'NVActivityIndicatorView'

  post_install do |installer|
    installer.generated_projects.each do |project|
      project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.6'
        end
      end
    end
  end
end
