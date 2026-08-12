class CreateProviderConfigs < ActiveRecord::Migration[8.1]
  def change
    create_table :provider_configs do |t|
      t.string :code, index: true
      t.string :authorization_endpoint
      t.jsonb :scopes_supported, default: {}, null: false

      t.timestamps
    end
  end
end
