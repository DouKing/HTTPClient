Pod::Spec.new do |s|
  s.name             = 'HTTPClient'
  s.version          = '0.1.0'
  s.summary          = 'A HTTP client.'
  
  s.description      = <<-DESC
    HTTP client using Alamofire.
                       DESC

  s.homepage         = 'https://github.com/douking/HTTPClient'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'douking' => 'wyk1016@126.com' }
  s.source           = { :git => 'https://github.com/douking/HTTPClient.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.source_files = 'Source/**/*'
  s.public_header_files = 'Source/HTTPClient.h'
  
  s.dependency 'Alamofire'
end
