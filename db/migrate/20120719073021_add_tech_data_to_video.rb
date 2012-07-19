class AddTechDataToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :finished_at, :datetime
    add_column :videos, :duration, :time
    add_column :videos, :resolution, :string
    add_column :videos, :fps, :double
    add_column :videos, :video_info, :string
    add_column :videos, :audio_info, :string
  end
end
