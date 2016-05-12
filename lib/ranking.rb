# -*- coding: utf-8 -*-

class Ranking
  def self.combined(n_weeks)
    "todo"
#     n_weeks = n_weeks.to_i
#     from = Date.today.beginning_of_week - (n_weeks - 1).week if n_weeks > 0

#     ranking = scope.map { |player| { :rating => player.rating(from), :player => player} }
#     ranking.sort_by! { |pr| -pr[:rating] }

#     members = Slack.members
#     return "Error: Couldn't fetch members list" if members.blank?

#     rows = []

#     ranking.each_with_index do |pr, index|
#       goals_for = pr[:player].goals_scored(from)
#       goals_against = pr[:player].goals_conceded(from)
#       goal_difference = goals_for - goals_against

#       name = pr[:player].member_name()

#       rows << ["#{index+1}", name, "#{pr[:player].games_played(from)}", "#{pr[:player].won(from)}", "#{pr[:player].drawn(from)}", "#{pr[:player].lost(from)}", "#{goals_for}", "#{goals_against}", "#{goal_difference}", "#{pr[:rating].to_i}"]
#     end

#     table = Terminal::Table.new :title => "Ligapplidium: League Table", :headings => ["Rang", "Player", "P.", "W.", "D.", "L.", "GF", "GA", "Diff.", "Rating"], :rows => rows
#     table.align_column(8, :right) # right align the diff column content
#     table.align_column(9, :center) # center align the rating column content

#     "```#{table}```

# J: Games played. W: Won. T: Ties. L: Lost. GF: Goals For. GA: Goals against.
# "
  end
end
