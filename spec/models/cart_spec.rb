# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Cart' do
  let(:attributes) { items }

  subject(:cart) { Cart.new(attributes) }

  let(:banana_cake_item) { { 'name': 'Banana Cake', 'price': '34.99', 'collection': 'BEST-SELLERS' } }
  let(:cocoa_item) { { 'name': 'Cocoa', 'price': '34.99', 'collection': 'KETO' } }
  let(:peanut_butter_item) { { 'name': 'Peanut Butter', 'price': '39.0', 'collection': 'BEST-SELLERS' } }
  let(:banana_cake_item_discounted) do
    (banana_cake_item[:price].to_f - banana_cake_item[:price].to_f * expected_discount).round(2)
  end
  let(:peanut_butter_item_discount) do
    (peanut_butter_item[:price].to_f - peanut_butter_item[:price].to_f * expected_discount).round(2)
  end
  let(:items_result) do
    {
      'line_items': result,
      'total_price': total_price.to_f
    }
  end

  describe '#calculate_cart_discount' do
    context 'when buying non discountable boxes' do
      let(:total_price) { banana_cake_item_discounted + peanut_butter_item_discount + cocoa_item[:price].to_f }
      let(:expected_discount) { 0.05 }
      let(:items) do
        [
          banana_cake_item,
          cocoa_item,
          peanut_butter_item
        ]
      end

      let(:result) do
        [
          banana_cake_item.dup.merge({ "discounted_price": banana_cake_item_discounted }),
          peanut_butter_item.dup.merge({ "discounted_price": peanut_butter_item_discount }),
          cocoa_item.dup.merge({ "discounted_price": cocoa_item[:price].to_f.round(2) })
        ]
      end

      it 'apply the discount considering the number of boxes in the discount list (3 boxes, but only 2 are from discount list)' do
        expect(cart.calculate_cart_discount[:line_items]).to match_array(items_result[:line_items])
        expect(cart.calculate_cart_discount[:total_price]).to eq(total_price)
      end
    end

    context 'when buying 1 box' do
      let(:total_price) { banana_cake_item[:price] }
      let(:items) do
        [
          banana_cake_item
        ]
      end

      let(:result) do
        [
          banana_cake_item.dup.merge({ 'discounted_price': banana_cake_item[:price].to_f })
        ]
      end

      it 'does not apply discont' do
        expect(cart.calculate_cart_discount).to include(items_result)
      end
    end

    context 'when buying 2 boxes' do
      let(:total_price) { 70.29 }
      let(:expected_discount) { 0.05 }
      let(:items) do
        [
          banana_cake_item,
          peanut_butter_item
        ]
      end

      let(:result) do
        [
          banana_cake_item.dup.merge({ 'discounted_price': banana_cake_item_discounted }),
          peanut_butter_item.dup.merge({ 'discounted_price': peanut_butter_item_discount })
        ]
      end

      it 'apply 5% of discount' do
        expect(cart.calculate_cart_discount).to include(items_result)
      end
    end

    context 'when buying 3 boxes' do
      let(:total_price) { (banana_cake_item_discounted * 2) + peanut_butter_item_discount }
      let(:expected_discount) { 0.10 }
      let(:items) do
        [
          banana_cake_item,
          banana_cake_item,
          peanut_butter_item
        ]
      end

      let(:result) do
        [
          banana_cake_item.dup.merge({ 'discounted_price': banana_cake_item_discounted }),
          banana_cake_item.dup.merge({ 'discounted_price': banana_cake_item_discounted }),
          peanut_butter_item.dup.merge({ 'discounted_price': peanut_butter_item_discount })
        ]
      end

      it 'apply 10% of discount' do
        expect(cart.calculate_cart_discount).to include(items_result)
      end
    end

    context 'when buying 4 boxes' do
      let(:total_price) { (banana_cake_item_discounted * 2) + (peanut_butter_item_discount * 2) }
      let(:expected_discount) { 0.20 }
      let(:items) do
        [
          banana_cake_item,
          banana_cake_item,
          peanut_butter_item,
          peanut_butter_item
        ]
      end

      let(:result) do
        [
          banana_cake_item.dup.merge({ 'discounted_price': banana_cake_item_discounted }),
          banana_cake_item.dup.merge({ 'discounted_price': banana_cake_item_discounted }),
          peanut_butter_item.dup.merge({ 'discounted_price': peanut_butter_item_discount }),
          peanut_butter_item.dup.merge({ 'discounted_price': peanut_butter_item_discount })
        ]
      end

      it 'apply 20% of discount' do
        expect(cart.calculate_cart_discount).to include(items_result)
      end
    end

    context 'when buying 5 boxes or more' do
      let(:total_price) { (banana_cake_item_discounted * 2) + (peanut_butter_item_discount * 3) }
      let(:expected_discount) { 0.25 }
      let(:items) do
        [
          banana_cake_item,
          banana_cake_item,
          peanut_butter_item,
          peanut_butter_item,
          peanut_butter_item
        ]
      end

      let(:result) do
        [
          banana_cake_item.dup.merge({ "discounted_price": banana_cake_item_discounted }),
          banana_cake_item.dup.merge({ "discounted_price": banana_cake_item_discounted }),
          peanut_butter_item.dup.merge({ "discounted_price": peanut_butter_item_discount }),
          peanut_butter_item.dup.merge({ "discounted_price": peanut_butter_item_discount }),
          peanut_butter_item.dup.merge({ "discounted_price": peanut_butter_item_discount })
        ]
      end

      it 'apply 25% of discount' do
        expect(cart.calculate_cart_discount).to include(items_result)
      end
    end

    context 'when buying more than 5 boxes' do
      let(:total_price) { (banana_cake_item_discounted * 2) + (peanut_butter_item_discount * 4) }
      let(:expected_discount) { 0.25 }
      let(:items) do
        [
          banana_cake_item,
          banana_cake_item,
          peanut_butter_item,
          peanut_butter_item,
          peanut_butter_item,
          peanut_butter_item
        ]
      end

      let(:result) do
        [
          banana_cake_item.dup.merge({ "discounted_price": banana_cake_item_discounted }),
          banana_cake_item.dup.merge({ "discounted_price": banana_cake_item_discounted }),
          peanut_butter_item.dup.merge({ "discounted_price": peanut_butter_item_discount }),
          peanut_butter_item.dup.merge({ "discounted_price": peanut_butter_item_discount }),
          peanut_butter_item.dup.merge({ "discounted_price": peanut_butter_item_discount }),
          peanut_butter_item.dup.merge({ "discounted_price": peanut_butter_item_discount })
        ]
      end

      it 'apply 25% of discount' do
        expect(cart.calculate_cart_discount).to include(items_result)
      end
    end
  end

  describe 'validations' do
    let(:items) { [banana_cake_item] }

    describe 'lineItem name key' do
      context 'when name key is not present' do
        before do
          banana_cake_item.delete(:name)
        end

        it 'returns an error' do
          cart.valid?
          expect(cart.errors[:base]).to include("Name can't be blank")
        end
      end

      context 'when name key is not a string' do
        before do
          banana_cake_item[:name] = 2.to_f
        end

        it 'returns an error' do
          cart.valid?
          expect(cart.errors[:base]).to include('Name must be a string')
        end
      end
    end

    describe 'lineItem price key' do
      context 'when price key is not present' do
        before do
          banana_cake_item.delete(:price)
        end

        it 'returns an error' do
          cart.valid?
          expect(cart.errors[:base]).to include("Price can't be blank")
        end
      end

      context 'when price key is not a number' do
        before do
          banana_cake_item[:price] = 'price'
        end

        it 'returns an error' do
          cart.valid?
          expect(cart.errors[:base]).to include('Price must be a number')
        end
      end

      context 'when price key is a negative number' do
        before do
          banana_cake_item[:price] = -4
        end

        it 'returns an error' do
          cart.valid?
          expect(cart.errors[:base]).to include("Price can't be negative")
        end
      end
    end

    describe 'lineItem collection key' do
      context 'when collection key is not present' do
        before do
          banana_cake_item.delete(:collection)
        end

        it 'returns an error' do
          cart.valid?
          expect(cart.errors[:base]).to include("Collection can't be blank")
        end
      end

      context 'when collection key is not a string' do
        before do
          banana_cake_item[:collection] = 2.to_f
        end

        it 'returns an error' do
          cart.valid?
          expect(cart.errors[:base]).to include('Collection must be a string')
        end
      end
    end
  end
end
