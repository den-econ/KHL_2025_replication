* ==============================================================================
*
* Project         : Estimating Living Wage (KHL) 2025 
* Description     : Calculate Living Wage (KHL) - National and Province
* Stata version   : 16 
* Date created    : October 30, 2025 - by Bertha
* Last modified   : October 30, 2025 - by Bertha
*
* ==============================================================================

  capture:  log close
  clear     all
  set more  off

  log using   "$logs/2f_living_wage.log", replace

**# DATA PREPARATION
    
    use     "$data/foodexp.dta", clear
    merge   1:1 R101 using "$data/nonfood_exp.dta" 
    drop    _merge
    
**# LIVING WAGE (KHL) 
    
    gen     hh_size         = $hh_size

    * Adjust to household of 4 members
    gen     food            = food_exp * hh_size
    gen     rent            = rent_exp_aeq * $adult_equiv
    gen     utility         = utilities_exp_aeq * $adult_equiv
    gen     education       = education_exp_pc * hh_size
    gen     health          = health_exp_pc * hh_size
    gen     clothing        = clothing_exp_aeq * $adult_equiv
    gen     transport       = transport_exp_aeq * $adult_equiv
    gen     communication   = communication_exp_aeq * $adult_equiv
    gen     durable         = durable_exp_aeq * $adult_equiv
    gen     othergoods      = othergood_exp_aeq * $adult_equiv
    gen     indonesialist   = indonesia_exp_aeq * $adult_equiv

    * Total needs for 1 household
    egen    aggregate_need  = rowtotal (food-othergoods)
    gen     aggregate_need_indo = food + rent + utility + indonesialist

    * Total needs divided by number of working adults in a household (baseline assumption = 1.5)
    gen     needs           = aggregate_need / ($work_adults * 1000)
    gen     needs_indo      = aggregate_need_indo / ($work_adults * 1000)

    gen     needs_ILO_rp    = aggregate_need / $work_adults 
    gen     needs_85item_rp = aggregate_need_indo / $work_adults 

    gen     adult_equiv     = $adult_equiv
    gen     work_adults     = $work_adults

    ren     R101 province
    gen     year = $year

    keeporder   province year ///
                food_exp rent_exp_aeq utilities_exp_aeq education_exp_pc health_exp_pc clothing_exp_aeq transport_exp_aeq communication_exp_aeq ///
                durable_exp_aeq othergood_exp_aeq indonesia_exp_aeq adult_equiv hh_size ///
                food rent utility education health clothing transport communication durable othergoods ///
                indonesialist aggregate_need aggregate_need_indo ///
                work_adults needs_ILO_rp needs_85item_rp needs needs_indo

    save    "$data/needs.dta", replace

    export  excel using "$output/KHL_Estimates.xlsx", ///
            firstrow(variables) sheet("KHL") replace

    

    

  

    

    
