class CreateArtManagerRoles < ActiveRecord::Migration
  def change
    create_table :art_manager_roles do |t|
      t.references :role_id, index: true
    end
  end
end
