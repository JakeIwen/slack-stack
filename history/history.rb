require 'slack-ruby-client'
require 'pry'
require 'json'
require 'pp'
require 'dotenv'

Dotenv.load('../.env')

# pp ENV

Slack.configure do |config| :dotenv
  config.token = ENV['SLACK_API_TOKEN']
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

    class HistoryGenerator

      def initialize(client, channel)
        @channel = channel
        @client = client
        @old_history = []
        @ts = 0
      end

      def write_new_history
        get_old_history
        get_time_stamp
        @new_history = @client.web_client.channels_history(channel: @channel, oldest: @ts).messages
        File.open("history.json", "w") do |f|
          f.puts JSON.pretty_generate(@new_history + @old_history)
        end
      end

      private

      def get_old_history
        @file_obj_list = @client.web_client.files_list.files
        pp @file_obj_list

        @file_name_list = @file_obj_list.map { |a|
          { "file_name" => a["name"], "file_url" => a["permalink_public"] }
        }
        if @file_name_list.include?('slack-stack-history')
          @msg_json = @file_name_list.select { |a| a=='slack-stack-history' }
        else
          puts "no message history json found. create new?"
        end
        pp @file_name_list
        # binding.pry
        begin
          @old_history = JSON.parse(File.read('history.json'))
        rescue
          puts 'An error occured parsing the history file'
        end
      end

      def get_time_stamp
        return unless @old_history.first.is_a? Hash
        return unless @old_history.first['ts']
        @ts = @old_history.first['ts'].to_f + 1
      end
    end

    HistoryGenerator.new(client, data.channel).write_new_history

    # If history.json exists AND has valid hash ['ts'] at parsed array position 0, only get new messages
    # append new messages to existing messages
    # write new history.json

    # is there a better way to protect against non-existing/bad files?
    # json = File.read('history.json') rescue nil
    # oldhist = JSON.parse(json) rescue []
    # if oldhist[0].nil? || oldhist[0]['ts'].nil?
    #   puts "invalid/empty existing file"
    #   ts =  0
    #   oldhist = []
    # else
    #   puts "valid existing file"
    #   ts =  oldhist[0]['ts'].to_f + 1
    # end
    # newhist = client.web_client.channels_history(channel: data.channel, oldest:ts).messages
    #
    # File.open("history.json", "w") do |f|
    #   # gets ALL messages if ts==0:
    #   f.puts JSON.pretty_generate(newhist + oldhist)
    # end
  end
end

client.start!
