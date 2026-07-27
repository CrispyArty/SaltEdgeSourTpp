class CreateApiRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :api_requests do |t|
      t.string :method, null: false
      t.string :url, null: false
      t.integer :status_code
      t.boolean :pending, default: false
      t.float :duration_ms
      t.jsonb :request_headers
      t.jsonb :request_body
      t.jsonb :response_headers
      t.text :response_body
      t.string :error_class
      t.text :error_message
      t.timestamps
    end

    add_index :api_requests, :created_at
    add_index :api_requests, :status_code
  end
end
