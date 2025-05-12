class CreateAttendances < ActiveRecord::Migration[7.0]
  def change
    create_table :attendances do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.string :status, null: false, default: 'attending' # attending, maybe, declined

      t.timestamps
    end

    # Bir kullanıcı bir etkinliğe yalnızca bir kez katılabilir
    add_index :attendances, [:user_id, :event_id], unique: true
    
    # Status'a göre hızlı sorgulama için
    add_index :attendances, :status
  end
end 