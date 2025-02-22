/*=================================================================================================================
Project:		Global ROLI QRQ cleaning and analysis
Routine:		Data import CC LONG
Author(s):		Natalia Rodriguez 	(nrodriguez@worldjusticeproject.org)
Dependencies:  	World Justice Project
Creation Date:	April, 2024

Description:
Data import dofile for the cleaning and analyzing the QRQ data within the Global ROLI.
This do-file imports the original CC datasets exported by the QRQ team from Alchemer and renames all variables
according to the QRQ datamap.

=================================================================================================================*/

/*=================================================================================================================
					Data Loading
=================================================================================================================*/

*--- Loading data from Excel (original exports from the QRQ team)

/*-----------*/
/* 1. Civil  */
/*-----------*/

**** LONGITUDINAL ****

import excel "$path2data\CC Long 2024.xlsx", sheet("Worksheet") firstrow clear

gen longitudinal=1
gen question="cc"
rename SG_id id_original
rename Vlanguage language
rename WJP_country country

egen id=concat(language longitudinal id_original), punct(_)
egen id_alex=concat(question id), punct(_)
drop id id_original

**We are keeping the responses from last year (_cc)
keep  WJP_login WJP_password id_alex country question _cc*
order WJP_login WJP_password id_alex country question

*Rename variables
rename _cc* cc*

*Destring
destring cc_*, replace

/*Harmonizing question numbering according to old QRQ*/

