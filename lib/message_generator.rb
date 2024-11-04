require 'time'
require 'debug'

class MessageGenerator
  def initialize(user_name:)
    @user_name = user_name
  end

  def start_message
    "@#{@user_name} 作業開始"
  end

  # 本日分の作業時間を集計し表示用に整える
  # data: Array<activity_logs>
  def daily_report_message(data)
    # 現在の日時（JST）を取得
    current_date = Time.now.getlocal("+09:00").to_date

    total_minutes = data.sum do |entry|
      start_time = Time.parse(entry['start_at']).getlocal("+09:00")
      end_time = Time.parse(entry['end_at']).getlocal("+09:00")

      if start_time.to_date == current_date && end_time.to_date == current_date
        # 当日内に収まっている場合はそのまま計算
        ((end_time - start_time) / 60.0).round
      elsif start_time.to_date == current_date
        # start_timeが当日でend_timeが翌日の場合、当日分の作業時間のみ計算
        ((Time.new(current_date.year, current_date.month, current_date.day, 23, 59, 59, "+09:00") - start_time) / 60.0).round
      elsif end_time.to_date == current_date
        # end_timeが当日でstart_timeが前日の場合、当日分の作業時間のみ計算
        ((end_time - Time.new(current_date.year, current_date.month, current_date.day, 0, 0, 0, "+09:00")) / 60.0).round
      else
        0  # 当日分でない場合は0分
      end
    end

    hours = total_minutes / 60
    minutes = total_minutes % 60
    "本日 #{hours}時間#{minutes}分"
  end
end