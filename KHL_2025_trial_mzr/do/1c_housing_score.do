* ==============================================================================
*
* Project         : Estimating Living Wage (KHL) 2025 
* Description     : Constructing the Housing Score
* Stata version   : 16 
* Date created    : October 30, 2025 - by Bertha
* Last modified   : October 30, 2025 - by Bertha
*
* ==============================================================================

  capture:  log close
  clear     all
  set more  off

  log using "$logs/1c_housing_score.log", replace

**# DATA PREPARATION 

    use     "$rawdata/KOR25RT.dta", clear 
    do      "$dofile/sub/0_labeling_province.do"
    keep    URUT R101 R102 R105 NUINFORT NUINFORT1 R1601-R1617

    merge   1:1 URUT using "$data/adultequi.dta"
    drop    _merge
    
    merge   1:1 URUT using "$data/hh_size.dta"
    drop    _merge

    do      "$dofile/sub/0_labeling_susenas_kor_rt.do"


**# CONSTRUCTION OF HOUSING SCORE
    
    ********************************************************************************
    *** 4.1. Space
    ********************************************************************************
    gen     sqm_pc=R1604/R301

    gen     h_score_size_dw=.
    replace h_score_size_dw=1 if sqm_pc<=6 // Less than 6 sqm pc
    replace h_score_size_dw=2 if sqm_pc<=10.1 & sqm_pc>6 // Bet. 6 and 10.1 sqm pc
    replace h_score_size_dw=3 if sqm_pc<=20 & sqm_pc>10.1 // Bet. 10.1 and 20 sqm pc
    replace h_score_size_dw=4 if sqm_pc<=39 & sqm_pc>20 // Bet. 20 and 39 sqm pc
    replace h_score_size_dw=5 if sqm_pc>39 // Larger than 40 sqm pc

    gen     h_score_space=round(h_score_size_dw, 1)

    ********************************************************************************
    *** 4.2. Material
    ********************************************************************************
    *4.2.1 Roof
    gen     h_score_roof=.
    replace h_score_roof=1 if R1606==6  //bamboo / palm / sago palm

    replace h_score_roof=2 if R1606==3  //Zinc

    replace h_score_roof=3 if R1606==5  //Asbestos
    replace h_score_roof=3 if R1606==2  //Roof Tiles
    replace h_score_roof=3 if R1606==4  //Shingles

    replace h_score_roof=4 if R1606==7  //Others

    replace h_score_roof=5 if R1606==1  //Concrete

    *4.2.2 Wall
    gen     h_score_wall=.

    replace h_score_wall=1 if R1607==4  //Bamboo / woven bamboo
    replace h_score_wall=1 if R1607==5  //Others

    replace h_score_wall=3 if R1607==2  //Plaster of woven bamboo / wire
    replace h_score_wall=3 if R1607==3  //Wood / plank / logs

    replace h_score_wall=5 if R1607==1  //Wall

    *4.2.3 Floor
    gen     h_score_floor=.
    replace h_score_floor=1 if R1608==6 //Bamboo / soil
        
    replace h_score_floor=2 if R1608==5 //Red Cement/Brick

    replace h_score_floor=3 if R1608==4 //Wood/plank
    replace h_score_floor=3 if R1608==7 //Others

    replace h_score_floor=4 if R1608==3 //Parquet / vinyl / carpet

    replace h_score_floor=5 if R1608==1 //Marble / granite
    replace h_score_floor=5 if R1608==2 //Ceramic / tiles / terasso

    gen     h_score_material=round(((h_score_wall+h_score_roof+h_score_floor)/3), 1)

    ********************************************************************************
    *** 4.3 Water Accessibility
    ********************************************************************************
    gen     h_score_water=.

    replace h_score_water=1 if R1610A==9    //Surface water (rivers, lakes, reservoirs, ponds, irrigation)
    replace h_score_water=1 if R1610A==10   //Rainwater
    replace h_score_water=1 if R1610A==11   //Others

    replace h_score_water=2 if R1610A==6    //The well is unprotected
    replace h_score_water=2 if R1610A==8    //Unprotected springs

    replace h_score_water=3 if R1610A==5    //The well is protected
    replace h_score_water=3 if R1610A==7    //Protected springs

    replace h_score_water=4 if R1610A==4    //Borehole / Pump

    replace h_score_water=5 if R1610A==1    //Branded bottled water
    replace h_score_water=5 if R1610A==2    //Refill water
    replace h_score_water=5 if R1610A==3    //Plumbing

    ********************************************************************************
    *** 4.4 Facilities
    ********************************************************************************
    gen     h_score_toilet=.
    replace h_score_toilet=1 if R1609B==3   //Do not use
    replace h_score_toilet=1 if R1609B==4   //Cemplung / cubluk

    replace h_score_toilet=3 if R1609B==2   //Plengsengan

    replace h_score_toilet=5 if R1609B==1   //Goose neck

    gen     h_score_disposal=.

    replace h_score_disposal=1 if R1609C==3
    replace h_score_disposal=1 if R1609C==4
    replace h_score_disposal=1 if R1609C==5

    replace h_score_disposal=3 if R1609C==6

    replace h_score_disposal=5 if R1609C==1
    replace h_score_disposal=5 if R1609C==2

    egen    facilities=rowtotal(h_score_toilet h_score_disposal)
    gen     h_score_facilities=round(((facilities)/2), 1)
    drop    facilities
    
    ********************************************************************************
    *** 4.5 Total Score
    ********************************************************************************
    egen    h_score=rowtotal(h_score_size_dw h_score_material h_score_water h_score_facilities)
    label   variable h_score    "Housing Score"

    ********************************************************************************
    *** 4.6 Ownership
    ********************************************************************************
    gen     ownership = .
    replace ownership = 1 if R1602 == 1     // Owned
    replace ownership = 2 if R1602 == 2     // Contract
    replace ownership = 3 if R1602 == 3     // Rental free
    replace ownership = 5 if R1602 == 4     // Service
    replace ownership = 6 if R1602 == 5     // Others

    label   define ownershipl 1 "Owned" 2 "Contract" 3 "Rental free" 5 "Service" 6 "Others"
    label   values ownership ownershipl

    tab     ownership R105 [aweight = WEIND] // Urban (1) Rural (2)


    drop    NUINFORT NUINFORT1 R1601-R1617

    save   "$data/housing_score.dta", replace 


**# HOUSING SCORE AVERAGE BY PROVINCE 

    preserve
    collapse (mean) h_score [aw=WEIND], by(R101)
    gen     h_score_avg = round(h_score) 

    export  excel using "$output/1_hscore_prov.xlsx", ///
            firstrow(variables) sheet("Summary") replace
    drop    h_score
    save    "$data/hh_score_prov.dta", replace 

    restore


**# DISTRIBUTION BY QUINTILE

    * Merge with quintile data
    merge   1:1 URUT using "$data/quintiles.dta"
    drop    _merge
    
    merge   1:1 URUT using "$data/quintiles_province.dta"
    drop    _merge

    * National 
    preserve
    collapse (mean) h_score [aw=WEIND], by(quintile_pc)
    format  h_score  %9.2fc

    export  excel using "$output/1_hscore_quintile.xlsx", ///
            firstrow(variables) sheetmodify sheet("National") 

    restore

    *Province
    preserve
    collapse (mean) h_score [aw=WEIND], by(R101 quintile_pc_province)
    format  h_score  %9.2fc

    export  excel using "$output/1_hscore_quintile.xlsx", ///
            firstrow(variables) sheetmodify sheet("Province") 

    restore



 
