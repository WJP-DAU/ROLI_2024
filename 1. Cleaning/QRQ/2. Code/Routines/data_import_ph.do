/*=================================================================================================================
Project:		Global ROLI QRQ cleaning and analysis
Routine:		Data import PH
Author(s):		Natalia Rodriguez 	(nrodriguez@worldjusticeproject.org)
Dependencies:  	World Justice Project
Creation Date:	April, 2024

Description:
Data import dofile for the cleaning and analyzing the QRQ data within the Global ROLI.
This do-file imports the original PH datasets exported by the QRQ team from Alchemer and renames all variables
according to the QRQ datamap.

=================================================================================================================*/

/*=================================================================================================================
					Data Loading
=================================================================================================================*/

*--- Loading data from Excel (original exports from the QRQ team)

/*------------------*/
/* 4. Public Health */
/*------------------*/


**** LONGITUDINAL ****

import excel "$path2data\1. Original\PH Long 2024", sheet("Worksheet") firstrow clear
drop _ph*

rename ResponseID SG_id
rename Language Vlanguage
rename wjp_login WJP_login 
rename wjp_password WJP_password 
rename wjp_country WJP_country

order SG_id
drop ph_leftout-ph_referral3_language Status
gen longitudinal=1
save "$path2data\1. Original\ph_final_long.dta", replace


**** REGULAR ****

import excel "$path2data\1. Original\PH Reg 2024", sheet("Worksheet") firstrow clear
drop iVstatus ph_leftout-DX 
gen longitudinal=0


**** Append the regular and the longitudinal databases ****
append using "$path2data\1. Original\ph_final_long.dta"

gen question="ph"
destring SG_id ph_*, replace

* Check for experts without id
count if SG_id==.

rename SG_id id_original
rename Vlanguage language
rename WJP_country country

* Create ID
egen id=concat(language longitudinal id_original), punct(_)
egen id_alex=concat(question id), punct(_)
drop id id_original

/* These 3 lines are for incorporating 2023 data */
gen year=2024
gen regular=0
drop if language=="Last_Year"

order question year regular longitudinal id_alex language country WJP_login

/*Harmonizing question numbering according to old QRQ*/

**NO HARMONIZATION - WE DIDN'T REMOVE PH QUESTIONS


/* Recoding questions - Percentages */
foreach v in ph_q5a ph_q5b ph_q5c ph_q5d {
	replace `v'=1 if `v'==0
	replace `v'=2 if `v'==5
	replace `v'=3 if `v'==25
	replace `v'=4 if `v'==50
	replace `v'=5 if `v'==75
	replace `v'=6 if `v'==100
}


/* Recoding 9 to missing */
#delimit ;
foreach v in 
ph_q1a ph_q1b ph_q1c ph_q1d 
ph_q2 ph_q3 
ph_q4a ph_q4b ph_q4c 
ph_q5a ph_q5b ph_q5c ph_q5d 
ph_q6a ph_q6b ph_q6c ph_q6d ph_q6e ph_q6f ph_q6g 
ph_q7 
ph_q8a ph_q8b ph_q8c ph_q8d ph_q8e ph_q8f ph_q8g 
ph_q9a ph_q9b ph_q9c ph_q9d 
ph_q10a ph_q10b ph_q10c ph_q10d ph_q10e ph_q10f 
ph_q11a ph_q11b ph_q11c 
ph_q12a ph_q12b ph_q12c ph_q12d ph_q12e 
ph_q13 ph_q14
{ ;
	replace `v'=. if `v'==9 ;
} ;
#delimit cr


/* Check that all variables don't have 9-99s */
#delimit ;
foreach v in 
ph_q1a ph_q1b ph_q1c ph_q1d 
ph_q2 ph_q3 
ph_q4a ph_q4b ph_q4c 
ph_q5a ph_q5b ph_q5c ph_q5d 
ph_q6a ph_q6b ph_q6c ph_q6d ph_q6e ph_q6f ph_q6g 
ph_q7 
ph_q8a ph_q8b ph_q8c ph_q8d ph_q8e ph_q8f ph_q8g 
ph_q9a ph_q9b ph_q9c ph_q9d 
ph_q10a ph_q10b ph_q10c ph_q10d ph_q10e ph_q10f 
ph_q11a ph_q11b ph_q11c 
ph_q12a ph_q12b ph_q12c ph_q12d ph_q12e 
ph_q13 ph_q14
{ ;
	list `v' if `v'==9 & `v'!=. ;
} ;
#delimit cr


sum ph_*	

/* Change names to match the MAP file and the GPP */

drop if country=="Burundi"

replace country="Congo, Rep." if country=="Republic of Congo"
replace country="Korea, Rep." if country=="Republic of Korea"
replace country="Egypt, Arab Rep." if country=="Egypt"
replace country="Iran, Islamic Rep." if country=="Iran"
replace country="St. Kitts and Nevis" if country=="Saint Kitts and Nevis"		
replace country="St. Lucia" if country=="Saint Lucia"
replace country="St. Vincent and the Grenadines" if country=="Saint Vincent and the Grenadines"
replace country="Cote d'Ivoire" if country=="Ivory Coast"
replace country="Congo, Dem. Rep." if country=="Democratic Republic of Congo"
replace country="Gambia" if country=="The Gambia"

replace country="Kyrgyz Republic" if country=="Kyrgyzstan"
replace country="North Macedonia" if country=="Macedonia, FYR"
replace country="Russian Federation" if country=="Russia"
replace country="Venezuela, RB" if country=="Venezuela"
replace country="Czechia" if country=="Czech Republic"
replace country="Turkiye" if country=="Turkey"

/* Save final dataset */

save "$path2data\1. Original\ph_final.dta", replace
erase "$path2data\1. Original\ph_final_long.dta"

