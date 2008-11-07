class CreateApplicationVersionTestRuns < ActiveRecord::Migration
  def self.up
    create_table :application_version_test_runs, :force => true do |t|
      t.integer :application_version_id, :null => false
      t.string :test_run_id, :null => false
    end
  end

  def self.down
    drop_table :application_version_test_runs
  end
end
