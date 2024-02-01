class Product::Operation::Create < ApplicationOperation
  step Subprocess(Parser::Operation::Request),
       In() => ->(ctx, **) { { entity: :product } },
       In() => [ :message ],
       Out() => { reply: :products_data }
  step :prepare_products_data
  step :create_product
  step Subprocess(Telegram::Operation::BuildProductsList)
  step :prepare_message

  private

  def prepare_products_data(ctx, products_data:, **)
    return unless products_data["products"]&.is_a?(Array)

    ctx[:product_names] = products_data["products"]
  end

  def create_product(ctx, model:, product_names:, **)
    ctx[:products] = product_names.map { |name| model.products.create(name: name) }
  end

  def prepare_message(ctx, **)
    ctx[:result_message] = "Ваш список покупок"
  end
end
