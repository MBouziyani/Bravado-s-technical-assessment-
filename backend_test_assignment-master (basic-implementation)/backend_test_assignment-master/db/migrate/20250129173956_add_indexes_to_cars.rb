class AddIndexesToCars < ActiveRecord::Migration[8.0]
  def change
    add_index :cars, :price unless index_exists?(:cars, :price)
    add_index :cars, :brand_id unless index_exists?(:cars, :brand_id)
    add_index :brands, :name unless index_exists?(:brands, :name)
  end
end