class CreateReleaseTypes < ActiveRecord::Migration[7.2]
  def change
    create_table :release_types do |t|
      t.string :name
      t.references :album

      t.timestamps
    end
  end
end
