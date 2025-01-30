FactoryBot.define do
  factory :car do
    model { "Golf" }
    price { 35000 }
    association :brand
  end
end
