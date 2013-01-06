module ConcernedInheritance::ClassMethods

  def inherited_callbacks
    (self.singleton_class.ancestors + self.ancestors).select do |ancestor|
      ancestor.instance_variable_defined? :@inherited_callbacks
    end.map do |ancestor|
      ancestor.instance_variable_get :@inherited_callbacks
    end.flatten
  end

  private

  def inherited(subclass=nil, &block)
    if subclass.nil?
      define_inherited_callback(&block)
    else
      run_inherited_callbacks(subclass)
      super(subclass)
    end
  end

  def run_inherited_callbacks(subclass)
    self.inherited_callbacks.each do |callback|
      ConcernedInheritance::Delegator.new(self, subclass, callback)
    end
  end

end