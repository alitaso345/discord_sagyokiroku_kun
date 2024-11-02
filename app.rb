require 'discordrb'
require 'dotenv/load'
require 'sqlite3'

DB_PATH = 'test.db'
SELECT_LATEST_LOG_QUERY = "SELECT * FROM activity_logs WHERE user_id = ? AND end_at IS NULL ORDER BY start_at DESC LIMIT 1".freeze
UPDATE_LOG_END_TIME_QUERY = "UPDATE activity_logs SET end_at = ? WHERE id = ?".freeze
INSERT_LOG_QUERY = "INSERT INTO activity_logs(user_id, start_at) VALUES(?, ?)".freeze

db = SQLite3::Database.new(DB_PATH)
bot = Discordrb::Bot.new(token: ENV['DISCORD_TOKEN'])

bot.interaction_create(type: Discordrb::Interaction::TYPES[:command]) do |event|
  if event.interaction.data['name'] == 'touch'
    now = Time.now.strftime('%Y/%m/%d %H:%M')
    user = event.user
    message = nil
  
    row = db.get_first_row(SELECT_LATEST_LOG_QUERY, [user.id])
  
    if row
      # レコードがある場合は、作業終了としてend_atを更新
      db.execute(UPDATE_LOG_END_TIME_QUERY, [now, row[0]])
  
      # 作業時間の計算
      time_difference = Time.parse(now) - Time.parse(row[2]) 
      hours = (time_difference/3600).to_i
      minutes = (time_difference%3600/60).to_i
      message = "@#{user.username} 作業終了 作業時間(#{hours}時間#{minutes}分)"
    else
      # レコードがない場合は、新規作業開始として挿入
      db.execute(INSERT_LOG_QUERY, [user.id, now])
      message = "@#{user.username} 作業開始 #{now}"
    end
  
    event.respond(content: message)
  end
end

bot.run