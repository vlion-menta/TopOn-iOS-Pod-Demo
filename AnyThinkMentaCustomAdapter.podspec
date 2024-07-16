Pod::Spec.new do |s|
    s.name             = 'AnyThinkMentaCustomAdapter'
    s.version          = '5.20.31'
    s.summary          = 'AnyThinkMentaCustomAdapter.'
    s.description      = 'This is the AnyThinkMentaCustomAdapter. Please proceed to https://www.mentamob.com for more information.'
    s.homepage         = 'https://www.mentamob.com/'
    s.license          = "Custom"
    s.author           = { 'wzy' => 'wangzeyong@mentamob.com' }
    s.source           = { :git => "https://github.com/vlion-menta/TopOn-iOS-Pod-Demo.git", :tag => "#{s.version}" }
  
    s.ios.deployment_target = '11.0'
    s.frameworks = 'UIKit', 'MapKit', 'MediaPlayer', 'CoreLocation', 'AdSupport', 'CoreMedia', 'AVFoundation', 'CoreTelephony', 'StoreKit', 'SystemConfiguration', 'MobileCoreServices', 'CoreMotion', 'Accelerate','AudioToolbox','JavaScriptCore','Security','CoreImage','AudioToolbox','ImageIO','QuartzCore','CoreGraphics','CoreText'
    s.libraries = 'c++', 'resolv', 'z', 'sqlite3', 'bz2', 'xml2', 'iconv', 'c++abi'
    s.weak_frameworks = 'WebKit', 'AdSupport'
    s.static_framework = true
  
    s.source_files = 'MentaCustomAdapter/**/*'

    s.dependency 'MentaVlionBaseSDK', '~> 5.20.31'
    s.dependency 'MentaUnifiedSDK',   '~> 5.20.31'
    s.dependency 'MentaVlionSDK',     '~> 5.20.31'
    s.dependency 'MentaVlionAdapter', '~> 5.20.31'
    s.dependency 'AnyThinkiOS', '~> 6.3.54'
  
  end