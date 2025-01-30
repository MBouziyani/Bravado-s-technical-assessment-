class Api::V1::CarsController < ApplicationController
  include HTTParty

  BASE_RECOMMENDATION_URL = "https://bravado-images-production.s3.amazonaws.com/recomended_cars.json"

  def index
    user = User.includes(:preferred_brands).find_by(id: params[:user_id])
    return render json: { error: "User not found" }, status: :not_found unless user

    cars = Car.includes(:brand).where(nil)
    cars = cars.joins(:brand).where("brands.name ILIKE ?", "%#{params[:query]}%") if params[:query].present?
    cars = cars.where("price >= ?", params[:price_min]) if params[:price_min].present?
    cars = cars.where("price <= ?", params[:price_max]) if params[:price_max].present?

    recommended_cars = fetch_recommendations(user.id)
    sorted_cars = apply_labels_and_sort(cars, user, recommended_cars)

    paginated_cars = Kaminari.paginate_array(sorted_cars).page(params[:page] || 1).per(20)

    render json: paginated_cars.as_json(only: [:id, :model_name, :price], include: { brand: { only: [:id, :name] } })
  end

  private

  def fetch_recommendations(user_id)
    Rails.cache.fetch("recommendations_#{user_id}", expires_in: 24.hours) do
      response = HTTParty.get("#{BASE_RECOMMENDATION_URL}?user_id=#{user_id}")
      return {} unless response.success?

      JSON.parse(response.body).map { |r| [r["car_id"], r["rank_score"]] }.to_h
    rescue StandardError
      {}
    end
  end

  def apply_labels_and_sort(cars, user, recommended_cars)
    cars_with_labels = cars.map do |car|
      {
        car: car,
        rank_score: recommended_cars[car.id] || nil,
        label: determine_label(car, user)
      }
    end

    cars_with_labels
      .sort_by { |c| [label_priority(c[:label]), -c[:rank_score].to_f, c[:car].price] }
      .map { |c| c[:car] }
  end

  def determine_label(car, user)
    return "perfect_match" if user.preferred_brands.include?(car.brand) && user.preferred_price_range.include?(car.price)
    return "good_match" if user.preferred_brands.include?(car.brand)
    nil
  end

  def label_priority(label)
    { "perfect_match" => 0, "good_match" => 1, nil => 2 }[label]
  end
end
