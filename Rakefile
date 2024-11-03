require 'dotenv/load'
require 'sqlite3'
require 'httparty'
require 'json'

task :register_command do
  url = "https://discord.com/api/v10/applications/#{ENV['DISCORD_APPLICATION_ID']}/commands"
  
  body = {
    name: 'touch',
    type: 1,
    description: '【開発用】作業記録開始/終了コマンド'
  }.to_json
  
  headers = {
    'Authorization': "Bot #{ENV['DISCORD_TOKEN']}",
    'Content-Type' => 'application/json'
  }
  
  res = HTTParty.post(url, body: body, headers: headers)
  pp res
end

namespace :db do
  task :create do
    db = SQLite3::Database.new('test.db')
    db.execute <<-SQL
      create table activity_logs (
        id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
        user_id varchar(50) not null,
        start_at timestamptz not null,
        end_at timestamptz
      );

      create index user_id_index on activity_logs(user_id);
    SQL
  end
end