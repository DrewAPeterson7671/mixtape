class AddDurationAndIsrcToTracks < ActiveRecord::Migration[7.2]
  def change
    add_column :tracks, :duration, :integer
    add_column :tracks, :isrc, :string
    add_index :tracks, :isrc
  end
end
