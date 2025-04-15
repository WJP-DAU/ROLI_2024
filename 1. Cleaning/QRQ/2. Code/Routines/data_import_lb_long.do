/*=================================================================================================================
Project:		Global ROLI QRQ cleaning and analysis
Routine:		Data import LB LONG
Author(s):		Natalia Rodriguez 	(nrodriguez@worldjusticeproject.org)
Dependencies:  	World Justice Project
Creation Date:	April, 2024

Description:
Data import dofile for the cleaning and analyzing the QRQ LONG data within the Global ROLI.
This do-file imports the original LB datasets exported by the QRQ team from Alchemer and renames all variables
according to the QRQ datamap.

=================================================================================================================*/

/*=================================================================================================================
					Data Loading
=================================================================================================================*/

*--- Loading data from Excel (original exports from the QRQ team)

/*-----------*/
/* 3. Labor  */
/*-----------*/

**** LONGITUDINAL ****

import excel "$path2data\1. Original\LB Long 2024", sheet("Worksheet") firstrow clear

gen longitudinal=1
gen question="lb"
rename SG_id id_original
rename Vlanguage language
rename WJP_country country

egen id=concat(language longitudinal id_original), punct(_)
egen id_alex=concat(question id), punct(_)
drop id id_original

**We are keeping the responses from last year (_lb)
keep  WJP_login WJP_password id_alex country question _lb*
order WJP_login WJP_password id_alex country question

*Rename variables
rename _lb* lb*

*Destring
destring lb_*, replace


/*Harmonizing question numbering according to old QRQ*/

rename lb_q26b lb_q28b
rename lb_q26a lb_q28a
rename lb_q25g lb_q26g
rename lb_q25f lb_q26f
rename lb_q25e lb_q26e
rename lb_q25d lb_q26d
rename lb_q25c lb_q26c
rename lb_q25b lb_q26b
rename lb_q25a lb_q26a
rename lb_q24j lb_q25j
rename lb_q24i lb_q25i
rename lb_q24h lb_q25h
rename lb_q24g lb_q25g
rename lb_q24f lb_q25f
rename lb_q24e lb_q25e
rename lb_q24d lb_q25d
rename lb_q24c lb_q25c
rename lb_q24b lb_q25b
rename lb_q24a lb_q25a
rename lb_q23h lb_q24h
rename lb_q23g lb_q24g
rename lb_q23f lb_q24f
rename lb_q23e lb_q24e
rename lb_q23d lb_q24d
rename lb_q23c lb_q24c
rename lb_q23b lb_q24b
rename lb_q23a lb_q24a
rename lb_q22g lb_q23g
rename lb_q22f lb_q23f
rename lb_q22e lb_q23e
rename lb_q22d lb_q23d
rename lb_q22c lb_q23c
rename lb_q22b lb_q23b
rename lb_q22a lb_q23a
rename lb_q21 lb_q22
rename lb_q20i lb_q21j
rename lb_q20h lb_q21i
rename lb_q20g lb_q21g
rename lb_q20f lb_q21f
rename lb_q20e lb_q21e
rename lb_q20d lb_q21d
rename lb_q20c lb_q21c
rename lb_q20b lb_q21b
rename lb_q20a lb_q21a
rename lb_q19h lb_q20h
rename lb_q19g lb_q20g
rename lb_q19f lb_q20f
rename lb_q19e lb_q20e
rename lb_q19d lb_q20d
rename lb_q19c lb_q20c
rename lb_q19b lb_q20b
rename lb_q19a lb_q20a
rename lb_q18d lb_q19d
rename lb_q18c lb_q19c
rename lb_q18b lb_q19b
rename lb_q18a lb_q19a
rename lb_q17d lb_q18d
rename lb_q17c lb_q18c
rename lb_q17b lb_q18b
rename lb_q17a lb_q18a
rename lb_q16e lb_q17e
rename lb_q16d lb_q17d
rename lb_q16c lb_q17c
rename lb_q16b lb_q17b
rename lb_q16a lb_q17a
rename lb_q15f lb_q16f
rename lb_q15e lb_q16e
rename lb_q15d lb_q16d
rename lb_q15c lb_q16c
rename lb_q15b lb_q16b
rename lb_q15a lb_q16a
rename lb_q14e lb_q15e
rename lb_q14d lb_q15d
rename lb_q14c lb_q15c
rename lb_q14b lb_q15b
rename lb_q14a lb_q15a
rename lb_q13 lb_q14
rename lb_q12f lb_q13f
rename lb_q12e lb_q13e
rename lb_q12d lb_q13d
rename lb_q12c lb_q13c
rename lb_q12b lb_q13b
rename lb_q12a lb_q13a
rename lb_q11 lb_q12
rename lb_q10b lb_q11b
rename lb_q10a lb_q11a
rename lb_q9l lb_q10l
rename lb_q9k lb_q10k
rename lb_q9j lb_q10j
rename lb_q9i lb_q10i
rename lb_q9h lb_q10h
rename lb_q9g lb_q10g
rename lb_q9f lb_q10f
rename lb_q9e lb_q10e
rename lb_q9d lb_q10d
rename lb_q9c lb_q10c
rename lb_q9b lb_q10b
rename lb_q9a lb_q10a
rename lb_q8 lb_q9
rename lb_q7 lb_q8
rename lb_q6 lb_q7
rename lb_q5e lb_q6e
rename lb_q5d lb_q6d
rename lb_q5c lb_q6c
rename lb_q5b lb_q6b
rename lb_q5a lb_q6a
rename lb_q4_currency lb_q5_currency
rename lb_q4 lb_q5
rename lb_q3d lb_q4d
rename lb_q3c lb_q4c
rename lb_q3b lb_q4b
rename lb_q3a lb_q4a
rename lb_q2d lb_q3d
rename lb_q2c lb_q3c
rename lb_q2b lb_q3b
rename lb_q2a lb_q3a
rename lb_q1d lb_q2d
rename lb_q1c lb_q2c
rename lb_q1b lb_q2b
rename lb_q1a lb_q2a


