class Telegram::Operation::BuildTimesOfDaySettings < ApplicationOperation
  BUTTONS = [
    %w[07:00 12:00 17:00],
    %w[07:30 12:30 17:30],
    %w[08:00 13:00 18:00],
    %w[08:30 13:30 18:30],
    %w[09:00 14:00 19:00],
    %w[09:30 14:30 19:30],
    %w[10:00 15:00 20:00]
  ]


  step Model(User, :find_by, :username), Out() => { model: :user }
  step :build_reply_markup

  private

  def build_reply_markup(ctx, user:, **)
    ctx[:reply_markup] = {
      inline_keyboard: BUTTONS.map do |row|
        [
          { text: check_selected(row[0], user, :morning), callback_data: "set_morning_at:#{row[0]}" },
          { text: check_selected(row[1], user, :afternoon), callback_data: "set_afternoon_at:#{row[1]}" },
          { text: check_selected(row[2], user, :evening), callback_data: "set_evening_at:#{row[2]}" }
        ]
      end
    }
  end

  def check_selected(time, user, key)
    user.profile.send("#{key}_at").strftime("%H:%M") == time ? "✅ #{time}" : time
  end
end
