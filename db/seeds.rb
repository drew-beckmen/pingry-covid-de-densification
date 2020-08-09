require 'csv'

Course.destroy_all 
Enrollment.destroy_all 
Student.destroy_all 
Individual.destroy_all 

CSV.foreach('/Users/drewbeckmen/Desktop/pingry-data/dataset.csv', headers: true) do |row|
    course_number, family_number, family_name = row[0], row[1], row[2]
    course_numer = course_number.to_i 
    family_number = family_number.to_i 
    family_alphabet_number = family_name[0].downcase.ord - 96
    current_student = Student.find_or_create_by(household_name: family_name, household: family_number, place_in_alphabet: family_alphabet_number, cohorted: false)
    current_course = Course.find_or_create_by(class_number: course_number)
    Enrollment.create(course_id: current_course.id, student_id: current_student.id)
end

conversions = {"Kindergarten" => 0, "Grade 1" => 1, "Grade 2" => 2, "Grade 3" => 3, "Grade 4" => 4, "Grade 5" => 5, "Grade 6" => 6, "Form I" => 7, "Form II" => 8, "Form III" => 9, "Form IV" => 10, "Form V" => 11, "Form VI" => 12}

CSV.foreach('/Users/drewbeckmen/Desktop/pingry-data/all_students.csv', headers: true) do |row| 
    student_id, household_id, grade, surname = row[0], row[1], row[2], row[3]
    grade = conversions[grade]
    Individual.create(personal_id: student_id, household_id: household_id, grade_level: grade, surname: surname)
end
