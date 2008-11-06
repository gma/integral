class AddVersionToApplicationTestRuns < ActiveRecord::Migration
  def self.up
    add_column :application_test_runs, :version, :string, :null => false
  end

  def self.down
    remove_column :application_test_runs, :version
  end
end
