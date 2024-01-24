class ApplicationOperation < Trailblazer::Operation
  pass :prepare_debug
  
  def prepare_debug(ctx, **)
    ctx[:debug] = {} unless ctx[:debug]
  end

  def debug_step(ctx, **)
    debugger
  end

  def debugify(ctx, key, value)
    ctx[:debug][key] = value
  end
end