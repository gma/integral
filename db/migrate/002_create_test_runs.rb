class CreateTestRuns < ActiveRecord::Migration
  def self.up
    create_table :test_runs, :force => true do |t|
      t.boolean :passed, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :test_runs
  end
end
