# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "fluent-plugin-gamobile"
  s.version     = "0.0.1"
  s.authors     = ["Kentaro Yoshida"]
  s.email       = ["y.ken.studio@gmail.com"]
  s.homepage    = "https://github.com/y-ken/fluent-plugin-gamobile"
  s.summary     = %q{Fluentd Output plugin to send access report with "Google Analytics for mobile".}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "fluentd"
  s.add_runtime_dependency "fluentd"
  s.add_runtime_dependency "active_support"
  s.add_runtime_dependency "i18n"
end
