class AddUserEmailToReports < ActiveRecord::Migration
  def change
    add_column :reports, :user_email, :string
  end
end
