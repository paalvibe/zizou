class DepartmentPlayer < ActiveRecord::Base
  belongs_to :department
  belongs_to :player
end
