class CreateApplicationTestRuns < ActiveRecord::Migration
  def self.up
    create_table :application_test_runs, :force => true do |t|
      t.integer :test_run_id
      t.integer :application_id
    end
  end

  def self.down
    drop_table :application_test_runs
  end
end
