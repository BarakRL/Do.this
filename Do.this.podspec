Pod::Spec.new do |s|

  s.name         = "Do.this"
  s.version      = "1.0.0"
  s.summary      = "a quick async helper for Swift"
  s.description  = "Do.this is a Swift 5 quick async helper inspired by node.js Async"

  s.homepage     = "https://github.com/BarakRL/Do.this"
  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.author    = "Barak Harel"
  s.platform     = :ios, "11.0"

  s.source       = { :git => "https://github.com/BarakRL/Do.this.git", :tag => "#{s.version}" }
  s.source_files  = "Classes", "DoThis/**/*.{swift}"
  s.module_name	 = 'DoThis'

end
