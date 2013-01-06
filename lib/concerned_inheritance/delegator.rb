class ConcernedInheritance::Delegator < BasicObject

  attr_reader :baseclass, :subclass

  def initialize(baseclass, subclass, callback)
    @baseclass = baseclass
    @subclass  = subclass
    if callback.not_a?(::Proc)
      raise ::ArgumentError, "#{callback} must be a proc"
    elsif (-1..0).cover?(callback.arity)
      instance_eval(&callback)
    else
      raise ::ArgumentError, "#{callback} must have an arity of 0, got #{callback.arity}"
    end
  end

  def method_missing(m, *args, &block)
    subclass.send m, *args, &block
  end

end