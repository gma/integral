class CreateApplications < ActiveRecord::Migration
  def self.up
    create_table :applications, :force => true do |t|
      t.string :name, :null => false
      t.string :path, :null => false
      t.boolean :active, :default => true
      t.timestamps
    end
  end

  def self.down
    drop_table :applications
  end
end
