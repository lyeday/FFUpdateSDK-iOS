#
# Be sure to run `pod lib lint FFUpdateSDK-iOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FFUpdateSDK-iOS'
  s.version          = '2.3.1'
  s.summary          = 'A short description of FFUpdateSDK-iOS.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/lyeday/FFUpdateSDK-iOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'lyeday' => 'lyeday@qq.com' }
  s.source           = { :git => 'https://github.com/lyeday/FFUpdateSDK-iOS.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.4'

  s.source_files = 'FFUpdateSDK-iOS/**/*'
  s.requires_arc = true
  
  # s.resource_bundles = {
  #   'FFUpdateSDK-iOS' => ['FFUpdateSDK-iOS/Assets/*.png']
  # }
  # s.public_header_files = 'FFUpdateSDK-iOS/FFUpdate.h', 'FFUpdateSDK-iOS/FFCordovaResourceUpdate.h'
  s.public_header_files = 'FFUpdateSDK-iOS/*.h', 'FFUpdateSDK-iOS/Category/*.h'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
