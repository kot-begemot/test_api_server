require 'uri'

class Video < ActiveRecord::Base

  ALLOWED_PROTOCOLS = %w(http https ftp).freeze

  state_machine :state, initial: :new do
    # new: order was just created
    # paid: order was paid
    # expired: order pay time is expired
    state :new, :downloading, :downloaded, :processing, :finished

    event :download do
      transition :new => :downloading
    end
    event :process do
      transition :downloaded => :processing
    end
    event :ready do
      transition :downloading => :downloaded
      transition :processing => :finished
    end

    after_transition :new => :downloading, :do => :download_url
    after_transition :downloaded => :processing, :do => :start_conversion
  end

  attr_accessible :url
  
  validates_format_of :url, :with => URI::regexp(ALLOWED_PROTOCOLS)

  def download_and_convert
    download!
    process!
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
    seconds.times { |i| update_attribute :progress, i * percents_step }
  end
end
