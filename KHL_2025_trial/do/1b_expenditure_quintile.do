* ==============================================================================
*
* Project         : Estimating Living Wage (KHL) 2025 
* Description     : Generating Quintile Based on HH Total Expenditure - National
* Stata version   : 16 
* Date created    : October 30, 2025 - by Bertha
* Last modified   : October 30, 2025 - by Bertha
*
* ==============================================================================

  capture:  log close
  clear     all
  set more  off

  log using   "$logs/1b_expenditure_quintile.log", replace

**# FOOD EXPENDITURE 
  
    * Data Preparation 
    use     "$rawdata/BLOK41_append.dta", clear 
    
    do      "$dofile/sub/0_labeling_susenas_kp41.do"
    drop    if KLP==0

    * Monthly Food Expenditure 
    egen    food_exp_weekly = sum(B41K10), by(URUT)       // Sum weekly food exp over items
    duplicates drop URUT, force                           // One row per household

    gen     food_exp_monthly = food_exp_weekly * (30/7)   // Convert to monthly
    gen     food_exp_pc = food_exp_monthly / R301         // Per capita
    mean    food_exp_pc [aweight=WEIND]                   // National weighted average - figures matching with 2024 report page 15 

    keep    URUT food_exp_monthly food_exp_pc R301
    save    "$data/food_exp.dta",replace


**# NON-FOOD EXPENDITURE

    * Data Preparation 
    use     "$rawdata/BLOK42_append.dta", clear 

    do      "$dofile/sub/0_labeling_susenas_kp42.do"
    drop    if KLP==0

    * Monthly Non-Food Expenditure 
   
    // The survey reports monthly and yearly expenses for each item
    gen     monthly_exp = B42K4
    replace monthly_exp = B42K5/12 if B42K4 == 0  

      *** Housing and Household Facilities ***
      gen     hhfacility=1 if (KODE>=228 & KODE<=267)
      sort    URUT R101 R102 R105 R203
      bys     URUT: egen hhfacility1 = sum(monthly_exp) if hhfacility == 1
      egen    hhfacility_exp = mean(hhfacility1), by(URUT) 
      drop    hhfacility1 hhfacility

      *** Household Goods ***
      gen     hhgoods=1 if (KODE>=269 & KODE<=275)
      sort    URUT R101 R102 R105 R203
      bys     URUT: egen hhgoods1 = sum(monthly_exp) if hhgoods == 1
      egen    hhgoods_exp = mean(hhgoods1), by(URUT) 
      drop    hhgoods1 hhgoods

      *** Health Costs ***
      gen     health=1 if (KODE>=276 & KODE<=291) 
      sort    URUT R101 R102 R105 R203

      bys     URUT: egen health_exp1 = sum(monthly_exp) if health == 1
      egen    health_exp = mean(health_exp1), by(URUT) 
      drop    health_exp1 health

      *** Education Costs ***
      gen     education=1 if (KODE>=292 & KODE<=297) 
      sort    URUT R101 R102 R105 R203 

      bys     URUT: egen education_exp1 = sum(monthly_exp) if education == 1
      egen    education_exp = mean(education_exp1), by(URUT) 
      drop    education_exp1 education

      *** Transport and Other Services ***
      gen     transport=1 if (KODE>=298 & KODE<=306) 
      sort    URUT R101 R102 R105 R203 

      bys     URUT: egen transport_exp1 = sum(monthly_exp) if transport == 1
      egen    transport_exp = mean(transport_exp1), by(URUT) 
      drop    transport_exp1 transport

      *** Clothing, Footwear and Headwear Costs ***
      gen     clothing=1 if (KODE>=308 & KODE<=315)   
      sort    URUT R101 R102 R105 R203 

      bys     URUT: egen clothing_exp1 = sum(monthly_exp) if clothing == 1
      egen    clothing_exp = mean(clothing_exp1), by(URUT) 
      drop    clothing_exp1 clothing

      *** Durable Goods ***
      gen     durable=1 if (KODE>=317 & KODE<=333)  
      sort    URUT R101 R102 R105 R203 

      bys     URUT: egen durable_exp1 = sum(monthly_exp) if durable==1
      egen    durable_exp=mean(durable_exp1), by(URUT) 
      drop    durable_exp1 durable

      *** Taxes and Insurance ***
      gen     taxes=1 if (KODE>=335 & KODE<=340)  
      sort    URUT R101 R102 R105 R203 

      bys     URUT: egen taxes_exp1 = sum(monthly_exp) if taxes == 1
      egen    taxes_exp = mean(taxes_exp1), by(URUT) 
      drop    taxes_exp1 taxes

      *** Parties and Ceremonies ***
      gen     parties=1 if (KODE>=342 & KODE<=347)  
      sort    URUT R101 R102 R105 R203 

      bys     URUT: egen parties_exp1 = sum(monthly_exp) if parties == 1
      egen    parties_exp = mean(parties_exp1), by(URUT) 
      drop    parties_exp1 parties

    // Keep the data at the HH level
    drop    KODE B42K3* B42K4 B42K5 KLP SEBULAN KABU monthly_exp
    duplicates drop URUT, force 

    // Total non food expenditures
    egen  nonfood_exp    = rowtotal(hhfacility_exp hhgoods_exp health_exp education_exp transport_exp clothing_exp durable_exp taxes_exp parties_exp)
    gen   nonfood_exp_pc = nonfood_exp/R301
    mean  nonfood_exp_pc [aweight=WEIND]               // National weighted average - figures matching with 2024 report page 15 


