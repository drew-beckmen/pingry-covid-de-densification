require 'csv'
require_relative '../config/environment'

classes_to_delete = []
CSV.foreach('/Users/drewbeckmen/Desktop/pingry-data/all_classes.csv', headers: true) do |row|
    x, class_id = row[0], row[1]
    if x == "x"
        classes_to_delete << class_id.to_i 
    end 
end 

classes_to_delete.each do |course_id|
    Course.where(class_number: course_id).destroy_all
end
# puts Course.all.length  //=> now 855 from 879

pp Course.all.select {|course| course.students.length > 25 }.map{|course| course.class_number}
# [36635 (Intro Fit), 36633 (Intro Fit), 36634 (Intro Fit), 36804 (CP Glee Club - 30 Students)]

