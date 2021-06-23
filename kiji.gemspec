lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kiji/version'

Gem::Specification.new do |spec|
  spec.name          = 'kiji'
  spec.version       = Kiji::VERSION
  spec.authors       = ['kakipo']
  spec.email         = ['kakipo@gmail.com']

  # if spec.respond_to?(:metadata)
  #   spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com' to prevent pushes to rubygems.org, or delete to allow pushes to any server."
  # end

  spec.summary       = 'API toolkits for Japanese e-Gov system'
  spec.homepage      = 'https://github.com/kufu/kiji'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.8'
  spec.add_development_dependency 'dotenv'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-bundler'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'guard-rubocop'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubyzip'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock'

  # spec.add_runtime_dependency 'signer'
  spec.add_runtime_dependency 'faraday'
  spec.add_runtime_dependency 'nokogiri'
end
