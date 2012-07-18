class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string :url
      t.datetime :processed_at
      t.datetime :downloaded_at

      t.timestamps
    end
  end
end
