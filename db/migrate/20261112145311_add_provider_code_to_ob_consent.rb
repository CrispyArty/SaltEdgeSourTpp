class AddProviderCodeToOBConsent < ActiveRecord::Migration[8.1]
  def change
    add_column :ob_consents, :provider_code, :string
  end
end
