* ==============================================================================
*
* Project         : Estimating Living Wage (KHL) 2024 
* Description     : Identify Reference Quintile (National and Province)
* Stata version   : 16 
* Date created    : October 30, 2025 - by Bertha
* Last modified   : October 30, 2025 - by Bertha
*
* ==============================================================================

  capture:  log close
  clear     all
  set more  off

  log using   "$logs/2d_reference_quintile.log", replace

**# DATA PREPARATION 

    * Load dataset
    use     "$data/corefood.dta", clear  
   
    duplicates drop URUT, force                                 // One row per household
    
    merge   1:1 URUT using "$data/quintiles_province.dta"
    drop    _merge

**# REFERENCE QUINITLE

    * Generate Daily Calorie Intake
    gen     food_exp_monthly    = food_exp_weekly * (30/4)      // Convert to monthly
    gen     food_exp_pc         = food_exp_monthly/R301         // Per capita
    gen     calorie_pc          = calories/R301
    gen     protein_pc          = protein/R301
    gen     pc_caldaily         = daily_calinHH/R301

    sum     pc_caldaily, detail

    * Calorie Intake by Quintile - National
    
    table   quintile_pc [aweight = WEIND], contents(mean pc_caldaily)               // final
    table   quintile_pc if R105 == 1 [aweight = WEIND], contents(mean pc_caldaily)  // final
    table   quintile_pc if R105 == 2 [aweight = WEIND], contents(mean pc_caldaily)  // final
    
    preserve
    collapse (mean) pc_caldaily [aw=WEIND], by(quintile_pc)
    gen     cal_optimal = $cal_optimal
    gen     cal_diff    = abs(pc_caldaily-cal_optimal)
    egen    min_diff    = min(cal_diff)
    gen     is_min_diff = (cal_diff == min_diff)

    export  excel using "$output/2_reference_quintile.xlsx", ///
            firstrow(variables) sheetmodify sheet("National") 
    restore

    * Calorie Intake by Quintile - Province
    collapse (mean) pc_caldaily [aw=WEIND], by(R101 quintile_pc_province)
    gen     cal_optimal = $cal_optimal
    gen     cal_diff    = abs(pc_caldaily-cal_optimal)
    egen    min_diff    = min(cal_diff), by(R101)
    gen     is_min_diff = (cal_diff == min_diff)

    export  excel using "$output/2_reference_quintile.xlsx", ///
            firstrow(variables) sheetmodify sheet("Province")  

    preserve
    merge   1:m R101 quintile_pc_province using "$data/quintiles_province.dta"
    drop    _merge

    save    "$data/prov_reference_quintile.dta", replace
    restore

    * Merge with Non-Food Expenditure Data
    merge   1:1 R101 quintile_pc_province using "$data/prov_meanexp_hltheduoth.dta" 
    

    * Reference quintile 

        // If fixed at national level
        if $q_fixed == 1 {
            keep if quintile_pc_province == $quintile
        }
        // If based on province reference quintile
        if $q_fixed == 0 {
            keep if is_min_diff==1
        }


    keep    R101 education_exp_pc- indonesia_exp_aeq

    merge   1:1 R101 using "$data/prov_meanexp_rent_utility.dta"
    drop    _merge

    save    "$data/nonfood_exp.dta", replace

