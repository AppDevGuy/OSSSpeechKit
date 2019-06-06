#
# Be sure to run `pod lib lint OSSSpeechKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'OSSSpeechKit'
  s.version          = '0.1.0'
  s.summary          = 'OSSSpeechKit provides developers easy text to voice integration.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
OSSSpeechKit offers an easy way to integrate text to voice using native AVFoundation speech kit.
                       DESC

  s.homepage         = 'https://github.com/appdevguy/OSSSpeechKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'appdevguy' => 'seaniosdeveloper@gmail.com' }
  s.source           = { :git => 'https://github.com/appdevguy/OSSSpeechKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'

  s.source_files = 'OSSSpeechKit/Classes/*.swift'
  
  # s.resource_bundles = {
  #   'OSSSpeechKit' => ['OSSSpeechKit/Assets/*.png']
  # }

   s.public_header_files = 'Pod/Classes/*.swift'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
