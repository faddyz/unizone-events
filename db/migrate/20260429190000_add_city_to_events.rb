class AddCityToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :city, :string, null: false, default: "İstanbul"
    add_index :events, :city
  end
end
