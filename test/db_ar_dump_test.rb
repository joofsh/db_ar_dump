require 'minitest_helper'

describe Foo do
  it 'can be created without arguments' do
    Foo.new.must_be_instance_of Foo
  end
end
