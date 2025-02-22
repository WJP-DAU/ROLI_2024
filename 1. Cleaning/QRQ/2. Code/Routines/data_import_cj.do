/*=================================================================================================================
Project:		Global ROLI QRQ cleaning and analysis
Routine:		Data import CJ
Author(s):		Natalia Rodriguez 	(nrodriguez@worldjusticeproject.org)
Dependencies:  	World Justice Project
Creation Date:	April, 2024

Description:
Data import dofile for the cleaning and analyzing the QRQ data within the Global ROLI.
This do-file imports the original CJ datasets exported by the QRQ team from Alchemer and renames all variables
according to the QRQ datamap.

=================================================================================================================*/

/*=================================================================================================================
					Data Loading
=================================================================================================================*/

*--- Loading data from Excel (original exports from the QRQ team)

/*--------------*/
/* 2. Criminal  */
/*--------------*/


**** LONGITUDINAL ****

import excel "$path2data\1. Original\CJ Long 2024", sheet("Worksheet") firstrow clear
drop _cj*
drop iVstatus cj_leftout-cj_referral3_language 
order SG_id
gen longitudinal=1
save "$path2data\1. Original\cj_final_long.dta", replace


**** REGULAR ****

import excel "$path2data\1. Original\CJ Reg 2024", sheet("Worksheet") firstrow clear
drop iVstatus cj_leftout-cj_referral3_language 
gen longitudinal=0


**** Append the regular and the longitudinal databases ****

append using "$path2data\1. Original\cj_final_long.dta"

gen question="cj"
destring SG_id cj_*, replace

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

rename cj_q38h cj_q42h
rename cj_q38g cj_q42g
rename cj_q38f cj_q42f
rename cj_q38e cj_q42e
rename cj_q38d cj_q42d
rename cj_q38c cj_q42c
rename cj_q38b cj_q42b
rename cj_q38a cj_q42a
rename cj_q37h cj_q41h
rename cj_q37g cj_q41g
rename cj_q37f cj_q41f
rename cj_q37e cj_q41e
rename cj_q37d cj_q41d
rename cj_q37c cj_q41c
rename cj_q37b cj_q41b
rename cj_q37a cj_q41a
rename cj_q36h cj_q40h
rename cj_q36g cj_q40g
rename cj_q36f cj_q40f
rename cj_q36e cj_q40e
rename cj_q36d cj_q40d
rename cj_q36c cj_q40c
rename cj_q36b cj_q40b
rename cj_q36a cj_q40a
rename cj_q35l cj_q39l
rename cj_q35k cj_q39k
rename cj_q35j cj_q39j
rename cj_q35i cj_q39i
rename cj_q35h cj_q39h
rename cj_q35g cj_q39g
rename cj_q35f cj_q39f
rename cj_q35e cj_q39e
rename cj_q35d cj_q39d
rename cj_q35c cj_q39c
rename cj_q35b cj_q39b
rename cj_q35a cj_q39a
rename cj_q34 cj_q38
rename cj_q33d cj_q37d
rename cj_q33c cj_q37c
rename cj_q33b cj_q37b
rename cj_q33a cj_q37a
rename cj_q32d cj_q36d
rename cj_q32c cj_q36c
rename cj_q32b cj_q36b
rename cj_q32a cj_q36a
rename cj_q31d cj_q35d
rename cj_q31c cj_q35c
rename cj_q31b cj_q35b
rename cj_q31a cj_q35a
rename cj_q30e cj_q34e
rename cj_q30d cj_q34d
rename cj_q30c cj_q34c
rename cj_q30b cj_q34b
rename cj_q30a cj_q34a
rename cj_q29e cj_q33e
rename cj_q29d cj_q33d
rename cj_q29c cj_q33c
rename cj_q29b cj_q33b
rename cj_q29a cj_q33a
rename cj_q28c cj_q32d
rename cj_q28b cj_q32c
rename cj_q28a cj_q32b
rename cj_q27g cj_q31g
rename cj_q27f cj_q31f
rename cj_q27e cj_q31e
rename cj_q27d cj_q31d
rename cj_q27c cj_q31c
rename cj_q27b cj_q31b
rename cj_q27a cj_q31a
rename cj_q26b cj_q29b
rename cj_q26a cj_q29a
rename cj_q25 cj_q28
rename cj_q24b cj_q27b
rename cj_q24a cj_q27a
rename cj_q23 cj_q26
rename cj_q22c cj_q25c
rename cj_q22b cj_q25b
rename cj_q22a cj_q25a
rename cj_q21c cj_q24c
rename cj_q21b cj_q24b
rename cj_q21a cj_q24a
rename cj_q20e cj_q22e
rename cj_q20d cj_q22d
rename cj_q20c cj_q22c
rename cj_q20b cj_q22b
rename cj_q20a cj_q22a
rename cj_q19k cj_q21k
rename cj_q19j cj_q21j
rename cj_q19i cj_q21i
rename cj_q19h cj_q21h
rename cj_q19g cj_q21g
rename cj_q19f cj_q21f
rename cj_q19e cj_q21e
rename cj_q19d cj_q21d
rename cj_q19c cj_q21c
rename cj_q19b cj_q21b
rename cj_q19a cj_q21a
rename cj_q18p cj_q20p
rename cj_q18o cj_q20o
rename cj_q18n cj_q20n
rename cj_q18m cj_q20m
rename cj_q18l cj_q20l
rename cj_q18k cj_q20k
rename cj_q18j cj_q20j
rename cj_q18i cj_q20i
rename cj_q18h cj_q20h
rename cj_q18g cj_q20g
rename cj_q18f cj_q20f
rename cj_q18e cj_q20e
rename cj_q18d cj_q20d
rename cj_q18c cj_q20c
rename cj_q18b cj_q20b
rename cj_q18a cj_q20a
rename cj_q17g cj_q19g
rename cj_q17f cj_q19f
rename cj_q17e cj_q19e
rename cj_q17d cj_q19d
rename cj_q17c cj_q19c
rename cj_q17b cj_q19b
rename cj_q17a cj_q19a
rename cj_q16e cj_q18e
rename cj_q16d cj_q18d
rename cj_q16c cj_q18c
rename cj_q16b cj_q18b
rename cj_q16a cj_q18a
rename cj_q15m cj_q16m
rename cj_q15l cj_q16l
rename cj_q15k cj_q16k
rename cj_q15j cj_q16j
rename cj_q15i cj_q16i
rename cj_q15h cj_q16h
rename cj_q15g cj_q16g
rename cj_q15f cj_q16f
rename cj_q15e cj_q16e
rename cj_q15d cj_q16d
rename cj_q15c cj_q16c
rename cj_q15b cj_q16b
rename cj_q15a cj_q16a
rename cj_q14 cj_q15
rename cj_q13 cj_q14
rename cj_q12f cj_q13f
rename cj_q12e cj_q13e
rename cj_q12d cj_q13d
rename cj_q12c cj_q13c
rename cj_q12b cj_q13b
rename cj_q12a cj_q13a
rename cj_q11f cj_q12f
rename cj_q11e cj_q12e
rename cj_q11d cj_q12d
rename cj_q11c cj_q12c
rename cj_q11b cj_q12b
rename cj_q11a cj_q12a
rename cj_q10b cj_q11b
rename cj_q10a cj_q11a
rename cj_q9 cj_q10
rename cj_q8 cj_q9
rename cj_q7 cj_q8
rename cj_q6c cj_q7c
rename cj_q6b cj_q7b
rename cj_q6a cj_q7a
rename cj_q5d cj_q6d
rename cj_q5c cj_q6c
rename cj_q5b cj_q6b
rename cj_q5a cj_q6a
rename cj_q4 cj_q4
rename cj_q3c cj_q3c
rename cj_q3b cj_q3b
rename cj_q3a cj_q3a
rename cj_q2 cj_q2
rename cj_q1 cj_q1


