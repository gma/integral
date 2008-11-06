class AddActiveToApplications < ActiveRecord::Migration
  def self.up
    add_column :applications, :active, :boolean, :default => true
  end

  def self.down
    remove_column :applications, :active
  end
end
