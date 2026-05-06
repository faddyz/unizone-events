class CreateImportRuns < ActiveRecord::Migration[8.0]
  def change
    create_table :import_runs do |t|
      t.string :source, null: false
      t.string :status, null: false, default: "running"
      t.boolean :dry_run, null: false, default: true
      t.datetime :started_at
      t.datetime :finished_at
      t.integer :fetched_count, null: false, default: 0
      t.integer :new_candidate_count, null: false, default: 0
      t.integer :duplicate_count, null: false, default: 0
      t.integer :skipped_count, null: false, default: 0
      t.integer :hidden_count, null: false, default: 0
      t.integer :failed_count, null: false, default: 0
      t.jsonb :parameters, null: false, default: {}
      t.text :error_message

      t.timestamps
    end

    add_index :import_runs, :source
    add_index :import_runs, :status
    add_index :import_runs, :started_at
  end
end
