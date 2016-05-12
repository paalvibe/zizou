require 'slackbot'

class BotController < ApplicationController
  def index
    Rails.logger.error "test"
    logger.error "test2"
    Rails.logger.error("params:" + params.inspect)
    slackbot = SlackBot.new(params)

    render json: { "text" => slackbot.answer }
  end
end
