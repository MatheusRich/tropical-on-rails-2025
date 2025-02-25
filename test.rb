# list the files in the parser/ directory and run the second to last one (alphabetically)

require 'fileutils'
ruby_files = Dir.glob("parser/*.rb").sort
system("ruby #{ruby_files[-2]}")
