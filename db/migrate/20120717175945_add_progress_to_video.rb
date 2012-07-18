class AddProgressToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :progress, :double
  end
end
