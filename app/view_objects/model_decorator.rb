class ModelDecorator
  attr_accessor :object

  def initialize(object)
    self.object = object
    yield(self) if block_given?
  end

end
