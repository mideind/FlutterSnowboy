#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_snowboy.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_snowboy'
  s.version          = '0.0.1'
  s.summary          = 'Flutter Snowboy plugin.'
  s.description      = 'Flutter plugin for Snowboy DNN-based hotword detection.'
  s.homepage         = 'http://github.com/mideind/flutter_snowboy'
  s.license          = { :file => '../LICENSE.txt' }
  s.author           = { 'Miðeind' => 'mideind@mideind.is' }
  s.source           = { :path => '.' }
  s.source_files     = ['Classes/**/*']
  # s.public_header_files = ['Classes/**/*.h']
  # s.vendored_libraries = ['Assets/**/*.a']
  s.private_header_files = ['Assets/**/*.h']
  s.resources        = 'Assets/**/*'
  s.dependency 'Flutter'
  s.platform         = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
