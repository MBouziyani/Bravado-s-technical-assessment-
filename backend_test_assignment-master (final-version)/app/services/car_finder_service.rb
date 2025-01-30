class CarFinderService
  def initialize(user, params)
    @user = user
    @params = params
  end

  def call
    cars = filter_cars(Car.includes(:brand))

    recommended_cars = fetch_recommendations

    cars = apply_labels_and_sort(cars, recommended_cars) 
    cars.page(@params[:page] || 1).per(20)
  end

  private

  def filter_cars(cars)
    if @params[:price_min].present? && @params[:price_max].present?
      cars = cars.where(price: @params[:price_min].to_i..@params[:price_max].to_i)
    end

    if @params[:query].present?
      cars = cars.joins(:brand).where("brands.name ILIKE ?", "%#{@params[:query]}%")
    end

    cars
  end

  def fetch_recommendations
    Rails.cache.fetch("recommendations_#{@user.id}", expires_in: 24.hours) do
      begin
        response = HTTParty.get("https://bravado-images-production.s3.amazonaws.com/recomended_cars.json?user_id=#{@user.id}")
        return {} unless response.success?
        JSON.parse(response.body).map { |r| [r["car_id"], r["rank_score"]] }.to_h
      rescue StandardError
        {}
      end
    end
  end

  def apply_labels_and_sort(cars, recommended_cars)
    preferred_brands = @user.preferred_brands.pluck(:name)
    price_range = @user.preferred_price_range
    price_min, price_max = price_range.first, price_range.last
  
 
    cars
      .left_joins(:brand)
      .select(
        "cars.*, #{recommended_cars_sql} AS rank_score",
        "CASE
          WHEN brands.name IN ('#{preferred_brands.join("', '")}') AND cars.price BETWEEN #{price_min} AND #{price_max} THEN 'perfect_match'
          WHEN brands.name IN ('#{preferred_brands.join("', '")}') THEN 'good_match'
          ELSE NULL
        END AS label"
      )
      .order(Arel.sql("label ASC, rank_score DESC, price ASC"))
  end
  
  

  def recommended_cars_sql
    recommendations = fetch_recommendations

    return "0" if recommendations.empty? 

    "CASE " + recommendations.map { |car_id, score| "WHEN cars.id = #{car_id} THEN #{score}" }.join(" ") + " ELSE 0 END"
  end
end
