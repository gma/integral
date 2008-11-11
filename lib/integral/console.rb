# Loaded by script/console.

Integral::Database.connect

# You should only use this function when you first install integral, to give
# yourself a successful test run for your existing applications. You should
# use the app:add thor task to add all relevant applications before you
# run it.
#
def create_test_run_from_live_versions(success)
  run = TestRun.new
  run.application_versions << ApplicationVersion.check_current_versions(:live)
  run.passed = success
  run.save!
end