rename cc_q37b cc_q40b
rename cc_q37a cc_q40a
rename cc_q36e cc_q39e
rename cc_q36d cc_q39d
rename cc_q36c cc_q39c
rename cc_q36b cc_q39b
rename cc_q36a cc_q39a
rename cc_q35 cc_q38
rename cc_q34e cc_q37e
rename cc_q34d cc_q37d
rename cc_q34c cc_q37c
rename cc_q34b cc_q37b
rename cc_q34a cc_q37a
rename cc_q33h cc_q36h
rename cc_q33g cc_q36g
rename cc_q33f cc_q36f
rename cc_q33e cc_q36e
rename cc_q33d cc_q36d
rename cc_q33c cc_q36c
rename cc_q33b cc_q36b
rename cc_q33a cc_q36a
rename cc_q32g cc_q35g
rename cc_q32f cc_q35f
rename cc_q32e cc_q35e
rename cc_q32d cc_q35d
rename cc_q32c cc_q35c
rename cc_q32b cc_q35b
rename cc_q32a cc_q35a
rename cc_q31l cc_q34l
rename cc_q31k cc_q34k
rename cc_q31j cc_q34j
rename cc_q31i cc_q34i
rename cc_q31h cc_q34h
rename cc_q31g cc_q34g
rename cc_q31f cc_q34f
rename cc_q31e cc_q34e
rename cc_q31d cc_q34d
rename cc_q31c cc_q34c
rename cc_q31b cc_q34b
rename cc_q31a cc_q34a
rename cc_q30 cc_q33
rename cc_q29k cc_q32l
rename cc_q29j cc_q32k
rename cc_q29i cc_q32j
rename cc_q29h cc_q32i
rename cc_q29g cc_q32h
rename cc_q29f cc_q32f
rename cc_q29e cc_q32e
rename cc_q29d cc_q32d
rename cc_q29c cc_q32c
rename cc_q29b cc_q32b
rename cc_q29a cc_q32a
rename cc_q28h cc_q31h
rename cc_q28g cc_q31g
rename cc_q28f cc_q31f
rename cc_q28e cc_q31e
rename cc_q28d cc_q31d
rename cc_q28c cc_q31c
rename cc_q28b cc_q31b
rename cc_q28a cc_q31a
rename cc_q27c cc_q30c
rename cc_q27b cc_q30b
rename cc_q27a cc_q30a
rename cc_q26d cc_q29d
rename cc_q26c cc_q29c
rename cc_q26b cc_q29b
rename cc_q26a cc_q29a
rename cc_q25f cc_q28f
rename cc_q25e cc_q28e
rename cc_q25d cc_q28d
rename cc_q25c cc_q28c
rename cc_q25b cc_q28b
rename cc_q25a cc_q28a
rename cc_q24 cc_q27
rename cc_q23k cc_q26k
rename cc_q23j cc_q26j
rename cc_q23i cc_q26i
rename cc_q23h cc_q26h
rename cc_q23g cc_q26g
rename cc_q23f cc_q26f
rename cc_q23e cc_q26e
rename cc_q23d cc_q26d
rename cc_q23c cc_q26c
rename cc_q23b cc_q26b
rename cc_q23a cc_q26a
rename cc_q22 cc_q25
rename cc_q21 cc_q24
rename cc_q20f cc_q23f
rename cc_q20e cc_q23e
rename cc_q20d cc_q23d
rename cc_q20c cc_q23c
rename cc_q20b cc_q23b
rename cc_q20a cc_q23a
rename cc_q19c cc_q22c
rename cc_q19b cc_q22b
rename cc_q19a cc_q22a
rename cc_q18 cc_q21
rename cc_q17b cc_q20b
rename cc_q17a cc_q20a
rename cc_q16l cc_q19l
rename cc_q16k cc_q19k
rename cc_q16j cc_q19j
rename cc_q16i cc_q19i
rename cc_q16h cc_q19h
rename cc_q16g cc_q19g
rename cc_q16f cc_q19f
rename cc_q16e cc_q19e
rename cc_q16d cc_q19d
rename cc_q16c cc_q19c
rename cc_q16b cc_q19b
rename cc_q16a cc_q19a
rename cc_q15g cc_q16g
rename cc_q15f cc_q16f
rename cc_q15e cc_q16e
rename cc_q15d cc_q16d
rename cc_q15c cc_q16c
rename cc_q15b cc_q16b
rename cc_q15a cc_q16a
rename cc_q14 cc_q15
rename cc_q13b cc_q14b
rename cc_q13a cc_q14a
rename cc_q12 cc_q13
rename cc_q11 cc_q12
rename cc_q10b cc_q11b
rename cc_q10a cc_q11a
rename cc_q9 cc_q10
rename cc_q8c cc_q9c
rename cc_q8b cc_q9b
rename cc_q8a cc_q9a
rename cc_q7 cc_q8
rename cc_q6d cc_q7d
rename cc_q6c cc_q7c
rename cc_q6b cc_q7b
rename cc_q6a cc_q7a
rename cc_q5_currency cc_q6_currency
rename cc_q5 cc_q6
rename cc_q4c cc_q5c
rename cc_q4b cc_q5b
rename cc_q4a cc_q5a
rename cc_q3c cc_q4c
rename cc_q3b cc_q4b
rename cc_q3a cc_q4a
rename cc_q2c cc_q3c
rename cc_q2b cc_q3b
rename cc_q2a cc_q3a
rename cc_q1 cc_q1

