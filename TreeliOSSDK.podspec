
Pod::Spec.new do |spec|

  spec.name         = "TreeliOSSDK"
  spec.version      = "1.0.0"
  spec.summary      = "iOS sdk TreeliOSSDK."
  spec.description  = "This is  treel iOS sdk TreeliOSSDK."
  spec.homepage     = "https://github.com/treel-lib/TreeliOSSDK"
  spec.license      = "MIT"
  spec.author             = { "treel" => "treel.developers@gmail.com" }
  spec.platform     = :ios, "11.0"
  spec.source       = { :git => "https://github.com/treel-lib/TreeliOSSDK.git", :tag => "1.0.0" }
  spec.source_files  = 'TreeliOSSDK/**/*.swift'
  spec.swift_versions = '5.0'
  spec.dependency 'CryptoSwift'
  spec.ios.deployment_target = '10.0'
 
end
