Pod::Spec.new do |s|
  s.name = 'EmitterKit'
  s.version = '5.2.3'
  s.license = 'MIT'
  s.summary = 'Type-safe event handling for Swift'
  s.homepage = 'https://github.com/aleclarson/emitter-kit'
  s.authors = { 'Alec Larson' => '' }
  s.source = { :git => 'https://github.com/aleclarson/emitter-kit.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = 'src/*.{h,swift}'

  s.requires_arc = true
  s.swift_version = '4.0'
end
