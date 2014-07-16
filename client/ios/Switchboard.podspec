Pod::Spec.new do |s|
  s.name         = "Switchboard"
  s.version      = "0.0.3"
  s.summary      = "Switchboard - Light A/B testing for your mobile iPhone and Android."
  s.description  = <<-DESC
                   Switchboard:
                   Easy and super light weight A/B testing for your mobile iPhone or android app. 
                   This mobile A/B testing framework allows you with minimal servers to run large amounts of mobile users.
                   DESC
  s.homepage     = "https://github.com/TofPlay/Switchboard"
  s.license      = "Apache License, Version 2.0"
  s.author       = { "Christophe Braud" => "chbperso@gmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/TofPlay/Switchboard.git", :tag => "0.0.3" }
  s.source_files = "client/ios/Switchboard/*.{h,m}"
  s.requires_arc = true
end
