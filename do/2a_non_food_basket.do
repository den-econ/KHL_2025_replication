* ==============================================================================
*
* Project         : Estimating Living Wage (KHL) 2025
* Description     : Identify Non-Food Basket for KHL Estimation
* Stata version   : 16 
* Date created    : October 30, 2025 - by Bertha
* Last modified   : October 30, 2025 - by Bertha
*
* ==============================================================================

  capture:  log close
  clear     all
  set more  off

  log using   "$logs/2a_non_food_basket.log", replace

**# DATA PREPARATION 

    * Load dataset
    use     "$rawdata/BLOK42_append.dta", clear  
    
    do      "$dofile/sub/0_labeling_susenas_kp42.do"
    drop    if KLP==0

    * Monthly Expenditures
    // The survey reports monthly and yearly expenses for each item
    gen     monthly_exp = B42K4
    replace monthly_exp = B42K5/12 if B42K4 == 0  


**# NON-FOOD BASKET 

    ********************************************************************************
    *** (1) Housing 
    ********************************************************************************
    *Rent
    gen     rent=1 if (KODE>=228 & KODE<=231)         

    bys     URUT: egen rent_exp1=sum(monthly_exp) if rent==1                
    egen    rent_exp=mean(rent_exp1), by (URUT)    
    drop    rent_exp1 

    *Utilities
    gen     utilities=1 if (KODE==234| KODE==236) | (KODE==239 | KODE==241) | (KODE==253 | KODE==255 | KODE==257 | KODE==259 | KODE==260 | KODE==261 | KODE==262)   

    bys     URUT: egen utilities_exp1=sum(monthly_exp) if utilities==1
    egen    utilities_exp=mean(utilities_exp1), by (URUT)  
    drop    utilities_exp1 

    ********************************************************************************
    *** (2) Health Costs
    ********************************************************************************
    gen     health=1 if (KODE>=276 & KODE<=291) 

    bys     URUT: egen health_exp1=sum(monthly_exp) if health==1
    egen    health_exp=mean(health_exp1), by (URUT)    
    drop    health_exp1 

    ********************************************************************************
    *** (3) Education Costs
    ********************************************************************************
    gen     education=1 if (KODE>=292 & KODE<=297)  

    bys     URUT: egen education_exp1=sum(monthly_exp) if education==1
    egen    education_exp=mean(education_exp1), by (URUT)  
    drop    education_exp1 

    ********************************************************************************
    *** (4) Communication
    ********************************************************************************
    *Home phone accounts, cellphone credit, public phones, telephone shops, postal items 
    gen     communication=1 if (KODE>=263 & KODE<=267)  
    sort    URUT R101 R102 R105 R203   

    bys     URUT: egen communication_exp1=sum(monthly_exp) if communication==1
    egen    communication_exp=mean(communication_exp1), by (URUT)
    drop    communication_exp1 

    ********************************************************************************
    *** (5) Transport and Other Services
    ********************************************************************************
    gen     transport=1 if (KODE>=298 & KODE<=301)  | (KODE==244 | KODE==246 | KODE==248 | KODE==250 | KODE==251)   

    bys     URUT: egen transport_exp1=sum(monthly_exp) if transport==1
    egen    transport_exp=mean(transport_exp1), by (URUT)  
    drop    transport_exp1 

    ********************************************************************************
    *** (6) Clothing, Footwear and Headwear Costs
    ********************************************************************************
    gen     clothing=1 if (KODE>=308 & KODE<=315)   

    bys     URUT: egen clothing_exp1=sum(monthly_exp) if clothing==1
    egen    clothing_exp=mean(clothing_exp1), by (URUT)    
    drop    clothing_exp1 

    ********************************************************************************
    *** (7) Durable Goods
    ********************************************************************************
    gen     durable=1 if (KODE>=317 & KODE<=333)    

    bys     URUT: egen durable_exp1=sum(monthly_exp) if durable==1
    egen    durable_exp=mean(durable_exp1), by (URUT)  
    drop    durable_exp1 

    ********************************************************************************
    *** (8) Other Goods and services
    ********************************************************************************
    *Miscelaneous Goods and Services, Parties and Ceremonies, Insurance
    //gen     othergood=1 if (KODE>=269 & KODE<=275 | KODE>=302 & KODE<=305 | KODE>=342 & KODE<=347 | KODE>=338 & KODE<=339)  // include both "asuransi kesehatan" dan "asuransi lainnya"
    gen     othergood=1 if (KODE>=269 & KODE<=275 | KODE>=302 & KODE<=305 | KODE>=342 & KODE<=347)  // without insurance 
    replace othergood=0 if KODE==304 | KODE==345
    bys     URUT: egen othergood_exp1=sum(monthly_exp) if othergood==1
    egen    othergood_exp=mean(othergood_exp1), by (URUT)  
    drop    othergood_exp1 

    
    *** List all non-food commodities
    preserve
    order   rent utilities health education communication transport clothing durable othergood 
    egen    nonfood = rowtotal(rent-othergood)
    keep if nonfood == 1
    collapse (first) nonfood, by(KODE)
    gen     no = _n
    sort    no
    keeporder no KODE

    export  excel using "$output/2_commodity_basket.xlsx", ///
            firstrow(variables) sheet("Non Food") sheetmodify
    restore
    
    drop    rent utilities health education communication transport clothing durable othergood 

**# NON-FOOD BASKET (85 ITEM)
    
    gen     indonesia_list=1 if KODE==308 | KODE==309 | KODE==310 | KODE==311 | KODE==312 | KODE==313 | KODE==314 | ///
            KODE==315 | KODE==318 | KODE==321 | KODE==319 | KODE==253 | KODE==234 | KODE==262 | KODE==236 | KODE==272 | ///
            KODE==320 | KODE==273 | KODE==298  

    bys     URUT: egen indonesia_list_exp1=sum(monthly_exp) if indonesia_list==1
    egen    indonesia_list_exp=mean(indonesia_list_exp1), by (URUT)    
    drop    indonesia_list_exp1 indonesia_list

    keep    URUT rent_exp utilities_exp communication_exp health_exp education_exp transport_exp ///
            clothing_exp durable_exp othergood_exp indonesia_list_exp WEIND WERT

    duplicates drop URUT, force 

    save   "$data/nonfoodexp.dta", replace 



