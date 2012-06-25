class Evaluator

  def self.formula(formula, values)
    # remove anything but GROSS, numbers, ()'s, decimal points, and basic math operators
    formula.gsub!(/((?![(GROSS)0-9\s\.\-\+\*\/\(\)]).)*/,'').upcase!
    begin
      formula.gsub!(/(GROSS)/) { |match|
        (
        values[match.to_sym] && values[match.to_sym].class.ancestors.include?(Numeric) ? values[match.to_sym].to_s : '0'
        )
      }
      instance_eval(formula)
    rescue Exception => e
      e.inspect
    end
  end

  #def self.formula gross_salary, salary_structure
  #  salary = 0.0
  #  salary_structure.each do |k,v|
  #    v.gsub! Regexp.new("GROSS"), gross_salary.to_s
  #    v.match /[0-9*+-]/
  #    result = eval(v)
  #    salary += result
  #  end
  #  salary
  #end

end