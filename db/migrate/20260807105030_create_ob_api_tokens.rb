class CreateOBApiTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :ob_api_tokens do |t|
      t.belongs_to :ob_consent
      t.string :access_token
      t.string :id_token
      t.string :refresh_token
      t.string :scope
      t.datetime :issued_at
      t.datetime :expired_at

      t.timestamps
    end
  end
end
