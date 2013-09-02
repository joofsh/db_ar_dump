class Foo

  def initialize params = {}
    params.each do |k, v|
      instance_variable_set("@#{k}", v)
    end
  end
end

p Foo.new
f = Foo.new(name: 'hi', game: 'oh my')
p f.name
