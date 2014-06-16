require 'spec_helper'

describe Releasetool do
  it 'should have a version number' do
    Releasetool::VERSION.should_not be_nil
  end

end
