class EnsureEventsApprovedColumn < ActiveRecord::Migration[8.0]
  def up
    unless column_exists?(:events, :approved)
      add_column :events, :approved, :boolean, default: false, null: false
    end

    change_column_default :events, :approved, false
    update "UPDATE events SET approved = FALSE WHERE approved IS NULL"
    change_column_null :events, :approved, false, false

    add_index :events, :approved unless index_exists?(:events, :approved)
  end

  def down
    remove_index :events, :approved if index_exists?(:events, :approved)
  end
end