/* Recoding questions - Percentages */
foreach v in cc_q20a cc_q20b cc_q21 {
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
cc_q1 cc_q3a cc_q3b cc_q3c 
cc_q4a cc_q4b cc_q4c 
cc_q5a cc_q5b cc_q5c 
cc_q7a cc_q7b cc_q7c cc_q7d 
cc_q8 
cc_q9a cc_q9b cc_q9c 
cc_q10 
cc_q11a cc_q11b 
cc_q12 cc_q13 
cc_q14a cc_q14b cc_q15 
cc_q16a cc_q16b cc_q16c cc_q16d cc_q16e cc_q16f cc_q16g 
cc_q19a cc_q19b cc_q19c cc_q19d cc_q19e cc_q19f cc_q19g cc_q19h cc_q19i cc_q19j cc_q19k cc_q19l 
cc_q20a cc_q20b cc_q21 
cc_q22a cc_q22b cc_q22c cc_q23a cc_q23b cc_q23c cc_q23d cc_q23e cc_q23f cc_q24 cc_q25 
cc_q27 
cc_q28a cc_q28b cc_q28c cc_q28d cc_q28e cc_q28f 
cc_q29a cc_q29b cc_q29c cc_q29d 
cc_q30a cc_q30b cc_q30c 
cc_q31a cc_q31b cc_q31c cc_q31d cc_q31e cc_q31f cc_q31g cc_q31h 
cc_q32a cc_q32b cc_q32c cc_q32d cc_q32e cc_q32f cc_q32h cc_q32i cc_q32j cc_q32k cc_q32l 
cc_q33 
cc_q34a cc_q34b cc_q34c cc_q34d cc_q34e cc_q34f cc_q34g cc_q34h cc_q34i cc_q34j cc_q34k cc_q34l 
cc_q35a cc_q35b cc_q35c cc_q35d cc_q35e cc_q35f cc_q35g 
cc_q36a cc_q36b cc_q36c cc_q36d cc_q36e cc_q36f cc_q36g cc_q36h 
cc_q37a cc_q37b cc_q37c cc_q37d cc_q37e 
cc_q38 
cc_q39a cc_q39b cc_q39c cc_q39d cc_q39e 
cc_q40a cc_q40b
{ ;
	replace `v'=. if `v'==9 ;
} ;
#delimit cr


/* Recoding 99 to missing - Scale 1-10 */
foreach v in cc_q26a cc_q26b cc_q26c cc_q26d cc_q26e cc_q26f cc_q26g cc_q26h cc_q26i cc_q26j cc_q26k {
	replace `v'=. if `v'==99
}


/* Check that all variables don't have 9/99s */
#delimit ;
foreach v in 
cc_q1 cc_q3a cc_q3b cc_q3c 
cc_q4a cc_q4b cc_q4c 
cc_q5a cc_q5b cc_q5c 
cc_q7a cc_q7b cc_q7c cc_q7d 
cc_q8 
cc_q9a cc_q9b cc_q9c 
cc_q10 
cc_q11a cc_q11b 
cc_q12 cc_q13 
cc_q14a cc_q14b cc_q15 
cc_q16a cc_q16b cc_q16c cc_q16d cc_q16e cc_q16f cc_q16g 
cc_q19a cc_q19b cc_q19c cc_q19d cc_q19e cc_q19f cc_q19g cc_q19h cc_q19i cc_q19j cc_q19k cc_q19l 
cc_q20a cc_q20b cc_q21 
cc_q22a cc_q22b cc_q22c cc_q23a cc_q23b cc_q23c cc_q23d cc_q23e cc_q23f cc_q24 cc_q25 
cc_q27 
cc_q28a cc_q28b cc_q28c cc_q28d cc_q28e cc_q28f 
cc_q29a cc_q29b cc_q29c cc_q29d 
cc_q30a cc_q30b cc_q30c 
cc_q31a cc_q31b cc_q31c cc_q31d cc_q31e cc_q31f cc_q31g cc_q31h 
cc_q32a cc_q32b cc_q32c cc_q32d cc_q32e cc_q32f cc_q32h cc_q32i cc_q32j cc_q32k cc_q32l 
cc_q33 
cc_q34a cc_q34b cc_q34c cc_q34d cc_q34e cc_q34f cc_q34g cc_q34h cc_q34i cc_q34j cc_q34k cc_q34l 
cc_q35a cc_q35b cc_q35c cc_q35d cc_q35e cc_q35f cc_q35g 
cc_q36a cc_q36b cc_q36c cc_q36d cc_q36e cc_q36f cc_q36g cc_q36h 
cc_q37a cc_q37b cc_q37c cc_q37d cc_q37e 
cc_q38 
cc_q39a cc_q39b cc_q39c cc_q39d cc_q39e 
cc_q40a cc_q40b
{ ;
	list `v' if `v'==9 & `v'!=. ;
} ;
#delimit cr	
	
foreach v in cc_q26a cc_q26b cc_q26c cc_q26d cc_q26e cc_q26f cc_q26g cc_q26h cc_q26i cc_q26j cc_q26k  {
		list `v' if `v'==99 & `v'!=.
	}

sum cc_*

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

save "$path2exp\Long\cc_final_long_2023.dta", replace
