class Telegram::Operation::BuildBirthdaysList < ApplicationOperation
  step Model(User, :find_by, :username), Out() => { model: :user }
  step :find_birthdays
  step :build_reply_markup

  private

  def find_birthdays(ctx, user:, **)
    ctx[:birthdays] = user.birthdays
  end

  def build_reply_markup(ctx, birthdays:, **)
    ctx[:reply_markup] = {
      inline_keyboard: birthdays.map do |b|
        [{ text: "#{b.person} #{b.date.strftime("%d.%m.%Y")}", callback_data: "view_birthday:#{b.id}" }]
      end
    }
  end
end
