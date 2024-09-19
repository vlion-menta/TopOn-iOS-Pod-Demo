Pod::Spec.new do |s|
  s.name             = 'TPNMentaCustomAdapter'
  s.version          = '1.0.17'
  s.summary          = 'TPNMentaCustomAdapter.'
  s.description      = 'A short description of TPNMentaCustomAdapter'
  s.homepage         = 'https://github.com/jdy/TopOnDemo-global'
  s.license          = "Custom"
  s.author           = { 'jdy' => 'wzy2010416033@163.com' }
  s.source           = { :git => "https://github.com/vlion-menta/TopOn-iOS-Pod-Demo.git", :tag => "#{s.version}"}

  s.static_framework = true
  s.ios.deployment_target = '11.0'
  s.source_files = 'TPNMentaCustomAdapter/Classes/**/*'
  
  # s.dependency 'TPNiOS', '6.3.57'
  s.dependency 'AnyThinkiOS', '~> 6.3.57'
  s.dependency 'MentaBaseGlobal', '~> 1.0.17'
  s.dependency 'MentaMediationGlobal', '~> 1.0.17'
  s.dependency 'MentaVlionGlobal', '~> 1.0.17'
  s.dependency 'MentaVlionGlobalAdapter', '~> 1.0.17'

end
