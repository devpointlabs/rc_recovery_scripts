require 'httparty'
require 'csv'
require 'yaml'
require 'pry'

config = YAML.load_file('server.yml')

if config
  files = `ls rc_files`.split("\n").map { |f| "rc_files/#{f}" }
  files.each do |f|
    data = []
    row_num = 0
    HTTParty::Basement.default_options.update(verify: false)
    auth = {"Authorization" => "Bearer #{config['canvas_api_key']}"}
    CSV.foreach(f) do |row|
      if row_num == 0
        row_num += 1
        next
      else
        user_id = row[0].to_i
        if record = data.find { |d| d[:id].to_i == user_id }
          record[:records] << { date: row[1], status: row[2], course: row[3], teacher: row[4] }
        else
          url = "#{config['canvas_url']}/users/#{user_id}"
          user = HTTParty.get(url, headers: auth)
          entry = { 
            id: user['id'], 
            course: row[3],
            name: user['name'],
            email: user['login_id'],
            records: [{ date: row[1], status: row[2], course: row[3], teacher: row[4]}]
          }
          data << entry
        end
      end
    end
    CSV.open("files/#{data.first[:course]}.csv", "wb") do |csv|
      csv << ["id", "name", "email", "date", "status", "graded_by", "course"]
      data.each do |d|
        id = d[:id]
        name = d[:name]
        email = d[:email]
        course = d[:course]
        d[:records].each do |record|
          csv << [id, name, email, record[:date], record[:status], record[:teacher], course]
        end
      end
    end
  end
else
  raise 'Missing file server.yml'
end


