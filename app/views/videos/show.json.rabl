object @video
attributes :id

if @video.finished?
  attributes :finished_at, :resolution, :fps, :video_info, :audio_info
  node do |v|
    { duration:  Time.at(v.duration).utc.strftime("%T") }
  end
else
  attributes :state
  attributes(:progress) if @video.downloading? || @video.processing? || @video.storing?
end