/*=================================================================================================================
Project:		ROLI 2024
Routine:		TPS data cleaning and Harmonization 2024 (master do file)
Author(s):		Natalia Rodriguez (nrodriguez@worldjusticeproject.org)
Dependencies:  	World Justice Project
Creation Date:	April, 2025

Description:
Master dofile for the cleaning and analyzing the TPS data included in the Global Index. 
This do file imports the original datasets from each source and cleans them.
Then, we export the data to the MAP

=================================================================================================================*/

clear
cls
set maxvar 120000

/*=================================================================================================================
					Pre-settings
=================================================================================================================*/


*--- Stata Version
*version 15

*--- Required packages:
* NONE

*--- Defining paths to SharePoint & your local Git Repo copy:

*------ (a) Natalia Rodriguez:
if (inlist("`c(username)'", "nrodriguez")) {
	global path2SP "C:\Users\nrodriguez\OneDrive - World Justice Project\Programmatic\Data Analytics\7. WJP ROLI\ROLI_2024\1. Cleaning\TPS"
	global path2GH ""
}


*--- Defining path to Data and DoFiles:

**Path2data: Path to data folder. 
global path2data "${path2SP}\1. Data"


**Path 2dos: Path to do-files (Routines). 
global path2dos  "${path2GH}\2. Code"


/*=================================================================================================================
					1. Importing the datasets
=================================================================================================================*/

/*----------------------*/
/* Countries's dataset  */
/*----------------------*/

*Countries dataset with current names and WDI codes

/*
import excel "C:\Users\nrodriguez\OneDrive - World Justice Project\Programmatic\Index Data & Analysis\2024\Map 4_Qatar.xlsx", sheet("Data_Sorting") cellrange(A1:B283) firstrow clear

drop if country==""

save "${path2data}\2. Clean\general_info.dta", replace
*/


/*----------------------*/
/*          PTS         */
/*----------------------*/

use "${path2data}\1. Original\Political Terror Scale\PTS-2023.dta" 
keep if PTS_A!=.
rename Country_OLD country
rename Year year
keep country year PTS_A

bys country: egen max_year=max(year)
keep if year==max_year
drop max_year

*replace country="The Bahamas" if country=="Bahamas"
replace country="Congo, Rep." if country=="Congo"
replace country="Congo, Dem. Rep." if country=="Democratic Republic of the Congo"
replace country="Cote d'Ivoire" if country=="Ivory Coast (Cote d'Ivoire)"
replace country="Czechia" if country=="Czech Republic"
replace country="Egypt, Arab Rep." if country=="Egypt"
*replace country="The Gambia" if country=="Gambia"
replace country="Finland" if country=="Finland "
replace country="Iran, Islamic Rep." if country=="Iran"
replace country="Korea, Rep." if country=="South Korea (Republic of Korea)"
replace country="Kyrgyz Republic" if country=="Kyrgyz Republic"
replace country="North Macedonia" if country=="Macedonia"
replace country="Russian Federation" if country=="Russia"
replace country="Slovak Republic" if country=="Slovakia"
replace country="Turkiye" if country=="Turkey"
replace country="Venezuela, RB" if country=="Venezuela"

save "${path2data}\2. Clean\PTS_2023.dta", replace


/*----------------------*/
/*        COUPS         */
/*----------------------*/

import delimited "${path2data}\1. Original\Coups\powell_thyne_coups_final.txt", clear 

keep if year>=2019

rename coup coup2
gen coup=coup2
recode coup (1=0.5) (2=0)

bys country year: gen n=_n

collapse (mean) coup, by(country year)

encode country, gen(c)
drop country 
rename c country 
xtset country year

tsfill, full
decode country, gen(c)
drop country
rename c country
drop if country==""

replace coup=1 if coup==.

collapse (mean) coup, by(country)

*Manual fix due to more than one coup in the year - Done in Excel manually by averaging the events, not the years. See excel "Coups".
//9/9/2024: Natalia fixed this to match last year, created a new calculations excel in Coups 2024 (TPS folder)
replace coup=0.666666667 if country=="Burkina Faso"
replace coup=0.5 if country=="Sudan"

save "${path2data}\2. Clean\coups.dta", replace

/*----------------------*/
/*       Gallup         */
/*----------------------*/

