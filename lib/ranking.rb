# -*- coding: utf-8 -*-
require 'slack'
require 'terminal-table'

class Ranking

  def self.usernames_in_game(game)
    names = {team1: [], team2: []}
    {team1: game.team_player1, team2: game.team_player2}.each do |team, player|
      if player.is? TeamPlayer
        usernames = player.username.split
        names[team] << usernames[0]
        names[team] << usernames[1]
      else
        names[team] << player.username
      end
    end
    names
  end

  def self.combined(n_weeks)
    n_weeks = n_weeks.to_i
    games = nil
    if n_weeks == 0
      games = Game.order(created_at: :desc)
    else
      from = (Date.today - (n_weeks * 7)).to_s
      games = Game.where("created_at >= ?", from).order(created_at: :desc)
    end
    results = {}

    players = {}

    default_rating = 1500

    games.find_each do |game|
      # create list of results
      names = usernames_in_game(game)

#      game_names1 = # todo get team 1 names
#      game_names2 = # todo get team 2 names
      # players = self.add_player_entries(players, game) # can this be done more efficiently?
      results[game.id.to_s] = {
        created_at_str: game.created_at.to_s[0..9],
        names: names,
        goals: {team1: game.team_player1.score, team2: game.team_player2.score},
        win:
        {
          team1: game.team_player1.score > game.team_player2.score,
          team2: game.team_player2.score > game.team_player1.score,
        }
      }
    end
    # process all results
    players = {}
    other_team = {team1: :team2, team2: team1}
    # add missing players and collect team ratings
    results.each do |result|
      team_ratings = {team1: 0, team2: 0}
      result.names.each do |team, names|
        names.each do |username|
          if not (players.include?(username))
            player = {name: Slack.username_by_id(username), rating: 1500, goals_for: 0, goals_against: 0, wins: 0, losses: 0}
          else
            player = players[username]
          end
          team_ratings[team] += player[:rating] # add players rating to team rating for this result
        end
      end
      # calculate rating deltas
      rating_deltas = calculate_rating_deltas(team_ratings, result)

      # apply deltas to player stats
      result.names.each do |team, names|
        names.each do |username|
          players[username][:rating] = players[username][:rating] + rating_deltas[team]
          players[username][:goals_for] = players[username][:goals_for] + result[:goals][team]
          players[username][:goals_for] = players[username][:goals_against] + result[:goals][other_team[team]]
          if result[:win][team]
            players[username][:wins] = players[username][:wins] + 1
          else
            players[username][:losses] = players[username][:losses] + 1
          end
        end
      end
    end

    sorted_players = players.sort_by{|k, v| v[:rating]}.reverse

    rows = []
    idx = 0
    sorted_players.each do |username, p|
      idx = idx + 1
      rows << ["#{idx}", p[:name], p[:rating], p[:wins] + p[:losses], p[:goals_for], p[:goals_against], p[:goals_for] - p[:goals_against]]
    end
    table = Terminal::Table.new :title => "General player rating", :headings => ["Pos", "Name", "Rat.", "GP", "W", "L", "GF", "GA", "GD"], :rows => rows
    #     table.align_column(8, :right) # right align the diff column content
    #     table.align_column(9, :center) # center align the rating column content

      "```#{table}```

Pos: Rating position. Rat: rating. GP: Games played. W: Won. L: Lost. GF: Goals For. GA: Goals against. GA: Goals diff.
"
  end

  def self.calculate_rating_deltas(team_ratings, result)
    rating_deltas = {}
    default_win_weight = 10 # what multiplier of rating diff should be applied
    score_diff_weight = 0.3 # how much should
    base_delta_constant = 100
    rating_diff_base_weight = -10
    
    # example rating_points:
    # team1 rating: 1000 + 1600 = 2600
    # team2 rating 1600 + 1550 = 3050
    # rating_diff = -450
    # rating_sum = 5650
    # relative_rating_diff = -0.0796460177
    # team1 goals: 10
    # team2 goals: 6
    # team1 goal_diff = 4
    # team2 goal_diff = 4
    # team1 result_weight: 10 + 10 - 6 = 14
    # team2 result_weight: -10 + 6 - 10 = -14
    #
    # team1 base_delta: 100 (base_delta_constant)  * 14 (result_weight) / 20 (default_win_weight*2) = 70
    # team2 base_delta: 100 (base_delta_constant)  * -14 (result_weight) / 20 (default_win_weight*2) = -70
    # team1 rating delta: 70 (base_delta) * -10 (rating_diff_base_weight) *  -0.08 (relative_rating_diff) = 56
    # team2 rating delta: 70 (base_delta) * -10 (rating_diff_base_weight) *  0.08 (relative_rating_diff) = -56
    team = :team1
    rating_sum = team_ratings[team] + team_ratings[other_team[team]]
    rating_diff = team_ratings[team] - team_ratings[other_team[team]]
    relative_rating_diff = rating_diff / rating_sum
    if result[:win][team]
      result_weight = default_win_weight
    else
      result_weight = -default_win_weight
    end
    result_weight = result_weight + result[:goals][team] - result[:goals][other_team[team]]
    result_counter_weight = default_win_weight * 2
    base_delta = base_delta_constant * (result_weight / result_counter_weight)
    rating_delta = base_delta * rating_diff_base_weight * relative_rating_diff
    rating_deltas[team] = rating_delta
    rating_deltas[other_team[team]] = -rating_delta
    rating_deltas
  end
end
