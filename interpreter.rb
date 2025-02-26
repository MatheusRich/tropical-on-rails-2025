# list the files in the interpreter/ directory and run the second to last one (alphabetically)

require 'fileutils'
ruby_files = Dir.glob("interpreter/*.rb").sort
system("TEST=false ruby #{ruby_files[-2]}")
