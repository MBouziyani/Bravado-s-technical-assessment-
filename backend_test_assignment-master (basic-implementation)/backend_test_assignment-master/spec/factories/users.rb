FactoryBot.define do
  factory :user do
    email { "test@example.com" }
    preferred_price_range { (30000..50000) }
  end
end
