class AddAppidInReports < ActiveRecord::Migration
  def change
    add_column :reports, :appid, :string
  end
end
