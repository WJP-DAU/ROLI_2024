/*=================================================================================================================
Project:		QRQ LONG
Routine:		QRQ Data Cleaning and Harmonization 2024 (master do file) - long
Author(s):		Natalia Rodriguez (nrodriguez@worldjusticeproject.org)
Dependencies:  	World Justice Project
Creation Date:	April, 2024

Description:
Master dofile for the cleaning and analyzing the QRQ LONG data for the Global Index. 

=================================================================================================================*/


clear
cls

/*=================================================================================================================
					Pre-settings
=================================================================================================================*/

*--- Stata Version
version 15

*--- Required packages:
* NONE

*--- Defining paths to SharePoint & your local Git Repo copy:

*------ (a) Natalia Rodriguez:
if (inlist("`c(username)'", "nrodriguez")) {
	global path2SP "C:\Users\nrodriguez\OneDrive - World Justice Project\Programmatic\Data Analytics\7. WJP ROLI\ROLI_2024\1. Cleaning\QRQ"
	global path2GH "C:\Users\nrodriguez\OneDrive - World Justice Project\Natalia\GitHub\ROLI_2024\1. Cleaning\QRQ"
}

*------ (b) Alex Ponce:
else if (inlist("`c(username)'", "")) {
	global path2SP ""
	global path2GH ""
}

*--- Defining path to Data and DoFiles:

**Path2data: Path to original exports from Alchemer by QRQ team. 
global path2data "${path2SP}\1. Data"

