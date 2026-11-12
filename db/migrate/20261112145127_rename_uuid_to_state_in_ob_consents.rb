class RenameUuidToStateInOBConsents < ActiveRecord::Migration[8.1]
  def change
    rename_column :ob_consents, :uuid, :state
  end
end