*------ Property stolen
import excel "${path2data}\1. Original\Gallup\Money Property Stolen.xlsx", sheet("Money Property Stolen") cellrange(B8:Z2338) firstrow clear

rename Time year
destring year, replace

rename Geography country
drop Demographic DemographicValue No DKRF-Z
rename Yes property_stolen

replace country="Congo, Rep." if country=="Congo Brazzaville"
replace country="Congo, Dem. Rep." if country=="Congo (Kinshasa)"
replace country="Cote d'Ivoire" if country=="Ivory Coast (Cote d'Ivoire)"
replace country="Czechia" if country=="Czech Republic"
replace country="Egypt, Arab Rep." if country=="Egypt"
*replace country="The Gambia" if country=="Gambia"
replace country="Netherlands" if country=="Netherlands (Kingdom of the)"
replace country="Hong Kong SAR, China" if country=="Hong Kong S.A.R. of China"
replace country="Iran, Islamic Rep." if country=="Iran"
replace country="Korea, Rep." if country=="South Korea"
replace country="Kyrgyz Republic" if country=="Kyrgyzstan"
replace country="Moldova" if country=="Moldova, Republic of"
replace country="North Macedonia" if country=="Macedonia"
replace country="Russian Federation" if country=="Russia"
replace country="Slovak Republic" if country=="Slovakia"
replace country="Turkiye" if country=="Türkiye"
replace country="United Kingdom" if country=="United Kingdom of Great Britain and Northern Ireland"
replace country="United States" if country=="United States of America"
replace country="Venezuela, RB" if country=="Venezuela"

bys country: egen max_year=max(year)
keep if year==max_year
drop if year==.
drop max_year

save "${path2data}\2. Clean\property_stolen.dta", replace


*------ Safe walking alone
import excel "${path2data}\1. Original\Gallup\Safe Walking Home.xlsx", sheet("Safe Walking Alone") cellrange(B8:Z2340) firstrow clear

rename Time year
destring year, replace

rename Geography country
drop Demographic DemographicValue No DKRF-Z
rename Yes feel_safe

replace country="Congo, Rep." if country=="Congo Brazzaville"
replace country="Congo, Dem. Rep." if country=="Congo (Kinshasa)"
replace country="Cote d'Ivoire" if country=="Ivory Coast (Cote d'Ivoire)"
replace country="Czechia" if country=="Czech Republic"
replace country="Egypt, Arab Rep." if country=="Egypt"
*replace country="The Gambia" if country=="Gambia"
replace country="Netherlands" if country=="Netherlands (Kingdom of the)"
replace country="Hong Kong SAR, China" if country=="Hong Kong S.A.R. of China"
replace country="Iran, Islamic Rep." if country=="Iran"
replace country="Korea, Rep." if country=="South Korea"
replace country="Kyrgyz Republic" if country=="Kyrgyzstan"
replace country="Moldova" if country=="Moldova, Republic of"
replace country="North Macedonia" if country=="Macedonia"
replace country="Russian Federation" if country=="Russia"
replace country="Slovak Republic" if country=="Slovakia"
replace country="Turkiye" if country=="Türkiye"
replace country="United Kingdom" if country=="United Kingdom of Great Britain and Northern Ireland"
replace country="United States" if country=="United States of America"
replace country="Venezuela, RB" if country=="Venezuela"

bys country: egen max_year=max(year)
keep if year==max_year
drop if year==.
drop max_year

save "${path2data}\2. Clean\feel_safe.dta", replace


/*----------------------*/
/*      UPPSALA         */
/*----------------------*/

*------ One side violence
use "${path2data}\1. Original\Uppsala\OneSided_v24_1.dta", clear

keep if year==2023
keep conflict_id dyad_id

save "${path2data}\2. Clean\one_side_raw.dta", replace


*------ Battle related deaths
use "${path2data}\1. Original\Uppsala\BattleDeaths_v24_1.dta", clear

destring year, replace
keep if year==2023
keep conflict_id dyad_id

save "${path2data}\2. Clean\battle_related_deaths_raw.dta", replace


*------ GED to merge with OSV and BRD
use "${path2data}\1. Original\Uppsala\GEDEvent_v24_1.dta", clear

destring year, replace
keep if year==2023

