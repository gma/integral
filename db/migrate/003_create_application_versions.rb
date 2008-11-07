class CreateApplicationVersions < ActiveRecord::Migration
  def self.up
    create_table :application_versions, :force => true do |t|
      t.integer :application_id, :null => false
      t.string :version, :null => false
    end
  end

  def self.down
    drop_table :application_versions
  end
end
