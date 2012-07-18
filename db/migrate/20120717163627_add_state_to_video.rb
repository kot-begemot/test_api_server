class AddStateToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :state, :string
  end
end
