require 'slack-ruby-client'
require 'pry'
require 'json'
require 'pp'
require 'dotenv'
require 'open-uri'
require "byebug"
require 'rest-client'

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
        @json_url = []
        @old_history = []
        @ts = 0
      end

      def write_new_history
        @old_history = fetch_and_parse_history
        get_time_stamp
        @new_history = @client.web_client.channels_history(channel: @channel, oldest: @ts).messages
        byebug
        # File.open("history.json", "w") do |f|
        #   f.puts JSON.pretty_generate(@new_history + @old_history)
        # end
      end

      private

      def get_time_stamp
        return unless @old_history.first.is_a? Hash
        return unless @old_history.first['ts']
        @ts = @old_history.first['ts'].to_f + 1
      end

      def fetch_and_parse_history
        file_obj = @client.web_client.files_list.files.select{ |k|  k["title"].to_s.match("slack-stack-history") }
        @json_url = file_obj[0]["url_private_download"]
        res = RestClient.get(@json_url, { "Authorization" => "Bearer #{ENV['SLACK_API_TOKEN']}" })
        return res_code unless res.code == 200
        JSON.parse(res.body)
      end
    end

    HistoryGenerator.new(client, data.channel).write_new_history

  end
end




client.start!
