require 'mini_magick'

AVATAR_DIR = 'avatars'
OUTPUT_FILE = 'collage.png'
TARGET_ASPECT = 16.0 / 9.0
IMAGE_SIZE = 420

avatar_files = Dir[File.join(AVATAR_DIR, '*')]
count = avatar_files.size

# Compute best columns/rows to approximate 16:9 aspect
best_columns = (1..count).min_by do |cols|
  rows = (count.to_f / cols).ceil
  aspect = (cols * IMAGE_SIZE).to_f / (rows * IMAGE_SIZE)
  (aspect - TARGET_ASPECT).abs
end

columns = best_columns
rows = (count.to_f / columns).ceil

collage_width = columns * IMAGE_SIZE
collage_height = rows * IMAGE_SIZE

montage = MiniMagick::Tool::Montage.new
avatar_files.each { |f| montage << f }

# Correct resize and crop syntax: first resize, then crop if necessary
montage.geometry "#{IMAGE_SIZE}x#{IMAGE_SIZE}+0+0"
montage.gravity 'center'
montage.resize "#{IMAGE_SIZE}x#{IMAGE_SIZE}^"
montage.extent "#{IMAGE_SIZE}x#{IMAGE_SIZE}"
montage.tile "#{columns}x#{rows}"
montage.background 'none'
# montage.background '#fbfbfb'
montage << OUTPUT_FILE

montage.call

actual_aspect = collage_width.to_f / collage_height
puts "✅ Collage created at #{OUTPUT_FILE}"
puts "Size: #{collage_width}x#{collage_height}px (#{columns} columns x #{rows} rows)"
puts "Aspect ratio: #{actual_aspect.round(2)} (target #{TARGET_ASPECT.round(2)})"
