class CartsController < ApplicationController
  before_action :check_cart_params, only: :create

  def create
    cart = Cart.new(cart_params[:lineItems])

    if cart.valid?
      format_response(cart)
    else
      render json: { errors: cart.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActionController::UnpermittedParameters => e
    render json: { error: e }, status: :unprocessable_entity
  end

  private

  def cart_params
    params.require(:cart).permit(:reference, lineItems: %i[name price collection])
  end

  def check_cart_params
    errors = []
    errors << 'cart hash is required' unless params[:cart].present?
    errors << 'reference key is required' if params.dig(:cart, :reference).blank?
    errors << 'lineItems key is required' if params.dig(:cart, :lineItems).blank?

    return if errors.empty?

    render json: { errors: errors }, status: :unprocessable_entity
  end

  def format_response(cart)
    cart_with_discount = cart.calculate_cart_discount
    render json: {
      cart: {
        reference: cart_params[:reference],
        lineItems: cart_with_discount[:line_items],
        totalPrice: cart_with_discount[:total_price]
      }.deep_stringify_keys
    }
  end

  def render_error(error_message)
    render json: { error: error_message }, status: :unprocessable_entity
  end
end
