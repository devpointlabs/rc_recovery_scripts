#This script should be run on rc server to generate CSV files

require 'csv'

namespace :recover do
  desc "retrieve attendance data"
  task :info, [:id] => [:environment] do |t, args|
    if args[:id]
      id = args[:id].to_i
      statuses = Status.where(course_id: id).order(class_date: :desc)
      columns = ["student_id", "class_date", "attendance", "course_id", "teacher_id"]
      CSV.open("/home/rails/rollcall/files/#{id}_report.csv", "wb") do |csv|
        csv << columns
        statuses.each do |student|
          row = []
          columns.each do |c|
            row << student[c]
          end
          csv << row
        end
      end
    else
      raise "Specify course id rake recover:info[1]"
    end
  end

end
