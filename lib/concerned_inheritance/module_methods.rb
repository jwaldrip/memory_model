module ConcernedInheritance::ModuleMethods

  def inherited_callbacks
    @inherited_callbacks
  end

  def inherited(&block)
    define_inherited_callback(&block)
  end

end