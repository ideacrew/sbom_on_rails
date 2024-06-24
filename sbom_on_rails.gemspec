lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name = %q{sbom_on_rails}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Trey Evans"]

  s.email = 'lewis.r.evans@gmail.com'
  s.date = %q{2024-05-01}
  s.summary = %q{Report gem versions.}
  s.description = %q{Produce an SBOM for a rails application using multiple sources.}
  s.files = `git ls-files -- lib/* bin/*`.split("\n")
  s.homepage = %q{http://github.com/ideacrew/sbom_on_rails}
  s.require_paths = ["lib"]
  s.license = "MIT"
  s.bindir = "bin"

  s.required_ruby_version = '>= 2.7'
  s.add_runtime_dependency "bundler"
  s.add_runtime_dependency "gem_report"
  s.add_runtime_dependency "treetop"
  s.add_runtime_dependency "nokogiri"
  s.add_runtime_dependency "rubyzip"
end
