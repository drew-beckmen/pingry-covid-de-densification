require_relative '../config/environment'
require 'csv'
#---------- Running a single simulation-------------------------------------------------------------------
    # Params: Array of numbers representing letter of alphabet to be cohorted
        # For example: [1, ...,  13] means people with last names in first half of alphabet to be cohorted

def updated_cohorted_field(letters)
    # bool = false #true for cohort 1.5 blue day, false for cohort 1.5 white day  
    boolB = false  
    boolM = false   
    Student.all.each do |family|
        if letters.include?(family.place_in_alphabet)
            
            # Uncomment below for cohort 2.5
            if family.place_in_alphabet == 13
                if boolM 
                    family.update(cohorted: true)
                end 
                boolM = !boolM
            elsif family.place_in_alphabet == 3 
                if boolB 
                    family.update(cohorted: true)
                end 
                boolB = !boolB 
            else 
                family.update(cohorted: true)
            end

            # Uncomment below for cohort 1.5 
            # if family.place_in_alphabet == 19
            #     if bool 
            #         family.update(cohorted: true)
            #     end 
            #     bool = !bool
            # else 
            #     family.update(cohorted: true)
            # end 

            # Uncomment below for all other tests
            # family.update(cohorted: true)
        end 
    end 
end

def reset_students
    Student.all.each {|family| family.update(cohorted: false)}
end 

def simulate(letters)
    updated_cohorted_field(letters)
    percent_reduction_hash = {} #can export this to histogram if you want
    original_class_size_hash = {}
    reduced_class_size_hash = {}
    counter = 0 
    # Export to CSV
    CSV.open('pingry.csv', "w") do |csv|
        Course.all.each do |single_course|
            class_identifier = single_course.class_number 
            number_students_before_cohorting = single_course.students.length 
            number_students_at_home = single_course.students.where(cohorted: true).length
            number_students_remaining_in_class = single_course.students.where(cohorted: false).length 
            reduced_class_size_hash[class_identifier] = number_students_remaining_in_class
            original_class_size_hash[class_identifier] = number_students_before_cohorting
            percent_reduction = (number_students_at_home.to_f / number_students_before_cohorting.to_f) * 100
            if percent_reduction >= 50 || number_students_remaining_in_class <= 8 
                counter += 1
            end 
            percent_reduction_hash[class_identifier] = percent_reduction
            csv << [class_identifier, number_students_before_cohorting, number_students_remaining_in_class, percent_reduction]
        end 
    end 
    percent_reduction_array = percent_reduction_hash.values 
    original_students_per_class_array = original_class_size_hash.values 
    new_students_per_class_array = reduced_class_size_hash.values 

    # --------Graph for After Cohorting ------------------------------
    g = Gruff::Histogram.new 
    g.bin_width = 1
    g.spacing_factor = 0
    g.title = "Course Sizes After Cohorting"
    g.x_axis_label = "Students Per Class"
    g.y_axis_label = "Number of Courses"
    g.label_max_size = 2
    g.marker_font_size = 15
    g.minimum_bin = 0
    g.maximum_bin = 30
    g.data :AfterCohorting, new_students_per_class_array
    g.write('after.png')
    #------------------------------------------------------------------

    #---------Graph for Before Cohorting-------------------------------
    b = Gruff::Histogram.new 
    b.bin_width = 1
    b.spacing_factor = 0
    b.title = "Course Sizes Before Cohorting"
    b.x_axis_label = "Students Per Class"
    b.y_axis_label = "Number of Courses" 
    b.label_max_size = 2
    b.marker_font_size = 15
    b.minimum_bin = 0
    b.maximum_bin = 30
    b.data :BeforeCohorting, original_students_per_class_array
    b.write('before.png')
    #-------------------------------------------------------------------

    percentage_families_remaining_in_school = Student.all.where(cohorted: false).length / Student.all.length.to_f
    reset_students
    puts "Percentage of Families in School: #{percentage_families_remaining_in_school}"
    puts "Mean:  #{new_students_per_class_array.mean}"
    puts "Median: #{new_students_per_class_array.median}"
    puts "Variance: #{new_students_per_class_array.variance}"
    puts "Standard Dev: #{new_students_per_class_array.standard_deviation}"
    puts "Number of Courses Reduced By 50% or Less Than or Equal To 8 People: #{counter}"
    puts "Percentage of All Courses Reduced By 50% or Less Than 8 People: #{counter/Course.all.length.to_f}"
end 

# Candidates for Cohorting--------------------------------------

# Cohort 1 (Frequency): [17, 19, 9, 13, 21, 16, 24, 5, 2, 3, 25, 7, 12] AND [1, 4, 6, 8, 10, 11, 14, 15, 18, 20, 22, 23, 26]
    # Cohort 1.5 (toggle bool in updated cohorted field, get rid of bool for regular cohorting): 
        #[17, 19, 9, 13, 21, 16, 24, 5, 2, 3, 25, 7, 12] (true) AND [1, 4, 6, 8, 10, 11, 14, 15, 19, 18, 20, 22, 23, 26] (false)
# Cohort 2 (A-M): [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13] AND [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26]
    # Cohort 2.5 [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13] (true) AND [3, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26] (false)

letters = [3, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26]
puts simulate(letters)

#-----------------------------------------------------------------

# Frequency Analysis on Last Names
def check_last_name_frequency
    frequency = {}
    Enrollment.all.each do |enrollment| 
        if frequency[enrollment.student.place_in_alphabet]
            frequency[enrollment.student.place_in_alphabet] += 1
        else 
            frequency[enrollment.student.place_in_alphabet] = 1
        end 
    end 
    frequency.sort_by{|k, v| v}
end 

# pp check_last_name_frequency