**# TOTAL EXPENDITURE (FOOD + NON-FOOD)

    * Monthly total expenditure
    merge   1:1 URUT using "$data/food_exp.dta" 
    egen    total_exp = rowtotal(food_exp_monthly hhfacility_exp hhgoods_exp health_exp education_exp transport_exp clothing_exp durable_exp taxes_exp parties_exp)
    gen     total_exp_pc = total_exp/R301
    mean    total_exp_pc [aweight = WEIND]               // National weighted average - figures matching with 2024 report page 15 

    
    * Adjust total expenditure to adult equivalent
    drop    _merge
    merge   1:1 URUT using "$data/adultequi.dta" 
    gen     total_exp_aeq = total_exp/aeq_hh

    /*
    See the ILO manual page 22: https://www.ilo.org/sites/default/files/2025-04/254_499_EN07.pdf

    - To account for family size and reflect living standards, we could simply divide the total household expenditure by the number of household members. 
    - However, because there are economies of scale when several individuals live together and because children have lower material needs than adults, 
    estimating per capita expenditure requires the use of equivalence scales (ILO 2015). 
    - Therefore, in this baseline methodology, we suggest using the OECD adult equivalence scale (the Oxford scale), 
    which typically assigns a value of 1 to the household head, 0.7 to each additional adult member and 0.5 to each child. 
    - Once this is done, we rank the households from the poorest to the richest and create quintiles on
    the basis of their total monthly expenditure per adult equivalent.
    */

**# QUINTILE - NATIONAL

    * Calculate quintile
    xtile   quintile    = total_exp_aeq [aw= WEIND], n(5)
    xtile   quintile_pc = total_exp_pc [aw= WEIND], n(5)
    xtile   decile      = total_exp_aeq [aw= WEIND], n(10)
    xtile   decile_pc   = total_exp_pc [aw= WEIND], n(10)


    keep    URUT R101 R301 total_exp total_exp_pc aeq_hh adult_hh total_exp_aeq quintile quintile_pc decile decile_pc WERT WEIND
    do      "$dofile/sub/0_labeling_province.do"

    save    "$data/quintiles.dta", replace


**# QUINTILE - PROVINCE

    * Calculate quintile
    levelsof R101, local(provinces)

    gen   quintile_pc_province = .

    foreach p of local provinces {
          xtile   q = total_exp_pc if R101 == `p' [aw=WEIND], nq(5)
          replace quintile_pc_province = q if R101 == `p'
          drop    q
    }

    keep  URUT R101 total_exp total_exp_pc aeq_hh adult_hh total_exp_aeq quintile quintile_pc quintile_pc_province decile WERT WEIND

    table R101 [aweight=WEIND], contents(mean total_exp_pc)

    save  "$data/quintiles_province.dta", replace