/* Recoding questions - Percentages */
foreach var of varlist lb_q11a lb_q11b lb_q12 {
	replace `var'=1 if `var'==0 
	replace `var'=2 if `var'==5
	replace `var'=3 if `var'==25
	replace `var'=4 if `var'==50
	replace `var'=5 if `var'==75
	replace `var'=6 if `var'==100
}


/* Recoding 9 to missing */
#delimit ;
foreach v in 
lb_q2a lb_q2b lb_q2c lb_q2d 
lb_q3a lb_q3b lb_q3c lb_q3d 
lb_q4a lb_q4b lb_q4c lb_q4d 
lb_q6a lb_q6b lb_q6c lb_q6d lb_q6e 
lb_q7 lb_q8 lb_q9 
lb_q10a lb_q10b lb_q10c lb_q10d lb_q10e lb_q10f lb_q10g lb_q10h lb_q10i lb_q10j lb_q10k lb_q10l 
lb_q11a lb_q11b 
lb_q12 
lb_q13a lb_q13b lb_q13c lb_q13d lb_q13e lb_q13f 
lb_q14 
lb_q15a lb_q15b lb_q15c lb_q15d lb_q15e 
lb_q16a lb_q16b lb_q16c lb_q16d lb_q16e lb_q16f 
lb_q17a lb_q17b lb_q17c lb_q17d lb_q17e 
lb_q18a lb_q18b lb_q18c lb_q18d 
lb_q19a lb_q19b lb_q19c lb_q19d 
lb_q20a lb_q20b lb_q20c lb_q20d lb_q20e lb_q20f lb_q20g lb_q20h 
lb_q21a lb_q21b lb_q21c lb_q21d lb_q21e lb_q21f lb_q21g lb_q21i lb_q21j 
lb_q22 
lb_q23a lb_q23b lb_q23c lb_q23d lb_q23e lb_q23f lb_q23g 
lb_q24a lb_q24b lb_q24c lb_q24d lb_q24e lb_q24f lb_q24g lb_q24h 
lb_q25a lb_q25b lb_q25c lb_q25d lb_q25e lb_q25f lb_q25g lb_q25h lb_q25i lb_q25j 
lb_q26a lb_q26b lb_q26c lb_q26d lb_q26e lb_q26f lb_q26g 
lb_q28a lb_q28b
{ ;
	replace `v'=. if `v'==9 ;
} ;
#delimit cr


/* Check that all variables don't have 9-99s */
#delimit ;
foreach v in 
lb_q2a lb_q2b lb_q2c lb_q2d 
lb_q3a lb_q3b lb_q3c lb_q3d 
lb_q4a lb_q4b lb_q4c lb_q4d 
lb_q6a lb_q6b lb_q6c lb_q6d lb_q6e 
lb_q7 lb_q8 lb_q9 
lb_q10a lb_q10b lb_q10c lb_q10d lb_q10e lb_q10f lb_q10g lb_q10h lb_q10i lb_q10j lb_q10k lb_q10l 
lb_q11a lb_q11b 
lb_q12 
lb_q13a lb_q13b lb_q13c lb_q13d lb_q13e lb_q13f 
lb_q14 
lb_q15a lb_q15b lb_q15c lb_q15d lb_q15e 
lb_q16a lb_q16b lb_q16c lb_q16d lb_q16e lb_q16f 
lb_q17a lb_q17b lb_q17c lb_q17d lb_q17e 
lb_q18a lb_q18b lb_q18c lb_q18d 
lb_q19a lb_q19b lb_q19c lb_q19d 
lb_q20a lb_q20b lb_q20c lb_q20d lb_q20e lb_q20f lb_q20g lb_q20h 
lb_q21a lb_q21b lb_q21c lb_q21d lb_q21e lb_q21f lb_q21g lb_q21i lb_q21j 
lb_q22 
lb_q23a lb_q23b lb_q23c lb_q23d lb_q23e lb_q23f lb_q23g 
lb_q24a lb_q24b lb_q24c lb_q24d lb_q24e lb_q24f lb_q24g lb_q24h 
lb_q25a lb_q25b lb_q25c lb_q25d lb_q25e lb_q25f lb_q25g lb_q25h lb_q25i lb_q25j 
lb_q26a lb_q26b lb_q26c lb_q26d lb_q26e lb_q26f lb_q26g 
lb_q28a lb_q28b
{ ;
	list `v' if `v'==9 & `v'!=. ;
} ;
#delimit cr

sum lb_*	

destring WJP_password, replace


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

save "$path2data\1. Original\lb_final_long_2023.dta", replace



