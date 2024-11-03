require 'json'
require 'pg'
require 'time'

db = PG.connect(
  dbname: ENV['DB_NAME'],
  host: ENV['DB_HOSTNAME'],
  user: ENV['DB_USER'],
  port: ENV['DB_PORT'],
  password: ENV['DB_PASSWORD']
)

get '/' do
  "Health check: #{Time.now}"
end

post '/interactions' do
  request_body = JSON.parse(request.body.read)

  # スラッシュコマンド以外の機能はないため
  return unless request_body['type'] == 2
  
  if request_body['data']['name'] == 'touch'
    now = Time.now.utc
    user = request_body['user'] || request_body['member']['user']
    content = nil
  
    row = db.exec_params('SELECT * FROM activity_logs WHERE user_id = $1 AND end_at IS NULL ORDER BY start_at DESC LIMIT 1',[user['id']]).first
  
    if row
      # レコードがある場合は、作業終了としてend_atを更新
      db.exec_params('UPDATE activity_logs SET end_at = $1 WHERE id = $2', [now, row['id']])
  
      # 作業時間の計算
      time_difference = now - Time.parse(row['start_at']) 
      hours = (time_difference/3600).to_i
      minutes = (time_difference%3600/60).to_i
      content = "@#{user['username']} 作業終了 作業時間(#{hours}時間#{minutes}分)"
    else
      # レコードがない場合は、新規作業開始として挿入
      db.exec_params('INSERT INTO activity_logs(user_id, start_at) VALUES($1, $2)', [user['id'], now])
      content = "@#{user['username']} 作業開始"
    end
  end

  content_type(:json)
  {
    type: 4,
    data: {content: content}
  }.to_json
end