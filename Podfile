# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'MarinTrace' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MarinTrace
  pod 'Firebase/Analytics'
  pod 'Firebase/Auth'
  pod 'Firebase/Performance'
  pod 'Firebase/Crashlytics'
  pod 'VENTokenField', '~> 2.0'
  pod 'GoogleSignIn'
  pod 'Alamofire', '~> 4.9'
  pod 'M13Checkbox'
  pod 'SwaggerClient', :path => "./"
  pod 'Auth0', '~> 1.0'
  pod 'SVProgressHUD'
  pod 'RealmSwift'
  pod 'KeychainSwift', '~> 19.0'

  target 'MarinTraceTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'MarinTraceUITests' do
    # Pods for testing
  end

end

post_install do |installer|
     installer.pods_project.targets.each do |target|
           target.build_configurations.each do |config|
                 config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
           end
     end
 end
