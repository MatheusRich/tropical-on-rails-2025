require 'fileutils'
ruby_files = Dir.glob("parser/*.rb").sort.reject { it.include?("helper") }

ruby_files.each do |file|
  puts "Running #{file}"
  system("ruby #{file}")
end
