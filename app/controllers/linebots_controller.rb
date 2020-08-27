class LinebotsController < ApplicationController
  require 'line/bot'

  # protect_from_forgery except: :callback

  def callback
    head :bad_request unless valid_signature?

    events.each { |event|
      puts "event.type #{event.type}"
      puts "event #{event}"
      puts "events #{events}"

      case event.type
      when Line::Bot::Event::MessageType::Text
        if event.message['text'].eql?('アンケート')
          client.reply_message(event['replyToken'], template)
        end
      when 'beacon'
        client.reply_message(event['replyToken'], template_2)
      else
        puts "type #{event.type}"
        client.reply_message(event['replyToken'], template_3)
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

  def template_2
    {
      "type": "template",
      "altText": "this is a confirm template",
      "template": {
          "type": "confirm",
          "text": "beaconです",
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

  def template_3
    {
      "type": "template",
      "altText": "this is a confirm template",
      "template": {
          "type": "confirm",
          "text": "beaconでもメッセージでもありません",
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
