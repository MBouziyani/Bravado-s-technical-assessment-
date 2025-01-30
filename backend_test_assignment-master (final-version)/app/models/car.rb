class Car < ApplicationRecord
  belongs_to :brand

  validates :model, presence: true
  validates :price, presence: true
end
