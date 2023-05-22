# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Cart', type: :request do
  let(:json_response) { JSON.parse(response.body) }
  let(:line_items_expected_response) do
    [
      { "name": 'Peanut Butter', "price": '39.0', "collection": 'BEST-SELLERS', 'discounted_price': 37.05 },
      { "name": 'Cocoa', "price": '34.99', "collection": 'KETO', "discounted_price": 34.99 },
      { "name": 'Fruity', "price": '32', "collection": 'DEFAULT', "discounted_price": 30.4 }
    ].map(&:deep_stringify_keys)
  end

  let(:cart_hash_request) do
    {
      "cart": {
        "reference": '2d832fe0-6c96-4515-9be7-4c00983539c1',
        "lineItems": [
          { "name": 'Peanut Butter', "price": '39.0', "collection": 'BEST-SELLERS' },
          { "name": 'Cocoa', "price": '34.99', "collection": 'KETO' },
          { "name": 'Fruity', "price": '32', "collection": 'DEFAULT' }
        ]
      }
    }
  end

  let(:cart_hash_response) do
    {
      "cart": {
        "reference": '2d832fe0-6c96-4515-9be7-4c00983539c1',
        "lineItems": line_items_expected_response,
        "totalPrice": total_price
      }
    }.deep_transform_keys(&:to_s)
  end

  context 'when requesting a post to /cart with valid attributes' do
    let(:total_price) { 102.44 }

    before do
      post '/cart', params: cart_hash_request
    end

    it 'returns 200 status code' do
      expect(response).to have_http_status(200)
    end

    it 'returns the cart hash with the expected data' do
      expect(json_response).to eq(cart_hash_response)
    end

    it 'response hash must have the cart total price' do
      expect(json_response['cart']['totalPrice']).to eq(102.44)
    end

    it 'each cart items element in the response hash must have the discounted price key' do
      expect(json_response['cart']['lineItems']).to match_array(line_items_expected_response)
    end
  end

  context 'when a not permitted key is injected to the hash' do
    before do
      cart_hash_request[:cart][:lineItems][0][:other_key] = 'A non expected key'

      post '/cart', params: cart_hash_request
    end

    it 'returns 422 status code' do
      expect(response).to have_http_status(422)
    end

    it 'returns a hash with the error message' do
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq('found unpermitted parameter: :other_key')
    end
  end

  context 'when lineItems array is empty' do
    let(:line_items_expected_response) { [] }
    let(:total_price) { 0 }

    before do
      cart_hash_request[:cart][:lineItems] = []
      post '/cart', params: cart_hash_request
    end

    it 'returns 200 status code' do
      expect(response).to have_http_status(200)
    end

    it 'returns an empty array for lineItems' do
      expect(json_response['cart']['lineItems']).to eq []
    end

    it 'returns 0 for total price' do
      expect(json_response['cart']['totalPrice']).to eq total_price
    end
  end

  context 'when cart hash is not present' do
    before do
      cart_hash_request[:cart] = {}
      post '/cart', params: cart_hash_request
    end

    it 'returns 422 status code' do
      expect(response).to have_http_status(422)
    end

    it 'return errors' do
      expect(json_response['errors']).to eq(['cart hash is required', 'reference key is required', 'lineItems key is required'])
    end
  end

  context 'when lineItems key is not present' do
    before do
      cart_hash_request[:cart].delete(:lineItems)
      post '/cart', params: cart_hash_request
    end

    it 'returns 422 status code' do
      expect(response).to have_http_status(422)
    end

    it 'return an error' do
      expect(json_response['errors']).to eq(['lineItems key is required'])
    end
  end

  context 'when reference key is not present' do
    before do
      cart_hash_request[:cart].delete(:reference)
      post '/cart', params: cart_hash_request
    end

    it 'returns 422 status code' do
      expect(response).to have_http_status(422)
    end

    it 'return an error' do
      expect(json_response['errors']).to eq(['reference key is required'])
    end
  end
end
