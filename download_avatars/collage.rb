require 'mini_magick'

AVATAR_DIR = 'avatars'
OUTPUT_FILE = 'collage.jpg'

avatar_files = Dir[File.join(AVATAR_DIR, '*')]

# Set grid dimensions
columns = Math.sqrt(avatar_files.size).ceil
rows = (avatar_files.size.to_f / columns).ceil

image_size = 100 # avatar size (px)
collage_width = columns * image_size
collage_height = rows * image_size

# Create a white canvas explicitly
collage = MiniMagick::Tool::Convert.new do |convert|
  convert.size "#{collage_width}x#{collage_height}"
  convert.xc 'white'
  convert << OUTPUT_FILE
end

collage_image = MiniMagick::Image.open(OUTPUT_FILE)

x, y = 0, 0
avatar_files.each do |avatar|
  image = MiniMagick::Image.open(avatar)
  image.resize "#{image_size}x#{image_size}^"
  image.gravity 'center'
  image.extent "#{image_size}x#{image_size}"

  collage_image = collage_image.composite(image) do |c|
    c.compose 'Over'
    c.geometry "+#{x}+#{y}"
  end

  x += image_size
  if x >= collage_width
    x = 0
    y += image_size
  end
end

collage_image.write OUTPUT_FILE
puts "✅ Collage created at #{OUTPUT_FILE}"
