require 'rake'
require 'rake/gempackagetask'
require 'spec/rake/spectask'
require 'battleship_tournament/submit'

desc "Run all specs"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.rcov = false
end

PKG_NAME = "ssoroka_takes_the_win"
PKG_VERSION   = "1.0"

spec = Gem::Specification.new do |s|
  s.name = PKG_NAME
  s.version = PKG_VERSION
  s.files = FileList['**/*'].reject{|f| f =~ /^pkg/}.to_a
  s.require_path = 'lib'
  s.test_files = Dir.glob('spec/*_spec.rb')
  s.bindir = 'bin'
  s.executables = []
  s.summary = "Battleship Player:ssoroka takes the win"
  s.rubyforge_project = "sparring"
  s.homepage = "http://sparring.rubyforge.org/"

  ###########################################
  ##
  ## You are encouraged to modify the following
  ## spec attributes.
  ##
  ###########################################
  s.description = "A battleship player"
  s.author = "Steven Soroka"
  s.email = "ssoroka78@gmail.com"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = false
  pkg.need_tar = false
end

desc "Submit your player"
task :submit do
  submitter = BattleshipTournament::Submit.new(PKG_NAME)
  submitter.submit
end
