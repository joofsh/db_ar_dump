require 'db_ar_dump'
require 'minitest/autorun'

describe DbArDump do
  it 'can be created without arguments' do
    DbArDump.foo.must_equal 'hi'
  end
end
