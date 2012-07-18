object @video
attributes :id

if @video.finished?
  attributes :state, :processed_at, :downloaded_at
else
  attributes :state
  attributes(:progress) if @video.downloading? || @video.processing?
end