* ==============================================================================
*
* Project         : Estimating Living Wage (KHL) 2025 
* Description     : Adult Equivalent Energy Intake (AEEI) scale - FAO
* Stata version   : 16 
* Date created    : October 30, 2025 - by Bertha
* Last modified   : October 30, 2025 - by Bertha
*
* ==============================================================================

  capture:  log close
  clear     all
  set more  off

  log using   "$logs/1a_assumptions.log", replace
   
**# Prepare dataset 
  
    use     "$rawdata/KOR25IND_merge.dta", clear 

**# Adult Equivalent Energy Intake (AEEI) scale - FAO
      
    /*Source: FAO, Human Energy Requirements, Report of a Joint FAO/WHO/UNU Expert
    Consultation, Rome, 17–24 October 2001. For these age ranges, we used the median
    weight (65kg for female and 70kg for male) and the basal metabolic rate of 1.75 for a
    moderate PAL implied by a normal lifestyle.*

    See the ILO manual page 19: https://www.ilo.org/sites/default/files/2025-04/254_499_EN07.pdf
    */

    * Generate the coefficient for adult equivalent using the FAO measurement
      
      gen     aeei_coef = .
      
      replace aeei_coef = 0.29 if R407 == 0
      replace aeei_coef = 0.29 if R407 == 1 & R405 == 2
      replace aeei_coef = 0.32 if R407 == 1 & R405 == 1

      replace aeei_coef = 0.36 if R407 == 2 & R405 == 2
      replace aeei_coef = 0.38 if R407 == 2 & R405 == 1

      replace aeei_coef = 0.39 if R407 == 3 & R405 == 2
      replace aeei_coef = 0.42 if R407 == 3 & R405 == 1

      replace aeei_coef = 0.42 if R407 == 4 & R405 == 2
      replace aeei_coef = 0.46 if R407 == 4 & R405 == 1

      replace aeei_coef = 0.45 if R407 == 5 & R405 == 2
      replace aeei_coef = 0.50 if R407 == 5 & R405 == 1

      replace aeei_coef = 0.48 if R407 == 6 & R405 == 2
      replace aeei_coef = 0.53 if R407 == 6 & R405 == 1

      replace aeei_coef = 0.53 if R407 == 7 & R405 == 2
      replace aeei_coef = 0.58 if R407 == 7 & R405 == 1

      replace aeei_coef = 0.58 if R407 == 8 & R405 == 2
      replace aeei_coef = 0.62 if R407 == 8 & R405 == 1

      replace aeei_coef = 0.63 if R407 == 9 & R405 == 2
      replace aeei_coef = 0.67 if R407 == 9 & R405 == 1

      replace aeei_coef = 0.68 if R407 == 10 & R405 == 2
      replace aeei_coef = 0.73 if R407 == 10 & R405 == 1

      replace aeei_coef = 0.73 if R407 == 11 & R405 == 2
      replace aeei_coef = 0.80 if R407 == 11 & R405 == 1

      replace aeei_coef = 0.77 if R407 == 12 & R405 == 2
      replace aeei_coef = 0.86 if R407 == 12 & R405 == 1

      replace aeei_coef = 0.81 if R407 == 13 & R405 == 2
      replace aeei_coef = 0.94 if R407 == 13 & R405 == 1

      replace aeei_coef = 0.83 if R407 == 14 & R405 == 2
      replace aeei_coef = 1.02 if R407 == 14 & R405 == 1

      replace aeei_coef = 0.85 if R407 == 15 & R405 == 2
      replace aeei_coef = 1.08 if R407 == 15 & R405 == 1

      replace aeei_coef = 0.85 if R407 == 16 & R405 == 2
      replace aeei_coef = 1.13 if R407 == 16 & R405 == 1

      replace aeei_coef = 0.85 if R407 == 17 & R405 == 2
      replace aeei_coef = 1.15 if R407 == 17 & R405 == 1

      replace aeei_coef = 0.85 if R407 == 18 & R405 == 2
      replace aeei_coef = 1.15 if R407 == 18 & R405 == 1

      replace aeei_coef = 0.86 if R407 >= 19 & R407 < 30 & R405 == 2
      replace aeei_coef = 1.03 if R407 >= 19 & R407 < 30 & R405 == 1

      replace aeei_coef = 0.81 if R407 >= 30 & R407 <= 60 & R405 == 2
      replace aeei_coef = 1.00 if R407 >= 30 & R407 <= 60 & R405 == 1

      replace aeei_coef = 0.75 if R407 > 60 & R407 != . & R405 == 2
      replace aeei_coef = 0.83 if R407 > 60 & R407 != . & R405 == 1

      egen    aeei_hh   = sum(aeei_coef), by(URUT)

