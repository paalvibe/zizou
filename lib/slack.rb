class Slack
  @@id2username = nil
  def self.members
    hash = Slack.query('https://slack.com/api/users.list', { :token => ENV["SLACK_API_TOKEN"] })
    hash["members"]
  end

  private

  def self.query(url, params = {})
    uri = URI(url)
    uri.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(uri)
    JSON.parse(res.body) rescue {}
  end

  def self.setup_id2username_map()
    @@id2username = {}
    self.members.each do |member|
      @@id2username[member["id"]] = member["name"]
    end
  end

  def self.username_by_id(id)
    self.setup_id2username_map if @@id2username.nil?
    return @@id2username[id] if @@id2username.include?(id)
    "unknown"
  end
end
