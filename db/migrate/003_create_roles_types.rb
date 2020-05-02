class CreateRolesTypes < ActiveRecord::Migration
  def change
    create_table :roles_types do |t|
      t.references :role, index: true, foreign_key: true
      t.integer :type_roles_id
    end
  end
end
