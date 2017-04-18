class AddJobIdToReports < ActiveRecord::Migration
	def change
		add_reference :reports, :job, index: true
		Report.find_each do |report|
			job = Job.find_by(title: report.job)
			if job
				job_id = job.id
			else
				Job.create(title: report.job)
				job = Job.find_by(title: report.job)
				job_id = job.id
			end
			report.update(job_id: job_id)
		end
		remove_column :reports, :job
		remove_column :reports, :buildurl
	end
end
