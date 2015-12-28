class AddFailedScenariosParser < ActiveRecord::Migration
  def change
    add_column :reports, :failed_tests, :string
  end
end
