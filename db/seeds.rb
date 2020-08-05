require 'csv'

Course.destroy_all 
Enrollment.destroy_all 
Student.destroy_all 

CSV.foreach('/Users/drewbeckmen/Desktop/pingry-data/db/dataset.csv', headers: true) do |row|
    course_number, family_number, family_name = row[0], row[1], row[2]
    course_numer = course_number.to_i 
    family_number = family_number.to_i 
    family_alphabet_number = family_name[0].downcase.ord - 96
    current_student = Student.find_or_create_by(household_name: family_name, household: family_number, place_in_alphabet: family_alphabet_number, cohorted: false)
    current_course = Course.find_or_create_by(class_number: course_number)
    Enrollment.create(course_id: current_course.id, student_id: current_student.id)
end
