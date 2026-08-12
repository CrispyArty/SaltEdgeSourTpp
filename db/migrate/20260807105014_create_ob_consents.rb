class CreateOBConsents < ActiveRecord::Migration[8.1]
  def change
    create_table :ob_consents do |t|
      t.string :external_id, index: true
      t.integer :status, default: 0, null: false
      t.jsonb :permissions
      t.datetime :expired_at

      t.timestamps
    end
  end
end
