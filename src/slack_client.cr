require "http/client"
require "json"

# A slack client to post messages to a particular channel
class SlackClient
  BASE_URI = URI.parse("https://slack.com")

  def initialize(@token : String, @channel_id : String)
    @client = HTTP::Client.new(BASE_URI)
    @default_headers = HTTP::Headers{
      "Authorization" => "Bearer #{@token}",
      "Content-Type"  => "application/json; charset=utf-8",
    }
  end

  # Schedule a message to be posted at a particular time
  def schedule_message(text : String, post_at : Time)
    request_body = {
      channel: @channel_id,
      mrkdwn:  false,
      post_at: post_at.to_unix,
      text:    text,
    }

    post("/api/chat.scheduleMessage", request_body)
  end

  # Get all scheduled messages for the channel
  def scheduled_messages
    request_body = {
      channel: @channel_id,
    }

    response_body = post("/api/chat.scheduledMessages.list", request_body)
    response_body["scheduled_messages"].as_a
  end

  private def post(path, request_body)
    response = @client.post(
      path,
      body: request_body.to_json,
      headers: @default_headers
    )

    JSON.parse(response.body)
  end
end
