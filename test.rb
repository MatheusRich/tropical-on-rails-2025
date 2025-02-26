require 'fileutils'
ruby_files = Dir.glob("interpreter/*.rb").sort.reject { it.include?("helper") }

ruby_files.each do |file|
  puts "Running #{file}"
  system("ruby #{file}")
end
