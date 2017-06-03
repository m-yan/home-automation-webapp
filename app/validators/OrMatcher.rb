class OrMatcher
  def initialize *vs; @vs = vs; end
  def === target; @vs.any?{|v| v === target }; end
end
def or_matcher *vs; OrMatcher.new *vs; end

