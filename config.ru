require 'sinatra'
require 'dotenv/load'
require './app'
require_relative 'discord_signature_verifier'

use DiscordSignatureVerifer, ENV['DISCORD_PUBLIC_KEY']
run Sinatra::Application