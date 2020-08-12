require_relative '../config/environment'
require 'csv'

#---------- Running a single simulation-------------------------------------------------------------------
    # Params: Array of numbers representing letter of alphabet to be cohorted
        # For example: [1, ...,  13] means people with last names in first half of alphabet to be cohorted

def updated_cohorted_field(letters)
    bool = true    #true for cohort 1.5 blue day, false for cohort 1.5 white day  
    # boolB = false     
    # boolM = false      
    Student.all.each do |family|
        if letters.include?(family.place_in_alphabet)
            
            # Uncomment below for cohort 2.5
            # if family.place_in_alphabet == 13
            #     if boolM 
            #         family.update(cohorted: true)
            #     end 
            #     boolM = !boolM
            # elsif family.place_in_alphabet == 3 
            #     if boolB 
            #         family.update(cohorted: true)
            #     end 
            #     boolB = !boolB 
            # else 
            #     family.update(cohorted: true)
            # end

            # Uncomment below for cohort 1.5 
            if family.place_in_alphabet == 19
                if bool 
                    family.update(cohorted: true)
                end 
                bool = !bool
            else 
                family.update(cohorted: true)
            end 

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
            if percent_reduction >= 40 || number_students_remaining_in_class <= 8 
                counter += 1
            end 
            percent_reduction_hash[class_identifier] = percent_reduction
            csv << [class_identifier, number_students_before_cohorting, number_students_remaining_in_class, percent_reduction]
        end 
    end 
    percent_reduction_array = percent_reduction_hash.values 
    original_students_per_class_array = original_class_size_hash.values 
    new_students_per_class_array = reduced_class_size_hash.values 
    # binding.pry   
    # --------Graph for After Cohorting ------------------------------
    g = Gruff::Histogram.new 
    g.theme = {
        colors: %w(purple green),
        marker_color: 'blue',
        background_colors: ['white', 'grey'],
        background_direction: :top_bottom
    }
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
    b.theme = {
        colors: %w(purple green),
        marker_color: 'blue',
        background_colors: ['white', 'grey'],
        background_direction: :top_bottom
    }
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
    puts "Percentage of Families in School: #{percentage_families_remaining_in_school}"
    puts "Mean:  #{new_students_per_class_array.mean}"
    puts "Median: #{new_students_per_class_array.median}"
    puts "Variance: #{new_students_per_class_array.variance}"
    puts "Standard Dev: #{new_students_per_class_array.standard_deviation}"
    puts "Number of Courses Reduced By 50% or Less Than or Equal To 10 People: #{counter}"
    puts "Percentage of All Courses Reduced By 50% or Less Than 10 People: #{counter/Course.all.length.to_f}"

    # return a list of all the household ids being sent home
    households_at_home = Student.all.where(cohorted: true).map{|family| family.household}
    reset_students
    [households_at_home, reduced_class_size_hash]
end 


# Summary on People at School Given Household Ids at Home-----------------

# Returns a hash of # of students in each grade going to school given households staying home
def students_per_grade_cohorted(households_at_home)
    return_hash = {}
    Individual.all.each do |person| 
        if !households_at_home.include?(person.household_id)
            if return_hash[person.grade_level]
                return_hash[person.grade_level] += 1
            else 
                return_hash[person.grade_level] = 1
            end  
        end 
    end 
    return_hash
end 

# Returns a hash of # of total students in each grade 
def calculate_total_students_per_grade
    return_hash = {}
    Individual.all.each do |person| 
        if return_hash[person.grade_level]
            return_hash[person.grade_level] += 1
        else 
            return_hash[person.grade_level] = 1
        end 
    end 
    return_hash 
end
#--------------------------------------------------------------------------

# Candidates for Cohorting--------------------------------------

# Cohort 1 (Frequency): [17, 19, 9, 13, 21, 16, 24, 5, 2, 3, 25, 7, 12] AND [1, 4, 6, 8, 10, 11, 14, 15, 18, 20, 22, 23, 26]
    # Cohort 1.5 (toggle bool in updated cohorted field, get rid of bool for regular cohorting): 
        #[17, 19, 9, 13, 21, 16, 24, 5, 2, 3, 25, 7, 12] (true) AND [1, 4, 6, 8, 10, 11, 14, 15, 19, 18, 20, 22, 23, 26] (false)
# Cohort 2 (A-M): [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13] AND [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26]
    # Cohort 2.5 [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13] (true) AND [3, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26] (false)

# Cohort 1.5 White Day
letters = [17, 19, 9, 13, 21, 16, 24, 5, 2, 3, 25, 7, 12]#[1, 4, 6, 8, 10, 11, 14, 15, 19, 18, 20, 22, 23, 26] #[17, 19, 9, 13, 21, 16, 24, 5, 2, 3, 25, 7, 12]
households_staying_home, class_size_hash = simulate(letters)
households_staying_home = households_staying_home + [11799, 83455, 84314, 58603, 78734, 81672, 81253, 61776, 18695, 79778] - [61324, 80972, 83115, 9376, 23957, 81451, 79789]

