require 'fileutils'
ruby_files = Dir.glob("parser/*.rb").sort.reject { it.include?("helper") }
