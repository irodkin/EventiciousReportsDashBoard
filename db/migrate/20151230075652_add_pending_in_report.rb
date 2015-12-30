class AddPendingInReport < ActiveRecord::Migration
  def change
    add_column :reports, :pending_tests, :string
  end
end
