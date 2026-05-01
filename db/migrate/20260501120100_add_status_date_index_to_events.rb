class AddStatusDateIndexToEvents < ActiveRecord::Migration[8.0]
  def change
    unless index_exists?(:events, [ :status, :date ], name: "index_events_on_status_and_date")
      add_index :events, [ :status, :date ], name: "index_events_on_status_and_date"
    end
  end
end
