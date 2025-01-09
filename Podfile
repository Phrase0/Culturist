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
  pod 'Firebase/Crashlytics'
  pod 'SwiftLint'
  pod 'ARCL'
  pod 'FSCalendar+Persian'
  pod 'SnapKit'
  pod 'Gemini'
  pod 'NVActivityIndicatorView'

  # post install
  post_install do |installer|
    # Set iOS deployment target
    installer.generated_projects.each do |project|
      project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
        end
      end
    end

    # Modify BoringSSL-GRPC settings
    installer.pods_project.targets.each do |target|
      next unless target.name == 'BoringSSL-GRPC'

      # Adjust compiler flags
      target.source_build_phase.files.each do |file|
        next unless file.settings && file.settings['COMPILER_FLAGS']

        flags = file.settings['COMPILER_FLAGS'].split
        flags.reject! { |flag| flag == '-GCC_WARN_INHIBIT_ALL_WARNINGS' }
        file.settings['COMPILER_FLAGS'] = flags.join(' ')
      end

      # Adjust library search paths
      target.build_configurations.each do |config|
        xcconfig_relative_path = "Pods/Target Support Files/#{target.name}/#{target.name}.#{config.name}.xcconfig"
        file_path = Pathname.new(File.expand_path(xcconfig_relative_path))
        next unless File.file?(file_path)

        configuration = Xcodeproj::Config.new(file_path)
        next if configuration.attributes['LIBRARY_SEARCH_PATHS'].nil?

        configuration.attributes['LIBRARY_SEARCH_PATHS'].sub! 'DT_TOOLCHAIN_DIR', 'TOOLCHAIN_DIR'
        configuration.save_as(file_path)
      end
    end
  end
end
