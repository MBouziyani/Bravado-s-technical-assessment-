require "test_helper"

class Api::V1::CarsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "test@example.com", preferred_price_range: 30000..50000)
    @brand = Brand.create!(name: "Volkswagen")
    @car = Car.create!(model_name: "Golf", price: 35000, brand: @brand)
    UserPreferredBrand.create!(user: @user, brand: @brand)
  end

  test "should return a successful response" do
    get api_v1_cars_url, params: { user_id: @user.id }, as: :json
    assert_response :success
  end

  test "should return 404 if user not found" do
    get api_v1_cars_url, params: { user_id: 9999 }, as: :json
    assert_response :not_found
  end

  test "should filter cars by price range" do
    get api_v1_cars_url, params: { user_id: @user.id, price_min: 36000 }, as: :json
    json_response = JSON.parse(response.body)

    assert json_response.none? { |car| car["price"] < 36000 }, "Returned cars below the price range"
  end

  test "should filter cars by brand name" do
    get api_v1_cars_url, params: { user_id: @user.id, query: "Volkswagen" }, as: :json
    json_response = JSON.parse(response.body)

    assert json_response.all? { |car| car["brand"]["name"] == "Volkswagen" }, "Returned cars not matching brand query"
  end
end
