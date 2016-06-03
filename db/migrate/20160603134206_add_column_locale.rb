class AddColumnLocale < ActiveRecord::Migration
  def change
  	add_column :reports, :locale, :string
    Report.all.each do |report|
      report.update(locale:"ru")
    end
  end
end
