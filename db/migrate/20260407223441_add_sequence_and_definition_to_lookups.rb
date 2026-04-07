class AddSequenceAndDefinitionToLookups < ActiveRecord::Migration[7.2]
  def change
    add_column :editions, :sequence, :integer
    add_column :media, :sequence, :integer
    add_column :phases, :sequence, :integer
    add_column :priorities, :sequence, :integer
    add_column :release_types, :sequence, :integer

    add_column :phases, :definition, :text
    add_column :priorities, :definition, :text
  end
end
