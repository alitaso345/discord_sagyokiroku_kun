require 'message_generator'

RSpec.describe MessageGenerator do
  describe 'start_message' do
    it 'returns mention name and start message' do
      message_generator = MessageGenerator.new(user_name: 'alice')
      expect(message_generator.start_message()).to eq('@alice 作業開始')
    end
  end

  describe 'daily_report_message' do
    it 'normal pattern' do
      message_generator = MessageGenerator.new(user_name: 'alice')
      data = [
        {'id' => 1, 'user_id' => 11, 'start_at' => '2024-11-04 10:00:00 UTC', 'end_at' => '2024-11-04 10:30:00 UTC'},
        {'id' => 2, 'user_id' => 22, 'start_at' => '2024-11-04 11:00:00 UTC', 'end_at' => '2024-11-04 11:50:00 UTC'},
      ]
      expect(message_generator.daily_report_message(data)).to eq('本日 1時間20分')
    end

    it 'returns only the work time for the current day part1' do
      message_generator = MessageGenerator.new(user_name: 'alice')
      data = [
        {'id' => 1, 'user_id' => 11, 'start_at' => '2024-11-04 13:00:00 UTC', 'end_at' => '2024-11-04 16:00:00 UTC'}
      ]
      allow(Time.now).to receive(:utc).and_return(Time.new(2024, 11, 4, 20, 0, 0, "+09:00"))
      expect(message_generator.daily_report_message(data)).to eq('本日 2時間0分')
    end

    it 'returns only the work time for the current day part2' do
      message_generator = MessageGenerator.new(user_name: 'alice')
      data = [
        {'id' => 1, 'user_id' => 11, 'start_at' => '2024-11-04 13:00:00 UTC', 'end_at' => '2024-11-04 16:00:00 UTC'}
      ]
      allow(Time).to receive(:now).and_return(Time.new(2024, 11, 5, 7, 0, 0, "+09:00"))
      expect(message_generator.daily_report_message(data)).to eq('本日 1時間0分')
    end
  end
end