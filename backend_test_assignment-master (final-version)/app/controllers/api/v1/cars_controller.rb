class Api::V1::CarsController < ApplicationController
  require_dependency "car_finder_service"
  def index
    user = User.find_by(id: params[:user_id])
    return render json: { error: "User not found" }, status: :not_found unless user

    cars = CarFinderService.new(user, params).call
    render json: cars.as_json(only: [:id, :model_name, :price], include: { brand: { only: [:id, :name] } })
  end
end
