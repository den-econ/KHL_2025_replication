
**# Labeling Susenas 
    
    * Variable
    label variable URUT     "Household ID"
    label variable R101     "Provincial Code"
    label variable R102     "District"
    label variable R105     "Urban/Rural"
    label variable R203     "Results of Household Enumeration"
    label variable R301     "Number of Household Members"
    label variable COICOP   "COICOP Code"
    label variable KLP      "Subgroup Code"
    label variable KODE     "Commodity Item Number"
    label variable B41K5    "Number of Consumption per Week of a Household Derived from Purchases"
    label variable B41K6    "Value of Expenditures for a Week of a Household Derived from Purchases"
    label variable B41K7    "Number of Consumption per Week of a Household Originating from Own Production, Gifting, etc."
    label variable B41K8    "Value of Expenditures for a Week of a Household Derived from Own Production, Giving, etc."
    label variable B41K9    "Number of Household Consumption a Week"
    label variable B41K10   "Value of expenditure a week one household"
    label variable KALORI   "Number of Calories Consumption per week in a household"
    label variable PROTEIN  "Number of Protein Consumption a Week for one household"
    label variable LEMAK    "Quantity consumption of fat: One week per household"
    label variable KARBO    "Amount of Consumption of Carbohydrates per week in a household"
    label variable WERT     "Weighing for Household Estimates"
    label variable WEIND    "Weighing for Population Estimation"
    label variable KABU     "Regency "
    //label variable WI1      "Indonesian NKS serial number"
    //label variable WI2      "Serial number for household samples in Indonesia"

    * Values for Variable "KLP" 2025
    label define klp_lbl ///
    1   "PADI-PADIAN" ///
    8   "UMBI-UMBIAN" ///
    16  "IKAN/UDANG/CUMI/KERANG" ///
    61  "DAGING" ///
    74  "TELUR DAN SUSU" ///
    85  "SAYUR-SAYURAN" ///
    121 "KACANG-KACANGAN" ///
    129 "BUAH-BUAHAN" ///
    154 "MINYAK DAN KELAPA" ///
    159 "BAHAN MINUMAN" ///
    167 "BUMBU-BUMBUAN" ///
    182 "KONSUMSI LAINNYA" ///
    187 "MAKANAN DAN MINUMAN"

    label values KLP klp_lbl
