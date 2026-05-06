class CreateExternalEventCandidates < ActiveRecord::Migration[8.0]
  def change
    create_table :external_event_candidates do |t|
      t.string :source, null: false
      t.string :external_id, null: false
      t.string :status, null: false, default: "pending"
      t.integer :priority, null: false, default: 0
      t.string :title
      t.string :city
      t.string :venue
      t.string :venue_type
      t.datetime :starts_at
      t.datetime :ends_at
      t.string :category
      t.string :format
      t.string :poster_url
      t.string :ticket_url
      t.string :external_url
      t.string :ticket_url_kind
      t.jsonb :raw_data, null: false, default: {}
      t.jsonb :mapped_data, null: false, default: {}
      t.jsonb :review_reasons, null: false, default: []
      t.jsonb :priority_reasons, null: false, default: []
      t.string :duplicate_warning
      t.string :hidden_reason
      t.datetime :first_seen_at
      t.datetime :last_seen_at
      t.references :resolved_event, foreign_key: { to_table: :events }
      t.datetime :resolved_at

      t.timestamps
    end

    add_index :external_event_candidates, [ :source, :external_id ], unique: true
    add_index :external_event_candidates, :status
    add_index :external_event_candidates, :priority
    add_index :external_event_candidates, :starts_at
    add_index :external_event_candidates, :venue_type
    add_index :external_event_candidates, :city
  end
end
