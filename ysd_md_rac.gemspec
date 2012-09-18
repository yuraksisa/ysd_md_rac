Gem::Specification.new do |s|
  s.name    = "ysd_md_rac"
  s.version = "0.2.0"
  s.authors = ["Yurak Sisa Dream"]
  s.date    = "2012-01-09"
  s.email   = ["yurak.sisa.dream@gmail.com"]
  s.files   = Dir['lib/**/*.rb']
  s.summary = "A model for resource access control management"
  s.homepage = "http://github.com/yuraksisa/ysd_md_rac"
    
  s.add_runtime_dependency "ysd_md_system"          # YSD::System::Request
  s.add_runtime_dependency "ysd_md_comparison"      # To build the conditions
     
end