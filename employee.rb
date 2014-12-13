# inheritance practice

class Employee
  attr_reader :salary
  
  def initialize(name, title, salary, boss = nil)
    @name, @title, @salary, @boss = name, title, salary, boss
  end
  
  def bonus(multiplier)
    @salary * multiplier
  end
end

class Manager < Employee
  attr_reader :employees
  
  def initialize(name, title, salary, boss = nil)
    super 
    @employees = []
  end
  
  def bonus(multiplier)
    all_sub_employees = employees.dup
    employee_salary_sum = 0
    
    all_sub_employees.each do |employee|
      if employee.is_a?(Manager)
        all_sub_employees += employee.employees
      end
      employee_salary_sum += employee.salary
    end
    
    employee_salary_sum * multiplier
  end
end

bob = Employee.new('bob', 'janitor', 27_000, 'Steve')
jody = Employee.new('jody', 'scientist', 30_000, 'Steve')
steve = Manager.new('steve','shift manager', 33_750)
steve.employees << bob
steve.employees << jody

p "Bob's bonus: #{bob.bonus(3)}. Steve's bonus: #{steve.bonus(3)}"