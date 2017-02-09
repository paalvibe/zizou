# -*- coding: utf-8 -*-
require 'ranking'
require 'terminal-table'

class DepartmentRanking
  fields = [:ranking, :wins, :losses, :wins, :losses, :goals_for, :goals_against]
  def group_by_department(players)
    departments = {}

    players.each do |username, p|
      player = Player.find_by(username: username)
      deps = Department.find_by_player(player)
      deps.each do |dep|
        if not departments.include?(dep.name)
          new_dep = {name: dep.name, players: {}, count: 1}
          self.fields.each do |f|
            new_dep[f] = 0
          end
          departments[:dep.name] = new_dep
        else
          departments[:dep.name][:count] = departments[:dep.name][:count] + 1
        end
        departments[:dep.name][:players][:username] = p
        self.fields.each do |f|
          departments[:dep.name][f] = departments[:dep.name][f] + p[f]
        end
      end
    end
  end

  def self.ranking(n_weeks)
    sorted_players = Ranking.combined_players_sorted(n_weeks)
    departments = group_by_department(sorted_players)
    sorted_departments = departments.sort_by{|k, v| v[:rating] / v[:count]}.reverse

    rows = []
    idx = 0
    sorted_departments.each do |dep_name, d|
      idx = idx + 1
      rows << ["#{idx}", d[:name], '%.2f' % d[:rating] / d[:count], d[:wins] + d[:losses], d[:wins], d[:losses], d[:goals_for], d[:goals_against], d[:goals_for] - d[:goals_against]]
    end
    table = Terminal::Table.new :title => "Team ranking", :headings => ["Pos", "Name", "Rat.", "GP", "W", "L", "GF", "GA", "GD"], :rows => rows
    #     table.align_column(8, :right) # right align the diff column content
    #     table.align_column(9, :center) # center align the rating column content

      "```#{table}```

Pos: Rating position. Rat: rating. GP: Games played. W: Won. L: Lost. GF: Goals For. GA: Goals against. GA: Goals diff.
"
  end
end
