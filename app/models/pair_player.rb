require 'slack'

class PairPlayer < Player

  def self.find_or_create_by_users(user1, user2)
    PairPlayer.find_or_create_by(username: concatenate_and_order_usernames(user1, user2))
  end

  def self.concatenate_and_order_usernames(username1, username2)
    usernames = [username1, username2]
    "#{usernames.min} #{usernames.max}"
  end

  def ids_from_username
    username.split
  end

  def member_name
    username1, username2 = self.ids_from_username

    name1 = Slack.username_by_id(username1)
    name2 = Slack.username_by_id(username2)

    "#{name1} and #{name2}"
  end
end
