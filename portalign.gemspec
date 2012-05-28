require File.expand_path("../lib/portalign/version", __FILE__)

Gem::Specification.new do |s|
  s.name = "portalign"
  s.version = Portalign::VERSION

  s.required_rubygems_version = ">= 1.3.6"
  s.authors = ["Micah Wedemeyer"]
  s.email = "micah@agileleague.com"
  s.files = Dir["{lib}/**/*.rb", "bin/*", "Rakefile", "*.md"]
  s.homepage = "http://github.com/agileleague/portalign"
  s.summary = "A tool to automatically add and remove your current IP address to Amazon EC2 security groups."
  s.description = "Easily set and unset your current IP as an allowed ingress for a given EC2 security group. This allows you to securely close port 22 (or whatever you use for SSH) except for your current exact IP."
  s.test_files = Dir["{spec}/**/*.rb"]

  s.add_runtime_dependency("aws", "2.5.6")
  s.add_development_dependency("rake")
  s.add_development_dependency("rspec", " ~> 2.10.0")
end

