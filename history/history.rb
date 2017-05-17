require 'slack-ruby-client'
require 'pry'
require 'json'
require 'pp'
require 'dotenv'
require 'date'
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
  # puts data
  case data.text
  when 'bot hi' then
    client.web_client.chat_postMessage channel: data.channel, text: "Hi <@#{data.user}>!"
  when /^bot/ then
    client.web_client.chat_postMessage channel: data.channel, text: "Sorry <@#{data.user}>, what?"
  when 'history' then
    #Where should this class actually go?

    class HistoryGenerator

      def initialize(client, channel)
        @channel = channel
        @client = client.web_client
        @json_url = []
        @old_history = []
        @ts = 0
      end

      def generate
        fetch_and_parse_history
        get_time_stamp
        post_new_history
        #how toonly delete on success of post_new_history?
        delete_older_history
      end

      #what is this private thing doing? can only '.initialize' and '.generate' be accessed as methods?
      # do we nest functions much?
      private

      def post_new_history
        new_messages = @client.channels_history(channel: @channel, oldest: @ts).messages
        #how can the following JSON include new_messages without async issues form the above call?
        message_json = JSON.pretty_generate(new_messages + @old_history)
        comment = Time.at(@ts).to_s + " to " + Time.now.to_s
        @client.files_upload(content:message_json, filetype:"javascript", title:"slack-stack-history", filename:"history.json", initial_comment:comment, channels:@channel)
      end

      # instance variables vs returning values???
      def get_time_stamp
        return unless @old_history.first.is_a? Hash
        return unless @old_history.first['ts']
        @ts = @old_history.first['ts'].to_f + 1
      end

      def fetch_and_parse_history
        fetch_history
        if @file_objects == []
          @old_history = []
        else
          @json_url = @file_objects[0]["url_private_download"]
          res = RestClient.get(@json_url, { "Authorization" => "Bearer #{ENV['SLACK_API_TOKEN']}" })
          return unless res.code == 200
          @old_history = JSON.parse(res.body)
        end
      end

      def delete_older_history
        puts "#{@file_objects.length} to delete"
        @file_objects.each do |f|
          @client.files_delete(file: f.id)
        end
      end

      def fetch_history
        @file_objects = @client.files_list.files.select{ |k|  k["title"].to_s.match("slack-stack-history") }
      end
    end

    HistoryGenerator.new(client, data.channel).generate

  end
end




client.start!
