class Department < ActiveRecord::Base
  has_many :department_players

  def self.find_by_name(name)
    Department.find_by(name: name.upcase)
  end

  def self.add_user(dep_name, username)
    begin
      raise "Missing department name" if dep_name.blank?
      department = Department.create_or_update({name: dep_name})
      player = DepartmentPlayer.find_or_create_by(department: department, username: username)
      department.department_players << player
      department.save
      "User <@#{username}> added to department #{dep_name}"
    rescue
      "Error adding user <@#{username}> to department #{dep_name}"
    end
  end

  def self.remove_user(dep_name, username)
    begin
      department = Department.create_or_update({name: dep_name})
      player = DepartmentPlayer.find_by(username: username, department: department)
      department.department_players.delete(player)
      player.destroy
      "User <@#{username}> removed from department #{dep_name}"
    rescue
      "Error removing user <@#{username}> from department #{dep_name}"
    end
  end

  def self.create_or_update(options = {})
    department = Department.find_by(name: options[:name])

    if department.blank?
      department = Department.create(options)
    else
      department.update(options)
    end

    department
  end

    def str_rep()
      "department: #{self.name}\n  players: " + self.department_players.map { |p| "<@#{p.username}>" }.join(" ")
    end
end
