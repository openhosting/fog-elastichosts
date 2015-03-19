require 'rake/testtask'

Rake::TestTask.new do |t|
  t.test_files = FileList['spec/lib/*_spec.rb']
  t.verbose = true
end

task :default => :test

def name
  @name ||= Dir['*.gemspec'].first.split('.').first
end

def version
  line = File.read("lib/#{name}.rb")[/^\s*VERSION\s*=\s*.*/]
  line.match(/.*VERSION\s*=\s*['"](.*)['"]/)[1]
end

def gemspec_file
  "#{name}.gemspec"
end

def gem_file
  "#{name}-#{version}.gem"
end

desc "Run all tests"
task :test do
  exec 'script/test'
end
