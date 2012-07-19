require 'uri'

class Video < ActiveRecord::Base

  ALLOWED_PROTOCOLS = %w(http https ftp).freeze
  CONVERSION_FORMAT = 'AVI'.freeze

  state_machine :state, initial: :new do
    # new: order was just created
    # paid: order was paid
    # expired: order pay time is expired
    state :new, :downloading, :downloaded, :processing, :processed, :storing, :finished

    event :download do
      transition :new => :downloading
    end
    event :process do
      transition :downloaded => :processing
    end
    event :store do
      transition :processed => :storing
    end
    event :ready do
      transition :downloading => :downloaded
      transition :processing => :processed
      transition :storing => :finished
    end

    after_transition :new => :downloading, :do => :download_url
    after_transition :downloaded => :processing, :do => :start_conversion
    after_transition :processed => :storing, :do => :move_to_storage
    after_transition :storing => :finished, :do => :finish_emulation
  end

  attr_accessible :url
  
  validates_format_of :url, :with => URI::regexp(ALLOWED_PROTOCOLS)

  def convert!
    download!
    process!
    store!
  end

  protected

  ###
  # Opens url and saves it as temporary file
  def download_url
    process_emulation 10
    clear_progress_bar
    self.downloaded_at = Time.now.utc
    save! && ready!
  end

  ##
  # Initialize conversion process
  def start_conversion
    process_emulation 15
    clear_progress_bar
    self.processed_at = Time.now.utc
    save! && ready!
  end

  ###
  # Relocate converted file to specific place
  def move_to_storage
    process_emulation 5
    clear_progress_bar
    self.finished_at = Time.now.utc
    save! && ready!
  end

  def clear_progress_bar
    self.progress = 0
  end

  def clear_progress_bar!
    update_attribute :progress, 0
  end

  ###
  # Emulate task performance
  def process_emulation seconds
    full_progress_bar = 100
    percents_step = full_progress_bar/seconds
    seconds.times do |i|
      update_attribute :progress, i * percents_step
      sleep(1)
    end
  end

  ###
  # Emulate technical data
  def finish_emulation
    self.duration = 1000 + Random.rand(2000)
    self.resolution = "800x600"
    self.fps = 20 + Random.rand(10)
    self.video_info = "#{resolution} (2.37:1), #{fps} fps, XviD build 50 ~1760 kbps avg, 0.34 bit/pixel"
    self.audio_info = "48 kHz, AC3 Dolby Digital, 3/2 (L,C,R,l,r) + LFE ch, ~384 kbps"
    save!
  end
end