/* Recoding questions - Percentages */
foreach v in cj_q22a cj_q22b cj_q22c cj_q22d cj_q22e cj_q24a cj_q24b cj_q24c cj_q25a cj_q25b cj_q25c cj_q28 {
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
cj_q1 cj_q2 cj_q3a cj_q3b cj_q3c cj_q4 
cj_q6a cj_q6b cj_q6c cj_q6d 
cj_q7a cj_q7b cj_q7c 
cj_q8 cj_q9 cj_q10 
cj_q11a cj_q11b 
cj_q12a cj_q12b cj_q12c cj_q12d cj_q12e cj_q12f 
cj_q13a cj_q13b cj_q13c cj_q13d cj_q13e cj_q13f 
cj_q14 cj_q15 
cj_q22a cj_q22b cj_q22c cj_q22d cj_q22e 
cj_q24a cj_q24b cj_q24c 
cj_q25a cj_q25b cj_q25c 
cj_q26 
cj_q27a cj_q27b 
cj_q28 
cj_q29a cj_q29b 
cj_q31a cj_q31b cj_q31c cj_q31d cj_q31e cj_q31f cj_q31g 
cj_q32b cj_q32c cj_q32d 
cj_q33a cj_q33b cj_q33c cj_q33d cj_q33e 
cj_q34a cj_q34b cj_q34c cj_q34d cj_q34e 
cj_q35a cj_q35b cj_q35c cj_q35d 
cj_q36a cj_q36b cj_q36c cj_q36d 
cj_q38 
cj_q39a cj_q39b cj_q39c cj_q39d cj_q39e cj_q39f cj_q39g cj_q39h cj_q39i cj_q39j cj_q39k cj_q39l 
cj_q40a cj_q40b cj_q40c cj_q40d cj_q40e cj_q40f cj_q40g cj_q40h 
cj_q41a cj_q41b cj_q41c cj_q41d cj_q41e cj_q41f cj_q41g cj_q41h 
cj_q42a cj_q42b cj_q42c cj_q42d cj_q42e cj_q42f cj_q42g cj_q42h
{ ;
	replace `v'=. if `v'==9 ;
} ;
#delimit cr


/* Recoding 99 to missing - Scale 1-10 */
#delimit ;
foreach v in 
cj_q16a cj_q16b cj_q16c cj_q16d cj_q16e cj_q16f cj_q16g cj_q16h cj_q16i cj_q16j cj_q16k cj_q16l cj_q16m 
cj_q18a cj_q18b cj_q18c cj_q18d cj_q18e 
cj_q19a cj_q19b cj_q19c cj_q19d cj_q19e cj_q19f cj_q19g 
cj_q20a cj_q20b cj_q20c cj_q20d cj_q20e cj_q20f cj_q20g cj_q20h cj_q20i cj_q20j cj_q20k cj_q20l cj_q20m cj_q20n cj_q20o cj_q20p 
cj_q21a cj_q21b cj_q21c cj_q21d cj_q21e cj_q21f cj_q21g cj_q21h cj_q21i cj_q21j cj_q21k 
cj_q37a cj_q37b cj_q37c cj_q37d 
{ ;
	replace `v'=. if `v'==99 ;
} ;
# delimit cr


/* Check that all variables don't have 9/99s */	
#delimit ;
foreach v in 
cj_q1 cj_q2 cj_q3a cj_q3b cj_q3c cj_q4 
cj_q6a cj_q6b cj_q6c cj_q6d 
cj_q7a cj_q7b cj_q7c 
cj_q8 cj_q9 cj_q10 
cj_q11a cj_q11b 
cj_q12a cj_q12b cj_q12c cj_q12d cj_q12e cj_q12f 
cj_q13a cj_q13b cj_q13c cj_q13d cj_q13e cj_q13f 
cj_q14 cj_q15 
cj_q22a cj_q22b cj_q22c cj_q22d cj_q22e 
cj_q24a cj_q24b cj_q24c 
cj_q25a cj_q25b cj_q25c 
cj_q26 
cj_q27a cj_q27b 
cj_q28 
cj_q29a cj_q29b 
cj_q31a cj_q31b cj_q31c cj_q31d cj_q31e cj_q31f cj_q31g 
cj_q32b cj_q32c cj_q32d 
cj_q33a cj_q33b cj_q33c cj_q33d cj_q33e 
cj_q34a cj_q34b cj_q34c cj_q34d cj_q34e 
cj_q35a cj_q35b cj_q35c cj_q35d 
cj_q36a cj_q36b cj_q36c cj_q36d 
cj_q38 
cj_q39a cj_q39b cj_q39c cj_q39d cj_q39e cj_q39f cj_q39g cj_q39h cj_q39i cj_q39j cj_q39k cj_q39l 
cj_q40a cj_q40b cj_q40c cj_q40d cj_q40e cj_q40f cj_q40g cj_q40h 
cj_q41a cj_q41b cj_q41c cj_q41d cj_q41e cj_q41f cj_q41g cj_q41h 
cj_q42a cj_q42b cj_q42c cj_q42d cj_q42e cj_q42f cj_q42g cj_q42h
{ ;
	list `v' if `v'==9 & `v'!=. ;
} ;
#delimit cr

#delimit ;
foreach v in 
cj_q16a cj_q16b cj_q16c cj_q16d cj_q16e cj_q16f cj_q16g cj_q16h cj_q16i cj_q16j cj_q16k cj_q16l cj_q16m 
cj_q18a cj_q18b cj_q18c cj_q18d cj_q18e 
cj_q19a cj_q19b cj_q19c cj_q19d cj_q19e cj_q19f cj_q19g 
cj_q20a cj_q20b cj_q20c cj_q20d cj_q20e cj_q20f cj_q20g cj_q20h cj_q20i cj_q20j cj_q20k cj_q20l cj_q20m cj_q20n cj_q20o cj_q20p 
cj_q21a cj_q21b cj_q21c cj_q21d cj_q21e cj_q21f cj_q21g cj_q21h cj_q21i cj_q21j cj_q21k 
cj_q37a cj_q37b cj_q37c cj_q37d 
{ ;
	list `v' if `v'==99 & `v'!=. ;
} ;
# delimit cr	

	
sum cj_*	

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

save "$path2data\1. Original\cj_final.dta", replace
erase "$path2data\1. Original\cj_final_long.dta"


