* ==============================================================================
*
* Project         : Estimating Living Wage (KHL) 2024 
* Description     : Assess Food Expenditure by Subgroup, Quintile, and Province
* Stata version   : 16 
* Date created    : October 30, 2025 - by Bertha
* Last modified   : October 30, 2025 - by Bertha
*
* ==============================================================================

  capture:  log close
  clear     all
  set more  off

  log using   "$logs/2e_food_expenditure.log", replace

**# DATA PREPARATION 

    * Load dataset
    use     "$data/corefood.dta", clear

    * Calculate median price
    gen     price_hh            = (B41K10*(30/7))/consumption_kg2
    egen    price_median        = median(price_hh), by (KODE)
    egen    price_median_province = median(price_hh), by (R101 KODE)
    egen    price_median_fn     = median(price_median), by(KLP)

  
**# FOOD EXPENDITURE  

    gen     cal_intdaily        = cal_int * (12/365)
    gen     cal_intdaily_pc     = cal_intdaily/R301
    gen     protein_intdaily    = protein_int * (12/365)
    gen     protein_intdaily_pc = protein_intdaily/R301
    gen     qty_daily           = consumption_kg2 * (12/365)
    gen     qty_daily_pc        = qty_daily/R301
    gen     qty_value_pc        = qty_daily_pc * price_median
    gen     qty_value_pc_prov   = qty_daily_pc * price_median_province

    keep    URUT R101 WEIND quintile_pc KLP cal_intdaily_pc qty_daily_pc protein_intdaily_pc qty_value_pc qty_value_pc_prov 

    egen    klp_hh_pc           = sum(cal_intdaily_pc), by(URUT KLP)
    egen    klp_hh_qty          = sum(qty_daily_pc), by(URUT KLP)
    egen    klp_hh_protein      = sum(protein_intdaily_pc), by(URUT KLP)
    egen    klp_hh_value        = sum(qty_value_pc), by(URUT KLP)
    egen    klp_hh_value_prov   = sum(qty_value_pc_prov), by(URUT KLP)

    duplicates drop URUT KLP, force                    // One row per household and KLP

    save    "$data/corefood_atklp.dta", replace
    
    /*
    table   KLP [aweight= WEIND], contents(mean klp_hh_pc)
    table   KLP [aweight= WEIND], contents(mean klp_hh_qty)
    table   KLP [aweight= WEIND], contents(mean klp_hh_protein)
    table   KLP [aweight= WEIND], contents(mean klp_hh_value)
    */
    
    preserve
    collapse (mean) klp_hh_pc klp_hh_qty klp_hh_protein klp_hh_value [aw=WEIND], by(KLP)
    export  excel using "$output/2_corefood_atklp.xlsx", ///
            firstrow(variables) sheetmodify sheet("All")  
    restore

    * Taking a reference quintile 
    preserve
    keep    if quintile_pc == $quintile   
    collapse (mean) klp_hh_pc klp_hh_qty klp_hh_protein klp_hh_value [aw=WEIND], by(KLP)
    export  excel using "$output/2_corefood_atklp.xlsx", ///
            firstrow(variables) sheetmodify sheet("Quintile_$quintile")  
    restore


**# FOOD DISTRIBUTION
    
    clear
    use     "$data/corefood_atklp.dta", clear
    merge   m:1 R101 URUT using "$data/prov_reference_quintile.dta" 

    * Reference quintile 
    
        // If fixed at national level
        if $q_fixed == 1 {
            keep if quintile_pc_province == $quintile
        }
        // If based on province reference quintile
        if $q_fixed == 0 {
            keep if is_min_diff==1
        }

    
    * Adjustment to consumption value based on optimal calorie intake 

    collapse (mean) pc_caldaily cal_optimal klp_hh_value_prov [aw=WEIND], by(R101 KLP)
    gen     adjust_coef     = cal_optimal/pc_caldaily 
    gen     adjust_value    = adjust_coef * klp_hh_value_prov

    export  excel using "$output/2_food_exp_reference_quintile.xlsx", ///
            firstrow(variables) sheetmodify sheet("Adjustment_Coeff")

    collapse (sum) adjust_value, by(R101)
    gen     food_exp = (adjust_value*365)/12
    drop    adjust_value
    save    "$data/foodexp.dta", replace

    export  excel using "$output/2_food_exp_reference_quintile.xlsx", ///
            firstrow(variables) sheetmodify sheet("Province")