**Path2exp: Path to folder with final datasets (QRQ.dta and qrq_country_averages.dta". 

**Path 2dos: Path to do-files (Routines). 
global path2dos  "${path2GH}\2. Code"

/*=================================================================================================================
					I. Cleaning the data
=================================================================================================================*/

/*-----------*/
/* 1. Civil  */
/*-----------*/

cls
do "${path2dos}/Routines/data_import_cc_long.do"

/*--------------*/
/* 2. Criminal  */
/*--------------*/

cls
do "${path2dos}/Routines/data_import_cj_long.do"

/*-----------*/
/* 3. Labor  */
/*-----------*/

cls
do "${path2dos}/Routines/data_import_lb_long.do"

/*------------------*/
/* 4. Public Health */
/*------------------*/

cls
do "${path2dos}/Routines/data_import_ph_long.do"


/*=================================================================================================================
					II. Appending the data
=================================================================================================================*/

clear
use "$path2data\1. Original\cc_final_long_2023.dta"
append using "$path2data\1. Original\cj_final_long_2023.dta"
append using "$path2data\1. Original\lb_final_long_2023.dta"
append using "$path2data\1. Original\ph_final_long_2023.dta"

save "$path2data\1. Original\qrq_long_2023.dta", replace


/*=================================================================================================================
					III. Re-scaling the data
=================================================================================================================*/

do "${path2dos}/Routines/normalization.do"


/*=================================================================================================================
					IV. Creating variables common in various questionnaires
=================================================================================================================*/

do "${path2dos}/Routines/common_q.do"

sort country question id_alex

save "$path2data\1. Original\qrq_long_2023.dta", replace


/*=================================================================================================================
					V. Checks
=================================================================================================================*/

**            **
/* 1.Averages */
**            **

egen total_score=rowmean(cc_q1_norm- ph_q14_norm)
drop if total_score==.


**              **
/* 2.Duplicates */
**              **

sort WJP_login
egen total_n=rownonmiss(cc_q1_norm- ph_q14_norm)

// Duplicates by login (can show duplicates for years and surveys. Ex: An expert that answered three qrq's one year)
duplicates tag WJP_login, generate (dup)
tab dup
br if dup>0

// Duplicates by login and score (shows duplicates of year and expert, that SHOULD be removed)
duplicates tag WJP_login total_score, generate(true_dup)
tab true_dup
br if true_dup>0

// Duplicates by id and year (Doesn't show the country)
duplicates tag id_alex, generate (dup_alex)
tab dup_alex
br if dup_alex>0

//Duplicates by id, year and score (Should be removed)
duplicates tag id_alex total_score, generate(true_dup_alex)
tab true_dup_alex
br if true_dup_alex>0

//Duplicates by login and questionnaire. They should be removed, as this is a long dataset.
duplicates tag question WJP_login, generate(true_dup_question)
tab true_dup_question
br if true_dup_question>0

drop dup true_dup dup_alex true_dup_alex true_dup_question


**                                                   **
/* 3. Drop questionnaires with very few observations */
**                                                   **

*Total number of experts by country
bysort country: gen N=_N

*Drops surveys with less than 25 nonmissing values. Erin cleaned empty suveys and surveys with low responses
*There are countries with low total_n because we removed the DN/NA at the beginning of the do file
br if total_n<=25
drop if total_n<=25 & N>=20

/* 4.Outliers */
bysort country: egen total_score_mean=mean(total_score)
bysort country: egen total_score_sd=sd(total_score)

gen outlier=0

*Added a new part that takes into account the sd. It was marking as outliers countries with only one expert (as the sd is missing)
replace outlier=1 if total_score>=(total_score_mean+2.5*total_score_sd) & total_score~=. & total_score_sd!=.
replace outlier=1 if total_score<=(total_score_mean-2.5*total_score_sd) & total_score~=. & total_score_sd!=.
bysort country: egen outlier_CO=max(outlier)

*Shows the number of experts of low count countries have and if the country has outliers
tab country outlier_CO if N<=20

*Shows the number of outlies per each low count country
tab country outlier if N<=20

drop if outlier==1 & N>20

sort country id_alex


**                  **
/* 4. Factor scores */
**                  **

do "${path2dos}/Routines/scores.do"

save "$path2data\1. Original\qrq_long_2023.dta", replace


/*=================================================================================================================
					VI. Checking that the 2023 and the 2024 data have the same observations
=================================================================================================================*/


/* We do all the merges with the type of questionnaire too because there are some experts that responded more than one questionnaire, but one of them was removed
When we do the merge, it wrongly keeps the questionnaire droppped from 2024, as it has not been droppped in the 2023 long
*/

*Save loggins from 2023

use "$path2data\1. Original\qrq_long_2023.dta", clear
keep WJP_password question
sort WJP_password
save "$path2data\1. Original\qrq_login_long_2023.dta", replace

/* Open this year's dataset (2024) and merge the loggings from 2023. We are keeping only the ones that matched. 
- There could be ones that didn't match because we deleted them from the 2024 dataset (outliers) and from older years.
- With this, we will keep the longitudinal experts from 2024 that are valid (that haven't been removed in 2024). 
- 2023 login long has all the 2023 qrq long experts. It will be removing the regular from 2024 and from previous years */

use "$path2data\1. Original\qrq.dta", clear
sort WJP_password
merge m:m WJP_password question using "$path2data\1. Original\qrq_login_long_2023.dta"
keep if _merge==3
drop _merge

*Check the year of the data -  it must be the latest year (2024)
tab year
count

save "$path2data\1. Original\qrq_long_2024.dta", replace

keep WJP_password question
sort WJP_password
save "$path2data\1. Original\qrq_login_long_2024.dta", replace

*Open the 2023 and merge the loggings that match from 2024.

use "$path2data\1. Original\qrq_long_2023.dta", clear
sort WJP_password
merge m:m WJP_password question using "$path2data\1. Original\qrq_login_long_2024.dta"
keep if _merge==3
drop _merge

save "$path2data\1. Original\qrq_long_2023.dta", replace

count
erase "$path2data\1. Original\qrq_login_long_2023.dta"
erase "$path2data\1. Original\qrq_login_long_2024.dta"

/*=================================================================================================================
					VII. Country Agerages
=================================================================================================================*/

/*-------------------------*/
/* Country Averages (2023) */
/*-------------------------*/

use "$path2data\1. Original\qrq_long_2023.dta", clear

foreach var of varlist cc_q1_norm- all_q105_norm {
	bysort country: egen CO_`var'=mean(`var')
}

egen tag = tag(country)
keep if tag==1
drop cc_q1- all_q105_norm 

rename CO_* *

drop tag
drop WJP_login WJP_password id_alex question- f_8 ROLI

sort country

/* Adding the new countries to the dataset (right now, they are missing observations) (Only for 2023) */

// NONE FOR THIS YEAR - WE ARE NOT ADDING NEW COUNTRIES

sort country

*Creating ROLI scores with only QRQ data
do "${path2dos}/Routines/scores.do"

keep country f_1 f_1_2 f_1_3 f_1_4 f_1_5 f_1_6 f_1_7 ///
f_2 f_2_1 f_2_2 f_2_3 f_2_4 ///
f_3 f_3_1 f_3_2 f_3_3 f_3_4 ///
f_4 f_4_1 f_4_2 f_4_3 f_4_4 f_4_5 f_4_6 f_4_7 f_4_8 ///
f_5 f_5_3 ///
f_6 f_6_1 f_6_2 f_6_3 f_6_4 f_6_5 ///
f_7 f_7_1 f_7_2 f_7_3  f_7_4 f_7_5 f_7_6 f_7_7 ///
f_8 f_8_1 f_8_2 f_8_3 f_8_4 f_8_5 f_8_6 f_8_7 ///
f_1 f_2 f_3 f_4 f_5 f_6 f_7 f_8 ROL 

*Renaming 2024 scores
foreach v in f_1_2 f_1_3 f_1_4 f_1_5 f_1_6 f_1_7 f_2_1 f_2_2 f_2_3 f_2_4 f_3_1 f_3_2 f_3_3 f_3_4 f_4_1 f_4_2 f_4_3 f_4_4 f_4_5 f_4_6 f_4_7 f_4_8 f_5_3 f_6_1 f_6_2 f_6_3 f_6_4 f_6_5 f_7_1 f_7_2 f_7_3 f_7_4 f_7_5 f_7_6 f_7_7 f_8_1 f_8_2 f_8_3 f_8_4 f_8_5 f_8_6 f_8_7 f_1 f_2 f_3 f_4 f_5 f_6 f_7 f_8 ROLI {
	rename `v' `v'_2023
}

save "$path2data\3. Final\qrq_long_2023_country_averages.dta", replace


/*-------------------------*/
/* Country Averages (2024) */
/*-------------------------*/

use "$path2data\1. Original\qrq_long_2024.dta", clear

foreach var of varlist cc_q1_norm- all_q105_norm {
	bysort country: egen CO_`var'=mean(`var')
}

egen tag = tag(country)
keep if tag==1
drop cc_q1- all_q105_norm 

rename CO_* *
drop tag

drop question-language
*drop WJP_login WJP_password cc_q6a_usd cc_q6a_gni
*drop WJP_login WJP_password 
*drop total_score-total_score_mean

sort country

/* Adding the new countries to the dataset (right now, they are missing observations) (Only for 2024) */

// NONE FOR THIS YEAR - WE ARE NOT ADDING NEW COUNTRIES

sort country

*Creating ROLI scores with only QRQ data
do "${path2dos}/Routines/scores.do"

keep country f_1 f_1_2 f_1_3 f_1_4 f_1_5 f_1_6 f_1_7 ///
f_2 f_2_1 f_2_2 f_2_3 f_2_4 ///
f_3 f_3_1 f_3_2 f_3_3 f_3_4 ///
f_4 f_4_1 f_4_2 f_4_3 f_4_4 f_4_5 f_4_6 f_4_7 f_4_8 ///
f_5 f_5_3 ///
f_6 f_6_1 f_6_2 f_6_3 f_6_4 f_6_5 ///
f_7 f_7_1 f_7_2 f_7_3  f_7_4 f_7_5 f_7_6 f_7_7 ///
f_8 f_8_1 f_8_2 f_8_3 f_8_4 f_8_5 f_8_6 f_8_7 ///
f_1 f_2 f_3 f_4 f_5 f_6 f_7 f_8 ROL 

*Renaming 2024 scores
foreach v in f_1_2 f_1_3 f_1_4 f_1_5 f_1_6 f_1_7 f_2_1 f_2_2 f_2_3 f_2_4 f_3_1 f_3_2 f_3_3 f_3_4 f_4_1 f_4_2 f_4_3 f_4_4 f_4_5 f_4_6 f_4_7 f_4_8 f_5_3 f_6_1 f_6_2 f_6_3 f_6_4 f_6_5 f_7_1 f_7_2 f_7_3 f_7_4 f_7_5 f_7_6 f_7_7 f_8_1 f_8_2 f_8_3 f_8_4 f_8_5 f_8_6 f_8_7 f_1 f_2 f_3 f_4 f_5 f_6 f_7 f_8 ROLI {
	rename `v' `v'_2024
}

save "$path2data\3. Final\qrq_long_2024_country_averages.dta", replace


/*=================================================================================================================
					VIII. Number of longitudinal questionnaires
=================================================================================================================*/

use "$path2data\1. Original\qrq_long_2023.dta", clear

count

gen aux1=1 if question=="cc"
gen aux2=1 if question=="cj"
gen aux3=1 if question=="lb"
gen aux4=1 if question=="ph"

bysort country: egen cc_total=total(aux1)
bysort country: egen cj_total=total(aux2)
bysort country: egen lb_total=total(aux3)
bysort country: egen ph_total=total(aux4)
egen tag = tag(country)

sort country
*br country cc_total cj_total lb_total ph_total if tag==1


/*=================================================================================================================
					IX. Changes over time (LONG)
=================================================================================================================*/

use "$path2data\3. Final\qrq_long_2024_country_averages.dta", replace

*Merging 2023 scores

merge 1:1 country using "$path2data\3. Final\qrq_long_2023_country_averages.dta"
drop _merge

*Calculating changes over time
foreach v in f_1_2 f_1_3 f_1_4 f_1_5 f_1_6 f_1_7 f_2_1 f_2_2 f_2_3 f_2_4 f_3_1 f_3_2 f_3_3 f_3_4 f_4_1 f_4_2 f_4_3 f_4_4 f_4_5 f_4_6 f_4_7 f_4_8 f_5_3 f_6_1 f_6_2 f_6_3 f_6_4 f_6_5 f_7_1 f_7_2 f_7_3 f_7_4 f_7_5 f_7_6 f_7_7 f_8_1 f_8_2 f_8_3 f_8_4 f_8_5 f_8_6 f_8_7 f_1 f_2 f_3 f_4 f_5 f_6 f_7 f_8 ROLI {
	g double dif_`v'=(`v'_2024-`v'_2023)
	g double growth_`v'=(`v'_2024-`v'_2023)/`v'_2023
}

keep country dif_* growth_*

save "$path2data\3. Final\qrq_long_changes_over_time.dta", replace



























