require "dotenv"
Dotenv.load if File.readable?(".env")

require "./slack_client"

SLACK_TOKEN      = ENV.fetch("SLACK_TOKEN")
SLACK_CHANNEL_ID = ENV.fetch("SLACK_CHANNEL_ID")

# Make array of video links
FRIDAY_VIDEOS = [
  "https://www.youtube.com/watch?v=7-iLzd-HKRg",
  "https://www.youtube.com/watch?v=94TZJO_PXhU",
  "https://www.youtube.com/watch?v=akT0wxv9ON8",
  "https://www.youtube.com/watch?v=kfVsfOSbJY0",
  "https://www.youtube.com/watch?v=KlyXNRrsk4A",
  "https://www.youtube.com/watch?v=rkIPy1Sx2ro",
]

class FridayBot
  def self.call
    new.call
  end

  def initialize
    @client = SlackClient.new(SLACK_TOKEN, SLACK_CHANNEL_ID)
  end

  def call
    scheduled_messages = @client.scheduled_messages
    current_time = Time.local

    # Post messages up to 120 days in advance
    120.times do
      current_time = current_time.at_beginning_of_day + 8.hours
      maybe_schedule_message(scheduled_messages, current_time)
      current_time += 1.day
    end
  end

  private def find_already_scheduled(scheduled_messages, current_time)
    timestamp = current_time.to_unix

    scheduled_messages.find { |msg| msg["post_at"] == timestamp }
  end

  private def maybe_schedule_message(scheduled_messages, current_time)
    # Only schedule messages on Fridays
    return unless current_time.friday?

    # Skip the current day if we've already scheduled a message for it
    existing_msg = find_already_scheduled(scheduled_messages, current_time)
    if existing_msg
      puts "Message #{existing_msg["id"]} already scheduled at #{current_time}"
      return
    end

    # Choose a random video from the list
    random_video = FRIDAY_VIDEOS.sample(Random::Secure)
    puts "Posting #{random_video} to #{SLACK_CHANNEL_ID} at #{current_time}"

    # Schedule it to be posted in the channel
    @client.schedule_message(random_video, current_time)
  end
end

FridayBot.call
