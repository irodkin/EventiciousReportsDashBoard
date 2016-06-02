class RemoveDeviceColumnFromReports < ActiveRecord::Migration
  def change
  	remove_column :reports, :device, :string
  end
end
