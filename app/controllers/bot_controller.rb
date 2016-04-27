require 'slackbot'

class BotController < ApplicationController
  def index
    slackbot = SlackBot.new(params)

    puts("params:" + params.inspect)

    render json: { "text" => slackbot.answer }
  end
end
