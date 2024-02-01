class Reminder::Operation::Preprocess < ApplicationOperation
  NUMERAL_DIC = {
    1 => %w[один одну одного одним одной одними],
    2 => %w[два двух двух],
    3 => %w[три трёх трёх],
    4 => %w[четыре четырёх],
    5 => %w[пять пяти пяти],
    6 => %w[шесть шестей ],
    7 => %w[семь седьмей],
    8 => %w[восемь восьми],
    9 => %w[девять девяти],
    10 => %w[десять десяти],
    11 => %w[одиннадцать],
    12 => %w[двенадцать],
    13 => %w[тринадцать],
    14 => %w[четырнадцать],
    15 => %w[пятнадцать],
    16 => %w[шестнадцать],
    17 => %w[семнадцать],
    18 => %w[восемнадцать],
    19 => %w[девятнадцать],
    20 => %w[двадцать двадцать двадцать],
    30 => %w[тридцать],
    40 => %w[сорок],
    50 => %w[пятьдесят],
    60 => %w[шестьдесят],
    70 => %w[семьдесят],
    80 => %w[восемьдесят],
    90 => %w[девяносто],
    100 => %w[сто],
    200 => %w[двести],
    300 => %w[триста],
    400 => %w[четыреста],
    500 => %w[пятьсот],
    600 => %w[шестьсот],
    700 => %w[семьсот],
    800 => %w[восемьсот],
    900 => %w[девятьсот],
    1000 => %w[тысяча тысячи тысяч]
  }.flat_map { |k, vs| vs.map { |v| { v => k } } }.reduce(&:merge)

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
    [1, :second] => %w[секунд секунд секунды секунду],
    [1, :minute] => %w[минута минут минуты минуту мин],
    [30, :minutes] => [ "пол час", "пол часа", "пол часов", "пол часу", "полчаса" ],
    [1, :hour] => %w[час часа часов],
    [1, :day] => %w[день дня дней],
    [1, :week] => %w[неделя неделю недели недель ],
    [1, :month] => %w[месяц месяца месяцев],
    [1, :year] => %w[год года годов лет]
  }.flat_map { |k, vs| vs.map { |v| { v => k } } }.reduce(&:merge)

  RELATIVE_DAYS = {
    "сегодня" => Date.today,
    "завтра" => Date.tomorrow,
    "послезавтра" => Date.tomorrow.tomorrow
  }

  REGULAR_REMINDER_WORDS = %w[каждый каждая каждое каждые каждую каждых каждым каждыми каждыми]
  REGULAR_REMINDER_REGEX = /^.*(#{REGULAR_REMINDER_WORDS.join('|')})\s?([0-9]+)?\s?(#{TIME_RANGES.keys.join('|')}).*$/
  EVERY_REGEX = /\b(?:#{REGULAR_REMINDER_WORDS.join('|')})\b/i
  MONTHDAY_REGEX = /^.* ([0-9]{1,2}) (числа|числам|число|числе).*$/
  RELATIVE_TIME_REGEXP = /^.*(через|спустя|засеки|засечь|таймер|таймер на| на )\s?([0-9]+)?\s?(#{TIME_RANGES.keys.join('|')}).*$/

  step :prepare_string
  pass :replace_numerals
  pass :parse_relative_days
  pass :parse_regular_reminder
  pass :parse_weekdays
  pass :parse_relative_time
  pass :parse_monthday
  pass :add_explanation

  private

  def prepare_string(ctx, string:, **)
    ctx[:string] = string.downcase.tap { |it| debugify(ctx, :preprocess_orig_string, it) }
    ctx[:explanation] = ""
  end

  def replace_numerals(ctx, string:, **)
    first, *rest = string.split.find_all { |w| NUMERAL_DIC.key? w }
    return unless first
    num = [first, *rest].map { |w| NUMERAL_DIC[w] }.sum
    string.gsub!(first, num.to_s)
    rest.each { |w| string.gsub!(w, "") }
    string.squish!
  end

  def parse_relative_days(ctx, string:, **)
    relative_day = string.split.find { |w| RELATIVE_DAYS.key? w }

    ctx[:explanation].concat(" ", RELATIVE_DAYS[relative_day].strftime("%Y-%m-%d")) if relative_day
  end

  def parse_regular_reminder(ctx, string:, **)
    REGULAR_REMINDER_REGEX.match(string) do |m|
      num = m[2] ? m[2].to_i : 1
      unit = TIME_RANGES[m[3]][1]

      ctx[:explanation].concat(" ", "type: #{unit}, interval: #{num}")
    end
  end

  def parse_weekdays(ctx, string:, **)
    weekday = string.split.find { |w| WEEKDAYS_MAP.key? w }
    return unless weekday
    ctx[:explanation].concat(" ", Date.today.next_occurring(WEEKDAYS_MAP[weekday]).to_s)
    return unless EVERY_REGEX.match?(string)
    ctx[:explanation].concat(" ", "type: week")
  end
  
  def parse_relative_time(ctx, string:, **)
    RELATIVE_TIME_REGEXP.match(string) do |m|
      num = m[2] ? m[2].to_i : 1
      unit = TIME_RANGES[m[3]]
      datetime = (num * unit[0].send(unit[1])).from_now
      ctx[:explanation].concat(" ", datetime.strftime("%Y-%m-%d %H:%M"))
    end
  end

  def parse_monthday(ctx, string:, **)
    MONTHDAY_REGEX.match(string) do |m|
      this_month_occurrence = Date.today.at_beginning_of_month + m[1].to_i - 1
      next_month_occurrence = this_month_occurrence.next_month
      date = this_month_occurrence.past? ? next_month_occurrence : this_month_occurrence
      ctx[:explanation].concat(" ", date.to_s, " ", "type: monthday")
    end

  end

  def add_explanation(ctx, explanation: nil, string:, **)
    return unless explanation
    ctx[:string] = "#{string} (#{explanation})".tap { |it| debugify(ctx, :preprocessed_string, it) }
  end
end
