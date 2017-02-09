# -*- coding: utf-8 -*-
require 'ranking'
require 'terminal-table'

class DepartmentRanking
  FIELDS = [:rating, :wins, :losses, :wins, :losses, :goals_for, :goals_against]
  def self.group_by_department(players)
    departments = {}
    players.each do |username, p|
      player = Player.find_by(username: username)
      dep_players = DepartmentPlayer.where({username: username})
      next if dep_players.nil?
      dep_players.each do |dep_player|
        next if dep_player.department.nil?
        dep_name = dep_player.department.name
        if not departments.include?(dep_name)
          new_dep = {name: dep_name, players: {}, count: 1}
          FIELDS.each do |f|
            new_dep[f] = 0
          end
          departments[dep_name] = new_dep
        else
          departments[dep_name][:count] = departments[dep_name][:count] + 1
        end
        departments[dep_name][:players][username] = p
        FIELDS.each do |f|
          departments[dep_name][f] = departments[dep_name][f] + p[f]
        end
      end
    end
    departments
  end

  def self.ranking(n_weeks)
    sorted_players = Ranking.combined_players_sorted(n_weeks)
    departments = group_by_department(sorted_players)
    sorted_departments = departments.sort_by{|k, v| (v[:rating] / v[:count].to_f)}.reverse

    rows = []
    idx = 0
    sorted_departments.each do |dep_name, d|
      idx = idx + 1
      rows << ["#{idx}", d[:name], '%.2f' % (d[:rating] / d[:count].to_f), d[:wins] + d[:losses], d[:wins], d[:losses], d[:goals_for], d[:goals_against], d[:goals_for] - d[:goals_against]]
    end
    table = Terminal::Table.new :title => "Team ranking", :headings => ["Pos", "Name", "Rat.", "GP", "W", "L", "GF", "GA", "GD"], :rows => rows
    #     table.align_column(8, :right) # right align the diff column content
    #     table.align_column(9, :center) # center align the rating column content

      "```#{table}```

Pos: Rating position. Rat: rating. GP: Games played. W: Won. L: Lost. GF: Goals For. GA: Goals against. GA: Goals diff.
"
  end
end