keep conflict_new_id dyad_new_id best country

rename conflict_new_id conflict_id
rename dyad_new_id dyad_id

tostring conflict_id dyad_id, replace

merge m:1 conflict_id dyad_id using "${path2data}\2. Clean\one_side_raw.dta", gen(os)
merge m:1 conflict_id dyad_id using "${path2data}\2. Clean\battle_related_deaths_raw.dta", gen(brd)

replace country="Congo, Rep." if country=="Congo"
replace country="Congo, Dem. Rep." if country=="DR Congo (Zaire)"
replace country="Egypt, Arab Rep." if country=="Egypt"
replace country="Iran, Islamic Rep." if country=="Iran"
replace country="Myanmar" if country=="Myanmar (Burma)"
replace country="Kyrgyz Republic" if country=="Kyrgyzstan"
replace country="Russian Federation" if country=="Russia (Soviet Union)"
replace country="Turkiye" if country=="Turkey"

*Generating overall counts by country
preserve
keep if os==3
collapse (sum) best, by(country)
rename best one_side
save "${path2data}\2. Clean\one_side.dta", replace
restore

preserve
keep if brd==3
collapse (sum) best, by(country)
rename best brd
save "${path2data}\2. Clean\battle_related_deaths.dta", replace
restore

/*----------------------*/
/*  Terrorism deaths    */
/*----------------------*/

/*
import excel "C:\Users\nrodriguez\OneDrive - World Justice Project\Programmatic\Index Third Party Sources\2023 Index\Quantitative Checks\TPS\Center for Systemic Peace\HCTBSep2021list.xls", sheet("termap1") firstrow clear
rename LOC wdi_code
keep if YEAR>=2016
drop if YEAR>2020
merge m:1 wdi_code using "countries.dta"
drop if _merge==2

replace country="Burkina Faso" if wdi_code=="BFO"
replace country="Bangladesh" if wdi_code=="BNG"
replace country="Cameroon" if wdi_code=="CAO"
replace country="Indonesia" if wdi_code=="INS"
replace country="Nigeria" if wdi_code=="NIG"
replace country="Philippines" if wdi_code=="PHI"
replace country="Sri Lanka" if wdi_code=="SRI"
replace country="United Kingdom" if wdi_code=="UKG"

drop if country==""

gen events=1

preserve
collapse(sum) DEATH events, by(country)
rename DEATH terrorism_deaths_2016_2020_norm
rename events terrorism_events_2016_2020_norm
save "HCTB 5 year.dta", replace
restore

preserve
keep if YEAR==2020
collapse(sum) DEATH events, by(country)
rename DEATH terrorism_deaths_2020_norm
rename events terrorism_events_2020_norm
save "HCTB year.dta", replace
restore
*/

/*----------------------*/
/*       Homicides      */
/*----------------------*/

*------ UNOCD
import excel "${path2data}\1. Original\UNODC\data_cts_intentional_homicide.xlsx", sheet("data_cts_intentional_homicide") cellrange(A3:M117073) firstrow clear

keep if Unitofmeasurement=="Rate per 100,000 population"
keep if Indicator=="Victims of intentional homicide"
keep if Dimension=="Total"
keep if Category=="Total"
keep if Sex=="Total"
keep if Age=="Total"
drop Region-Age Unitofmeasurement Source

bys Country: egen max_year=max(Year)
keep if Year==max_year
drop max_year

rename Iso3_code wdi_code

save "${path2data}\2. Clean\homicides.dta", replace


*------ WHO
import delimited "${path2data}\1. Original\WHO\data.csv", clear 
keep if dim1=="Both sexes"
keep location period factvaluenumeric
rename location country

replace country="Congo, Rep." if country=="Congo"
replace country="Congo, Dem. Rep." if country=="Democratic Republic of the Congo"
replace country="Cote d'Ivoire" if country=="CÃ´te dâIvoire"
replace country="Czechia" if country=="Czech Republic"
replace country="Egypt, Arab Rep." if country=="Egypt"
*replace country="The Gambia" if country=="Gambia"
replace country="Hong Kong SAR, China" if country=="Hong Kong"
replace country="Iran, Islamic Rep." if country=="Iran"
replace country="Korea, Rep." if country=="South Korea"
replace country="Kyrgyz Republic" if country=="Kyrgyzstan"
replace country="Moldova" if country=="Moldova, Republic of"
replace country="North Macedonia" if country=="Macedonia"
replace country="Russian Federation" if country=="Russia"
replace country="Slovak Republic" if country=="Slovakia"
replace country="Turkiye" if country=="Türkiye"
replace country="United Kingdom" if country=="United Kingdom of Great Britain and Northern Ireland"
replace country="United States" if country=="United States of America"
replace country="Venezuela, RB" if country=="Venezuela (Bolivarian Republic of)"

