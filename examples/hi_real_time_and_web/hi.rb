require 'slack-ruby-client'
require 'pry'
require 'json'
# require 'pathname'

Slack.configure do |config|
  config.token = 'xoxp-146385117830-146586426951-148262854690-2bce85ab96ce9040abb9c9a7b7cd4708'
  fail 'Missing ENV[SLACK_API_TOKEN]!' unless config.token
end

client = Slack::RealTime::Client.new

client.on :hello do
  puts "Successfully connected, welcome '#{client.self.name}' to the '#{client.team.name}' team at https://#{client.team.domain}.slack.com."

end

client.on :message do |data|
  puts data
  case data.text
  when 'bot hi' then
    client.web_client.chat_postMessage channel: data.channel, text: "Hi <@#{data.user}>!"
  when /^bot/ then
    client.web_client.chat_postMessage channel: data.channel, text: "Sorry <@#{data.user}>, what?"
  when 'history' then

    # If history.json exists AND has valid hash ['ts'] at parsed array position 0, only get new messages
    # append new messages to existing messages
    # write new history.json

    # is there a better way to protect against non-existing/bad files?
    json = File.read('history.json') rescue nil
    oldhist = JSON.parse(json) rescue []
    File.open("history.json", "w") do |f|
      puts "oldhist #{oldhist}"
      # is there a quick way to check if hash ['ts'] exists and is of type Float?
      if oldhist[0].nil? || oldhist[0]['ts'].nil?
        puts "invalid/empty existing file"
        ts =  0
        oldhist = []
      else
        puts "valid existing file"
        ts =  oldhist[0]['ts'].to_f + 1
      end
      # gets ALL messages if ts==0:
      newhist = client.web_client.channels_history(channel: data.channel, oldest:ts).messages
      # binding.pry
      f.puts JSON.pretty_generate(newhist + oldhist)
    end
  end
end

client.start!
