class ApplicationOperation < Trailblazer::Operation
  pass :prepare_debug

  def self.step(*args, **kwargs)
    if kwargs.keys.any? { |k| k.class.to_s == "Trailblazer::Activity::DSL::Linear::VariableMapping::DSL::In" }
      kwargs.merge!(In() => [:debug])
    end

    if kwargs.keys.any? { |k| k.class.to_s == "Trailblazer::Activity::DSL::Linear::VariableMapping::DSL::Out" }
      kwargs.merge!(Out() => [:debug])
    end

    super(*args, **kwargs)
  end

  def self.pass(*args, **kwargs)
    if kwargs.keys.any? { |k| k.class.to_s == "Trailblazer::Activity::DSL::Linear::VariableMapping::DSL::In" }
      kwargs.merge!(In() => [:debug])
    end

    if kwargs.keys.any? { |k| k.class.to_s == "Trailblazer::Activity::DSL::Linear::VariableMapping::DSL::Out" }
      kwargs.merge!(Out() => [:debug])
    end

    super(*args, **kwargs)
  end
  
  def prepare_debug(ctx, **)
    ctx[:debug] ||= {}
  end

  def debug_step(ctx, **)
    debugger
  end

  def debugify(ctx, key, value)
    ctx[:debug].merge!(key => value)
  end
end
