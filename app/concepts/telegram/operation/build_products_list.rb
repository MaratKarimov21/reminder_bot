class Telegram::Operation::BuildProductsList < ApplicationOperation
  step Model(User, :find_by, :username), Out() => { model: :user }
  step :find_products
  step :build_reply_markup

  private

  def find_products(ctx, user:, **)
    ctx[:products] = user.products.order(created_at: :desc)
  end

  def build_reply_markup(ctx, products:, **)
    ctx[:reply_markup] = {
      inline_keyboard: products.map { |p| [{ text: prepared_text(p), callback_data: "toggle_in_cart:#{p.id}" }] }.push(clean_cart_button)
    }
  end

  def prepared_text(product)
    spaces = 35 - (product.name.length * 2)
    spaces = 0 if spaces < 0
    product.in_cart ? "✅#{" " * spaces}#{product.name}️" : "☑️#{" " * spaces}#{product.name}"
  end

  def clean_cart_button
    [{ text: "🗑 Очистить помеченное", callback_data: "clean_cart:_" }]
  end
end
