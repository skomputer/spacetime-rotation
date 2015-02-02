# REQUIREMENTS:
# ffmpeg
# mencoder
# imagemagick
# ruby
# rmagick
# 
# USAGE:
# ruby spacetime-rotate-video.rb [horizontal|vertical] [VIDEO PATH] [START TIME (HH:MM:SS)]

orientation = ARGV[0]
slice_name = (orientation == 'horizontal' ? 'row' : 'col')
video_path = ARGV[1]
video_basename = File.basename(video_path).split('.')[0..-2].join('.')
output_filename = video_basename + "-spacetime-rotation-#{orientation}.mp4"
width, height = `ffmpeg -i #{video_path} 2>&1 | perl -lane 'print $1 if /(\\d+x\\d+),/'`.strip.split('x').map(&:to_i)
start_time = ARGV[2] or "00:00:00"
fps = 24
duration = (orientation == 'horizontal' ? height : width)/fps + 10

frames_dir = video_basename + "-frames"
output_frames_dir = video_basename + "#-{slice_name}s")
Dir.mkdir(frames_dir) unless File.directory?(frames_dir)
Dir.mkdir(output_frames_dir) unless File.directory?(output_frames_dir)

`ffmpeg -ss #{start_time} -t #{duration} -i #{video_path} -qscale:v 1 #{frames_dir}/image_%06d.jpg`

(1..(orientation == 'horizontal' ? height : width)).to_a.each_slice(10) do |slices|
  `ruby spacetime-rotation.rb #{orientation} #{frames_dir}/image_%06d.jpg #{output_frames_dir}/#{slice_name}-%04d.jpg #{slices.first} #{slices.last} 1`
end

`cd #{output_frames_dir}; ls -1v | grep jpg > files.txt`
`cd #{output_frames_dir}; mencoder -nosound -ovc lavc -lavcopts vcodec=mpeg4:vbitrate=16000000 -o #{output_filename} -mf type=jpeg:fps=24 mf://@files.txt`