class Reminder::Operation::Preprocess < Trailblazer::Operation
  WEEKDAYS_MAP = {
    monday: %w[понедельник понедельника пн],
    tuesday: %w[вторник вторника вт],
    wednesday: %w[среда среду ср],
    thursday: %w[четверг четверга чт],
    friday: %w[пятница пятницу пт],
    saturday: %w[суббота субботу сб],
    sunday: %w[воскресенье воскресенья вс]
  }.flat_map { |k, vs| vs.map { |v| { v => k } } }.reduce(&:merge)

  TIME_RANGES = {
    1.second => %w[секунд секунд секунды секунду сек],
    1.minute => %w[минута минут минуты минуту мин],
    30.minutes => [ "пол час", "пол часа", "пол часов", "пол часу" ],
    1.hour => %w[час часа часов ч],
    1.day => %w[день дня дней дн],
    1.week => %w[неделя неделю недели недель нед],
    1.month => %w[месяц месяца месяцев мес],
    1.year => %w[год года годов лет г]
  }.flat_map { |k, vs| vs.map { |v| { v => k } } }.reduce(&:merge)

  RELATIVE_TIME_REGEXP = /^.*(через|спустя|засеки|засечь)\s?([0-9]+)?\s?(#{TIME_RANGES.keys.join('|')}).*$/

  step :prepare_string
  step :parse_weekdays
  step :parse_relative_time
  step :add_explanation

  private

  def prepare_string(ctx, string:, **)
    ctx[:string] = string.downcase
  end

  def parse_weekdays(ctx, string:, **)
    weekday = string.split.find { |w| WEEKDAYS_MAP.key? w }

    ctx[:explanation] = Date.today.next_occurring(WEEKDAYS_MAP[weekday]) if weekday
    true
  end
  
  def parse_relative_time(ctx, string:, **)
    RELATIVE_TIME_REGEXP.match(string) do |m|
      num = m[2] ? m[2].to_i : 1
      unit = TIME_RANGES[m[3]]
      datetime = (num * unit).from_now
      ctx[:explanation] = datetime.strftime("%Y-%m-%d %H:%M")
    end
    true
  end

  def add_explanation(ctx, explanation: nil, string:, **)
    return true unless explanation
    puts "#{string} (#{explanation})"
    ctx[:string] = "#{string} (#{explanation})"
    true
  end
end
