class AddConversionFieldsToEvents < ActiveRecord::Migration[8.0]
  def change
    add_column :events, :ticket_url, :string
    add_column :events, :capacity, :integer
  end
end
