class CreateProjectLeadRoles < ActiveRecord::Migration
  def change
    create_table :project_lead_roles do |t|
      t.references :role_id, index: true
    end
  end
end
