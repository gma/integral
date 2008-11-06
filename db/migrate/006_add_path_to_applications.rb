class AddPathToApplications < ActiveRecord::Migration
  def self.up
    add_column :applications, :path, :string, :null => false
  end

  def self.down
    remove_column :applications, :path
  end
end
