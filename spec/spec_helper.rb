# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "releasetool"

RSpec.configure do |config|
  config.around quietly: true do |example|
    original_stderr = $stderr
    original_stdout = $stdout
    # Redirect stderr and stdout
    $stderr = File.open(File::NULL, "w")
    $stdout = File.open(File::NULL, "w")
    example.run
    $stderr = original_stderr
    $stdout = original_stdout
  end
end
