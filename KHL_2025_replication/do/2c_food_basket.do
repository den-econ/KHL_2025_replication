* ==============================================================================
*
* Project         : Estimating Living Wage (KHL) 2025 
* Description     : Identify Food Basket for KHL Estimation
* Stata version   : 16 
* Date created    : October 30, 2025 - by Bertha
* Last modified   : October 30, 2025 - by Bertha
*
* ==============================================================================

  capture:  log close
  clear     all
  set more  off

  log using   "$logs/2c_food_basket.log", replace

**# DATA PREPARATION 

    * Load dataset
    use     "$rawdata/BLOK41_append.dta", clear  
    rename  *, upper 
    do      "$dofile/sub/0_labeling_province.do"
    do      "$dofile/sub/0_labeling_susenas_kp41.do"
    drop    if KLP == 0

    drop    if KODE >= 219 // drop alcoholic beverages and tobacco

    compress
    merge   m:1 KODE using "$rawdata/calorie_fnl.dta" 

    keep if _merge==3
    drop    _merge

    preserve
    collapse (first) KLP, by(KODE)
    order   KLP KODE 
    export  excel using "$output/2_commodity_basket.xlsx", ///
            firstrow(variables) sheet("Food") sheetmodify
    restore


**# FOOD BASKET 

    ********************************************************************************
    *** Food Consumption per Capita
    ********************************************************************************
    * The consumed quantity is given in kg, but weekly. Calculate monthly quantity
    gen     consumption_kg  = B41K9 * unit_of_quantity_kg * (30/7)

    * Calcule Consumption per capita
    gen     pc_quant        = consumption_kg/R301

    * For biased data, winsorize data:
    //ssc   install winsor2
    winsor2 pc_quant, cuts(1 99) by(KODE)
    gen     check = 0
    replace check = 1 if pc_quant != pc_quant_w

    * Calcule the total consumption with the winsorized data
    gen     consumption_kg2 = consumption_kg
    replace consumption_kg2 = pc_quant_w * R301 if check == 1
        
        
    * Total consumption per capita
    gen     cons_tot_kg_pc  = consumption_kg2/R301
    gen     cons_tot_kg_pc_daily = cons_tot_kg_pc/30
    gen     dailyquant_pc   = 0
    replace dailyquant_pc   = cons_tot_kg_pc_daily if cons_tot_kg_pc_daily!=.
    

    ********************************************************************************
    *** Calorie Intake
    ********************************************************************************
    // Notes: if using DKBM data, can skip this line or divide the DKBM numbers by 10
    gen     calories_kg     = calorie * 10  // with calorie_fnl
            
    gen     cal_int         = calories_kg * consumption_kg2
    egen    hh_calintake    = sum(cal_int), by (URUT) 

    * Per capita calorie consumption
    gen     daily_calinHH   = hh_calintake * (12/365) 

    merge   m:1 URUT using "$data/quintiles.dta"
    drop    _merge

    sum     daily_calinHH [aweight = WEIND], detail
    table   quintile_pc [aweight = WEIND], contents(mean daily_calinHH)

    gen     aeq_caldaily    = daily_calinHH/aeq_hh      // Calorie per adult equivalent

    * Calorie intake given by HH at the weekly level
    gen     KALORI_D    = KALORI/7
    egen    HH_KALORI   = sum(KALORI_D), by(URUT)

    * Protein
    gen     protein_kg  = protein*10
    gen     protein_int = protein_kg*consumption_kg2

    egen    hh_protintake = sum(protein_int), by(URUT)

    egen    food_exp_weekly = sum(B41K10), by(URUT)     // Sum weekly food exp over items
    
    save    "$data/corefood.dta", replace


    
