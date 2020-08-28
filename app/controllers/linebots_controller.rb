class LinebotsController < ApplicationController
  require 'line/bot'

  def callback
    head :bad_request unless valid_signature?

    events.each { |event|
      puts "event.type #{event.type}"
      puts "event #{event}"
      puts "event.class #{event.class}"
      puts "JSON.parse(event.to_json, symbolize_names: true) #{JSON.parse(event.to_json, symbolize_names: true)}"

      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          if event.message['text'].eql?('アンケート')
            client.reply_message(event['replyToken'], template)
          end
        end
      when Line::Bot::Event::Beacon
        client.reply_message(event['replyToken'], message_type_text)
      else
        puts "type #{event.type}"
        client.reply_message(event['replyToken'], template)
      end
    }

    head :ok
  end

  private

  def events
    @events ||= client.parse_events_from(body)
  end

  def signature
    @signature ||= request.env['HTTP_X_LINE_SIGNATURE']
  end

  def body
    @body ||= request.body.read
  end 

  def valid_signature?
    client.validate_signature(body, signature)
  end

  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_id = ENV.fetch("LINE_CHANNEL_ID")
      config.channel_secret = ENV.fetch("LINE_CHANNEL_SECRET")
      config.channel_token = ENV.fetch("LINE_CHANNEL_TOKEN")
    }
  end

  def message_type_text
    {
      "type": "text",
      "text": OpenWeatherMap.latest_forcasts_message
    }
  end

  def template
    {
      "type": "template",
      "altText": "this is a confirm template",
      "template": {
          "type": "confirm",
          "text": "今日のもくもく会は楽しいですか？",
          "actions": [
              {
                "type": "message",
                "label": "楽しい",
                "text": "楽しい"
              },
              {
                "type": "message",
                "label": "楽しくない",
                "text": "楽しくない"
              }
          ]
      }
    }
  end
end
