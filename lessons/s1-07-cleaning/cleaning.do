capture log close                       // closes any logs, should they be open
set linesize 90
log using "cleaning.log", replace    // open new log

// NAME: Data cleaning
// FILE: lecture9_cleaning.do
// AUTH: Will Doyle
// REVS: Benjamin Skinner
// INIT: 15 October 2014
// LAST: 24 Ocotber 2017
  
clear all                               // clear memory
set more off                            // turn off annoying "__more__" feature

// load CA school data with problems
use caschool_problem, replace


// label data

la data "California school district-level data from 1998" 


// replacing problematic variable labels 
describe
label variable observation_number "Unit ID"
label variable gr_span "Grade Span"

// I AM MAKING AN ASSUMPTION ABOUT THIS VARIABLE//
// WE REALLY REALLY NEED TO CHECK THIS *****  //

la var teachers "Full time equivalent teachers" 

la var calw "Percent of students whose parents are enrolled in CalWorks"

la var meal_pct "Percent of students eligible for free/reduced price meals" 

la var computer "Number of computers in the district" 

la var testscr "Academic Performance Index score" 

la var comp_stu "Number of computers per student" 

la var str "Student/Teacher Ratio"

// I AM MAKING AN ASSUMPTION ABOUT THIS VARIABLE//
// WE REALLY REALLY NEED TO CHECK THIS *****  //

la var avginc "Average income (maybe)" 

la var el_pct "English language learners percent" 


//Flag this for missing ***** //
la var read_scr "Average reading score"

//Flag this for missing ***** //
la var math_scr "Average math score"  

la var foo "Unknown variable" 


// LOOKING FOR OUTLIERS WITH VARIOUS PLOTS

// box plot str
graph box str, name(box_str)
graph export  box_str.eps, name(box_str) replace

// histogram str
histogram str, name(hist_str)
graph export  hist_str.eps, name(hist_str) replace

// NOTE: student teacher ratio for observation #121 coded incorrectly (was 47.4, ratio is about 18
// Code below replaces for this district 
replace str =enrl_tot/teachers if observation_number==121

// NOTE: student teacher ratio for observation #301 coded incorrectly (was 34, ratio is about 18
// Code below replaces for this district 
replace str =enrl_tot/teachers if observation_number==301

// IMPOSSIBLE VALUES 

// summarize calw percent
sum calw_pct

// Remove impossible values for calworks because some schools recorded more than 100
replace calw_pct =. if calw_pct>100

// LOOKING FOR IMPLAUSIBLE VALUES WITH VARIOUS PLOTS

// twoway scatter of avginc and meal_pct
graph twoway scatter avginc meal_pct, name(sc_inc_meal)
graph export  sc_inc_meal.eps, name(sc_inc_meal) replace

// CHECKING CALCUATIONS

// create new student teacher ratio variable
gen str_two = enrl_tot / teachers

// twoway scatter of both student teacher ratio variables
graph twoway scatter str_two str, name(sc_str_str_two)
graph export  sc_str_str_two.eps, name(sc_str_str_two) replace

// assume negative means missing and drop
replace teachers = . if teachers == -4

// create another new student teacher ratio variable
gen str_three = enrl_tot / teachers

// twoway scatter of new new and old student teacher ratio variables
graph twoway scatter str_three str, name(sc_str_str_three)
graph export  sc_str_str_three.eps, name(sc_str_str_three) replace

// LOOKING FOR DUPLICATES 

// check for duplicate observations
duplicates report observation_number

// check for duplicate district cod
duplicates report dist_cod

// CHECK FOR NEGATIVE VALUES, MISSING DATA

// inspect test scores
inspect testscr

// inspect reading scores
inspect read_scr

// plot reading scores for further investigation
histogram read_scr, name(hist_read_scr)
graph export hist_read_scr.eps, name(hist_read_scr) replace                                              

// end file     
log close
exit
