require 'slack-ruby-client'
require 'pry'
require 'json'
require 'pp'
require 'dotenv'
require 'date'
require "byebug"
require 'rest-client'

Dotenv.load('../.env')

class HistoryGenerator

  def initialize(client, channel, user)
    @channel = channel
    @client = client.web_client
    @old_history = []
    @ts = 0
    @file_objects = nil
    @user = user
  end

  def generate
    fetch_history
    return false if @file_objects.empty?
    return false unless parse_history
    get_time_stamp
    success = post_new_history?
    delete_old_history if success
    true
  end

  private

  def fetch_history
    @file_objects = @client.files_list.files.select{ |k|  k["title"].to_s.match("slack-stack-history") }
  end

  def parse_history
    history_file_url = @file_objects[0]["url_private_download"]
    res = RestClient.get(history_file_url, { "Authorization" => "Bearer #{ENV['SLACK_API_TOKEN']}" })
    return false unless res.code == 200
    @old_history = JSON.parse(res.body)
  end

  def get_time_stamp
    return unless @old_history.first.is_a? Hash
    return unless @old_history.first['ts']
    @ts = @old_history.first['ts'].to_f + 1
  end

  def post_new_history?
    new_messages = @client.channels_history(channel: @channel, oldest: @ts).messages
    message_json = JSON.pretty_generate(new_messages + @old_history)
    comment = Time.at(@ts).to_s + " to " + Time.now.to_s
    @client.files_upload(content:message_json, filetype:"javascript", title:"slack-stack-history", filename:"history.json", initial_comment:comment, user:@user).ok
  end

  def delete_old_history
    puts "#{@file_objects.length} to delete"
    @file_objects.each do |f|
      @client.files_delete(file: f.id)
    end
  end
end

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
    history_written = HistoryGenerator.new(client, data.channel, data.user).generate
    if history_written
      puts "Okay, I wrote your history"
    else
      puts "Sorry, something went wrong."
    end
  end
end

client.start!
