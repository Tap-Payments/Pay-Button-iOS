Pod::Spec.new do |s|
  s.name             = 'Pay-Button-iOS'
  s.version          = '0.0.2'
  s.summary          = 'From the shelf card processing library provided by Tap Payments'
  s.homepage         = 'https://github.com/Tap-Payments/Pay-Button-iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'o.rabie' => 'o.rabie@tap.company', 'h.sheshtawy' => 'h.sheshtawy@tap.company' }
  s.source           = { :git => 'https://github.com/Tap-Payments/Pay-Button-iOS.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  s.source_files = 'Sources/Pay-Button-iOS/Logic/**/*.swift'
  s.resources = "Sources/Pay-Button-iOS/Resources/**/*.{json,xib,pdf,png,gif,storyboard,xcassets,xcdatamodeld,lproj}"
  s.dependency'SwiftyRSA'
  s.dependency'SharedDataModels-iOS'
  s.dependency'TapFontKit-iOS'
  s.dependency'Robin'
end
