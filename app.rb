require 'sinatra'
require 'dotenv/load'
require 'ed25519'
require 'json'
require 'sqlite3'
require_relative 'discord_signature_verifier'

db = SQLite3::Database.new('test.db')

use DiscordSignatureVerifer, ENV['DISCORD_PUBLIC_KEY']

get '/healthz' do
  "Health check: #{Time.now}"
end

post '/interactions' do
  request_body = JSON.parse(request.body.read)

  # スラッシュコマンド以外の機能はないため
  return unless request_body['type'] == 2
  
  if request_body['data']['name'] == 'touch'
    now = Time.now.strftime('%Y/%m/%d %H:%M')
    user = request_body['user'] || request_body['member']['user']
    content = nil
  
    row = db.get_first_row('SELECT * FROM activity_logs WHERE user_id = ? AND end_at IS NULL ORDER BY start_at DESC LIMIT 1', [user['id']])
  
    if row
      # レコードがある場合は、作業終了としてend_atを更新
      db.execute('UPDATE activity_logs SET end_at = ? WHERE id = ?', [now, row[0]])
  
      # 作業時間の計算
      time_difference = Time.parse(now) - Time.parse(row[2]) 
      hours = (time_difference/3600).to_i
      minutes = (time_difference%3600/60).to_i
      content = "@#{user['username']} 作業終了 作業時間(#{hours}時間#{minutes}分)"
    else
      # レコードがない場合は、新規作業開始として挿入
      db.execute('INSERT INTO activity_logs(user_id, start_at) VALUES(?, ?)', [user['id'], now])
      content = "@#{user['username']} 作業開始"
    end
  end

  content_type(:json)
  {
    type: 4,
    data: {
      content: content
    }
  }.to_json
end