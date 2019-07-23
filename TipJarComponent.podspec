Pod::Spec.new do |s|
  s.name             = 'TipJarComponent'
  s.version          = '0.0.1'
  s.summary          = 'An iOS component for providing users an option to tip the developer.'

  s.description      = <<-DESC
  A helper utility for developers to easily enable one-time tips from their users.
  Supports iCloud syncing of already paid tips. Ability to launch as a standalone
  component (overlaid above the app's content) or as a view controller, that can be
  presented in the app's navigation stack.
  DESC

  s.homepage         = 'https://github.com/zigadolar/tip-jar'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Dolar, Ziga' => 'dolar.ziga@gmail.com' }
  s.source           = { :git => 'https://github.com/zigadolar/tip-jar.git', :tag => s.version.to_s }

  s.platform = :ios, '11.0'
  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'

  s.source_files = 'TipJarComponent/Classes/**/*'
  
  s.ios.resource_bundles = {
    'TipJarComponent' => ['TipJarComponent/Assets/*.xcassets',
    'TipJarComponent/Assets/*.storyboard',
    'TipJarComponent/Assets/*.xib']
  }

  s.frameworks = 'UIKit', 'StoreKit'
end
