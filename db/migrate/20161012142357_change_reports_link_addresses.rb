class ChangeReportsLinkAddresses < ActiveRecord::Migration
  def change
  	Report.all.each do |report|
  		if report.link.include?(".34/")
  			new_link = report.link.sub(".34/", ".183/")
	      report.update(link:new_link)
	    end
    end
  end
end
