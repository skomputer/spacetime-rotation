require 'rmagick'

orientation = ARGV[0]
start = Time.now
start_frame = ARGV[5].to_i
slices = (ARGV[3].to_i..ARGV[4].to_i).to_a
data = {}

slices.each do |z|
  data[z] = []
end

infile = ARGV[1] % (start_frame)
image = Magick::Image.read(infile)[0]
width = image.columns
height = image.rows

(orientation == 'horizontal' ? height : width).times do |n|
  infile = ARGV[1] % (n+start_frame)
  next unless File.exist?(infile)
  image = Magick::Image.read(infile)[0]

  slices.each do |z|
    data[z] << orientation == 'horizontal' ? image.dispatch(0, z, width, 1, "RGB") : image.dispatch(z, 0, 1, height, "RGB").each_slice(3).to_a
    print "collecting #{orientation == 'horizontal' ? 'row' : 'column'} #{z} data from #{infile}\r"
  end
end

slices.each do |z|
  outfile = ARGV[2] % z
  print "\nwriting #{orientation == 'horizontal' ? 'row' : 'column'} #{z} data to #{outfile}"
  output = Magick::Image.constitute(width, data[z].count, "RGB", orientation == 'horizontal' ? data[z].flatten : data[z].transpose.flatten)
  output.write(outfile)
end

print "\n#{Time.now - start}s\n"