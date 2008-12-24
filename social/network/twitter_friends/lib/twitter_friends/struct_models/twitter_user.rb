module TwitterUserShared
  module ClassMethods

  end

  def included base
    base.extend ClassMethods
  end
end
