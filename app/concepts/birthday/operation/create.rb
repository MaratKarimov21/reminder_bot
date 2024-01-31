class Birthday::Operation::Create < ApplicationOperation
  step Subprocess(Parser::Operation::Request),
       In() => ->(ctx, **) { { entity: :birthday } },
       In() => [ :message ],
       Out() => { reply: :birthday_data }
  step :prepare_birthday_data
  step :parse_date
  step :create_birthday
  step :prepare_message

  private

  def prepare_birthday_data(ctx, birthday_data:, **)
    return unless birthday_data["date"] && birthday_data["person"].presence
    birthday_data.tap do |data|
      data["date"] = data["date"].presence || Date.today.strftime("%d.%m.%Y")
    end
  end

  def parse_date(ctx, birthday_data:, **)
    ctx[:parsed_date] = Date.parse(birthday_data["date"])
  rescue
    nil
  end

  def create_birthday(ctx, model:, birthday_data:, parsed_date:, **)
    ctx[:birthday] = model.birthdays.create(person: birthday_data["person"], date: parsed_date)
  end


  def prepare_message(ctx, birthday:, **)
    ctx[:result_message] = "День рождения #{birthday.person} установлен на #{birthday.date}"
  end
end
