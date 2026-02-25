class RemovePreferenceColumnsFromCoreTables < ActiveRecord::Migration[7.2]
  def change
    remove_column :artists, :complete, :boolean, default: false
    remove_column :artists, :priority_id, :bigint
    remove_column :artists, :phase_id, :bigint

    remove_column :albums, :rating, :integer
    remove_column :albums, :listened, :boolean, default: false

    remove_column :tracks, :rating, :integer
    remove_column :tracks, :listened, :boolean
  end
end
