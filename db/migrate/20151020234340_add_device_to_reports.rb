class AddDeviceToReports < ActiveRecord::Migration
  def change
  	add_column :reports, :device, :string
  end
end
