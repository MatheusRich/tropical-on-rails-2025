require 'mini_magick'

AVATAR_DIR = 'avatars'
OUTPUT_FILE = 'collage.jpg'
TARGET_ASPECT = 16.0 / 9.0
IMAGE_SIZE = 64

avatar_files = Dir[File.join(AVATAR_DIR, '*')]
count = avatar_files.size

# Find columns and rows to closely match TARGET_ASPECT
best_columns = (1..count).min_by do |cols|
  rows = (count.to_f / cols).ceil
  aspect = (cols * IMAGE_SIZE).to_f / (rows * IMAGE_SIZE)
  (aspect - TARGET_ASPECT).abs
end

columns = best_columns
rows = (count.to_f / columns).ceil

collage_width = columns * IMAGE_SIZE
collage_height = rows * IMAGE_SIZE

# Create blank canvas
MiniMagick::Tool::Convert.new do |convert|
  convert.size "#{collage_width}x#{collage_height}"
  convert.xc 'white'
  convert << OUTPUT_FILE
end

collage_image = MiniMagick::Image.open(OUTPUT_FILE)

x, y = 0, 0
avatar_files.each_with_index do |avatar, index|
  image = MiniMagick::Image.open(avatar)
  image.resize "#{IMAGE_SIZE}x#{IMAGE_SIZE}^"
  image.gravity 'center'
  image.extent "#{IMAGE_SIZE}x#{IMAGE_SIZE}"

  collage_image = collage_image.composite(image) do |c|
    c.compose 'Over'
    c.geometry "+#{x}+#{y}"
  end

  x += IMAGE_SIZE
  if (index + 1) % columns == 0
    x = 0
    y += IMAGE_SIZE
  end
end

collage_image.write OUTPUT_FILE

actual_aspect = collage_width.to_f / collage_height
puts "✅ Collage created at #{OUTPUT_FILE}"
puts "Size: #{collage_width}x#{collage_height}px (#{columns} columns x #{rows} rows)"
puts "Aspect ratio: #{actual_aspect.round(2)} (target #{TARGET_ASPECT.round(2)})"
