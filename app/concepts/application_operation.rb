class ApplicationOperation < Trailblazer::Operation
  pass :prepare_debug
  
  def prepare_debug(ctx, **)
    ctx[:debug] = {} unless ctx[:debug]
  end

  def debug(ctx, **)
    debugger
  end
end