# frozen_string_literal: true

# This class validates the presence and format of the keys we need to calculate discounts as expected.
# Calutates the discount price and returns the hash with the discounted_price key for each item element and the key total_price.
class Cart
  include ActiveModel::Validations
  # This hash has functions as key to find the appropriate discount rate.
  # Depending on the state of the cart (e.g how many items there are), we will pick a different discount.
  DISCOUNT_PROGRESSION = {
    ->(count) { count <= 1 } => 0.0,
    ->(count) { count == 2 } => 0.05,
    ->(count) { count == 3 } => 0.10,
    ->(count) { count == 4 } => 0.20,
    ->(count) { count >= 5 } => 0.25
  }

  validate :validate_line_items

  def initialize(line_items = [])
    @line_items = line_items.map(&:to_h)
  end

  def calculate_cart_discount
    items = calculate_discounts

    {
      line_items: items,
      total_price: items.map { |item| item[:discounted_price] }.sum.round(2)
    }
  end

  private

  def validate_line_items
    @line_items.each do |item|
      if item[:name].blank?
        errors.add(:base, "Name can't be blank")
      elsif !item[:name].is_a?(String)
        errors.add(:base, 'Name must be a string')
      end

      if item[:price].blank?
        errors.add(:base, "Price can't be blank")
      else
        begin
          float_price = Float(item[:price])
          if float_price.negative?
            errors.add(:base, "Price can't be negative")
          end
        rescue ArgumentError
          errors.add(:base, 'Price must be a number')
        end
      end

      if item[:collection].blank?
        errors.add(:base, "Collection can't be blank")
      elsif !item[:collection].is_a?(String)
        errors.add(:base, 'Collection must be a string')
      end
    end
  end

  def calculate_discounts
    @line_items.dup.map do |item|
      item[:discounted_price] = if eligible_discount?(item)
                                  (item[:price].to_f * (1.0 - discount_percentage)).round(2)
                                else
                                  item[:price].to_f
                                end
      item
    end
  end

  # This method is used to find the discount percentage we must apply, regarding
  # the discountable_items_count output (quantity of items in the cart).
  def discount_percentage
    DISCOUNT_PROGRESSION.find { |condition, _| condition.call(discountable_items_count) }[1]
  end

  def discountable_items_count
    @line_items.count { |item| eligible_discount?(item) }
  end

  def eligible_discount?(item)
    item[:collection] != 'KETO'
  end
end
