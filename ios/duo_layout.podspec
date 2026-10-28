#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint duo_layout.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'duo_layout'
  s.version          = '0.4.0'
  s.summary          = 'The iPhone Duo hinge, fold and status bar column, for duo_layout.'
  s.description      = <<-DESC
The iPhone Duo hinge, fold and status bar column, for duo_layout.
                       DESC
  s.homepage         = 'https://github.com/AbdulrahmanElsehemi/duo_layout'
  s.license          = { :file => '../LICENSE' }
  s.author           = 'Abdulrahman Elsehemy'
  s.source           = { :path => '.' }
  s.source_files = 'duo_layout/Sources/duo_layout/**/*.swift'
  s.dependency 'Flutter'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # It declares nothing: the plugin tracks nothing, collects nothing, and
  # calls none of the APIs Apple asks reasons for.
  s.resource_bundles = {'duo_layout_privacy' => ['duo_layout/Sources/duo_layout/PrivacyInfo.xcprivacy']}
end