**# Adult Equivalent OECD
      
    /*
    See the ILO manual page 22: https://www.ilo.org/sites/default/files/2025-04/254_499_EN07.pdf
    - To account for family size and reflect living standards, we could simply
    divide the total household expenditure by the number of household members. 
    - However, because there are economies of scale when several individuals live together 
    and because children have lower material needs than adults, estimating per capita expenditure requires
    the use of equivalence scales (ILO 2015). 
    - Therefore, in this baseline methodology, we suggest using the OECD adult equivalence scale (the Oxford scale), 
    which typically assigns a value of 1 to the household head, 0.7 to each additional adult member and 0.5 to each child. 
    - Once this is done, we rank the households from the poorest to the richest and create quintiles on
    the basis of their total monthly expenditure per adult equivalent.
    */

    gen     aeq = .
    replace aeq = 1   if R405 == 1 &    R407 >= 18
    replace aeq = 0.7 if R405 != 1 &    R407 >= 18
    replace aeq = 0.5 if                R407 < 18
    order   URUT R405 R407 aeq

    egen    aeq_hh = sum(aeq), by(URUT)

    label   variable aeq_hh "Adult Equivalent in the HH"


    * Number of Adults
    gen     adult = 1 if R407 >= 18
    replace adult = 0 if R407 < 18
    egen    adult_hh = sum(adult), by (URUT)

    keep    R101 R102 R105 URUT aeq_hh aeei_hh adult_hh
    duplicates drop

    save "$data/adultequi", replace

**# Household Size 

    use     "$rawdata/BLOK42_append.dta", clear  
    
    keep    URUT R101 R301 WERT WEIND
    duplicates drop URUT, force                    // One row per household    
    
    sum     R301 [aw=WERT], detail

    save    "$data/hh_size.dta", replace 
       
    * By Province
    preserve

    collapse (mean) R301 [aw=WERT], by(R101)
    gen     hh_size = round(R301, 0.01) 
    drop    R301

    export  excel using "$output/1_assumption.xlsx", ///
            firstrow(variables) sheet("HH Size") sheetmodify
    
    save   "$data/hh_size_prov.dta", replace 

    restore

    * Adult equivalent by household size
    merge   1:1 URUT using "$data/adultequi"
    drop    _merge
    
    preserve
    collapse (mean) aeq_hh aeei_hh [aw=WERT], by(R301)  
    export  excel using "$output/1_assumption.xlsx", ///
            firstrow(variables) sheet("Adult Equivalent_National") sheetmodify
    restore
   
    preserve
    collapse (mean) aeq_hh aeei_hh [aw=WERT], by(R101 R301) 
    export  excel using "$output/1_assumption.xlsx", ///
            firstrow(variables) sheet("Adult Equivalent_Province") sheetmodify
    restore

    keep if R301 == 4


    use     "$rawdata/KOR25IND_merge.dta", clear 
    rename  *, upper 

    keeporder URUT R101 R707 R407

**# Working Adults 

    use     "$rawdata/KOR25IND_merge.dta", clear 
    rename  *, upper 

    keeporder URUT R101 R707 R706 R407 

    // working adult, income earners, wage earners
    gen     working_adult   = 1 if (R706<=6 & R407>=15 & R706!=.) // working adult 
    replace working_adult   = 0 if working_adult == .

    
    gen     income_earners  = 1 if (R706<=5 & R407>=15 & R706!=.) // income earner
    replace income_earners  = 0 if income_earners == .


    gen     wage_earners    = 1 if (R706==4 & R407>=15 & R706!=.) // wage earner
    replace wage_earners    = 0 if wage_earners == .

    // full time 
    gen     working_adult_ft    = (working_adult == 1 & R707 >= 35)
    replace working_adult_ft    = 0 if working_adult_ft == .

    gen     income_earners_ft   = (income_earners == 1 & R707 >= 35)
    replace income_earners_ft   = 0 if income_earners_ft == .

    gen     wage_earners_ft     = (wage_earners == 1 & R707 >= 35)
    replace wage_earners_ft     = 0 if wage_earners_ft == .


    collapse (sum) working_adult working_adult_ft income_earners income_earners_ft wage_earners wage_earners_ft, by(URUT)

    merge   1:1 URUT using "$data/hh_size.dta"

    * Full time worker at national level 

    sum     working_adult_ft income_earners_ft wage_earners_ft [aw=WERT]
    sum     income_earners_ft [aw=WERT], detail
    
    preserve
    collapse (mean) working_adult working_adult_ft income_earners income_earners_ft wage_earners wage_earners_ft [aw=WERT], by(R301)
    export  excel using "$output/1_assumption.xlsx", ///
            firstrow(variables) sheet("FT workers_national") sheetmodify
    restore
    
  
    * Full time worker at province level 
    collapse (mean) working_adult working_adult_ft income_earners income_earners_ft wage_earners wage_earners_ft [aw=WERT], by(R101 R301)
    export  excel using "$output/1_assumption.xlsx", ///
            firstrow(variables) sheet("FT workers_province") sheetmodify
   
    keep if R301 == 4

    keeporder R101 R301 working_adult_ft income_earners_ft wage_earners_ft
    do      "$dofile/sub/0_labeling_province.do"


    save    "$data/full_time.dta", replace




        
   

