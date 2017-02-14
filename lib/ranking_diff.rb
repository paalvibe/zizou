# -*- coding: utf-8 -*-
require 'ranking'
require 'department_ranking'
require 'terminal-table'

class RankingDiff
  def self.player_pos(sorted_players)
    positions = {}
    idx = 0
    sorted_players.each do |u, p|
      idx = idx + 1
      positions[u] = idx
    end
    positions
  end

  def self.players(negative_game_offset, n_weeks)
    negative_game_offset = negative_game_offset.to_i
    negative_game_offset = 1 if negative_game_offset < 1
    all_games = Ranking.games(n_weeks)
    older_games = all_games[negative_game_offset..-1] # TODO use negative_game_offset
    sorted_players_all = Ranking.combined_players_sorted(all_games)
    sorted_players_all_hash = sorted_players_all.to_h
    sorted_players_older = Ranking.combined_players_sorted(older_games)
    sorted_players_older_hash = sorted_players_older.to_h
    last_games = all_games[0..negative_game_offset]

    involved_usernames = last_games.map{ |g| Ranking.usernames_in_game(g).map { |k, usernames| usernames } }.flatten

    new_positions = player_pos(sorted_players_all)
    old_positions = player_pos(sorted_players_older)

    player_diffs = {}
    involved_usernames.each do |u|
      new_player = sorted_players_all_hash[u]
      old_player = sorted_players_older_hash[u]
      player_diffs[u] = {
        name: new_player[:name],
        new_pos: new_positions[u],
        old_pos: old_positions[u],
        new_rating: new_player[:rating],
        old_rating: old_player.nil? ? 1500 : old_player[:rating],
      }
    end
    sorted_player_diffs = player_diffs.sort_by{|k, v| v[:new_rating]}.reverse

    rows = []
    idx = 0
    sorted_player_diffs.to_h.each do |username, d|
      idx = idx + 1
      rows << [d[:name],
               "#{d[:old_pos]} -> #{d[:new_pos]}",
               ('%.2f -> %.2f' % [d[:old_rating], d[:new_rating]])]
    end
    table = Terminal::Table.new :title => "Player rating changes", :headings => ["Name", "Pos.", "Rating"], :rows => rows
    ret = "```#{table}```
"

    # involved_departments = involved_usernames.map{ |u| Department.find_by_username(u) }.flatten
    # sorted_departments_all = DepartmentRanking.sorted_departments(all_games)
    # sorted_departments_older = DepartmentRanking.sorted_departments(older_games)
    ret
  end
end
