* ==============================================================================
*
* Project         : Estimating Living Wage (KHL) 2024 
* Description     : Setting File Paths for KHL Estimation 
* Stata version   : 16 
* Date created    : October 30, 2025 - by Bertha
* Last modified   : October 30, 2025 - by Bertha
*
* ==============================================================================

  capture:  log close
  clear     all
  set more  off

**# Set directory by user 

  * Steps:
  * (1) Note: create a folder titled "KHL_2025" in user's device
  * (2) Change "`c(username)'" as shown in Stata by typing the following command:
  display "`c(username)'"
  * (3) Change the global "base" with the path where the "KHL_2025" folder is located


  /*** User 1 ***/

 if "`c(username)'" == "berth" {
      
      global  github  "C:\Users\berth\GitHub\KHL_2025\KHL_2025_replication" 
      global  data    "C:\Users\berth\Google Drive\DEN\Direktorat Eksekutif 2\Database\KHL_data\data_2025"

      capture mkdir   "$github/do"
      capture mkdir   "$github/logs"
      capture mkdir   "$github/output"

      capture mkdir   "$data/raw"    // to add raw Susenas data
      capture mkdir   "$data/clean"
     

      global  rawdata "$data/raw"  
      global  data    "$data/clean"

      global  dofile  "$github/do"
      global  logs    "$github/logs"
      global  output  "$github/output"
  } 

  
  /*** User 2 ***/
  
  else if "`c(username)'" == "" {         // change the username 
      
      global  github  ""                  // to add GitHub directory
      global  data    ""                  // to add data directory

      capture mkdir   "$github/do"
      capture mkdir   "$github/logs"
      capture mkdir   "$github/output"

      capture mkdir   "$data/raw"    // to add raw Susenas data
      capture mkdir   "$data/clean"
     

      global  rawdata "$data/raw"  
      global  data    "$data/clean"

      global  dofile  "$github/do"
      global  logs    "$github/logs"
      global  output  "$github/output"
      global  output  "$base/output"
    } 
 

  /*** User 3 ***/
  
  else if "`c(username)'" == "" {         // change the username 
      
      global  github  ""                  // to add GitHub directory
      global  data    ""                  // to add data directory

      capture mkdir   "$github/do"
      capture mkdir   "$github/logs"
      capture mkdir   "$github/output"

      capture mkdir   "$data/raw"    // to add raw Susenas data
      capture mkdir   "$data/clean"
     

      global  rawdata "$data/raw"  
      global  data    "$data/clean"

      global  dofile  "$github/do"
      global  logs    "$github/logs"
      global  output  "$github/output"
      global  output  "$base/output"
    } 

  else {
    di as red "User is not recognized."
    exit
  }
