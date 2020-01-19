Pod::Spec.new do |s|
  s.name             = 'Tsuchi'
  s.version          = '0.7.0'
  s.summary          = 'Tsuchi is a Firebase Cloud Messaging wrapper.'

  s.description      = <<-DESC
Tsuchi is a Firebase Cloud Messaging wrapper.
You can define type safe Notification object, and handle it.
                       DESC

  s.homepage         = 'https://github.com/miup/Tsuchi'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'miup' => 'contact@miup.blue' }
  s.source           = { :git => 'https://github.com/miup/Tsuchi.git', :tag => s.version.to_s }

  s.ios.deployment_target = '11.0'

  s.source_files = 'Tsuchi/Classes/**/*'

  s.static_framework = true
  s.static_framework = true

  s.dependency 'Firebase/Core', '~>6.0'
  s.dependency 'Firebase/Messaging', '~>6.0'
end
