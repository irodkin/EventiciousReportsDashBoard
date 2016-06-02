class AddAppTypeToReports < ActiveRecord::Migration
  def change
    add_column :reports, :app_type, :string
  end
end
