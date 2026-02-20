* ==============================================================================
*
* Project         : Estimating Living Wage (KHL) 2024 
* Description     : Analyze Living Wage (KHL) Estimates
* Stata version   : 16 
* Date created    : September 7, 2025 - by Bertha
* Last modified   : September 7, 2025 - by Bertha
*
* ==============================================================================

  capture:  log close
  clear     all
  set more  off
  set scheme s2color

  log using   "$logs/3a_khl_analysis.log", replace


**# DATA PREPARATION

    * Minimum wage data
    import  excel "$rawdata/UMP_2025.xlsx", ///
            clear firstrow 
    gen     year = 2025
    save    "$data/mindata.dta", replace

    * Merge with KHL data
    merge   1:1 province year using "$data/needs.dta"
    keep    if _merge==3
    
    gen     min=minwage/1000
    gen     khl_mw_ratio = needs_ILO_rp/minwage
    gen     mw_khl_ratio = minwage/needs_ILO_rp
    gen     avgumk_khl_ratio = avg_umk/needs_ILO_rp
    
    drop    _merge
    label   values province province_lbl

**# LIVING WAGE (KHL) ASSESSMENT 

    * KHL (ILO) 
    graph   hbar needs, ///
            over(province, label(labsize(tiny))) ///
            ylabel(, labsize(vsmall)) ///
            bar(1, color(sea)) ///
            legend(off) ///
            ytitle("Rupiah (Thousands)", size(vsmall)) ///
            title("Living Wage (ILO), $year", size(small)) ///
            blabel(bar, size(tiny) format(%4.0f)) ///
            graphregion(color(white)) plotregion(color(white))
    graph   export "$output/graph1.png", replace width(1500)

    * UMP/KHL  
    graph   hbar mw_khl_ratio, ///
            over(province, label(labsize(tiny))) ///
            ylabel(, labsize(vsmall)) ///
            bar(1, color(lavender)) ///
            legend(off) ///
            ytitle("UMP/KHL Ratio", size(vsmall)) ///
            title("Minimum Wage/Living Wage Ratio, $year", size(small)) ///
            blabel(bar, size(tiny) format(%4.2f)) ///
            graphregion(color(white)) plotregion(color(white))
    graph   export "$output/graph2a.png", replace width(1500)

    * UM/KHL
    graph   hbar mw_khl_ratio avgumk_khl_ratio, ///
            over(province, label(labsize(tiny))) ///
            ylabel(, labsize(vsmall)) ///
            bar(1, color(teal)) ///
            bar(2, color(dkorange)) ///
            legend(position(3) cols(1) size(vsmall)  ///
            order(1 "UMP/KHL Ratio" 2 "Average UMK/KHL Ratio") region(lstyle(none)) symxsize(5) symysize(2)) ///
            ytitle("UM/KHL Ratio", size(vsmall)) ///
            title("Minimum Wage/Living Wage Ratio, $year", size(small)) ///
            blabel(bar, size(tiny) format(%4.2f)) ///
            graphregion(color(white)) plotregion(color(white))
    graph   export "$output/graph2b.png", replace width(1500)

    * KHL (ILO) vs Minimum Wage
    graph   hbar needs min, ///
            over(province, label(labsize(tiny))) ///
            ylabel(, labsize(vsmall)) ///
            bar(1, color(sea)) ///
            bar(2, color(maroon)) ///
            legend(position(3) cols(1) size(vsmall)  ///
            order(1 "Living Wage (ILO)" 2 "Minimum Wage") region(lstyle(none)) symxsize(5) symysize(2)) ///
            ytitle("Rupiah (Thousands)", size(vsmall)) ///
            title("Living Wage (ILO) vs Minimum Wage, $year", size(small)) ///
            blabel(bar, size(tiny) format(%4.0f)) ///
            graphregion(color(white)) plotregion(color(white))
    graph   export "$output/graph3.png", replace width(1500)

    * KHL (85-item) vs Minimum Wage
    graph   hbar needs_indo min, ///
            over(province, label(labsize(tiny))) ///
            ylabel(, labsize(vsmall)) ///
            bar(1, color(teal)) ///
            bar(2, color(maroon)) ///
            legend(position(3) cols(1) size(vsmall)  ///
            order(1 "Living Wage (85-item list)" 2 "Minimum Wage") region(lstyle(none)) symxsize(5) symysize(2)) ///
            ytitle("Rupiah (Thousands)", size(vsmall)) ///
            title("Living Wage (85 items) vs Living Wage (ILO), $year", size(small)) ///
            blabel(bar, size(tiny) format(%4.0f)) ///
            graphregion(color(white)) plotregion(color(white))
    graph   export "$output/graph4.png", replace width(1500)

    * KHL (ILO) vs KHL (85-item) 
    graph   hbar needs needs_indo, ///
            over(province, label(labsize(tiny))) ///
            ylabel(, labsize(vsmall)) ///
            bar(1, color(sea)) ///
            bar(2, color(teal)) ///
            legend(position(3) cols(1) size(vsmall)  ///
            order(1 "Living Wage (ILO)" 2 "Living Wage (85 item list)") region(lstyle(none)) symxsize(5) symysize(2)) ///
            ytitle("Rupiah (Thousands)", size(vsmall)) ///
            title("Living Wage (ILO) vs Living Wage (85-item list)", size(small)) ///
            blabel(bar, size(tiny) format(%4.0f)) ///
            graphregion(color(white)) plotregion(color(white))
    graph   export "$output/graph5.png", replace width(1500)

    *Variation in living wage
    graph   box needs needs_indo, ///
            ytitle("Living Cost (000 IDR)") ///
            legend(order(1 "ILO Living Wage Benchmark" 2 "85-item Needs") cols(2) ring(1) pos(6))  ///
            graphregion(color(white)) plotregion(color(white))
    graph   export "$output/graph5.png", replace width(1500)


**# LIVING WAGE (KHL) - MINIMUM WAGE RATIO

    * Check variables: needs (ILO benchmark), needs_indo (85-item), min (monthly MW in 000 IDR)
    sum     needs needs_indo min

    * Create ratio of minimum wage to each living wage benchmark
    gen     min_vs_needs = min/needs
    gen     min_vs_needs_indo = min/needs_indo

    * Categorize by KHL (ILO)
    gen     category_ilo = .
    replace category_ilo = 1 if min_vs_needs < 0.8
    replace category_ilo = 2 if min_vs_needs >= 0.8 & min_vs_needs <= 1
    replace category_ilo = 3 if min_vs_needs > 1
    label   define cat_ilo 1 "Below 80%" 2 "80–100%" 3 "Above 100%"
    label   values category_ilo cat_ilo

    * Categorize by KHL (85-item list)
    gen     category_85 = .
    replace category_85 = 1 if min_vs_needs_indo < 0.8
    replace category_85 = 2 if min_vs_needs_indo >= 0.8 & min_vs_needs_indo <= 1
    replace category_85 = 3 if min_vs_needs_indo > 1
    label   define cat_85 1 "Below 80%" 2 "80–100%" 3 "Above 100%"
    label   values category_85 cat_85

    * Tabulate results
    di      "ILO Benchmark:"
    tab     category_ilo

    di      "85-item Needs Benchmark:"
    tab     category_85

    save    "$data/needs_assessment_data.dta", replace




        
   

  
