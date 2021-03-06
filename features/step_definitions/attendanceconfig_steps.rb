Given /^User have Attendance Configuration First Shift created$/ do
  AttendanceConfiguration.create(:attendance=> "First Shift", short_name: "FS", salary_calendar_days: "Actual Days / Month")
end

Then /^Attendance Configuration "(.*?)" should be deleted$/ do |value|
  AttendanceConfiguration.delete(value)
end

Then /^AttendanceConfiguration count should increase by (\d+)$/ do |count|
  AttendanceConfiguration.count.should == count.to_i
end