CSV.open('cohorts.csv', "w") do |csv|
    households_staying_home.each do |household_id|
        csv << [household_id, Student.find_by(household: household_id).household_name, "White"]
    end 
    all_other_households = Student.all.map{|student| student.household} - households_staying_home
    all_other_households.each do |household_id|
        csv << [household_id, Student.find_by(household: household_id).household_name, "Blue"]
    end 
end 

small_classes_left = class_size_hash.filter{|k, v| v < 4}
pp small_classes_left.keys # in case you want to get class ids for classes less than a given size
# binding.pry

# Export class size data to csv (already within)
# class_size_hash = class_size_hash.to_a
# CSV.open('class_size2.csv', "w") do |csv|
#     class_size_hash.each do |row|
#         csv << row 
#     end     
# end 

students_per_grade_remaining = students_per_grade_cohorted(households_staying_home)
totals_per_grade = calculate_total_students_per_grade
pp students_per_grade_remaining
percentage_by_grade = students_per_grade_remaining.map {|k, v| v.to_f/totals_per_grade[k] }
pp percentage_by_grade
puts "Number of Students in School: #{students_per_grade_remaining.values.sum}. Percentage:  #{students_per_grade_remaining.values.sum.to_f / Individual.all.length}"


# lower_school_in_school = 0 
# lower_school_total = 0
# 5.times do |i|
#     lower_school_in_school += students_per_grade_remaining[i]
#     lower_school_total += totals_per_grade[i]
# end 
# puts "Number Students in Short Hills: #{lower_school_in_school}"
# puts "Total Number Students in Short Hills: #{lower_school_total}"


# middle_school_in_school = 0
# middle_school_total = 0 
# (5..7).each do |i|
#     middle_school_in_school += students_per_grade_remaining[i]
#     middle_school_total += totals_per_grade[i]
# end 
# puts "Number Students in Middle School: #{middle_school_in_school}"
# puts "Total Number Students in Middle School: #{middle_school_total}"

# upper_school_in_school = 0
# upper_school_total = 0 
# (8..12).each do |i|
#     upper_school_in_school += students_per_grade_remaining[i]
#     upper_school_total += totals_per_grade[i]
# end 
# puts "Number Students in Upper School: #{upper_school_in_school}"
# puts "Total Number Students in Upper School: #{upper_school_total}"

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

# arr_frequencies = check_last_name_frequency
# conversions = {1 =>  "A", 2 =>  "B", 3 =>  "C", 4 =>  "D", 5 =>  "E", 6 =>  "F", 7 =>  "G", 8 =>  "H", 9 =>  "I", 10 =>  "J", 11 =>  "K", 12 =>  "L", 13 =>  "M", 14 =>  "N", 15 =>  "O", 16 =>  "P", 17 =>  "Q", 18 =>  "R", 19 =>  "S", 20 =>  "T", 21 =>  "U", 22 =>  "V", 23 =>  "W", 24 =>  "X", 25 =>  "Y", 26 =>  "Z"}
# arr_frequencies = arr_frequencies.map{|pair| [conversions[pair[0]], pair[1]]}
# # pp arr_frequencies.reduce(0) {|acc, pair| acc + pair[1]}
# CSV.open('frequency.csv', "w") do |csv|
#     arr_frequencies.each do |row|
#         csv << row 
#     end 
# end 

#-------------------------------------------------------
    # Max Function for Class Size on Any Given Day
def max_class_size
    class_size_hash = {}
    CSV.foreach('/Users/drewbeckmen/Desktop/pingry-data/class_size.csv', headers: false) do |row|
        class_id, number_students = row[0].to_i, row[1].to_i
        class_size_hash[class_id] = [number_students]
    end
    
    CSV.foreach('/Users/drewbeckmen/Desktop/pingry-data/class_size2.csv', headers: false) do |row|
        class_id, number_students = row[0].to_i, row[1].to_i
        class_size_hash[class_id] << number_students
    end
    class_size_hash.each{|k, v| class_size_hash[k] = v.max }
    histogram_values = class_size_hash.values 

    b = Gruff::Histogram.new 
    b.theme = {
        colors: %w(purple green),
        marker_color: 'blue',
        background_colors: ['white', 'grey'],
        background_direction: :top_bottom
    }
    b.bin_width = 1
    b.spacing_factor = 0
    b.title = "Max Course Sizes After Cohorting"
    b.x_axis_label = "Students Per Class"
    b.y_axis_label = "Number of Courses" 
    b.label_max_size = 2
    b.marker_font_size = 15
    b.minimum_bin = 0
    b.maximum_bin = 30
    b.data :MaxSizes, histogram_values
    b.write('max_class_sizes.png')

    puts "Mean:  #{histogram_values.mean}"
    puts "Median: #{histogram_values.median}"
    puts "Variance: #{histogram_values.variance}"
    puts "Standard Dev: #{histogram_values.standard_deviation}"
end 

# max_class_size
#----------------------------------------------------