require 'discordrb'
require 'dotenv/load'

bot = Discordrb::Bot.new(token: ENV['DISCORD_TOKEN'])
bot.register_application_command(:touch, '作業記録開始/終了コマンド')