class AddUuidToOBConsent < ActiveRecord::Migration[8.1]
  def change
    add_column :ob_consents, :uuid, :string
  end
end
