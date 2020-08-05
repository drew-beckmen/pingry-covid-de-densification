require_relative '../config/environment'
#---------- Running a single simulation-------------------------------------------------------------------
    # Params: Array of numbers representing letter of alphabet to be cohorted
        # For example: [1, ...,  13] means people with last names in first half of alphabet to be cohorted

def updated_cohorted_field(letters) 
    Student.all.each do |family|
        if letters.include?(family.place_in_alphabet)
            family.update(cohorted: true)
        end 
    end 
end

def reset_students
    Student.all.each {|family| family.update(cohorted: false)}
end 

def simulate
    g = Gruff::Histogram.new 
    g.title = "Cohort A-M"
    letters = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]
    updated_cohorted_field(letters)
    results_hash = {}
    Course.all.each do |single_course|
        class_identifier = single_course.class_number 
        number_students_before_cohorting = single_course.students.length 
        number_students_after_cohorting = single_course.students.where(cohorted: true).length
        percent_reduction = (number_students_after_cohorting.to_f / number_students_before_cohorting.to_f) * 100
        results_hash[class_identifier] = percent_reduction
    end 
    percent_reduction_array = results_hash.values 
    g.data :Reduction, percent_reduction_array
    g.write('histogram.png')
    reset_students
    results_hash 
end 

pp simulate