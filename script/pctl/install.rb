#!/usr/bin/env ruby
require 'fileutils'
require 'optparse'

def prompt(message, default)
  print "#{message} [#{default}]: "
  input = gets.chomp
  input.empty? ? default : input
end

# Parse command line options
options = {
  install_path: File.expand_path('~/bin/pctl')
}

OptionParser.new do |opts|
  opts.banner = "Usage: install.rb [options]"

  opts.on("--install-path PATH", "Installation path (default: ~/bin/pctl)") do |path|
    options[:install_path] = File.expand_path(path)
  end
end.parse!

# Confirm or get installation path
install_path = prompt("Installation path", options[:install_path])
FileUtils.mkdir_p(install_path)

# Copy files to installation directory
source_dir = File.expand_path('../', __FILE__)
FileUtils.cp_r(Dir["#{source_dir}/{Gemfile,src}"], install_path)

# Install gems in standalone mode
Dir.chdir(install_path) do
  system('bundle install --standalone')
end

# Create symlink to the executable
target_path = File.expand_path('../pctl', install_path)
source_path = File.expand_path('src/pctl', install_path)
FileUtils.ln_sf(source_path, target_path)

# Create or update shell configuration
shell_config = File.expand_path('~/.bashrc')
shell_config = File.expand_path('~/.zshrc') if ENV['SHELL'].include?('zsh')

puts "\nInstallation complete!"
puts "- Installed to: #{install_path}"
puts "- Executable symlinked to: #{target_path}"

puts "\nNote: Set DATABASS_DB_PATH environment variable to your database location:"
puts "export DATABASS_DB_PATH=/path/to/your/db/development.sqlite3"
