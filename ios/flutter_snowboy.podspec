#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_snowboy.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name                    = 'flutter_snowboy'
  s.version                 = '0.0.1'
  s.summary                 = 'Flutter Snowboy plugin.'
  s.description             = 'Flutter plugin for Snowboy DNN-based hotword detection.'
  s.homepage                = 'http://github.com/mideind/flutter_snowboy'
  s.author                  = { "Sveinbjorn Thordarson" => "sveinbjorn@sveinbjorn.org" }
  s.license                 = { :type => 'Apache 2', :file => '../LICENSE.txt' }
  s.source                  = { :path => '.' }
  s.source_files            = ['Classes/**/*.h', 'Classes/**/*.m', 'Classes/**/*.mm']
  s.public_header_files     = ['Classes/**/*.h']
  s.vendored_frameworks     = 'Snowboy.framework'
  s.resources               = 'Assets/**/*'
  s.dependency              'Flutter'
  s.platform                = :ios, '12.0'
  s.framework               = 'Accelerate'
  s.requires_arc            = true
  # Compile source files as Objective-C++
  s.xcconfig = {
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++11',
    'CLANG_CXX_LIBRARY' => 'libc++',
    'GCC_INPUT_FILETYPE' => 'sourcecode.cpp.objcpp',
  }
  # Flutter.framework does not contain an i386 slice.
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
end
