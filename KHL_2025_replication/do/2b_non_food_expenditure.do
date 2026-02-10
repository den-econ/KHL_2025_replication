* ==============================================================================
*
* Project         : Estimating Living Wage (KHL) 2025 
* Description     : Assess Non-Food Expenditure by Quintile and Province
* Stata version   : 16 
* Date created    : October 30, 2025 - by Bertha
* Last modified   : October 30, 2025 - by Bertha
*
* ==============================================================================

  capture:  log close
  clear     all
  set more  off
  set scheme    plotplain 

  log using   "$logs/2b_non_food_expenditure.log", replace

**# DATA PREPARATION 

    * Load dataset
    use     "$data/nonfoodexp.dta", clear

    merge   1:1 URUT using "$data/housing_score.dta"
    drop    _merge
    merge   1:1 URUT using "$data/quintiles.dta"
    drop    _merge
    merge   1:1 URUT using "$data/quintiles_province.dta"
    drop    _merge

**# HOUSING

    * Housing - to output
    gen     rent_exp_aeq        = rent_exp/aeq_hh
    gen     utilities_exp_aeq   = utilities_exp/aeq_hh
    table   h_score [aweight=WEIND], contents(mean rent_exp_aeq)
    table   h_score [aweight=WEIND], contents(mean utilities_exp_aeq) 

    * Housing (rent and utility) expenditure by score (national)
    preserve
    collapse (mean) rent_exp_aeq utilities_exp_aeq [aw=WEIND], by(h_score)
    label   variable rent_exp_aeq       "rent"
    label   variable utilities_exp_aeq  "utility"

    export  excel using "$output/2_meanexp_rent_utility.xlsx", ///
            firstrow(variables) sheetmodify sheet("National") 
    restore

    * Housing (rent and utility) expenditure by score (province)
    preserve
    collapse (mean) rent_exp_aeq utilities_exp_aeq [aw=WEIND], by(R101 h_score)

    * Housing score average 
    merge   m:1 R101 using "$data/hh_score_prov.dta"
    keep if h_score == h_score_avg
    drop    _merge h_score

    label   variable rent_exp_aeq       "rent"
    label   variable utilities_exp_aeq  "utility"

    save    "$data/prov_meanexp_rent_utility.dta", replace

    export  excel using "$output/2_meanexp_rent_utility.xlsx", ///
            firstrow(variables) sheet("Province") replace
    restore
    
    * Housing expenditure vs score
    gl      hscore = 13 // ILO threshold

    preserve
    gen     ln_rent_aeq = ln(rent_exp_aeq)
    reg     ln_rent_aeq h_score [aweight=WERT]
    gen     rent_pred   = exp(_b[_cons] + _b[h_score] * h_score)

    scalar  A = exp(_b[_cons])
    scalar  B = _b[h_score]
    display "y = " A " * e^(" B " * x)"
    display exp(_b[_cons] + _b[h_score]*$hscore) //to show what is the rent at x = 13, need to divide value by 1000 in graph 
    *in 2018 average rent corresponding to x = 13 was 143, in 2024 it is 157.1

    collapse (mean) rent_exp_aeq rent_pred [aweight=WERT], by(h_score)
    gen rent_aeq_k  = rent_exp_aeq / 1000
    gen rent_pred_k = rent_pred / 1000

    twoway  (scatter rent_aeq_k h_score, msymbol(circle) mcolor(blue) msize(vsmall)) ///
            (line rent_pred_k h_score, lcolor(blue) lpattern(shortdash)), ///
            ytitle("Monthly rent per adult equivalent (ITDR)", size(small)) ///
            xtitle("Housing Quality Score", size(small)) ///
            title("Rent per AEQ by Housing Quality Score", size(medium)) ///
            legend(order(1 "Actual" 2 "Fitted (Exponential)")) ///
            text(600 14 "y = 16501.6 * e^{0.173 * x}", place(e)) ///
            legend(off) ///
            xlabel(1(1)20) ///
            xline($hscore, lcolor(red) lpattern(shortdash)) ///
            yline(167, lcolor(red) lpattern(shortdash))
    graph   export "$output/2_housing_exp_score.png", replace width(1500)
    restore

**# HEALTH, EDUCATION, AND OTHER ESSENTIALS
    
    * Health and education - to output
    gen     education_exp_pc        = education_exp/R301
    gen     health_exp_pc           = health_exp/R301

    * Other essential goods and services - to output
    gen     clothing_exp_aeq        = clothing_exp/aeq_hh
    gen     transport_exp_aeq       = transport_exp/aeq_hh
    gen     communication_exp_aeq   = communication_exp/aeq_hh
    gen     durable_exp_aeq         = durable_exp/aeq_hh
    gen     othergood_exp_aeq       = othergood_exp/aeq_hh
    gen     indonesia_exp_aeq       = indonesia_list_exp/aeq_hh

    * Quintile wise table for Indonesia
    preserve
    collapse (mean) ///
            education_exp_pc ///
            health_exp_pc ///
            clothing_exp_aeq ///
            transport_exp_aeq ///
            communication_exp_aeq ///
            durable_exp_aeq ///
            othergood_exp_aeq ///
            indonesia_exp_aeq ///
            [aw=WEIND], by(quintile_pc)

    export  excel using "$output/2_meanexp_health_edu_other.xlsx", ///
            firstrow(variables) sheetmodify sheet("National") 
    restore

    * Quintile wise table for provinces
    preserve
    collapse (mean) ///
            education_exp_pc ///
            health_exp_pc ///
            clothing_exp_aeq ///
            transport_exp_aeq ///
            communication_exp_aeq ///
            durable_exp_aeq ///
            othergood_exp_aeq ///
            indonesia_exp_aeq ///
            [aw=WEIND], by(R101 quintile_pc_province)
        
    label   variable education_exp_pc       "Education"
    label   variable health_exp_pc          "Health"
    label   variable clothing_exp_aeq       "Clothing"
    label   variable transport_exp_aeq      "Transport"
    label   variable communication_exp_aeq  "Communication"
    label   variable durable_exp_aeq        "Durables"
    label   variable othergood_exp_aeq      "Other G&S"
    label   variable indonesia_exp_aeq      "Indonesia_list_exp"

    save    "$data/prov_meanexp_hltheduoth.dta", replace

    export  excel using "$output/2_meanexp_health_edu_other.xlsx", ///
            firstrow(variables) sheetmodify sheet("Province") 
    restore
