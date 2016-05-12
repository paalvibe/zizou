require 'slackbot'

class BotController < ApplicationController
  def index
    slackbot = SlackBot.new(params)

    Rails.logger.error("params:" + params.inspect)

    render json: { "text" => slackbot.answer }
  end
end