keep if period==2019

save "${path2data}\2. Clean\homicides_who.dta", replace


/*=================================================================================================================
					2. Merge datasets
=================================================================================================================*/


use "${path2data}\2. Clean\general_info.dta", clear

replace country="Bahamas" if country=="The Bahamas"
replace country="Gambia" if country=="The Gambia"


*------PTS
merge 1:1 country using "${path2data}\2. Clean\PTS_2023.dta"
tab country if _merge==1
drop if _merge==2
drop _merge 
rename year year_PTS

*------Coups
merge 1:1 country using "${path2data}\2. Clean\coups.dta"
tab country if _merge==2
drop if _merge==2
drop _merge

*------Property stolen
merge 1:1 country using "${path2data}\2. Clean\property_stolen.dta"
tab country if _merge==1
drop if _merge==2
drop _merge 
rename year year_ps

*------Feel safe
merge 1:1 country using "${path2data}\2. Clean\feel_safe.dta"
tab country if _merge==1
drop if _merge==2
drop _merge 
rename year year_fs


*------One side
merge 1:1 country using "${path2data}\2. Clean\one_side.dta"
tab country if _merge==2
drop if _merge==2
drop _merge 

*------BRD
merge 1:1 country using "${path2data}\2. Clean\battle_related_deaths.dta"
tab country if _merge==2
drop if _merge==2
drop _merge 

/*
*------HCTB

merge 1:1 country using "HCTB 5 year.dta"
drop _merge

merge 1:1 country using "HCTB year.dta"
drop _merge
*/

*------Homicides

merge 1:1 wdi_code using "${path2data}\2. Clean\homicides.dta"
drop if _merge==2
drop _merge Country
rename Year year_homicides_un

merge 1:1 country using "${path2data}\2. Clean\homicides_who.dta"
tab country if _merge==2
drop if _merge==2
rename period year_homicides_who
replace year_homicides_who=. if VALUE!=.

gen homicides_un_2023_norm=VALUE
replace homicides_un_2023_norm=factvaluenumeric if homicides_un_2023_norm==.
drop VALUE factvaluenumeric _merge


order year*, last


/*=================================================================================================================
					3. Rename and clean data
=================================================================================================================*/

drop wdi_code

rename PTS_A pts_2023_norm
rename coup coups_2019_2023_norm
rename property_stolen property_stolen_gallup_2023_norm
rename feel_safe feel_safe_gallup_2023_norm
rename one_side casualties_one_sided_2023_norm
rename brd battle_deaths_2023_norm

replace coups_2019_2023_norm=1-coups_2019_2023_norm
replace coups_2019_2023_norm=0 if coups_2019_2023_norm==.

foreach var of varlist  casualties_one_sided_2023_norm battle_deaths_2023_norm  {
replace `var'=0 if `var'==.
}


order country coups_2019_2023_norm feel_safe_gallup_2023_norm property_stolen_gallup_2023_norm pts_2023_norm battle_deaths_2023_norm casualties_one_sided_2023_norm homicides_un_2023_norm

br

*order country coups_2018_2022_norm terrorism_deaths_2020_norm terrorism_deaths_2016_2020_norm terrorism_events_2020_norm terrorism_events_2016_2020_norm feel_safe_gallup_2022_norm property_stolen_gallup_2022_norm pts_2022_norm battle_deaths_2022_norm casualties_one_sided_2022_norm homicides_un_2021_norm

br country coups_2019_2023_norm feel_safe_gallup_2023_norm property_stolen_gallup_2023_norm pts_2023_norm battle_deaths_2023_norm casualties_one_sided_2023_norm homicides_un_2023_norm


save "${path2data}\2. Clean\TPS_index.dta", replace











