/*=================================================================================================================
Project:		QRQ 2024
Routine:		QRQ Data Cleaning and Harmonization 2024 (master do file)
Author(s):		Natalia Rodriguez (nrodriguez@worldjusticeproject.org)
Dependencies:  	World Justice Project
Creation Date:	February, 2025

Description:
Master dofile for the cleaning and analyzing the QRQ data for the Global Index. 
This do file takes the calculations from 2024 and develops new calculations for experts (outliers)

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
	
	*global path2data "C:\Users\nrodriguez\OneDrive - World Justice Project\Programmatic\QRQ\QRQ 2024\Final Data\excel"
	*global path2exp  "C:\Users\nrodriguez\OneDrive - World Justice Project\Programmatic\Index Data & Analysis\2024\QRQ"
	*global path2dos  "C:\Users\nrodriguez\OneDrive - World Justice Project\Programmatic\QRQ do files\2024"
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
do "${path2dos}/Routines/data_import_cc.do"

/*--------------*/
/* 2. Criminal  */
/*--------------*/

cls
do "${path2dos}/Routines/data_import_cj.do"

/*-----------*/
/* 3. Labor  */
/*-----------*/

cls
do "${path2dos}/Routines/data_import_lb.do"

/*------------------*/
/* 4. Public Health */
/*------------------*/

cls
do "${path2dos}/Routines/data_import_ph.do"


/*=================================================================================================================
					II. Appending the data
=================================================================================================================*/

clear
use "${path2data}\1. Original\cc_final.dta"
append using "${path2data}\1. Original\cj_final.dta"
append using "${path2data}\1. Original\lb_final.dta"
append using "${path2data}\1. Original\ph_final.dta"

save "${path2data}\1. Original\qrq.dta", replace


/*=================================================================================================================
					III. Re-scaling the data
=================================================================================================================*/

do "${path2dos}/Routines/normalization.do"


/*=================================================================================================================
					IV. Creating variables common in various questionnaires
=================================================================================================================*/

do "${path2dos}/Routines/common_q.do"

sort country question id_alex

save "$path2data\1. Original\qrq.dta", replace


/*=================================================================================================================
					V. Merging with 2023 data and previous years
=================================================================================================================*/

/* Responded in 2023 */
clear
use "$path2data\1. Original\qrq_original_2023.dta"
keep WJP_password
duplicates drop
sort WJP_password
save "$path2data\1. Original\qrq_2023_login.dta", replace


/* Responded longitudinal survey in 2024 */ 
clear
use "$path2data\1. Original\qrq.dta"
keep WJP_password
duplicates drop
sort WJP_password
save "$path2data\1. Original\qrq_login.dta", replace 


/* Only answered in 2023 (and not in 2024) (Login) */
clear
use "$path2data\1. Original\qrq_2023_login.dta"
merge 1:1 WJP_password using "$path2data\1. Original\qrq_login.dta"
keep if _merge==1
drop _merge
sort WJP_password
save "$path2data\1. Original\qrq_2023_login_unique.dta", replace 


/* Only answered in 2023 (and not in 2024) (Full data) */
clear
use "$path2data\1. Original\qrq_original_2023.dta"
sort WJP_password
merge m:1 WJP_password using "$path2data\1. Original\qrq_2023_login_unique.dta"

replace _merge=3 if id_alex=="lb_English_1_28_2021_2022" // LB Gambia expert that answered CC in 2023 but not LB (old LB answer from 2021) DO NOT DELETE NEXT YEAR!!!!!!!!!!!!!!!!!!!!!!!!!!! CHECK IT!!!!!!
replace _merge=3 if id_alex=="lb_English_0_587_2022" //LB Grenada that switched disciplines over years and are long CCs. DO NOT DELETE NEXT YEAR!!!!!!!!
replace _merge=3 if id_alex=="lb_English_0_638"  //LB Grenada that switched disciplines over years and are long CJs. DO NOT DELETE NEXT YEAR!!!!!!!! 
replace _merge=3 if id_alex=="lb_French_0_724_2021_2022" //LB Guinea old, CC long 2024. DO NOT DELETE
replace _merge=3 if id_alex=="lb_French_0_486" //LB Guinea old, CJ long 2024. DO NOT DELETE
replace _merge=3 if id_alex=="lb_French_1_470" //LB Guinea old, CJ AND CJ long 2024. DO NOT DELETE

keep if _merge==3
drop _merge
gen aux="2023"
egen id_alex_1=concat(id_alex aux), punct(_)
replace id_alex=id_alex_1
drop id_alex_1 aux
sort WJP_password
save "$path2data\1. Original\qrq_2023.dta", replace

erase "$path2data\1. Original\qrq_2023_login.dta"
erase "$path2data\1. Original\qrq_login.dta"
erase "$path2data\1. Original\qrq_2023_login_unique.dta"


/* Merging with 2023 data and older regular data*/
clear
use "$path2data\1. Original\qrq.dta"
append using "$path2data\1. Original\qrq_2023.dta"

*Dropping total scores from previous years
drop total_score total_n f_1* f_2* f_3* f_4* f_6* f_7* f_8* N total_score_mean total_score_sd outlier outlier_CO

*Observations are no longer longitudinal because the database we're appending only includes people that only answered in 2023 or before
tab year longitudinal
replace longitudinal=0 if year==2023
tab year longitudinal


/* Change names of countries according to new MAP (for the 2023 and older data) */

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


/* Merging with Cost of Lawyers 2024 clean data for new countries */

drop cc_q6a_usd cc_q6a_gni

 /*
sort id_alex

merge 1:1 id_alex using "cost of lawyers_2024.dta"
tab _merge
drop if _merge==2
drop _merge 
save qrq.dta, replace
*/


/*=================================================================================================================
					VI. Checks
=================================================================================================================*/


********************************************************
				  /* 1.Averages */
********************************************************

egen total_score=rowmean(cc_q1_norm- ph_q14_norm)
drop if total_score==.


********************************************************
				  /* 2.Duplicates */
********************************************************

sort country question year

*------ Duplicates by login (can show duplicates for years and surveys. Ex: An expert that answered three qrq's one year)
duplicates tag WJP_login, generate(dup)
tab dup
br if dup>0


*------ Duplicates by login and score (shows duplicates of year and expert, that SHOULD be removed)
duplicates tag WJP_login total_score, generate(true_dup)
tab true_dup
br if true_dup>0


*------ Duplicates by id and year (Doesn't show the country)
duplicates tag id_alex, generate (dup_alex)
tab dup_alex
br if dup_alex>0


*------ Duplicates by id, year and score (Should be removed)
duplicates tag id_alex total_score, generate(true_dup_alex)
tab true_dup_alex
br if true_dup_alex>0


*------ Duplicates by login and questionnaire. Helps identify duplicate old experts without password. Should be removed if the country and question are the same
duplicates tag question WJP_login, generate(true_dup_question)
tab true_dup_question
br if true_dup_question>0


*------ Duplicates by login, questionnaire and year. They should be removed if the country and year are the same.
duplicates tag question WJP_login year, generate(true_dup_question_year)
tab true_dup_question_year
br if true_dup_question_year>0


*------ Check which years don't have a password
tab year if WJP_password!=.
tab year if WJP_password==.


*------ Duplicates by password and questionnaire. Some experts have changed their emails and our check with id_alex doesn't catch them. 
duplicates tag question country WJP_password, gen(dup_password)

br if dup_password>0 & WJP_password!=.
tab dup_password if WJP_password!=.

*Check the year and keep the most recent one
tab year if dup_password>0 & WJP_password!=.

bys question country WJP_password: egen year_max=max(year) if dup_password>0 & dup_password!=. & WJP_password!=.
gen dup_mark=1 if year!=year_max & dup_password>0 & dup_password!=. & WJP_password!=.
drop if dup_mark==1

drop dup_password year_max dup_mark

tab year


*------ Duplicates by login (lowercases) and questionnaire. 
/*This check drops experts that have emails with uppercases and are included 
from two different years of the same questionnaire and country (consecutive years). We should remove the 
old responses that we are including as "regular" that we think are regular because of the 
upper and lower cases. */

gen WJP_login_lower=ustrlower(WJP_login)
duplicates tag question country WJP_login_lower , generate(true_dup_question_lower)
tab true_dup_question_lower

sort country question WJP_login_lower year
br if true_dup_question_lower>0

bys country question WJP_login_lower: egen year_max=max(year) if true_dup_question_lower>0
gen dup_mark=1 if year!=year_max & true_dup_question_lower>0 & WJP_password==.

drop if dup_mark==1

*Test it again
drop true_dup_question_lower
duplicates tag question country WJP_login_lower , generate(true_dup_question_lower)
tab true_dup_question_lower

sort country question WJP_login_lower year
br if true_dup_question_lower>0

drop dup true_dup dup_alex true_dup_alex true_dup_question true_dup_question_year WJP_login_lower year_max dup_mark true_dup_question_lower


********************************************************
/* 3. Drop questionnaires with very few observations */
********************************************************

egen total_n=rownonmiss(cc_q1_norm- ph_q14_norm)

*Total number of experts by country
bysort country: gen N=_N

*Total number of experts by country and discipline
bysort country question: gen N_questionnaire=_N


*Number of questions per QRQ
*CC: 162
*CJ: 197
*LB: 134
*PH: 49

*Drops surveys with less than 25 nonmissing values. Erin cleaned empty suveys and surveys with low responses
*There are countries with low total_n because we removed the DN/NA at the beginning of the do file
br if total_n<=25
drop if total_n<=25 & N>=20


********************************************************
				 /* 4. Factor scores */
********************************************************

qui do "${path2dos}/Routines/scores.do"


********************************************************
		/* 5. Dropping the tail / old experts */
********************************************************

sort country question year total_score

*Counting the number of experts per discipline
foreach x in cc cj lb ph {
gen count_`x'=1 if question=="`x'"
}

*Creating total counts by country per discipline
foreach x in cc cj lb ph {
bys country: egen `x'_total=total(count_`x')
}

*Counting the number of experts per discipline and year (if they are in the tail)
foreach x in cc cj lb ph {
gen tail_`x'=1 if count_`x'==1 & year<2022
}

foreach x in cc cj lb ph {
bys country: egen `x'_total_tail=total(tail_`x')
}

*Counting the number of NEW experts (2022-2024)
foreach x in cc cj lb ph {
gen new_`x'=1 if count_`x'==1 & year>=2022
}

foreach x in cc cj lb ph {
bys country: egen `x'_total_new=total(new_`x')
}

*Creating percentages for the tail
foreach x in cc cj lb ph {
gen percentage_tail_`x'=`x'_total_tail/`x'_total
}


*Drop the tail per discipline (% of the tail is small (less or equal than 50%))
tab country if cc_total_new>=15
tab country if cj_total_new>=15
tab country if lb_total_new>=15
tab country if ph_total_new>=15

drop if tail_cc==1 & cc_total_new>=15
drop if tail_cj==1 & cj_total_new>=15
drop if tail_lb==1 & lb_total_new>=15
drop if tail_ph==1 & ph_total_new>=15


drop N N_questionnaire

********************************************************
				 /* 6. Outliers */
********************************************************

*Total number of experts by country
bysort country: gen N=_N

*Total number of experts by country and discipline
bysort country question: gen N_questionnaire=_N


qui do "${path2dos}\Routines\outliers.do"


*----- Aggregate Scores - NO DELETIONS (scenario 1)

preserve

collapse (mean) cc_q1_norm- all_q105_norm, by(country)

do "${path2dos}\Routines\scores.do"

save "$path2data\2. Scenarios\qrq_country_averages_s1.dta", replace

restore


*----- Aggregate Scores - Removing general outliers (scenario 2)

preserve

*Dropping general outliers
drop if outlier==1 & N>20 & N_questionnaire>5

collapse (mean) cc_q1_norm- all_q105_norm, by(country)

do "${path2dos}\Routines\scores.do"

save "$path2data\2. Scenarios\qrq_country_averages_s2.dta", replace

restore


*----- Aggregate Scores - Removing sub-factor outliers + general outliers (scenario 3)

*preserve

*Dropping general outliers
drop if outlier==1 & N>20 & N_questionnaire>5

*Dropping questions in sub-factor for experts that are outliers in that indicator
do "${path2dos}\Routines\subfactor_questions.do"

/*
#delimit ;
foreach v in 
f_1_2 f_1_3 f_1_4 f_1_5 f_1_6 f_1_7 
f_2_1 f_2_2 f_2_3 f_2_4
f_3_1 f_3_2 f_3_3 f_3_4
f_4_1 f_4_2 f_4_3 f_4_4 f_4_5 f_4_6 f_4_7 f_4_8
f_5_3
f_6_1 f_6_2 f_6_3 f_6_4 f_6_5
f_7_1 f_7_2 f_7_3  f_7_4 f_7_5 f_7_6 f_7_7
f_8_1 f_8_2 f_8_3 f_8_4 f_8_5 f_8_6 f_8_7
f_1 f_2 f_3 f_4 f_5 f_6 f_7 f_8 
{;
	foreach x of global ``v'' { ;
		replace ``x''=. if outlier_`v'==1 ;	
};
};
#delimit cr
*/

foreach v in f_1_2 f_1_3 f_1_4 f_1_5 f_1_6 f_1_7 f_2_1 f_2_2 f_2_3 f_2_4 f_3_1 f_3_2 f_3_3 f_3_4 f_4_1 f_4_2 f_4_3 f_4_4 f_4_5 f_4_6 f_4_7 f_4_8 f_5_3 f_6_1 f_6_2 f_6_3 f_6_4 f_6_5 f_7_1 f_7_2 f_7_3 f_7_4 f_7_5 f_7_6 f_7_7 f_8_1 f_8_2 f_8_3 f_8_4 f_8_5 f_8_6 f_8_7 {
	foreach x of global "`v'" {
		replace ``x''=. if outlier_`v'==1 
}
}



collapse (mean) cc_q1_norm- all_q105_norm, by(country)

do "${path2dos}\Routines\scores.do"

save "$path2data\2. Scenarios\qrq_country_averages_s3.dta", replace

restore





/*=================================================================================================================
					VII. Adjustments
=================================================================================================================*/

sort country question year total_score

/*
*Afghanistan
drop if id_alex=="cc_English_1_1104" //Afghanistan
drop if id_alex=="cj_English_1_136" //Afghanistan
drop if id_alex=="lb_English_0_26" //Afghanistan
replace cc_q28e_norm=. if country=="Afghanistan" //Afghanistan
replace lb_q6c_norm=. if country=="Afghanistan" //Afghanistan
replace all_q87_norm=. if country=="Afghanistan" //Afghanistan
replace all_q84_norm=. if country=="Afghanistan" //Afghanistan
replace all_q89_norm=. if all_q89_norm==1 & country=="Afghanistan" //Afghanistan
replace all_q59_norm=. if id_alex=="lb_English_0_26" //Afghanistan
replace cc_q39a_norm=. if id_alex=="cc_Arabic_0_864" //Afghanistan - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39b_norm=. if id_alex=="cc_Arabic_0_864" //Afghanistan - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39c_norm=. if id_alex=="cc_Arabic_0_864" //Afghanistan - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39d_norm=. if id_alex=="cc_Arabic_0_864" //Afghanistan - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39e_norm=. if id_alex=="cc_Arabic_0_864" //Afghanistan - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q40_norm=. if id_alex=="cc_Arabic_0_864" //Afghanistan - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q41_norm=. if id_alex=="cc_Arabic_0_864" //Afghanistan - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q42_norm=. if id_alex=="cc_Arabic_0_864" //Afghanistan - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q43_norm=. if id_alex=="cc_Arabic_0_864" //Afghanistan - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q44_norm=. if id_alex=="cc_Arabic_0_864" //Afghanistan - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q45_norm=. if id_alex=="cc_Arabic_0_864" //Afghanistan - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q46_norm=. if id_alex=="cc_Arabic_0_864" //Afghanistan - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q47_norm=. if id_alex=="cc_Arabic_0_864" //Afghanistan - reduzco el cambio negativo en la pregunta  - 3.2 //
replace lb_q16b_norm=0 if id_alex=="lb_English_0_398_2017_2018_2019_2021_2022_2023" //Afghanistan - reduzco el cambio positivo en la pregunta  - 4.1 //
replace lb_q16b_norm=0 if id_alex=="lb_English_1_403_2022_2023" //Afghanistan - reduzco el cambio positivo en la pregunta  - 4.1 //
replace cj_q11b_norm=0 if id_alex=="cj_English_0_227_2017_2018_2019_2021_2022_2023" //Afghanistan - reduzco el cambio positivo en la pregunta  - 4.2 //
replace cj_q31e_norm=0 if id_alex=="cj_English_0_225_2021_2022_2023" //Afghanistan - reduzco el cambio positivo en la pregunta  - 4.2 //
replace all_q29_norm=. if id_alex=="cc_English_1_999" //Afghanistan - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cc_English_1_999" //Afghanistan - reduzco el cambio positivo en la pregunta  - 4.5 //
replace lb_q2d_norm=. if id_alex=="lb_English_1_168" //Afghanistan - el nivel es muy alto y va en contra de long  - 6.3 //
replace lb_q3d_norm=. if id_alex=="lb_English_1_168" //Afghanistan - el nivel es muy alto y va en contra de long  - 6.3 //
replace lb_q3d_norm=. if id_alex=="lb_English_0_398_2017_2018_2019_2021_2022_2023" //Afghanistan - el nivel es muy alto y va en contra de long  - 6.3 //
replace cc_q26b_norm=. if id_alex=="cc_English_1_999" //Afghanistan - el nivel es muy alto y va en contra de long  - 7.6 //
replace cc_q26b_norm=. if id_alex=="cc_English_1_202_2017_2018_2019_2021_2022_2023" //Afghanistan - el nivel es muy alto y va en contra de long  - 7.6 //
replace all_q86_norm=.5 if id_alex=="lb_English_1_532_2016_2017_2018_2019_2021_2022_2023" //Afghanistan - el nivel es muy alto y va en contra de long  - 7.6 //
replace all_q86_norm=.5 if id_alex=="lb_English_0_398_2017_2018_2019_2021_2022_2023" //Afghanistan - el nivel es muy alto y va en contra de long  - 7.6 //
replace all_q90_norm=. if id_alex=="lb_English_1_501_2023" //Afghanistan - el nivel es muy alto y va en contra de long  - 7.7 //
replace all_q90_norm=. if id_alex=="lb_English_1_108" //Afghanistan - el nivel es muy alto y va en contra de long  - 7.7 //
replace all_q91_norm=. if id_alex=="lb_English_0_398_2017_2018_2019_2021_2022_2023" //Afghanistan - el nivel es muy alto y va en contra de long  - 7.7 //
replace cj_q20o_norm=. if id_alex=="cj_English_0_185_2023" //Afghanistan - reduzco el cambio negativo en la pregunta  - 8.4 //
replace cj_q20o_norm=. if id_alex=="cj_English_1_893_2023" //Afghanistan - reduzco el cambio negativo en la pregunta  - 8.4 //
replace cj_q20m_norm=. if id_alex=="cj_English_0_1017_2018_2019_2021_2022_2023" //Afghanistan - Va en contra de long  - 8.6 //
replace cj_q20m_norm=. if id_alex=="cj_English_0_767_2019_2021_2022_2023" //Afghanistan - Va en contra de long  - 8.6 //

*Albania
drop if id_alex=="lb_English_1_73" //Albania
drop if id_alex=="lb_English_1_71" //Albania
drop if id_alex=="cj_English_1_672" //Albania
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="lb_English_0_566_2016_2017_2018_2019_2021_2022_2023" //Albania: Dropping 0s. Outlier in all questions
	}
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="cc_English_0_272_2023" //Albania: Dropping 0s. Outlier in all questions
	}

replace cj_q36c_norm=. if id_alex=="cj_English_0_516" //Albania - reduzco el cambio positivo en la pregunta  - 1.4 //
replace cj_q8_norm=. if id_alex=="cj_English_0_516" //Albania - reduzco el cambio positivo en la pregunta  - 1.4 //	
replace cc_q33_norm=. if id_alex=="cc_English_1_403_2022_2023" //Albania - reduzco el cambio positivo en la pregunta  - 1.4 //	
replace all_q9_norm=. if id_alex=="lb_English_0_70_2023" //Albania - reduzco el cambio positivo en la pregunta  - 1.4 //	
replace cc_q9c_norm=. if id_alex=="cc_English_1_165_2022_2023" //Albania - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cc_q40a_norm=. if id_alex=="cc_English_1_165_2022_2023" //Albania - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cc_q40b_norm=. if id_alex=="cc_English_1_165_2022_2023" //Albania - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cc_q26a_norm=. if id_alex=="cc_English_0_824_2022_2023" //Albania - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q26a_norm=. if id_alex=="cc_English_1_933_2022_2023" //Albania - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q26a_norm=. if id_alex=="cc_English_0_272_2023" //Albania - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q26a_norm=. if id_alex=="cc_English_0_309_2023" //Albania - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="cc_English_0_272_2023" //Albania - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="cc_English_0_309_2023" //Albania - reduzco el cambio negativo en la pregunta  - 7.5 //
	
*Algeria
replace all_q87_norm=. if country=="Algeria" //Algeria
drop if id_alex=="cj_French_0_1083" //Algeria
drop if id_alex=="cj_Arabic_0_1271" //Algeria
drop if id_alex=="lb_Arabic_0_598"  //Algeria
drop if id_alex=="ph_French_0_162_2021_2022_2023"  //Algeria
drop if id_alex=="ph_French_1_540_2023"  //Algeria
drop if id_alex=="ph_French_0_454_2023"  //Algeria
drop if id_alex=="ph_French_0_729_2021_2022_2023"  //Algeria
drop if id_alex=="ph_French_0_583_2021_2022_2023"  //Algeria
drop if id_alex=="cj_Arabic_0_1366" //Algeria
drop if id_alex=="cj_French_0_1094" //Algeria
drop if id_alex=="ph_French_0_401_2018_2019_2021_2022_2023" //Algeria
replace cj_q8_norm=. if country=="Algeria" //Algeria
replace all_q53_norm=. if country=="Algeria" //Algeria
foreach v in cj_q40b_norm cj_q40c_norm {
	replace `v'=. if `v'==1 & country=="Algeria" //Algeria
}
foreach v in cc_q39b_norm cc_q39d_norm cc_q39e_norm {
	replace `v'=. if id_alex=="cc_Arabic_0_1999" //Algeria
}
replace all_q44_norm=. if country=="Algeria" //Algeria
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="cc_English_0_915_2019_2021_2022_2023" //Algeria: Dropping 0s. Outlier in all questions
	}
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="cc_French_1_1402_2022_2023" //Algeria: Dropping 0s. Outlier in all questions
	}
replace lb_q19a_norm=. if lb_q19a_norm==1 & country=="Algeria" //Algeria
replace cj_q31b_norm=. if cj_q31b_norm==. & country=="Algeria" //Algeria
replace cj_q34c_norm=. if cj_q34c_norm==1 & country=="Algeria" //Algeria
replace cj_q33c_norm=. if cj_q33c_norm==1 & country=="Algeria" //Algeria
replace cj_q11b_norm=. if country=="Algeria" //Algeria
foreach v in all_q76_norm all_q77_norm all_q78_norm all_q79_norm all_q80_norm all_q81_norm {
	replace `v'=. if id_alex=="cc_French_0_1718" //Algeria
}
replace all_q6_norm=. if id_alex=="cc_French_0_2008" //Algeria
drop if id_alex=="cj_French_0_318_2022_2023" //Algeria

replace cc_q9c_norm=. if id_alex=="cc_English_0_915_2019_2021_2022_2023" //Algeria - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cc_q14a_norm=. if id_alex=="cc_French_1_1568_2021_2022_2023" //Algeria - reduzco el cambio positivo en la pregunta  - 6.5 //
replace cc_q14b_norm=. if id_alex=="cc_French_1_1568_2021_2022_2023" //Algeria - reduzco el cambio positivo en la pregunta  - 6.5 //
replace cc_q16a_norm=. if id_alex=="cc_French_1_202_2021_2022_2023" //Algeria - reduzco el cambio positivo en la pregunta  - 6.5 //
replace cc_q16b_norm=. if id_alex=="cc_French_1_202_2021_2022_2023" //Algeria - reduzco el cambio positivo en la pregunta  - 6.5 //
replace cc_q16c_norm=. if id_alex=="cc_French_1_202_2021_2022_2023" //Algeria - reduzco el cambio positivo en la pregunta  - 6.5 //
replace cc_q16d_norm=. if id_alex=="cc_French_1_202_2021_2022_2023" //Algeria - reduzco el cambio positivo en la pregunta  - 6.5 //
replace cc_q16e_norm=. if id_alex=="cc_French_1_202_2021_2022_2023" //Algeria - reduzco el cambio positivo en la pregunta  - 6.5 //
replace cc_q16f_norm=. if id_alex=="cc_French_1_202_2021_2022_2023" //Algeria - reduzco el cambio positivo en la pregunta  - 6.5 //
replace all_q65_norm=. if id_alex=="cc_French_0_255_2018_2019_2021_2022_2023" //Algeria - reduzco el nivel de la pregunta (muy alto)  - 7.1 //
replace all_q65_norm=. if id_alex=="cc_English_0_915_2019_2021_2022_2023" //Algeria - reduzco el nivel de la pregunta (muy alto)  - 7.1 //
replace cc_q22c_norm=. if id_alex=="cc_French_0_255_2018_2019_2021_2022_2023" //Algeria - reduzco el nivel de la pregunta (muy alto)  - 7.1 //
replace all_q6_norm=. if id_alex=="lb_English_0_358" //Algeria - reduzco el cambio positivo en la pregunta  - 7.4 //
replace all_q3_norm=. if id_alex=="cj_French_0_1237" //Algeria - reduzco el cambio positivo en la pregunta  - 7.4 //
replace all_q4_norm=. if id_alex=="cj_French_0_1237" //Algeria - reduzco el cambio positivo en la pregunta  - 7.4 //
replace all_q7_norm=. if id_alex=="cj_French_0_1237" //Algeria - reduzco el cambio positivo en la pregunta  - 7.4 //
replace cj_q28_norm=. if id_alex=="cj_French_0_1315" //Algeria - reduzco el cambio positivo en la pregunta  - 8.3 //

*Angola
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="cc_Portuguese_0_457_2021_2022_2023" //Angola: Dropping 0s. Outlier in all questions
	}
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="cc_Portuguese_1_111" //Angola: Dropping 0s. Outlier in all questions
	}

drop if id_alex=="cc_Portuguese_1_292" //Angola (muy positivo)
replace all_q96_norm=. if id_alex=="cj_Portuguese_1_915" //Angola - reduzco el cambio positivo en la pregunta  - 2.4 //
replace cc_q40b_norm=. if id_alex=="cc_Portuguese_1_111" //Angola - reduzco el cambio negativo en la pregunta  - 3.4 //
replace lb_q23d_norm=. if id_alex=="lb_Portuguese_0_23" //Angola - reduzco el cambio positivo en la pregunta  - 4.8 //
replace lb_q23e_norm=. if id_alex=="lb_Portuguese_0_23" //Angola - reduzco el cambio positivo en la pregunta  - 4.8 //
replace lb_q16f_norm=. if id_alex=="lb_Portuguese_0_798_2021_2022_2023" //Angola - reduzco el cambio positivo en la pregunta  - 4.8 //
replace lb_q19a_norm=. if id_alex=="lb_Portuguese_0_798_2021_2022_2023" //Angola - reduzco el cambio positivo en la pregunta  - 6.4 //
replace cc_q10_norm=. if id_alex=="cc_Portuguese_0_1262" //Angola - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q11a_norm=. if id_alex=="cc_Portuguese_0_1262" //Angola - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q16c_norm=. if id_alex=="cc_Portuguese_0_735_2019_2021_2022_2023" //Angola - reduzco el cambio negativo en la pregunta  - 6.5 //
foreach v in all_q76_norm all_q77_norm all_q78_norm all_q79_norm all_q80_norm all_q81_norm {
	replace `v'=. if id_alex=="lb_Portuguese_0_23" //Angola: Dropping 0s. Outlier in all questions - reduzco el cambio negativo en la pregunta 7.2
	}
	
*Antigua and Barbuda
replace cj_q21a_norm=. if country=="Antigua and Barbuda" //Antigua and Barbuda
replace cj_q21e_norm=. if country=="Antigua and Barbuda" //Antigua and Barbuda
drop if id_alex=="cj_English_0_1096" //Antigua and Barbuda
foreach v in all_q78_norm all_q80_norm {
	replace `v'=. if id_alex=="lb_English_0_53" //Antigua and Barbuda
}
replace cj_q10_norm=. if country=="Antigua and Barbuda" //Antigua and Barbuda
replace cc_q9c_norm=. if id_alex=="cc_English_1_950" //Angola - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cc_q40a_norm=. if id_alex=="cc_English_1_950" //Angola - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cc_q40b_norm=. if id_alex=="cc_English_1_950" //Angola - reduzco el cambio positivo en la pregunta  - 3.4 //
replace lb_q3d_norm=.5 if id_alex=="lb_English_0_748_2017_2018_2019_2021_2022_2023" //Angola - reduzco el cambio positivo en la pregunta  - 6.3 //
replace all_q74_norm=. if id_alex=="cc_English_0_1461" //Angola - reduzco el cambio positivo en la pregunta  - 7.1 //
replace all_q69_norm=. if id_alex=="cc_English_0_1461" //Angola - reduzco el cambio positivo en la pregunta  - 7.1 //
replace all_q74_norm=. if id_alex=="lb_English_0_180_2016_2017_2018_2019_2021_2022_2023" //Angola - reduzco el cambio positivo en la pregunta  - 7.1 //
replace all_q69_norm=. if id_alex=="lb_English_0_180_2016_2017_2018_2019_2021_2022_2023" //Angola - reduzco el cambio positivo en la pregunta  - 7.1 //
replace cj_q20o_norm=.5555556 if id_alex=="cj_English_0_685_2021_2022_2023" //Angola - reduzco el cambio positivo en la pregunta  - 8.4 //

*Argentina
drop if id_alex=="cc_English_1_564_2019_2021_2022_2023" //Argentina (muy negativo)
drop if id_alex=="cj_Spanish_0_416_2022_2023" //Argentina (muy negativo)
drop if id_alex=="lb_English_1_417_2016_2017_2018_2019_2021_2022_2023" //Argentina (muy negativo)
drop if id_alex=="cj_Spanish_0_579" //Argentina (muy positivo)
replace cj_q38_norm=. if country=="Argentina" //Argentina
replace cj_q8_norm=. if id_alex=="cj_English_0_223" //Argentina
foreach v in cj_q12c_norm cj_q12e_norm cj_q12f_norm cj_q20o_norm {
	replace `v'=. if `v'==0 & country=="Argentina" //Argentina
}
replace all_q1_norm=. if id_alex=="cc_Spanish (Mexico)_0_1510_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.2 (Q)  //
replace all_q2_norm=. if id_alex=="cc_Spanish (Mexico)_0_1510_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.2 (Q)  //
replace all_q20_norm=. if id_alex=="cc_Spanish (Mexico)_0_1510_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.2 (Q)  //
replace all_q21_norm=. if id_alex=="cc_Spanish (Mexico)_0_1510_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.2 (Q)  //
replace all_q1_norm=. if id_alex=="lb_Spanish_0_424_2016_2017_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.2 (Q)  //
replace all_q2_norm=. if id_alex=="lb_Spanish_0_424_2016_2017_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.2 (Q)  //
replace all_q20_norm=. if id_alex=="lb_Spanish_0_424_2016_2017_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.2 (Q)  //
replace all_q21_norm=. if id_alex=="lb_Spanish_0_424_2016_2017_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.2 (Q)  //
replace all_q1_norm=. if id_alex=="lb_Spanish_1_424_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.2 (Q)  //
replace all_q2_norm=. if id_alex=="lb_Spanish_1_424_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.2 (Q)  //
replace all_q20_norm=. if id_alex=="lb_Spanish_1_424_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.2 (Q)  //
replace all_q21_norm=. if id_alex=="lb_Spanish_1_424_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.2 (Q)  //
replace all_q9_norm=. if id_alex=="cc_Spanish (Mexico)_0_625_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.4 //
replace cj_q36c_norm=. if id_alex=="cj_Spanish_0_509" //Argentina - reduzco el cambio negativo en la pregunta  - 1.4 //
replace cj_q8_norm=. if id_alex=="cj_Spanish_0_509" //Argentina - reduzco el cambio negativo en la pregunta  - 1.4 //
replace cj_q36c_norm=. if id_alex=="cj_English_1_142_2022_2023" //Argentina - reduzco el cambio negativo en la pregunta  - 1.4 //
replace all_q14_norm=. if id_alex=="cc_English_1_481_2017_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.6 (Q) //
replace all_q15_norm=. if id_alex=="cc_English_1_481_2017_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.6 (Q) //
replace all_q16_norm=. if id_alex=="cc_English_1_481_2017_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.6 (Q) //
replace all_q18_norm=. if id_alex=="cc_English_1_481_2017_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.6 (Q)  //
replace all_q94_norm=. if id_alex=="cc_English_1_481_2017_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.6 (Q)  //
replace all_q19_norm=. if id_alex=="cc_English_1_481_2017_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.6 (Q)  //
replace all_q20_norm=. if id_alex=="cc_English_1_481_2017_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.6 (Q)  //
replace all_q21_norm=. if id_alex=="cc_English_1_481_2017_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.6 (Q)  //
replace all_q14_norm=. if id_alex=="cj_Spanish_0_349_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.6 (Q)  //
replace all_q15_norm=. if id_alex=="cj_Spanish_0_349_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.6 (Q)  //
replace all_q16_norm=. if id_alex=="cj_Spanish_1_804_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.6 (Q)  //
replace all_q17_norm=. if id_alex=="cj_Spanish_0_349_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.6 (Q)  //
replace all_q18_norm=. if id_alex=="cj_Spanish_0_349_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.6 (Q)  //
replace all_q94_norm=. if id_alex=="cj_Spanish_0_349_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.6 (Q)  //
replace all_q19_norm=. if id_alex=="cj_Spanish_0_349_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.6 (Q)  //
replace all_q20_norm=. if id_alex=="cj_Spanish_0_349_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.6 (Q)  //
replace all_q21_norm=. if id_alex=="cj_Spanish_0_349_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.6 (Q)  //
replace all_q14_norm=. if id_alex=="cc_English_1_481_2017_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.6 (Q)  //
replace all_q15_norm=. if id_alex=="cc_English_1_481_2017_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.6 (Q)  //
replace all_q16_norm=. if id_alex=="cc_English_1_481_2017_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.6 (Q)  //
replace all_q18_norm=. if id_alex=="cc_English_1_481_2017_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.6 (Q)  //
replace all_q94_norm=. if id_alex=="cc_English_1_481_2017_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.6 (Q)  //
replace all_q19_norm=. if id_alex=="cc_English_1_481_2017_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.6 (Q)  //
replace all_q20_norm=. if id_alex=="cc_English_1_481_2017_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.6 (Q)  //
replace all_q21_norm=. if id_alex=="cc_English_1_481_2017_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 1.6 (Q)  //
replace all_q96_norm=. if id_alex=="cc_Spanish_1_1201_2022_2023" //Argentina - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_Spanish_1_602_2023" //Argentina - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_Spanish_0_754_2021_2022_2023" //Argentina - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_0_343_2021_2022_2023" //Argentina - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_Spanish_0_559_2021_2022_2023" //Argentina - reduzco el cambio negativo en la pregunta  - 2.4 //
replace cc_q9a_norm=. if id_alex=="cc_English_0_1520_2019_2021_2022_2023" //Argentina - reduzco el cambio negativo en la pregunta  - 3.3 (Q) //
replace cc_q11b_norm=. if id_alex=="cc_English_0_1974" //Argentina - reduzco el cambio negativo en la pregunta  - 3.3 (Q) //
replace cc_q32j_norm=. if id_alex=="cc_English_0_1974" //Argentina - reduzco el cambio negativo en la pregunta  - 3.3 (Q) //
replace cc_q9a_norm=. if id_alex=="cc_es-mx_0_904_2017_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio negativo en la pregunta  - 3.3 (Q) //
replace cc_q32j_norm=. if id_alex=="cc_es-mx_0_904_2017_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio negativo en la pregunta  - 3.3 (Q) //
replace cj_q10_norm=. if id_alex=="cj_Spanish_1_106_2022_2023" //Argentina - reduzco el cambio negativo en la pregunta  - 4.2 //
replace cj_q31f_norm=. if id_alex=="cj_Spanish_1_979_2022_2023" //Argentina - reduzco el cambio negativo en la pregunta  - 4.6 //
replace cj_q31g_norm=. if id_alex=="cj_Spanish_1_979_2022_2023" //Argentina - reduzco el cambio negativo en la pregunta  - 4.6 //
replace cj_q31f_norm=. if id_alex=="cj_Spanish_0_458_2022_2023" //Argentina - reduzco el cambio negativo en la pregunta  - 4.6 //
replace cj_q31g_norm=. if id_alex=="cj_Spanish_0_458_2022_2023" //Argentina - reduzco el cambio negativo en la pregunta  - 4.6 //
replace cj_q31f_norm=. if id_alex=="cj_English_1_1058_2023" //Argentina - reduzco el cambio negativo en la pregunta  - 4.6 //
replace cj_q31g_norm=. if id_alex=="cj_English_1_1058_2023" //Argentina - reduzco el cambio negativo en la pregunta  - 4.6 //
replace all_q19_norm=. if id_alex=="cc_English_0_1138" //Argentina - reduzco el cambio positivo en la pregunta  - 4.7 (Q)//
replace all_q31_norm=. if id_alex=="cc_English_0_1138" //Argentina - reduzco el cambio positivo en la pregunta  - 4.7 (Q)//
replace all_q32_norm=. if id_alex=="cc_English_0_1138" //Argentina - reduzco el cambio positivo en la pregunta  - 4.7 (Q)//
replace all_q14_norm=. if id_alex=="cc_English_0_1138" //Argentina - reduzco el cambio positivo en la pregunta  - 4.7 (Q)//
replace all_q19_norm=. if id_alex=="cc_English_0_1974" //Argentina - reduzco el cambio positivo en la pregunta  - 4.7 (Q)//
replace all_q31_norm=. if id_alex=="cc_English_0_1974" //Argentina - reduzco el cambio positivo en la pregunta  - 4.7 (Q)//
replace all_q32_norm=. if id_alex=="cc_English_0_1974" //Argentina - reduzco el cambio positivo en la pregunta  - 4.7 (Q)//
replace all_q14_norm=. if id_alex=="cc_English_0_1974" //Argentina - reduzco el cambio positivo en la pregunta  - 4.7 (Q)//
replace all_q19_norm=. if id_alex=="cj_Spanish_0_78" //Argentina - reduzco el cambio positivo en la pregunta  - 4.7 (Q)//
replace all_q31_norm=. if id_alex=="cj_Spanish_0_78" //Argentina - reduzco el cambio positivo en la pregunta  - 4.7 (Q)//
replace all_q32_norm=. if id_alex=="cj_Spanish_0_78" //Argentina - reduzco el cambio positivo en la pregunta  - 4.7 (Q)//
replace all_q14_norm=. if id_alex=="cc_Spanish_1_663" //Argentina - reduzco el cambio positivo en la pregunta  - 4.7 (Q)//
replace all_q19_norm=. if id_alex=="cc_Spanish_1_663" //Argentina - reduzco el cambio positivo en la pregunta  - 4.7 (Q)//
replace all_q31_norm=. if id_alex=="cc_Spanish_1_663" //Argentina - reduzco el cambio positivo en la pregunta  - 4.7 (Q)//
replace all_q32_norm=. if id_alex=="cc_Spanish_1_663" //Argentina - reduzco el cambio positivo en la pregunta  - 4.7 (Q)//
replace all_q14_norm=. if id_alex=="cj_Spanish_0_78" //Argentina - reduzco el cambio positivo en la pregunta  - 4.7 (Q)//
replace all_q32_norm=. if id_alex=="cc_English_1_476_2017_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 4.7 (Q)//
replace all_q32_norm=. if id_alex=="cc_es-mx_0_904_2017_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 4.7 (Q)//
replace all_q32_norm=. if id_alex=="cc_Spanish_0_157_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 4.7 (Q)//
replace all_q31_norm=. if id_alex=="cc_Spanish_0_311_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 4.7 (Q)//
replace all_q31_norm=. if id_alex=="cc_Spanish_0_1645" //Argentina - reduzco el cambio positivo en la pregunta  - 4.7 (Q)//
replace cj_q15_norm=. if id_alex=="cj_Spanish_1_979_2022_2023" //Argentina - reduzco el cambio negativo en la pregunta  - 5.3 //
replace all_q76_norm=. if id_alex=="lb_Spanish_1_368_2017_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q77_norm=. if id_alex=="lb_Spanish_1_368_2017_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q78_norm=. if id_alex=="lb_Spanish_1_368_2017_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q79_norm=. if id_alex=="lb_Spanish_1_368_2017_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q80_norm=. if id_alex=="lb_Spanish_1_368_2017_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q81_norm=. if id_alex=="lb_Spanish_1_368_2017_2018_2019_2021_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 7.2 //
replace cj_q18b_norm=. if id_alex=="cj_Spanish_0_579" //Argentina - reduzco el cambio positivo en la pregunta  - 8.1 //
replace cj_q18c_norm=. if id_alex=="cj_Spanish_0_579" //Argentina - reduzco el cambio positivo en la pregunta  - 8.1 //
replace cj_q25a_norm=. if id_alex=="cj_Spanish_1_809" //Argentina - reduzco el cambio positivo en la pregunta  - 8.1 //
replace cj_q25b_norm=. if id_alex=="cj_Spanish_1_809" //Argentina - reduzco el cambio positivo en la pregunta  - 8.1 //
replace cj_q25c_norm=. if id_alex=="cj_Spanish_1_809" //Argentina - reduzco el cambio positivo en la pregunta  - 8.1 //
replace cj_q27a_norm=. if id_alex=="cj_English_0_223" //Argentina - reduzco el cambio negativo en la pregunta  - 8.2 //
replace cj_q27b_norm=. if id_alex=="cj_English_0_223" //Argentina - reduzco el cambio negativo en la pregunta  - 8.2 //
replace cj_q7a_norm=. if id_alex=="cj_English_0_223" //Argentina - reduzco el cambio negativo en la pregunta  - 8.2 //
replace cj_q7b_norm=. if id_alex=="cj_English_0_223" //Argentina - reduzco el cambio negativo en la pregunta  - 8.2 //
replace cj_q7c_norm=. if id_alex=="cj_English_0_223" //Argentina - reduzco el cambio negativo en la pregunta  - 8.2 //
replace cj_q20a_norm=. if id_alex=="cj_English_0_223" //Argentina - reduzco el cambio negativo en la pregunta  - 8.2 //
replace cj_q21g_norm=. if id_alex=="cj_Spanish_0_579" //Argentina - reduzco el cambio positivo en la pregunta  - 8.3 //
replace cj_q21g_norm=. if id_alex=="cj_Spanish_1_648_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 8.3 //
replace cj_q21h_norm=. if id_alex=="cj_English_1_142_2022_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 8.3 //
replace cj_q21a_norm=. if id_alex=="cj_Spanish_0_551" //Argentina - reduzco el cambio positivo en la pregunta  - 8.3 //
replace cj_q21e_norm=. if id_alex=="cj_English_1_1058_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 8.3 //
replace cj_q40b_norm=. if id_alex=="cj_Spanish_0_376_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 8.6 //
replace cj_q40c_norm=. if id_alex=="cj_Spanish_0_376_2023" //Argentina - reduzco el cambio positivo en la pregunta  - 8.6 //

*Australia
drop if id_alex=="cc_English_0_878" //Australia (muy positivo)
drop if id_alex=="cj_English_1_610" //Australia (muy positivo)
foreach v in all_q76_norm all_q77_norm all_q78_norm all_q79_norm all_q80_norm all_q81_norm all_q82_norm {
	replace `v'=. if id_alex=="cc_English_0_1451" //Australia
}
replace all_q84_norm=. if id_alex=="lb_English_0_519" //Australia
replace cc_q26a_norm=. if id_alex=="cc_English_0_1021" //Australia
replace all_q88_norm=. if country=="Australia" //Australia
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="lb_English_0_324" //Australia: Dropping 0s. Outlier in all questions
	}
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="cc_English_0_1535" //Australia: Dropping 0s. Outlier in all questions
	}
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="cc_English_0_878" //Australia: Dropping 0s. Outlier in all questions
	}
	foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="cc_English_0_877" //Australia: Dropping 0s. Outlier in all questions
	}
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="cc_English_1_1018" //Australia: Dropping 0s. Outlier in all questions
	}	

replace cc_q27_norm=. if id_alex=="cc_English_0_1323" //Australia - reduzco el cambio positivo en la pregunta  - 2.1 //
replace cc_q27_norm=. if id_alex=="cc_English_0_877" //Australia - reduzco el cambio positivo en la pregunta  - 2.1 //
replace cc_q27_norm=. if id_alex=="cc_English_0_970" //Australia - reduzco el cambio positivo en la pregunta  - 2.1 //
replace all_q97_norm=. if id_alex=="cc_English_0_1323" //Australia - reduzco el cambio positivo en la pregunta  - 2.1 //
replace all_q97_norm=. if id_alex=="cc_English_0_877" //Australia - reduzco el cambio positivo en la pregunta  - 2.1 //
replace all_q97_norm=. if id_alex=="cc_English_0_970" //Australia - reduzco el cambio positivo en la pregunta  - 2.1 //
replace all_q97_norm=. if id_alex=="lb_English_0_404" //Australia - reduzco el cambio positivo en la pregunta  - 2.1 //
replace all_q97_norm=. if id_alex=="lb_English_0_514" //Australia - reduzco el cambio positivo en la pregunta  - 2.1 //
replace all_q95_norm=. if id_alex=="cc_English_0_1323" //Australia - reduzco el cambio positivo en la pregunta  - 2.1 //
replace all_q95_norm=. if id_alex=="cc_English_0_1276" //Australia - reduzco el cambio positivo en la pregunta  - 2.1 //
replace all_q96_norm=. if id_alex=="cc_English_0_1630" //Australia - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_0_1323" //Australia - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_0_877" //Australia - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="lb_English_1_480_2017_2018_2019_2021_2022_2023" //Australia - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="lb_English_0_192_2018_2019_2021_2022_2023" //Australia - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q30_norm=. if id_alex=="cc_English_0_1656" //Australia - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cc_English_0_1646" //Australia - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cj_English_1_239" //Australia - reduzco el cambio negativo en la pregunta  - 4.5 //

	foreach v in cc_q14a_norm cc_q14b_norm cc_q16b_norm cc_q16c_norm cc_q16d_norm cc_q16e_norm cc_q16f_norm cc_q16g_norm {
	replace `v'=. if id_alex=="cc_English_0_1630" //Australia - reduzco el cambio negativo en la pregunta  - 6.5 //
	}
	foreach v in all_q76_norm all_q77_norm all_q78_norm all_q79_norm all_q80_norm all_q81_norm {
	replace `v'=. if id_alex=="cc_English_1_831_2023" //Australia - reduzco el cambio negativo en la pregunta  - 7.2 //
	}

*Austria
foreach v in all_q14_norm all_q15_norm all_q16_norm all_q18_norm all_q94_norm all_q19_norm all_q20_norm all_q21_norm {
	replace `v'=. if id_alex=="cc_English_0_167_2022_2023" //Austria: Removing low scores. Outlier in sub-factor
}
replace all_q96_norm=. if id_alex=="cc_English_0_167_2022_2023" //Austria: Removing 0. Outlier in question
replace all_q13_norm=. if id_alex=="lb_English_0_180_2021_2022_2023" //Austria: Removing low score. Outlier in question
replace all_q19_norm=. if id_alex=="cc_English_0_1532" //Austria: Removing low score. Outlier in question
replace all_q15_norm=. if id_alex=="cc_English_0_516_2019_2021_2022_2023" //Austria: Removing low score. Outlier in question
replace all_q16_norm=. if id_alex=="cc_English_0_516_2019_2021_2022_2023" //Austria: Removing low score. Outlier in question
replace all_q15_norm=. if id_alex=="cc_English_0_1532" //Austria: Removing low score. Outlier in question
replace all_q16_norm=. if id_alex=="cc_English_0_1532" //Austria: Removing low score. Outlier in question
replace all_q16_norm=. if id_alex=="cc_English_0_1113" //Austria: Removing low score. Outlier in question
replace all_q94_norm=. if id_alex=="cj_English_1_355_2017_2018_2019_2021_2022_2023" //Austria - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q94_norm=. if id_alex=="lb_English_1_412" //Austria - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q21_norm=. if id_alex=="cc_English_0_934_2018_2019_2021_2022_2023" //Austria - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q21_norm=. if id_alex=="cc_English_0_1039_2021_2022_2023" //Austria - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q19_norm=. if id_alex=="cc_English_1_1582_2019_2021_2022_2023" //Austria - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q20_norm=. if id_alex=="cc_English_0_713_2021_2022_2023" //Austria - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q96_norm=. if id_alex=="cc_English_0_1039_2021_2022_2023" //Austria - reduzco el cambio negativo en la pregunta  - 2.1 //
replace all_q96_norm=. if id_alex=="lb_English_0_180_2021_2022_2023" //Austria - reduzco el cambio negativo en la pregunta  - 2.1 //
replace all_q96_norm=. if id_alex=="cc_English_1_1582_2019_2021_2022_2023" //Austria - reduzco el cambio negativo en la pregunta  - 2.1 //
replace cc_q39a_norm=. if id_alex=="cc_English_0_1113" //Austria - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39b_norm=. if id_alex=="cc_English_0_1113" //Austria - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39c_norm=. if id_alex=="cc_English_0_1113" //Austria - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39d_norm=. if id_alex=="cc_English_0_1113" //Austria - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q48_norm=. if id_alex=="lb_English_0_743_2019_2021_2022_2023" //Austria - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q49_norm=. if id_alex=="lb_English_0_743_2019_2021_2022_2023" //Austria - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q50_norm=. if id_alex=="lb_English_0_743_2019_2021_2022_2023" //Austria - reduzco el cambio negativo en la pregunta  - 6.4 //
replace cc_q11a_norm=. if id_alex=="cc_English_0_1113" //Austria - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q16a_norm=. if id_alex=="cc_English_0_1113" //Austria - reduzco el cambio negativo en la pregunta  - 6.5 //

*The Bahamas
replace cc_q33_norm=. if id_alex=="cc_English_0_1414" //The Bahamas - reduzco el cambio negativo en la pregunta  - 1.4 //
replace cc_q40a_norm=. if id_alex=="cc_English_0_1493" //The Bahamas - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cc_q40b_norm=. if id_alex=="cc_English_0_1493" //The Bahamas - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cc_q16a_norm=. if id_alex=="cc_English_1_877_2018_2019_2021_2022_2023" //The Bahamas - reduzco el cambio negativo en la pregunta  - 6.5 //

*Bangladesh
drop if id_alex=="cc_English_1_333" //Bangladesh: highest CC. 
replace cj_q38_norm=. if id_alex=="cj_English_0_91_2019_2021_2022_2023" //Bangladesh - reduzco el cambio negativo en la pregunta  - 1.4 //
replace cj_q36c_norm=. if id_alex=="cj_English_0_91_2019_2021_2022_2023" //Bangladesh - reduzco el cambio negativo en la pregunta  - 1.4 //
replace cj_q8_norm=. if id_alex=="cj_English_0_91_2019_2021_2022_2023" //Bangladesh - reduzco el cambio negativo en la pregunta  - 1.4 //
replace all_q24_norm=. if id_alex=="cj_English_0_91_2019_2021_2022_2023" //Bangladesh - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q25_norm=. if id_alex=="cj_English_0_91_2019_2021_2022_2023" //Bangladesh - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q26_norm=. if id_alex=="cj_English_0_91_2019_2021_2022_2023" //Bangladesh - reduzco el cambio negativo en la pregunta  - 1.7 //
replace cc_q9c_norm=. if id_alex=="cc_English_0_243" //Bangladesh - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cc_q40a_norm=. if id_alex=="cc_English_0_243" //Bangladesh - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cc_q40b_norm=. if id_alex=="cc_English_0_243" //Bangladesh - reduzco el cambio positivo en la pregunta  - 3.4 //
replace lb_q2d_norm=. if id_alex=="lb_English_0_395" //Bangladesh - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q76_norm=. if id_alex=="lb_English_1_629_2023" //Bangladesh - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q77_norm=. if id_alex=="lb_English_1_629_2023" //Bangladesh - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q78_norm=. if id_alex=="lb_English_1_629_2023" //Bangladesh - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q79_norm=. if id_alex=="lb_English_1_629_2023" //Bangladesh - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q80_norm=. if id_alex=="lb_English_1_629_2023" //Bangladesh - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q81_norm=. if id_alex=="lb_English_1_629_2023" //Bangladesh - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q59_norm=. if id_alex=="lb_English_1_156" //Bangladesh - reduzco el cambio positivo en la pregunta  - 7.7 //
replace cc_q14a_norm=. if id_alex=="cc_English_0_509_2017_2018_2019_2021_2022_2023" //Bangladesh - reduzco el cambio positivo en la pregunta  - 7.7 //

*Barbados
drop if id_alex=="cc_English_0_1598" //Barbados (muy negativo)
foreach v in all_q41_norm all_q42_norm {
	replace `v'=. if id_alex=="cc_English_0_775_2023" //Barbados: Dropping 0s. Outlier in all questions
	}	
foreach v in all_q41_norm all_q42_norm {
	replace `v'=. if id_alex=="cc_English_0_1124_2023" //Barbados: Dropping 0s. Outlier in all questions
	}	
replace all_q2_norm=. if id_alex=="cc_English_1_377_2021_2022_2023" //Barbados -  //
replace all_q53_norm=. if id_alex=="cc_English_1_1303_2017_2018_2019_2021_2022_2023" //Barbados - reduzco el cambio positivo en la pregunta  - 1.5 //
replace all_q11_norm=. if id_alex=="cj_English_0_249_2016_2017_2018_2019_2021_2022_2023" //Barbados - reduzco el cambio positivo en la pregunta  - 1.5 //
replace all_q22_norm=. if id_alex=="cc_English_0_1060_2021_2022_2023" //Barbados - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q23_norm=. if id_alex=="cc_English_0_1060_2021_2022_2023" //Barbados - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q24_norm=. if id_alex=="cc_English_0_1060_2021_2022_2023" //Barbados - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q24_norm=. if id_alex=="cc_English_1_557_2017_2018_2019_2021_2022_2023" //Barbados - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q8_norm=. if id_alex=="cc_English_1_1303_2017_2018_2019_2021_2022_2023" //Barbados - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q90_norm=. if id_alex=="lb_English_0_471" //Barbados - reduzco el cambio negativo en la pregunta  - 7.7 //
replace all_q89_norm=. if id_alex=="cc_English_0_1926" //Barbados - reduzco el cambio negativo en la pregunta  - 7.7 //
	
*Belarus
drop if id_alex=="cc_Russian_0_383_2019_2021_2022_2023" //Belarus (muy positivo)
drop if id_alex=="cj_Russian_1_93_2019_2021_2022_2023" //Belarus (muy positivo)
drop if id_alex=="cc_English_0_926_2019_2021_2022_2023" //Belarus (muy positivo)
drop if id_alex=="lb_Russian_0_289_2022_2023" //Belarus
drop if id_alex=="cc_Russian_1_636" //Belarus
replace all_q84_norm=. if country=="Belarus" //Belarus
replace all_q85_norm=. if country=="Belarus" //Belarus
replace cc_q26a_norm=. if country=="Belarus" //Belarus
replace cj_q21h_norm=. if cj_q21h_norm==1 & country=="Belarus" //Belarus
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="cc_English_0_1370_2021_2022_2023" //Belarus: Dropping 0s. Outlier in all questions
	}	
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="lb_English_1_562" //Belarus: Dropping 0s. Outlier in all questions
	}	
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="cc_English_0_779_2018_2019_2021_2022_2023" //Belarus: Dropping 0s. Outlier in all questions
	}
replace cj_q31f_norm=. if id_alex=="cj_Russian_1_966_2023" //Belarus - reduzco el cambio negativo en la pregunta  - 4.6 //
replace cj_q31g_norm=. if id_alex=="cj_Russian_1_966_2023" //Belarus - reduzco el cambio negativo en la pregunta  - 4.6 //
replace cj_q42c_norm=. if id_alex=="cj_Russian_1_966_2023" //Belarus - reduzco el cambio negativo en la pregunta  - 4.6 //
replace cj_q42d_norm=. if id_alex=="cj_Russian_1_966_2023" //Belarus - reduzco el cambio negativo en la pregunta  - 4.6 //
replace lb_q23g_norm=. if id_alex=="lb_English_1_578_2017_2018_2019_2021_2022_2023" //Belarus - reduzco el cambio negativo en la pregunta  - 4.8 //
replace cj_q7a_norm=. if id_alex=="cj_English_1_484_2016_2017_2018_2019_2021_2022_2023" //Belarus - reduzco el cambio positivo en la pregunta  - 8.2 //
replace cj_q7b_norm=. if id_alex=="cj_English_1_484_2016_2017_2018_2019_2021_2022_2023" //Belarus - reduzco el cambio positivo en la pregunta  - 8.2 //
replace cj_q7c_norm=. if id_alex=="cj_English_1_484_2016_2017_2018_2019_2021_2022_2023" //Belarus - reduzco el cambio positivo en la pregunta  - 8.2 //
replace cj_q21g_norm=. if id_alex=="cj_Russian_0_964_2021_2022_2023" //Belarus - reduzco el cambio positivo en la pregunta  - 8.3 //
replace cj_q21h_norm=.5555556 if id_alex=="cj_Russian_1_973_2023" //Belarus - reduzco el cambio positivo en la pregunta  - 8.3 //
replace cj_q20o_norm=. if id_alex=="cj_Russian_0_986_2017_2018_2019_2021_2022_2023" //Belarus - reduzco el cambio positivo en la pregunta  - 8.4 //
replace cj_q32b_norm=. if id_alex=="cj_Russian_0_264_2019_2021_2022_2023" //Belarus - reduzco el cambio positivo en la pregunta  - 8.5 //
replace cj_q20k_norm=. if id_alex=="cj_Russian_0_264_2019_2021_2022_2023" //Belarus - reduzco el cambio positivo en la pregunta  - 8.5 //
replace cj_q24b_norm=. if id_alex=="cj_Russian_0_264_2019_2021_2022_2023" //Belarus - reduzco el cambio positivo en la pregunta  - 8.5 //
replace cj_q24c_norm=. if id_alex=="cj_Russian_0_264_2019_2021_2022_2023" //Belarus - reduzco el cambio positivo en la pregunta  - 8.5 //

*Belgium
drop if id_alex=="cj_French_0_925_2017_2018_2019_2021_2022_2023" //Belgium: Lowest CJ
drop if id_alex=="cj_English_0_764" //Belgium (muy negativo)
drop if id_alex=="cc_French_1_1132" //Belgium (muy negativo)
replace all_q85_norm=. if id_alex=="lb_French_0_551" //Belgium: Removing low score from questionnaire
replace cc_q26b_norm=. if id_alex=="cc_French_1_617_2022_2023" //Belgium: Removing low score from questionnaire
replace all_q9_norm=. if id_alex=="cc_French_0_676_2021_2022_2023" //Belarus - reduzco el cambio negativo en la pregunta  - 1.4 //
replace all_q9_norm=. if id_alex=="cc_French_1_1143_2021_2022_2023" //Belarus - reduzco el cambio negativo en la pregunta  - 1.4 //
replace cj_q38_norm=. if id_alex=="cj_English_0_1338" //Belarus - reduzco el cambio negativo en la pregunta  - 1.4 //
replace cj_q36c_norm=. if id_alex=="cj_English_0_1338" //Belarus - reduzco el cambio negativo en la pregunta  - 1.4 //
replace all_q62_norm=. if id_alex=="cc_French_0_813_2016_2017_2018_2019_2021_2022_2023" //Belarus - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q63_norm=. if id_alex=="cc_French_0_813_2016_2017_2018_2019_2021_2022_2023" //Belarus - reduzco el cambio negativo en la pregunta  - 6.3 //
replace cj_q21a_norm=. if id_alex=="cj_English_0_161_2018_2019_2021_2022_2023" //Belarus - reduzco el cambio negativo en la pregunta  - 8.3 //
replace cj_q21e_norm=. if id_alex=="cj_English_0_161_2018_2019_2021_2022_2023" //Belarus - reduzco el cambio negativo en la pregunta  - 8.3 //
replace cj_q21g_norm=. if id_alex=="cj_English_0_161_2018_2019_2021_2022_2023" //Belarus - reduzco el cambio negativo en la pregunta  - 8.3 //

*Belize
drop if id_alex=="cj_English_1_839" //Belize (muy positivo)
drop if id_alex=="cc_English_0_1339_2014_2016_2017_2018_2019_2021_2022_2023" //Belize (muy negativo)
replace all_q87_norm=. if country=="Belize" //Belize
replace cj_q21h_norm=. if country=="Belize" //Belize
replace cj_q15_norm=. if country=="Belize" //Belize
foreach v in cj_q42c_norm cj_q42d_norm cj_q10_norm cj_q31c_norm cj_q31d_norm cj_q31f_norm cj_q31g_norm {
	replace `v'=. if id_alex=="cj_English_1_839" //Belize
}
replace cj_q6d_norm=. if country=="Belize" //Belize
replace cj_q21c_norm=. if id_alex=="cj_English_1_839" //Belize
replace cj_q21d_norm=. if id_alex=="cj_English_1_839" //Belize
replace cj_q31g_norm=. if id_alex=="cj_English_1_404_2022_2023" //Belize
foreach v in cj_q21e_norm cj_q21g_norm cj_q12c_norm cj_q12d_norm cj_q20o_norm {
	replace `v'=. if id_alex=="cj_English_1_839" //Belize
}
replace cj_q36c_norm=.3333333 if id_alex=="cj_English_1_652_2021_2022_2023" //Belize - reduzco el cambio negativo en la pregunta  - 1.4 //
replace cj_q33c_norm=.3333333 if id_alex=="cj_English_1_652_2021_2022_2023" //Belize - reduzco el cambio negativo en la pregunta  - 2.2 //
replace cc_q14a_norm=. if id_alex=="cc_English_1_64" //Belize - reduzco el cambio negativo en la pregunta  - 7.7 //
replace cc_q14b_norm=. if id_alex=="cc_English_1_64" //Belize - reduzco el cambio negativo en la pregunta  - 7.7 //
replace cj_q40b_norm=. if id_alex=="cj_English_1_1045_2017_2018_2019_2021_2022_2023" //Belize - reduzco el cambio negativo en la pregunta  - 8.6 //
replace cj_q20m_norm=. if id_alex=="cj_English_1_1045_2017_2018_2019_2021_2022_2023" //Belize - reduzco el cambio negativo en la pregunta  - 8.6 //

*Benin
drop if id_alex=="cc_French_1_139" //Benin
drop if id_alex=="lb_French_1_431" //Benin
drop if id_alex=="cc_French_1_770" //Benin 
replace lb_q19a_norm=. if country=="Benin" //Benin 
replace cc_q10_norm=. if id_alex=="cc_French_0_149" //Benin 
replace cc_q16a_norm=. if id_alex=="cc_French_0_149" //Benin 
replace all_q90_norm=. if country=="Benin" //Benin
replace all_q78_norm=. if id_alex=="lb_French_0_575" //Benin 
replace cc_q40a_norm=. if id_alex=="cc_French_0_149" //Benin - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cc_q40b_norm=. if id_alex=="cc_French_0_149" //Benin - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cj_q11b_norm=. if id_alex=="cj_French_0_420" //Benin - reduzco el cambio positivo en la pregunta  - 4.2 //
replace all_q30_norm=. if id_alex=="cj_French_0_420" //Benin - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cj_French_0_420" //Benin - reduzco el cambio positivo en la pregunta  - 4.5 //
replace cc_q16c_norm=. if id_alex=="cc_French_0_70_2018_2019_2021_2022_2023" //Benin - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cj_q22e_norm=. if id_alex=="cj_French_0_420" //Benin - reduzco el cambio negativo en la pregunta  - 8.7 //
replace cj_q22e_norm=. if id_alex=="cj_French_0_353" //Benin - reduzco el cambio negativo en la pregunta  - 8.7 //
replace cj_q22a_norm=. if id_alex=="cj_French_0_420" //Benin - reduzco el cambio negativo en la pregunta  - 8.7 //
replace cj_q22a_norm=. if id_alex=="cj_French_0_353" //Benin - reduzco el cambio negativo en la pregunta  - 8.7 //
replace cj_q22c_norm=. if id_alex=="cj_French_0_363_2018_2019_2021_2022_2023" //Benin - reduzco el cambio negativo en la pregunta  - 8.7 //

*Bolivia
replace all_q85_norm=. if all_q85_norm==0 & country=="Bolivia" //Bolivia
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="cc_English_0_1697" //Bolivia: Dropping 0s. Outlier in all questions
	}
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="lb_Spanish_1_582" //Bolivia: Dropping 0s. Outlier in all questions
	}	
replace all_q96_norm=. if id_alex=="cc_Spanish_1_544_2023" //Bolivia - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_Spanish_1_732_2023" //Bolivia - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_Spanish_0_512" //Bolivia - reduzco el cambio negativo en la pregunta  - 2.4 //
replace cc_q9c_norm=. if id_alex=="cc_Spanish_0_835_2016_2017_2018_2019_2021_2022_2023" //Bolivia - reduzco el cambio positivo en la pregunta  - 3.4 //	
replace cc_q40a_norm=. if id_alex=="cc_Spanish_1_1499_2021_2022_2023" //Bolivia - reduzco el cambio positivo en la pregunta  - 3.4 //	
replace cj_q42c_norm=. if id_alex=="cj_Spanish_0_317_2022_2023" //Bolivia - reduzco el cambio negativo en la pregunta  - 4.6 //	
replace cj_q42d_norm=. if id_alex=="cj_Spanish_0_317_2022_2023" //Bolivia - reduzco el cambio negativo en la pregunta  - 4.6 //	
replace cj_q15_norm=. if id_alex=="cj_Spanish_1_316" //Bolivia - reduzco el cambio positivo en la pregunta  - 5.3 //	
replace cc_q14a_norm=. if id_alex=="cc_Spanish (Mexico)_1_860_2019_2021_2022_2023" //Bolivia - reduzco el cambio negativo en la pregunta  - 6.5 //	
replace cc_q16b_norm=. if id_alex=="cc_Spanish_0_512" //Bolivia - reduzco el cambio negativo en la pregunta  - 6.5 //	
replace cc_q16c_norm=. if id_alex=="cc_Spanish_0_512" //Bolivia - reduzco el cambio negativo en la pregunta  - 6.5 //	
replace cc_q16d_norm=. if id_alex=="cc_Spanish_0_512" //Bolivia - reduzco el cambio negativo en la pregunta  - 6.5 //	
replace cc_q16e_norm=. if id_alex=="cc_Spanish_0_512" //Bolivia - reduzco el cambio negativo en la pregunta  - 6.5 //	
replace cc_q16f_norm=. if id_alex=="cc_Spanish_0_512" //Bolivia - reduzco el cambio negativo en la pregunta  - 6.5 //	
replace cc_q16g_norm=. if id_alex=="cc_Spanish_0_512" //Bolivia - reduzco el cambio negativo en la pregunta  - 6.5 //	
replace all_q86_norm=. if id_alex=="cc_English_0_1697" //Bolivia - reduzco el cambio negativo en la pregunta  - 7.6 //	
replace all_q87_norm=. if id_alex=="cc_English_0_1697" //Bolivia - reduzco el cambio negativo en la pregunta  - 7.6 //	
replace all_q90_norm=. if id_alex=="cc_English_0_1697" //Bolivia - reduzco el cambio negativo en la pregunta  - 7.7 //	
replace all_q91_norm=. if id_alex=="cc_English_0_1697" //Bolivia - reduzco el cambio negativo en la pregunta  - 7.7 //	
replace cj_q12a_norm=. if id_alex=="cj_Spanish_0_279_2023" //Bolivia - reduzco el cambio negativo en la pregunta  - 8.4 //	
replace cj_q12b_norm=. if id_alex=="cj_Spanish_0_279_2023" //Bolivia - reduzco el cambio negativo en la pregunta  - 8.4 //	
replace cj_q12c_norm=. if id_alex=="cj_Spanish_0_279_2023" //Bolivia - reduzco el cambio negativo en la pregunta  - 8.4 //
replace cj_q12d_norm=. if id_alex=="cj_Spanish_0_279_2023" //Bolivia - reduzco el cambio negativo en la pregunta  - 8.4 //
replace cj_q12e_norm=. if id_alex=="cj_Spanish_0_279_2023" //Bolivia - reduzco el cambio negativo en la pregunta  - 8.4 //
replace cj_q12f_norm=. if id_alex=="cj_Spanish_0_279_2023" //Bolivia - reduzco el cambio negativo en la pregunta  - 8.4 //
replace cj_q20o_norm=. if id_alex=="cj_English_0_73" //Bolivia - reduzco el cambio negativo en la pregunta  - 8.4 //
replace cj_q40c_norm=. if id_alex=="cj_Spanish_1_820" //Bolivia - reduzco el cambio positivo en la pregunta  - 8.6 //
	
*Bosnia and Herzegovina
replace lb_q2d_norm=. if country=="Bosnia and Herzegovina" //Bosnia and Herzegovina: Score of 1, too high
replace lb_q3d_norm=. if country=="Bosnia and Herzegovina" //Bosnia and Herzegovina: Score of 1, too high
replace all_q29_norm=. if id_alex=="cj_English_1_741_2022_2023" //Bosnia and Herzegovina: Score of 0, only expert with this score.
replace cc_q16a_norm=. if cc_q16a_norm==0 & country=="Bosnia and Herzegovina" //Bosnia and Herzegovina: Removing 2 0's (outliers)
drop if id_alex=="cc_English_0_758_2022_2023" //Bosnia and Herzegovina: Lowest CC expert. 
replace all_q96_norm=. if id_alex=="cj_English_1_980_2019_2021_2022_2023" //Bosnia and Herzegovina: Outlier (score of 1 in this question)
replace cc_q26b_norm=. if id_alex=="cc_English_0_657" //Bosnia and Herzegovina: Outlier (score of 1 in this question)
replace cc_q13_norm=. if id_alex=="cc_English_1_444" //Bosnia and Herzegovina: Outlier (score of 1 in this question)
replace all_q22_norm=. if id_alex=="lb_English_1_400_2022_2023" //Bosnia and Herzegovina - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q23_norm=. if id_alex=="lb_English_1_400_2022_2023" //Bosnia and Herzegovina - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q24_norm=. if id_alex=="lb_English_1_400_2022_2023" //Bosnia and Herzegovina - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q25_norm=. if id_alex=="lb_English_1_400_2022_2023" //Bosnia and Herzegovina - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q26_norm=. if id_alex=="lb_English_1_400_2022_2023" //Bosnia and Herzegovina - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q27_norm=. if id_alex=="lb_English_1_400_2022_2023" //Bosnia and Herzegovina - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q27_norm=. if id_alex=="cc_English_1_207" //Bosnia and Herzegovina - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q27_norm=. if id_alex=="cj_English_1_741_2022_2023" //Bosnia and Herzegovina - reduzco el cambio positivo en la pregunta  - 2.4 //
replace cc_q39a_norm=. if id_alex=="cc_English_1_444" //Bosnia and Herzegovina - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39b_norm=. if id_alex=="cc_English_1_444" //Bosnia and Herzegovina - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39c_norm=. if id_alex=="cc_English_1_444" //Bosnia and Herzegovina - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39d_norm=. if id_alex=="cc_English_1_444" //Bosnia and Herzegovina - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39e_norm=. if id_alex=="cc_English_1_444" //Bosnia and Herzegovina - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q40a_norm=. if id_alex=="cc_English_0_92" //Bosnia and Herzegovina - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cc_q40b_norm=. if id_alex=="cc_English_0_92" //Bosnia and Herzegovina - reduzco el cambio negativo en la pregunta  - 3.4 //
replace all_q30_norm=. if id_alex=="cj_English_1_148" //Bosnia and Herzegovina - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cj_English_1_440" //Bosnia and Herzegovina - reduzco el cambio negativo en la pregunta  - 4.5 //
replace cj_q31g_norm=. if id_alex=="cj_English_1_741_2022_2023" //Bosnia and Herzegovina - reduzco el cambio negativo en la pregunta  - 4.6 //
replace all_q19_norm=. if id_alex=="cj_English_0_136_2017_2018_2019_2021_2022_2023" //Bosnia and Herzegovina - reduzco el cambio negativo en la pregunta  - 4.7 //
replace all_q31_norm=. if id_alex=="cj_English_0_136_2017_2018_2019_2021_2022_2023" //Bosnia and Herzegovina - reduzco el cambio negativo en la pregunta  - 4.7 //
replace all_q32_norm=. if id_alex=="cj_English_0_136_2017_2018_2019_2021_2022_2023" //Bosnia and Herzegovina - reduzco el cambio negativo en la pregunta  - 4.7 //
replace all_q14_norm=. if id_alex=="cj_English_0_136_2017_2018_2019_2021_2022_2023" //Bosnia and Herzegovina - reduzco el cambio negativo en la pregunta  - 4.7 //
replace all_q80_norm=. if id_alex=="lb_English_0_457_2018_2019_2021_2022_2023" //Bosnia and Herzegovina - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q81_norm=. if id_alex=="lb_English_0_457_2018_2019_2021_2022_2023" //Bosnia and Herzegovina - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q80_norm=. if id_alex=="lb_English_1_400_2022_2023" //Bosnia and Herzegovina - reduzco el cambio negativo en la pregunta  - 7.2 //
replace cc_q26a_norm=. if id_alex=="cc_Russian_1_952" //Bosnia and Herzegovina - reduzco el cambio positivo en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="cc_Russian_1_952" //Bosnia and Herzegovina - reduzco el cambio positivo en la pregunta  - 7.5 //
replace all_q85_norm=. if id_alex=="cc_English_1_444" //Bosnia and Herzegovina - reduzco el cambio positivo en la pregunta  - 7.5 //


*Botswana
drop if id_alex=="cc_English_0_796_2023" //Botswana (muy positivo)
foreach v in cj_q40b_norm cj_q40c_norm cj_q20m_norm {
	replace `v'=. if id_alex=="cj_English_1_80" //Botswana: Lowest expert for 8.6. Removed all their answers for the questions in 8.6.
}
foreach v in cj_q7a_norm cj_q7b_norm cj_q7c_norm cj_q20a_norm cj_q20b_norm cj_q20e_norm {
	replace `v'=. if id_alex=="cj_English_1_80" //Botswana
}
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="cc_English_0_203_2023" //Botswana: Dropping 0s. Outlier in all questions
	}	
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="cc_English_0_680_2022_2023" //Botswana: Dropping 0s. Outlier in all questions
	}	

replace all_q96_norm=. if id_alex=="lb_English_0_389_2016_2017_2018_2019_2021_2022_2023" //Botswana - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="lb_English_1_482_2016_2017_2018_2019_2021_2022_2023" //Botswana - reduzco el cambio positivo en la pregunta  - 2.4 //
replace cc_q39a_norm=. if id_alex=="cc_English_0_316_2023" //Botswana - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39b_norm=. if id_alex=="cc_English_0_316_2023" //Botswana - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39c_norm=. if id_alex=="cc_English_0_316_2023" //Botswana - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39d_norm=. if id_alex=="cc_English_0_316_2023" //Botswana - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39e_norm=. if id_alex=="cc_English_0_316_2023" //Botswana - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q9c_norm=. if id_alex=="cc_English_1_1194_2022_2023" //Botswana - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cc_q40a_norm=. if id_alex=="cc_English_1_1270_2022_2023" //Botswana - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cc_q40b_norm=. if id_alex=="cc_English_0_316_2023" //Botswana - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cj_q11a_norm=. if id_alex=="cj_English_1_716_2016_2017_2018_2019_2021_2022_2023" //Botswana - reduzco el cambio negativo en la pregunta  - 4.2 //
replace cj_q11a_norm=. if id_alex=="cj_English_0_544_2021_2022_2023" //Botswana - reduzco el cambio negativo en la pregunta  - 4.2 //
replace all_q29_norm=. if id_alex=="cc_English_0_427_2023" //Botswana - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cc_English_0_427_2023" //Botswana - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cc_English_1_621" //Botswana - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cc_English_1_621" //Botswana - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q71_norm=. if id_alex=="lb_English_1_314" //Botswana - reduzco el cambio positivo en la pregunta  - 7.1 //
replace all_q71_norm=. if id_alex=="lb_English_1_499" //Botswana - reduzco el cambio positivo en la pregunta  - 7.1 //
replace all_q89_norm=. if id_alex=="cc_English_1_1077" //Botswana - reduzco el cambio positivo en la pregunta  - 7.7 //
replace all_q89_norm=. if id_alex=="lb_English_1_132" //Botswana - reduzco el cambio positivo en la pregunta  - 7.7 //
replace all_q90_norm=. if id_alex=="lb_English_1_132" //Botswana - reduzco el cambio positivo en la pregunta  - 7.7 //
replace cj_q28_norm=. if id_alex=="cj_English_1_80" //Botswana - reduzco el cambio negativo en la pregunta  - 8.4 //
	
*Brazil
replace cc_q40a_norm=. if country=="Brazil" //Brazil: Very high score in the sub-factor. Was removed last year
drop if id_alex=="cc_Portuguese_1_119_2022_2023" //Brazil: Highest CC
drop if id_alex=="cj_Portuguese_1_211" //Brazil: Highest CJ
drop if id_alex=="lb_Portuguese_0_149_2022_2023" //Brazil: Highest LB
replace cc_q39a_norm=. if id_alex=="cc_Portuguese_1_322_2023" //Brazil - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39b_norm=. if id_alex=="cc_Portuguese_1_322_2023" //Brazil - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39c_norm=. if id_alex=="cc_Portuguese_1_322_2023" //Brazil - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39d_norm=. if id_alex=="cc_Portuguese_1_322_2023" //Brazil - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39e_norm=. if id_alex=="cc_Portuguese_1_322_2023" //Brazil - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cj_q42c_norm=. if id_alex=="cj_Portuguese_0_522_2022_2023" //Brazil - reduzco el cambio positivo en la pregunta  - 4.6 //
replace cj_q15_norm=. if id_alex=="cj_Portuguese_1_704" //Brazil - reduzco el cambio negativo en la pregunta  - 5.3 //
replace cc_q16b_norm=. if id_alex=="cc_Portuguese_1_1044_2022_2023" //Brazil - reduzco el cambio positivo en la pregunta  - 6.5 //
replace cc_q10_norm=. if id_alex=="cc_English_1_1418_2023" //Brazil - reduzco el cambio positivo en la pregunta  - 6.5 //
replace cc_q11a_norm=. if id_alex=="cc_English_1_1418_2023" //Brazil - reduzco el cambio positivo en la pregunta  - 6.5 //
replace cc_q16a_norm=. if id_alex=="cc_English_1_1418_2023" //Brazil - reduzco el cambio positivo en la pregunta  - 6.5 //

*Bulgaria
drop if id_alex=="cj_French_0_432" //Bulgaria (muy positivo)
drop if id_alex=="cj_English_0_714" //Bulgaria (muy positivo)
drop if id_alex=="cc_English_0_1897" //Bulgaria (muy negativo)
drop if id_alex=="cc_English_0_1086" //Bulgaria (muy negativo)
drop if id_alex=="cc_English_0_424" //Bulgaria: Lowest CC
foreach v in cc_q33_norm all_q9_norm {
	replace `v'=. if id_alex=="cc_English_0_695" //Bulgaria: Removing 1s. Outlier in question
	replace `v'=. if id_alex=="cc_French_0_343" //Bulgaria: Removing 1s. Outlier in question
}
replace cj_q36c_norm=. if id_alex=="cj_English_0_810" //Bulgaria: Removing 1s. Outlier in question
replace cj_q36c_norm=. if id_alex=="cj_English_0_249" //Bulgaria: Removing 1s. Outlier in question
foreach v in all_q48_norm all_q49_norm all_q50_norm lb_q19a_norm {
	replace `v'=. if id_alex=="lb_English_0_313" //Bulgaria: Removing 1s. Outlier in sub-factor
	replace `v'=. if id_alex=="lb_English_0_458" //Bulgaria: Removing 1s. Outlier in sub-factor
}
replace cj_q21a_norm=. if id_alex=="cj_English_0_249" //Bulgaria: Removing high score. Outlier in question
replace cj_q21a_norm=. if id_alex=="cj_English_0_707" //Bulgaria: Removing high score. Outlier in question
replace cj_q21e_norm=. if id_alex=="cj_English_0_707" //Bulgaria: Removing high score. Outlier in question
replace cj_q21g_norm=. if id_alex=="cj_English_0_714" //Bulgaria: Removing 1. Outlier
replace cj_q21g_norm=. if id_alex=="cj_Russian_0_354" //Bulgaria: Removing 1. Outlier
replace cj_q21g_norm=. if id_alex=="cj_English_0_1186" //Bulgaria: Removing 1. Outlier
replace cj_q21h_norm=. if cj_q21h_norm==1 & country=="Bulgaria" //Bulgaria: Removing 1s. Outliers in question
replace cj_q28_norm=. if id_alex=="cj_French_0_432" //Bulgaria: Removing high score. Outlier in sub-factor
replace cj_q12e_norm=. if id_alex=="cj_English_0_714" //Bulgaria: Removing 1. Outlier
replace cj_q20o_norm=. if id_alex=="cj_English_0_260" //Bulgaria: Removing 1. Outlier
replace cj_q20o_norm=. if id_alex=="cj_English_0_714" //Bulgaria: Removing 1. Outlier
replace all_q2_norm=. if id_alex=="cc_English_0_695" //Bulgaria - reduzco el cambio positivo en la pregunta  - 1.2 //
replace all_q2_norm=. if id_alex=="cc_English_0_1426" //Bulgaria - reduzco el cambio positivo en la pregunta  - 1.2 //
replace all_q2_norm=. if id_alex=="cc_English_0_1376" //Bulgaria - reduzco el cambio positivo en la pregunta  - 1.2 //
replace all_q2_norm=. if id_alex=="cc_French_0_343" //Bulgaria - reduzco el cambio positivo en la pregunta  - 1.2 //
replace cc_q39a_norm=. if id_alex=="cc_English_0_1140" //Bulgaria - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39b_norm=. if id_alex=="cc_English_0_1140" //Bulgaria - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39c_norm=. if id_alex=="cc_English_0_1140" //Bulgaria - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39d_norm=. if id_alex=="cc_English_0_1140" //Bulgaria - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39e_norm=. if id_alex=="cc_English_0_1140" //Bulgaria - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39a_norm=. if id_alex=="cc_English_1_1129_2022_2023" //Bulgaria - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39b_norm=. if id_alex=="cc_English_1_1129_2022_2023" //Bulgaria - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39c_norm=. if id_alex=="cc_English_1_1129_2022_2023" //Bulgaria - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39d_norm=. if id_alex=="cc_English_1_1129_2022_2023" //Bulgaria - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39e_norm=. if id_alex=="cc_English_1_1129_2022_2023" //Bulgaria - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39a_norm=. if id_alex=="cc_English_0_1909" //Bulgaria - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39b_norm=. if id_alex=="cc_English_0_1909" //Bulgaria - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39c_norm=. if id_alex=="cc_English_0_1909" //Bulgaria - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39d_norm=. if id_alex=="cc_English_0_1909" //Bulgaria - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39e_norm=. if id_alex=="cc_English_0_1909" //Bulgaria - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q40a_norm=. if id_alex=="cc_English_0_1426" //Bulgaria - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cc_q40a_norm=. if id_alex=="cc_English_0_1376" //Bulgaria - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cc_q40a_norm=. if id_alex=="cc_French_0_343" //Bulgaria - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cc_q40a_norm=. if id_alex=="cc_Russian_0_1306" //Bulgaria - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cc_q40a_norm=. if id_alex=="cc_English_0_1773" //Bulgaria - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cc_q40a_norm=. if id_alex=="cc_English_0_346" //Bulgaria - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cj_q11a_norm=. if id_alex=="cj_Russian_0_354" //Bulgaria - reduzco el cambio negativo en la pregunta  - 4.2 //
replace cj_q11b_norm=. if id_alex=="cj_Russian_0_354" //Bulgaria - reduzco el cambio negativo en la pregunta  - 4.2 //
replace cj_q31e_norm=. if id_alex=="cj_English_0_1186" //Bulgaria - reduzco el cambio negativo en la pregunta  - 4.2 //
replace cj_q42c_norm=. if id_alex=="cj_Russian_0_354" //Bulgaria - reduzco el cambio negativo en la pregunta  - 4.2 //
replace cj_q42d_norm=. if id_alex=="cj_Russian_0_354" //Bulgaria - reduzco el cambio negativo en la pregunta  - 4.2 //
replace cj_q10_norm=. if id_alex=="cj_Russian_0_354" //Bulgaria - reduzco el cambio negativo en la pregunta  - 4.2 //
replace cj_q10_norm=. if id_alex=="cj_English_0_792" //Bulgaria - reduzco el cambio negativo en la pregunta  - 4.2 //
replace all_q13_norm=. if id_alex=="cj_English_0_792" //Bulgaria - reduzco el cambio negativo en la pregunta  - 4.4 //
replace all_q14_norm=. if id_alex=="cj_English_0_792" //Bulgaria - reduzco el cambio negativo en la pregunta  - 4.4 //
replace all_q15_norm=. if id_alex=="cj_English_0_792" //Bulgaria - reduzco el cambio negativo en la pregunta  - 4.4 //
replace all_q16_norm=. if id_alex=="cj_English_0_792" //Bulgaria - reduzco el cambio negativo en la pregunta  - 4.4 //
replace all_q17_norm=. if id_alex=="cj_English_0_792" //Bulgaria - reduzco el cambio negativo en la pregunta  - 4.4 //
replace all_q29_norm=. if id_alex=="cj_Russian_0_354" //Bulgaria - reduzco el cambio negativo en la pregunta  - 4.5 //
replace cj_q31f_norm=. if id_alex=="cj_English_0_1186" //Bulgaria - reduzco el cambio negativo en la pregunta  - 4.5 //
replace cj_q31f_norm=. if id_alex=="cj_English_0_792" //Bulgaria - reduzco el cambio negativo en la pregunta  - 4.5 //
replace lb_q23f_norm=. if id_alex=="lb_English_0_605" //Bulgaria - reduzco el cambio positivo en la pregunta  - 4.8 //
replace lb_q23g_norm=. if id_alex=="lb_English_0_605" //Bulgaria - reduzco el cambio positivo en la pregunta  - 4.8 //
replace lb_q23f_norm=. if id_alex=="lb_English_1_151_2023" //Bulgaria - reduzco el cambio positivo en la pregunta  - 4.8 //
replace lb_q23g_norm=. if id_alex=="lb_English_1_151_2023" //Bulgaria - reduzco el cambio positivo en la pregunta  - 4.8 //
replace cj_q15_norm=. if id_alex=="cj_Russian_0_838" //Bulgaria - reduzco el cambio negativo en la pregunta  - 5.3 //
replace cj_q15_norm=. if id_alex=="cj_English_0_1186" //Bulgaria - reduzco el cambio negativo en la pregunta  - 5.3 //
replace cj_q15_norm=. if id_alex=="cj_English_0_331" //Bulgaria - reduzco el cambio negativo en la pregunta  - 5.3 //
replace all_q49_norm=. if id_alex=="cc_English_1_1129_2022_2023" //Bulgaria - reduzco el cambio positivo en la pregunta  - 6.4 //
replace all_q49_norm=. if id_alex=="cc_English_0_344" //Bulgaria - reduzco el cambio positivo en la pregunta  - 6.4 //
replace all_q49_norm=. if id_alex=="cc_Russian_0_908" //Bulgaria - reduzco el cambio positivo en la pregunta  - 6.4 //
replace lb_q19a_norm=. if id_alex=="lb_English_0_206" //Bulgaria - reduzco el cambio positivo en la pregunta  - 6.4 //
replace lb_q19a_norm=. if id_alex=="lb_English_0_585" //Bulgaria - reduzco el cambio positivo en la pregunta  - 6.4 //
replace lb_q19a_norm=. if id_alex=="lb_English_0_98" //Bulgaria - reduzco el cambio positivo en la pregunta  - 6.4 //
replace cc_q10_norm=. if id_alex=="cc_English_0_1376" //Bulgaria - reduzco el cambio positivo en la pregunta  - 6.5 //
replace cc_q11a_norm=. if id_alex=="cc_English_0_1376" //Bulgaria - reduzco el cambio positivo en la pregunta  - 6.5 //
replace cc_q16a_norm=. if id_alex=="cc_English_0_1376" //Bulgaria - reduzco el cambio positivo en la pregunta  - 6.5 //
replace cc_q11a_norm=. if id_alex=="cc_English_0_1426" //Bulgaria - reduzco el cambio positivo en la pregunta  - 7.4 //
replace all_q3_norm=. if id_alex=="cc_English_0_1426" //Bulgaria - reduzco el cambio positivo en la pregunta  - 7.4 //
replace cc_q11a_norm=. if id_alex=="cc_English_0_1376" //Bulgaria - reduzco el cambio positivo en la pregunta  - 7.4 //
replace all_q3_norm=. if id_alex=="cc_English_0_1376" //Bulgaria - reduzco el cambio positivo en la pregunta  - 7.4 //
replace cj_q21g_norm=. if id_alex=="cj_English_0_71_2022_2023" //Bulgaria - reduzco el cambio positivo en la pregunta  - 8.3 //
replace cj_q21g_norm=. if id_alex=="cj_English_1_750_2023" //Bulgaria - reduzco el cambio positivo en la pregunta  - 8.3 //
replace cj_q21h_norm=. if id_alex=="cj_English_1_750_2023" //Bulgaria - reduzco el cambio positivo en la pregunta  - 8.3 //
replace cj_q21h_norm=. if id_alex=="cj_English_0_176" //Bulgaria - reduzco el cambio positivo en la pregunta  - 8.3 //
replace cj_q28_norm=. if id_alex=="cj_English_0_249" //Bulgaria - reduzco el cambio positivo en la pregunta  - 8.3 //
replace cj_q28_norm=. if id_alex=="cj_English_0_810" //Bulgaria - reduzco el cambio positivo en la pregunta  - 8.3 //
replace cj_q20m_norm=. if id_alex=="cj_English_0_71_2022_2023" //Bulgaria - reduzco el cambio positivo en la pregunta  - 8.6 //

*Burkina Faso
drop if id_alex=="cc_English_0_1371_2019_2021_2022_2023" //Burkina Faso (muy positivo)
drop if id_alex=="lb_French_1_301"  //Burkina Faso (muy positivo)
replace cj_q11b_norm=. if country=="Burkina Faso" //Burkina Faso: Score of 1. Removed last year.
drop if id_alex=="cj_French_1_340" //Burkina Faso: Highest CJ expert. 20 points above country average.
foreach v in all_q62_norm all_q63_norm {
	replace `v'=. if id_alex=="cc_French_0_420_2021_2022_2023" //Burkina Faso: Removing highest answers 
}
replace lb_q2d_norm=. if id_alex=="lb_French_1_301" //Burkina Faso: Expert with score of 1. Outlier
replace cj_q20m_norm=. if cj_q20m_norm==1 & country=="Burkina Faso" //Burkina Faso: Removing highest answers 
foreach v in all_q29_norm all_q30_norm {
	replace `v'=. if `v'==0 & country=="Burkina Faso" //Burkina Faso: Lowest answers. Outliers 
}
replace all_q21_norm=. if id_alex=="cc_English_0_1598_2017_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio negativo en la pregunta (removi GPP) - 1.2 (Q) //
replace all_q21_norm=. if id_alex=="lb_French_0_190_2023" //Burkina Faso - reduzco el cambio negativo en la pregunta (removi GPP) - 1.2 (Q) //
replace all_q21_norm=. if id_alex=="cc_French_0_907_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio negativo en la pregunta (removi GPP) - 1.2 (Q) //
replace all_q20_norm=. if id_alex=="lb_French_0_190_2023" //Burkina Faso - reduzco el cambio negativo en la pregunta (removi GPP) - 1.2 (Q) //replace cc_q33_norm=. if id_alex=="cc_English_0_1032_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 1.4 //
replace cc_q33_norm=. if id_alex=="cc_French_0_907_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 1.4 //
replace cc_q33_norm=. if id_alex=="cc_French_0_1674_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 1.4 //
replace all_q9_norm=. if id_alex=="cc_French_0_1619" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 1.4 //
replace cj_q38_norm=. if id_alex=="cj_French_0_617_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 1.4 //
replace cj_q38_norm=. if id_alex=="cj_French_0_238_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 1.4 //
replace cj_q38_norm=. if id_alex=="cj_French_0_238_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 1.4 //
replace cc_q27_norm=. if id_alex=="cc_French_0_907_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 2.1 //
replace all_q96_norm=. if id_alex=="cj_French_0_778_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cj_French_0_963_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cj_French_0_870_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 2.4 //
replace cc_q39d_norm=. if id_alex=="cc_French_0_220_2016_2017_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cj_q31e_norm=. if id_alex=="cj_French_0_238_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 4.2 //
replace cj_q31e_norm=. if id_alex=="cj_French_0_963_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 4.2 //
replace cj_q42c_norm=. if id_alex=="cj_French_0_238_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 4.2 //
replace cj_q42d_norm=. if id_alex=="cj_English_1_889_2017_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 4.2 //
replace cj_q42d_norm=. if id_alex=="cj_English_1_889_2017_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 4.2 //
replace all_q72_norm=. if id_alex=="cc_French_0_413_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 7.1 (Q) //
replace all_q74_norm=. if id_alex=="cc_French_0_1619" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 7.1 (Q) //
replace all_q75_norm=. if id_alex=="cc_French_0_1619" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 7.1 (Q) //
replace all_q76_norm=. if id_alex=="cc_French_0_782" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 7.2 //
replace cc_q11a_norm=. if id_alex=="cc_French_0_782" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 7.4 //
replace cc_q11a_norm=. if id_alex=="cc_French_0_1631_2017_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 7.4 //
replace all_q3_norm=. if id_alex=="cc_French_0_1619" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 7.4 //
replace all_q4_norm=. if id_alex=="cc_French_0_1619" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 7.4 //
replace all_q7_norm=. if id_alex=="cc_French_0_1619" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 7.4 //
replace all_q84_norm=. if id_alex=="lb_French_0_634_2014_2016_2017_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 7.5 (Q) //
replace all_q85_norm=. if id_alex=="lb_French_0_526_2016_2017_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 7.5 (Q) //
replace all_q85_norm=. if id_alex=="lb_French_0_526_2016_2017_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 7.5 (Q) //
replace cc_q13_norm=. if id_alex=="cc_French_0_499" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 7.5 (Q) //
replace cc_q13_norm=. if id_alex=="cc_French_1_975" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 7.5 (Q) //
replace all_q84_norm=. if id_alex=="cc_French_0_819" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 7.5 (Q) //
replace cc_q13_norm=. if id_alex=="cc_French_0_819" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 7.5 (Q) //
replace cj_q40b_norm=. if id_alex=="cj_French_0_617_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 8.6 (Q) //
replace cj_q40c_norm=. if id_alex=="cj_French_0_617_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 8.6 (Q) //
replace cj_q20m_norm=. if id_alex=="cj_French_0_617_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 8.6 (Q) //

*Cambodia
replace all_q85_norm=. if id_alex=="cc_English_0_1902" //Cambodia: Highest score for this question. Big increase in score for 7.5.
replace all_q88_norm=. if all_q88_norm==1 & country=="Cambodia" //Cambodia: Removing highest scores for this question. Big increase in score for 7.5.
replace all_q22_norm=. if id_alex=="cj_English_1_863_2017_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q23_norm=. if id_alex=="cj_English_1_863_2017_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q24_norm=. if id_alex=="cj_English_1_863_2017_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q25_norm=. if id_alex=="cj_English_1_863_2017_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q26_norm=. if id_alex=="cj_English_1_863_2017_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q27_norm=. if id_alex=="cj_English_1_863_2017_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q8_norm=. if id_alex=="cj_English_1_863_2017_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q22_norm=. if id_alex=="cj_English_1_452_2017_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q23_norm=. if id_alex=="cj_English_1_452_2017_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q24_norm=. if id_alex=="cj_English_1_452_2017_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q25_norm=. if id_alex=="cj_English_1_452_2017_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q26_norm=. if id_alex=="cj_English_1_452_2017_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q27_norm=. if id_alex=="cj_English_1_452_2017_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q8_norm=. if id_alex=="cj_English_1_452_2017_2018_2019_2021_2022_2023" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q22_norm=. if id_alex=="cc_English_0_1902" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q23_norm=. if id_alex=="cc_English_0_1902" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q24_norm=. if id_alex=="cc_English_0_1902" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q25_norm=. if id_alex=="cc_English_0_1902" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q26_norm=. if id_alex=="cc_English_0_1902" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q27_norm=. if id_alex=="cc_English_0_1902" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q8_norm=. if id_alex=="cc_English_0_1902" //Burkina Faso - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //

*Cameroon
replace ph_q6b_norm=. if country=="Cameroon" //Cameroon: Highest score in sub-sub-factor. Removed last year.
replace ph_q6d_norm=. if country=="Cameroon" //Cameroon: Highest score in sub-sub-factor. Removed last year.
replace ph_q6e_norm=. if country=="Cameroon" //Cameroon: Highest score in sub-sub-factor. Removed last year.
replace ph_q5a_norm=. if country=="Cameroon" //Cameroon: Highest score in sub-sub-factor. Removed last year.
replace cc_q27_norm=. if country=="Cameroon" //Cameroon: Highest score in sub-sub-factor. Removed last year.
foreach v in cc_q9c_norm cc_q40a_norm {
	replace `v'=. if `v'==1 & country=="Cameroon" //Cameroon: Scores of 1 for two experts. Outliers
}
replace cc_q26b_norm=. if id_alex=="cc_French_1_789" //Cameroon: Expert with hightest score in this question. Outlier
drop if id_alex=="cj_English_0_609_2019_2021_2022_2023" //Cameroon: 
foreach v in cj_q12c_norm cj_q12d_norm cj_q20o_norm {
	replace `v'=. if id_alex=="cj_English_0_878" //Cameroon: Lowest expert for this sub-factor. Dropping 0s for this expert
}
replace cc_q39b_norm=. if id_alex=="cc_English_0_697" //Cameroon - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39b_norm=. if id_alex=="cc_English_1_465_2022_2023" //Cameroon - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cj_q11b_norm=. if id_alex=="cj_English_1_570" //Cameroon - reduzco el cambio negativo en la pregunta  - 4.2 //
replace cj_q11b_norm=. if id_alex=="cj_English_1_859_2022_2023" //Cameroon - reduzco el cambio negativo en la pregunta  - 4.2 //
replace cj_q31e_norm=. if id_alex=="cj_English_1_859_2022_2023" //Cameroon - reduzco el cambio negativo en la pregunta  - 4.2 //
replace all_q14_norm=. if id_alex=="cc_French_0_1389_2022_2023" //Cameroon - reduzco el cambio negativo en la pregunta  - 4.4 //
replace all_q94_norm=. if id_alex=="cc_French_0_734_2023" //Cameroon - reduzco el cambio negativo en la pregunta  - 4.4 //
replace all_q94_norm=. if id_alex=="cc_French_0_669" //Cameroon - reduzco el cambio negativo en la pregunta  - 4.4 //
replace all_q29_norm=. if id_alex=="cj_English_0_355" //Cameroon - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cj_English_0_57_2023" //Cameroon - reduzco el cambio negativo en la pregunta  - 4.5 //
replace lb_q2d_norm=. if id_alex=="lb_English_1_744_2023" //Cameroon - reduzco el cambio positivo en la pregunta  - 6.3 //
replace all_q63_norm=. if id_alex=="lb_English_1_744_2023" //Cameroon - reduzco el cambio positivo en la pregunta  - 6.3 //
replace all_q62_norm=. if id_alex=="lb_English_1_699_2023" //Cameroon - reduzco el cambio positivo en la pregunta  - 6.3 //
replace all_q83_norm=. if id_alex=="cc_English_0_697" //Cameroon - reduzco el cambio positivo en la pregunta  - 7.3 //
replace cc_q28e_norm=. if id_alex=="cc_English_1_709" //Cameroon - reduzco el cambio positivo en la pregunta  - 7.3 //
replace cc_q26h_norm=. if id_alex=="cc_French_0_734_2023" //Cameroon - reduzco el cambio positivo en la pregunta  - 7.3 //
replace all_q51_norm=. if id_alex=="cc_English_1_1092" //Cameroon - reduzco el cambio positivo en la pregunta  - 7.3 //
replace all_q28_norm=. if id_alex=="cc_English_1_1092" //Cameroon - reduzco el cambio positivo en la pregunta  - 7.3 //
replace all_q3_norm=. if id_alex=="cc_French_0_1389_2022_2023" //Cameroon - reduzco el cambio negativo en la pregunta  - 7.4 //
replace cc_q26b_norm=. if id_alex=="cc_English_1_1110" //Cameroon - reduzco el cambio positivo en la pregunta  - 7.6 //
replace all_q86_norm=. if id_alex=="lb_English_0_490_2021_2022_2023" //Cameroon - reduzco el cambio positivo en la pregunta  - 7.6 //
replace all_q86_norm=. if id_alex=="lb_English_0_17_2022_2023" //Cameroon - reduzco el cambio positivo en la pregunta  - 7.6 //
replace cj_q20k_norm=. if id_alex=="cj_English_1_279_2019_2021_2022_2023" //Cameroon - reduzco el cambio negativo en la pregunta  - 8.5 //

*Canada
replace all_q80_norm=. if country=="Canada" //Canada: Outlier question for discrimination against immigrants. Score is too low. this question was removed last year too.
replace all_q48_norm=. if id_alex=="lb_French_1_246" //Canada - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q49_norm=. if id_alex=="lb_French_1_246" //Canada - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q50_norm=. if id_alex=="lb_French_1_246" //Canada - reduzco el cambio negativo en la pregunta  - 6.4 //
replace lb_q19a_norm=. if id_alex=="lb_French_1_246" //Canada - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q76_norm=. if id_alex=="cc_English_0_1405_2019_2021_2022_2023" //Canada - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q77_norm=. if id_alex=="cc_English_0_1405_2019_2021_2022_2023" //Canada - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q78_norm=. if id_alex=="cc_English_0_1405_2019_2021_2022_2023" //Canada - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q79_norm=. if id_alex=="cc_English_0_1405_2019_2021_2022_2023" //Canada - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q81_norm=. if id_alex=="cc_English_0_1405_2019_2021_2022_2023" //Canada - reduzco el cambio negativo en la pregunta  - 7.2 //

*Chile
drop if id_alex=="cc_Spanish_1_900" //Chile (muy negativo)
replace all_q80_norm=. if all_q80_norm==0 & country=="Chile" //Chile: Removing 0's from two experts. Outliers for this question
replace all_q78_norm=. if all_q78_norm==0 & country=="Chile" //Chile: Removing 0's from two experts. Outliers for this question
replace all_q48_norm=. if id_alex=="cc_English_1_336_2023" //Chile - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q48_norm=. if id_alex=="lb_Spanish_0_258" //Chile - reduzco el cambio negativo en la pregunta  - 6.4 //
replace lb_q19a_norm=. if id_alex=="lb_Spanish_0_258" //Chile - reduzco el cambio negativo en la pregunta  - 6.4 //
replace lb_q19a_norm=. if id_alex=="lb_Spanish_0_109_2016_2017_2018_2019_2021_2022_2023" //Chile - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q76_norm=. if id_alex=="cc_Spanish_1_1026_2022_2023" //Chile - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q77_norm=. if id_alex=="cc_Spanish_1_1026_2022_2023" //Chile - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q78_norm=. if id_alex=="cc_Spanish_1_1026_2022_2023" //Chile - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q79_norm=. if id_alex=="cc_Spanish_1_1026_2022_2023" //Chile - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q80_norm=. if id_alex=="cc_Spanish_1_1026_2022_2023" //Chile - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q81_norm=. if id_alex=="cc_Spanish_1_1026_2022_2023" //Chile - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q76_norm=. if id_alex=="cc_Spanish_1_582_2023" //Chile - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q77_norm=. if id_alex=="cc_Spanish_1_582_2023" //Chile - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q78_norm=. if id_alex=="cc_Spanish_1_582_2023" //Chile - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q79_norm=. if id_alex=="cc_Spanish_1_582_2023" //Chile - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q80_norm=. if id_alex=="cc_Spanish_1_582_2023" //Chile - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q81_norm=. if id_alex=="cc_Spanish_1_582_2023" //Chile - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q76_norm=. if id_alex=="lb_Spanish_1_502" //Chile - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q77_norm=. if id_alex=="lb_Spanish_1_502" //Chile - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q78_norm=. if id_alex=="lb_Spanish_1_502" //Chile - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q79_norm=. if id_alex=="lb_Spanish_1_502" //Chile - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q80_norm=. if id_alex=="lb_Spanish_1_502" //Chile - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q81_norm=. if id_alex=="lb_Spanish_1_502" //Chile - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q76_norm=. if id_alex=="lb_Spanish_0_256" //Chile - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q77_norm=. if id_alex=="lb_Spanish_0_256" //Chile - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q78_norm=. if id_alex=="lb_Spanish_0_256" //Chile - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q79_norm=. if id_alex=="lb_Spanish_0_256" //Chile - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q80_norm=. if id_alex=="lb_Spanish_0_256" //Chile - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q81_norm=. if id_alex=="lb_Spanish_0_256" //Chile - reduzco el cambio negativo en la pregunta  - 7.2 //

*China
drop if id_alex=="cc_English_0_2011" //China: Highest CC
drop if id_alex=="cj_English_0_187" //China: Highest CJ
drop if id_alex=="ph_English_1_66_2023" //China: Highest PH
drop if id_alex=="cj_English_0_1393" //China: Highest CJ X2
drop if id_alex=="lb_English_0_619" //China: Highest LB
drop if id_alex=="cc_English_0_2017" //China: Highest CC, second
replace cc_q33_norm=. if country=="China" //China: Score of 1.
replace cj_q36c_norm=. if country=="China" //China: Score of 0.  
replace cj_q12c_norm=. if id_alex=="cj_English_1_853" //China: Removing 1's this experts. Outliers for this question
replace cj_q12d_norm=. if id_alex=="cj_English_1_853" //China: Removing 1's this experts. Outliers for this question
replace cj_q12e_norm=. if id_alex=="cj_English_1_853" //China: Removing 1's this experts. Outliers for this question
replace cj_q21a_norm=. if id_alex=="cj_English_1_714_2022_2023" //China: Removing highest score for this question. Outlier for this question
replace cj_q21e_norm=. if id_alex=="cj_English_1_714_2022_2023" //China: Removing highest score for this question. Outlier for this question
replace cj_q21g_norm=. if id_alex=="cj_English_1_853" //China: Removing highest score for this question. Outlier for this question
replace cj_q15_norm=. if id_alex=="cj_English_0_1391" //China: Removing highest score for this question. Outlier for this question
replace cj_q15_norm=. if id_alex=="cj_English_1_560" //China: Removing highest score for this question. Outlier for this question
replace all_q27_norm=. if id_alex=="cc_English_1_94" //China - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q8_norm=. if id_alex=="cc_English_1_94" //China - reduzco el cambio positivo en la pregunta  - 1.7 //
replace cc_q28e_norm=. if id_alex=="cc_English_1_94" //China - reduzco el cambio positivo en la pregunta  - 2.2 //
replace cc_q39b_norm=. if id_alex=="cc_English_1_937_2021_2022_2023" //China - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39d_norm=. if id_alex=="cc_English_1_937_2021_2022_2023" //China - reduzco el cambio positivo en la pregunta  - 3.2 //
replace all_q44_norm=. if id_alex=="cc_English_1_94" //China - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q10_norm=. if id_alex=="cc_English_1_94" //China - reduzco el cambio positivo en la pregunta  - 6.5 //
replace cc_q14a_norm=. if id_alex=="cc_English_1_94" //China - reduzco el cambio positivo en la pregunta  - 6.5 //
replace all_q6_norm=. if id_alex=="cc_English_1_94" //China - reduzco el cambio positivo en la pregunta  - 7.4 //
replace cc_q11a_norm=. if id_alex=="cc_English_1_94" //China - reduzco el cambio positivo en la pregunta  - 7.4 //
replace all_q3_norm=. if id_alex=="cc_English_1_94" //China - reduzco el cambio positivo en la pregunta  - 7.4 //
replace all_q4_norm=. if id_alex=="cc_English_1_94" //China - reduzco el cambio positivo en la pregunta  - 7.4 //
replace all_q7_norm=. if id_alex=="cc_English_1_94" //China - reduzco el cambio positivo en la pregunta  - 7.4 //
replace cj_q16g_norm=. if id_alex=="cj_English_0_375_2013_2014_2016_2017_2018_2019_2021_2022_2023" //China - reduzco el cambio positivo en la pregunta  - 8.1 //
replace cj_q16h_norm=. if id_alex=="cj_English_1_714_2022_2023" //China - reduzco el cambio positivo en la pregunta  - 8.1 //
replace cj_q16i_norm=. if id_alex=="cj_English_0_375_2013_2014_2016_2017_2018_2019_2021_2022_2023" //China - reduzco el cambio positivo en la pregunta  - 8.1 //
replace cj_q18b_norm=. if id_alex=="cj_English_1_714_2022_2023" //China - reduzco el cambio positivo en la pregunta  - 8.1 //
replace cj_q18c_norm=. if id_alex=="cj_English_1_714_2022_2023" //China - reduzco el cambio positivo en la pregunta  - 8.1 //
replace cj_q18e_norm=. if id_alex=="cj_English_1_560" //China - reduzco el cambio positivo en la pregunta  - 8.1 //
replace cj_q25a_norm=. if id_alex=="cj_English_1_714_2022_2023" //China - reduzco el cambio positivo en la pregunta  - 8.1 //
replace cj_q20o_norm=0.3333333 if id_alex=="cj_English_0_905_2023" //China - reduzco el cambio positivo en la pregunta  - 8.4 //

*Colombia
drop if id_alex=="cc_Spanish_0_623" //Colombia (muy negativo)
drop if id_alex=="cj_Spanish_1_72" //Colombia (muy negativo)
replace all_q22_norm=. if all_q22_norm==0 & country=="Colombia" //Colombia: Removing 0's from experts. Outliers for this question
replace all_q24_norm=. if all_q24_norm==0 & country=="Colombia" //Colombia: Removing 0's from experts. Outliers for this question 
replace cc_q33_norm=. if id_alex=="cc_Spanish_1_1345_2023" //Colombia: Removing 0. Outlier
replace all_q25_norm=. if all_q25_norm==0 & country=="Colombia" //Colombia: Removing 0's from experts. Outliers for this question 
replace all_q16_norm=. if all_q16_norm==0  & country=="Colombia" //Colombia: Removing 0's from experts. Outliers for this question 
replace all_q14_norm=. if all_q14_norm==0  & country=="Colombia" //Colombia: Removing 0's from experts. Outliers for this question 
replace all_q17_norm=. if all_q17_norm==0  & country=="Colombia" //Colombia: Removing 0's from experts. Outliers for this question 
replace lb_q2d_norm=. if id_alex=="lb_English_1_327" //Colombia: Removing 0. Outlier
replace lb_q3d_norm=. if id_alex=="lb_English_1_327" //Colombia: Removing 0. Outlier
replace all_q48_norm=. if all_q48_norm==0 & country=="Colombia" //Colombia: Removing 0's from experts. Outliers for this question 
replace lb_q19a_norm=. if id_alex=="lb_Spanish_1_344" //Colombia: Removing 0. Outlier
replace cj_q40b_norm=. if id_alex=="cj_Spanish_1_318" //Colombia: Removing 0. Outlier
replace cj_q24c_norm=. if cj_q24c_norm==1 & country=="Colombia" //Colombia: Removing 1s. Outliers
drop if id_alex=="cj_Spanish_1_461" //Colombia: Highest CJ expert. Outlier
foreach v in cj_q21a_norm cj_q21e_norm cj_q21g_norm cj_q21h_norm cj_q28_norm {
	replace `v'=. if id_alex=="cj_English_0_296" //Colombia: Removing expert's answers (0s). Lowest expert in sub-factor
}
foreach v in cj_q21a_norm cj_q21e_norm cj_q21g_norm cj_q21h_norm cj_q28_norm {
	replace `v'=. if id_alex=="cj_Spanish_1_691_2022_2023" //Colombia: Removing expert's answers (0s). Lowest expert in sub-factor
}
foreach v in cj_q21a_norm cj_q21e_norm cj_q21g_norm cj_q21h_norm cj_q28_norm {
	replace `v'=. if id_alex=="cj_Spanish_1_72" //Colombia: Removing expert's answers (0s). Lowest expert in sub-factor
}
replace all_q10_norm=. if id_alex=="lb_Spanish_1_396_2023" //Colombia - reduzco el cambio positivo en la pregunta  - 1.5 //
replace all_q11_norm=. if id_alex=="lb_Spanish_1_396_2023" //Colombia - reduzco el cambio positivo en la pregunta  - 1.5 //
replace all_q58_norm=. if id_alex=="lb_Spanish_1_352_2017_2018_2019_2021_2022_2023" //Colombia - reduzco el cambio positivo en la pregunta  - 2.2 //
replace cc_q26h_norm=. if id_alex=="cc_Spanish_0_1595_2022_2023" //Colombia - reduzco el cambio positivo en la pregunta  - 2.2 //
replace cj_q32b_norm=. if id_alex=="cj_Spanish_0_561_2022_2023" //Colombia - reduzco el cambio positivo en la pregunta  - 2.2 //
replace cj_q24c_norm=. if id_alex=="cj_Spanish_1_318" //Colombia - reduzco el cambio positivo en la pregunta  - 2.2 //
replace cj_q34a_norm=. if id_alex=="cj_Spanish_0_295" //Colombia - reduzco el cambio positivo en la pregunta  - 2.3 //
replace cj_q34b_norm=. if id_alex=="cj_Spanish_0_295" //Colombia - reduzco el cambio positivo en la pregunta  - 2.3 //
replace cj_q34c_norm=. if id_alex=="cj_Spanish_0_295" //Colombia - reduzco el cambio positivo en la pregunta  - 2.3 //
replace cj_q34d_norm=. if id_alex=="cj_Spanish_0_295" //Colombia - reduzco el cambio positivo en la pregunta  - 2.3 //
replace cj_q34e_norm=. if id_alex=="cj_Spanish_0_295" //Colombia - reduzco el cambio positivo en la pregunta  - 2.3 //
replace cc_q32h_norm=. if id_alex=="cc_Spanish_0_1700_2022_2023" //Colombia - reduzco el cambio positivo en la pregunta  - 3.1 //
replace cc_q32i_norm=. if id_alex=="cc_Spanish_0_1700_2022_2023" //Colombia - reduzco el cambio positivo en la pregunta  - 3.1 //
replace cc_q39c_norm=. if id_alex=="cc_Spanish_0_1595_2022_2023" //Colombia - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39a_norm=. if id_alex=="cc_Spanish_1_1223_2022_2023" //Colombia - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39b_norm=. if id_alex=="cc_Spanish_1_1223_2022_2023" //Colombia - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cj_q31e_norm=. if id_alex=="cj_Spanish_0_733_2023" //Colombia - reduzco el cambio positivo en la pregunta  - 4.2 //
replace cj_q42d_norm=. if id_alex=="cj_Spanish_1_691_2022_2023" //Colombia - reduzco el cambio positivo en la pregunta  - 4.2 //
replace all_q30_norm=. if id_alex=="cc_Spanish_0_1595_2022_2023" //Colombia - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cc_Spanish_0_1700_2022_2023" //Colombia - reduzco el cambio positivo en la pregunta  - 4.5 //
replace lb_q23a_norm=. if id_alex=="lb_Spanish_0_788_2021_2022_2023" //Colombia - reduzco el cambio negativo en la pregunta  - 4.8 //
replace all_q76_norm=. if id_alex=="lb_Spanish_1_344" //Colombia - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q77_norm=. if id_alex=="lb_Spanish_1_344" //Colombia - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q78_norm=. if id_alex=="lb_Spanish_1_344" //Colombia - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q79_norm=. if id_alex=="lb_Spanish_1_344" //Colombia - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q80_norm=. if id_alex=="lb_Spanish_1_344" //Colombia - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q81_norm=. if id_alex=="lb_Spanish_1_344" //Colombia - reduzco el cambio negativo en la pregunta  - 7.2 //
replace cc_q13_norm=. if id_alex=="cc_Spanish_1_1223_2022_2023" //Colombia - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q85_norm=. if id_alex=="cc_Spanish_0_48" //Colombia - reduzco el cambio negativo en la pregunta  - 7.6 //
replace cc_q13_norm=. if id_alex=="cc_Spanish_0_48" //Colombia - reduzco el cambio negativo en la pregunta  - 7.6 //
replace cc_q26b_norm=. if id_alex=="cc_Spanish_1_1223_2022_2023" //Colombia - reduzco el cambio negativo en la pregunta  - 7.6 //
replace all_q89_norm=. if id_alex=="cc_Spanish_0_388_2023" //Colombia - reduzco el cambio negativo en la pregunta  - 7.7 //
replace all_q59_norm=. if id_alex=="cc_Spanish_0_1700_2022_2023" //Colombia - reduzco el cambio negativo en la pregunta  - 7.7 //
replace all_q59_norm=. if id_alex=="cc_Spanish_1_673_2022_2023" //Colombia - reduzco el cambio negativo en la pregunta  - 7.7 //
replace all_q90_norm=. if id_alex=="cc_Spanish_1_1223_2022_2023" //Colombia - reduzco el cambio negativo en la pregunta  - 7.7 //
replace cj_q21a_norm=. if id_alex=="cj_Spanish_0_295" //Colombia - reduzco el cambio negativo en la pregunta  - 8.3 //
replace cj_q21e_norm=. if id_alex=="cj_Spanish_0_295" //Colombia - reduzco el cambio negativo en la pregunta  - 8.3 //
replace cj_q21g_norm=. if id_alex=="cj_Spanish_0_295" //Colombia - reduzco el cambio negativo en la pregunta  - 8.3 //
replace cj_q21h_norm=. if id_alex=="cj_Spanish_0_295" //Colombia - reduzco el cambio negativo en la pregunta  - 8.3 //
replace cj_q28_norm=. if id_alex=="cj_Spanish_0_295" //Colombia - reduzco el cambio negativo en la pregunta  - 8.3 //
replace cj_q20o_norm=. if id_alex=="cj_Spanish_1_318" //Colombia - reduzco el cambio negativo en la pregunta  - 8.4 //

*Congo, Dem. Rep
drop if id_alex=="cj_French_0_428" //Congo, Dem. Rep: Highest CJ 
drop if id_alex=="lb_French_1_73_2022_2023" //Congo, Dem. Rep: Highest LB
drop if id_alex=="cj_English_0_533_2023" //Congo, Dem. Rep: Highest CJ, second
drop if id_alex=="cc_French_0_854" //Congo, Dem. Rep: (muy positivo)
replace cc_q33_norm=. if id_alex=="cc_French_1_1043_2022_2023" //Congo, Dem. Rep - reduzco el cambio positivo en la pregunta  - 1.4 //
replace cj_q38_norm=. if id_alex=="cj_French_0_77" //Congo, Dem. Rep - reduzco el cambio positivo en la pregunta  - 1.4 //
replace cc_q28e_norm=. if id_alex=="cc_French_0_1210_2023" //Congo, Dem. Rep - reduzco el cambio positivo en la pregunta  - 2.2 //
replace all_q96_norm=. if id_alex=="lb_French_0_557_2018_2019_2021_2022_2023" //Congo, Dem. Rep - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q48_norm=. if id_alex=="cc_French_0_553_2023" //Congo, Dem. Rep - reduzco el cambio positivo en la pregunta  - 6.4 //
replace all_q49_norm=. if id_alex=="cc_French_0_553_2023" //Congo, Dem. Rep - reduzco el cambio positivo en la pregunta  - 6.4 //
replace all_q50_norm=. if id_alex=="cc_French_0_553_2023" //Congo, Dem. Rep - reduzco el cambio positivo en la pregunta  - 6.4 //
replace cc_q10_norm=. if id_alex=="cc_French_1_776" //Congo, Dem. Rep - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q11a_norm=. if id_alex=="cc_French_1_776" //Congo, Dem. Rep - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q16a_norm=. if id_alex=="cc_French_1_776" //Congo, Dem. Rep - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q16f_norm=. if id_alex=="cc_French_0_869_2023" //Congo, Dem. Rep - reduzco el cambio negativo en la pregunta  - 6.5 //
replace all_q6_norm=. if id_alex=="cc_French_1_776" //Congo, Dem. Rep - reduzco el cambio negativo en la pregunta  - 7.4 //
replace cc_q11a_norm=. if id_alex=="cc_French_1_776" //Congo, Dem. Rep - reduzco el cambio negativo en la pregunta  - 7.4 //
replace all_q3_norm=. if id_alex=="cc_French_0_978_2023" //Congo, Dem. Rep - reduzco el cambio negativo en la pregunta  - 7.4 //
replace all_q4_norm=. if id_alex=="cc_French_1_776" //Congo, Dem. Rep - reduzco el cambio negativo en la pregunta  - 7.4 //
replace all_q7_norm=. if id_alex=="cc_French_1_776" //Congo, Dem. Rep - reduzco el cambio negativo en la pregunta  - 7.4 //
replace cc_q26b_norm=. if id_alex=="cc_French_0_869_2023" //Congo, Dem. Rep - reduzco el cambio positivo en la pregunta  - 7.6 //
replace all_q89_norm=. if id_alex=="cc_French_1_452" //Congo, Dem. Rep - reduzco el cambio positivo en la pregunta  - 7.6 //
replace all_q59_norm=. if id_alex=="cc_French_1_452" //Congo, Dem. Rep - reduzco el cambio positivo en la pregunta  - 7.6 //
replace all_q90_norm=. if id_alex=="cc_French_1_452" //Congo, Dem. Rep - reduzco el cambio positivo en la pregunta  - 7.6 //

*Congo, Rep
drop if id_alex=="cc_French_0_1345" //Congo, Rep (muy negativo)
drop if id_alex=="cc_French_0_121_2022_2023" //Congo, Rep: Highest CC. Outlier
foreach v in all_q48_norm all_q49_norm {
	replace `v'=. if `v'==0 & country=="Congo, Rep." //Congo, Rep: Removing 0s for two experts. Outliers.
}
replace all_q1_norm=. if id_alex=="cc_French_1_1089_2023" //Congo, Rep - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q21_norm=. if id_alex=="cc_French_1_1089_2023" //Congo, Rep - reduzco el cambio negativo en la pregunta  - 1.2 //
replace cc_q33_norm=. if id_alex=="cc_French_0_746_2021_2022_2023" //Congo, Rep - reduzco el cambio negativo en la pregunta  - 1.4 //
replace cc_q33_norm=. if id_alex=="cc_French_0_302_2022_2023" //Congo, Rep - reduzco el cambio negativo en la pregunta  - 1.4 //
replace all_q29_norm=. if id_alex=="cc_French_0_746_2021_2022_2023" //Congo, Rep - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cc_French_0_746_2021_2022_2023" //Congo, Rep - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cc_French_0_294_2021_2022_2023" //Congo, Rep - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cc_French_0_294_2021_2022_2023" //Congo, Rep - reduzco el cambio positivo en la pregunta  - 4.5 //
replace lb_q23c_norm=. if id_alex=="lb_French_0_652_2023" //Congo, Rep - reduzco el cambio negativo en la pregunta  - 4.8 //
replace cc_q14b_norm=. if id_alex=="cc_French_1_538" //Congo, Rep - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q16d_norm=. if id_alex=="cc_French_0_222" //Congo, Rep - reduzco el cambio negativo en la pregunta  - 6.5 //
replace all_q59_norm=. if id_alex=="cc_French_1_538" //Congo, Rep - reduzco el cambio negativo en la pregunta  - 7.7 //
replace cc_q14a_norm=. if id_alex=="cc_French_1_538" //Congo, Rep - reduzco el cambio negativo en la pregunta  - 7.7 //
replace cc_q14b_norm=. if id_alex=="cc_French_1_538" //Congo, Rep - reduzco el cambio negativo en la pregunta  - 7.7 //

*Costa Rica
drop if id_alex=="cc_Spanish_0_196_2023" //Costa Rica (muy negativo)
replace cj_q32d_norm=. if country=="Costa Rica" //Costa Rica: No military
replace cc_q33_norm=. if id_alex=="cc_Spanish_1_256" //Costa Rica: Removing 0 for an expert. Outliers
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="lb_Spanish_1_507_2021_2022_2023" //Costa Rica: Dropping 0s. Outlier in all questions
	}	
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="lb_Spanish_1_510_2023" //Costa Rica: Dropping 0s. Outlier in all questions
	}
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="cc_Spanish_1_1000" //Costa Rica: Dropping 0s. Outlier in all questions
	}	
drop if id_alex=="cc_English_0_974" //Costa Rica: Lowest CC
foreach v in all_q76_norm all_q77_norm all_q78_norm all_q79_norm all_q80_norm all_q81_norm all_q82_norm {
	replace `v'=. if id_alex=="cc_Spanish_0_200" //Costa Rica: Dropping 0s. Outlier in all questions
}
foreach v in all_q76_norm all_q77_norm all_q78_norm all_q79_norm all_q80_norm all_q81_norm all_q82_norm {
	replace `v'=. if id_alex=="lb_Spanish_0_497_2018_2019_2021_2022_2023" //Costa Rica: Dropping 0s. Outlier in all questions
}
foreach v in all_q76_norm all_q77_norm all_q78_norm all_q79_norm all_q80_norm all_q81_norm all_q82_norm {
	replace `v'=. if id_alex=="lb_Spanish_0_307_2023" //Costa Rica: Dropping 0s. Outlier in all questions
}
foreach v in cc_q39a_norm cc_q39b_norm cc_q39d_norm {
	replace `v'=. if id_alex=="cc_Spanish_1_1000" //Costa Rica: Dropping 0s. Outlier in all questions
}
replace cc_q39d_norm=. if id_alex=="cc_Spanish_1_302_2022_2023" //Costa Rica - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q46_norm=. if id_alex=="cc_Spanish_1_360_2023" //Costa Rica - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q29_norm=. if id_alex=="cc_Spanish_1_360_2023" //Costa Rica - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cj_English_1_801_2019_2021_2022_2023" //Costa Rica - reduzco el cambio negativo en la pregunta  - 4.5 //
replace cc_q26h_norm=. if id_alex=="cc_Spanish_1_360_2023" //Costa Rica - reduzco el cambio negativo en la pregunta  - 7.3 //
replace cc_q28e_norm=. if id_alex=="cc_Spanish_1_360_2023" //Costa Rica - reduzco el cambio negativo en la pregunta  - 7.3 //
replace all_q88_norm=. if id_alex=="cc_Spanish_1_1228_2022_2023" //Costa Rica - reduzco el cambio positivo en la pregunta  - 7.5 //
replace cc_q26b_norm=. if id_alex=="cc_English_0_441_2023" //Costa Rica - reduzco el cambio negativo en la pregunta  - 7.6 //
replace cc_q26b_norm=. if id_alex=="cc_English_0_899_2023" //Costa Rica - reduzco el cambio negativo en la pregunta  - 7.6 //

*Côte d'Ivoire
drop if id_alex=="cc_French_0_607" //Cote d'Ivoire (muy negativo)
replace cc_q39a_norm=. if id_alex=="cc_French_0_1703" //Cote d'Ivoire - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39b_norm=. if id_alex=="cc_French_0_1703" //Cote d'Ivoire - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39c_norm=. if id_alex=="cc_French_0_1703" //Cote d'Ivoire - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39d_norm=. if id_alex=="cc_French_0_1703" //Cote d'Ivoire - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39e_norm=. if id_alex=="cc_French_0_1703" //Cote d'Ivoire - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q9c_norm=. if id_alex=="cc_French_1_1216_2023" //Cote d'Ivoire - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cc_q40a_norm=. if id_alex=="cc_French_1_1216_2023" //Cote d'Ivoire - reduzco el cambio negativo en la pregunta  - 3.4 //
replace all_q30_norm=. if id_alex=="cj_French_1_793_2022_2023" //Cote d'Ivoire - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cc_French_0_590_2023" //Cote d'Ivoire - reduzco el cambio negativo en la pregunta  - 4.5 //
replace cc_q14a_norm=. if id_alex=="cc_French_0_562_2022_2023" //Cote d'Ivoire - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q14b_norm=. if id_alex=="cc_French_0_562_2022_2023" //Cote d'Ivoire - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q26b_norm=. if id_alex=="cc_French_0_1703" //Cote d'Ivoire - reduzco el cambio negativo en la pregunta  - 7.6 //

*Croatia
drop if id_alex=="cc_English_0_871" //Croatia: Lowest CC
drop if id_alex=="cc_English_0_228" //Croatia: Lowest CC, 2
drop if id_alex=="cc_English_0_647" //Croatia: Lowest CC, 3
replace all_q80_norm=. if country=="Croatia" //Croatia
drop if id_alex=="cc_English_1_592" //Croatia: Lowest CC, 4
drop if id_alex=="cc_English_0_450" //Croatia: Lowest CC, 5
drop if id_alex=="cc_English_0_556" //Croatia: Lowest CC, 6
drop if id_alex=="cc_English_0_1240_2023" //Croatia: Lowest CC, 7
drop if id_alex=="cc_English_0_1582" //Croatia: Lowest CC, 8
drop if id_alex=="cc_English_0_1209" //Croatia (muy negativo)
drop if id_alex=="cj_English_0_754" //Croatia (muy negativo)
drop if id_alex=="cc_English_0_826" //Croatia (muy negativo)
drop if id_alex=="lb_English_0_129" //Croatia (muy negativo)
replace all_q13_norm=. if id_alex=="cj_English_0_1028_2022_2023" //Croatia: Removing low scores. 
replace all_q13_norm=. if id_alex=="cj_English_0_1069" //Croatia: Removing low scores. 
replace all_q14_norm=. if id_alex=="cj_English_1_603" //Croatia: Removing low scores. 
replace all_q14_norm=. if id_alex=="cj_English_1_444" //Croatia: Removing low scores. 
replace all_q14_norm=. if id_alex=="cj_English_0_1028_2022_2023" //Croatia: Removing low scores. 
replace all_q15_norm=. if id_alex=="cj_English_0_1028_2022_2023" //Croatia: Removing low scores. 
replace all_q15_norm=. if id_alex=="cj_English_1_444" //Croatia: Removing low scores. 
replace all_q16_norm=. if id_alex=="cj_English_0_1028_2022_2023" //Croatia: Removing low scores. 
replace all_q17_norm=. if id_alex=="cj_English_1_140_2023" //Croatia: Removing low scores. 
replace all_q17_norm=. if id_alex=="cj_English_0_1028_2022_2023" //Croatia: Removing low scores. 
replace all_q18_norm=. if id_alex=="cj_English_0_1028_2022_2023" //Croatia: Removing low scores. 
replace all_q94_norm=. if all_q94_norm==0 & country=="Croatia" //Croatia: Removing low scores. 
replace all_q20_norm=. if id_alex=="cj_English_0_1028_2022_2023" //Croatia: Removing low scores. 
foreach v in all_q31_norm all_q32_norm {
	replace `v'=. if id_alex=="cj_English_1_603" //Croatia: Removing low scores. Outlier in sub-factor
}
replace cc_q9a_norm=. if id_alex=="cc_English_0_315" //Croatia: Removing 0
foreach v in  cc_q40a_norm cc_q40b_norm {
	replace `v'=. if id_alex=="cc_English_0_1209" //Croatia: Removing low scores. Outlier in sub-factor
}
replace all_q29_norm=. if all_q29_norm==0 & country=="Croatia" //Croatia: Removing 0s.
replace all_q30_norm=. if id_alex=="cj_English_1_603" //Croatia: Removing 0s.
foreach v in cj_q31f_norm cj_q42d_norm {
	replace `v'=. if id_alex=="cj_English_0_776" //Croatia: Removing 1s
}
replace all_q76_norm=. if id_alex=="cc_English_0_1359" //Croatia: Removing 0s
replace all_q78_norm=. if id_alex=="lb_English_0_129" //Croatia: Removing 0s
replace all_q79_norm=. if id_alex=="lb_English_0_129" //Croatia: Removing 0s
replace all_q82_norm=. if id_alex=="cc_English_0_826" //Croatia: Removing 0s

foreach v in cj_q12a_norm cj_q12b_norm cj_q12c_norm cj_q12d_norm cj_q12e_norm cj_q12f_norm cj_q20o_norm {
	replace `v'=. if id_alex=="cj_English_0_776" //Croatia: Removing 1s. Outlier in sub-factor
}
replace cj_q20o_norm=. if id_alex=="cj_English_0_1028_2022_2023" //Croatia: Removing 1s. Outlier in question
replace all_q1_norm=. if id_alex=="cj_English_0_1028_2022_2023" //Croatia - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q1_norm=. if id_alex=="cj_English_1_357_2022_2023" //Croatia - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q1_norm=. if id_alex=="cj_English_1_428" //Croatia - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q2_norm=. if id_alex=="cc_English_0_315" //Croatia - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q2_norm=. if id_alex=="cj_English_0_821" //Croatia - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q2_norm=. if id_alex=="lb_English_1_360" //Croatia - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q5_norm=. if id_alex=="cj_English_0_251" //Croatia - reduzco el cambio negativo en la pregunta  - 1.3 //
replace cc_q33_norm=. if id_alex=="cc_English_1_1504_2022_2023" //Croatia - reduzco el cambio negativo en la pregunta  - 1.4 //
replace cc_q33_norm=. if id_alex=="cc_English_1_462_2022_2023" //Croatia - reduzco el cambio negativo en la pregunta  - 1.4 //
replace cj_q8_norm=. if id_alex=="cj_English_1_428" //Croatia - reduzco el cambio negativo en la pregunta  - 1.4 //
replace all_q22_norm=. if id_alex=="cj_English_0_1028_2022_2023" //Croatia - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q23_norm=. if id_alex=="cj_English_0_1028_2022_2023" //Croatia - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q24_norm=. if id_alex=="cj_English_0_1028_2022_2023" //Croatia - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q25_norm=. if id_alex=="cj_English_0_1028_2022_2023" //Croatia - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q26_norm=. if id_alex=="cj_English_0_1028_2022_2023" //Croatia - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q27_norm=. if id_alex=="cj_English_0_1028_2022_2023" //Croatia - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q8_norm=. if id_alex=="cj_English_0_1028_2022_2023" //Croatia - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q24_norm=1 if id_alex=="cj_English_1_603" //Croatia - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q25_norm=1 if id_alex=="cj_English_1_603" //Croatia - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q94_norm=. if id_alex=="cj_English_0_1028_2022_2023" //Croatia - reduzco el cambio negativo en la pregunta  - 3.3 //
replace all_q21_norm=. if id_alex=="cj_English_0_1028_2022_2023" //Croatia - reduzco el cambio negativo en la pregunta  - 3.3 //
replace all_q13_norm=. if id_alex=="cj_English_1_603" //Croatia - reduzco el cambio negativo en la pregunta  - 3.3 //
replace all_q14_norm=. if id_alex=="cj_English_1_603" //Croatia - reduzco el cambio negativo en la pregunta  - 3.3 //
replace all_q18_norm=. if id_alex=="cj_English_1_603" //Croatia - reduzco el cambio negativo en la pregunta  - 3.3 //
replace all_q94_norm=. if id_alex=="cj_English_1_603" //Croatia - reduzco el cambio negativo en la pregunta  - 3.3 //
replace all_q20_norm=. if id_alex=="cj_English_1_603" //Croatia - reduzco el cambio negativo en la pregunta  - 3.3 //
replace all_q21_norm=. if id_alex=="cj_English_1_603" //Croatia - reduzco el cambio negativo en la pregunta  - 3.3 //
replace cc_q9a_norm=. if id_alex=="cc_English_0_1555" //Croatia - reduzco el cambio negativo en la pregunta  - 3.3 //
replace cc_q9a_norm=. if id_alex=="cc_English_0_1359" //Croatia - reduzco el cambio negativo en la pregunta  - 3.3 //
replace all_q105_norm=. if id_alex=="cc_English_0_1555" //Croatia - reduzco el cambio negativo en la pregunta  - 3.3 //
replace all_q105_norm=. if id_alex=="cc_English_0_1359" //Croatia - reduzco el cambio negativo en la pregunta  - 3.3 //
replace all_q31_norm=. if id_alex=="cj_English_0_1069" //Croatia - reduzco el cambio negativo en la pregunta  - 3.3 //
replace all_q32_norm=. if id_alex=="cj_English_0_1069" //Croatia - reduzco el cambio negativo en la pregunta  - 3.3 //
replace all_q31_norm=. if id_alex=="cj_English_1_444" //Croatia - reduzco el cambio negativo en la pregunta  - 3.3 //
replace all_q32_norm=. if id_alex=="cj_English_1_444" //Croatia - reduzco el cambio negativo en la pregunta  - 3.3 //
replace cc_q9c_norm=. if id_alex=="cc_English_1_737_2023" //Croatia - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cc_q9c_norm=. if id_alex=="cc_English_0_315" //Croatia - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cc_q40a_norm=. if id_alex=="cc_English_1_249_2022_2023" //Croatia - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cc_q40a_norm=. if id_alex=="cc_English_1_650_2023" //Croatia - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cc_q40a_norm=1 if id_alex=="cc_English_1_230_2023" //Croatia - reduzco el cambio negativo en la pregunta  - 3.4 //
replace all_q30_norm=. if id_alex=="cj_English_0_1337" //Croatia - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cj_English_0_1069" //Croatia - reduzco el cambio negativo en la pregunta  - 4.5 //
replace cj_q31f_norm=. if id_alex=="cj_English_0_821" //Croatia - reduzco el cambio positivo en la pregunta  - 4.6 //
replace cj_q31g_norm=. if id_alex=="cj_English_0_821" //Croatia - reduzco el cambio positivo en la pregunta  - 4.6 //
replace cj_q31f_norm=. if id_alex=="cj_English_0_251" //Croatia - reduzco el cambio positivo en la pregunta  - 4.6 //
replace cj_q31g_norm=. if id_alex=="cj_English_0_251" //Croatia - reduzco el cambio positivo en la pregunta  - 4.6 //
replace all_q31_norm=1 if id_alex=="cc_English_1_230_2023" //Croatia - reduzco el cambio negativo en la pregunta  - 4.7 //
replace all_q32_norm=1 if id_alex=="cc_English_1_230_2023" //Croatia - reduzco el cambio negativo en la pregunta  - 4.7 //
replace all_q14_norm=1 if id_alex=="cc_English_1_230_2023" //Croatia - reduzco el cambio negativo en la pregunta  - 4.7 //
replace all_q31_norm=1 if id_alex=="cc_English_0_805_2023" //Croatia - reduzco el cambio negativo en la pregunta  - 4.7 //
replace all_q32_norm=1 if id_alex=="cc_English_0_805_2023" //Croatia - reduzco el cambio negativo en la pregunta  - 4.7 //
replace all_q14_norm=1 if id_alex=="cc_English_0_805_2023" //Croatia - reduzco el cambio negativo en la pregunta  - 4.7 //
replace all_q19_norm=1 if id_alex=="cc_English_0_1916" //Croatia - reduzco el cambio negativo en la pregunta  - 4.7 //
replace all_q31_norm=1 if id_alex=="cc_English_0_1916" //Croatia - reduzco el cambio negativo en la pregunta  - 4.7 //
replace all_q32_norm=1 if id_alex=="cc_English_0_1916" //Croatia - reduzco el cambio negativo en la pregunta  - 4.7 //
replace all_q14_norm=1 if id_alex=="cc_English_0_1916" //Croatia - reduzco el cambio negativo en la pregunta  - 4.7 //
replace cj_q15_norm=. if id_alex=="cj_English_0_776" //Croatia - reduzco el cambio negativo en la pregunta  - 5.3 //
replace cj_q15_norm=. if id_alex=="cj_English_0_184" //Croatia - reduzco el cambio negativo en la pregunta  - 5.3 //
replace all_q55_norm=. if id_alex=="lb_English_0_629_2023" //Croatia - reduzco el cambio negativo en la pregunta  - 6.2 //
replace cc_q11a_norm=. if id_alex=="cc_English_1_230_2023" //Croatia - reduzco el cambio negativo en la pregunta  - 6.5 //
replace all_q76_norm=1 if id_alex=="cc_English_0_1996" //Croatia - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q77_norm=1 if id_alex=="cc_English_0_1996" //Croatia - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q78_norm=1 if id_alex=="cc_English_0_1996" //Croatia - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q79_norm=1 if id_alex=="cc_English_0_1996" //Croatia - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q84_norm=. if id_alex=="cc_English_0_1359" //Croatia - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q85_norm=. if id_alex=="cc_English_0_1359" //Croatia - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q26a_norm=. if id_alex=="cc_English_0_1359" //Croatia - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q26a_norm=. if id_alex=="cc_English_0_805_2023" //Croatia - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q26b_norm=. if id_alex=="cc_English_0_394" //Croatia - reduzco el cambio negativo en la pregunta  - 7.6 //
replace all_q86_norm=. if id_alex=="lb_English_0_371_2023" //Croatia - reduzco el cambio negativo en la pregunta  - 7.6 //
replace all_q86_norm=. if id_alex=="lb_English_0_448" //Croatia - reduzco el cambio negativo en la pregunta  - 7.6 //
replace all_q87_norm=. if id_alex=="lb_English_0_448" //Croatia - reduzco el cambio negativo en la pregunta  - 7.6 //
replace cc_q26b_norm=. if id_alex=="cc_English_0_261" //Croatia - reduzco el cambio negativo en la pregunta  - 7.6 //
replace all_q86_norm=. if id_alex=="cc_English_0_261" //Croatia - reduzco el cambio negativo en la pregunta  - 7.6 //
replace all_q87_norm=. if id_alex=="cc_English_0_261" //Croatia - reduzco el cambio negativo en la pregunta  - 7.6 //
replace all_q59_norm=. if id_alex=="cc_English_0_315" //Croatia - reduzco el cambio negativo en la pregunta  - 7.7 //
replace all_q59_norm=. if id_alex=="cc_English_0_1359" //Croatia - reduzco el cambio negativo en la pregunta  - 7.7 //
replace all_q90_norm=. if id_alex=="lb_English_0_629_2023" //Croatia - reduzco el cambio negativo en la pregunta  - 7.7 //
replace all_q91_norm=. if id_alex=="lb_English_0_629_2023" //Croatia - reduzco el cambio negativo en la pregunta  - 7.7 //
replace cj_q32b_norm=. if id_alex=="cj_English_1_603" //Croatia - reduzco el cambio negativo en la pregunta  - 8.5 //
replace cj_q20k_norm=. if id_alex=="cj_English_1_603" //Croatia - reduzco el cambio negativo en la pregunta  - 8.5 //

*Cyprus
drop if id_alex=="cc_English_0_962" //Cyprus: Lowest CC
drop if id_alex=="cc_English_0_1520" //Cyprus (muy negativo)
replace cc_q26b_norm=. if id_alex=="cc_English_1_96" //Cyprus
replace all_q84_norm=. if all_q84_norm==0 & country=="Cyprus" //Cyprus
replace cc_q13_norm=. if cc_q13_norm==0 & country=="Cyprus" //Cyprus
drop if id_alex=="cj_English_0_637" //Cyprus: Lowest CJ
foreach v in cj_q11a_norm cj_q11b_norm cj_q31e_norm cj_q42c_norm cj_q42d_norm cj_q10_norm {
	replace `v'=. if id_alex=="cj_English_0_1068_2021_2022_2023" //Cyprus: Removing 1s. Outlier in sub-factor
}
replace cj_q31f_norm=. if id_alex=="cj_English_0_588" //Cyprus: Removing low score in question.
replace lb_q2d_norm=. if id_alex=="lb_English_0_449" //Cyprus: Removing low score in question.
replace all_q62_norm=. if all_q62_norm==0 & country=="Cyprus" //Cyprus: Removing 0s
replace all_q63_norm=. if country=="Cyprus" //Cyprus: Low question in sub-factor
replace all_q80_norm=. if all_q80_norm==0 & country=="Cyprus" //Cyprus: Removing 0s
replace all_q82_norm=. if id_alex=="cc_English_1_703_2023" //Cyprus: Removing 0 in question. Outlier.
replace cc_q26b_norm=. if country=="Cyprus" //Cyprus: Low question in sub-factor
replace cj_q21a_norm=. if id_alex=="cj_English_0_1005" //Cyprus: Removing low score
replace cj_q21h_norm=. if id_alex=="cj_English_0_588" //Cyprus: Removing low score
replace cj_q38_norm=. if id_alex=="cj_English_0_768" //Cyprus - reduzco el cambio positivo en la pregunta  - 1.4 //
replace cj_q36c_norm=. if id_alex=="cj_English_0_768" //Cyprus - reduzco el cambio positivo en la pregunta  - 1.4 //
replace cj_q38_norm=. if id_alex=="cj_English_0_843_2021_2022_2023" //Cyprus - reduzco el cambio positivo en la pregunta  - 1.4 //
replace all_q58_norm=. if id_alex=="cc_English_0_769" //Cyprus - reduzco el cambio negativo en la pregunta  - 2.2 //
replace all_q28_norm=. if id_alex=="lb_English_0_119_2021_2022_2023" //Cyprus - reduzco el cambio negativo en la pregunta  - 2.2 //
replace cj_q33c_norm=. if id_alex=="cj_English_0_301_2021_2022_2023" //Cyprus - reduzco el cambio negativo en la pregunta  - 2.2 //
replace cj_q32c_norm=. if id_alex=="cj_English_0_1005" //Cyprus - reduzco el cambio negativo en la pregunta  - 2.3 //
replace cj_q34d_norm=. if id_alex=="cj_English_0_1005" //Cyprus - reduzco el cambio negativo en la pregunta  - 2.3 //
replace all_q96_norm=. if id_alex=="cc_English_0_672_2022_2023" //Cyprus - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cj_English_0_843_2021_2022_2023" //Cyprus - reduzco el cambio positivo en la pregunta  - 2.4 //
replace cc_q39a_norm=. if id_alex=="cc_English_0_633" //Cyprus - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39b_norm=. if id_alex=="cc_English_0_633" //Cyprus - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39c_norm=. if id_alex=="cc_English_0_633" //Cyprus - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39d_norm=. if id_alex=="cc_English_0_633" //Cyprus - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39d_norm=. if id_alex=="cc_English_1_1102" //Cyprus - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39d_norm=. if id_alex=="cc_English_0_282" //Cyprus - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39b_norm=. if id_alex=="cc_English_0_1673_2022_2023" //Cyprus - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q9a_norm=. if id_alex=="cc_English_0_769" //Cyprus - reduzco el cambio negativo en la pregunta  - 3.3 //
replace cc_q9a_norm=. if id_alex=="cc_English_1_1102" //Cyprus - reduzco el cambio negativo en la pregunta  - 3.3 //
replace cc_q40a_norm=. if id_alex=="cc_English_1_1102" //Cyprus - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cc_q9c_norm=. if id_alex=="cc_English_1_1102" //Cyprus - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cj_q11a_norm=. if id_alex=="cj_English_0_1005" //Cyprus - reduzco el cambio positivo en la pregunta  - 4.2 //
replace cj_q11b_norm=. if id_alex=="cj_English_0_1005" //Cyprus - reduzco el cambio positivo en la pregunta  - 4.2 //
replace cj_q31e_norm=. if id_alex=="cj_English_0_1005" //Cyprus - reduzco el cambio positivo en la pregunta  - 4.2 //
replace cj_q42c_norm=. if id_alex=="cj_English_0_1005" //Cyprus - reduzco el cambio positivo en la pregunta  - 4.2 //
replace cj_q42d_norm=. if id_alex=="cj_English_0_1005" //Cyprus - reduzco el cambio positivo en la pregunta  - 4.2 //
replace cj_q10_norm=. if id_alex=="cj_English_0_1005" //Cyprus - reduzco el cambio positivo en la pregunta  - 4.2 //
replace cj_q6c_norm=. if id_alex=="cj_English_0_1015" //Cyprus - reduzco el cambio positivo en la pregunta  - 4.3 //
replace cj_q6d_norm=. if id_alex=="cj_English_0_1015" //Cyprus - reduzco el cambio positivo en la pregunta  - 4.3 //
replace cj_q29a_norm=. if id_alex=="cj_English_0_1015" //Cyprus - reduzco el cambio positivo en la pregunta  - 4.3 //
replace cj_q4_norm=. if id_alex=="cj_English_0_1015" //Cyprus - reduzco el cambio positivo en la pregunta  - 4.3 //
replace all_q29_norm=. if id_alex=="cj_English_0_588" //Cyprus - reduzco el cambio negativo en la pregunta  - 4.5 //
replace cj_q31g_norm=1 if id_alex=="cj_English_0_768" //Cyprus - reduzco el cambio negativo en la pregunta  - 4.6 //
replace cj_q31g_norm=.6666667 if id_alex=="cj_English_0_588" //Cyprus - reduzco el cambio negativo en la pregunta  - 4.6 //
replace all_q32_norm=. if id_alex=="cj_English_0_588" //Cyprus - reduzco el cambio negativo en la pregunta  - 4.7 //
replace cj_q15_norm=. if id_alex=="cj_English_0_768" //Cyprus - reduzco el cambio negativo en la pregunta  - 5.3 //
replace cj_q15_norm=. if id_alex=="cj_English_0_1005" //Cyprus - reduzco el cambio negativo en la pregunta  - 5.3 //
replace all_q62_norm=. if id_alex=="cc_English_0_282" //Cyprus - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q62_norm=. if id_alex=="lb_English_0_449" //Cyprus - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q62_norm=. if id_alex=="cc_English_0_633" //Cyprus - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q48_norm=. if id_alex=="cc_English_1_703_2023" //Cyprus - reduzco el cambio negativo en la pregunta  - 6.4 //
replace lb_q19a_norm=. if id_alex=="lb_English_0_57_2021_2022_2023" //Cyprus - reduzco el cambio negativo en la pregunta  - 6.4 //
replace cc_q22a_norm=. if id_alex=="cc_English_0_282" //Cyprus - reduzco el cambio positivo en la pregunta  - 7.1 //
replace cc_q22b_norm=. if id_alex=="cc_English_0_282" //Cyprus - reduzco el cambio positivo en la pregunta  - 7.1 //
replace cc_q22c_norm=. if id_alex=="cc_English_0_282" //Cyprus - reduzco el cambio positivo en la pregunta  - 7.1 //
replace cc_q22a_norm=. if id_alex=="cc_English_1_932" //Cyprus - reduzco el cambio positivo en la pregunta  - 7.1 //
replace cc_q22b_norm=. if id_alex=="cc_English_1_932" //Cyprus - reduzco el cambio positivo en la pregunta  - 7.1 //
replace cc_q22c_norm=. if id_alex=="cc_English_1_932" //Cyprus - reduzco el cambio positivo en la pregunta  - 7.1 //
replace all_q71_norm=. if id_alex=="lb_English_0_57_2021_2022_2023" //Cyprus - reduzco el cambio positivo en la pregunta  - 7.1 //
replace all_q72_norm=. if id_alex=="lb_English_0_57_2021_2022_2023" //Cyprus - reduzco el cambio positivo en la pregunta  - 7.1 //
replace all_q71_norm=. if id_alex=="cc_English_1_933" //Cyprus - reduzco el cambio positivo en la pregunta  - 7.1 //
replace all_q72_norm=. if id_alex=="cc_English_1_933" //Cyprus - reduzco el cambio positivo en la pregunta  - 7.1 //
replace all_q70_norm=. if id_alex=="cc_English_0_1673_2022_2023" //Cyprus - reduzco el cambio positivo en la pregunta  - 7.1 //
replace all_q70_norm=. if id_alex=="cc_English_0_230_2023" //Cyprus - reduzco el cambio positivo en la pregunta  - 7.1 //
replace all_q70_norm=. if id_alex=="cc_English_1_289_2023" //Cyprus - reduzco el cambio positivo en la pregunta  - 7.1 //
replace all_q80_norm=. if id_alex=="cc_English_0_1673_2022_2023" //Cyprus - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q80_norm=. if id_alex=="cc_English_1_1102" //Cyprus - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q28_norm=. if id_alex=="lb_English_0_119_2021_2022_2023" //Cyprus - reduzco el cambio negativo en la pregunta  - 7.3 //
replace cc_q26a_norm=. if id_alex=="cc_English_1_933" //Cyprus - reduzco el cambio positivo en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="cc_English_0_633" //Cyprus - reduzco el cambio positivo en la pregunta  - 7.5 //
replace all_q86_norm=. if id_alex=="cc_English_0_769" //Cyprus - reduzco el cambio positivo en la pregunta  - 7.6 //
replace all_q86_norm=. if id_alex=="cc_English_0_633" //Cyprus - reduzco el cambio positivo en la pregunta  - 7.6 //
replace cj_q20e_norm=. if id_alex=="cj_English_0_843_2021_2022_2023" //Cyprus -   - 8.2 //
replace cj_q21g_norm=. if id_alex=="cj_English_0_588" //Cyprus - reduzco el cambio negativo en la pregunta  - 8.3 //
replace cj_q21g_norm=. if id_alex=="cj_English_0_1015" //Cyprus - reduzco el cambio negativo en la pregunta  - 8.3 //
replace cj_q21h_norm=. if id_alex=="cj_English_0_1015" //Cyprus - reduzco el cambio negativo en la pregunta  - 8.3 //
replace cj_q28_norm=. if id_alex=="cj_English_0_1015" //Cyprus - reduzco el cambio negativo en la pregunta  - 8.3 //
replace cj_q32c_norm=. if id_alex=="cj_English_0_1005" //Cyprus - reduzco el cambio negativo en la pregunta  - 8.5 //

*Czechia
drop if id_alex=="cj_English_0_291" //Czechia: Lowest CJ
drop if id_alex=="cc_English_0_428" //Czechia: Lowest CC 
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="lb_English_0_539" //Czechia: Removing 1s. Outlier in scores
}
foreach v in cc_q9b_norm cc_q39a_norm cc_q39b_norm cc_q39d_norm cc_q39c_norm all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm {
	replace `v'=. if id_alex=="cc_English_0_1283" //Czechia: Removing 1s. Outlier in scores
}
replace cc_q39b_norm=. if id_alex=="cc_English_0_1829" //Czechia: Removing 1 in question. Outliers
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="lb_English_1_556" //Czechia: Removing 1s. Outlier in scores
}
replace all_q76_norm=. if all_q76_norm==0 & country=="Czechia" //Czechia: Removing 0s. Outlier in question
replace all_q80_norm=. if id_alex=="cc_English_1_404_2023" //Czechia: Removing 0. Outlier in question
replace all_q82_norm=. if all_q82_norm==0 & country=="Czechia" //Czechia: Removing 0s. Outlier in question
replace all_q89_norm=. if id_alex=="cc_English_0_1951" //Czechia: Removing 0s. Outlier in question
replace all_q89_norm=. if id_alex=="cc_English_0_1283" //Czechia: Removing 0s. Outlier in question
replace cc_q14a_norm=. if id_alex=="cc_English_0_1829" //Czechia: Removing 0. Outlier in question
replace all_q2_norm=. if id_alex=="cc_English_1_1168_2022_2023" //Czechia - reduzco el cambio positivo en la pregunta  - 1.2 //
replace all_q2_norm=. if id_alex=="cc_English_1_404_2023" //Czechia - reduzco el cambio positivo en la pregunta  - 1.2 //
replace all_q22_norm=. if id_alex=="cc_English_0_1434" //Czechia - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q23_norm=. if id_alex=="cc_English_0_1434" //Czechia - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q24_norm=. if id_alex=="cc_English_0_1434" //Czechia - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q25_norm=. if id_alex=="cc_English_0_1434" //Czechia - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q26_norm=. if id_alex=="cc_English_0_1434" //Czechia - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q27_norm=. if id_alex=="cc_English_0_1434" //Czechia - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q96_norm=. if id_alex=="cj_English_0_828" //Czechia - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_0_1998" //Czechia - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_0_1626" //Czechia - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_0_359" //Czechia - reduzco el cambio positivo en la pregunta  - 2.4 //
replace cc_q39a_norm=. if id_alex=="cc_English_0_1299" //Czechia - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39b_norm=. if id_alex=="cc_English_0_1299" //Czechia - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39c_norm=. if id_alex=="cc_English_0_1299" //Czechia - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39d_norm=. if id_alex=="cc_English_0_1299" //Czechia - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39e_norm=. if id_alex=="cc_English_0_1299" //Czechia - reduzco el cambio positivo en la pregunta  - 3.2 //
replace all_q29_norm=. if id_alex=="cc_English_0_1299" //Czechia - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cc_English_0_1299" //Czechia - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cc_English_0_1998" //Czechia - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cc_English_0_1998" //Czechia - reduzco el cambio positivo en la pregunta  - 4.5 //
replace cj_q31f_norm=. if id_alex=="cj_English_1_431" //Czechia - reduzco el cambio positivo en la pregunta  - 4.6 //
replace cj_q31g_norm=. if id_alex=="cj_English_1_431" //Czechia - reduzco el cambio positivo en la pregunta  - 4.6 //
replace cj_q42c_norm=. if id_alex=="cj_English_1_431" //Czechia - reduzco el cambio positivo en la pregunta  - 4.6 //
replace cj_q42d_norm=. if id_alex=="cj_English_1_431" //Czechia - reduzco el cambio positivo en la pregunta  - 4.6 //
replace lb_q23a_norm=. if id_alex=="lb_English_0_539" //Czechia - reduzco el cambio positivo en la pregunta  - 4.8 //
replace lb_q23b_norm=. if id_alex=="lb_English_0_539" //Czechia - reduzco el cambio positivo en la pregunta  - 4.8 //
replace lb_q23c_norm=. if id_alex=="lb_English_0_539" //Czechia - reduzco el cambio positivo en la pregunta  - 4.8 //
replace lb_q23d_norm=. if id_alex=="lb_English_0_539" //Czechia - reduzco el cambio positivo en la pregunta  - 4.8 //
replace lb_q23e_norm=. if id_alex=="lb_English_0_539" //Czechia - reduzco el cambio positivo en la pregunta  - 4.8 //
replace cj_q15_norm=. if id_alex=="cj_English_0_1333" //Czechia - reduzco el cambio negativo en la pregunta  - 5.3 //
replace lb_q3d_norm=. if id_alex=="lb_English_0_435" //Czechia - reduzco el cambio positivo en la pregunta  - 6.3 //
replace all_q49_norm=. if id_alex=="lb_English_0_435" //Czechia - reduzco el cambio positivo en la pregunta  - 6.4 //
replace all_q49_norm=. if id_alex=="lb_English_0_569" //Czechia - reduzco el cambio positivo en la pregunta  - 6.4 //
replace cc_q16f_norm=. if id_alex=="cc_English_0_1848" //Czechia - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q14a_norm=. if id_alex=="cc_English_1_1223_2023" //Czechia - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q14b_norm=. if id_alex=="cc_English_1_1223_2023" //Czechia - reduzco el cambio negativo en la pregunta  - 6.5 //
replace all_q65_norm=. if id_alex=="cc_English_0_1894" //Czechia - reduzco el cambio negativo en la pregunta  - 7.1 //
replace all_q65_norm=. if id_alex=="cc_English_0_1299" //Czechia - reduzco el cambio negativo en la pregunta  - 7.1 //
replace all_q74_norm=. if id_alex=="cc_English_1_1168_2022_2023" //Czechia - reduzco el cambio negativo en la pregunta  - 7.1 //
replace all_q74_norm=. if id_alex=="cc_English_1_404_2023" //Czechia - reduzco el cambio negativo en la pregunta  - 7.1 //
replace all_q69_norm=. if id_alex=="cc_English_0_1829" //Czechia - reduzco el cambio negativo en la pregunta  - 7.1 //
replace all_q80_norm=. if id_alex=="cc_English_0_1848" //Czechia - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q76_norm=. if id_alex=="lb_English_1_291_2023" //Czechia - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q77_norm=. if id_alex=="lb_English_0_435" //Czechia - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q85_norm=. if id_alex=="cc_English_0_1894" //Czechia - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q26b_norm=. if id_alex=="cc_English_0_1618" //Czechia - reduzco el cambio negativo en la pregunta  - 7.6 //
replace all_q89_norm=. if id_alex=="cc_English_0_359" //Czechia - reduzco el cambio negativo en la pregunta  - 7.7 //
replace all_q90_nor=. if id_alex=="cc_English_0_1848" //Czechia - reduzco el cambio negativo en la pregunta  - 7.7 //
replace cc_q14a_norm=. if id_alex=="cc_English_0_1848" //Czechia - reduzco el cambio negativo en la pregunta  - 7.7 //
replace cc_q14b_norm=. if id_alex=="cc_English_0_1848" //Czechia - reduzco el cambio negativo en la pregunta  - 7.7 //
replace cj_q20o_norm=. if id_alex=="cj_English_0_1333" //Czechia - reduzco el cambio negativo en la pregunta  - 8.4 //
replace cj_q20o_norm=. if id_alex=="cj_English_1_476_2023" //Czechia - reduzco el cambio negativo en la pregunta  - 8.4 //

*Denmark
replace cc_q11b_norm=. if id_alex=="cc_English_1_1293_2023" //Denmark: Removing 0. Outlier
replace all_q29_norm=. if country=="Denmark" /*Denmark*/
foreach v in all_q48_norm all_q49_norm all_q50_norm {
	replace `v'=. if id_alex=="lb_English_1_64" //Denmark: Removing 1s. Highest expert in sub-factor. Outlier
}
replace all_q96_norm=. if id_alex=="cc_English_1_559_2023" //Denmark - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_0_588_2023" //Denmark - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_0_1668" //Denmark - reduzco el cambio negativo en la pregunta  - 2.4 //
replace cc_q9a_norm=. if id_alex=="cc_English_0_194" //Denmark - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q11b_norm=. if id_alex=="cc_English_0_194" //Denmark - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q11b_norm=. if id_alex=="cc_English_0_1218" //Denmark - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q11b_norm=. if id_alex=="cc_English_0_330" //Denmark - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q32j_norm=. if id_alex=="cc_English_1_1131_2023" //Denmark - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q19_norm=. if id_alex=="cc_English_1_1293_2023" //Denmark - reduzco el cambio negativo en la pregunta  - 4.7 //
replace cj_q15_norm=. if id_alex=="cj_English_0_782" //Denmark - reduzco el cambio negativo en la pregunta  - 5.3 //
replace all_q48_norm=. if id_alex=="cc_English_0_1694_2022_2023" //Denmark - reduzco el cambio positivo en la pregunta  - 6.4 //
replace all_q49_norm=. if id_alex=="cc_English_0_1694_2022_2023" //Denmark - reduzco el cambio positivo en la pregunta  - 6.4 //
replace all_q50_norm=. if id_alex=="cc_English_0_1694_2022_2023" //Denmark - reduzco el cambio positivo en la pregunta  - 6.4 //
replace all_q48_norm=. if id_alex=="cc_English_0_1677_2022_2023" //Denmark - reduzco el cambio positivo en la pregunta  - 6.4 //
replace all_q49_norm=. if id_alex=="cc_English_0_1677_2022_2023" //Denmark - reduzco el cambio positivo en la pregunta  - 6.4 //
replace all_q50_norm=. if id_alex=="cc_English_0_1677_2022_2023" //Denmark - reduzco el cambio positivo en la pregunta  - 6.4 //
replace all_q84_norm=. if id_alex=="cc_English_0_559" //Denmark - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q85_norm=. if id_alex=="cc_English_0_559" //Denmark - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q84_norm=. if id_alex=="cc_English_0_1547" //Denmark - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q85_norm=. if id_alex=="cc_English_0_1547" //Denmark - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q26b_norm=. if id_alex=="cc_English_0_1694_2022_2023" //Denmark - reduzco el cambio positivo en la pregunta  - 7.6 //
replace cc_q26b_norm=. if id_alex=="cc_English_0_1677_2022_2023" //Denmark - reduzco el cambio positivo en la pregunta  - 7.6 //
replace cj_q40b_norm=. if id_alex=="cj_English_0_548_2018_2019_2021_2022_2023" //Denmark - reduzco el cambio positivo en la pregunta  - 8.6 //
replace cj_q40c_norm=. if id_alex=="cj_English_0_548_2018_2019_2021_2022_2023" //Denmark - reduzco el cambio positivo en la pregunta  - 8.6 //

*Dominica
drop if id_alex=="cj_English_0_824" //Dominica (muy negativo)
replace cj_q28_norm=. if country=="Dominica" /*Dominica*/
replace lb_q3d_norm=. if id_alex=="lb_English_0_581" //Dominica: Removing 0s. Outlier in this question
replace lb_q2d_norm=. if id_alex=="lb_English_0_581" //Dominica: Removing 0s. Outlier in this question
foreach v in all_q48_norm all_q49_norm all_q50_norm lb_q19a_norm {
	replace `v'=. if id_alex=="lb_English_0_581" //Dominica: Removing 0s. Outlier in all questions
}
replace cj_q26_norm=. if id_alex=="cj_English_0_824" //Dominica: Removing 0s. Outlier in this question
replace all_q74_norm=. if id_alex=="cc_English_0_1439" //Dominica: Removing 0s. Outlier in this question
replace all_q71_norm=. if id_alex=="cc_English_0_1439" //Dominica: Removing 0s. Outlier in this question
foreach v in all_q74_norm all_q75_norm all_q71_norm all_q72_norm {
	replace `v'=. if id_alex=="lb_English_0_581" //Dominica: Dropping 0s. Outlier in all questions
}
foreach v in all_q76_norm all_q77_norm all_q78_norm all_q79_norm all_q80_norm all_q81_norm all_q82_norm {
	replace `v'=. if id_alex=="cc_English_0_1439" //Dominica: Dropping 0s. Outlier in all questions
}
foreach v in all_q84_norm all_q85_norm all_q86_norm {
	replace `v'=. if id_alex=="lb_English_0_581" //Dominica: Dropping 0s. Outlier in all questions
}
replace all_q89_norm=. if id_alex=="lb_English_0_581" //Dominica: Removing 0s. Outlier in this question
replace all_q90_norm=. if id_alex=="lb_English_0_581" //Dominica: Removing 0s. Outlier in this question
replace cj_q20m_norm=. if country=="Dominica" //Dominica: Dropping question. Only 1 answer
replace cc_q33_norm=.5 if id_alex=="cc_English_0_1444_2016_2017_2018_2019_2021_2022_2023" //Dominica - reduzco el cambio positivo en la pregunta  - 1.4 //
replace all_q9_norm=. if id_alex=="cc_French_1_1324_2022_2023" //Dominica - reduzco el cambio positivo en la pregunta  - 1.4 //
replace all_q25_norm=. if id_alex=="cc_English_0_1982" //Dominica - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q25_norm=. if id_alex=="cc_English_0_1439" //Dominica - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q22_norm=. if id_alex=="lb_English_0_581" //Dominica - reduzco el cambio positivo en la pregunta  - 1.7 //
replace cj_q34a_norm=.6666667 if id_alex=="cj_English_0_412_2021_2022_2023" //Dominica - reduzco el cambio positivo en la pregunta  - 2.3 //
replace cj_q34b_norm=.6666667 if id_alex=="cj_English_0_412_2021_2022_2023" //Dominica - reduzco el cambio positivo en la pregunta  - 2.3 //
replace cj_q34d_norm=.6666667 if id_alex=="cj_English_0_412_2021_2022_2023" //Dominica - reduzco el cambio positivo en la pregunta  - 2.3 //
replace all_q96_norm=. if id_alex=="lb_English_0_581" //Dominica - reduzco el cambio positivo en la pregunta  - 2.4 //
*replace all_q96_norm=. if id_alex=="cc_English_0_1439" //Dominica - reduzco el cambio positivo en la pregunta  - 2.4 //
replace cc_q32i_norm=. if id_alex=="cc_English_0_1439" //Dominica - reduzco el cambio positivo en la pregunta  - 3.1 //
replace all_q33_norm=. if id_alex=="cc_English_0_1439" //Dominica - reduzco el cambio positivo en la pregunta  - 3.1 //
replace cc_q9a_norm=. if id_alex=="cc_English_0_1439" //Dominica - reduzco el cambio negativo en la pregunta  - 3.3 //
replace cc_q9c_norm=. if id_alex=="cc_English_0_1439" //Dominica - reduzco el cambio negativo en la pregunta  - 3.4 //
replace ph_q6b_norm=. if id_alex=="ph_English_0_438_2018_2019_2021_2022_2023" //Dominica - reduzco el cambio positivo en la pregunta  - 4.1 //
replace cj_q15_norm=. if id_alex=="cj_English_1_729" //Dominica - reduzco el cambio negativo en la pregunta  - 5.3 //
replace all_q62_norm=. if id_alex=="cc_English_0_1439" //Dominica - reduzco el cambio positivo en la pregunta  - 6.3 //
replace all_q48_norm=. if id_alex=="cc_English_0_1439" //Dominica - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q49_norm=. if id_alex=="cc_English_0_1439" //Dominica - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q50_norm=. if id_alex=="cc_English_0_1439" //Dominica - reduzco el cambio negativo en la pregunta  - 6.4 //
replace cc_q10_norm=. if id_alex=="cc_English_0_1439" //Dominica - reduzco el cambio positivo en la pregunta  - 6.5 //
replace all_q74_norm=. if id_alex=="cc_English_0_907_2016_2017_2018_2019_2021_2022_2023" //Dominica - reduzco el cambio negativo en la pregunta  - 7.1 //
replace all_q88_norm=. if id_alex=="cc_English_0_907_2016_2017_2018_2019_2021_2022_2023" //Dominica - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="cc_English_1_976_2017_2018_2019_2021_2022_2023" //Dominica - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q90_norm=. if id_alex=="cc_English_0_1982" //Dominica - reduzco el cambio negativo en la pregunta  - 7.7 //
replace cc_q14b_norm=. if id_alex=="cc_English_0_1439" //Dominica - reduzco el cambio negativo en la pregunta  - 7.7 //
replace cj_q21h_norm=.2222222 if id_alex=="cj_English_0_412_2021_2022_2023" //Dominica - reduzco el cambio positivo en la pregunta  - 8.3 //
replace cj_q21e_norm=. if id_alex=="cj_English_0_412_2021_2022_2023" //Dominica - reduzco el cambio positivo en la pregunta  - 8.3 //
replace cj_q21g_norm=. if id_alex=="cj_English_0_412_2021_2022_2023" //Dominica - reduzco el cambio positivo en la pregunta  - 8.3 //

*Dominican Republic
drop if id_alex=="lb_Spanish_1_479_2022_2023" //Dominican Republic: Highest LB
drop if id_alex=="lb_Spanish_0_410_2017_2018_2019_2021_2022_2023" //Dominican Republic: Highest LB, second
drop if id_alex=="cc_Spanish_1_1097" //Dominican Republic (muy negativo)
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="cc_Spanish_0_444_2023" //Dominican Republic: Dropping 1s. Outlier in all questions
	}	
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="cc_English_0_699" //Dominican Republic: Dropping 1s. Outlier in all questions
	}	
replace cc_q39c_norm=. if id_alex=="cc_English_0_699" //Dominican Republic: Removing 1s. Outlier in this question
replace cc_q39e_norm=. if id_alex=="cc_English_0_699" //Dominican Republic: Removing 1s. Outlier in this question
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="lb_Spanish_0_579_2018_2019_2021_2022_2023" //Dominican Republic: Dropping 1s. Outlier in all questions
	}	
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="lb_English_1_613_2021_2022_2023" //Dominican Republic: Dropping 1s. Outlier in all questions
	}	
replace all_q43_norm=. if country=="Dominican Republic" //Dominican Republic: Highest question in sub-sub-factor
replace all_q96_norm=. if id_alex=="cj_Spanish_0_809_2023" //Dominican Republic - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cj_Spanish_0_498_2018_2019_2021_2022_2023" //Dominican Republic - reduzco el cambio positivo en la pregunta  - 2.4 //
replace cc_q39a_norm=. if id_alex=="cc_English_1_768" //Dominican Republic - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39b_norm=. if id_alex=="cc_English_1_768" //Dominican Republic - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39c_norm=. if id_alex=="cc_English_1_768" //Dominican Republic - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39d_norm=. if id_alex=="cc_English_1_768" //Dominican Republic - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39e_norm=. if id_alex=="cc_English_1_768" //Dominican Republic - reduzco el cambio positivo en la pregunta  - 3.2 //
replace all_q40_norm=. if id_alex=="cc_English_1_768" //Dominican Republic - reduzco el cambio positivo en la pregunta  - 3.2 //
replace all_q29_norm=. if id_alex=="cj_Spanish_0_810_2019_2021_2022_2023" //Dominican Republic - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cj_Spanish_0_710_2019_2021_2022_2023" //Dominican Republic - reduzco el cambio negativo en la pregunta  - 4.5 //
replace lb_q23b_norm=. if id_alex=="lb_Spanish_0_272_2022_2023" //Dominican Republic - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q23d_norm=. if id_alex=="lb_Spanish_0_272_2022_2023" //Dominican Republic - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q23e_norm=. if id_alex=="lb_Spanish_0_272_2022_2023" //Dominican Republic - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q23f_norm=. if id_alex=="lb_Spanish_0_245_2021_2022_2023" //Dominican Republic - reduzco el cambio negativo en la pregunta  - 4.8 //
replace all_q59_norm=. if id_alex=="lb_Spanish_0_272_2022_2023" //Dominican Republic - reduzco el cambio negativo en la pregunta  - 7.7 //
replace all_q90_norm=. if id_alex=="cc_Spanish_0_778_2023" //Dominican Republic - reduzco el cambio negativo en la pregunta  - 7.7 //

*Ecuador
replace cj_q38_norm=. if id_alex=="cj_Spanish_1_812_2023" //Ecuador: Lowest expert in sub-factor 
replace cj_q36c_norm=. if id_alex=="cj_Spanish_1_812_2023" //Ecuador: Lowest expert in sub-factor 

foreach v in all_q22_norm all_q23_norm all_q24_norm all_q25_norm all_q26_norm all_q27_norm all_q8_norm {
	replace `v'=. if id_alex=="cc_Spanish_0_389_2023" //Ecuador: Highest expert in sub-factor 
}
foreach v in all_q22_norm all_q23_norm all_q24_norm all_q25_norm all_q26_norm all_q27_norm all_q8_norm {
	replace `v'=. if id_alex=="cc_Spanish_1_1302_2022_2023" //Ecuador: Highest expert in sub-factor 
}
foreach v in all_q22_norm all_q23_norm all_q24_norm all_q25_norm all_q26_norm all_q27_norm all_q8_norm {
	replace `v'=. if id_alex=="lb_Spanish_0_24_2023" //Ecuador: Highest expert in sub-factor 
}
drop if id_alex=="cj_Spanish_1_812_2023" //Ecuador: Lowest CJ 
replace cc_q40a_norm=. if id_alex=="cc_Spanish_0_872_2023" //Ecuador: Removing 0s. Outlier in this question
replace cc_q40a_norm=. if id_alex=="cc_Spanish_0_389_2023" //Ecuador: Removing 0s. Outlier in this question
foreach v in all_q29_norm all_q30_norm {
	replace `v'=. if id_alex=="cc_Spanish_1_986" //Ecuador: Highest expert in factor 
}
foreach v in all_q29_norm all_q30_norm {
	replace `v'=. if id_alex=="cc_Spanish_0_172" //Ecuador: Highest expert in factor , second
}
foreach v in all_q29_norm all_q30_norm {
	replace `v'=. if id_alex=="cc_Spanish_0_389_2023" //Ecuador: Highest expert in factor, third
}
foreach v in cj_q31f_norm cj_q31g_norm cj_q42c_norm cj_q42d_norm {
	replace `v'=. if id_alex=="cj_Spanish_0_675" //Ecuador: Removing 0s. Outlier in sub_factor
}
foreach v in cj_q31f_norm cj_q31g_norm cj_q42c_norm cj_q42d_norm {
	replace `v'=. if id_alex=="cj_Spanish_1_137" //Ecuador: Removing 0s. Outlier in sub_factor
}
foreach v in all_q19_norm all_q31_norm all_q32_norm all_q14_norm{
	replace `v'=. if id_alex=="cc_Spanish_1_986" //Ecuador: Removing 1s. Outlier in sub_factor
}
replace all_q96_norm=. if id_alex=="cc_English_0_321_2023" //Ecuador: Removing 0s. Outlier in sub_factor
replace all_q96_norm=. if id_alex=="cj_Spanish_0_153_2023" //Ecuador: Removing 0s. Outlier in sub_factor
replace all_q96_norm=. if id_alex=="cj_Spanish_1_524" //Ecuador: Removing 0s. Outlier in sub_factor
replace all_q96_norm=. if id_alex=="cc_Spanish_0_872_2023" //Ecuador: Removing 0s. Outlier in sub_factor
replace cj_q31g_norm=. if id_alex=="cj_Spanish_1_297_2023" //Ecuador: Removing 0s. Outlier in sub_factor
replace cj_q42d_norm=. if id_alex=="cj_Spanish_0_17" //Ecuador: Removing 0s. Outlier in sub_factor
foreach v in lb_q2d_norm lb_q3d_norm all_q62_norm all_q63_norm {
	replace `v'=. if id_alex=="lb_Spanish_0_443_2023" //Ecuador: Removing 0s. Outlier in sub_factor
}
foreach v in lb_q2d_norm lb_q3d_norm all_q62_norm all_q63_norm {
	replace `v'=. if id_alex=="cc_English_0_90_2023" //Ecuador: Removing 0s. Outlier in sub_factor
}
foreach v in all_q76_norm all_q77_norm all_q78_norm all_q79_norm all_q80_norm all_q81_norm all_q82_norm {
	replace `v'=. if id_alex=="lb_Spanish_0_78" //Ecuador: Removing 0s. Outlier in sub_factor
}
foreach v in all_q76_norm all_q77_norm all_q78_norm all_q79_norm all_q80_norm all_q81_norm all_q82_norm {
	replace `v'=. if id_alex=="lb_Spanish_0_403" //Ecuador: Removing 0s. Outlier in sub_factor
}
foreach v in all_q84_norm all_q85_norm all_q88_norm cc_q13_norm cc_q26a_norm {
	replace `v'=. if id_alex=="lb_Spanish_0_78" //Ecuador: Removing 0s. Outlier in sub_factor
}
foreach v in all_q84_norm all_q85_norm all_q88_norm cc_q13_norm cc_q26a_norm {
	replace `v'=. if id_alex=="cc_Spanish_1_1175_2022_2023" //Ecuador: Removing 0s. Outlier in sub_factor
}
foreach v in all_q84_norm all_q85_norm all_q88_norm cc_q13_norm cc_q26a_norm {
	replace `v'=. if id_alex=="cc_Spanish_0_872_2023" //Ecuador: Removing 0s. Outlier in sub_factor
}
foreach v in cj_q27a_norm cj_q27b_norm cj_q7a_norm cj_q7b_norm cj_q7c_norm cj_q20a_norm cj_q20b_norm cj_q20e_norm {
	replace `v'=. if id_alex=="cj_Spanish_0_308" //Ecuador: Removing 0s. Outlier in sub_factor
}
foreach v in cj_q27a_norm cj_q27b_norm cj_q7a_norm cj_q7b_norm cj_q7c_norm cj_q20a_norm cj_q20b_norm cj_q20e_norm {
	replace `v'=. if id_alex=="cj_Spanish_0_578_2023" //Ecuador: Removing 0s. Outlier in sub_factor
}
foreach v in cj_q21a_norm cj_q21e_norm cj_q21g_norm cj_q21h_norm cj_q28_norm {
	replace `v'=. if id_alex=="cj_Spanish_1_524" //Ecuador: Removing 0s. Outlier in sub_factor
}
foreach v in cj_q12a_norm cj_q12b_norm cj_q12c_norm cj_q12d_norm cj_q12e_norm cj_q12f_norm cj_q20o_norm {
	replace `v'=. if id_alex=="cj_Spanish_0_90_2022_2023" //Ecuador: Removing 0s. Outlier in sub_factor
}
foreach v in cj_q32c_norm cj_q32d_norm cj_q31a_norm cj_q31b_norm cj_q34a_norm cj_q34b_norm cj_q34c_norm cj_q34d_norm cj_q34e_norm cj_q33a_norm cj_q33b_norm cj_q33c_norm cj_q33d_norm cj_q33e_norm cj_q16j_norm cj_q18a_norm cj_q32b_norm cj_q20k_norm cj_q24b_norm cj_q24c_norm {
	replace `v'=. if id_alex=="cj_Spanish_0_578_2023" //Ecuador: Removing 0s. Outlier in sub_factor	
}
foreach v in cj_q32c_norm cj_q32d_norm cj_q31a_norm cj_q31b_norm cj_q34a_norm cj_q34b_norm cj_q34c_norm cj_q34d_norm cj_q34e_norm cj_q33a_norm cj_q33b_norm cj_q33c_norm cj_q33d_norm cj_q33e_norm cj_q16j_norm cj_q18a_norm cj_q32b_norm cj_q20k_norm cj_q24b_norm cj_q24c_norm {
	replace `v'=. if id_alex=="cj_Spanish_1_524" //Ecuador: Removing 0s. Outlier in sub_factor	
}
replace all_q2_norm=. if id_alex=="cc_Spanish_1_374" //Ecuador - reduzco el cambio positivo en la pregunta  - 1.2 //
replace all_q2_norm=. if id_alex=="cc_Spanish_0_172" //Ecuador - reduzco el cambio positivo en la pregunta  - 1.2 //
replace all_q1_norm=. if id_alex=="cc_Spanish_0_172" //Ecuador - reduzco el cambio positivo en la pregunta  - 1.2 //
replace cj_q38_norm=. if id_alex=="cj_Spanish_0_90_2022_2023" //Ecuador - reduzco el cambio negativo en la pregunta  - 1.4 //
replace cj_q38_norm=. if id_alex=="cj_Spanish_0_578_2023" //Ecuador - reduzco el cambio negativo en la pregunta  - 1.4 //
replace all_q22_norm=. if id_alex=="cj_Spanish_0_76" //Ecuador - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q24_norm=. if id_alex=="cj_Spanish_0_76" //Ecuador - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q25_norm=. if id_alex=="cj_Spanish_0_76" //Ecuador - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q27_norm=. if id_alex=="cj_Spanish_0_675" //Ecuador - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q22_norm=. if id_alex=="lb_Spanish_0_490_2023" //Ecuador - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q96_norm=. if id_alex=="cc_Spanish_0_389_2023" //Ecuador - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_Spanish_0_948" //Ecuador - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="lb_English_1_723_2023" //Ecuador - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="lb_Spanish_0_24_2023" //Ecuador - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="lb_Spanish_1_568" //Ecuador - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="lb_Spanish_1_568" //Ecuador - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q15_norm=. if id_alex=="cc_Spanish_1_374" //Ecuador - reduzco el cambio positivo en la pregunta  - 4.4 //
replace all_q15_norm=. if id_alex=="cc_Spanish_1_986" //Ecuador - reduzco el cambio positivo en la pregunta  - 4.4 //
replace all_q16_norm=. if id_alex=="cc_Spanish_1_374" //Ecuador - reduzco el cambio positivo en la pregunta  - 4.4 //
replace all_q16_norm=. if id_alex=="cc_Spanish_1_986" //Ecuador - reduzco el cambio positivo en la pregunta  - 4.4 //
replace all_q19_norm=. if id_alex=="cc_Spanish_1_374" //Ecuador - reduzco el cambio positivo en la pregunta  - 4.4 //
replace all_q19_norm=. if id_alex=="cc_Spanish_1_986" //Ecuador - reduzco el cambio positivo en la pregunta  - 4.4 //
replace all_q29_norm=. if id_alex=="cc_Spanish_1_374" //Ecuador - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cc_Spanish_1_374" //Ecuador - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cj_Spanish_0_90_2022_2023" //Ecuador - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cj_Spanish_0_90_2022_2023" //Ecuador - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cc_Spanish_1_1302_2022_2023" //Ecuador - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cc_Spanish_1_1302_2022_2023" //Ecuador - reduzco el cambio positivo en la pregunta  - 4.5 //
replace cj_q42c_norm=. if id_alex=="cj_Spanish_0_153_2023" //Ecuador - reduzco el cambio positivo en la pregunta  - 4.6 //
replace cj_q42c_norm=. if id_alex=="cj_Spanish_0_151_2023" //Ecuador - reduzco el cambio positivo en la pregunta  - 4.6 //
replace cj_q42d_norm=. if id_alex=="cj_Spanish_0_153_2023" //Ecuador - reduzco el cambio positivo en la pregunta  - 4.6 //
replace cj_q42d_norm=. if id_alex=="cj_Spanish_0_151_2023" //Ecuador - reduzco el cambio positivo en la pregunta  - 4.6 //
replace cj_q31f_norm=. if id_alex=="cj_Spanish_0_17" //Ecuador - reduzco el cambio positivo en la pregunta  - 4.6 //
replace cj_q31g_norm=. if id_alex=="cj_Spanish_0_17" //Ecuador - reduzco el cambio positivo en la pregunta  - 4.6 //
replace all_q19_norm=. if id_alex=="cc_Spanish_1_374" //Ecuador - reduzco el cambio positivo en la pregunta  - 4.7 //
replace all_q31_norm=. if id_alex=="cc_Spanish_1_374" //Ecuador - reduzco el cambio positivo en la pregunta  - 4.7 //
replace all_q32_norm=. if id_alex=="cc_Spanish_1_374" //Ecuador - reduzco el cambio positivo en la pregunta  - 4.7 //
replace all_q14_norm=. if id_alex=="cc_Spanish_1_374" //Ecuador - reduzco el cambio positivo en la pregunta  - 4.7 //
replace all_q19_norm=. if id_alex=="cc_Spanish_0_389_2023" //Ecuador - reduzco el cambio positivo en la pregunta  - 4.7 //
replace all_q31_norm=. if id_alex=="cc_Spanish_0_389_2023" //Ecuador - reduzco el cambio positivo en la pregunta  - 4.7 //
replace all_q32_norm=. if id_alex=="cc_Spanish_0_389_2023" //Ecuador - reduzco el cambio positivo en la pregunta  - 4.7 //
replace all_q14_norm=. if id_alex=="cc_Spanish_0_389_2023" //Ecuador - reduzco el cambio positivo en la pregunta  - 4.7 //
replace all_q63_norm=. if id_alex=="cc_Spanish_0_461_2023" //Ecuador - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q63_norm=. if id_alex=="cc_Spanish_0_62_2023" //Ecuador - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q74_norm=. if id_alex=="cc_Spanish_0_438_2022_2023" //Ecuador - reduzco el cambio negativo en la pregunta  - 7.1 //
replace all_q75_norm=. if id_alex=="cc_Spanish_0_438_2022_2023" //Ecuador - reduzco el cambio negativo en la pregunta  - 7.1 //
replace all_q74_norm=. if id_alex=="cc_Spanish_1_1175_2022_2023" //Ecuador - reduzco el cambio negativo en la pregunta  - 7.1 //
replace all_q75_norm=. if id_alex=="cc_Spanish_1_1175_2022_2023" //Ecuador - reduzco el cambio negativo en la pregunta  - 7.1 //
replace all_q85_norm=. if id_alex=="lb_Spanish_0_223_2023" //Ecuador - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="lb_Spanish_0_223_2023" //Ecuador - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q85_norm=. if id_alex=="lb_Spanish_0_443_2023" //Ecuador - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="lb_Spanish_0_443_2023" //Ecuador - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q85_norm=. if id_alex=="lb_Spanish_1_351" //Ecuador - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="lb_Spanish_1_351" //Ecuador - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="cc_Spanish_0_547_2022_2023" //Ecuador - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="cc_Spanish_0_438_2022_2023" //Ecuador - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cj_q20e_norm=. if id_alex=="cj_Spanish_1_137" //Ecuador - reduzco el cambio negativo en la pregunta  - 8.2 //
replace cj_q20e_norm=. if id_alex=="cj_Spanish_1_137" //Ecuador - reduzco el cambio negativo en la pregunta  - 8.2 //
replace cj_q20e_norm=. if id_alex=="cj_Spanish_1_297_2023" //Ecuador - reduzco el cambio negativo en la pregunta  - 8.2 //
replace cj_q21h_norm=. if id_alex=="cj_Spanish_0_308" //Ecuador - reduzco el cambio negativo en la pregunta  - 8.3 //
replace cj_q21h_norm=. if id_alex=="cj_Spanish_0_193" //Ecuador - reduzco el cambio negativo en la pregunta  - 8.3 //
replace cj_q21h_norm=. if id_alex=="cj_Spanish_0_90_2022_2023" //Ecuador - reduzco el cambio negativo en la pregunta  - 8.3 //
replace cj_q28_norm=. if id_alex=="cj_Spanish_0_153_2023" //Ecuador - reduzco el cambio negativo en la pregunta  - 8.3 //
replace cj_q21e_norm=. if id_alex=="cj_Spanish_1_297_2023" //Ecuador - reduzco el cambio negativo en la pregunta  - 8.3 //
replace cj_q21e_norm=. if id_alex=="cj_Spanish_0_420_2023" //Ecuador - reduzco el cambio negativo en la pregunta  - 8.3 //
replace cj_q20o_norm=. if id_alex=="cj_Spanish_1_297_2023" //Ecuador - reduzco el cambio negativo en la pregunta  - 8.4 //
replace cj_q40c_norm=. if id_alex=="cj_Spanish_1_297_2023" //Ecuador - reduzco el cambio negativo en la pregunta  - 8.6 //

*Egypt
drop if id_alex=="ph_English_1_121" //Egypt, Arab Rep.: Highest PH
drop if id_alex=="lb_English_0_32" //Egypt, Arab Rep.: Highest LB
drop if id_alex=="cj_English_1_76" //Egypt, Arab Rep. (muy positivo)
drop if id_alex=="cc_English_0_97" //Egypt, Arab Rep. (muy negativo)
replace cj_q28_norm=. if country=="Egypt, Arab Rep." //Egypt, Arab Rep.: Score of 1. 
replace cj_q21h_norm=. if country=="Egypt, Arab Rep." //Egypt, Arab Rep.: Removed last year. High score
replace cj_q32b_norm=. if id_alex=="cj_English_1_678" //Egypt, Arab Rep. - reduzco el cambio positivo en la pregunta  - 2.2 //
replace cj_q24c_norm=. if id_alex=="cj_English_1_678" //Egypt, Arab Rep. - reduzco el cambio positivo en la pregunta  - 2.2 //
replace cj_q33a_norm=. if id_alex=="cj_English_1_678" //Egypt, Arab Rep. - reduzco el cambio positivo en la pregunta  - 2.2 //
replace cj_q33b_norm=. if id_alex=="cj_English_1_678" //Egypt, Arab Rep. - reduzco el cambio positivo en la pregunta  - 2.2 //
replace cj_q33c_norm=. if id_alex=="cj_English_1_678" //Egypt, Arab Rep. - reduzco el cambio positivo en la pregunta  - 2.2 //
replace cj_q33d_norm=. if id_alex=="cj_English_1_678" //Egypt, Arab Rep. - reduzco el cambio positivo en la pregunta  - 2.2 //
replace cj_q33e_norm=. if id_alex=="cj_English_1_678" //Egypt, Arab Rep. - reduzco el cambio positivo en la pregunta  - 2.2 //
replace cc_q9c_norm=. if id_alex=="cc_English_0_437" //Egypt, Arab Rep. - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cc_q40a_norm=. if id_alex=="cc_English_0_489" //Egypt, Arab Rep. - reduzco el cambio positivo en la pregunta  - 3.4 //
replace ph_q6a_norm=. if id_alex=="ph_English_0_153" //Egypt, Arab Rep. - reduzco el cambio negativo en la pregunta  - 4.1 //
replace ph_q6b_norm=. if id_alex=="ph_English_0_153" //Egypt, Arab Rep. - reduzco el cambio negativo en la pregunta  - 4.1 //
replace ph_q6c_norm=. if id_alex=="ph_English_0_153" //Egypt, Arab Rep. - reduzco el cambio negativo en la pregunta  - 4.1 //
replace ph_q6d_norm=. if id_alex=="ph_English_0_153" //Egypt, Arab Rep. - reduzco el cambio negativo en la pregunta  - 4.1 //
replace ph_q6e_norm=. if id_alex=="ph_English_0_153" //Egypt, Arab Rep. - reduzco el cambio negativo en la pregunta  - 4.1 //
replace cj_q10_norm=. if id_alex=="cj_English_1_902_2023" //Egypt, Arab Rep. - reduzco el cambio negativo en la pregunta  - 4.2 //
replace all_q30_norm=. if id_alex=="cj_English_0_690_2021_2022_2023" //Egypt, Arab Rep. - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cc_English_0_489" //Egypt, Arab Rep. - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cc_English_0_489" //Egypt, Arab Rep. - reduzco el cambio positivo en la pregunta  - 4.5 //
replace cj_q31f_norm=. if id_alex=="cj_English_0_690_2021_2022_2023" //Egypt, Arab Rep. - reduzco el cambio negativo en la pregunta  - 4.6 //
replace cj_q31g_norm=. if id_alex=="cj_English_0_690_2021_2022_2023" //Egypt, Arab Rep. - reduzco el cambio negativo en la pregunta  - 4.6 //
replace all_q77_norm=. if id_alex=="lb_English_0_222_2016_2017_2018_2019_2021_2022_2023" //Egypt, Arab Rep. - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q77_norm=. if id_alex=="lb_English_0_538_2018_2019_2021_2022_2023" //Egypt, Arab Rep. - reduzco el cambio negativo en la pregunta  - 7.2 //
replace cc_q13_norm=. if id_alex=="cc_English_1_230" //Egypt, Arab Rep. - reduzco el cambio positivo en la pregunta  - 7.5 //
replace cj_q40b_norm=. if id_alex=="cc_English_1_742" //Egypt, Arab Rep. - reduzco el cambio positivo en la pregunta  - 7.5 //
replace cj_q40c_norm=. if id_alex=="cj_English_0_506" //Egypt, Arab Rep. - reduzco el cambio positivo en la pregunta  - 8.6 //
replace cj_q31f_norm=. if id_alex=="cj_English_0_690_2021_2022_2023" //Egypt, Arab Rep.: Removing 0s in question
replace cj_q31f_norm=. if id_alex=="cj_English_1_902_2023" //Egypt, Arab Rep.: Removing 0s in question
replace cj_q31f_norm=. if id_alex=="cj_English_0_181" //Egypt, Arab Rep.: Removing 0s in question

foreach v in all_q89_norm all_q59_norm all_q90_norm all_q91_norm cc_q14a_norm cc_q14b_norm {
	replace `v'=. if id_alex=="cc_English_0_97" //Egypt, Arab Rep.: Outlier. 0s in all questions
}
replace all_q88_norm=. if id_alex=="cc_English_1_742" //Egypt, Arab Rep.: Outlier. Highest score in question
replace cj_q21a_norm=. if id_alex=="cj_English_1_76" //Egypt, Arab Rep.: Outlier. Highest score in question
replace cj_q21e_norm=. if id_alex=="cj_English_1_76" //Egypt, Arab Rep.: Outlier. Highest score in question
replace cj_q21g_norm=. if id_alex=="cj_English_1_902_2023" //Egypt, Arab Rep.: Outlier. Highest score in question

*El Salvador
drop if id_alex=="cj_Spanish_1_221" //El Salvador: Lowest CJ
drop if id_alex=="cj_English_1_550" //El Salvador (muy negativo)
drop if id_alex=="cc_Spanish_1_325" //El Salvador (muy negativo)
foreach v in cc_q9b_norm cc_q39a_norm cc_q39b_norm cc_q39d_norm cc_q39c_norm cc_q39e_norm {
	replace `v'=. if id_alex=="cc_Spanish_1_1124_2022_2023" //El Salvador: Removing 0s. Outlier in sub_factor
}
foreach v in cc_q9b_norm cc_q39a_norm cc_q39b_norm cc_q39d_norm cc_q39c_norm cc_q39e_norm {
	replace `v'=. if id_alex=="cc_English_1_48_2023" //El Salvador: Removing 0s. Outlier in sub_factor
}
foreach v in cc_q9b_norm cc_q39a_norm cc_q39b_norm cc_q39d_norm cc_q39c_norm cc_q39e_norm {
	replace `v'=. if id_alex=="cc_Spanish_1_1134" //El Salvador: Removing 0s. Outlier in sub_factor
}
foreach v in cc_q9b_norm cc_q39a_norm cc_q39b_norm cc_q39d_norm cc_q39c_norm cc_q39e_norm {
	replace `v'=. if id_alex=="cc_Spanish_0_987_2023" //El Salvador: Removing 0s. Outlier in sub_factor
}
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="lb_Spanish_0_437_2019_2021_2022_2023" //El Salvador: Removing 0s. Outlier in sub-sub-factor
	}	
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="cc_Spanish_1_1124_2022_2023" //El Salvador: Removing 0s. Outlier in sub-sub-factor
	}
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="cc_English_1_48_2023" //El Salvador: Removing 0s. Outlier in sub-sub-factor
	}
foreach v in cc_q9c_norm cc_q40a_norm cc_q40b_norm {
	replace `v'=. if id_alex=="cc_English_1_48_2023" //El Salvador: Removing 0s. Outlier in sub-sub-factor
}
foreach v in all_q13_norm all_q14_norm all_q15_norm all_q16_norm all_q17_norm cj_q10_norm all_q94_norm all_q19_norm all_q20_norm all_q21_norm all_q19_norm all_q31_norm all_q32_norm all_q14_norm {
	replace `v'=. if id_alex=="cj_English_1_550" //El Salvador: Removing 0s. Outlier in sub-sub-factor
}
foreach v in cj_q11a_norm cj_q11b_norm cj_q31e_norm cj_q42c_norm cj_q42d_norm cj_q10_norm {
	replace `v'=. if id_alex=="cj_English_1_640" //El Salvador: Removing 0s. Outlier in sub-sub-factor
}
foreach v in cj_q31f_norm cj_q31g_norm cj_q42c_norm cj_q42d_norm {
	replace `v'=. if id_alex=="cj_English_1_550" //El Salvador: Removing 0s. Outlier in sub-sub-factor
}
foreach v in all_q19_norm all_q31_norm all_q32_norm all_q14_norm  {
	replace `v'=. if id_alex=="cc_Spanish_1_1124_2022_2023" //El Salvador: Removing 0s. Outlier in sub-sub-factor
}
replace all_q62_norm=. if id_alex=="cc_English_0_195_2023" //El Salvador: Removing 1. Outlier in question.
foreach v in all_q62_norm all_q63_norm {
	replace `v'=. if id_alex=="lb_Spanish_1_401_2016_2017_2018_2019_2021_2022_2023"
}
foreach v in all_q62_norm all_q63_norm {
	replace `v'=. if id_alex=="lb_Spanish_1_401_2016_2017_2018_2019_2021_2022_2023" //El Salvador: Removing 1. Outlier in question.
}
foreach v in all_q62_norm all_q63_norm {
	replace `v'=. if id_alex=="lb_English_1_614_2019_2021_2022_2023" //El Salvador: Removing 1. Outlier in question.
}
foreach v in all_q62_norm all_q63_norm {
	replace `v'=. if id_alex=="lb_English_0_468_2019_2021_2022_2023" //El Salvador: Removing 1. Outlier in question.
}
foreach v in all_q48_norm all_q49_norm all_q50_norm {
	replace `v'=. if id_alex=="cc_English_1_48_2023" //El Salvador: Removing 0s. Outlier in sub-factor.
}
foreach v in all_q6_norm cc_q11a_norm all_q3_norm all_q4_norm all_q7_norm {
	replace `v'=. if id_alex=="cc_Spanish_1_1134" //El Salvador: Removing 0s. Outlier in sub-factor.
}
replace all_q86_norm=. if id_alex=="cc_Spanish_0_42" //El Salvador: Removing 0. Outlier in question.
replace cc_q26b_norm=. if id_alex=="cc_Spanish_1_325" //El Salvador: Removing 0. Outlier in question. 
foreach v in cj_q40b_norm cj_q40c_norm cj_q20m_norm {
	replace `v'=. if id_alex=="cj_English_1_1006" //El Salvador: Removing 0s. Outlier in sub-factor.
}
foreach v in cc_q10_norm cc_q11a_norm cc_q16a_norm {
	replace `v'=. if id_alex=="cc_Spanish_1_1134" //El Salvador: Removing 0s. Outlier in sub-factor.
}
replace all_q2_norm=. if id_alex=="cc_Spanish_1_1124_2022_2023" //El Salvador - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q2_norm=. if id_alex=="cc_English_1_48_2023" //El Salvador - reduzco el cambio negativo en la pregunta  - 1.2 //
replace cc_q25_norm=. if id_alex=="cc_Spanish_1_1124_2022_2023" //El Salvador - reduzco el cambio negativo en la pregunta  - 1.2 //
replace cc_q25_norm=. if id_alex=="cc_English_1_48_2023" //El Salvador - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q5_norm=. if id_alex=="cc_Spanish_1_1453_2022_2023" //El Salvador - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q5_norm=. if id_alex=="cc_Spanish_1_1124_2022_2023" //El Salvador - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q24_norm=. if id_alex=="cc_Spanish_0_157" //El Salvador - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q24_norm=. if id_alex=="cj_Spanish_0_368" //El Salvador - reduzco el cambio negativo en la pregunta  - 1.7 //
replace cc_q40b_norm=. if id_alex=="cc_Spanish_1_1124_2022_2023" //El Salvador - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cc_q40b_norm=. if id_alex=="cc_Spanish_0_663_2022_2023" //El Salvador - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cc_q9c_norm=. if id_alex=="cc_Spanish_1_1124_2022_2023" //El Salvador - reduzco el cambio negativo en la pregunta  - 3.4 //
replace all_q29_norm=. if id_alex=="cj_English_1_1006" //El Salvador - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cj_English_1_1006" //El Salvador - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q48_norm=. if id_alex=="lb_Spanish_1_567_2018_2019_2021_2022_2023" //El Salvador - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q49_norm=. if id_alex=="lb_Spanish_1_567_2018_2019_2021_2022_2023" //El Salvador - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q50_norm=. if id_alex=="lb_Spanish_1_567_2018_2019_2021_2022_2023" //El Salvador - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q50_norm=. if id_alex=="lb_Spanish_1_153_2023" //El Salvador - reduzco el cambio negativo en la pregunta  - 6.4 //
replace cc_q26b_norm=. if id_alex=="cc_Spanish_1_1124_2022_2023" //El Salvador - reduzco el cambio negativo en la pregunta  - 7.6 //
replace cc_q26b_norm=. if id_alex=="cc_Spanish_0_157" //El Salvador - reduzco el cambio negativo en la pregunta  - 7.6 //
replace all_q87_norm=. if id_alex=="cc_Spanish_0_157" //El Salvador - reduzco el cambio negativo en la pregunta  - 7.6 //
replace cc_q14a_norm=. if id_alex=="cc_Spanish_1_1124_2022_2023" //El Salvador - reduzco el cambio negativo en la pregunta  - 7.7 //
replace cc_q14b_norm=. if id_alex=="cc_Spanish_1_1124_2022_2023" //El Salvador - reduzco el cambio negativo en la pregunta  - 7.7 //
replace cj_q7c_norm=. if id_alex=="cj_English_1_1006" //El Salvador - reduzco el cambio negativo en la pregunta  - 8.2 //
replace cj_q20m_norm=. if id_alex=="cj_Spanish_0_782_2023" //El Salvador - reduzco el cambio negativo en la pregunta  - 8.6 //

*Estonia
replace lb_q2d_norm=. if id_alex=="lb_English_0_199" //Estonia: Removing lowest score in question
replace lb_q3d_norm=. if id_alex=="lb_English_0_199" //Estonia: Removing lowest score in question
replace all_q62_norm=. if id_alex=="lb_English_1_456" //Estonia: Removing 0 in question
replace all_q63_norm=. if id_alex=="lb_English_1_456" //Estonia: Removing 0 in question
replace cj_q38_norm=. if id_alex=="cj_English_1_184_2022_2023" //Estonia - reduzco el cambio negativo en la pregunta  - 1.4 //
replace cc_q9c_norm=. if id_alex=="cc_English_1_626_2019_2021_2022_2023" //Estonia - reduzco el cambio negativo en la pregunta  - 3.4 //
replace all_q76_norm=. if id_alex=="cc_English_0_1195_2017_2018_2019_2021_2022_2023" //Estonia - reduzco el cambio negativo en la pregunta  - 4.1 //
replace all_q78_norm=. if id_alex=="cc_English_0_128_2023" //Estonia - reduzco el cambio negativo en la pregunta  - 4.1 //
replace lb_q16e_norm=. if id_alex=="lb_English_0_418_2021_2022_2023" //Estonia - reduzco el cambio negativo en la pregunta  - 4.1 //
replace lb_q16b_norm=. if id_alex=="lb_English_0_572_2014_2016_2017_2018_2019_2021_2022_2023" //Estonia - reduzco el cambio negativo en la pregunta  - 4.1 //
replace cj_q42c_norm=. if id_alex=="cj_English_0_929" //Estonia - reduzco el cambio negativo en la pregunta  - 4.6 //
replace all_q62_norm=. if id_alex=="lb_English_0_572_2014_2016_2017_2018_2019_2021_2022_2023" //Estonia - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q63_norm=. if id_alex=="lb_English_0_352" //Estonia - reduzco el cambio negativo en la pregunta  - 6.3 //
replace lb_q2d_norm=1 if id_alex=="lb_English_1_448_2014_2016_2017_2018_2019_2021_2022_2023" //Estonia - reduzco el cambio negativo en la pregunta  - 6.3 //
replace lb_q3d_norm=1 if id_alex=="lb_English_1_448_2014_2016_2017_2018_2019_2021_2022_2023" //Estonia - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q48_norm=. if id_alex=="lb_English_1_232_2019_2021_2022_2023" //Estonia - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q49_norm=. if id_alex=="lb_English_1_232_2019_2021_2022_2023" //Estonia - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q50_norm=. if id_alex=="lb_English_1_232_2019_2021_2022_2023" //Estonia - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q49_norm=. if id_alex=="cc_English_0_1192" //Estonia - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q50_norm=. if id_alex=="cc_English_0_1192" //Estonia - reduzco el cambio negativo en la pregunta  - 6.4 //
replace cc_q16f_norm=. if id_alex=="cc_English_1_644" //Estonia - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q16e_norm=. if id_alex=="cc_English_1_644" //Estonia - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cj_q40c_norm=. if id_alex=="cj_English_1_1102_2021_2022_2023" //Estonia - reduzco el cambio negativo en la pregunta  - 8.6 //
replace cj_q20m_norm=. if id_alex=="cj_English_1_1102_2021_2022_2023" //Estonia - reduzco el cambio negativo en la pregunta  - 8.6 //

*Ethiopia
drop if id_alex=="cj_English_1_425" //Ethiopia (muy negativo)
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="lb_English_0_633_2019_2021_2022_2023" //Ethiopia: Removing 0s. Outlier in sub-sub-factor
	}
foreach v in cc_q9b_norm cc_q39a_norm cc_q39b_norm cc_q39d_norm cc_q39c_norm cc_q39e_norm {
	replace `v'=. if id_alex=="cc_English_1_903" //Ethiopia: Removing 0s. Outlier in sub-sub-factor
}
foreach v in cc_q9b_norm cc_q39a_norm cc_q39b_norm cc_q39d_norm cc_q39c_norm cc_q39e_norm {
	replace `v'=. if id_alex=="cc_English_1_640" //Ethiopia: Removing 0s. Outlier in sub-sub-factor
}
foreach v in cc_q9b_norm cc_q39a_norm cc_q39b_norm cc_q39d_norm cc_q39c_norm cc_q39e_norm {
	replace `v'=. if id_alex=="cc_English_0_707_2023" //Ethiopia: Removing 0s. Outlier in sub-sub-factor
}
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="cc_English_1_525_2023" //Ethiopia: Removing 0s. Outlier in sub-sub-factor
	}
foreach v in cj_q31f_norm cj_q31g_norm cj_q42c_norm cj_q42d_norm {
	replace `v'=. if id_alex=="cj_English_1_425" //Ethiopia: Removing 0s. Outlier in sub-factor
}
replace all_q54_norm=. if id_alex=="cc_English_0_1406_2022_2023" //Ethiopia: Removing 0 in question
replace all_q55_norm=. if id_alex=="cc_English_0_1406_2022_2023" //Ethiopia: Removing 0 in question
foreach v in cc_q28a_norm cc_q28b_norm cc_q28c_norm cc_q28d_norm {
	replace `v'=. if id_alex=="cc_English_0_1406_2022_2023" //Ethiopia: Removing 0s. Outlier in sub-factor
}
foreach v in all_q54_norm all_q55_norm {
	replace `v'=. if id_alex=="cc_English_1_525_2023" //Ethiopia: Removing 0s. Outlier in sub-factor
}
foreach v in cc_q28a_norm cc_q28b_norm cc_q28c_norm cc_q28d_norm {
	replace `v'=. if id_alex=="cc_English_1_911_2023" //Ethiopia: Removing 0s. Outlier in sub-factor
}
foreach v in cc_q28a_norm cc_q28b_norm cc_q28c_norm cc_q28d_norm {
	replace `v'=. if id_alex=="cc_English_1_640" //Ethiopia: Removing 0s. Outlier in sub-factor
}
replace all_q63_norm=. if id_alex=="lb_English_1_611" //Ethiopia: Removing 0 in question
replace all_q63_norm=. if id_alex=="cc_English_1_640" //Ethiopia: Removing 0 in question
replace all_q63_norm=. if id_alex=="cc_English_1_525_2023" //Ethiopia: Removing 0 in question
replace all_q63_norm=. if id_alex=="cc_English_1_409" //Ethiopia: Removing 0 in question
foreach v in lb_q2d_norm lb_q3d_norm {
	replace `v'=. if id_alex=="lb_English_1_87" //Ethiopia: Removing 0s. Outlier in sub-factor
}
foreach v in all_q48_norm all_q49_norm all_q50_norm {
	replace `v'=. if id_alex=="cc_English_1_640" //Ethiopia: Removing 0s. Outlier in sub-factor
}
replace cc_q26b_norm=. if id_alex=="cc_English_1_911_2023" //Ethiopia: Removing 0 in question
replace cj_q8_norm=. if id_alex=="cj_English_0_412_2023" //Ethiopia - reduzco el cambio negativo en la pregunta  - 1.4 //
replace cj_q36c_norm=. if id_alex=="cj_English_0_412_2023" //Ethiopia - reduzco el cambio negativo en la pregunta  - 1.4 //
replace all_q96_norm=. if id_alex=="cc_English_0_343_2023" //Ethiopia - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_1_911_2023" //Ethiopia - reduzco el cambio negativo en la pregunta  - 2.4 //
replace cc_q9c_norm=. if id_alex=="cc_English_0_685" //Ethiopia - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cc_q40a_norm=. if id_alex=="cc_English_0_685" //Ethiopia - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cj_q31f_norm=. if id_alex=="cj_English_0_412_2023" //Ethiopia - reduzco el cambio negativo en la pregunta  - 4.6 //
replace cj_q31g_norm=. if id_alex=="cj_English_0_412_2023" //Ethiopia - reduzco el cambio negativo en la pregunta  - 4.6 //
replace cj_q31f_norm=. if id_alex=="cj_English_0_656_2023" //Ethiopia - reduzco el cambio negativo en la pregunta  - 4.6 //
replace cj_q31g_norm=. if id_alex=="cj_English_0_656_2023" //Ethiopia - reduzco el cambio negativo en la pregunta  - 4.6 //
replace lb_q23f_norm=. if id_alex=="lb_English_0_633_2019_2021_2022_2023" //Ethiopia - reduzco el cambio positivo en la pregunta  - 4.8 //
replace lb_q16c_norm=. if id_alex=="lb_English_1_609" //Ethiopia - reduzco el cambio positivo en la pregunta  - 4.8 //
replace lb_q16d_norm=. if id_alex=="lb_English_1_609" //Ethiopia - reduzco el cambio positivo en la pregunta  - 4.8 //
replace lb_q23a_norm=. if id_alex=="lb_English_0_190" //Ethiopia - reduzco el cambio positivo en la pregunta  - 4.8 //
replace lb_q23b_norm=. if id_alex=="lb_English_0_190" //Ethiopia - reduzco el cambio positivo en la pregunta  - 4.8 //
replace cc_q26b_norm=. if id_alex=="cc_English_1_525_2023" //Ethiopia - reduzco el cambio negativo en la pregunta  - 7.6 //
replace cc_q26b_norm=. if id_alex=="cc_English_0_707_2023" //Ethiopia - reduzco el cambio negativo en la pregunta  - 7.6 //
replace cj_q20o_norm=. if id_alex=="cj_English_0_815_2022_2023" //Ethiopia - reduzco el cambio positivo en la pregunta  - 8.4 //
replace cj_q40c_norm=. if id_alex=="cj_English_0_412_2023" //Ethiopia - reduzco el cambio negativo en la pregunta  - 8.6 //

*Finland
drop if id_alex=="cc_English_0_1865" //Finland: Lowest CC
replace all_q96_norm=. if id_alex=="cc_English_0_382_2016_2017_2018_2019_2021_2022_2023" //Finland - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_0_1027_2016_2017_2018_2019_2021_2022_2023" //Finland - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_0_1582_2017_2018_2019_2021_2022_2023" //Finland - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_0_557_2017_2018_2019_2021_2022_2023" //Finland - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_1_765_2019_2021_2022_2023" //Finland - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="lb_English_1_137_2021_2022_2023" //Finland - reduzco el cambio positivo en la pregunta  - 2.4 //
replace cc_q32j_norm=. if id_alex=="cc_English_1_614" //Finland - reduzco el cambio negativo en la pregunta  - 3.3 //
replace cc_q40b_norm=. if id_alex=="cc_English_1_1105" //Finland - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cc_q40b_norm=. if id_alex=="cc_English_0_36" //Finland - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cj_q11a_norm=. if id_alex=="cj_English_1_295_2022_2023" //Finland - reduzco el cambio negativo en la pregunta  - 4.2 //
replace cj_q11b_norm=. if id_alex=="cj_English_1_295_2022_2023" //Finland - reduzco el cambio negativo en la pregunta  - 4.2 //
replace cj_q10_norm=. if id_alex=="cj_English_1_295_2022_2023" //Finland - reduzco el cambio negativo en la pregunta  - 4.2 //
replace all_q30_norm=. if id_alex=="cj_English_1_295_2022_2023" //Finland - reduzco el cambio negativo en la pregunta  - 4.5 //
replace lb_q16a_norm=. if id_alex=="lb_English_0_362" //Finland - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q16b_norm=. if id_alex=="lb_English_0_362" //Finland - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q16c_norm=. if id_alex=="lb_English_0_362" //Finland - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q16d_norm=. if id_alex=="lb_English_0_362" //Finland - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q16e_norm=. if id_alex=="lb_English_0_362" //Finland - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q16f_norm=. if id_alex=="lb_English_0_362" //Finland - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q23e_norm=. if id_alex=="lb_English_0_362" //Finland - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q23d_norm=. if id_alex=="lb_English_0_231" //Finland - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q23d_norm=. if id_alex=="cj_English_1_295_2022_2023" //Finland - reduzco el cambio positivo en la pregunta  - 5.3 //
replace lb_q23d_norm=. if id_alex=="cj_English_1_983_2022_2023" //Finland - reduzco el cambio positivo en la pregunta  - 5.3 //
replace all_q62_norm=. if id_alex=="lb_English_0_402" //Finland - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q63_norm=. if id_alex=="lb_English_0_402" //Finland - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q62_norm=. if id_alex=="cc_English_0_1027_2016_2017_2018_2019_2021_2022_2023" //Finland - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q63_norm=. if id_alex=="cc_English_0_1027_2016_2017_2018_2019_2021_2022_2023" //Finland - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q76_norm=. if id_alex=="cc_English_0_1857" //Finland - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q78_norm=. if id_alex=="cc_English_0_382_2016_2017_2018_2019_2021_2022_2023" //Finland - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q88_norm=. if id_alex=="cc_English_0_441" //Finland - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q26a_norm=. if id_alex=="cc_English_0_441" //Finland - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="cc_English_0_1857" //Finland - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q26a_norm=. if id_alex=="cc_English_0_1857" //Finland - reduzco el cambio negativo en la pregunta  - 7.5 //

*France
drop if id_alex=="cc_French_1_356" //France: Lowest CC
drop if id_alex=="cj_French_0_1365" //France: Lowest CJ
drop if id_alex=="cc_French_0_2005" //France (muy negativo)
foreach v in cj_q38_norm cj_q36c_norm cj_q8_norm {
	replace `v'=. if id_alex=="cj_French_0_138" //France: Removing 1s. Outliers in sub-factor
	replace `v'=. if id_alex=="cj_French_0_978" //France: Removing 1s. Outliers in sub-factor
}
replace all_q14_norm=. if all_q14_norm==0 & country=="France" //France: Removing 0s in question, outliers.
replace all_q21_norm=. if all_q21_norm==0 & country=="France" //France: Removing 0s in question, outliers.
foreach v in cj_q31f_norm cj_q31g_norm cj_q42c_norm cj_q42d_norm {
	replace `v'=. if id_alex=="cj_French_0_138" //France: Removing 1s, outlier in sub-factor
}
foreach v in cj_q31f_norm cj_q31g_norm cj_q42c_norm cj_q42d_norm {
	replace `v'=. if id_alex=="cj_French_0_1329" //France: Removing 1s, outlier in sub-factor
}
foreach v in cj_q31f_norm cj_q31g_norm cj_q42c_norm cj_q42d_norm {
	replace `v'=. if id_alex=="cj_French_0_978" //France: Removing 1s, outlier in sub-factor
}
foreach v in cj_q31f_norm cj_q31g_norm cj_q42c_norm cj_q42d_norm {
	replace `v'=. if id_alex=="cj_French_0_25" //France: Removing 1s, outlier in sub-factor
}
replace all_q48_norm=. if id_alex=="cc_French_0_1603" //France: Removing low score in question, outlier.
replace all_q49_norm=. if id_alex=="cc_French_0_1795" //France: Removing low score in question, outlier.
replace all_q49_norm=. if id_alex=="cc_French_0_392" //France: Removing low score in question, outlier.s
replace all_q49_norm=. if id_alex=="cc_French_0_1757" //France: Removing 0. Outlier in question
replace lb_q19a_norm=. if id_alex=="lb_French_1_449_2016_2017_2018_2019_2021_2022_2023" //France: Removing low score, outlier in question
replace all_q50_norm=. if id_alex=="cc_French_0_1500" 
foreach v in all_q76_norm all_q77_norm all_q78_norm all_q79_norm all_q80_norm all_q81_norm {
	replace `v'=. if id_alex=="cc_French_0_392" //France: Removing 0s. Outlier in sub-factor
}
replace all_q80_norm=. if id_alex=="cc_French_0_570" //France: Removing 0 in question, outlier
foreach v in all_q76_norm all_q77_norm all_q78_norm all_q79_norm all_q80_norm all_q81_norm {
	replace `v'=. if id_alex=="cc_English_0_790" //France: Removing 0s. Outlier in sub-factor
}
replace cc_q26b_norm=. if id_alex=="cc_French_0_1603" //France: Removing 0 in question, outlier
replace all_q86_norm=. if id_alex=="cc_French_0_1500" //France: Removing 0 in question, outlier
replace all_q87_norm=. if id_alex=="cc_French_0_1501" //France: Removing 0 in question, outlier
replace all_q59_norm=. if id_alex=="cc_French_0_2005" //France: Removing 0 in question, outlier
replace all_q89_norm=. if id_alex=="cc_French_0_1500" //France: Removing 0. Outlier in sub-factor
replace all_q89_norm=. if id_alex=="lb_French_0_450_2022_2023" //France: Removing 0. Outlier in sub-factor
replace all_q91_norm=. if id_alex=="cc_French_0_1501" //France: Removing 0 in question, outlier
replace all_q91_norm=. if id_alex=="cc_French_0_1590" //France: Removing low score in question, outlier
foreach v in cj_q40b_norm cj_q40c_norm cj_q20m_norm {
	replace `v'=. if id_alex=="cj_French_0_138" //France: Removing 1. Outlier in sub-factor
}
foreach v in cj_q40b_norm cj_q40c_norm cj_q20m_norm {
	replace `v'=. if id_alex=="cj_French_0_1329" //France: Removing 1. Outlier in sub-factor
}
foreach v in cj_q40b_norm cj_q40c_norm cj_q20m_norm {
	replace `v'=. if id_alex=="cj_French_0_978" //France: Removing 1. Outlier in sub-factor
}
replace all_q13_norm=. if id_alex=="cj_French_1_962_2022_2023" //France - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q14_norm=. if id_alex=="cc_French_0_570" //France - reduzco el cambio negativo en la pregunta  - 1.6 //
replace cj_q10_norm=. if id_alex=="cj_French_0_1168" //France - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q19_norm=. if id_alex=="cc_French_0_392" //France - reduzco el cambio negativo en la pregunta  - 1.6 //
replace cj_q15_norm=. if id_alex=="cj_French_0_217" //France - reduzco el cambio negativo en la pregunta  - 5.3 //
replace cj_q15_norm=. if id_alex=="cj_English_0_984_2022_2023" //France - reduzco el cambio negativo en la pregunta  - 5.3 //
replace all_q48_norm=. if id_alex=="lb_French_0_572" //France - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q49_norm=. if id_alex=="lb_French_0_83" //France - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q50_norm=. if id_alex=="lb_French_0_83" //France - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q80_norm=. if id_alex=="lb_French_0_576_2017_2018_2019_2021_2022_2023" //France - reduzco el cambio negativo en la pregunta  - 7.2 //
replace cj_q20o_norm=. if id_alex=="cj_French_1_752" //France - reduzco el cambio positivo en la pregunta  - 8.4 //
replace cj_q20o_norm=. if id_alex=="cj_French_0_1277" //France - reduzco el cambio positivo en la pregunta  - 8.4 //
replace cj_q20o_norm=. if id_alex=="cj_French_0_778" //France - reduzco el cambio positivo en la pregunta  - 8.4 //
replace cj_q40b_norm=. if id_alex=="cj_French_1_851_2023" //France - reduzco el cambio positivo en la pregunta  - 8.6 //
replace cj_q40c_norm=. if id_alex=="cj_French_1_851_2023" //France - reduzco el cambio positivo en la pregunta  - 8.6 //

*Gabon
drop if id_alex=="cj_French_1_921" //Gabon (muy positivo)
drop if id_alex=="cc_French_0_63_2022_2023" //Gabon (muy negativo)
replace lb_q23a_norm=. if country=="Gabon" /*Gabon*/
drop if id_alex=="cc_English_1_1450_2023" //Gabon: Highest CC
foreach v in lb_q16a_norm lb_q16b_norm lb_q16c_norm lb_q16d_norm lb_q16f_norm {
	replace `v'=. if id_alex=="lb_French_1_477" //Gabon: Removing 1s. Outliers in questions
}
foreach v in ph_q6a_norm ph_q6b_norm ph_q6c_norm ph_q6d_norm ph_q6e_norm ph_q6f_norm {
	replace `v'=. if id_alex=="ph_French_0_195" //Gabon: Removing 1s. Outliers in questions
}
foreach v in cj_q12a_norm cj_q12b_norm cj_q12c_norm cj_q12d_norm cj_q12e_norm cj_q12f_norm {
	replace `v'=. if id_alex=="cj_French_1_921" //Gabon: Removing 1s. Outliers in questions
}
replace cj_q21g_norm=. if id_alex=="cj_French_0_476_2022_2023" //Gabon: Removing highest score. 
replace cj_q20m_norm=. if id_alex=="cj_French_1_921" //Gabon: Removing highest score. 
replace cj_q34a_norm=. if id_alex=="cj_English_1_695_2023" //Gabon - reduzco el cambio positivo en la pregunta  - 2.3 //
replace cj_q34b_norm=. if id_alex=="cj_English_1_695_2023" //Gabon - reduzco el cambio positivo en la pregunta  - 2.3 //
replace cj_q34e_norm=. if id_alex=="cj_English_1_695_2023" //Gabon - reduzco el cambio positivo en la pregunta  - 2.3 //
replace cj_q18a_norm=. if id_alex=="cj_French_0_476_2022_2023" //Gabon - reduzco el cambio positivo en la pregunta  - 2.3 //
replace all_q96_norm=. if id_alex=="lb_French_1_477" //Gabon - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cj_French_0_764_2022_2023" //Gabon - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q37_norm=. if id_alex=="cc_French_0_186_2022_2023" //Gabon - reduzco el cambio positivo en la pregunta  - 3.1 //
replace all_q37_norm=. if id_alex=="cc_French_0_48_2022_2023" //Gabon - reduzco el cambio positivo en la pregunta  - 3.1 //
replace cc_q32i_norm=. if id_alex=="cc_French_0_186_2022_2023" //Gabon - reduzco el cambio positivo en la pregunta  - 3.1 //
replace cc_q39b_norm=. if id_alex=="cc_French_0_186_2022_2023" //Gabon - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39d_norm=. if id_alex=="cc_French_0_186_2022_2023" //Gabon - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q9c_norm=. if id_alex=="cc_French_0_186_2022_2023" //Gabon - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cc_q40a_norm=. if id_alex=="cc_French_0_186_2022_2023" //Gabon - reduzco el cambio positivo en la pregunta  - 3.4 //
replace all_q29_norm=. if id_alex=="cc_French_0_48_2022_2023" //Gabon - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q14_norm=. if id_alex=="cc_French_0_1083_2022_2023" //Gabon - reduzco el cambio positivo en la pregunta  - 4.7 //
replace lb_q23d_norm=. if id_alex=="lb_French_1_477" //Gabon - reduzco el cambio positivo en la pregunta  - 4.8 //
replace lb_q19a_norm=.6666667 if id_alex=="lb_French_0_393_2022_2023" //Gabon - reduzco el cambio positivo en la pregunta  - 6.4 //
replace cc_q10_norm=. if id_alex=="cc_French_0_208_2022_2023" //Gabon - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q11a_norm=. if id_alex=="cc_French_0_208_2022_2023" //Gabon - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q16a_norm=. if id_alex=="cc_French_0_208_2022_2023" //Gabon - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q14a_norm=. if id_alex=="cc_French_0_208_2022_2023" //Gabon - reduzco el cambio negativo en la pregunta  - 6.5 //
replace all_q6_norm=. if id_alex=="cc_French_0_222_2022_2023" //Gabon - reduzco el cambio negativo en la pregunta  - 7.4 //
replace cc_q11a_norm=. if id_alex=="cc_French_0_119_2022_2023" //Gabon - reduzco el cambio negativo en la pregunta  - 7.4 //
replace all_q86_norm=. if id_alex=="cc_French_0_48_2022_2023" //Gabon - reduzco el cambio negativo en la pregunta  - 7.6 //
replace all_q87_norm=. if id_alex=="cc_French_0_48_2022_2023" //Gabon - reduzco el cambio negativo en la pregunta  - 7.6 //
replace cj_q40b_norm=. if id_alex=="cj_English_1_695_2023" //Gabon - reduzco el cambio negativo en la pregunta  - 8.6 //
replace cj_q40c_norm=. if id_alex=="cj_English_1_695_2023" //Gabon - reduzco el cambio negativo en la pregunta  - 8.6 //

*The Gambia
replace cj_q38_norm=. if country=="Gambia" //The Gambia
replace cj_q21d_norm=. if country=="Gambia" //The Gambia
replace cj_q6d_norm=. if country=="Gambia" //The Gambia
replace cj_q31g_norm=. if id_alex=="cj_English_1_372" //Gambia: Removing 0. Outlier
replace cj_q42d_norm=. if id_alex=="cj_English_1_372" //Gambia: Removing 0. Outlier
replace all_q80_norm=. if all_q80_norm==0 & country=="Gambia" //Gambia: Removing 0. Outlier
replace all_q81_norm=. if all_q81_norm==0 & country=="Gambia" //Gambia: Removing 0. Outlier
replace cj_q28_norm=. if id_alex=="cj_English_1_372" //Gambia: Highest score in question. 
replace all_q53_norm=. if id_alex=="cc_English_1_1142_2023" //Gambia - reduzco el cambio positivo en la pregunta  - 1.5 //
replace all_q53_norm=. if id_alex=="lb_English_0_776_2019_2021_2022_2023" //Gambia - reduzco el cambio positivo en la pregunta  - 1.5 //
replace all_q96_norm=. if id_alex=="cc_English_1_1142_2023" //Gambia - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_1_1006" //Gambia - reduzco el cambio positivo en la pregunta  - 2.4 //
replace cj_q10_norm=. if id_alex=="cj_English_1_211_2022_2023" //Gambia - reduzco el cambio negativo en la pregunta  - 4.2 //
replace all_q29_norm=. if id_alex=="cj_English_1_211_2022_2023" //Gambia - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cj_English_0_1164_2019_2021_2022_2023" //Gambia - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q48_norm=. if id_alex=="cc_English_0_1273_2022_2023" //Gambia - reduzco el cambio positivo en la pregunta  - 6.4 //
replace all_q49_norm=. if id_alex=="cc_English_0_1273_2022_2023" //Gambia - reduzco el cambio positivo en la pregunta  - 6.4 //
replace all_q48_norm=. if id_alex=="lb_English_0_776_2019_2021_2022_2023" //Gambia - reduzco el cambio positivo en la pregunta  - 6.4 //
replace all_q49_norm=. if id_alex=="lb_English_0_776_2019_2021_2022_2023" //Gambia - reduzco el cambio positivo en la pregunta  - 6.4 //
replace cc_q10_norm=. if id_alex=="cc_English_0_1362_2019_2021_2022_2023" //Gambia - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q10_norm=. if id_alex=="cc_English_0_141_2022_2023" //Gambia - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q16b_norm=. if id_alex=="cc_English_1_1006" //Gambia - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cj_q21h_norm=. if id_alex=="cj_English_0_628_2019_2021_2022_2023" //Gambia - reduzco el cambio positivo en la pregunta  - 8.3 //
replace cj_q28_norm=.05 if id_alex=="cj_English_1_372" //Gambia - reduzco el cambio positivo en la pregunta  - 8.3 //

*Georgia
drop if id_alex=="cj_English_0_335" //Georgia: Lowest CJ
drop if id_alex=="cj_English_0_439"  //Georgia: Lowest CJ, 2

*Germany
drop if id_alex=="cc_English_0_736" //Germany: Lowest CC
drop if id_alex=="cc_English_1_700_2023" //Germany: Lowest CC, 2
drop if id_alex=="cc_English_0_1361" //Germany: Lowest CC, 3
drop if id_alex=="cc_English_0_1372" //Germany: Lowest CC, 4
drop if id_alex=="cc_English_0_1406" //Germany (muy negativo)
drop if id_alex=="cc_English_0_1237" //Germany (muy negativo)
drop if id_alex=="cj_English_0_1098" //Germany (muy negativo)
drop if id_alex=="cj_English_0_1303" //Germany (muy negativo)
foreach v in cj_q31f_norm cj_q31g_norm cj_q42c_norm {
	replace `v'=. if id_alex=="cj_English_0_953" //Germany: Removing 1s, outliers in sub-factor
	replace `v'=. if id_alex=="cj_English_0_966" //Germany: Removing 1s, outliers in sub-factor
	replace `v'=. if id_alex=="cj_English_0_847" //Germany: Removing 1s, outliers in sub-factor
	replace `v'=. if id_alex=="cj_English_0_386_2023" //Germany: Removing 1s, outliers in sub-factor
}
foreach v in all_q62_norm all_q63_norm {
	replace `v'=. if id_alex=="cc_English_0_1660" //Germany: Removing 1s. Outlier in question
	replace `v'=. if id_alex=="cc_English_1_1491_2022_2023" //Germany: Removing 1s. Outlier in question
	replace `v'=. if id_alex=="cc_English_0_1412" //Germany: Removing 1s. Outlier in question
}
foreach v in all_q84_norm all_q85_norm cc_q13_norm all_q88_norm cc_q26a_norm {
	replace `v'=. if id_alex=="cc_English_0_1403" //Germany: Removing low scores and 0s. Outlier in sub-factor
	replace `v'=. if id_alex=="cc_English_0_1726" //Germany: Removing low scores and 0s. Outlier in sub-factor
}
replace cc_q13_norm=. if id_alex=="cc_English_0_1863" //Germany: Removing low scores in question, outlier
replace cc_q26a_norm=. if id_alex=="cc_English_0_1863" //Germany: Removing low scores in question, outlier
replace all_q88_norm=. if id_alex=="cc_English_0_1863" //Germany: Removing low scores in question, outlier
replace cc_q13_norm=. if id_alex=="cc_English_1_1330_2023" //Germany: Removing low scores in question, outlier
replace cc_q26a_norm=. if id_alex=="cc_English_1_1330_2023" //Germany: Removing low scores in question, outlier
replace all_q88_norm=. if id_alex=="cc_English_1_1330_2023" //Germany: Removing low scores in question, outlier

foreach v in all_q86_norm all_q87_norm {
	replace `v'=.  if id_alex=="cc_English_1_406" //Germany: Removing low scores in question, outlier
	replace `v'=.  if id_alex=="cc_English_0_1001" //Germany: Removing low scores in question, outlier
	replace `v'=.  if id_alex=="cc_English_0_1476" //Germany: Removing low scores in question, outlier
}
replace cc_q26b_norm=. if id_alex=="cc_English_0_1710" //Germany: Removing low scores, outlier in question
replace cc_q26b_norm=. if id_alex=="cc_English_0_1403" //Germany: Removing low scores, outlier in question
replace cc_q26b_norm=. if id_alex=="cc_English_0_1237" //Germany: Removing low scores, outlier in question
replace all_q95_norm=. if id_alex=="cc_English_1_1457_2022_2023" //Germany - reduzco el cambio positivo en la pregunta  - 2.1 //
replace all_q95_norm=. if id_alex=="cc_English_0_480_2022_2023" //Germany - reduzco el cambio positivo en la pregunta  - 2.1 //
replace all_q95_norm=. if id_alex=="cc_English_0_1710" //Germany - reduzco el cambio positivo en la pregunta  - 2.1 //
replace all_q95_norm=. if id_alex=="cc_English_0_1258" //Germany - reduzco el cambio positivo en la pregunta  - 2.1 //
replace all_q95_norm=. if id_alex=="cc_English_0_634_2023" //Germany - reduzco el cambio positivo en la pregunta  - 2.1 //
replace all_q95_norm=. if id_alex=="cc_English_1_610_2023" //Germany - reduzco el cambio positivo en la pregunta  - 2.1 //
replace all_q95_norm=. if id_alex=="lb_English_0_452" //Germany - reduzco el cambio positivo en la pregunta  - 2.1 //
replace cj_q32c_norm=. if id_alex=="cj_English_0_608_2022_2023" //Germany - reduzco el cambio positivo en la pregunta  - 2.2 //
replace cj_q24b_norm=. if id_alex=="cj_English_0_847" //Germany - reduzco el cambio positivo en la pregunta  - 2.2 //
replace all_q96_norm=. if id_alex=="cc_English_1_346_2023" //Germany - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_0_1111_2023" //Germany - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_0_326_2023" //Germany - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_1_610_2023" //Germany - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_0_1364" //Germany - reduzco el cambio positivo en la pregunta  - 2.4 //
replace cc_q39a_norm=. if id_alex=="cc_English_0_610" //Germany - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39b_norm=. if id_alex=="cc_English_0_610" //Germany - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39c_norm=. if id_alex=="cc_English_0_610" //Germany - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39d_norm=. if id_alex=="cc_English_0_1710" //Germany - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39a_norm=. if id_alex=="cc_English_1_259_2023" //Germany - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39b_norm=. if id_alex=="cc_English_1_259_2023" //Germany - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39c_norm=. if id_alex=="cc_English_1_259_2023" //Germany - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39d_norm=. if id_alex=="cc_English_1_259_2023" //Germany - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39e_norm=. if id_alex=="cc_English_1_259_2023" //Germany - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q40a_norm=. if id_alex=="cc_English_0_1150" //Germany - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cc_q40b_norm=. if id_alex=="cc_English_0_1150" //Germany - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cc_q9c_norm=. if id_alex=="cc_English_0_1141" //Germany - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cc_q40a_norm=. if id_alex=="cc_English_0_1141" //Germany - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cc_q40b_norm=. if id_alex=="cc_English_0_1141" //Germany - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cc_q39e_norm=. if id_alex=="cc_English_1_259_2023" //Germany - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cj_q31f_norm=. if id_alex=="cj_English_0_288" //Germany - reduzco el cambio positivo en la pregunta  - 4.6 //
replace cj_q31g_norm=. if id_alex=="cj_English_0_288" //Germany - reduzco el cambio positivo en la pregunta  - 4.6 //
replace cj_q31f_norm=. if id_alex=="cj_English_0_859" //Germany - reduzco el cambio positivo en la pregunta  - 4.6 //
replace cj_q31g_norm=. if id_alex=="cj_English_0_859" //Germany - reduzco el cambio positivo en la pregunta  - 4.6 //
replace cj_q31f_norm=. if id_alex=="cj_English_0_1194" //Germany - reduzco el cambio positivo en la pregunta  - 4.6 //
replace cj_q31g_norm=. if id_alex=="cj_English_0_1194" //Germany - reduzco el cambio positivo en la pregunta  - 4.6 //
replace lb_q23a_norm=. if id_alex=="lb_English_1_319" //Germany - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q23b_norm=. if id_alex=="lb_English_1_319" //Germany - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q23c_norm=. if id_alex=="lb_English_1_319" //Germany - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q23d_norm=. if id_alex=="lb_English_1_319" //Germany - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q23e_norm=. if id_alex=="lb_English_1_319" //Germany - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q3d_norm=. if id_alex=="lb_English_0_441" //Germany - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q63_norm=. if id_alex=="lb_English_0_452" //Germany - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q78_norm=. if id_alex=="lb_English_0_452" //Germany - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q80_norm=. if id_alex=="lb_English_0_452" //Germany - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q81_norm=. if id_alex=="lb_English_0_452" //Germany - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q84_norm=. if id_alex=="cc_English_0_1412" //Germany - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q84_norm=. if id_alex=="cc_English_0_1476" //Germany - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q85_norm=. if id_alex=="cc_English_0_1476" //Germany - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q84_norm=. if id_alex=="cc_English_0_1804" //Germany - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q85_norm=. if id_alex=="cc_English_0_1804" //Germany - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q85_norm=1 if id_alex=="cc_English_0_468" //Germany - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q26b_norm=. if id_alex=="cc_English_1_1330_2023" //Germany - reduzco el cambio negativo en la pregunta  - 7.6 //
replace cc_q26b_norm=. if id_alex=="cc_English_0_842" //Germany - reduzco el cambio negativo en la pregunta  - 7.6 //
replace cc_q26b_norm=. if id_alex=="cc_English_0_1362" //Germany - reduzco el cambio negativo en la pregunta  - 7.6 //
replace all_q86_norm=. if id_alex=="cc_English_0_684" //Germany - reduzco el cambio negativo en la pregunta  - 7.6 //
replace all_q86_norm=. if id_alex=="cc_English_0_1710" //Germany - reduzco el cambio negativo en la pregunta  - 7.6 //
replace all_q86_norm=. if id_alex=="cc_English_0_1623" //Germany - reduzco el cambio negativo en la pregunta  - 7.6 //
replace all_q87_norm=. if id_alex=="cc_English_0_1543" //Germany - reduzco el cambio negativo en la pregunta  - 7.6 //
replace all_q87_norm=. if id_alex=="cc_English_0_1804" //Germany - reduzco el cambio negativo en la pregunta  - 7.6 //
replace all_q87_norm=. if id_alex=="cc_English_0_1623" //Germany - reduzco el cambio negativo en la pregunta  - 7.6 //
replace cj_q7a_norm=. if id_alex=="cj_English_1_604_2023" //Germany - reduzco el cambio negativo en la pregunta  - 8.2 //
replace cj_q7a_norm=. if id_alex=="cj_English_0_1194" //Germany - reduzco el cambio negativo en la pregunta  - 8.2 //
replace cj_q40b_norm=. if id_alex=="cj_English_0_1014" //Germany - reduzco el cambio negativo en la pregunta  - 8.6 //
replace cj_q40c_norm=. if id_alex=="cj_English_0_1014" //Germany - reduzco el cambio negativo en la pregunta  - 8.6 //
replace cj_q20m_norm=. if id_alex=="cj_English_0_1014" //Germany - reduzco el cambio negativo en la pregunta  - 8.6 //

*Ghana

*Greece
drop if id_alex=="cc_English_0_1057" //Greece: Lowest CC
drop if id_alex=="cc_English_0_1425" //Greece: Lowest CC, 2
drop if id_alex=="cc_English_0_1635" //Greece: Lowest CC, 3
drop if id_alex=="cj_English_0_320" //Greece: Lowest CJ
drop if id_alex=="cj_English_0_169" //Greece: Lowest CJ, 2
drop if id_alex=="cj_English_0_545" //Greece (muy negativo)
drop if id_alex=="cj_English_0_225" //Greece (muy negativo)
drop if id_alex=="cc_English_0_1096" //Greece (muy negativo, f1)
foreach v in all_q9_norm cj_q38_norm cj_q36c_norm cj_q8_norm  {
	replace `v'=. if id_alex=="cj_English_0_628" //Greece: Removing 0s, outlier in questions
}
replace cc_q33_norm=. if id_alex=="cc_English_0_1163" //Greece: Removing 0 in question, outlier
replace cc_q33_norm=. if id_alex=="cc_English_0_1790" //Greece: Removing 0 in question, outlier
replace cj_q8_norm=. if id_alex=="cj_English_0_395" //Greece: Removing 0 in question, outlier
replace cj_q8_norm=. if id_alex=="cj_English_1_466" //Greece: Removing 0 in question, outlier
foreach v in cj_q38_norm cj_q36c_norm {
	replace `v'=. if id_alex=="cj_English_0_1065" //Greece: Removing 0s, outlier in questions
	replace `v'=. if id_alex=="cj_English_0_276" //Greece: Removing 0s, outlier in questions
}
foreach v in cj_q38_norm all_q9_norm {
	replace `v'=. if id_alex=="cj_English_0_206" //Greece: Removing 0s, outlier in questions
}
foreach v in all_q13_norm all_q14_norm {
	replace `v'=. if id_alex=="cc_English_0_1514" //Greece: Removing 0s, outlier in sub-factor
	replace `v'=. if id_alex=="lb_English_1_683_2023" //Greece: Removing 0s, outlier in sub-factor
	replace `v'=. if id_alex=="cc_English_0_1096" //Greece: Removing 0s, outlier in sub-factor
	replace `v'=. if id_alex=="cj_English_0_662" //Greece: Removing 0s, outlier in sub-factor
	replace `v'=. if id_alex=="cj_English_0_15" //Greece: Removing 0s, outlier in sub-factor
	replace `v'=. if id_alex=="cj_English_0_545" //Greece: Removing 0s, outlier in sub-factor
	replace `v'=. if id_alex=="cj_English_0_225" //Greece: Removing 0s, outlier in sub-factor
}
foreach v in all_q17_norm all_q94_norm {
	replace `v'=. if id_alex=="lb_English_1_683_2023" //Greece: Removing 0s, outlier in sub-factor
}
foreach v in all_q15_norm all_q16_norm all_q94_norm {
	replace `v'=. if id_alex=="cc_English_1_517" //Greece: Removing 0s, outlier in sub-factor
}
foreach v in all_q15_norm all_q16_norm all_q17_norm {
	replace `v'=. if id_alex=="cj_English_0_545" //Greece: Removing 0s, outlier in sub-factor
}
foreach v in all_q19_norm all_q21_norm {
	replace `v'=. if id_alex=="cc_English_0_942" //Greece: Removing 0s, outlier in sub-factor	
	replace `v'=. if id_alex=="cc_English_0_1514" //Greece: Removing 0s, outlier in sub-factor
}
replace all_q20_norm=. if id_alex=="cj_English_0_1341"

foreach v in all_q15_norm all_q16_norm all_q94_norm {
	replace `v'=. if id_alex=="cc_English_0_1096" //Greece: Removing low scores. Outlier in sub-factor
	replace `v'=. if id_alex=="cc_English_0_942" //Greece: Removing low scores. Outlier in sub-factor
}
replace all_q94_norm=. if id_alex=="lb_English_0_509" //Greece: Removing 0.
foreach v in cj_q10_norm all_q15_norm all_q17_norm all_q94_norm {
	replace `v'=. if id_alex=="cj_English_0_668" //Greece: Removing low scores. Outlier in sub-factor
}
replace all_q19_norm=. if id_alex=="cj_English_0_545" //Greece: Removing 0.
replace all_q21_norm=. if id_alex=="cc_English_0_1096" //Greece: Removing 0.
replace all_q96_norm=. if all_q96_norm==1 & country=="Greece" //Greece: Removing 1s
foreach v in lb_q16a_norm lb_q16b_norm lb_q16c_norm lb_q16d_norm lb_q16e_norm lb_q16f_norm lb_q23a_norm lb_q23b_norm lb_q23c_norm lb_q23d_norm lb_q23e_norm lb_q23f_norm lb_q23g_norm {
	replace `v'=. if id_alex=="lb_English_0_594" //Greece: Removing 1s, outlier in sub-factor
}
foreach v in cj_q21a_norm cj_q21e_norm cj_q21g_norm cj_q21h_norm {
	replace `v'=. if id_alex=="cj_English_0_1341" //Greece: Removing 1s, outlier in sub-factor
}

replace all_q1_norm=. if id_alex=="cc_English_1_1383_2023" //Greece - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q1_norm=. if id_alex=="cc_English_1_269_2023" //Greece - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q1_norm=. if id_alex=="cc_English_1_838_2023" //Greece - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q1_norm=. if id_alex=="cc_English_0_1011_2023" //Greece - reduzco el cambio negativo en la pregunta  - 1.2 //
replace cc_q33_norm=. if id_alex=="cc_English_0_942" //Greece - reduzco el cambio negativo en la pregunta  - 1.4 //
replace all_q9_norm=. if id_alex=="cc_English_0_942" //Greece - reduzco el cambio negativo en la pregunta  - 1.4 //
replace cj_q8_norm=. if id_alex=="cj_English_0_185_2022_2023" //Greece - reduzco el cambio negativo en la pregunta  - 1.4 //
replace all_q10_norm=. if id_alex=="cj_English_0_662" //Greece - reduzco el cambio negativo en la pregunta  - 1.5 //
replace all_q11_norm=. if id_alex=="cj_English_0_662" //Greece - reduzco el cambio negativo en la pregunta  - 1.5 //
replace all_q12_norm=. if id_alex=="cj_English_0_662" //Greece - reduzco el cambio negativo en la pregunta  - 1.5 //
replace all_q10_norm=. if id_alex=="cj_English_0_668" //Greece - reduzco el cambio negativo en la pregunta  - 1.5 //
replace all_q11_norm=. if id_alex=="cj_English_0_668" //Greece - reduzco el cambio negativo en la pregunta  - 1.5 //
replace all_q12_norm=. if id_alex=="cj_English_0_668" //Greece - reduzco el cambio negativo en la pregunta  - 1.5 //
replace all_q13_norm=. if id_alex=="cj_English_0_584" //Greece - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q13_norm=. if id_alex=="cj_English_0_1065" //Greece - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q13_norm=. if id_alex=="cj_English_0_668" //Greece - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q14_norm=. if id_alex=="cc_English_0_942" //Greece - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q15_norm=. if id_alex=="cc_English_0_1514" //Greece - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q16_norm=. if id_alex=="cc_English_0_1514" //Greece - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q15_norm=. if id_alex=="cc_English_0_1790" //Greece - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q16_norm=. if id_alex=="cc_English_0_1790" //Greece - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q15_norm=. if id_alex=="cj_English_0_662" //Greece - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q16_norm=. if id_alex=="cj_English_0_662" //Greece - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q17_norm=. if id_alex=="cj_English_0_662" //Greece - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q17_norm=. if id_alex=="cj_English_0_584" //Greece - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q18_norm=. if id_alex=="cj_English_0_584" //Greece - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q18_norm=. if id_alex=="cj_English_0_646" //Greece - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q18_norm=. if id_alex=="cj_French_0_1184" //Greece - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q20_norm=. if id_alex=="cc_English_0_1382" //Greece - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q21_norm=. if id_alex=="cj_English_0_662" //Greece - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q21_norm=. if id_alex=="cj_English_0_584" //Greece - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q96_norm=. if id_alex=="lb_English_0_608" //Greece - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="lb_English_0_594" //Greece - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_0_863" //Greece - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_0_1402" //Greece - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cj_English_1_607" //Greece - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cj_English_0_1341" //Greece - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_0_910" //Greece - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_0_486" //Greece - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=0 if id_alex=="cc_English_1_1050" //Greece - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=0 if id_alex=="cj_English_1_707" //Greece - reduzco el cambio positivo en la pregunta  - 2.4 //
replace cc_q39c_norm=. if id_alex=="cc_English_0_942" //Greece - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39d_norm=. if id_alex=="cc_English_0_942" //Greece - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39e_norm=. if id_alex=="cc_English_0_942" //Greece - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q9c_norm=. if id_alex=="cc_English_0_1514" //Greece - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cc_q40a_norm=. if id_alex=="cc_English_0_1514" //Greece - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cc_q40b_norm=. if id_alex=="cc_English_0_1514" //Greece - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cc_q9c_norm=. if id_alex=="cc_English_0_1828" //Greece - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cc_q40a_norm=. if id_alex=="cc_English_0_1828" //Greece - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cc_q40b_norm=. if id_alex=="cc_English_0_1828" //Greece - reduzco el cambio negativo en la pregunta  - 3.4 //
replace all_q29_norm=. if id_alex=="cj_English_0_584" //Greece - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cj_English_0_584" //Greece - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cj_English_0_15" //Greece - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cj_English_0_15" //Greece - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cj_English_0_555" //Greece - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q31_norm=. if id_alex=="cj_English_0_581" //Greece - reduzco el cambio negativo en la pregunta  - 4.7 //
replace lb_q23f_norm=. if id_alex=="lb_English_0_393_2018_2019_2021_2022_2023" //Greece - reduzco el cambio positivo en la pregunta  - 4.7 //
replace lb_q23g_norm=. if id_alex=="lb_English_0_393_2018_2019_2021_2022_2023" //Greece - reduzco el cambio positivo en la pregunta  - 4.7 //
replace cj_q15_norm=. if id_alex=="cj_English_0_934" //Greece - reduzco el cambio positivo en la pregunta  - 5.3 //
replace cj_q15_norm=. if id_alex=="cj_English_0_1162" //Greece - reduzco el cambio positivo en la pregunta  - 5.3 //
replace cj_q15_norm=. if id_alex=="cj_English_0_1162" //Greece - reduzco el cambio positivo en la pregunta  - 5.3 //
replace cj_q15_norm=. if id_alex=="cj_English_0_628" //Greece - reduzco el cambio positivo en la pregunta  - 5.3 //
replace all_q62_norm=. if id_alex=="cc_English_0_1786" //Greece - reduzco el cambio positivo en la pregunta  - 6.3 //
replace all_q63_norm=. if id_alex=="cc_English_0_1786" //Greece - reduzco el cambio positivo en la pregunta  - 6.3 //
replace all_q62_norm=. if id_alex=="cc_English_0_1310" //Greece - reduzco el cambio positivo en la pregunta  - 6.3 //
replace all_q63_norm=. if id_alex=="cc_English_0_1310" //Greece - reduzco el cambio positivo en la pregunta  - 6.3 //
replace lb_q19a_norm=. if id_alex=="lb_English_1_152_2023" //Greece - reduzco el cambio positivo en la pregunta  - 6.4 //
replace all_q48_norm=. if id_alex=="cc_English_0_1011_2023" //Greece - reduzco el cambio positivo en la pregunta  - 6.4 //
replace all_q49_norm=. if id_alex=="cc_English_0_1011_2023" //Greece - reduzco el cambio positivo en la pregunta  - 6.4 //
replace all_q50_norm=. if id_alex=="cc_English_0_1011_2023" //Greece - reduzco el cambio positivo en la pregunta  - 6.4 //
replace all_q3_norm=. if id_alex=="cc_English_0_942" //Greece - reduzco el cambio negativo en la pregunta  - 7.4 //
replace all_q3_norm=. if id_alex=="cj_English_0_206" //Greece - reduzco el cambio negativo en la pregunta  - 7.4 //
replace all_q3_norm=. if id_alex=="cj_English_0_662" //Greece - reduzco el cambio negativo en la pregunta  - 7.4 //
replace all_q85_norm=. if id_alex=="cc_English_0_942" //Greece - reduzco el cambio positivo en la pregunta  - 7.5 //
replace all_q85_norm=. if id_alex=="cc_English_0_1445" //Greece - reduzco el cambio positivo en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="cc_English_0_942" //Greece - reduzco el cambio positivo en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="lb_English_0_594" //Greece - reduzco el cambio positivo en la pregunta  - 7.5 //
replace all_q89_norm=. if id_alex=="lb_English_0_594" //Greece - reduzco el cambio negativo en la pregunta  - 7.7 //
replace all_q89_norm=. if id_alex=="cc_English_0_1310" //Greece - reduzco el cambio negativo en la pregunta  - 7.7 //
replace cc_q14a_norm=. if id_alex=="cc_English_0_1790" //Greece - reduzco el cambio negativo en la pregunta  - 7.7 //
replace cc_q14b_norm=. if id_alex=="cc_English_0_1790" //Greece - reduzco el cambio negativo en la pregunta  - 7.7 //
replace cj_q21h_norm=. if id_alex=="cj_English_0_1162" //Greece - reduzco el cambio negativo en la pregunta  - 8.3 //
replace cj_q21h_norm=. if id_alex=="cj_English_0_681" //Greece - reduzco el cambio negativo en la pregunta  - 8.3 //
replace cj_q28_norm=. if id_alex=="cj_English_0_395" //Greece - reduzco el cambio negativo en la pregunta  - 8.3 //

*Grenada
replace all_q69_norm=. if country=="Grenada" /*Grenada*/
replace all_q84_norm=. if country=="Grenada" /*Grenada*/
replace cc_q13_norm=. if country=="Grenada" /*Grenada*/
replace cj_q22e_norm=. if country=="Grenada" /*Grenada*/
replace cj_q6b_norm=. if country=="Grenada" /*Grenada*/
replace cj_q6d_norm=. if country=="Grenada" /*Grenada*/
replace cj_q42c_norm=. if country=="Grenada" /*Grenada*/
replace cj_q42d_norm=. if country=="Grenada" /*Grenada*/
replace cj_q24c_norm=. if country=="Grenada" /*Grenada*/
replace all_q20_norm=. if country=="Grenada" //Grenada
replace cj_q9_norm=. if country=="Grenada"  //Grenada
replace cj_q11b_norm=. if country=="Grenada" //Grenada
replace cj_q31e_norm=. if id_alex=="cj_English_1_1075_2023" //Grenada: Removing 0s
replace all_q62_norm=. if id_alex=="cc_English_1_863" //Grenada: Removing 0s
replace all_q63_norm=. if id_alex=="cc_English_1_863" //Grenada: Removing 0s
replace cj_q20o_norm=. if id_alex=="cj_English_1_863" //Grenada: Removing 0s
replace cj_q31f_norm=. if id_alex=="cj_English_1_863" //Grenada: Removing 1. Outlier
replace cj_q31g_norm=. if id_alex=="cj_English_1_863" //Grenada: Removing 1. Outlier
replace cc_q33_norm=0 if id_alex=="cc_English_1_1108_2018_2019_2021_2022_2023" //Grenada - reduzco el cambio positivo en la pregunta  - 1.4 //
replace all_q9_norm=. if id_alex=="cc_English_0_1548_2016_2017_2018_2019_2021_2022_2023" //Grenada - reduzco el cambio positivo en la pregunta  - 1.4 //
replace all_q9_norm=. if id_alex=="cc_English_0_1548_2016_2017_2018_2019_2021_2022_2023" //Grenada - reduzco el cambio positivo en la pregunta  - 1.4 //
replace cj_q38_norm=0 if id_alex=="cj_English_1_547_2018_2019_2021_2022_2023" //Grenada - reduzco el cambio positivo en la pregunta  - 1.4 //
replace cj_q11a_norm=.3333333 if id_alex=="cj_English_1_1075_2023" //Grenada - reduzco el cambio positivo en la pregunta  - 4.2 //
replace cj_q10_norm=.3333333 if id_alex=="cj_English_1_1075_2023" //Grenada - reduzco el cambio positivo en la pregunta  - 4.2 //
replace cj_q22b_norm=. if id_alex=="cj_English_1_863" //Grenada - reduzco el cambio positivo en la pregunta  - 4.3 //
replace cj_q25b_norm=. if id_alex=="cj_English_1_863" //Grenada - reduzco el cambio positivo en la pregunta  - 4.3 //
replace cj_q25c_norm=. if id_alex=="cj_English_1_863" //Grenada - reduzco el cambio positivo en la pregunta  - 4.3 //
replace cj_q25a_norm=. if id_alex=="cj_English_1_863" //Grenada - reduzco el cambio positivo en la pregunta  - 4.3 //
replace cj_q31c_norm=. if id_alex=="cj_English_1_863" //Grenada - reduzco el cambio positivo en la pregunta  - 4.3 //
replace cj_q31d_norm=. if id_alex=="cj_English_1_863" //Grenada - reduzco el cambio positivo en la pregunta  - 4.3 //
replace cj_q29a_norm=. if id_alex=="cj_English_1_863" //Grenada - reduzco el cambio positivo en la pregunta  - 4.3 //
replace cj_q29b_norm=. if id_alex=="cj_English_1_863" //Grenada - reduzco el cambio positivo en la pregunta  - 4.3 //
replace cj_q22a_norm=. if id_alex=="cj_English_1_863" //Grenada - reduzco el cambio positivo en la pregunta  - 4.3 //
replace cj_q21d_norm=. if id_alex=="cj_English_1_863" //Grenada - reduzco el cambio positivo en la pregunta  - 4.3 //
replace all_q76_norm=. if id_alex=="cc_English_1_790" //Grenada - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q82_norm=. if id_alex=="cc_English_1_1303_2023" //Grenada - reduzco el cambio negativo en la pregunta  - 7.2 //
replace cc_q14a_norm=. if id_alex=="cc_English_1_790" //Grenada - reduzco el cambio negativo en la pregunta  - 7.7 //
replace cc_q14b_norm=. if id_alex=="cc_English_1_790" //Grenada - reduzco el cambio negativo en la pregunta  - 7.7 //

*Guatemala
drop if id_alex=="cc_Spanish_0_550" //Guatemala: Highest CC
drop if id_alex=="lb_English_1_423_2023" //Guatemala: Lowest expert in F1 and F4
drop if id_alex=="lb_Spanish_1_43" //Guatemala: Lowest expert in F1 and F4
foreach v in all_q1_norm all_q2_norm all_q20_norm all_q21_norm {
	replace `v'=. if id_alex=="lb_English_1_423_2023" //Guatemala: Removing 0s in questions
}
replace all_q29_norm=. if id_alex=="cj_Spanish_0_1010" //Guatemala: Removing 0s in questions
replace all_q30_norm=. if id_alex=="cj_Spanish_0_1010" //Guatemala: Removing 0s in questions
foreach v in all_q1_norm all_q2_norm all_q20_norm all_q21_norm {
	replace `v'=. if id_alex=="lb_Spanish_1_43" //Guatemala: Removing 0s in questions
}
replace all_q1_norm=. if all_q1_norm==0 & country=="Guatemala" //Guatemala: Removing 0s in question
replace all_q2_norm=. if all_q2_norm==0 & country=="Guatemala" //Guatemala: Removing 0s in question
replace all_q20_norm=. if all_q20_norm==0 & country=="Guatemala" //Guatemala: Removing 0s in questi
replace all_q21_norm=. if all_q21_norm==0 & country=="Guatemala" //Guatemala: Removing 0s in question
replace all_q14_norm=. if all_q14_norm==0 & country=="Guatemala" //Guatemala: Removing 0s in question
replace all_q15_norm=. if all_q15_norm==0 & country=="Guatemala" //Guatemala: Removing 0s in question
replace all_q16_norm=. if all_q16_norm==0 & country=="Guatemala" //Guatemala: Removing 0s in question
foreach v in all_q22_norm all_q23_norm all_q24_norm all_q25_norm all_q26_norm all_q27_norm all_q8_norm {
	replace `v'=. if id_alex=="cc_Spanish_1_747" //Guatemala: Removing 0s from questions. Outlier
}
replace all_q27_norm=. if all_q27_norm==0 & country=="Guatemala" //Guatemala: Removing 0s from question.
replace all_q18_norm=. if all_q18_norm==0  & country=="Guatemala" //Guatemala: Removing 0s from question.
foreach v in all_q13_norm all_q14_norm all_q15_norm all_q16_norm all_q17_norm cj_q10_norm all_q18_norm all_q94_norm all_q19_norm all_q20_norm all_q21_norm {
	replace `v'=. if id_alex=="lb_Spanish_0_487" //Guatemala: Removing 0s from questions.
}
foreach v in all_q13_norm all_q14_norm all_q15_norm all_q16_norm all_q17_norm cj_q10_norm all_q18_norm all_q94_norm all_q19_norm all_q20_norm all_q21_norm {
	replace `v'=. if id_alex=="lb_Spanish_1_630" //Guatemala: Removing 0s from questions.
}


replace cj_q38_norm=. if id_alex=="cj_English_0_569_2023" //Guatemala - reduzco el cambio negativo en la pregunta  - 1.4 //
replace cj_q38_norm=. if id_alex=="cj_Spanish_1_458_2023" //Guatemala - reduzco el cambio negativo en la pregunta  - 1.4 //
replace cj_q38_norm=. if id_alex=="cj_English_1_1000_2023" //Guatemala - reduzco el cambio negativo en la pregunta  - 1.4 //
replace all_q22_norm=. if id_alex=="lb_Spanish_1_138" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q23_norm=. if id_alex=="lb_Spanish_1_138" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q24_norm=. if id_alex=="lb_Spanish_1_138" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q25_norm=. if id_alex=="lb_Spanish_1_138" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q26_norm=. if id_alex=="lb_Spanish_1_138" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q27_norm=. if id_alex=="lb_Spanish_1_138" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q8_norm=. if id_alex=="lb_Spanish_1_138" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q22_norm=. if id_alex=="cc_English_1_1110_2022_2023" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q23_norm=. if id_alex=="cc_English_1_1110_2022_2023" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q24_norm=. if id_alex=="cc_English_1_1110_2022_2023" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q25_norm=. if id_alex=="cc_English_1_1110_2022_2023" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q26_norm=. if id_alex=="cc_English_1_1110_2022_2023" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q27_norm=. if id_alex=="cc_English_1_1110_2022_2023" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q8_norm=. if id_alex=="cc_English_1_1110_2022_2023" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q22_norm=. if id_alex=="cc_Spanish_0_413" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q23_norm=. if id_alex=="cc_Spanish_0_413" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q24_norm=. if id_alex=="cc_Spanish_0_413" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q25_norm=. if id_alex=="cc_Spanish_0_413" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q26_norm=. if id_alex=="cc_Spanish_0_413" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q27_norm=. if id_alex=="cc_Spanish_0_413" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q8_norm=. if id_alex=="cc_Spanish_0_413" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q22_norm=. if id_alex=="cj_Spanish_0_406" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q23_norm=. if id_alex=="cj_Spanish_0_406" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q24_norm=. if id_alex=="cj_Spanish_0_406" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q25_norm=. if id_alex=="cj_Spanish_0_406" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q26_norm=. if id_alex=="cj_Spanish_0_406" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q27_norm=. if id_alex=="cj_Spanish_0_406" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q22_norm=. if id_alex=="lb_Spanish_0_193" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q23_norm=. if id_alex=="lb_Spanish_0_193" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q24_norm=. if id_alex=="lb_Spanish_0_193" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q25_norm=. if id_alex=="lb_Spanish_0_193" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q26_norm=. if id_alex=="lb_Spanish_0_193" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace all_q27_norm=. if id_alex=="lb_Spanish_0_193" //Guatemala - reduzco el cambio positivo en la pregunta  - 1.7 (Q) //
replace cc_q39a_norm=. if id_alex=="cc_Spanish_0_1984" //Guatemala - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39b_norm=. if id_alex=="cc_Spanish_0_1984" //Guatemala - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39c_norm=. if id_alex=="cc_Spanish_0_1984" //Guatemala - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39d_norm=. if id_alex=="cc_Spanish_0_1984" //Guatemala - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39e_norm=. if id_alex=="cc_Spanish_0_1984" //Guatemala - reduzco el cambio positivo en la pregunta  - 3.2 //
replace all_q29_norm=. if id_alex=="cc_Spanish_0_790_2023" //Guatemala - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cj_Spanish_0_171_2022_2023" //Guatemala - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cj_Spanish_0_171_2022_2023" //Guatemala - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cj_Spanish_1_891" //Guatemala - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cj_Spanish_1_891" //Guatemala - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q31_norm=. if id_alex=="cj_Spanish_0_614" //Guatemala - reduzco el cambio positivo en la pregunta  - 4.7 //
replace all_q32_norm=. if id_alex=="cj_Spanish_0_614" //Guatemala - reduzco el cambio positivo en la pregunta  - 4.7 //
replace all_q31_norm=. if id_alex=="cj_Spanish_0_1010" //Guatemala - reduzco el cambio positivo en la pregunta  - 4.7 //
replace all_q49_norm=. if id_alex=="lb_Spanish_0_708_2017_2018_2019_2021_2022_2023" //Guatemala - reduzco el cambio positivo en la pregunta  - 6.4 //
replace all_q49_norm=. if id_alex=="lb_Spanish_0_708_2017_2018_2019_2021_2022_2023" //Guatemala - reduzco el cambio positivo en la pregunta  - 6.4 //
replace all_q65_norm=. if id_alex=="lb_Spanish_0_22_2023" //Guatemala - reduzco el cambio positivo en la pregunta  - 7.1 //
replace all_q65_norm=. if id_alex=="lb_Spanish_0_115_2023" //Guatemala - reduzco el cambio positivo en la pregunta  - 7.1 //
replace cc_q22a_norm=. if id_alex=="cc_English_1_1110_2022_2023" //Guatemala - reduzco el cambio positivo en la pregunta  - 7.1 //
replace cc_q22b_norm=. if id_alex=="cc_English_1_1110_2022_2023" //Guatemala - reduzco el cambio positivo en la pregunta  - 7.1 //
replace cc_q22c_norm=. if id_alex=="cc_English_1_1110_2022_2023" //Guatemala - reduzco el cambio positivo en la pregunta  - 7.1 //
replace all_q69_norm=. if id_alex=="cc_Spanish_0_1308" //Guatemala - reduzco el cambio positivo en la pregunta  - 7.1 //
replace all_q3_norm=. if id_alex=="cc_English_1_1110_2022_2023" //Guatemala - reduzco el cambio positivo en la pregunta  - 7.4 //
replace all_q4_norm=. if id_alex=="cc_English_1_1110_2022_2023" //Guatemala - reduzco el cambio positivo en la pregunta  - 7.4 //
replace all_q7_norm=. if id_alex=="cc_English_1_1110_2022_2023" //Guatemala - reduzco el cambio positivo en la pregunta  - 7.4 //
replace cj_q21h_norm=. if id_alex=="cj_English_1_1000_2023" //Guatemala - reduzco el cambio positivo en la pregunta  - 8.3 //
replace cj_q21h_norm=. if id_alex=="cj_Spanish_0_614" //Guatemala - reduzco el cambio positivo en la pregunta  - 8.3 //
replace cj_q28_norm=. if id_alex=="cj_Spanish_0_171_2022_2023" //Guatemala - reduzco el cambio positivo en la pregunta  - 8.3 //
replace cj_q20m_norm=. if id_alex=="cj_Spanish_0_171_2022_2023" //Guatemala - reduzco el cambio negativo en la pregunta  - 8.6 //
replace cj_q20m_norm=. if id_alex=="cj_Spanish_1_725_2023" //Guatemala - reduzco el cambio negativo en la pregunta  - 8.6 //
replace cj_q20m_norm=. if id_alex=="cj_Spanish_1_126" //Guatemala - reduzco el cambio negativo en la pregunta  - 8.6 //



*Guinea
drop if id_alex=="cj_French_0_67" //Guinea (muy positivo)
replace cj_q38_norm=. if country=="Guinea" //Guinea
replace all_q96_norm=. if id_alex=="cj_English_1_1014" //Guinea: Removing 1 in question
foreach v in cj_q32b_norm cj_q24b_norm cj_q24c_norm cj_q33a_norm cj_q33b_norm cj_q33c_norm cj_q33d_norm cj_q33e_norm {
	replace `v'=. if id_alex=="cj_French_0_522" //Guinea: Outlier in sub-factor
}
foreach v in cj_q31f_norm cj_q31g_norm cj_q42c_norm cj_q42d_norm {
	replace `v'=. if id_alex=="cj_English_0_751" //Guinea: Outlier in sub-factor. Os 
}

*Guyana
replace all_q70_norm=. if country=="Guyana" //Guyana
drop if id_alex=="cj_English_1_587" //Guyana (muy positivo)
replace all_q30_norm=. if id_alex=="cc_English_0_1202_2017_2018_2019_2021_2022_2023" //Guyana - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cj_English_0_186_2017_2018_2019_2021_2022_2023" //Guyana - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cj_English_0_186_2017_2018_2019_2021_2022_2023" //Guyana - reduzco el cambio negativo en la pregunta  - 4.5 //
replace cj_q21h_norm=. if id_alex=="cj_English_0_84" //Guyana - reduzco el cambio positivo en la pregunta  - 8.3 //
replace cj_q28_norm=. if id_alex=="cj_English_0_1188_2018_2019_2021_2022_2023" //Guyana - reduzco el cambio positivo en la pregunta  - 8.3 //

*Haiti
replace all_q89_norm=. if country=="Haiti" //Haiti
foreach v in cc_q39a_norm cc_q39b_norm cc_q39d_norm {
	replace `v'=. if id_alex=="cc_English_0_771" //Haiti: Removing 0s in question. Outliers
}
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="cc_English_1_253" //Haiti: Removing 0s in question. Outliers
	replace `v'=. if id_alex=="cc_French_1_54"  //Haiti: Removing 0s in question. Outliers, x2
	replace `v'=. if id_alex=="lb_French_1_478"  //Haiti: Removing 0s in question. Outliers, x2
}
replace all_q29_norm=. if id_alex=="cc_English_0_175" //Haiti: Removing 1s in question. Outliers
replace all_q30_norm=. if id_alex=="cc_English_0_175" //Haiti: Removing 1s in question. Outliers
foreach v in all_q29_norm all_q30_norm {
	replace `v'=. if id_alex=="cc_English_0_771" //Haiti: Removing 1s in question. Outliers
}
foreach v in all_q62_norm all_q63_norm {
	replace `v'=. if id_alex=="lb_English_1_29" //Haiti: Removing 0s. Outliers in sub-factor
}
foreach v in all_q77_norm all_q78_norm all_q79_norm all_q80_norm all_q81_norm all_q82_norm {
	replace `v'=. if id_alex=="cc_French_1_1361_2023" //Haiti: Removing 0s. Outliers in sub-factor
}
replace cc_q39a_norm=. if id_alex=="cc_English_1_253" //Haiti - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39b_norm=. if id_alex=="cc_English_1_253" //Haiti - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39c_norm=. if id_alex=="cc_English_0_771" //Haiti - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39d_norm=. if id_alex=="cc_English_1_253" //Haiti - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39e_norm=. if id_alex=="cc_English_1_253" //Haiti - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cj_q11b_norm=. if id_alex=="cj_French_0_349" //Haiti - reduzco el cambio negativo en la pregunta  - 4.2 //
replace cj_q11b_norm=. if id_alex=="cj_French_1_110_2023" //Haiti - reduzco el cambio positivo en la pregunta  - 4.2 //
replace all_q29_norm=. if id_alex=="cj_French_0_278_2023" //Haiti - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cj_French_0_349" //Haiti - reduzco el cambio negativo en la pregunta  - 4.5 //
replace cj_q42d_norm=. if id_alex=="cj_French_0_992_2023" //Haiti - reduzco el cambio negativo en la pregunta  - 4.6 //
replace all_q31_norm=. if id_alex=="cj_French_0_349" //Haiti - reduzco el cambio positivo en la pregunta  - 4.7 //
replace all_q32_norm=. if id_alex=="cj_French_0_349" //Haiti - reduzco el cambio positivo en la pregunta  - 4.7 //
replace all_q31_norm=. if id_alex=="cc_English_0_771" //Haiti - reduzco el cambio positivo en la pregunta  - 4.7 //
replace lb_q23g_norm=. if id_alex=="lb_French_0_67_2021_2022_2023" //Haiti - reduzco el cambio positivo en la pregunta  - 4.8 //
replace lb_q16c_norm=. if id_alex=="lb_English_0_239_2021_2022_2023" //Haiti - reduzco el cambio positivo en la pregunta  - 4.8 //
replace lb_q16d_norm=. if id_alex=="lb_English_0_239_2021_2022_2023" //Haiti - reduzco el cambio positivo en la pregunta  - 4.8 //
replace all_q62_norm=. if id_alex=="cc_English_0_1517_2021_2022_2023" //Haiti - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q63_norm=. if id_alex=="cc_English_0_1517_2021_2022_2023" //Haiti - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q62_norm=. if id_alex=="cc_French_0_849_2021_2022_2023" //Haiti - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q63_norm=. if id_alex=="cc_French_0_849_2021_2022_2023" //Haiti - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q49_norm=. if id_alex=="cc_English_0_175" //Haiti - reduzco el cambio positivo en la pregunta  - 6.4 //
replace cc_q14a_norm=. if id_alex=="cc_English_0_175" //Haiti - reduzco el cambio positivo en la pregunta  - 6.5 //
replace cc_q14a_norm=. if id_alex=="cc_English_0_459_2021_2022_2023" //Haiti - reduzco el cambio positivo en la pregunta  - 6.5 //
replace cc_q10_norm=. if id_alex=="cc_English_0_234_2021_2022_2023" //Haiti - reduzco el cambio positivo en la pregunta  - 6.5 //
replace all_q78_norm=. if id_alex=="lb_English_1_31" //Haiti - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q78_norm=. if id_alex=="cc_English_0_1513" //Haiti - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q80_norm=. if id_alex=="lb_French_0_89_2023" //Haiti - reduzco el cambio negativo en la pregunta  - 7.2 //
replace cc_q26b_norm=. if id_alex=="cc_French_1_720" //Haiti - reduzco el cambio positivo en la pregunta  - 7.6 //
replace all_q87_norm=. if id_alex=="lb_English_0_310_2021_2022_2023" //Haiti - reduzco el cambio positivo en la pregunta  - 7.6 //
replace cj_q12d_norm=. if id_alex=="cj_English_0_271_2021_2022_2023" //Haiti - reduzco el cambio positivo en la pregunta  - 8.4 //
replace cj_q40b_norm=. if id_alex=="cj_French_0_349" //Haiti - reduzco el cambio negativo en la pregunta  - 8.6 //
replace cj_q40c_norm=. if id_alex=="cj_French_0_349" //Haiti - reduzco el cambio negativo en la pregunta  - 8.6 //

*Honduras
drop if id_alex=="cj_Spanish_0_75_2023" //Honduras (muy negativo)
foreach v in all_q22_norm all_q23_norm all_q24_norm all_q25_norm all_q26_norm all_q27_norm all_q8_norm {
	replace `v'=. if id_alex=="cc_Spanish_1_32_2022_2023" //Honduras: Removing 1s. Outliers in sub-factor
}
foreach v in all_q22_norm all_q23_norm all_q24_norm all_q25_norm all_q26_norm all_q27_norm all_q8_norm {
	replace `v'=. if id_alex=="cj_Spanish_0_273_2023" //Honduras: Removing 1s. Outliers in sub-factor
}
foreach v in all_q22_norm all_q23_norm all_q24_norm all_q25_norm all_q26_norm all_q27_norm all_q8_norm {
	replace `v'=. if id_alex=="cc_English_1_815_2023" //Honduras: Removing 1s. Outliers in sub-factor
}
foreach v in cj_q31f_norm cj_q31g_norm cj_q42c_norm cj_q42d_norm {
	replace `v'=. if id_alex=="cj_Spanish_0_1093" //Honduras: Removing 1s. Outliers in sub-factor
}
foreach v in cj_q42c_norm cj_q42d_norm {
	replace `v'=. if id_alex=="cj_Spanish_1_831" //Honduras: Removing 1s. Outliers.
}
foreach v in all_q22_norm all_q23_norm all_q24_norm all_q25_norm all_q26_norm all_q27_norm all_q8_norm {
	replace `v'=. if id_alex=="cc_Spanish_1_303_2023" //Honduras: Removing 1s. Outliers in sub-factor
}
foreach v in all_q22_norm all_q23_norm all_q24_norm all_q25_norm all_q26_norm all_q27_norm all_q8_norm {
	replace `v'=. if id_alex=="cc_Spanish_1_308" //Honduras: Removing 1s. Outliers in sub-factor
}
replace cj_q31f_norm=. if id_alex=="cj_English_1_1093_2022_2023" //Honduras: Removing high scores, outliers.
replace cj_q31g_norm=. if id_alex=="cj_Spanish_1_1023_2022_2023" //Honduras: Removing high scores, outliers.

replace all_q24_norm=. if id_alex=="cj_Spanish_1_1023_2022_2023" //Honduras - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q24_norm=. if id_alex=="cj_English_1_1093_2022_2023" //Honduras - reduzco el cambio positivo en la pregunta  - 1.7 //

replace all_q95_norm=. if id_alex=="cc_English_0_627_2022_2023" //Honduras - reduzco el cambio negativo en la pregunta  - 2.1 //
replace all_q95_norm=. if id_alex=="cc_Spanish_1_32_2022_2023" //Honduras - reduzco el cambio negativo en la pregunta  - 2.1 //
replace all_q54_norm=. if id_alex=="cc_Spanish_1_32_2022_2023" //Honduras - reduzco el cambio negativo en la pregunta  - 2.1 //
replace all_q56_norm=. if id_alex=="cc_Spanish_1_308" //Honduras - reduzco el cambio negativo en la pregunta  - 2.1 //
replace all_q56_norm=. if id_alex=="lb_Spanish_0_150_2022_2023" //Honduras - reduzco el cambio negativo en la pregunta  - 2.1 //
replace all_q54_norm=. if id_alex=="ph_Spanish_0_287_2022_2023" //Honduras - reduzco el cambio negativo en la pregunta  - 2.1 //
replace ph_q12a_norm=. if id_alex=="ph_English_0_112_2023" //Honduras - reduzco el cambio negativo en la pregunta  - 2.1 //
replace ph_q12e_norm=. if id_alex=="ph_English_0_112_2023" //Honduras - reduzco el cambio negativo en la pregunta  - 2.1 //
replace cj_q24c_norm=. if id_alex=="cj_English_0_95" //Honduras - reduzco el cambio negativo en la pregunta  - 2.2 //
replace cj_q33a_norm=. if id_alex=="cj_English_0_95" //Honduras - reduzco el cambio negativo en la pregunta  - 2.2 //
replace cj_q33b_norm=. if id_alex=="cj_English_0_95" //Honduras - reduzco el cambio negativo en la pregunta  - 2.2 //
replace cj_q33c_norm=. if id_alex=="cj_English_0_95" //Honduras - reduzco el cambio negativo en la pregunta  - 2.2 //
replace cj_q33d_norm=. if id_alex=="cj_English_0_95" //Honduras - reduzco el cambio negativo en la pregunta  - 2.2 //
replace cj_q33e_norm=. if id_alex=="cj_English_0_95" //Honduras - reduzco el cambio negativo en la pregunta  - 2.2 //
replace all_q60_norm=. if id_alex=="cc_Spanish_1_244_2023" //Honduras - reduzco el cambio negativo en la pregunta  - 2.2 //
replace all_q60_norm=. if id_alex=="cc_English_1_76_2023" //Honduras - reduzco el cambio negativo en la pregunta  - 2.2 //
replace all_q60_norm=. if id_alex=="cc_Spanish_0_917_2023" //Honduras - reduzco el cambio negativo en la pregunta  - 2.2 //
replace all_q60_norm=. if id_alex=="cc_Spanish_1_681_2023" //Honduras - reduzco el cambio negativo en la pregunta  - 2.2 //
replace cc_q28e_norm=. if id_alex=="cc_Spanish_1_308" //Honduras - reduzco el cambio negativo en la pregunta  - 2.2 //
replace cj_q31a_norm=. if id_alex=="cj_Spanish_1_1002_2023" //Honduras - reduzco el cambio negativo en la pregunta  - 2.2 //
replace cj_q31a_norm=. if id_alex=="cj_English_0_95" //Honduras - reduzco el cambio negativo en la pregunta  - 2.3 //
replace cj_q31b_norm=. if id_alex=="cj_English_0_95" //Honduras - reduzco el cambio negativo en la pregunta  - 2.3 //
replace cj_q34a_norm=. if id_alex=="cj_English_0_95" //Honduras - reduzco el cambio negativo en la pregunta  - 2.3 //
replace cj_q34b_norm=. if id_alex=="cj_English_0_95" //Honduras - reduzco el cambio negativo en la pregunta  - 2.3 //
replace cj_q34c_norm=. if id_alex=="cj_English_0_95" //Honduras - reduzco el cambio negativo en la pregunta  - 2.3 //
replace cj_q34d_norm=. if id_alex=="cj_English_0_95" //Honduras - reduzco el cambio negativo en la pregunta  - 2.3 //
replace cj_q34e_norm=. if id_alex=="cj_English_0_95" //Honduras - reduzco el cambio negativo en la pregunta  - 2.3 //
replace all_q96_norm=. if id_alex=="cc_Spanish_1_642_2022_2023" //Honduras - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_Spanish_0_99_2022_2023" //Honduras - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="lb_Spanish_1_137" //Honduras - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_Spanish_1_244_2023" //Honduras - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q62_norm=. if id_alex=="lb_English_0_72_2019_2021_2022_2023" //Honduras - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q63_norm=. if id_alex=="lb_English_0_72_2019_2021_2022_2023" //Honduras - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q62_norm=. if id_alex=="lb_Spanish_0_80_2021_2022_2023" //Honduras - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q63_norm=. if id_alex=="lb_Spanish_0_80_2021_2022_2023" //Honduras - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q62_norm=. if id_alex=="cc_Spanish_1_642_2022_2023" //Honduras - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q63_norm=. if id_alex=="cc_Spanish_1_642_2022_2023" //Honduras - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q62_norm=. if id_alex=="cc_Spanish_1_32_2022_2023" //Honduras - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q63_norm=. if id_alex=="cc_Spanish_1_32_2022_2023" //Honduras - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q48_norm=. if id_alex=="lb_English_0_306_2016_2017_2018_2019_2021_2022_2023" //Honduras - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q50_norm=. if id_alex=="lb_English_0_306_2016_2017_2018_2019_2021_2022_2023" //Honduras - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q70_norm=. if id_alex=="cc_Spanish_1_681_2023" //Honduras - reduzco el cambio positivo en la pregunta  - 7.1 //
replace cj_q12d_norm=. if id_alex=="cj_Spanish_0_867" //Honduras - reduzco el cambio positivo en la pregunta  - 8.4 //
replace cj_q12e_norm=. if id_alex=="cj_Spanish_0_867" //Honduras - reduzco el cambio positivo en la pregunta  - 8.4 //
replace cj_q20o_norm=. if id_alex=="cj_Spanish_0_867" //Honduras - reduzco el cambio positivo en la pregunta  - 8.4 //
replace cj_q20o_norm=. if id_alex=="cj_Spanish_1_1002_2023" //Honduras - reduzco el cambio positivo en la pregunta  - 8.4 //

*Hong Kong
drop if id_alex=="cc_English_1_472" //Hong Kong: Highest CC
drop if id_alex=="cj_English_1_503" //Hong Kong: Highest CJ
drop if id_alex=="cc_English_1_109" //Hong Kong: Highest CC, 2
drop if id_alex=="cc_English_0_843" //Hong Kong: Highest CC, 3
drop if id_alex=="cc_English_0_725" //Hong Kong: Highest CC, 4
drop if id_alex=="cj_English_0_575"  //Hong Kong: Highest CJ, 2
drop if id_alex=="cj_English_1_234"  //Hong Kong: Highest CJ, 3
drop if id_alex=="cc_English_0_149_2023" //Hong Kong (muy positivo)
foreach v in all_q22_norm all_q23_norm all_q24_norm all_q25_norm all_q26_norm all_q27_norm all_q8_norm  {
	replace `v'=. if id_alex=="cc_English_0_1538" //Hong Kong: Removing 1s. Outlier in sub-factor
	replace `v'=. if id_alex=="cc_English_0_149_2023" //Hong Kong: Removing 1s. Outlier in sub-factor
}
replace all_q96_norm=. if id_alex=="cc_English_0_1538" //Hong Kong: Removing 1s. Outlier in question
foreach v in cj_q32c_norm cj_q32d_norm cj_q31a_norm cj_q31b_norm cj_q34a_norm cj_q34b_norm cj_q34c_norm cj_q34d_norm cj_q34e_norm cj_q16j_norm cj_q18a_norm {
	replace `v'=. if id_alex=="cj_English_1_264_2022_2023" //Hong Kong: Removing 1s. Outlier in sub-factor
}
replace all_q96_norm=. if id_alex=="cj_English_1_264_2022_2023" //Hong Kong: Removing 1. Outlier in question
replace all_q96_norm=. if id_alex=="lb_English_1_424_2023" //Hong Kong: Removing 1. Outlier in question
replace cc_q26b_norm=. if id_alex=="cc_English_0_1538" //Hong Kong: Removing 1. Outlier in question
replace all_q86_norm=. if id_alex=="cc_English_0_1447_2022_2023" //Hong Kong: Removing 1. Outlier in question
foreach v in cj_q20m_norm cj_q40c_norm {
	replace `v'=. if `v'==0 & country=="Hong Kong SAR, China" //Hong Kong: Removing 0s. Outlier in sub-factor
}
replace cj_q40b_norm=. if id_alex=="cj_English_0_720" //Hong Kong: Removing 0s. Outlier in question
foreach v in cc_q9b_norm cc_q39a_norm cc_q39b_norm cc_q39d_norm cc_q39c_norm cc_q39e_norm {
	replace `v'=. if id_alex=="cc_English_0_1538"   //Hong Kong: Removing 1. Outlier in question
}
replace cc_q26b_norm=. if id_alex=="cc_English_0_1447_2022_2023" //Hong Kong: Removing 1. Outlier in question
replace all_q62_norm=. if id_alex=="cc_English_0_1538" //Hong Kong: Removing 1. Outlier in sub-factor
replace all_q63_norm=. if id_alex=="cc_English_0_1538" //Hong Kong: Removing 1. Outlier in sub-factor
replace all_q13_norm=. if id_alex=="cj_English_1_763" //Hong Kong - reduzco el cambio positivo en la pregunta  - 1.6 //
replace all_q24_norm=. if id_alex=="lb_English_0_551_2016_2017_2018_2019_2021_2022_2023" //Hong Kong - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q25_norm=. if id_alex=="lb_English_0_551_2016_2017_2018_2019_2021_2022_2023" //Hong Kong - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q24_norm=. if id_alex=="cc_English_0_1698" //Hong Kong - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q25_norm=. if id_alex=="cc_English_0_1698" //Hong Kong - reduzco el cambio positivo en la pregunta  - 1.7 //
replace cj_q24c_norm=. if id_alex=="cj_English_1_986_2022_2023" //Hong Kong - reduzco el cambio positivo en la pregunta  - 2.2 //
replace cj_q32d_norm=.6666667 if id_alex=="cj_English_1_986_2022_2023" //Hong Kong - reduzco el cambio positivo en la pregunta  - 2.3 //
replace cj_q18a_norm=. if id_alex=="cj_English_1_876_2022_2023" //Hong Kong - reduzco el cambio positivo en la pregunta  - 2.3 //
replace all_q29_norm=. if id_alex=="cj_English_1_876_2022_2023" //Hong Kong - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cj_English_1_876_2022_2023" //Hong Kong - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cj_English_0_422_2022_2023" //Hong Kong - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q55_norm=. if id_alex=="cc_English_0_1673" //Hong Kong - reduzco el cambio negativo en la pregunta  - 6.2 //
replace all_q48_norm=. if id_alex=="cc_English_0_1352_2022_2023" //Hong Kong - reduzco el cambio positivo en la pregunta  - 6.4 //
replace all_q50_norm=. if id_alex=="cc_English_0_1352_2022_2023" //Hong Kong - reduzco el cambio positivo en la pregunta  - 6.4 //
replace all_q50_norm=. if id_alex=="cc_English_0_1698" //Hong Kong - reduzco el cambio positivo en la pregunta  - 6.4 //
replace cc_q14b_norm=.6666667 if id_alex=="cc_English_0_226_2023" //Hong Kong - reduzco el cambio positivo en la pregunta  - 6.5 //
replace all_q6_norm=. if id_alex=="cc_English_0_1447_2022_2023" //Hong Kong - reduzco el cambio positivo en la pregunta  - 7.2 //
replace cc_q11a_norm=. if id_alex=="cc_English_0_1447_2022_2023" //Hong Kong - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q3_norm=. if id_alex=="cc_English_0_1447_2022_2023" //Hong Kong - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q6_norm=. if id_alex=="cc_English_0_1538" //Hong Kong - reduzco el cambio positivo en la pregunta  - 7.2 //
replace cc_q11a_norm=. if id_alex=="cc_English_0_1538" //Hong Kong - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q3_norm=. if id_alex=="cc_English_0_1538" //Hong Kong - reduzco el cambio positivo en la pregunta  - 7.2 //
replace cc_q26b_norm=. if id_alex=="cc_English_1_909_2022_2023" //Hong Kong - reduzco el cambio positivo en la pregunta  - 7.6 //
replace cj_q40b_norm=. if id_alex=="cj_English_1_986_2022_2023" //Hong Kong - reduzco el cambio negativo en la pregunta  - 8.6 //
replace cj_q22e_norm=. if id_alex=="cj_English_1_876_2022_2023" //Hong Kong - reduzco el cambio positivo en la pregunta  - 8.7 //
replace cj_q22e_norm=. if id_alex=="cj_English_0_422_2022_2023" //Hong Kong - reduzco el cambio positivo en la pregunta  - 8.7 //

*Hungary
drop if id_alex=="cc_English_0_1195" //Hungary: Highest CC
drop if id_alex=="cc_English_0_891" //Hungary: Highest CC, 2
drop if id_alex=="cc_English_0_929" //Hungary: Highest CC, 3
drop if id_alex=="cj_English_1_580" //Hungary: Highest CJ
drop if id_alex=="cj_English_0_434" //Hungary: Highest CJ, 2
drop if id_alex=="cj_English_0_1013" //Hungary (muy positivo)
replace cj_q32d_norm=. if country=="Hungary" //Hungary
replace cj_q31e_norm=. if country=="Hungary" //Hungary
replace cj_q11b_norm=. if country=="Hungary" //Hungary
replace cj_q6d_norm=. if country=="Hungary" //Hungary
replace cc_q33_norm=. if id_alex=="cc_English_0_326" //Hungary: Removing high score, outlier
replace cj_q36c_norm=. if id_alex=="cj_English_0_275" //Hungary: Removing high score, outlier
replace cj_q8_norm=. if id_alex=="cj_English_0_536" //Hungary: Removing high score, outlier
foreach v in cc_q33_norm all_q9_norm {
	replace `v'=. if id_alex=="cc_English_0_1030" //Hungary: Removing high scores
}
foreach v in all_q9_norm cj_q38_norm cj_q36c_norm cj_q8_norm {
	replace `v'=. if id_alex=="cj_English_0_1013" //Hungary: Removing high scores
}
foreach v in cc_q39a_norm cc_q39b_norm cc_q39d_norm cc_q39c_norm cc_q39e_norm {
	replace `v'=. if id_alex=="cc_English_1_929" //Hungary: removing high scores, outlier in sub-factor
}
foreach v in cc_q9c_norm cc_q40a_norm cc_q40b_norm {
	replace `v'=. if id_alex=="cc_English_0_438" //Hungary: Removing 1s, outlier in sub-factor	
}
replace cc_q40b_norm=. if id_alex=="cc_English_0_667" //Hungary: Removing 1s
replace cc_q40b_norm=. if id_alex=="cc_English_0_1282" //Hungary: Removing 1s
replace all_q30_norm=. if id_alex=="cc_English_0_1282" //Hungary: Removing 1s
replace all_q30_norm=. if id_alex=="cc_English_0_667" //Hungary: Removing 1s
replace all_q30_norm=. if id_alex=="cj_English_0_275" //Hungary: Removing 1s
replace all_q30_norm=. if id_alex=="cc_English_0_1030" //Hungary: Removing 1s
replace cc_q26a_norm=. if id_alex=="cc_English_0_438" //Hungary: Removing high score
replace all_q88_norm=. if id_alex=="cc_English_0_511_2022_2023" //Hungary: Removing high score
replace all_q88_norm=. if id_alex=="cc_English_0_1975" //Hungary: Removing high score
replace all_q88_norm=. if id_alex=="lb_English_0_232" //Hungary: Removing high score
replace all_q88_norm=. if id_alex=="cc_English_1_952_2023" //Hungary: Removing high score
replace cj_q34a_norm=. if country=="Hungary" //Hungary
replace cj_q34b_norm=. if country=="Hungary" //Hungary
replace cj_q34e_norm=. if country=="Hungary" //Hungary
replace cj_q12b_norm=. if country=="Hungary" //Hungary
replace cj_q12d_norm=. if country=="Hungary" //Hungary
replace all_q77_norm=. if country=="Hungary" //Hungary
replace cj_q20o_norm=. if cj_q20o_norm==1 & country=="Hungary" //Hungary: Removing 1s
foreach v in  cj_q12b_norm cj_q12f_norm {
	replace `v'=. if id_alex=="cj_English_0_1323" //Hungary: Removing 1s
}
foreach v in  cj_q12b_norm cj_q12f_norm {
	replace `v'=. if id_alex=="cj_English_0_749" //Hungary: Removing 1s
}
foreach v in all_q76_norm all_q78_norm all_q79_norm all_q80_norm all_q81_norm all_q82_norm {
	replace `v'=. if id_alex=="lb_English_0_232" //Hungary: Removing 1s, outlier in sub-factor
	replace `v'=. if id_alex=="lb_English_0_607" //Hungary: Removing 1s, outlier in sub-factor
}
replace cj_q38_norm=. if id_alex=="cj_English_0_275" //Hungary - reduzco el cambio positivo en la pregunta  - 1.4 //
replace cj_q8_norm=. if id_alex=="cj_English_0_275" //Hungary - reduzco el cambio positivo en la pregunta  - 1.4 //
replace cj_q38_norm=. if id_alex=="cj_English_1_1068_2022_2023" //Hungary - reduzco el cambio positivo en la pregunta  - 1.4 //
replace cj_q8_norm=. if id_alex=="cj_English_1_1068_2022_2023" //Hungary - reduzco el cambio positivo en la pregunta  - 1.4 //
replace cj_q36c_norm=. if id_alex=="cj_English_0_710_2023" //Hungary - reduzco el cambio positivo en la pregunta  - 1.4 //
replace cc_q33_norm=. if id_alex=="cc_English_0_511_2022_2023" //Hungary - reduzco el cambio positivo en la pregunta  - 1.4 //
replace cc_q33_norm=. if id_alex=="cc_English_0_667" //Hungary - reduzco el cambio positivo en la pregunta  - 1.4 //
replace all_q53_norm=. if id_alex=="cc_English_0_1900" //Hungary - reduzco el cambio positivo en la pregunta  - 1.5 //
replace all_q53_norm=. if id_alex=="cc_English_0_1975" //Hungary - reduzco el cambio positivo en la pregunta  - 1.5 //
replace all_q52_norm=. if id_alex=="cc_English_0_667" //Hungary - reduzco el cambio positivo en la pregunta  - 1.5 //
replace all_q53_norm=. if id_alex=="cc_English_0_667" //Hungary - reduzco el cambio positivo en la pregunta  - 1.5 //
replace all_q52_norm=. if id_alex=="cc_English_0_1030" //Hungary - reduzco el cambio positivo en la pregunta  - 1.5 //
replace all_q53_norm=. if id_alex=="cc_English_0_1030" //Hungary - reduzco el cambio positivo en la pregunta  - 1.5 //
replace cj_q9_norm=. if id_alex=="cj_English_0_939" //Hungary - reduzco el cambio positivo en la pregunta  - 1.5 //
replace cj_q9_norm=. if id_alex=="cj_English_0_51" //Hungary - reduzco el cambio positivo en la pregunta  - 1.5 //
replace cj_q8_norm=. if id_alex=="cj_English_0_939" //Hungary - reduzco el cambio positivo en la pregunta  - 1.5 //
replace cj_q9_norm=. if id_alex=="cj_English_1_487_2022_2023" //Hungary - reduzco el cambio positivo en la pregunta  - 1.5 //
replace cj_q9_norm=. if id_alex=="cj_English_0_710_2023" //Hungary - reduzco el cambio positivo en la pregunta  - 1.5 //
replace all_q13_norm=. if id_alex=="lb_English_0_413" //Hungary - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q15_norm=. if id_alex=="cc_English_0_511_2022_2023" //Hungary - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q16_norm=. if id_alex=="cc_English_0_511_2022_2023" //Hungary - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q94_norm=. if id_alex=="cc_English_0_511_2022_2023" //Hungary - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q15_norm=. if id_alex=="cc_English_0_1241_2023" //Hungary - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q16_norm=. if id_alex=="cc_English_0_1241_2023" //Hungary - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q94_norm=. if id_alex=="cc_English_0_1241_2023" //Hungary - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q21_norm=. if id_alex=="cc_English_1_130_2023" //Hungary - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q21_norm=. if id_alex=="cc_English_1_952_2023" //Hungary - reduzco el cambio negativo en la pregunta  - 1.6 //
replace cj_q33a_norm=. if id_alex=="cj_English_1_423" //Hungary - reduzco el cambio positivo en la pregunta  - 2.2 //
replace cj_q33b_norm=. if id_alex=="cj_English_1_423" //Hungary - reduzco el cambio positivo en la pregunta  - 2.2 //
replace cj_q33a_norm=. if id_alex=="cj_English_0_1323" //Hungary - reduzco el cambio positivo en la pregunta  - 2.2 //
replace cj_q33b_norm=. if id_alex=="cj_English_0_1323" //Hungary - reduzco el cambio positivo en la pregunta  - 2.2 //
replace cj_q24b_norm=. if id_alex=="cj_English_0_336" //Hungary - reduzco el cambio positivo en la pregunta  - 2.2 //
replace cj_q24c_norm=. if id_alex=="cj_English_0_336" //Hungary - reduzco el cambio positivo en la pregunta  - 2.2 //
replace cj_q33a_norm=. if id_alex=="cj_English_0_336" //Hungary - reduzco el cambio positivo en la pregunta  - 2.2 //
replace cj_q33b_norm=. if id_alex=="cj_English_0_336" //Hungary - reduzco el cambio positivo en la pregunta  - 2.2 //
replace cj_q33c_norm=. if id_alex=="cj_English_0_336" //Hungary - reduzco el cambio positivo en la pregunta  - 2.2 //
replace cj_q33d_norm=. if id_alex=="cj_English_0_336" //Hungary - reduzco el cambio positivo en la pregunta  - 2.2 //
replace cj_q33e_norm=. if id_alex=="cj_English_0_336" //Hungary - reduzco el cambio positivo en la pregunta  - 2.2 //
replace cc_q28e_norm=. if id_alex=="cc_English_0_667" //Hungary - reduzco el cambio positivo en la pregunta  - 2.2 //
replace lb_q6c_norm=. if id_alex=="lb_English_0_333_2017_2018_2019_2021_2022_2023" //Hungary - reduzco el cambio positivo en la pregunta  - 2.2 //
replace all_q61_norm=. if id_alex=="lb_English_0_344" //Hungary - reduzco el cambio positivo en la pregunta  - 2.3 //
replace all_q61_norm=. if id_alex=="lb_English_0_611" //Hungary - reduzco el cambio positivo en la pregunta  - 2.3 //
replace cj_q18a_norm=. if id_alex=="cj_English_0_336" //Hungary - reduzco el cambio positivo en la pregunta  - 2.3 //
replace cj_q16j_norm=. if id_alex=="cj_English_0_336" //Hungary - reduzco el cambio positivo en la pregunta  - 2.3 //
replace all_q96_norm=. if id_alex=="cc_English_0_1241_2023" //Hungary - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_1_130_2023" //Hungary - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_1_952_2023" //Hungary - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_0_696" //Hungary - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_0_1004" //Hungary - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="lb_English_0_413" //Hungary - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_0_568" //Hungary - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_0_1208" //Hungary - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_0_538" //Hungary - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cj_English_0_560_2022_2023" //Hungary - reduzco el cambio negativo en la pregunta  - 2.4 //
replace cc_q39a_norm=. if id_alex=="cc_English_0_1900" //Hungary - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39b_norm=. if id_alex=="cc_English_0_1900" //Hungary - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39c_norm=. if id_alex=="cc_English_0_1900" //Hungary - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39d_norm=. if id_alex=="cc_English_0_1900" //Hungary - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39e_norm=. if id_alex=="cc_English_0_667" //Hungary - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39a_norm=. if id_alex=="cc_English_0_982" //Hungary - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39b_norm=. if id_alex=="cc_English_0_982" //Hungary - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39c_norm=. if id_alex=="cc_English_0_982" //Hungary - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39d_norm=. if id_alex=="cc_English_0_982" //Hungary - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39e_norm=. if id_alex=="cc_English_0_1030" //Hungary - reduzco el cambio positivo en la pregunta  - 3.2 //
replace all_q44_norm=. if id_alex=="cc_English_0_1030" //Hungary - reduzco el cambio positivo en la pregunta  - 3.2 //
replace all_q44_norm=. if id_alex=="cc_English_0_1241_2023" //Hungary - reduzco el cambio positivo en la pregunta  - 3.2 //
replace all_q44_norm=. if id_alex=="cc_English_0_511_2022_2023" //Hungary - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q40b_norm=. if id_alex=="cc_English_0_1030" //Hungary - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cc_q40b_norm=. if id_alex=="cc_English_0_1159" //Hungary - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cc_q40b_norm=. if id_alex=="cc_English_0_1104" //Hungary - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cc_q40b_norm=. if id_alex=="cc_English_0_696" //Hungary - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cc_q40b_norm=. if id_alex=="cc_English_0_1208" //Hungary - reduzco el cambio positivo en la pregunta  - 3.4 //
replace all_q30_norm=. if id_alex=="cc_English_0_1900" //Hungary - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cc_English_0_903" //Hungary - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cc_English_0_1082" //Hungary - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cc_English_0_1104" //Hungary - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cc_English_0_1975" //Hungary - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cj_English_0_336" //Hungary - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cj_English_0_837" //Hungary - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cj_English_0_599" //Hungary - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cj_English_0_336" //Hungary - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cj_English_0_275" //Hungary - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cc_English_0_1159" //Hungary - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cc_English_0_1104" //Hungary - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cc_English_0_568" //Hungary - reduzco el cambio positivo en la pregunta  - 4.5 //
replace lb_q23a_norm=. if id_alex=="lb_English_0_413" //Hungary - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q23b_norm=. if id_alex=="lb_English_0_413" //Hungary - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q23c_norm=. if id_alex=="lb_English_0_413" //Hungary - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q23d_norm=. if id_alex=="lb_English_0_413" //Hungary - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q23e_norm=. if id_alex=="lb_English_0_413" //Hungary - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q23a_norm=. if id_alex=="lb_English_0_426" //Hungary - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q23b_norm=. if id_alex=="lb_English_0_426" //Hungary - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q23c_norm=. if id_alex=="lb_English_0_426" //Hungary - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q23d_norm=. if id_alex=="lb_English_0_426" //Hungary - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q23e_norm=. if id_alex=="lb_English_0_426" //Hungary - reduzco el cambio negativo en la pregunta  - 4.8 //
replace all_q50_norm=. if id_alex=="lb_English_0_232" //Hungary - reduzco el cambio positivo en la pregunta  - 6.4 //
replace all_q50_norm=. if id_alex=="lb_English_0_607" //Hungary - reduzco el cambio positivo en la pregunta  - 6.4 //
replace lb_q19a_norm=. if id_alex=="lb_English_0_607" //Hungary - reduzco el cambio positivo en la pregunta  - 6.4 //
replace all_q78_norm=. if id_alex=="lb_English_0_398_2021_2022_2023" //Hungary - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q79_norm=. if id_alex=="lb_English_0_398_2021_2022_2023" //Hungary - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q78_norm=. if id_alex=="cc_English_0_1030" //Hungary - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q79_norm=. if id_alex=="cc_English_0_1030" //Hungary - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q78_norm=. if id_alex=="lb_English_0_106" //Hungary - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q79_norm=. if id_alex=="lb_English_0_106" //Hungary - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q82_norm=. if id_alex=="cc_English_0_1082" //Hungary - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q79_norm=. if id_alex=="lb_English_0_433" //Hungary - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q82_norm=. if id_alex=="cc_English_0_982" //Hungary - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q82_norm=. if id_alex=="cc_English_0_1900" //Hungary - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q85_norm=. if id_alex=="cc_English_0_438" //Hungary - reduzco el cambio positivo en la pregunta  - 7.5 //
replace all_q85_norm=. if id_alex=="lb_English_0_344" //Hungary - reduzco el cambio positivo en la pregunta  - 7.5 //
replace all_q85_norm=. if id_alex=="cc_English_0_903" //Hungary - reduzco el cambio positivo en la pregunta  - 7.5 //
replace all_q85_norm=. if id_alex=="cc_English_0_485" //Hungary - reduzco el cambio positivo en la pregunta  - 7.5 //
replace cc_q26a_norm=. if id_alex=="cc_English_0_1977" //Hungary - reduzco el cambio positivo en la pregunta  - 7.5 //
replace cc_q26a_norm=. if id_alex=="cc_English_0_982" //Hungary - reduzco el cambio positivo en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="cc_English_0_667" //Hungary - reduzco el cambio positivo en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="cc_English_0_1765" //Hungary - reduzco el cambio positivo en la pregunta  - 7.5 //
replace cj_q20o_norm=. if id_alex=="cj_English_0_336" //Hungary - reduzco el cambio positivo en la pregunta  - 8.4 //
replace cj_q20o_norm=. if id_alex=="cj_English_0_536" //Hungary - reduzco el cambio positivo en la pregunta  - 8.4 //
replace cj_q20o_norm=. if id_alex=="cj_English_0_1323" //Hungary - reduzco el cambio positivo en la pregunta  - 8.4 //

*India
drop if id_alex=="cc_English_0_494" //India: Highest CC
drop if id_alex=="cc_English_1_487" //India: Highest CC, second
foreach v in cc_q16a_norm cc_q16b_norm cc_q16c_norm cc_q16d_norm cc_q16e_norm cc_q16f_norm cc_q16g_norm {
	replace `v'=. if id_alex=="cc_English_0_1083_2023" //India: Removing 1s, outlier in sub-factor
}

replace cc_q33_norm=. if id_alex=="cc_English_1_1389_2022_2023" //India - reduzco el cambio negativo en la pregunta  - 1.4 //
replace all_q19_norm=. if id_alex=="cc_English_0_1395" //India - reduzco el cambio positivo en la pregunta  - 1.6 //
replace all_q21_norm=. if id_alex=="cc_English_0_331" //India - reduzco el cambio positivo en la pregunta  - 1.6 //
replace cj_q10_norm=. if id_alex=="cj_English_0_245_2018_2019_2021_2022_2023" //India - reduzco el cambio positivo en la pregunta  - 1.6 //
replace all_q29_norm=. if id_alex=="cj_English_1_523" //India - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cj_English_1_523" //India - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q80_norm=. if id_alex=="cc_English_0_2026" //India - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q3_norm=. if id_alex=="cj_English_0_933_2023" //India - reduzco el cambio negativo en la pregunta  - 7.4 //
replace all_q4_norm=. if id_alex=="cj_English_0_933_2023" //India - reduzco el cambio negativo en la pregunta  - 7.4 //
replace all_q7_norm=. if id_alex=="cj_English_0_933_2023" //India - reduzco el cambio negativo en la pregunta  - 7.4 //
replace all_q85_norm=. if id_alex=="cc_English_0_448_2023" //India - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q13_norm=. if id_alex=="cc_English_0_448_2023" //India - reduzco el cambio negativo en la pregunta  - 7.5 //

*Indonesia
drop if id_alex=="cj_English_0_377" //Indonesia: Lowest CJ 
drop if id_alex=="lb_English_0_66" //Indonesia: Lowest LB
drop if id_alex=="cj_English_1_393" //Indonesia: Lowest CJ, 2nd
replace cj_q36c_norm=. if id_alex=="cj_English_0_666_2022_2023" //Indonesia: Removing 0s.
replace cj_q38_norm=. if id_alex=="cj_English_0_697" //Indonesia: Removing 0s from question. Outlier
replace cj_q36c_norm=. if id_alex=="cj_English_0_697" //Indonesia: Removing 0s from question. Outlier
drop if id_alex=="cj_English_0_627" //Indonesia: Lowest CJ, 3rd
foreach v in all_q29_norm all_q30_norm {
	replace `v'=. if `v'==0 & country=="Indonesia" //Indonesia: Removing 0s. Outliers
}
replace cj_q9_norm=. if cj_q9_norm==0 & country=="Indonesia" //Indonesia: Removing 0s. 
drop if id_alex=="cj_English_0_437" //Indonesia: Low CJ
replace cj_q8_norm=1 if id_alex=="cj_English_0_572_2023" //Indonesia - reduzco el cambio negativo en la pregunta  - 1.4 //
replace cj_q8_norm=. if id_alex=="cj_English_1_89_2023" //Indonesia - reduzco el cambio negativo en la pregunta  - 1.4 //
replace cj_q36a_norm=. if id_alex=="cj_English_0_666_2022_2023" //Indonesia - reduzco el cambio negativo en la pregunta  - 1.5 //
replace cj_q36b_norm=. if id_alex=="cj_English_0_666_2022_2023" //Indonesia - reduzco el cambio negativo en la pregunta  - 1.5 //
replace cj_q9_norm=. if id_alex=="cj_English_0_666_2022_2023" //Indonesia - reduzco el cambio negativo en la pregunta  - 1.5 //
replace cj_q8_norm=. if id_alex=="cj_English_1_89_2023" //Indonesia - reduzco el cambio negativo en la pregunta  - 1.5 //
replace all_q10_norm=. if id_alex=="cj_English_0_666_2022_2023" //Indonesia - reduzco el cambio negativo en la pregunta  - 1.5 //
replace all_q11_norm=. if id_alex=="cj_English_0_666_2022_2023" //Indonesia - reduzco el cambio negativo en la pregunta  - 1.5 //
replace all_q22_norm=. if id_alex=="cj_English_0_292" //Indonesia - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q23_norm=. if id_alex=="cj_English_0_292" //Indonesia - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q24_norm=. if id_alex=="cj_English_0_292" //Indonesia - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q25_norm=. if id_alex=="cj_English_0_292" //Indonesia - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q26_norm=. if id_alex=="cj_English_0_292" //Indonesia - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q27_norm=. if id_alex=="cj_English_0_697" //Indonesia - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q23_norm=. if id_alex=="cc_English_1_992_2023" //Indonesia - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q96_norm=. if id_alex=="cj_English_0_651" //Indonesia - reduzco el cambio positivo en la pregunta  - 2.4 //
replace cc_q40a_norm=. if id_alex=="cc_English_0_805_2022_2023" //Indonesia - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cc_q40a_norm=. if id_alex=="cc_English_0_584_2022_2023" //Indonesia - reduzco el cambio positivo en la pregunta  - 3.4 //
replace all_q3_norm=. if id_alex=="cj_English_0_666_2022_2023" //Indonesia - reduzco el cambio negativo en la pregunta  - 7.4 //
replace all_q4_norm=. if id_alex=="cj_English_0_666_2022_2023" //Indonesia - reduzco el cambio negativo en la pregunta  - 7.4 //
replace cc_q11a_norm=. if id_alex=="cc_English_0_1519_2022_2023" //Indonesia - reduzco el cambio negativo en la pregunta  - 7.4 //
replace cj_q28_norm=. if id_alex=="cj_English_0_552_2022_2023" //Indonesia - reduzco el cambio positivo en la pregunta  - 8.3 //
replace cj_q28_norm=. if id_alex=="cj_English_0_1129" //Indonesia - reduzco el cambio positivo en la pregunta  - 8.3 //
replace cj_q21g_norm=. if id_alex=="cj_English_0_409" //Indonesia - reduzco el cambio positivo en la pregunta  - 8.3 //
replace cj_q40b_norm=. if id_alex=="cj_English_0_697" //Indonesia - reduzco el cambio negativo en la pregunta  - 8.6 //
replace cj_q40c_norm=. if id_alex=="cj_English_0_697" //Indonesia - reduzco el cambio negativo en la pregunta  - 8.6 //

*Iran, Islamic Rep.
replace cc_q9c_norm=. if id_alex=="cc_English_0_733_2013_2014_2016_2017_2018_2019_2021_2022_2023" //Iran, Islamic Rep. - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cc_q40a_norm=. if id_alex=="cc_English_0_614_2023" //Iran, Islamic Rep. - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cc_q40b_norm=. if id_alex=="cc_English_0_1461_2019_2021_2022_2023" //Iran, Islamic Rep. - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cj_q34a_norm=. if id_alex=="cj_English_1_681_2017_2018_2019_2021_2022_2023" //Iran, Islamic Rep. - reduzco el cambio positivo en la pregunta  - 8.5 //
replace cj_q34b_norm=. if id_alex=="cj_English_1_681_2017_2018_2019_2021_2022_2023" //Iran, Islamic Rep. - reduzco el cambio positivo en la pregunta  - 8.5 //
replace cj_q34c_norm=. if id_alex=="cj_English_1_681_2017_2018_2019_2021_2022_2023" //Iran, Islamic Rep. - reduzco el cambio positivo en la pregunta  - 8.5 //
replace cj_q34d_norm=. if id_alex=="cj_English_1_681_2017_2018_2019_2021_2022_2023" //Iran, Islamic Rep. - reduzco el cambio positivo en la pregunta  - 8.5 //
replace cj_q34e_norm=. if id_alex=="cj_English_1_681_2017_2018_2019_2021_2022_2023" //Iran, Islamic Rep. - reduzco el cambio positivo en la pregunta  - 8.5 //
replace cj_q1_norm=. if id_alex=="cj_English_1_195_2021_2022_2023" //Iran, Islamic Rep. - reduzco el cambio positivo en la pregunta  - 8.7 //
replace cj_q2_norm=. if id_alex=="cj_English_1_195_2021_2022_2023" //Iran, Islamic Rep. - reduzco el cambio positivo en la pregunta  - 8.7 //
replace cj_q11a_norm=. if id_alex=="cj_English_1_416_2016_2017_2018_2019_2021_2022_2023" //Iran, Islamic Rep. - reduzco el cambio positivo en la pregunta  - 8.7 //
replace cj_q22c_norm=. if id_alex=="cj_English_0_238_2022_2023" //Iran, Islamic Rep. - reduzco el cambio positivo en la pregunta  - 8.7 //
replace cj_q22a_norm=. if id_alex=="cj_English_1_681_2017_2018_2019_2021_2022_2023" //Iran, Islamic Rep. - reduzco el cambio positivo en la pregunta  - 8.7 //
replace cj_q6c_norm=. if id_alex=="cj_English_1_550_2016_2017_2018_2019_2021_2022_2023" //Iran, Islamic Rep. - reduzco el cambio positivo en la pregunta  - 8.7 //
replace cj_q6c_norm=. if id_alex=="cj_English_1_472_2017_2018_2019_2021_2022_2023" //Iran, Islamic Rep. - reduzco el cambio positivo en la pregunta  - 8.7 //

*Ireland
drop if id_alex=="cj_English_0_387" //Ireland: Highest CJ
drop if id_alex=="cj_English_0_229" //Ireland (muy positivo)
drop if id_alex=="cc_English_0_1314" //Ireland (muy positivo)
replace all_q96_norm=. if id_alex=="cj_English_0_1279" //Ireland: Removing 1s, outlier in sub-factor
replace all_q96_norm=. if id_alex=="cc_English_1_307_2023" //Ireland: Removing 1s, outlier in sub-factor
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="lb_English_0_393" //Ireland: Removing 1s. Outlier in sub-factor
}
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="cc_English_0_1624" //Ireland: Removing 1s. Outlier in sub-factor
}
foreach v in cc_q39a_norm cc_q39b_norm cc_q39c_norm cc_q39e_norm {
	replace `v'=. if id_alex=="cc_English_0_1624" //Ireland: Removing 1s. Outlier in sub-factor
}
replace cc_q39a_norm=. if id_alex=="cc_English_1_1144" //Ireland: Removing 1s. Outlier in sub-factor
replace cc_q39a_norm=. if id_alex=="cc_English_0_421" //Ireland: Removing 1s. Outlier in sub-factor
foreach v in cj_q11a_norm cj_q11b_norm cj_q42c_norm cj_q42d_norm cj_q10_norm {
	replace `v'=. if id_alex=="cj_English_0_229" //Ireland: Removing 1s. Outlier in sub-factor
	replace `v'=. if id_alex=="cj_English_0_1226" //Ireland: Removing 1s. Outlier in sub-factor
}
foreach v in all_q29_norm all_q30_norm {
	replace `v'=. if id_alex=="cc_English_1_307_2023" //Ireland: Removing 1s. Outlier in sub-factor
	replace `v'=. if id_alex=="cj_English_0_229" //Ireland: Removing 1s. Outlier in sub-factor
	replace `v'=. if id_alex=="cj_English_0_1226" //Ireland: Removing 1s. Outlier in sub-factor
	replace `v'=. if id_alex=="cc_English_0_1854" //Ireland: Removing 1s. Outlier in sub-factor
}
replace cj_q15_norm=. if id_alex=="cj_English_1_837" //Ireland: Removing lowest score, outlier.
replace cc_q26b_norm=. if id_alex=="cc_English_0_1314" //Ireland: Removing 1 in question, outlier
replace all_q86_norm=. if id_alex=="lb_English_0_393"  //Ireland: Removing high score in question, outlier
replace all_q87_norm=. if id_alex=="lb_English_0_393"  //Ireland: Removing 1 in question, outlier

foreach v in cj_q12a_norm cj_q12b_norm cj_q12c_norm cj_q12d_norm cj_q12e_norm cj_q12f_norm cj_q20o_norm {
	replace `v'=. if id_alex=="cj_English_0_229" //Ireland: Removing 1s. Outlier in sub-factor
}
foreach v in cj_q40b_norm cj_q40c_norm cj_q20m_norm {
	replace `v'=. if id_alex=="cj_English_0_229" //Ireland: Removing 1s. Outlier in sub-factor
}
foreach v in cc_q26b_norm all_q86_norm all_q87_norm {
	replace `v'=. if id_alex=="cc_English_0_1676" //Ireland: Removing high scores. Outlier in sub-factor
}
replace all_q9_norm=. if id_alex=="cj_English_1_720_2022_2023" //Ireland - reduzco el cambio positivo en la pregunta  - 1.4 //
replace cj_q38_norm=. if id_alex=="cj_English_1_720_2022_2023" //Ireland - reduzco el cambio positivo en la pregunta  - 1.4 //
replace all_q9_norm=. if id_alex=="lb_English_0_266_2021_2022_2023" //Ireland - reduzco el cambio positivo en la pregunta  - 1.4 //
replace cj_q32c_norm=. if id_alex=="cj_English_0_800_2021_2022_2023" //Ireland - reduzco el cambio positivo en la pregunta  - 2.3 //
replace all_q96_norm=. if id_alex=="lb_English_0_393" //Ireland - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="lb_English_0_17" //Ireland - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="lb_English_0_421" //Ireland - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q35_norm=. if id_alex=="lb_English_0_266_2021_2022_2023" //Ireland - reduzco el cambio positivo en la pregunta  - 3.1 //
replace all_q35_norm=. if id_alex=="lb_English_0_71_2021_2022_2023" //Ireland - reduzco el cambio positivo en la pregunta  - 3.1 //
replace cc_q32h_norm=. if id_alex=="cc_English_0_1676" //Ireland - reduzco el cambio positivo en la pregunta  - 3.1 //
replace cj_q11a_norm=. if id_alex=="cc_English_0_1676" //Ireland - reduzco el cambio positivo en la pregunta  - 4.2 //
replace cj_q11a_norm=. if id_alex=="cj_English_0_1279" //Ireland - reduzco el cambio positivo en la pregunta  - 4.2 //
replace cj_q11b_norm=. if id_alex=="cj_English_0_1279" //Ireland - reduzco el cambio positivo en la pregunta  - 4.2 //
replace cj_q42c_norm=. if id_alex=="cj_English_0_1279" //Ireland - reduzco el cambio positivo en la pregunta  - 4.2 //
replace cj_q42d_norm=. if id_alex=="cj_English_0_1279" //Ireland - reduzco el cambio positivo en la pregunta  - 4.2 //
replace cj_q10_norm=. if id_alex=="cj_English_0_1279" //Ireland - reduzco el cambio positivo en la pregunta  - 4.2 //
replace all_q29_norm=. if id_alex=="cc_English_0_646" //Ireland - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cc_English_0_646" //Ireland - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cc_English_1_1100" //Ireland - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cc_English_1_1100" //Ireland - reduzco el cambio positivo en la pregunta  - 4.5 //
replace cj_q31f_norm=. if id_alex=="cj_English_0_800_2021_2022_2023" //Ireland - reduzco el cambio positivo en la pregunta  - 4.6 //
replace cj_q31g_norm=. if id_alex=="cj_English_0_800_2021_2022_2023" //Ireland - reduzco el cambio positivo en la pregunta  - 4.6 //
replace all_q19_norm=. if id_alex=="cc_English_0_1676" //Ireland - reduzco el cambio positivo en la pregunta  - 4.7 //
replace all_q31_norm=. if id_alex=="cc_English_0_1676" //Ireland - reduzco el cambio positivo en la pregunta  - 4.7 //
replace all_q32_norm=. if id_alex=="cc_English_0_1676" //Ireland - reduzco el cambio positivo en la pregunta  - 4.7 //
replace all_q14_norm=. if id_alex=="cc_English_0_1676" //Ireland - reduzco el cambio positivo en la pregunta  - 4.7 //
replace lb_q23a_norm=. if id_alex=="lb_English_0_456" //Ireland - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q23b_norm=. if id_alex=="lb_English_0_456" //Ireland - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q23c_norm=. if id_alex=="lb_English_0_456" //Ireland - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q23d_norm=. if id_alex=="lb_English_0_456" //Ireland - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q23e_norm=. if id_alex=="lb_English_0_456" //Ireland - reduzco el cambio negativo en la pregunta  - 4.8 //
replace all_q6_norm=. if id_alex=="lb_English_0_393" //Ireland - reduzco el cambio negativo en la pregunta  - 7.2 //
replace cc_q11a_norm=. if id_alex=="cc_English_0_389_2022_2023" //Ireland - reduzco el cambio negativo en la pregunta  - 7.2 //
replace cc_q26a_norm=. if id_alex=="cc_English_0_421" //Ireland - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q26b_norm=. if id_alex=="cc_English_1_1144" //Ireland - reduzco el cambio positivo en la pregunta  - 7.6 //
replace all_q86_norm=. if id_alex=="cc_English_1_1144" //Ireland - reduzco el cambio positivo en la pregunta  - 7.6 //
replace all_q87_norm=. if id_alex=="cc_English_1_1144" //Ireland - reduzco el cambio positivo en la pregunta  - 7.6 //
replace cj_q21a_norm=. if id_alex=="cj_English_0_1279" //Ireland - reduzco el cambio negativo en la pregunta  - 8.3 //
replace cj_q40b_norm=. if id_alex=="cj_English_0_1226" //Ireland - reduzco el cambio positivo en la pregunta  - 8.6 //
replace cj_q40c_norm=. if id_alex=="cj_English_0_1226" //Ireland - reduzco el cambio positivo en la pregunta  - 8.6 //
replace cj_q20m_norm=. if id_alex=="cj_English_0_1226" //Ireland - reduzco el cambio positivo en la pregunta  - 8.6 //

*Italy
drop if id_alex=="cc_French_0_1845" //Italy: Lowest CC expert
drop if id_alex=="cc_English_0_1741" //Italy: Lowest CC expert
drop if id_alex=="cc_English_0_316" //Italy: Lowest CC expert
drop if id_alex=="cc_English_0_1964" //Italy: Lowest CC expert
drop if id_alex=="cc_English_0_895" //Italy: Lowest CC expert
drop if id_alex=="cc_English_0_231" //Italy: Lowest CC expert
drop if id_alex=="cc_English_0_893" //Italy: Lowest CC expert
drop if id_alex=="cj_English_0_1169" //Italy: Lowest CJ
drop if id_alex=="cj_English_0_732" //Italy: Lowest CJ
drop if id_alex=="cj_English_0_326" //Italy: Lowest CJ
drop if id_alex=="cj_English_0_1200" //Italy: Lowest CJ
drop if id_alex=="cj_English_0_329" //Italy: Lowest CJ
drop if id_alex=="lb_English_0_293" //Italy: lowest LB
drop if id_alex=="lb_English_0_124" //Italy: lowest LB
drop if id_alex=="cc_English_0_1108" //Italy: Lowest CC expert
drop if id_alex=="cc_English_0_1027" //Italy: Lowest CC expert
drop if id_alex=="cc_English_0_1839" //Italy: Lowest CC expert
drop if id_alex=="cc_English_0_1094" //Italy: Lowest CC expert
drop if id_alex=="cc_French_0_1225" //Italy: Lowest CC expert
drop if id_alex=="cc_English_0_1294" //Italy: Lowest CC expert
drop if id_alex=="cc_English_0_247" //Italy: Lowest CC expert
drop if id_alex=="cc_English_0_1316" //Italy: Lowest CC expert
drop if id_alex=="cc_English_0_1148" //Italy: Lowest CC expert
drop if id_alex=="cc_English_0_1793" //Italy: Lowest CC expert
drop if id_alex=="cc_English_1_645_2023" //Italy: Lowest CC expert
drop if id_alex=="cc_English_0_1180" //Italy: Lowest CC expert
drop if id_alex=="cc_English_0_1089" //Italy: Lowest CC expert
drop if id_alex=="cc_English_0_216" //Italy (muy negativo)
drop if id_alex=="cc_English_0_1939" //Italy (muy negativo)
drop if id_alex=="cc_English_0_1156" //Italy (muy negativo)
drop if id_alex=="cc_English_0_1794" //Italy (muy negativo)
drop if id_alex=="cc_English_0_1031" //Italy (muy negativo)
drop if id_alex=="cc_Spanish_0_713" //Italy (muy negativo)
drop if id_alex=="cj_French_0_799" //Italy (muy negativo)
drop if id_alex=="cj_English_0_815" //Italy (muy negativo)
drop if id_alex=="cj_English_0_689" //Italy (muy negativo)
drop if id_alex=="cj_English_0_1167" //Italy (muy negativo)
drop if id_alex=="cj_English_0_1221" //Italy (muy negativo)
drop if id_alex=="cj_English_1_947" //Italy (muy negativo)
drop if id_alex=="cj_French_0_629" //Italy (muy negativo)
drop if id_alex=="cj_English_0_567" //Italy (muy negativo)
drop if id_alex=="lb_English_0_241" //Italy (muy negativo)
drop if id_alex=="lb_English_0_319" //Italy (muy negativo)
foreach v in all_q10_norm all_q11_norm all_q12_norm {
	replace `v'=. if id_alex=="lb_English_0_241" //Italy: Removing 0s, outlier in sub-factor
	replace `v'=. if id_alex=="lb_English_0_379" //Italy: Removing 0s, outlier in sub-factor
	replace `v'=. if id_alex=="cc_English_0_1280" //Italy: Removing 0s, outlier in sub-factor
	replace `v'=. if id_alex=="cc_English_0_216" //Italy: Removing 0s, outlier in sub-factor
	replace `v'=. if id_alex=="cc_English_0_1000" //Italy: Removing 0s, outlier in sub-factor
	replace `v'=. if id_alex=="cc_English_0_1182" //Italy: Removing 0s, outlier in sub-factor
	replace `v'=. if id_alex=="cc_English_0_581" //Italy: Removing 0s, outlier in sub-factor
}
replace all_q10_norm=. if id_alex=="cj_English_0_689" //Italy: Removing 0s, outlier in question
replace all_q11_norm=. if id_alex=="cj_English_0_689" //Italy: Removing 0s, outlier in question
foreach v in cj_q22d_norm cj_q22b_norm {
	replace `v'=. if id_alex=="cj_English_0_726" //Italy: Removing 0s, outlier in question
	replace `v'=. if id_alex=="cj_English_0_680" //Italy: Removing 0s, outlier in question
}
replace cj_q22d_norm=. if id_alex=="" //Italy: Removing 0s, outlier in question
replace cj_q22d_norm=. if id_alex=="" //Italy: Removing 0s, outlier in question
replace cj_q22e_norm=. if id_alex=="cj_English_0_1167" //Italy: Removing 0s, outlier in question  
replace cj_q31d_norm=. if id_alex=="cj_English_0_689" //Italy: Removing 0s, outlier in question
foreach v in cj_q21b_norm cj_q21c_norm cj_q21d_norm {
	replace `v'=. if id_alex=="cj_English_0_567" //Italy: Removing 0s, outlier in question
	replace `v'=. if id_alex=="cj_English_0_726" //Italy: Removing 0s, outlier in question
}
foreach v in cj_q31f_norm cj_q31g_norm {
	replace `v'=. if id_alex=="cj_English_0_567" //Italy: Removing 0s, outlier in sub-factor
	replace `v'=. if id_alex=="cj_English_0_689" //Italy: Removing 0s, outlier in sub-factor
}
replace all_q14_norm=. if all_q14_norm==0 & country=="Italy" //Italy:Removing 0s, outlier in question
foreach v in all_q19_norm all_q31_norm all_q32_norm {
	replace `v'=. if id_alex=="cj_English_0_1221" //Italy: Removing 0s, outlier in sub-factor
}
foreach v in lb_q2d_norm lb_q3d_norm {
	replace `v'=. if id_alex=="lb_English_0_241" //Italy: Removing 0s, outlier in sub-factor
}
replace lb_q3d_norm=. if id_alex=="lb_English_0_319" //Italy: Removing 0, outlier in sub-factor
foreach v in all_q48_norm all_q49_norm all_q50_norm lb_q19a_norm {
	replace `v'=. if id_alex=="lb_English_0_542" //Italy: Removing 0s, outlier in sub-factor
}
replace all_q50_norm=. if id_alex=="cc_English_0_1924" //Italy: Removing 0, outlier in sub-factor
replace all_q49_norm=. if id_alex=="cc_English_0_887" //Italy: Removing 0, outlier in sub-factor
replace all_q49_norm=. if id_alex=="cc_English_0_1266" //Italy: Removing 0, outlier in sub-factor 
foreach v in all_q48_norm all_q50_norm lb_q19a_norm {
	replace `v'=. if id_alex=="lb_English_0_242" //Italy: Removing 0s, outlier in sub-factor
}
replace all_q49_norm=. if id_alex=="cc_English_0_1867" //Italy: Removing 0, outlier in sub-factor 
replace all_q49_norm=. if id_alex=="cc_English_0_936" //Italy: Removing 0, outlier in sub-factor 
foreach v in cc_q10_norm cc_q11a_norm cc_q16a_norm {
	replace `v'=. if id_alex=="cc_English_0_265" //Italy: Removing 0s, outlier in sub-factor 
	replace `v'=. if id_alex=="cc_Spanish_0_336" //Italy: Removing 0s, outlier in sub-factor 
	replace `v'=. if id_alex=="cc_English_0_216" //Italy: Removing 0s, outlier in sub-factor 
}
replace cc_q14a_norm=. if cc_q14a_norm==0 & country=="Italy" //Italy: Removing 0s, outlier in question
replace cc_q14b_norm=. if cc_q14b_norm==0 & country=="Italy" //Italy: Removing 0s, outlier in question
replace cc_q16b_norm=. if id_alex=="cc_English_0_1866" //Italy: Removing 0s, outlier in question
replace cc_q16b_norm=. if id_alex=="cc_English_0_265" //Italy: Removing 0s, outlier in question
replace cc_q11a_norm=. if cc_q11a_norm==0 & country=="Italy"
foreach v in all_q3_norm all_q4_norm all_q7_norm {
	replace `v'=. if id_alex=="cj_English_0_689" //Italy: Removing 0s, outlier in sub-factor
}
replace all_q48_norm=. if id_alex=="cc_English_0_580" //Italy: Removing low scores, outlier in sub-factor
replace all_q50_norm=. if id_alex=="cc_English_0_580" //Italy: Removing low scores, outlier in sub-factor
replace all_q49_norm=. if id_alex=="cc_English_0_363" //Italy: Removing 0, outlier in sub-factor
replace cc_q16c_norm=. if id_alex=="cc_English_0_636" //Italy: Removing 0, outlier in sub-factor
replace cc_q16b_norm=. if id_alex=="cc_English_0_1156" //Italy: Removing 0, outlier in sub-factor
replace cc_q16b_norm=. if id_alex=="cc_Spanish_0_336" //Italy: Removing 0, outlier in sub-factor
replace all_q4_norm=. if all_q4_norm==0 & country=="Italy" //Italy: Removing 0s, outlier in sub-factor
replace all_q3_norm=. if id_alex=="lb_English_0_360" //Italy: Removing 0, outlier in question
replace all_q7_norm=. if all_q7_norm==0 & country=="Italy" //Italy: Removing 0s, outlier in sub-factor
foreach v in cj_q21e_norm cj_q21g_norm cj_q21h_norm {
	replace `v'=. if id_alex=="cj_English_0_726" //Italy: Removing 0s, outlier in sub-factor
}
replace cj_q21g_norm=. if id_alex=="cj_English_0_1267" //Italy: Removing 0s, outlier in sub-factor
foreach v in cj_q40b_norm cj_q40c_norm cj_q20m_norm {
	replace `v'=. if id_alex=="cj_English_0_1149" //Italy: Removing 0s, outlier in sub-factor
}
foreach v in cj_q40b_norm cj_q40c_norm cj_q20m_norm {
	replace `v'=. if `v'==0 & country=="Italy" //Italy: Removing 0s, outlier in sub-factor
}
replace all_q49_norm=. if all_q49_norm==0 & country=="Italy" //Italy: Removing 0s, outlier in question
replace lb_q19a_norm=. if id_alex=="lb_English_0_554" //Italy: Removing low scores, outlier in question
replace all_q2_norm=. if id_alex=="lb_English_0_379" //Italy - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q20_norm=. if id_alex=="lb_English_0_379" //Italy - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q21_norm=. if id_alex=="lb_English_0_379" //Italy - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q2_norm=. if id_alex=="cc_English_0_1280" //Italy - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q20_norm=. if id_alex=="cc_English_0_1280" //Italy - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q21_norm=. if id_alex=="cc_English_0_1280" //Italy - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q2_norm=. if id_alex=="cc_English_0_1249" //Italy - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q20_norm=. if id_alex=="cc_English_0_1154" //Italy - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q21_norm=. if id_alex=="cc_English_0_1154" //Italy - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q3_norm=. if id_alex=="cc_English_0_1249" //Italy - reduzco el cambio negativo en la pregunta  - 1.3 //
replace all_q4_norm=. if id_alex=="cc_English_0_1249" //Italy - reduzco el cambio negativo en la pregunta  - 1.3 //
replace all_q3_norm=. if id_alex=="cc_English_0_581" //Italy - reduzco el cambio negativo en la pregunta  - 1.3 //
replace all_q4_norm=. if id_alex=="cc_English_0_581" //Italy - reduzco el cambio negativo en la pregunta  - 1.3 //
replace all_q3_norm=. if id_alex=="cj_English_0_798" //Italy - reduzco el cambio negativo en la pregunta  - 1.3 //
replace all_q4_norm=. if id_alex=="cj_English_0_798" //Italy - reduzco el cambio negativo en la pregunta  - 1.3 //
replace all_q3_norm=. if id_alex=="lb_English_1_280_2022_2023" //Italy - reduzco el cambio negativo en la pregunta  - 1.3 //
replace all_q4_norm=. if id_alex=="lb_English_1_280_2022_2023" //Italy - reduzco el cambio negativo en la pregunta  - 1.3 //
replace all_q4_norm=. if id_alex=="lb_English_1_280_2022_2023" //Italy - reduzco el cambio negativo en la pregunta  - 1.3 //
replace cc_q25_norm=. if id_alex=="cc_English_0_1236" //Italy - reduzco el cambio negativo en la pregunta  - 1.3 //
replace cc_q25_norm=. if id_alex=="cc_English_0_1127" //Italy - reduzco el cambio negativo en la pregunta  - 1.3 //
replace cc_q25_norm=. if id_alex=="cc_English_0_253" //Italy - reduzco el cambio negativo en la pregunta  - 1.3 //
replace cc_q25_norm=. if id_alex=="cc_English_0_399" //Italy - reduzco el cambio negativo en la pregunta  - 1.3 //
replace all_q8_norm=. if id_alex=="cj_English_0_726" //Italy - reduzco el cambio negativo en la pregunta  - 1.3 //
replace all_q8_norm=. if id_alex=="lb_English_1_280_2022_2023" //Italy - reduzco el cambio negativo en la pregunta  - 1.3 //
replace all_q12_norm=. if id_alex=="lb_English_0_242" //Italy - reduzco el cambio negativo en la pregunta  - 1.5 //
replace all_q12_norm=. if id_alex=="lb_English_0_248" //Italy - reduzco el cambio negativo en la pregunta  - 1.5 //
replace all_q12_norm=. if id_alex=="cj_English_0_87" //Italy - reduzco el cambio negativo en la pregunta  - 1.5 //
replace all_q12_norm=. if id_alex=="cc_English_0_1910" //Italy - reduzco el cambio negativo en la pregunta  - 1.5 //
replace all_q11_norm=. if id_alex=="cj_English_1_243_2023" //Italy - reduzco el cambio negativo en la pregunta  - 1.5 //
replace all_q11_norm=. if id_alex=="cj_English_0_235" //Italy - reduzco el cambio negativo en la pregunta  - 1.5 //
replace all_q11_norm=. if id_alex=="cj_English_0_606" //Italy - reduzco el cambio negativo en la pregunta  - 1.5 //
replace all_q14_norm=. if id_alex=="cc_English_0_1280" //Italy - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q15_norm=. if id_alex=="cc_English_0_1280" //Italy - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q16_norm=. if id_alex=="cc_English_0_1280" //Italy - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q18_norm=. if id_alex=="cc_English_0_1280" //Italy - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q19_norm=. if id_alex=="cc_English_0_1280" //Italy - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q20_norm=. if id_alex=="cc_English_0_1280" //Italy - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q21_norm=. if id_alex=="cc_English_0_1280" //Italy - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q15_norm=. if id_alex=="cc_English_0_265" //Italy - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q16_norm=. if id_alex=="cc_English_0_1127" //Italy - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q18_norm=. if id_alex=="cc_English_0_1127" //Italy - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q15_norm=1 if id_alex=="cc_English_0_1743" //Italy - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q16_norm=1 if id_alex=="cc_English_0_1743" //Italy - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q20_norm=. if id_alex=="lb_English_0_379" //Italy - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q21_norm=. if id_alex=="lb_English_0_379" //Italy - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q15_norm=. if id_alex=="cc_English_0_1866" //Italy - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q16_norm=. if id_alex=="cc_English_0_1866" //Italy - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q14_norm=. if id_alex=="cc_English_0_328" //Italy - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q15_norm=. if id_alex=="cc_English_0_328" //Italy - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q16_norm=. if id_alex=="cc_English_0_328" //Italy - reduzco el cambio negativo en la pregunta  - 1.6 //
replace cj_q34a_norm=. if id_alex=="cj_English_0_726" //Italy - reduzco el cambio negativo en la pregunta  - 2.3 //
replace cj_q34b_norm=. if id_alex=="cj_English_0_726" //Italy - reduzco el cambio negativo en la pregunta  - 2.3 //
replace cc_q39a_norm=. if id_alex=="cc_English_0_1774" //Italy - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39b_norm=. if id_alex=="cc_English_0_1774" //Italy - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39c_norm=. if id_alex=="cc_English_0_1774" //Italy - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39d_norm=. if id_alex=="cc_English_0_1774" //Italy - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39e_norm=. if id_alex=="cc_English_0_1774" //Italy - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q29_norm=. if id_alex=="cj_English_0_680" //Italy - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cj_English_0_822" //Italy - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cc_English_0_1127" //Italy - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q31_norm=. if id_alex=="cc_English_0_328" //Italy - reduzco el cambio negativo en la pregunta  - 4.7 //
replace all_q19_norm=. if id_alex=="cc_English_0_328" //Italy - reduzco el cambio negativo en la pregunta  - 4.7 //
replace all_q19_norm=. if id_alex=="cc_English_0_565" //Italy - reduzco el cambio negativo en la pregunta  - 4.7 //
replace all_q31_norm=. if id_alex=="cc_English_0_565" //Italy - reduzco el cambio negativo en la pregunta  - 4.7 //
replace all_q32_norm=. if id_alex=="cc_English_0_565" //Italy - reduzco el cambio negativo en la pregunta  - 4.7 //
replace all_q14_norm=. if id_alex=="cc_English_0_565" //Italy - reduzco el cambio negativo en la pregunta  - 4.7 //
replace all_q19_norm=. if id_alex=="cc_English_0_999" //Italy - reduzco el cambio negativo en la pregunta  - 4.7 //
replace all_q31_norm=. if id_alex=="cc_English_0_999" //Italy - reduzco el cambio negativo en la pregunta  - 4.7 //
replace all_q32_norm=. if id_alex=="cc_English_0_999" //Italy - reduzco el cambio negativo en la pregunta  - 4.7 //
replace all_q14_norm=. if id_alex=="cc_English_0_999" //Italy - reduzco el cambio negativo en la pregunta  - 4.7 //
replace lb_q23b_norm=. if id_alex=="lb_English_0_360" //Italy - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q23c_norm=. if id_alex=="lb_English_0_360" //Italy - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q23d_norm=. if id_alex=="lb_English_0_360" //Italy - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q23e_norm=. if id_alex=="lb_English_0_360" //Italy - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q23g_norm=. if id_alex=="lb_English_0_360" //Italy - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q23g_norm=. if id_alex=="lb_English_0_242" //Italy - reduzco el cambio negativo en la pregunta  - 4.8 //
replace all_q48_norm=. if id_alex=="lb_English_0_379" //Italy - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q49_norm=. if id_alex=="lb_English_0_379" //Italy - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q50_norm=. if id_alex=="lb_English_0_379" //Italy - reduzco el cambio negativo en la pregunta  - 6.4 //
replace lb_q19a_norm=. if id_alex=="lb_English_0_379" //Italy - reduzco el cambio negativo en la pregunta  - 6.4 //
replace lb_q19a_norm=. if id_alex=="lb_English_1_280_2022_2023" //Italy - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q49_norm=. if id_alex=="lb_English_0_242" //Italy - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q48_norm=. if id_alex=="cc_English_0_989" //Italy - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q49_norm=. if id_alex=="cc_English_0_989" //Italy - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q50_norm=. if id_alex=="cc_English_0_989" //Italy - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q48_norm=. if id_alex=="cc_English_0_1354" //Italy - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q49_norm=. if id_alex=="cc_English_0_1354" //Italy - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q50_norm=. if id_alex=="cc_English_0_1354" //Italy - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q48_norm=. if id_alex=="cc_English_0_636" //Italy - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q49_norm=. if id_alex=="cc_English_0_636" //Italy - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q50_norm=. if id_alex=="cc_English_0_636" //Italy - reduzco el cambio negativo en la pregunta  - 6.4 //
replace cc_q10_norm=. if id_alex=="cc_English_0_1280" //Italy - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q10_norm=. if id_alex=="cc_English_0_1266" //Italy - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q10_norm=. if id_alex=="cc_English_0_1867" //Italy - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q11a_norm=. if id_alex=="cc_English_0_1280" //Italy - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q11a_norm=. if id_alex=="cc_English_0_649" //Italy - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q11a_norm=. if id_alex=="cc_French_0_383" //Italy - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q11a_norm=. if id_alex=="cc_English_0_1866" //Italy - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q16a_norm=. if id_alex=="cc_English_0_1280" //Italy - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q16a_norm=. if id_alex=="cc_French_0_383" //Italy - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q16a_norm=. if id_alex=="cc_English_0_1866" //Italy - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q14a_norm=. if id_alex=="cc_French_0_383" //Italy - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q14b_norm=. if id_alex=="cc_French_0_383" //Italy - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q14a_norm=. if id_alex=="cc_English_0_1219" //Italy - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q14b_norm=. if id_alex=="cc_English_0_1219" //Italy - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q14a_norm=. if id_alex=="cc_English_0_1248" //Italy - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q14b_norm=. if id_alex=="cc_English_0_1248" //Italy - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q14a_norm=. if id_alex=="cc_English_0_1743" //Italy - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q14b_norm=. if id_alex=="cc_English_0_1743" //Italy - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q14a_norm=. if id_alex=="cc_English_0_1738" //Italy - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q14b_norm=. if id_alex=="cc_English_0_1738" //Italy - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q11a_norm=. if id_alex=="cc_English_0_1280" //Italy - reduzco el cambio negativo en la pregunta  - 7.4 //
replace cc_q11a_norm=. if id_alex=="cc_English_0_1266" //Italy - reduzco el cambio negativo en la pregunta  - 7.4 //
replace cc_q11a_norm=. if id_alex=="cc_English_0_351" //Italy - reduzco el cambio negativo en la pregunta  - 7.4 //
replace cc_q11a_norm=. if id_alex=="cc_English_0_1924" //Italy - reduzco el cambio negativo en la pregunta  - 7.4 //
replace cc_q11a_norm=. if id_alex=="cc_French_0_1107" //Italy - reduzco el cambio negativo en la pregunta  - 7.4 //
replace cc_q11a_norm=. if id_alex=="cc_French_0_1880" //Italy - reduzco el cambio negativo en la pregunta  - 7.4 //
replace cc_q11a_norm=. if id_alex=="cc_English_0_1867" //Italy - reduzco el cambio negativo en la pregunta  - 7.4 //
replace all_q85_norm=. if id_alex=="cc_English_0_1280" //Italy - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cj_q21e_norm=. if id_alex=="cj_French_1_62" //Italy - reduzco el cambio negativo en la pregunta  - 8.3 //
replace cj_q21e_norm=. if id_alex=="cj_English_0_1217" //Italy - reduzco el cambio negativo en la pregunta  - 8.3 //
replace cj_q21e_norm=. if id_alex=="cj_English_0_1267" //Italy - reduzco el cambio negativo en la pregunta  - 8.3 //
replace cj_q40b_norm=. if id_alex=="cj_English_1_207_2022_2023" //Italy - reduzco el cambio negativo en la pregunta  - 8.6 //
replace cj_q40c_norm=. if id_alex=="cj_English_1_207_2022_2023" //Italy - reduzco el cambio negativo en la pregunta  - 8.6 //
replace cj_q40b_norm=. if id_alex=="cj_English_0_798" //Italy - reduzco el cambio negativo en la pregunta  - 8.6 //
replace cj_q40c_norm=. if id_alex=="cj_English_0_798" //Italy - reduzco el cambio negativo en la pregunta  - 8.6 //

*Jamaica
replace all_q20_norm=. if country=="Jamaica" /*Jamaica*/

*Japan
drop if id_alex=="cj_English_0_350" //Japan: Lowest CJ
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="lb_English_1_169_2013_2014_2016_2017_2018_2019_2021_2022_2023" //Japan: Removing 1s. Outlier in sub-factor
	replace `v'=. if id_alex=="lb_English_1_538" //Japan: Removing 1s. Outlier in sub-factor
}
replace all_q29_norm=. if id_alex=="cj_English_0_926" //Japan - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cj_English_0_926" //Japan - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cc_English_0_391_2017_2018_2019_2021_2022_2023" //Japan - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cc_English_0_391_2017_2018_2019_2021_2022_2023" //Japan - reduzco el cambio negativo en la pregunta  - 4.5 //
replace cc_q13_norm=. if id_alex=="cc_English_1_990" //Japan - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="cc_English_1_990" //Japan - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q26a_norm=. if id_alex=="cc_English_1_990" //Japan - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="cc_English_0_848_2014_2016_2017_2018_2019_2021_2022_2023" //Japan - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q26a_norm=. if id_alex=="cc_English_0_848_2014_2016_2017_2018_2019_2021_2022_2023" //Japan - reduzco el cambio negativo en la pregunta  - 7.5 //

*Jordan
replace cc_q33_norm=. if country=="Jordan" //Jordan
drop if id_alex=="cc_English_1_596" //Jordan: Highest CC
drop if id_alex=="cj_English_1_614" //Jordan: Highest CJ
drop if id_alex=="cc_English_0_741" //Jordan (muy positivo)
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="lb_Arabic_0_18_2022_2023" //Jordan: Removing 0s. Outlier in sub-factor
}
foreach v in cc_q39a_norm cc_q39b_norm cc_q39d_norm cc_q39c_norm cc_q39e_norm {
	replace `v'=. if id_alex=="cc_English_0_50" //Jordan: Removing 0s. Outlier in sub-factor
	replace `v'=. if id_alex=="cc_English_1_810" //Jordan: Removing 0s. Outlier in sub-factor
	replace `v'=. if id_alex=="cc_English_1_205_2021_2022_2023" //Jordan: Removing 0s. Outlier in sub-factor
}
foreach v in all_q29_norm all_q30_norm {
	replace `v'=. if id_alex=="cj_Arabic_1_697_2021_2022_2023" //Jordan: Removing 1s. Outlier in sub-factor
	replace `v'=. if id_alex=="cc_English_0_542" //Jordan: Removing 1s. Outlier in sub-factor
}
foreach v in lb_q16a_norm lb_q16b_norm lb_q16c_norm lb_q16d_norm lb_q16e_norm lb_q16f_norm {
	replace `v'=. if id_alex=="lb_English_0_829_2021_2022_2023" //Jordan: Removing 1s. Outlier in sub-factor
}
replace lb_q23d_norm=. if id_alex=="lb_Arabic_0_18_2022_2023" //Jordan: Removing 1s.
replace lb_q23e_norm=. if id_alex=="lb_Arabic_0_18_2022_2023" //Jordan: Removing 1s.
replace cc_q26b_norm=. if id_alex=="cc_English_0_741" //Jordan: Removing 1 in question. 
replace cc_q26b_norm=. if id_alex=="cc_English_0_367_2018_2019_2021_2022_2023" //Jordan: Removing 1 in question. 
replace cj_q15_norm=. if id_alex=="cj_Arabic_0_591" //Jordan: Removing 0 in question. Outlier
replace cj_q36c_norm=. if id_alex=="cj_Arabic_0_120_2022_2023" //Jordan - reduzco el cambio positivo en la pregunta  - 1.4 //
replace cj_q8_norm=. if id_alex=="cj_Arabic_0_120_2022_2023" //Jordan - reduzco el cambio positivo en la pregunta  - 1.4 //
replace cc_q39c_norm=. if id_alex=="cc_English_0_1467_2022_2023" //Jordan - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39d_norm=. if id_alex=="cc_English_0_1467_2022_2023" //Jordan - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39e_norm=. if id_alex=="cc_English_0_1467_2022_2023" //Jordan - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q42_norm=. if id_alex=="cc_English_1_896_2016_2017_2018_2019_2021_2022_2023" //Jordan - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cj_q15_norm=. if id_alex=="cj_English_0_557_2014_2016_2017_2018_2019_2021_2022_2023" //Jordan - reduzco el cambio negativo en la pregunta  - 5.3 //
replace cj_q15_norm=. if id_alex=="cj_English_0_466_2014_2016_2017_2018_2019_2021_2022_2023" //Jordan - reduzco el cambio negativo en la pregunta  - 5.3 //
replace cj_q15_norm=. if id_alex=="cj_Arabic_0_120_2022_2023" //Jordan - reduzco el cambio negativo en la pregunta  - 5.3 //
replace all_q63_norm=. if id_alex=="lb_English_0_829_2021_2022_2023" //Jordan - reduzco el cambio negativo en la pregunta  - 6.3 //
replace cc_q11a_norm=. if id_alex=="cc_English_0_385_2018_2019_2021_2022_2023" //Jordan - reduzco el cambio positivo en la pregunta  - 7.4 //
replace all_q3_norm=. if id_alex=="cc_English_0_367_2018_2019_2021_2022_2023" //Jordan - reduzco el cambio positivo en la pregunta  - 7.4 //
replace all_q4_norm=. if id_alex=="cc_English_0_367_2018_2019_2021_2022_2023" //Jordan - reduzco el cambio positivo en la pregunta  - 7.4 //
replace all_q7_norm=. if id_alex=="cc_English_0_367_2018_2019_2021_2022_2023" //Jordan - reduzco el cambio positivo en la pregunta  - 7.4 //
replace cc_q26b_norm=. if id_alex=="cc_English_1_176_2022_2023" //Jordan - reduzco el cambio positivo en la pregunta  - 7.6 //
replace cc_q26b_norm=. if id_alex=="cc_English_0_542" //Jordan - reduzco el cambio positivo en la pregunta  - 7.6 //
replace cj_q20o_norm=. if id_alex=="cj_English_0_361" //Jordan - reduzco el cambio negativo en la pregunta  - 8.4 //

*Kazakhstan
drop if id_alex=="lb_Russian_1_562_2023" //Kazakhstan: Highest LB
drop if id_alex=="cc_Russian_1_961_2023" //Kazakhstan: Highest CC
foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="lb_Russian_0_156_2021_2022_2023" //Kazakhstan: Removing 1s. Outlier in sub-factor 
}
replace cc_q39c_norm=. if id_alex=="cc_English_0_377_2022_2023" //Kazakhstan: Removing 1 in question. Outlier.
foreach v in cc_q39a_norm cc_q39b_norm cc_q39e_norm {
	replace `v'=. if id_alex=="cc_Russian_1_654" //Kazakhstan: Removing 1s in question. Outliers.
}
foreach v in cj_q10_norm cj_q11a_norm cj_q11b_norm cj_q42c_norm cj_q42d_norm  {
	replace `v'=. if id_alex=="cj_English_1_331" //Kazakhstan: Removing 0s. Outlier in sub-factor
}
replace cj_q31e_norm=. if id_alex=="cj_Russian_1_210" //Kazakhstan: Removing 0 in question
replace cc_q26b_norm=. if cc_q26b_norm==0 & country=="Kazakhstan" //Kazakhstan: Removing 0s. 
replace cc_q14a_norm=. if id_alex=="cc_Russian_0_1594_2022_2023" //Kazakhstan: Removing 1. Outlier
replace cc_q39d_norm=. if id_alex=="cc_Russian_1_393_2023" //Kazakhstan - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q39e_norm=. if id_alex=="cc_Russian_1_393_2023" //Kazakhstan - reduzco el cambio positivo en la pregunta  - 3.2 //
replace cc_q40b_norm=. if id_alex=="cc_English_0_377_2022_2023" //Kazakhstan - reduzco el cambio negativo en la pregunta  - 3.4 //
replace all_q29_norm=. if id_alex=="cc_English_1_1075_2022_2023" //Kazakhstan - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cc_English_0_377_2022_2023" //Kazakhstan - reduzco el cambio positivo en la pregunta  - 4.5 //
replace lb_q23c_norm=. if id_alex=="lb_English_1_129_2017_2018_2019_2021_2022_2023" //Kazakhstan - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q16e_norm=. if id_alex=="lb_Russian_0_540_2018_2019_2021_2022_2023" //Kazakhstan - reduzco el cambio negativo en la pregunta  - 4.8 //
replace all_q48_norm=. if id_alex=="lb_Russian_0_729_2017_2018_2019_2021_2022_2023" //Kazakhstan - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q49_norm=. if id_alex=="lb_Russian_0_729_2017_2018_2019_2021_2022_2023" //Kazakhstan - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q76_norm=. if id_alex=="lb_English_0_273_2016_2017_2018_2019_2021_2022_2023" //Kazakhstan - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q77_norm=. if id_alex=="lb_English_0_273_2016_2017_2018_2019_2021_2022_2023" //Kazakhstan - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q78_norm=. if id_alex=="lb_English_0_273_2016_2017_2018_2019_2021_2022_2023" //Kazakhstan - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q79_norm=. if id_alex=="lb_English_0_273_2016_2017_2018_2019_2021_2022_2023" //Kazakhstan - reduzco el cambio positivo en la pregunta  - 7.2 //
replace cc_q26b_norm=. if id_alex=="cc_Russian_0_1594_2022_2023" //Kazakhstan - reduzco el cambio negativo en la pregunta  - 7.6 //
replace cc_q26b_norm=. if id_alex=="cc_Russian_1_654" //Kazakhstan - reduzco el cambio negativo en la pregunta  - 7.6 //
replace cj_q28_norm=. if id_alex=="cj_English_0_143_2022_2023" //Kazakhstan - reduzco el cambio negativo en la pregunta  - 8.3 //
replace cj_q20o_norm=. if id_alex=="cj_Russian_0_136_2022_2023" //Kazakhstan - reduzco el cambio negativo en la pregunta  - 8.4 //
replace cj_q20o_norm=. if id_alex=="cj_English_0_497_2013_2014_2016_2017_2018_2019_2021_2022_2023" //Kazakhstan - reduzco el cambio negativo en la pregunta  - 8.4 //
replace cj_q40c_norm=. if id_alex=="cj_English_0_143_2022_2023" //Kazakhstan - reduzco el cambio negativo en la pregunta  - 8.6 //
replace cj_q40b_norm=. if id_alex=="cj_English_0_143_2022_2023" //Kazakhstan - reduzco el cambio negativo en la pregunta  - 8.6 //
replace cj_q20m_norm=. if id_alex=="cj_Russian_1_90_2019_2021_2022_2023" //Kazakhstan - reduzco el cambio negativo en la pregunta  - 8.6 //

*Kenya
drop if id_alex=="cc_English_0_1937" //Kenya: Highest CC
drop if id_alex=="cc_English_0_2020" //Kenya: Highest CC, 2
drop if id_alex=="cj_English_0_626_2016_2017_2018_2019_2021_2022_2023"

foreach v in all_q40_norm all_q41_norm all_q42_norm all_q43_norm all_q44_norm all_q45_norm all_q46_norm all_q47_norm {
	replace `v'=. if id_alex=="lb_English_0_622_2017_2018_2019_2021_2022_2023" //Kenya: Removing 1s. Outlier in sub-factor
}
replace cc_q40a_norm=. if id_alex=="cc_English_0_884_2023" //Kenya: Removing 1. Outlier. 
replace cc_q40b_norm=. if id_alex=="cc_English_0_884_2023" //Kenya: Removing 1. Outlier. 

foreach v in all_q76_norm all_q77_norm all_q78_norm all_q79_norm all_q80_norm all_q81_norm all_q82_norm {
	replace `v'=. if id_alex=="cc_English_0_814_2023" //Kenya: Removing 1s. Outlier in sub-factor
}
foreach v in all_q76_norm all_q77_norm all_q78_norm all_q79_norm all_q80_norm all_q81_norm all_q82_norm {
	replace `v'=. if id_alex=="lb_English_0_262_2023" //Kenya: Removing 1s. Outlier in sub-factor
}
replace cc_q26a_norm=. if id_alex=="cc_English_0_884_2023" //Kenya: Removing 1. Outlier in sub-factor
replace cc_q26b_norm=. if id_alex=="cc_English_0_884_2023" //Kenya: Removing 1. Outlier in sub-factor
replace all_q85_norm=. if all_q85_norm==1 & country=="Kenya" //Kenya: Removing 1s. Outlier in sub-factor
replace cc_q40a_norm=. if id_alex=="cc_English_1_923" //Kenya: Removing 1. Outlier. 
replace cc_q40b_norm=. if id_alex=="cc_English_1_923" //Kenya: Removing 1. Outlier. 
replace cc_q33_norm=. if id_alex=="cc_English_0_519" //Kenya - reduzco el cambio positivo en la pregunta  - 1.4 //
replace all_q24_norm=. if id_alex=="cc_English_0_814_2023" //Kenya - aumento el cambio negativo en la pregunta  - 1.7 //
replace all_q25_norm=. if id_alex=="cc_English_0_814_2023" //Kenya - aumento el cambio negativo en la pregunta  - 1.7 //
replace all_q26_norm=. if id_alex=="cc_English_0_814_2023" //Kenya - aumento el cambio negativo en la pregunta  - 1.7 //
replace all_q24_norm=. if id_alex=="cj_English_0_319" //Kenya - aumento el cambio negativo en la pregunta  - 1.7 //
replace all_q25_norm=. if id_alex=="cj_English_0_319" //Kenya - aumento el cambio negativo en la pregunta  - 1.7 //
replace all_q26_norm=. if id_alex=="cj_English_0_319" //Kenya - aumento el cambio negativo en la pregunta  - 1.7 //
replace cc_q32h_norm=. if id_alex=="cc_English_0_814_2023" //Kenya - reduzco el cambio positivo en la pregunta  - 3.1 //
replace cc_q32i_norm=. if id_alex=="cc_English_0_814_2023" //Kenya - reduzco el cambio positivo en la pregunta  - 3.1 //
replace all_q33_norm=. if id_alex=="cc_English_1_762_2022_2023" //Kenya - reduzco el cambio positivo en la pregunta  - 3.1 //
replace lb_q2d_norm=. if id_alex=="lb_English_0_195_2019_2021_2022_2023" //Kenya - reduzco el cambio positivo en la pregunta  - 6.3 //
replace lb_q3d_norm=. if id_alex=="lb_English_0_195_2019_2021_2022_2023" //Kenya - reduzco el cambio positivo en la pregunta  - 6.3 //
replace all_q62_norm=. if id_alex=="cc_English_0_519" //Kenya - reduzco el cambio positivo en la pregunta  - 6.3 //
replace all_q63_norm=. if id_alex=="cc_English_0_519" //Kenya - reduzco el cambio positivo en la pregunta  - 6.3 //
replace all_q77_norm=. if id_alex=="lb_English_0_498_2018_2019_2021_2022_2023" //Kenya - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q78_norm=. if id_alex=="lb_English_0_498_2018_2019_2021_2022_2023" //Kenya - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q79_norm=. if id_alex=="lb_English_0_498_2018_2019_2021_2022_2023" //Kenya - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q80_norm=. if id_alex=="lb_English_0_498_2018_2019_2021_2022_2023" //Kenya - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q77_norm=. if id_alex=="cc_English_0_519" //Kenya - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q78_norm=. if id_alex=="cc_English_0_519" //Kenya - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q79_norm=. if id_alex=="cc_English_0_519" //Kenya - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q80_norm=. if id_alex=="cc_English_0_519" //Kenya - reduzco el cambio positivo en la pregunta  - 7.2 //
replace cc_q26b_norm=. if id_alex=="cc_English_1_909" //Kenya - reduzco el cambio positivo en la pregunta  - 7.6 //
replace cj_q16a_norm=. if id_alex=="cj_English_0_82" //Kenya - reduzco el cambio positivo en la pregunta  - 8.1 //
replace cj_q16b_norm=. if id_alex=="cj_English_0_82" //Kenya - reduzco el cambio positivo en la pregunta  - 8.1 //
replace cj_q16c_norm=. if id_alex=="cj_English_0_82" //Kenya - reduzco el cambio positivo en la pregunta  - 8.1 //
replace cj_q16d_norm=. if id_alex=="cj_English_0_82" //Kenya - reduzco el cambio positivo en la pregunta  - 8.1 //
replace cj_q16e_norm=. if id_alex=="cj_English_0_82" //Kenya - reduzco el cambio positivo en la pregunta  - 8.1 //
replace cj_q16f_norm=. if id_alex=="cj_English_0_82" //Kenya - reduzco el cambio positivo en la pregunta  - 8.1 //
replace cj_q16g_norm=. if id_alex=="cj_English_0_82" //Kenya - reduzco el cambio positivo en la pregunta  - 8.1 //
replace cj_q16h_norm=. if id_alex=="cj_English_0_82" //Kenya - reduzco el cambio positivo en la pregunta  - 8.1 //
replace cj_q16i_norm=. if id_alex=="cj_English_0_82" //Kenya - reduzco el cambio positivo en la pregunta  - 8.1 //
replace cj_q16j_norm=. if id_alex=="cj_English_0_82" //Kenya - reduzco el cambio positivo en la pregunta  - 8.1 //
replace cj_q16k_norm=. if id_alex=="cj_English_0_82" //Kenya - reduzco el cambio positivo en la pregunta  - 8.1 //
replace cj_q16l_norm=. if id_alex=="cj_English_0_82" //Kenya - reduzco el cambio positivo en la pregunta  - 8.1 //
replace cj_q16m_norm=. if id_alex=="cj_English_0_82" //Kenya - reduzco el cambio positivo en la pregunta  - 8.1 //

*Korea
replace cj_q15_norm=1 if id_alex=="cj_English_0_114_2016_2017_2018_2019_2021_2022_2023" //Korea: Outlier in question. Removing low score
replace lb_q19a_norm=. if id_alex=="lb_English_0_592_2014_2016_2017_2018_2019_2021_2022_2023" //Kenya - reduzco el cambio positivo en la pregunta  - 6.4 //
replace all_q88_norm=. if id_alex=="cc_English_0_108" //Kenya - reduzco el cambio positivo en la pregunta  - 7.5 //
replace cc_q26a_norm=. if id_alex=="cc_English_0_108" //Kenya - reduzco el cambio positivo en la pregunta  - 7.5 //
replace cc_q26b_norm=. if id_alex=="cc_English_0_108" //Kenya - reduzco el cambio positivo en la pregunta  - 7.6 //
replace all_q86_norm=. if id_alex=="cc_English_0_108" //Kenya - reduzco el cambio positivo en la pregunta  - 7.6 //
replace all_q87_norm=. if id_alex=="cc_English_0_108" //Kenya - reduzco el cambio positivo en la pregunta  - 7.6 //
replace cj_q40b_norm=. if id_alex=="cj_English_0_50" //Kenya - reduzco el cambio positivo en la pregunta  - 8.6 //
replace cj_q40c_norm=. if id_alex=="cj_English_0_50" //Kenya - reduzco el cambio positivo en la pregunta  - 8.6 //
replace cj_q20m_norm=. if id_alex=="cj_English_0_50" //Kenya - reduzco el cambio positivo en la pregunta  - 8.6 //

*Kosovo
drop if id_alex=="cc_English_1_716" //Kosovo: Highest CC
drop if id_alex=="cj_English_0_268" //Kosovo (muy positivo)
foreach v in cj_q36b_norm cj_q36a_norm cj_q9_norm cj_q8_norm {
	replace `v'=. if id_alex=="cj_English_1_474" //Kosovo: Removing 1s. Outlier in sub-factor
}
replace cj_q10_norm=. if cj_q10_norm==1 & country=="Kosovo" //Kosovo: Removing 1s. Outlier in question
foreach v in all_q22_norm all_q23_norm all_q24_norm all_q25_norm all_q26_norm all_q27_norm all_q8_norm {
	replace `v'=. if id_alex=="cc_English_0_825_2022_2023" //Kosovo: Removing 1s. Outlier in sub-factor
}
replace lb_q3d_norm=. if id_alex=="lb_English_0_54" //Kosovo: Removing 0. Outlier in question
replace lb_q2d_norm=. if id_alex=="lb_English_0_54" //Kosovo: Removing 0. Outlier in sub-factor
foreach v in cj_q40b_norm cj_q40c_norm cj_q20m_norm {
	replace `v'=. if id_alex=="cj_English_1_279_2023" //Kosovo: Removing 1s. Outlier in sub-factor
}
replace cj_q20m_norm=. if cj_q20m_norm==1 & country=="Kosovo" //Kosovo: Removing 1s. Outliers in question
replace all_q9_norm=. if all_q9_norm==1 & country=="Kosovo"  //Kosovo: Removing 1s. Outliers in question
replace cj_q15_norm=. if id_alex=="cj_English_1_949_2022_2023" //Kosovo - reduzco el cambio negativo en la pregunta  - 5.3 //
replace all_q84_norm=. if id_alex=="cc_English_0_1235_2022_2023" //Kosovo - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="cc_English_0_1413" //Kosovo - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q13_norm=. if id_alex=="cc_English_0_1235_2022_2023" //Kosovo - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q84_norm=. if id_alex=="cc_English_0_1413" //Kosovo - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="cc_English_0_1413" //Kosovo - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q13_norm=. if id_alex=="cc_English_0_1413" //Kosovo - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q84_norm=. if id_alex=="cc_English_1_344" //Kosovo - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="cc_English_1_344" //Kosovo - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q13_norm=. if id_alex=="cc_English_1_344" //Kosovo - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cj_q40b_norm=. if id_alex=="cj_English_1_93" //Kosovo - reduzco el cambio positivo en la pregunta  - 8.6 //
replace cj_q20m_norm=. if id_alex=="cj_English_1_474" //Kosovo - reduzco el cambio positivo en la pregunta  - 8.6 //

*Kuwait
drop if id_alex=="cc_English_1_703" //Kuwait: Highest CC
replace all_q96_norm=. if id_alex=="cc_Arabic_1_95" //Kuwait: Dropping 1 in question. Outlier.
foreach v in all_q48_norm all_q49_norm all_q50_norm lb_q19a_norm {
	replace `v'=. if id_alex=="cc_Arabic_1_95" //Kuwait: Dropping 1s. Outlier in sub-factor
}
foreach v in all_q76_norm all_q77_norm all_q78_norm all_q79_norm all_q80_norm all_q81_norm all_q82_norm {
	replace `v'=. if id_alex=="cc_Arabic_1_95" //Kuwait: Dropping 1s. Outlier in sub-factor
}
replace all_q88_norm=. if id_alex=="cc_Arabic_1_95" //Kuwait: Dropping 1 in question. Outlier.
foreach v in cj_q12a_norm cj_q12b_norm cj_q12c_norm cj_q12d_norm cj_q12e_norm cj_q12f_norm cj_q20o_norm {
	replace `v'=. if id_alex=="cj_English_0_742" //Kuwait: Dropping 1s. Outlier in sub-factor
}
replace cj_q20m_norm=. if id_alex=="cj_English_0_1348" //Kuwait: Dropping 1 in question. Outlier.
replace cc_q25_norm=. if id_alex=="cc_Arabic_1_95" //Kuwait - reduzco el cambio positivo en la pregunta  - 1.2 //
replace all_q4_norm=. if id_alex=="cc_Arabic_1_95" //Kuwait - reduzco el cambio positivo en la pregunta  - 1.2 //
replace all_q5_norm=. if id_alex=="cc_Arabic_1_95" //Kuwait - reduzco el cambio positivo en la pregunta  - 1.2 //
replace all_q8_norm=. if id_alex=="cj_English_0_1348" //Kuwait - reduzco el cambio positivo en la pregunta  - 1.2 //
replace all_q3_norm=. if id_alex=="lb_Arabic_1_590" //Kuwait - reduzco el cambio positivo en la pregunta  - 1.3 //
replace all_q4_norm=. if id_alex=="lb_Arabic_1_590" //Kuwait - reduzco el cambio positivo en la pregunta  - 1.3 //
replace all_q5_norm=. if id_alex=="cc_English_0_1288_2023" //Kuwait - reduzco el cambio positivo en la pregunta  - 1.3 //
replace all_q6_norm=. if id_alex=="lb_Arabic_1_590" //Kuwait - reduzco el cambio positivo en la pregunta  - 1.3 //
replace all_q7_norm=. if id_alex=="lb_Arabic_1_590" //Kuwait - reduzco el cambio positivo en la pregunta  - 1.3 //
replace all_q7_norm=. if id_alex=="cc_Arabic_1_95" //Kuwait - reduzco el cambio positivo en la pregunta  - 1.3 //
replace all_q8_norm=. if id_alex=="cc_Arabic_1_95" //Kuwait - reduzco el cambio positivo en la pregunta  - 1.3 //
replace all_q3_norm=. if id_alex=="cj_English_0_1348" //Kuwait - reduzco el cambio positivo en la pregunta  - 1.3 //
replace cc_q25_norm=. if id_alex=="cc_English_0_1288_2023" //Kuwait - reduzco el cambio positivo en la pregunta  - 1.3 //
replace cj_q38_norm=0 if id_alex=="cj_English_0_742" //Kuwait - reduzco el cambio positivo en la pregunta  - 1.4 //
replace cj_q8_norm=. if id_alex=="cj_English_0_1348" //Kuwait - reduzco el cambio positivo en la pregunta  - 1.4 //
replace cj_q8_norm=.5 if id_alex=="cj_English_0_742" //Kuwait - reduzco el cambio positivo en la pregunta  - 1.4 //
replace cc_q33_norm=. if id_alex=="cc_English_0_1288_2023" //Kuwait - reduzco el cambio positivo en la pregunta  - 1.4 //
replace all_q9_norm=. if id_alex=="cc_English_0_729_2023" //Kuwait - reduzco el cambio positivo en la pregunta  - 1.4 //
replace all_q9_norm=. if id_alex=="cc_English_1_997" //Kuwait - reduzco el cambio positivo en la pregunta  - 1.4 //
replace all_q24_norm=. if id_alex=="cc_English_0_677" //Kuwait - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q24_norm=. if id_alex=="cc_English_0_1286_2023" //Kuwait - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q27_norm=. if id_alex=="lb_English_0_216" //Kuwait - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q27_norm=. if id_alex=="lb_Arabic_1_590" //Kuwait - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q96_norm=. if id_alex=="lb_Arabic_1_590" //Kuwait - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="lb_English_0_216" //Kuwait - reduzco el cambio positivo en la pregunta  - 2.4 //
replace cc_q39d_norm=. if id_alex=="cc_English_0_795_2023" //Kuwait - reduzco el cambio negativo en la pregunta  - 3.2 //
replace lb_q16f_norm=.3333333 if id_alex=="lb_English_0_535_2023" //Kuwait - reduzco el cambio negativo en la pregunta  - 4.1 //
replace cj_q11a_norm=. if id_alex=="cj_English_0_742" //Kuwait - reduzco el cambio posivito en la pregunta  - 4.2 //
replace cj_q11b_norm=. if id_alex=="cj_English_0_742" //Kuwait - reduzco el cambio posivito en la pregunta  - 4.2 //
replace cj_q42c_norm=. if id_alex=="cj_English_0_742" //Kuwait - reduzco el cambio posivito en la pregunta  - 4.2 //
replace cj_q42d_norm=. if id_alex=="cj_English_0_742" //Kuwait - reduzco el cambio posivito en la pregunta  - 4.2 //
replace cj_q10_norm=. if id_alex=="cj_English_0_742" //Kuwait - reduzco el cambio posivito en la pregunta  - 4.2 //
replace cj_q10_norm=. if id_alex=="cj_English_0_1348" //Kuwait - reduzco el cambio posivito en la pregunta  - 4.2 //
replace lb_q23f_norm=. if id_alex=="lb_English_0_216" //Kuwait - reduzco el cambio posivito en la pregunta  - 4.8 //
replace lb_q23g_norm=. if id_alex=="lb_English_0_216" //Kuwait - reduzco el cambio posivito en la pregunta  - 4.8 //
replace cj_q15_norm=1 if id_alex=="cj_English_0_742" //Kuwait - reduzco el cambio negativo en la pregunta  - 5.3 //    
replace lb_q19a_norm=. if id_alex=="lb_English_0_216" //Kuwait - reduzco el cambio negativo en la pregunta  - 6.4 //    
replace cc_q11a_norm=. if id_alex=="cc_English_0_1286_2023" //Kuwait - reduzco el cambio posivito en la pregunta  - 6.5 //
replace all_q92_norm=. if id_alex=="cc_English_0_795_2023" //Kuwait - reduzco el cambio posivito en la pregunta  - 7.1 //
replace all_q75_norm=. if id_alex=="lb_English_0_216" //Kuwait - reduzco el cambio posivito en la pregunta  - 7.1 //
replace cc_q22a_norm=. if id_alex=="cc_Arabic_1_95" //Kuwait - reduzco el cambio posivito en la pregunta  - 7.1 //
replace cc_q22b_norm=. if id_alex=="cc_Arabic_1_95" //Kuwait - reduzco el cambio posivito en la pregunta  - 7.1 //
replace cc_q22c_norm=. if id_alex=="cc_Arabic_1_95" //Kuwait - reduzco el cambio posivito en la pregunta  - 7.1 //
replace all_q74_norm=. if id_alex=="cc_English_0_677" //Kuwait - reduzco el cambio posivito en la pregunta  - 7.1 //
replace all_q76_norm=. if id_alex=="lb_English_0_535_2023" //Kuwait - reduzco el cambio posivito en la pregunta  - 7.2 //
replace all_q77_norm=. if id_alex=="lb_English_0_535_2023" //Kuwait - reduzco el cambio posivito en la pregunta  - 7.2 //
replace all_q78_norm=. if id_alex=="lb_English_0_535_2023" //Kuwait - reduzco el cambio posivito en la pregunta  - 7.2//
replace all_q79_norm=. if id_alex=="lb_English_0_535_2023" //Kuwait - reduzco el cambio posivito en la pregunta  - 7.2 //
replace all_q80_norm=. if id_alex=="lb_English_0_535_2023" //Kuwait - reduzco el cambio posivito en la pregunta  - 7.2 //
replace all_q81_norm=. if id_alex=="lb_English_0_535_2023" //Kuwait - reduzco el cambio posivito en la pregunta  - 7.2 //
replace all_q84_norm=. if id_alex=="lb_Arabic_1_590" //Kuwait - reduzco el cambio posivito en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="lb_English_0_216" //Kuwait - reduzco el cambio posivito en la pregunta  - 7.5 //
replace cc_q26a_norm=. if id_alex=="cc_Arabic_1_95" //Kuwait - reduzco el cambio posivito en la pregunta  - 7.5 //
replace cc_q26b_norm=. if id_alex=="cc_English_0_795_2023" //Kuwait - reduzco el cambio posivito en la pregunta  - 7.6 //
replace cj_q20e_norm=. if id_alex=="cj_English_0_742" //Kuwait - reduzco el cambio posivito en la pregunta  - 8.2 //
replace cj_q7b_norm=. if id_alex=="cj_English_1_486" //Kuwait - reduzco el cambio posivito en la pregunta  - 8.2 //
replace cj_q20b_norm=. if id_alex=="cj_English_1_486" //Kuwait - reduzco el cambio posivito en la pregunta  - 8.2 //
replace cj_q21a_norm=. if id_alex=="cj_English_0_742" //Kuwait - reduzco el cambio posivito en la pregunta  - 8.3 //
replace cj_q20o_norm=0.2222222 if id_alex=="cj_English_0_742" //Kuwait - reduzco el cambio posivito en la pregunta  - 8.4 //
replace cj_q12e_norm=. if id_alex=="cj_English_1_486" //Kuwait - reduzco el cambio posivito en la pregunta  - 8.4 //
replace cj_q40b_norm=. if id_alex=="cj_English_1_486" //Kuwait - reduzco el cambio posivito en la pregunta  - 8.6 //
replace cj_q40c_norm=0 if id_alex=="cj_English_1_486" //Kuwait - reduzco el cambio posivito en la pregunta  - 8.6 //
replace cj_q40c_norm=.3333333 if id_alex=="cj_English_0_1348" //Kuwait - reduzco el cambio posivito en la pregunta  - 8.6 //

*Kyrgyz Republic
drop if id_alex=="cj_Russian_0_1021" //Kyrgyz Republic (muy positivo)
drop if id_alex=="cc_English_0_1413_2019_2021_2022_2023" //Kyrgyz Republic (muy positivo)
drop if id_alex=="cc_Russian_1_1376_2021_2022_2023" //Kyrgyz Republic (muy positivo)
replace cc_q40a_norm=. if country=="Kyrgyz Republic" //Kyrgyz Republic
replace cj_q21a_norm=. if id_alex=="cj_Russian_0_975_2021_2022_2023" //Kyrgyz Republic: Removing highest score in question
replace cj_q21g_norm=. if id_alex=="cj_Russian_0_1021" //Kyrgyz Republic: Removing highest score in question
replace cj_q21h_norm=. if id_alex=="cj_Russian_0_1021" //Kyrgyz Republic: Removing highest score in question
replace cj_q28_norm=. if id_alex=="cj_Russian_1_965_2018_2019_2021_2022_2023" //Kyrgyz Republic: Removing highest score in question
replace all_q2_norm=. if id_alex=="cc_English_0_454_2017_2018_2019_2021_2022_2023" //Kyrgyz Republic - reduzco el cambio posivito en la pregunta  - 1.2 //
replace all_q1_norm=. if id_alex=="lb_Russian_1_695_2021_2022_2023" //Kyrgyz Republic - reduzco el cambio posivito en la pregunta  - 1.2 //
replace all_q2_norm=. if id_alex=="lb_Russian_1_695_2021_2022_2023" //Kyrgyz Republic - reduzco el cambio posivito en la pregunta  - 1.2 //
replace all_q3_norm=. if id_alex=="cc_Russian_0_160" //Kyrgyz Republic - reduzco el cambio posivito en la pregunta  - 1.2 //
replace all_q94_norm=. if id_alex=="cj_Russian_0_843" //Kyrgyz Republic - reduzco el cambio posivito en la pregunta  - 1.6 //
replace all_q22_norm=. if id_alex=="cc_English_0_155_2017_2018_2019_2021_2022_2023" //Kyrgyz Republic - reduzco el cambio posivito en la pregunta  - 1.6 //
replace all_q22_norm=. if id_alex=="cc_English_0_685_2017_2018_2019_2021_2022_2023" //Kyrgyz Republic - reduzco el cambio posivito en la pregunta  - 1.7 //
replace all_q24_norm=. if id_alex=="cc_Russian_1_224_2019_2021_2022_2023" //Kyrgyz Republic - reduzco el cambio posivito en la pregunta  - 1.7 //
replace all_q25_norm=. if id_alex=="cc_Russian_1_224_2019_2021_2022_2023" //Kyrgyz Republic - reduzco el cambio posivito en la pregunta  - 1.7 //
replace cj_q24b_norm=. if id_alex=="cj_Russian_1_631" //Kyrgyz Republic - reduzco el cambio posivito en la pregunta  - 2.3 //
replace cj_q42d_norm=. if id_alex=="cj_English_1_940_2018_2019_2021_2022_2023" //Kyrgyz Republic - reduzco el cambio posivito en la pregunta  - 4.6 //
replace cj_q15_norm=0 if id_alex=="cj_Russian_1_307_2023" //Kyrgyz Republic - reduzco el cambio posivito en la pregunta  - 5.3 //
replace cj_q16d_norm=. if id_alex=="cj_Russian_0_843" //Kyrgyz Republic - reduzco el cambio posivito en la pregunta  - 8.1 //
replace cj_q16e_norm=. if id_alex=="cj_Russian_0_843" //Kyrgyz Republic - reduzco el cambio posivito en la pregunta  - 8.1 //
replace cj_q20a_norm=. if id_alex=="cj_Russian_0_975_2021_2022_2023" //Kyrgyz Republic - reduzco el cambio posivito en la pregunta  - 8.2 //
replace cj_q20b_norm=. if id_alex=="cj_Russian_0_975_2021_2022_2023" //Kyrgyz Republic - reduzco el cambio posivito en la pregunta  - 8.2 //
replace cj_q12b_norm=. if id_alex=="cj_English_1_940_2018_2019_2021_2022_2023" //Kyrgyz Republic - reduzco el cambio posivito en la pregunta  - 8.4 //
replace cj_q12c_norm=. if id_alex=="cj_English_1_940_2018_2019_2021_2022_2023" //Kyrgyz Republic - reduzco el cambio posivito en la pregunta  - 8.4 //
replace cj_q12d_norm=. if id_alex=="cj_English_1_940_2018_2019_2021_2022_2023" //Kyrgyz Republic - reduzco el cambio posivito en la pregunta  - 8.4 //
replace cj_q20o_norm=. if id_alex=="cj_Russian_1_857" //Kyrgyz Republic - reduzco el cambio posivito en la pregunta  - 8.4 //
replace cj_q40c_norm=. if id_alex=="cj_Russian_0_975_2021_2022_2023" //Kyrgyz Republic - reduzco el cambio posivito en la pregunta  - 8.4 //

*Latvia
drop if id_alex=="cc_English_0_528" //Latvia: Lowest CC
drop if id_alex=="cj_English_0_1352" //Latvia (muy negativo)
replace cj_q31f_norm=. if id_alex=="cj_English_0_1352" //Latvia: Removing 0s in question , outlier
replace cj_q31g_norm=. if id_alex=="cj_English_0_1352" //Latvia: Removing 0s in question , outlier
foreach v in all_q76_norm all_q77_norm all_q78_norm all_q79_norm all_q80_norm all_q81_norm all_q82_norm {
	replace `v'=. if id_alex=="lb_English_0_150" //Latvia: Removing 1s, outlier in sub-factor
	replace `v'=. if id_alex=="cc_English_0_1762_2022_2023" //Latvia: Removing 1s, outlier in sub-factor
	replace `v'=. if id_alex=="cc_English_0_392_2023" //Latvia: Removing 1s, outlier in sub-factor
}
replace cc_q26b_norm=. if id_alex=="cc_English_0_1676_2022_2023" //Latvia: Removing lowest score in question, outlier
replace all_q86_norm=. if id_alex=="cc_Russian_0_890" //Latvia: Removing lowest score in question, outlier
replace all_q87_norm=. if id_alex=="cc_English_1_1068_2022_2023" //Latvia: Removing lowest score in question, outlier
foreach v in cj_q40b_norm cj_q40c_norm cj_q20m_norm {
	replace `v'=. if id_alex=="cj_English_0_147" //Latvia: Removing 0s in questions, outliers
	replace `v'=. if id_alex=="cj_English_0_1352" //Latvia: Removing 0s in questions, outliers
	replace `v'=. if id_alex=="cj_English_0_620" //Latvia: Removing 0s in questions, outliers
}
replace cj_q38_norm=. if id_alex=="cj_English_0_387_2023" //Latvia - reduzco el cambio negativo en la pregunta  - 1.4 //
replace all_q13_norm=. if id_alex=="cj_English_0_719_2023" //Latvia - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q14_norm=. if id_alex=="cj_English_0_719_2023" //Latvia - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q15_norm=. if id_alex=="cj_English_0_147" //Latvia - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q16_norm=. if id_alex=="cj_English_0_147" //Latvia - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q17_norm=. if id_alex=="cj_English_0_147" //Latvia - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q18_norm=. if id_alex=="cc_English_0_849_2022_2023" //Latvia - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q19_norm=. if id_alex=="cj_English_0_147" //Latvia - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q20_norm=. if id_alex=="cj_English_0_147" //Latvia - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q21_norm=. if id_alex=="cj_English_0_147" //Latvia - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q94_norm=. if id_alex=="cj_English_0_147" //Latvia - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q54_norm=0 if id_alex=="cc_English_0_1957" //Latvia - reduzco el cambio positivo en la pregunta  - 2.1 //
replace all_q55_norm=. if id_alex=="cc_English_0_1361_2022_2023" //Latvia - reduzco el cambio positivo en la pregunta  - 2.1 //
replace lb_q17b_norm=. if id_alex=="lb_English_0_398_2022_2023" //Latvia - reduzco el cambio positivo en la pregunta  - 2.1 //
replace all_q96_norm=. if id_alex=="lb_English_0_475_2022_2023" //Latvia - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="lb_English_0_398_2022_2023" //Latvia - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_0_1676_2022_2023" //Latvia - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_0_493_2022_2023" //Latvia - reduzco el cambio negativo en la pregunta  - 2.4 //
replace cj_q42c_norm=. if id_alex=="cj_English_0_147" //Latvia - reduzco el cambio negativo en la pregunta  - 4.2 //
replace cj_q42d_norm=. if id_alex=="cj_English_0_147" //Latvia - reduzco el cambio negativo en la pregunta  - 4.2 //
replace cj_q10_norm=. if id_alex=="cj_English_0_147" //Latvia - reduzco el cambio negativo en la pregunta  - 4.2 //
replace all_q30_norm=. if id_alex=="cc_English_0_1957" //Latvia - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cj_English_1_937_2022_2023" //Latvia - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cc_English_0_1676_2022_2023" //Latvia - reduzco el cambio negativo en la pregunta  - 4.5 //
replace cj_q15_norm=. if id_alex=="cj_English_1_956_2022_2023" //Latvia - reduzco el cambio negativo en la pregunta  - 5.3 //
replace cc_q16a_norm=. if id_alex=="cc_English_0_1957" //Latvia - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q14a_norm=. if id_alex=="cc_English_0_1274" //Latvia - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q14b_norm=. if id_alex=="cc_English_0_1274" //Latvia - reduzco el cambio negativo en la pregunta  - 6.5 //
replace all_q76_norm=. if id_alex=="cc_English_0_910_2022_2023" //Latvia - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q88_norm=. if id_alex=="lb_English_0_150" //Latvia - reduzco el cambio positivo en la pregunta  - 7.5 //
replace cc_q26a_norm=. if id_alex=="cc_English_0_1585" //Latvia - reduzco el cambio positivo en la pregunta  - 7.5 //
replace all_q87_norm=. if id_alex=="lb_English_0_134_2021_2022_2023" //Latvia - reduzco el cambio negativo en la pregunta  - 7.6 //

*Lebanon
replace cj_q38_norm=. if id_alex=="cj_Arabic_1_835" //Lebanon: Removing 0 in question, outlier
foreach v in all_q62_norm all_q63_norm {
	replace `v'=. if id_alex=="cc_English_0_56" //Lebanon: Removing 1s, outliers in question
	replace `v'=. if id_alex=="cc_English_1_50" //Lebanon: Removing 1s, outliers in question
}
replace cj_q38_norm=. if id_alex=="cj_English_0_52" //Lebanon - reduzco el cambio negativo en la pregunta  - 1.4 //
replace cc_q40a_norm=. if id_alex=="cc_English_1_564" //Lebanon - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cc_q40b_norm=. if id_alex=="cc_English_1_564" //Lebanon - reduzco el cambio positivo en la pregunta  - 3.4 //
replace all_q17_norm=. if id_alex=="lb_English_1_650" //Lebanon - reduzco el cambio positivo en la pregunta  - 4.4 //
replace cj_q31f_norm=. if id_alex=="cj_English_1_1001" //Lebanon - reduzco el cambio positivo en la pregunta  - 4.7 //
replace cj_q31g_norm=. if id_alex=="cj_English_1_1001" //Lebanon - reduzco el cambio positivo en la pregunta  - 4.7 //
replace cc_q11a_norm=. if id_alex=="cc_English_1_274_2023" //Lebanon - reduzco el cambio positivo en la pregunta  - 6.5 //
replace cc_q16a_norm=. if id_alex=="cc_English_1_274_2023" //Lebanon - reduzco el cambio positivo en la pregunta  - 6.5 //
replace all_q77_norm=. if id_alex=="lb_English_1_211" //Lebanon - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q78_norm=. if id_alex=="lb_English_1_211" //Lebanon - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q79_norm=. if id_alex=="lb_English_1_211" //Lebanon - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q78_norm=. if id_alex=="lb_English_0_482_2013_2014_2016_2017_2018_2019_2021_2022_2023" //Lebanon - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q79_norm=. if id_alex=="lb_English_0_482_2013_2014_2016_2017_2018_2019_2021_2022_2023" //Lebanon - reduzco el cambio positivo en la pregunta  - 7.2 //
replace cc_q11a_norm=. if id_alex=="cc_English_1_274_2023" //Lebanon - reduzco el cambio positivo en la pregunta  - 7.4 //
replace cj_q20o_norm=. if id_alex=="cj_English_0_576_2022_2023" //Lebanon - reduzco el cambio negativo en la pregunta  - 8.4 //
replace cj_q40b_norm=. if id_alex=="cj_English_0_690_2022_2023" //Lebanon - reduzco el cambio negativo en la pregunta  - 8.6 //

*Liberia
replace all_q29_norm=. if id_alex=="cc_English_0_443_2022_2023" //Latvia - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cc_English_1_1285_2017_2018_2019_2021_2022_2023" //Latvia - reduzco el cambio positivo en la pregunta  - 4.5 //
replace lb_q23f_norm=. if id_alex=="lb_English_0_391" //Latvia - reduzco el cambio positivo en la pregunta  - 4.8 //
replace lb_q23g_norm=. if id_alex=="lb_English_0_391" //Latvia - reduzco el cambio positivo en la pregunta  - 4.8 //
replace all_q48_norm=. if id_alex=="lb_English_0_457_2022_2023" //Latvia - reduzco el cambio positivo en la pregunta  - 6.4 //
replace all_q49_norm=. if id_alex=="lb_English_0_457_2022_2023" //Latvia - reduzco el cambio positivo en la pregunta  - 6.4 //
replace all_q50_norm=. if id_alex=="lb_English_0_457_2022_2023" //Latvia - reduzco el cambio positivo en la pregunta  - 6.4 //
replace lb_q19a_norm=. if id_alex=="lb_English_0_457_2022_2023" //Latvia - reduzco el cambio positivo en la pregunta  - 6.4 //
replace all_q88_norm=. if id_alex=="cc_English_0_204_2016_2017_2018_2019_2021_2022_2023" //Latvia - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="cc_English_1_1285_2017_2018_2019_2021_2022_2023" //Latvia - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="cc_English_0_856_2017_2018_2019_2021_2022_2023" //Latvia - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cj_q20m_norm=. if id_alex=="cj_English_1_839_2019_2021_2022_2023" //Latvia - reduzco el cambio negativo en la pregunta  - 8.6 //

*Lithuania
drop if id_alex=="cc_English_0_1725" //Lithuania (muy positivo)
drop if id_alex=="cj_Russian_0_339" //Lithuania (muy positivo)
replace ph_q8d_norm=. if id_alex=="ph_English_0_203"  //Lithuania
replace ph_q8d_norm=. if id_alex=="ph_English_0_110" 
foreach v in ph_q8c_norm ph_q8e_norm ph_q8g_norm ph_q9d_norm ph_q12a_norm ph_q12b_norm ph_q12c_norm ph_q12d_norm ph_q12e_norm {
	replace `v'=. if id_alex=="ph_English_0_110" //Lithuania: Removing 1s in questions, outlier
}
replace all_q95_norm=. if id_alex=="cc_English_0_1725" //Lithuania: Removing 1s in questions, outlier
replace all_q95_norm=. if id_alex=="lb_English_1_77" //Lithuania: Removing 1s in questions, outlier
replace all_q95_norm=. if id_alex=="cc_English_0_455_2022_2023" //Lithuania: Removing 1s in questions, outlier
replace all_q95_norm=. if id_alex=="cj_English_1_751_2023" //Lithuania: Removing 1s in questions, outlier
foreach v in cj_q32c_norm cj_q32d_norm cj_q31a_norm cj_q31b_norm cj_q34a_norm cj_q34b_norm cj_q34c_norm cj_q34d_norm  cj_q34e_norm cj_q16j_norm cj_q18a_norm {
	replace `v'=. if id_alex=="cj_Russian_0_339" //Lithuania: Removing 1s in questions, outlier
	replace `v'=. if id_alex=="cj_English_1_751_2023" //Lithuania: Removing 1s in questions, outlier
	replace `v'=. if id_alex=="cj_English_0_472" //Lithuania: Removing 1s in questions, outlier
}
foreach v in lb_English_1_77 cj_English_1_751_2023 cc_English_0_1725 cc_English_0_455_2022_2023 {
	replace all_q96_norm=. if id_alex=="`v'" //Lithuania: Removing 1s in questions, outlier
}
foreach v in cj_q31f_norm cj_q31g_norm cj_q42c_norm cj_q42d_norm {
	replace `v'=. if id_alex=="cj_Russian_1_1007_2023" //Lithuania: Removing 1s in questions, outlier
	replace `v'=. if id_alex=="cj_English_1_751_2023" //Lithuania: Removing 1s in questions, outlier
}
replace all_q76_norm=. if id_alex=="lb_English_0_418" //Lithuania: Removing 0s in question, outlier
replace all_q77_norm=. if id_alex=="lb_English_0_418" //Lithuania: Removing 0s in question, outlier
replace all_q78_norm=. if id_alex=="lb_English_0_418" //Lithuania: Removing 0s in question, outlier
replace all_q80_norm=. if id_alex=="cc_English_0_857" //Lithuania: Removing low score in question, outlier
replace cj_q21a_norm=. if id_alex=="cj_English_0_550" //Lithuania: Removing 1s in questions, outlier
replace cj_q21e_norm=. if id_alex=="cj_Russian_0_339" //Lithuania: Removing highest score in questions, outlier
replace cj_q28_norm=. if id_alex=="cj_English_0_222_2023" //Lithuania: Removing highest score in questions, outlier
foreach v in cj_q40b_norm cj_q40c_norm cj_q20m_norm {
	replace `v'=. if id_alex=="cj_Russian_0_339" //Lithuania: Removing 1s in questions, outlier
	replace `v'=. if id_alex=="cj_English_1_751_2023" //Lithuania: Removing 1s in questions, outlier
	replace `v'=. if id_alex=="cj_English_1_111" //Lithuania: Removing 1s in questions, outlier
} 
replace all_q1_norm=. if id_alex=="cc_English_0_1730_2021_2022_2023" //Lithuania - reduzco el cambio negativo en la pregunta  - 1.2 //
replace cc_q25_norm=. if id_alex=="cc_English_0_857" //Lithuania - reduzco el cambio negativo en la pregunta  - 1.3 //
replace all_q6_norm=. if id_alex=="cc_English_0_1093" //Lithuania - reduzco el cambio negativo en la pregunta  - 1.3 //
replace cj_q38_norm=. if id_alex=="cj_Russian_0_841_2022_2023" //Lithuania - reduzco el cambio positivo en la pregunta  - 1.4 //
replace all_q28_norm=. if id_alex=="lb_English_0_418" //Lithuania - reduzco el cambio positivo en la pregunta  - 2.2 //
replace all_q6_norm=. if id_alex=="lb_English_0_418" //Lithuania - reduzco el cambio positivo en la pregunta  - 2.2 //
replace all_q6_norm=. if id_alex=="cc_English_1_165_2023" //Lithuania - reduzco el cambio positivo en la pregunta  - 2.2 //
replace cj_q32c_norm=. if id_alex=="cj_English_0_144_2023" //Lithuania - reduzco el cambio positivo en la pregunta  - 2.3 //
replace cj_q32d_norm=. if id_alex=="cj_English_0_144_2023" //Lithuania - reduzco el cambio positivo en la pregunta  - 2.3 //
replace cj_q31a_norm=. if id_alex=="cj_English_0_144_2023" //Lithuania - reduzco el cambio positivo en la pregunta  - 2.3 //
replace cj_q31b_norm=. if id_alex=="cj_English_0_144_2023" //Lithuania - reduzco el cambio positivo en la pregunta  - 2.3 //
replace cj_q34a_norm=. if id_alex=="cj_English_0_144_2023" //Lithuania - reduzco el cambio positivo en la pregunta  - 2.3 //
replace cj_q34b_norm=. if id_alex=="cj_English_0_144_2023" //Lithuania - reduzco el cambio positivo en la pregunta  - 2.3 //
replace cj_q34c_norm=. if id_alex=="cj_English_0_144_2023" //Lithuania - reduzco el cambio positivo en la pregunta  - 2.3 //
replace cj_q34d_norm=. if id_alex=="cj_English_0_144_2023" //Lithuania - reduzco el cambio positivo en la pregunta  - 2.3 //
replace cj_q34e_norm=. if id_alex=="cj_English_0_144_2023" //Lithuania - reduzco el cambio positivo en la pregunta  - 2.3 //
replace cj_q34e_norm=. if id_alex=="cj_English_0_144_2023" //Lithuania - reduzco el cambio positivo en la pregunta  - 2.3 //
replace cj_q16j_norm=. if id_alex=="cj_English_0_144_2023" //Lithuania - reduzco el cambio positivo en la pregunta  - 2.3 //
replace cj_q18a_norm=. if id_alex=="cj_English_0_144_2023" //Lithuania - reduzco el cambio positivo en la pregunta  - 2.3 //
replace cj_q42c_norm=. if id_alex=="cj_English_0_400_2022_2023" //Lithuania - reduzco el cambio positivo en la pregunta  - 4.2 //
replace cj_q42d_norm=. if id_alex=="cj_English_0_400_2022_2023" //Lithuania - reduzco el cambio positivo en la pregunta  - 4.2 //
replace cj_q10_norm=. if id_alex=="cj_English_0_400_2022_2023" //Lithuania - reduzco el cambio positivo en la pregunta  - 4.2 //
replace cj_q31g_norm=. if id_alex=="cj_English_0_430_2022_2023" //Lithuania - reduzco el cambio positivo en la pregunta  - 4.6 //
replace lb_q23g_norm=. if id_alex=="lb_Russian_0_228" //Lithuania - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q16e_norm=. if id_alex=="lb_English_0_665_2023" //Lithuania - reduzco el cambio negativo en la pregunta  - 4.8 //
replace all_q49_norm=. if id_alex=="lb_Russian_0_228" //Lithuania - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q50_norm=. if id_alex=="lb_Russian_0_228" //Lithuania - reduzco el cambio negativo en la pregunta  - 6.4 //
replace cc_q16f_norm=. if id_alex=="cc_English_0_1093" //Lithuania - reduzco el cambio negativo en la pregunta  - 6.5 //
replace all_q72_norm=. if id_alex=="cc_English_0_1093" //Lithuania - reduzco el cambio positivo en la pregunta  - 7.1 //
replace all_q71_norm=. if id_alex=="cc_English_1_165_2023" //Lithuania - reduzco el cambio positivo en la pregunta  - 7.1 //
replace all_q76_norm=. if id_alex=="cc_English_0_857" //Lithuania - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q77_norm=. if id_alex=="cc_English_0_857" //Lithuania - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q78_norm=. if id_alex=="cc_English_0_857" //Lithuania - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q79_norm=. if id_alex=="cc_English_0_857" //Lithuania - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q80_norm=. if id_alex=="cc_English_0_857" //Lithuania - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q81_norm=. if id_alex=="cc_English_0_857" //Lithuania - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q82_norm=. if id_alex=="cc_English_0_857" //Lithuania - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q80_norm=. if id_alex=="cc_English_0_159_2021_2022_2023" //Lithuania - reduzco el cambio positivo en la pregunta  - 7.2 //
replace all_q3_norm=. if id_alex=="cj_English_0_472" //Lithuania - reduzco el cambio positivo en la pregunta  - 7.4 //
replace cc_q26b_norm=. if id_alex=="cc_Russian_0_301" //Lithuania - reduzco el cambio negativo en la pregunta  - 7.6 //
replace all_q86_norm=. if id_alex=="cc_Russian_0_301" //Lithuania - reduzco el cambio negativo en la pregunta  - 7.6 //
replace cj_q40b_norm=. if id_alex=="cj_English_0_92" //Lithuania - reduzco el cambio positivo en la pregunta  - 8.6 //
replace cj_q40c_norm=. if id_alex=="cj_English_0_92" //Lithuania - reduzco el cambio positivo en la pregunta  - 8.6 //
replace cj_q20m_norm=. if id_alex=="cj_English_0_92" //Lithuania - reduzco el cambio positivo en la pregunta  - 8.6 //

*Luxembourg
drop if id_alex=="cc_English_0_1899" //Luxembourg (muy negativo)
replace all_q89_norm=. if country=="Luxembourg" //Luxembourg
replace lb_q2d_norm=. if id_alex=="lb_French_0_561" //Luxembourg: Removing low score, outlier
replace all_q48_norm=. if id_alex=="lb_French_0_561" //Luxembourg: Removing low score, outlier 
replace all_q49_norm=. if id_alex=="lb_French_0_561" //Luxembourg: Removing low score, outlier 
replace all_q50_norm=. if id_alex=="lb_French_0_561" //Luxembourg: Removing low score, outlier 
replace all_q49_norm=. if id_alex=="cc_English_0_1899" //Luxembourg: Removing low score, outlier 
replace all_q50_norm=. if id_alex=="cc_English_0_1899" //Luxembourg: Removing low score, outlier 
replace cc_q10_norm=. if id_alex=="cc_French_1_1270_2023" //Luxembourg: Removing low score, outlier 
replace cc_q10_norm=. if id_alex=="cc_English_0_1602" //Luxembourg: Removing low score, outlier 
replace cc_q11a_norm=. if id_alex=="cc_English_0_1602" //Luxembourg: Removing low score, outlier  
replace cc_q14a_norm=. if id_alex=="cc_English_0_1899" //Luxembourg: Removing low score, outlier  
replace cc_q14b_norm=. if id_alex=="cc_English_0_1899" //Luxembourg: Removing low score, outlier  
replace cc_q16e_norm=. if id_alex=="cc_English_0_1899" //Luxembourg: Removing low score, outlier  
foreach v in all_q76_norm all_q78_norm all_q79_norm all_q80_norm all_q81_norm all_q82_norm {
	replace `v'=. if `v'==0 & country=="Luxembourg" //Luxembourg: Removing 0s, outliers in questions
}
replace all_q84_norm=. if id_alex=="cc_English_0_1023" //Luxembourg: Removing low score, outlier  
replace cc_q13_norm=. if id_alex=="cc_French_0_755_2023" //Luxembourg: Removing 0s, outliers in questions
replace all_q88_norm=. if id_alex=="lb_English_0_635_2021_2022_2023" //Luxembourg: Removing 0s, outliers in questions
replace cc_q26a_norm=. if id_alex=="cc_French_0_755_2023" //Luxembourg: Removing low score, outlier  
replace all_q1_norm=. if id_alex=="cc_English_0_1023" //Luxembourg - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q1_norm=. if id_alex=="cc_English_0_1164" //Luxembourg - reduzco el cambio negativo en la pregunta  - 1.2 //
replace cc_q25_norm=. if id_alex=="cc_English_0_1023" //Luxembourg - reduzco el cambio positivo en la pregunta  - 1.3 //
replace all_q17_norm=. if id_alex=="lb_French_0_28_2021_2022_2023" //Luxembourg - reduzco el cambio positivo en la pregunta  - 1.6 //
replace cc_q40b_norm=. if id_alex=="cc_English_0_1518_2021_2022_2023" //Luxembourg - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cc_q28b_norm=. if id_alex=="cc_English_0_1602" //Luxembourg - reduzco el cambio positivo en la pregunta  - 6.2 //
replace cc_q28c_norm=. if id_alex=="cc_English_0_1602" //Luxembourg - reduzco el cambio positivo en la pregunta  - 6.2 //
replace cc_q28d_norm=. if id_alex=="cc_English_0_1602" //Luxembourg - reduzco el cambio positivo en la pregunta  - 6.2 //
replace lb_q3d_norm=1 if id_alex=="lb_English_1_517_2023" //Luxembourg - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q63_norm=. if id_alex=="cc_English_0_1078" //Luxembourg - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q48_norm=. if id_alex=="lb_French_0_28_2021_2022_2023" //Luxembourg - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q49_norm=. if id_alex=="lb_French_0_28_2021_2022_2023" //Luxembourg - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q50_norm=. if id_alex=="lb_French_0_28_2021_2022_2023" //Luxembourg - reduzco el cambio negativo en la pregunta  - 6.4 //
replace lb_q19a_norm=. if id_alex=="lb_French_0_28_2021_2022_2023" //Luxembourg - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q50_norm=. if id_alex=="cc_French_0_1362_2021_2022_2023" //Luxembourg - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q48_norm=. if id_alex=="cc_French_0_349_2023" //Luxembourg - reduzco el cambio negativo en la pregunta  - 6.4 //
replace cc_q10_norm=. if id_alex=="cc_French_0_1362_2021_2022_2023" //Luxembourg - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q14a_norm=. if id_alex=="cc_Spanish_0_1112_2022_2023" //Luxembourg - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q16b_norm=. if id_alex=="cc_English_0_1023" //Luxembourg - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q16c_norm=. if id_alex=="cc_English_0_1023" //Luxembourg - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q12_norm=. if id_alex=="cc_English_0_1078" //Luxembourg - reduzco el cambio negativo en la pregunta  - 7.1 //
replace all_q74_norm=. if id_alex=="cc_French_0_755_2023" //Luxembourg - reduzco el cambio negativo en la pregunta  - 7.1 //
replace all_q75_norm=. if id_alex=="cc_Spanish_0_1112_2022_2023" //Luxembourg - reduzco el cambio negativo en la pregunta  - 7.1 //
replace all_q71_norm=. if id_alex=="cc_English_0_1602" //Luxembourg - reduzco el cambio negativo en la pregunta  - 7.1 //
replace all_q72_norm=. if id_alex=="cc_English_0_1602" //Luxembourg - reduzco el cambio negativo en la pregunta  - 7.1 //
replace all_q88_norm=. if id_alex=="cc_English_0_1078" //Luxembourg - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="cc_French_1_1270_2023" //Luxembourg - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q26a_norm=. if id_alex=="cc_English_0_1078" //Luxembourg - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q85_norm=. if id_alex=="lb_French_0_888_2021_2022_2023" //Luxembourg - reduzco el cambio negativo en la pregunta  - 7.5 //

*Madagascar
foreach v in all_q59_norm cc_q26h_norm cc_q28e_norm {
	replace `v'=. if id_alex=="cc_French_0_1453" //Madagascar: Removing highest scores, outliers in question
}
replace all_q59_norm=. if id_alex=="lb_French_1_669_2022_2023" //Madagascar: Removing highest scores, outliers in question
replace cj_q33c_norm=. if id_alex=="cj_French_0_224" //Madagascar: Removing highest scores, outliers in question

replace cc_q28e_norm=. if id_alex=="cc_English_0_652_2022_2023" //Madagascar: Removing highest scores, outliers in question
replace all_q59_norm=. if id_alex=="lb_French_0_276_2023" //Madagascar: Removing highest scores, outliers in question
foreach v in cc_English_0_1287_2022_2023 cc_English_0_652_2022_2023 ph_French_0_540_2021_2022_2023 ph_French_0_56 {
	replace all_q54_norm=. if id_alex=="`v'" //Madagascar: Removing 1s, outliers in question
}
replace cc_q16a_norm=. if id_alex=="cc_English_0_616_2023" //Madagascar: Removing 1s, outliers in question

foreach v in cc_q14a_norm cc_q14b_norm cc_q16b_norm cc_q16c_norm cc_q16d_norm {
	replace `v'=. if id_alex=="cc_French_0_239_2022_2023" //Madagascar: Removing 1s, outliers in sub-factor
}
foreach v in cc_French_0_239_2022_2023 cc_English_0_652_2022_2023 cc_French_0_183 {
	replace cc_q1_norm=. if id_alex=="`v'" //Madagascar: Removing 1s, outliers in question
}
replace all_q51_norm=. if id_alex=="lb_French_0_534_2017_2018_2019_2021_2022_2023" //Madagascar: Removing 1s, outliers in question
replace cc_q26h_norm=. if id_alex=="cc_French_0_183" //Madagascar: Removing highest score, outliers in question
replace cc_q28e_norm=. if id_alex=="cc_French_0_183" //Madagascar: Removing highest score, outliers in question

foreach v in lb_q6c_norm all_q57_norm all_q58_norm  {
	replace `v'=. if id_alex=="lb_French_0_535" //Madagascar: Removing highest score, outliers in question
}
replace cc_q26h_norm=. if id_alex=="cc_French_1_1232_2022_2023" //Madagascar: Removing highest score, outliers in question
replace cc_q28e_norm=. if id_alex=="cc_French_0_1970" //Madagascar: Removing highest score, outliers in question
replace all_q59_norm=. if id_alex=="lb_French_1_242" //Madagascar: Removing 1s, outliers in question
replace cc_q1_norm=. if id_alex=="cc_English_0_616_2023" //Madagascar: Removing 1s, outliers in question
replace cc_q1_norm=. if id_alex=="cc_French_1_1232_2022_2023" //Madagascar: Removing 1s, outliers in question
replace all_q26_norm=. if id_alex=="lb_French_0_425" //Madagascar - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q27_norm=. if id_alex=="lb_French_0_425" //Madagascar - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q8_norm=. if id_alex=="lb_French_0_425" //Madagascar - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q26_norm=. if id_alex=="cj_English_1_1233_2021_2022_2023" //Madagascar - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q27_norm=. if id_alex=="cj_English_1_1233_2021_2022_2023" //Madagascar - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q8_norm=. if id_alex=="cj_English_1_1233_2021_2022_2023" //Madagascar - reduzco el cambio negativo en la pregunta  - 1.7 //
replace cc_q26h_norm=. if id_alex=="cc_English_0_616_2023" //Madagascar - reduzco el cambio positivo en la pregunta  - 2.2 //
replace all_q40_norm=. if id_alex=="cc_French_1_350" //Madagascar - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q41_norm=. if id_alex=="cc_French_1_350" //Madagascar - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q42_norm=. if id_alex=="cc_French_1_350" //Madagascar - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q43_norm=. if id_alex=="cc_French_1_350" //Madagascar - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q44_norm=. if id_alex=="cc_French_1_350" //Madagascar - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q45_norm=. if id_alex=="cc_French_1_350" //Madagascar - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q46_norm=. if id_alex=="cc_French_1_350" //Madagascar - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q47_norm=. if id_alex=="cc_French_1_350" //Madagascar - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q9c_norm=. if id_alex=="cc_French_0_1453" //Madagascar - reduzco el cambio positivo en la pregunta  - 3.4 //
replace all_q85_norm=. if id_alex=="cc_French_0_933_2022_2023" //Madagascar - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q85_norm=. if id_alex=="lb_French_1_375" //Madagascar - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q13_norm=. if id_alex=="cc_French_1_608_2022_2023" //Madagascar - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q26a_norm=. if id_alex=="cc_French_0_1970" //Madagascar - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q89_norm=. if id_alex=="cc_French_0_239_2022_2023" //Madagascar - reduzco el cambio positivo en la pregunta  - 7.7 //

*Malawi
drop if id_alex=="cj_English_0_165" // Malawi (muy negativo)
replace cc_q25_norm=. if country=="Malawi" // Malawi (se elimino el anio pasado)
replace cj_q38_norm=. if country=="Malawi" // Malawi (se elimino el anio pasado)
replace lb_q3d_norm=. if id_alex=="lb_English_0_55_2021_2022_2023" // Malawi - reduzco el cambio positivo en la pregunta  - 6.3 //
replace all_q62_norm=. if id_alex=="cc_English_0_269_2021_2022_2023" // Malawi - reduzco el cambio positivo en la pregunta  - 6.3 //
replace cc_q14a_norm=. if id_alex=="cc_English_0_879_2022_2023" // Malawi - reduzco el cambio positivo en la pregunta  - 6.5 //
replace cc_q14b_norm=. if id_alex=="cc_English_0_879_2022_2023" // Malawi - reduzco el cambio positivo en la pregunta  - 6.5 //
replace cc_q16b_norm=. if id_alex=="cc_English_0_879_2022_2023" // Malawi - reduzco el cambio positivo en la pregunta  - 6.5 //
replace cc_q16c_norm=. if id_alex=="cc_English_0_879_2022_2023" // Malawi - reduzco el cambio positivo en la pregunta  - 6.5 //
replace cc_q16d_norm=. if id_alex=="cc_English_0_879_2022_2023" // Malawi - reduzco el cambio positivo en la pregunta  - 6.5 //
replace cc_q16e_norm=. if id_alex=="cc_English_0_879_2022_2023" // Malawi - reduzco el cambio positivo en la pregunta  - 6.5 //
replace cc_q16f_norm=. if id_alex=="cc_English_0_879_2022_2023" // Malawi - reduzco el cambio positivo en la pregunta  - 6.5 //
replace cc_q16g_norm=. if id_alex=="cc_English_0_879_2022_2023" // Malawi - reduzco el cambio positivo en la pregunta  - 6.5 //

*Malaysia
replace cj_q36c_norm=. if id_alex=="cj_English_0_412_2016_2017_2018_2019_2021_2022_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 1.4 //
replace ph_q7_norm=. if id_alex=="ph_English_1_242_2017_2018_2019_2021_2022_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 2.1 //
replace cc_q39a_norm=. if id_alex=="cc_English_0_235_2018_2019_2021_2022_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39b_norm=. if id_alex=="cc_English_0_235_2018_2019_2021_2022_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39c_norm=. if id_alex=="cc_English_0_235_2018_2019_2021_2022_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39d_norm=. if id_alex=="cc_English_0_235_2018_2019_2021_2022_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39e_norm=. if id_alex=="cc_English_0_235_2018_2019_2021_2022_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q40_norm=. if id_alex=="cc_English_0_235_2018_2019_2021_2022_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q41_norm=. if id_alex=="cc_English_0_235_2018_2019_2021_2022_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q42_norm=. if id_alex=="cc_English_0_235_2018_2019_2021_2022_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q43_norm=. if id_alex=="cc_English_0_235_2018_2019_2021_2022_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q44_norm=. if id_alex=="cc_English_0_235_2018_2019_2021_2022_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q45_norm=. if id_alex=="cc_English_0_235_2018_2019_2021_2022_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q46_norm=. if id_alex=="cc_English_0_235_2018_2019_2021_2022_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q47_norm=. if id_alex=="cc_English_0_235_2018_2019_2021_2022_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q40a_norm=. if id_alex=="cc_English_0_1529_2018_2019_2021_2022_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q40b_norm=. if id_alex=="cc_English_0_1529_2018_2019_2021_2022_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q41_norm=. if id_alex=="cc_English_1_709_2016_2017_2018_2019_2021_2022_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q42_norm=. if id_alex=="cc_English_1_709_2016_2017_2018_2019_2021_2022_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q47_norm=. if id_alex=="cc_English_1_709_2016_2017_2018_2019_2021_2022_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q9c_norm=. if id_alex=="cc_English_0_63" // Malaysia - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cj_q15_norm=. if id_alex=="cj_English_0_372_2016_2017_2018_2019_2021_2022_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 5.3 /
replace all_q29_norm=. if id_alex=="cc_English_0_769_2021_2022_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cc_English_0_63" // Malaysia - reduzco el cambio negativo en la pregunta  - 4.5 //
replace cj_q42c_norm=. if id_alex=="cj_English_0_1371_2018_2019_2021_2022_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 4.6 //
replace cj_q42d_norm=. if id_alex=="cj_English_0_1371_2018_2019_2021_2022_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 4.6 //
replace lb_q23f_norm=. if id_alex=="lb_English_1_325" // Malaysia - reduzco el cambio negativo en la pregunta  - 4.8 //
replace all_q92_norm=. if id_alex=="cc_English_1_709_2016_2017_2018_2019_2021_2022_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 7.1 //
replace all_q74_norm=. if id_alex=="cc_English_1_709_2016_2017_2018_2019_2021_2022_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 7.1 //
replace all_q70_norm=. if id_alex=="cc_English_1_709_2016_2017_2018_2019_2021_2022_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 7.1 //
replace all_q92_norm=. if id_alex=="lb_English_0_124_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 7.1 //
replace all_q88_norm=. if id_alex=="cc_English_0_1450_2016_2017_2018_2019_2021_2022_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="cc_English_1_709_2016_2017_2018_2019_2021_2022_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cj_q21a_norm=. if id_alex=="cj_English_0_494_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 8.3 //
replace cj_q21e_norm=. if id_alex=="cj_English_0_494_2023" // Malaysia - reduzco el cambio negativo en la pregunta  - 8.3 //

*Mali
drop if id_alex=="cc_French_1_1111" // Mali (muy positivo)
drop if id_alex=="cj_French_0_1072" // Mali (muy positivo)
drop if id_alex=="cc_French_0_1693" // Mali (muy positivo)
drop if id_alex=="cj_English_0_687" // Mali (muy positivo)
replace cc_q33_norm=. if country=="Mali" // Mali (se elimino el anio pasado)
replace cj_q36c_norm=. if id_alex=="cj_French_0_1348_2018_2019_2021_2022_2023" // Mali - reduzco el cambio positivo en la pregunta  - 1.4 //
replace all_q12_norm=. if id_alex=="cj_French_1_598" // Mali - reduzco el cambio positivo en la pregunta  - 1.5 //
replace cc_q27_norm=. if id_alex=="cc_French_0_687_2018_2019_2021_2022_2023" // Mali - reduzco el cambio positivo en la pregunta  - 2.1 //
replace cc_q27_norm=. if id_alex=="cc_French_0_54_2018_2019_2021_2022_2023" // Mali - reduzco el cambio positivo en la pregunta  - 2.1 //
replace all_q96_norm=. if id_alex=="cj_French_0_1348_2018_2019_2021_2022_2023" // Mali - reduzco el cambio positivo en la pregunta  - 2.4 //
replace cj_q11b_norm=. if id_alex=="cj_French_0_458_2018_2019_2021_2022_2023" // Mali - reduzco el cambio positivo en la pregunta  - 4.2 //
replace cj_q11b_norm=. if id_alex=="cj_French_0_371_2021_2022_2023" // Mali - reduzco el cambio positivo en la pregunta  - 4.2 //
replace all_q15_norm=. if id_alex=="cj_French_1_598" // Mali - reduzco el cambio positivo en la pregunta  - 4.6 //
replace all_q16_norm=. if id_alex=="cj_French_1_598" // Mali - reduzco el cambio positivo en la pregunta  - 4.6 //
replace all_q17_norm=. if id_alex=="cj_French_0_1348_2018_2019_2021_2022_2023" // Mali - reduzco el cambio positivo en la pregunta  - 4.6 //
replace all_q17_norm=. if id_alex=="cj_French_0_353_2018_2019_2021_2022_2023" // Mali - reduzco el cambio positivo en la pregunta  - 4.6 //
replace all_q21_norm=. if id_alex=="cc_French_0_62_2018_2019_2021_2022_2023" // Mali - reduzco el cambio positivo en la pregunta  - 4.6 //
replace all_q19_norm=. if id_alex=="cc_French_0_69_2018_2019_2021_2022_2023" // Mali - reduzco el cambio negativo en la pregunta (removi GPP) - 4.7 (Q) //
replace all_q31_norm=. if id_alex=="cc_French_0_69_2018_2019_2021_2022_2023" // Mali - reduzco el cambio negativo en la pregunta (removi GPP) - 4.7 (Q) //
replace all_q32_norm=. if id_alex=="cc_French_0_69_2018_2019_2021_2022_2023" // Mali - reduzco el cambio negativo en la pregunta (removi GPP) - 4.7 (Q) //
replace all_q14_norm=. if id_alex=="cc_French_0_69_2018_2019_2021_2022_2023" // Mali - reduzco el cambio negativo en la pregunta (removi GPP) - 4.7 (Q) //
replace all_q31_norm=. if id_alex=="cc_French_0_56_2018_2019_2021_2022_2023" // Mali - reduzco el cambio negativo en la pregunta (removi GPP) - 4.7 (Q) //
replace all_q84_norm=.25 if id_alex=="cc_French_0_762_2022_2023" // Mali - reduzco el nivel de la pregunta (muy alta)  - 7.5 //
replace all_q85_norm=.25 if id_alex=="cc_French_0_762_2022_2023" // Mali - reduzco el nivel de la pregunta (muy alta)  - 7.5 //
replace cc_q13_norm=. if id_alex=="cc_French_1_553" // Mali - reduzco el nivel de la pregunta (muy alta)  - 7.5 //
replace cc_q13_norm=. if id_alex=="cc_French_0_977_2019_2021_2022_2023" // Mali - reduzco el nivel de la pregunta (muy alta)  - 7.5 //
replace all_q86_norm=. if id_alex=="lb_English_1_828_2022_2023" // Mali - reduzco el cambio positivo de la pregunta  - 7.6 //
replace all_q87_norm=. if id_alex=="lb_English_1_828_2022_2023" // Mali - reduzco el cambio positivo de la pregunta  - 7.6 //
replace all_q86_norm=. if id_alex=="cc_French_0_56_2018_2019_2021_2022_2023" // Mali - reduzco el cambio positivo de la pregunta  - 7.6 //
replace all_q87_norm=. if id_alex=="cc_French_0_56_2018_2019_2021_2022_2023" // Mali - reduzco el cambio positivo de la pregunta  - 7.6 //
replace cc_q26b_norm=. if id_alex=="cc_French_0_62_2018_2019_2021_2022_2023" // Mali - reduzco el cambio positivo de la pregunta  - 7.6 //
replace cj_q40b_norm=. if id_alex=="cj_French_1_598" // Mali - reduzco el cambio positivo de la pregunta  - 8.6 //
replace cj_q40c_norm=. if id_alex=="cj_French_1_598" // Mali - reduzco el cambio positivo de la pregunta  - 8.6 //

*Malta
drop if id_alex=="cc_English_0_1753" // Malta (muy negativo)
drop if id_alex=="cc_English_0_327" // Malta (muy negativo)
drop if id_alex=="cc_English_0_40_2022_2023" // Malta (muy negativo)
drop if id_alex=="cc_English_0_40_2022_2023" // Malta (muy negativo)
replace lb_q19a_norm=. if country=="Malta" // Malta (se elimino el anio pasado)
replace cj_q27a_norm=. if country=="Malta" // Malta (se elimino el anio pasado)
replace all_q1_norm=. if id_alex=="cc_English_0_1335_2021_2022_2023" // Malta - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q1_norm=. if id_alex=="cj_English_1_895_2023" // Malta - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q3_norm=. if id_alex=="cc_English_1_528" // Malta - reduzco el cambio negativo en la pregunta  - 1.3 //
replace cc_q33_norm=. if id_alex=="cc_English_0_534_2021_2022_2023" // Malta - reduzco el cambio positivo en la pregunta  - 1.4 //
replace cj_q9_norm=. if id_alex=="cj_English_0_587" // Malta - reduzco el cambio negativo en la pregunta  - 1.5 //
replace all_q10_norm=. if id_alex=="lb_English_0_11" // Malta - reduzco el cambio negativo en la pregunta  - 1.5 //
replace all_q11_norm=. if id_alex=="lb_English_0_11" // Malta - reduzco el cambio negativo en la pregunta  - 1.5 //
replace cj_q10_norm=. if id_alex=="cj_English_0_587" // Malta - reduzco el cambio negativo en la pregunta  - 1.6 //
replace cj_q10_norm=. if id_alex=="cj_English_0_535" // Malta - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q96_norm=. if id_alex=="cc_English_0_905_2022_2023" // Malta - ajustoo el cambio negativo del GPP  - 2.4 //
replace all_q96_norm=. if id_alex=="lb_English_0_11" // Malta - ajustoo el cambio negativo del GPP  - 2.4 //
replace all_q96_norm=. if id_alex=="lb_English_1_311" // Malta - ajustoo el cambio negativo del GPP  - 2.4 //
replace all_q29_norm=. if id_alex=="cc_English_0_1335_2021_2022_2023" // Malta - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cj_English_1_895_2023" // Malta - reduzco el cambio negativo en la pregunta  - 4.5 //
replace cj_q31f_norm=. if id_alex=="cj_English_0_587" // Malta - reduzco el cambio negativo en la pregunta  - 4.6 //
replace lb_q23g_norm=. if id_alex=="lb_English_0_11" // Malta - reduzco el cambio negativo en la pregunta  - 4.8 //
replace cj_q15_norm=. if id_alex=="cj_English_0_587" // Malta - reduzco el cambio negativo en la pregunta  - 5.3 //
replace cj_q15_norm=. if id_alex=="cj_English_0_535" // Malta - reduzco el cambio negativo en la pregunta  - 5.3 //
replace all_q50_norm=. if id_alex=="lb_English_0_11" // Malta - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q6_norm=. if id_alex=="lb_English_0_11" // Malta - reduzco el cambio negativo en la pregunta  - 7.4 //
replace all_q3_norm=. if id_alex=="lb_English_0_11" // Malta - reduzco el cambio negativo en la pregunta  - 7.4 //
replace all_q4_norm=. if id_alex=="lb_English_0_11" // Malta - reduzco el cambio negativo en la pregunta  - 7.4 //
replace all_q7_norm=. if id_alex=="lb_English_0_11" // Malta - reduzco el cambio negativo en la pregunta  - 7.4 //
replace cj_q7a_norm=. if id_alex=="cj_English_0_587" // Malta - reduzco el cambio negativo en la pregunta  - 8.2 //

*Mauritania
replace cj_q36c_norm=.3333333 if id_alex=="cj_Arabic_0_1018_2023" // Mauritania - reduzco el cambio positivo en la pregunta  - 1.4 //
replace cj_q38_norm=. if id_alex=="cj_French_0_564" // Mauritania - reduzco el cambio positivo en la pregunta  - 1.4 //
replace all_q22_norm=. if id_alex=="cc_French_0_799" // Mauritania - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q23_norm=. if id_alex=="cc_French_0_799" // Mauritania - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q24_norm=. if id_alex=="cc_French_0_799" // Mauritania - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q25_norm=. if id_alex=="cc_French_0_799" // Mauritania - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q26_norm=. if id_alex=="cc_French_0_799" // Mauritania - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q27_norm=. if id_alex=="cc_French_0_799" // Mauritania - reduzco el cambio positivo en la pregunta  - 1.7 //
replace all_q8_norm=. if id_alex=="cc_French_0_799" // Mauritania - reduzco el cambio positivo en la pregunta  - 1.7 //
replace cc_q40a_norm=. if id_alex=="cc_French_0_799" // Mauritania - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cc_q40b_norm=. if id_alex=="cc_French_0_799" // Mauritania - reduzco el cambio positivo en la pregunta  - 3.4 //
replace all_q29_norm=. if id_alex=="cc_French_0_111_2018_2019_2021_2022_2023" // Mauritania - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cc_French_0_111_2018_2019_2021_2022_2023" // Mauritania - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cc_French_0_799" // Mauritania - reduzco el cambio negativo en la pregunta  - 4.5 //
replace cj_q15_norm=. if id_alex=="cj_French_0_564" // Mauritania - reduzco el cambio negativo en la pregunta  - 5.3 //
replace all_q48_norm=. if id_alex=="cc_French_0_532_2021_2022_2023" // Mauritania - reduzco el cambio positivo en la pregunta  - 6.4 //
replace all_q49_norm=. if id_alex=="cc_French_0_532_2021_2022_2023" // Mauritania - reduzco el cambio positivo en la pregunta  - 6.4 //
replace cj_q12d_norm=. if id_alex=="cj_French_1_1261_2019_2021_2022_2023" // Mauritania - reduzco el cambio negativo en la pregunta  - 8.4 //
replace cj_q20o_norm=. if id_alex=="cj_English_0_542_2018_2019_2021_2022_2023" // Mauritania - reduzco el cambio negativo en la pregunta  - 8.4 //
replace cc_q16a_norm=. if id_alex=="cc_French_0_799" // Mauritania - reduzco el cambio positivo en la pregunta  - 6.5 //

*Mauritius
drop if id_alex=="cj_English_0_1294" // Mauritius (muy positivo)
drop if id_alex=="cj_English_0_490" // Mauritius (muy positivo)
drop if id_alex=="cc_English_1_901" // Mauritius (muy positivo)
replace cc_q39a_norm=. if id_alex=="cc_English_1_737_2022_2023" // Mauritius - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39b_norm=. if id_alex=="cc_English_1_737_2022_2023" // Mauritius - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39c_norm=. if id_alex=="cc_English_1_737_2022_2023" // Mauritius - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39d_norm=. if id_alex=="cc_English_1_737_2022_2023" // Mauritius - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39e_norm=. if id_alex=="cc_English_1_737_2022_2023" // Mauritius - reduzco el cambio negativo en la pregunta  - 3.2 //
replace lb_q16a_norm=. if id_alex=="lb_English_0_280" // Mauritius - reduzco el cambio positivo en la pregunta  - 4.8 //
replace lb_q16b_norm=. if id_alex=="lb_English_0_280" // Mauritius - reduzco el cambio positivo en la pregunta  - 4.8 //
replace lb_q16c_norm=. if id_alex=="lb_English_0_280" // Mauritius - reduzco el cambio positivo en la pregunta  - 4.8 //
replace lb_q16d_norm=. if id_alex=="lb_English_0_280" // Mauritius - reduzco el cambio positivo en la pregunta  - 4.8 //
replace lb_q16e_norm=. if id_alex=="lb_English_0_280" // Mauritius - reduzco el cambio positivo en la pregunta  - 4.8 //
replace lb_q16f_norm=. if id_alex=="lb_English_0_280" // Mauritius - reduzco el cambio positivo en la pregunta  - 4.8 //
replace lb_q23f_norm=. if id_alex=="lb_English_0_280" // Mauritius - reduzco el cambio positivo en la pregunta  - 4.8 //
replace lb_q23g_norm=. if id_alex=="lb_English_0_280" // Mauritius - reduzco el cambio positivo en la pregunta  - 4.8 //
replace cj_q15_norm=. if id_alex=="cj_English_0_505" // Mauritius - reduzco el cambio positivo en la pregunta  - 5.3 //
replace lb_q2d_norm=. if id_alex=="lb_English_0_280" // Mauritius - reduzco el cambio positivo en la pregunta  - 6.3 //
replace all_q62_norm=. if id_alex=="cc_English_0_720_2018_2019_2021_2022_2023" // Mauritius - reduzco el cambio positivo en la pregunta  - 6.3 //
replace all_q63_norm=. if id_alex=="cc_English_0_720_2018_2019_2021_2022_2023" // Mauritius - reduzco el cambio positivo en la pregunta  - 6.3 //

*Mexico
drop if id_alex=="cc_Spanish_0_487_2022_2023" // Mexico (muy negativo)
drop if id_alex=="cj_English_0_208" // Mexico (muy negativo)
drop if id_alex=="cj_Spanish_1_410" // Mexico (muy negativo)
drop if id_alex=="lb_Spanish_0_311" // Mexico (muy negativo)
drop if id_alex=="cj_Spanish_0_985" // Mexico (muy negativo)
drop if id_alex=="cc_Spanish_0_137" // Mexico (muy negativo)
drop if id_alex=="cj_Spanish_1_78_2023" // Mexico (muy negativo)
drop if id_alex=="cj_Spanish_0_341" // Mexico (muy negativo)
replace cj_q29a_norm=. if country=="Mexico" // Mexico (se elimino el anio pasado)
replace cj_q29b_norm=. if country=="Mexico" // Mexico (se elimino el anio pasado)
replace all_q21_norm=. if id_alex=="cc_Spanish_1_148_2023" // Mexico - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q21_norm=. if id_alex=="cc_Spanish_0_1136_2023" // Mexico - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q27_norm=. if id_alex=="cc_English_1_1001_2022_2023" // Mexico - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q54_norm=. if id_alex=="cc_Spanish_1_369" // Mexico - reduzco el cambio positivo en la pregunta  - 2.1 //
replace all_q54_norm=. if id_alex=="cc_English_1_891" // Mexico - reduzco el cambio positivo en la pregunta  - 2.1 //
replace cj_q22d_norm=. if id_alex=="cj_English_0_208" // Mexico - reduzco el cambio negativo en la pregunta  - 4.3 //
replace cj_q22e_norm=. if id_alex=="cj_English_0_208" // Mexico - reduzco el cambio negativo en la pregunta  - 4.3 //
replace cj_q25a_norm=. if id_alex=="cj_English_0_208" // Mexico - reduzco el cambio negativo en la pregunta  - 4.3 //
replace cj_q25b_norm=. if id_alex=="cj_English_0_208" // Mexico - reduzco el cambio negativo en la pregunta  - 4.3 //
replace cj_q25c_norm=. if id_alex=="cj_English_0_208" // Mexico - reduzco el cambio negativo en la pregunta  - 4.3 //
replace cj_q6a_norm=. if id_alex=="cj_English_0_208" // Mexico - reduzco el cambio negativo en la pregunta  - 4.3 //
replace cj_q6b_norm=. if id_alex=="cj_English_0_208" // Mexico - reduzco el cambio negativo en la pregunta  - 4.3 //
replace cj_q25c_norm=. if id_alex=="cj_English_0_208" // Mexico - reduzco el cambio negativo en la pregunta  - 4.3 //
replace cj_q6c_norm=. if id_alex=="cj_English_0_208" // Mexico - reduzco el cambio negativo en la pregunta  - 4.3 //
replace cj_q6d_norm=. if id_alex=="cj_English_0_208" // Mexico - reduzco el cambio negativo en la pregunta  - 4.3 //
replace cj_q22c_norm=. if id_alex=="cj_English_0_208" // Mexico - reduzco el cambio negativo en la pregunta  - 4.3 //
replace cj_q3a_norm=. if id_alex=="cj_English_0_208" // Mexico - reduzco el cambio negativo en la pregunta  - 4.3 //
replace all_q29_norm=. if id_alex=="cc_Spanish_0_423" // Mexico - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cc_Spanish_1_609" // Mexico - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cj_Spanish_1_232" // Mexico - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cc_Spanish_1_77" // Mexico - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cj_Spanish_1_338" // Mexico - reduzco el cambio negativo en la pregunta  - 4.5 //
replace cj_q31f_norm=. if id_alex=="cj_Spanish_0_803_2023" // Mexico - reduzco el cambio negativo en la pregunta  - 4.6 //
replace cj_q42c_norm=. if id_alex=="cj_English_0_484" // Mexico - reduzco el cambio negativo en la pregunta  - 4.6 //
replace lb_q16c_norm=. if id_alex=="lb_Spanish_0_194_2023" // Mexico - reduzco el cambio negativo en la pregunta  - 4.8 //
replace lb_q16d_norm=. if id_alex=="lb_Spanish_0_194_2023" // Mexico - reduzco el cambio negativo en la pregunta  - 4.8 //
replace cc_q10_norm=. if id_alex=="cc_Spanish_0_423" // Mexico - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q10_norm=. if id_alex=="cc_Spanish_1_609" // Mexico - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q14a_norm=. if id_alex=="cc_English_0_1040" // Mexico - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q16b_norm=. if id_alex=="cc_Spanish_0_1235" // Mexico - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q16c_norm=. if id_alex=="cc_Spanish_0_1235" // Mexico - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q16d_norm=. if id_alex=="cc_Spanish_0_1235" // Mexico - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q16e_norm=. if id_alex=="cc_Spanish_0_1235" // Mexico - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q16f_norm=. if id_alex=="cc_Spanish_0_1235" // Mexico - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q16g_norm=. if id_alex=="cc_Spanish_0_1235" // Mexico - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q16b_norm=. if id_alex=="cc_Spanish_1_570_2023" // Mexico - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q16c_norm=. if id_alex=="cc_Spanish_1_570_2023" // Mexico - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q16d_norm=. if id_alex=="cc_Spanish_1_570_2023" // Mexico - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q16e_norm=. if id_alex=="cc_Spanish_1_570_2023" // Mexico - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q16f_norm=. if id_alex=="cc_Spanish_1_570_2023" // Mexico - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q16g_norm=. if id_alex=="cc_Spanish_1_570_2023" // Mexico - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q10_norm=. if id_alex=="cc_Spanish_0_1235" // Mexico - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q10_norm=. if id_alex=="cc_Spanish_1_215" // Mexico - reduzco el cambio negativo en la pregunta  - 6.5 //
replace all_q92_norm=. if id_alex=="cc_Spanish_1_1123_2022_2023" // Mexico - reduzco el cambio positivo en la pregunta  - 7.1 //
replace all_q75_norm=. if id_alex=="cc_English_0_675" // Mexico - reduzco el cambio positivo en la pregunta  - 7.1 //
replace all_q70_norm=. if id_alex=="cc_Spanish_0_423" // Mexico - reduzco el cambio positivo en la pregunta  - 7.1 //
replace all_q70_norm=. if id_alex=="cc_Spanish_0_629_2022_2023" // Mexico - reduzco el cambio positivo en la pregunta  - 7.1 //
replace all_q28_norm=. if id_alex=="cc_English_0_675" // Mexico - reduzco el cambio positivo en la pregunta  - 7.3 //
replace cc_q28e_norm=. if id_alex=="cc_English_1_891" // Mexico - reduzco el cambio positivo en la pregunta  - 7.3 //
replace all_q88_norm=. if id_alex=="cc_English_0_1040" // Mexico - reduzco el cambio positivo en la pregunta  - 7.5 //
replace all_q85_norm=. if id_alex=="cc_English_0_1040" // Mexico - reduzco el cambio positivo en la pregunta  - 7.5 //
replace cc_q26a_norm=. if id_alex=="cc_English_1_891" // Mexico - reduzco el cambio positivo en la pregunta  - 7.5 //
replace all_q86_norm=. if id_alex=="lb_Spanish_1_113" // Mexico - reduzco el cambio negativo en la pregunta  - 7.6 //
replace all_q86_norm=. if id_alex=="cc_Spanish_1_215" // Mexico - reduzco el cambio negativo en la pregunta  - 7.6 //
replace all_q90_norm=. if id_alex=="cc_English_0_675" // Mexico - reduzco el cambio negativo en la pregunta  - 7.7 //
replace cc_q14a_norm=. if id_alex=="cc_Spanish_0_1235" // Mexico - reduzco el cambio negativo en la pregunta  - 7.7 //
replace cc_q14b_norm=. if id_alex=="cc_Spanish_0_1235" // Mexico - reduzco el cambio negativo en la pregunta  - 7.7 //
replace cj_q27a_norm=. if id_alex=="cj_Spanish_0_570_2022_2023" // Mexico - reduzco el cambio negativo en la pregunta  - 8.2 //
replace cj_q27b_norm=. if id_alex=="cj_Spanish_0_570_2022_2023" // Mexico - reduzco el cambio negativo en la pregunta  - 8.2 //
replace cj_q20a_norm=. if id_alex=="cj_Spanish_0_570_2022_2023" // Mexico - reduzco el cambio negativo en la pregunta  - 8.2 //
replace cj_q20b_norm=. if id_alex=="cj_Spanish_0_570_2022_2023" // Mexico - reduzco el cambio negativo en la pregunta  - 8.2 //
replace cj_q20e_norm=. if id_alex=="cj_Spanish_0_1305" // Mexico - reduzco el cambio negativo en la pregunta  - 8.2 //

*Moldova
drop if id_alex=="cj_English_1_898" // Moldova (muy positivo)
drop if id_alex=="cc_English_1_425" // Moldova (muy positivo)
drop if id_alex=="cj_English_0_556_2023" // Moldova (muy positivo)
drop if id_alex=="cc_Russian_0_601_2022_2023" // Moldova (muy positivo)
replace all_q13_norm=. if id_alex=="cj_Russian_0_362_2022_2023" // Moldova - reduzco el cambio positivo en la pregunta  - 1.4 //
replace all_q14_norm=. if id_alex=="cj_English_1_472" // Moldova - reduzco el cambio positivo en la pregunta  - 1.6 //
replace all_q15_norm=. if id_alex=="cj_English_1_472" // Moldova - reduzco el cambio positivo en la pregunta  - 1.6 //
replace all_q16_norm=. if id_alex=="cj_English_1_472" // Moldova - reduzco el cambio positivo en la pregunta  - 1.6 //
replace all_q17_norm=. if id_alex=="cj_English_1_472" // Moldova - reduzco el cambio positivo en la pregunta  - 1.6 //
replace cj_q10_norm=. if id_alex=="cj_English_1_472" // Moldova - reduzco el cambio positivo en la pregunta  - 1.6 //
replace all_q18_norm=. if id_alex=="cj_English_1_472" // Moldova - reduzco el cambio positivo en la pregunta  - 1.6 //
replace all_q94_norm=. if id_alex=="cj_English_1_472" // Moldova - reduzco el cambio positivo en la pregunta  - 1.6 //
replace all_q20_norm=. if id_alex=="cj_English_1_472" // Moldova - reduzco el cambio positivo en la pregunta  - 1.6 //
replace all_q21_norm=. if id_alex=="cj_English_1_472" // Moldova - reduzco el cambio positivo en la pregunta  - 1.6 //
replace all_q96_norm=. if id_alex=="lb_Russian_1_228_2018_2019_2021_2022_2023" // Moldova - reduzco el cambio negativo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="lb_Russian_0_711_2019_2021_2022_2023" // Moldova - reduzco el cambio negativo en la pregunta  - 2.4 //
replace cj_q11a_norm=. if id_alex=="cj_English_0_471" // Moldova - reduzco el cambio positivo en la pregunta  - 4.2 //
replace cj_q31e_norm=. if id_alex=="cj_English_0_471" // Moldova - reduzco el cambio positivo en la pregunta  - 4.2 //
replace cj_q42c_norm=. if id_alex=="cj_English_0_471" // Moldova - reduzco el cambio positivo en la pregunta  - 4.2 //
replace cj_q42d_norm=. if id_alex=="cj_English_0_471" // Moldova - reduzco el cambio positivo en la pregunta  - 4.2 //
replace cj_q10_norm=. if id_alex=="cj_English_0_471" // Moldova - reduzco el cambio positivo en la pregunta  - 4.2 //
replace all_q14_norm=. if id_alex=="cj_English_0_449" // Moldova - reduzco el cambio positivo en la pregunta  - 4.7 //
replace cc_q26b_norm=. if id_alex=="cc_English_0_1327_2022_2023" // Moldova - reduzco el cambio negativo en la pregunta  - 7.6 //
replace cc_q26b_norm=. if id_alex=="cc_Russian_1_1108" // Moldova - reduzco el cambio negativo en la pregunta  - 7.6 //
replace all_q86_norm=. if id_alex=="cc_English_0_1855" // Moldova - reduzco el cambio negativo en la pregunta  - 7.6 //
replace all_q87_norm=. if id_alex=="cc_English_0_866" // Moldova - reduzco el cambio negativo en la pregunta  - 7.6 //
replace cj_q20o_norm=. if id_alex=="cj_English_0_565_2022_2023" // Moldova - reduzco el cambio positivo en la pregunta  - 8.4 //

*Mongolia
replace cj_q42c_norm=. if id_alex=="cj_English_0_989_2023" // Mongolia - reduzco el cambio negativo en la pregunta  - 4.2 //
replace cj_q10_norm=. if id_alex=="cj_English_0_989_2023" // Mongolia - reduzco el cambio negativo en la pregunta  - 4.2 //
replace cj_q10_norm=. if id_alex=="cj_English_1_626_2019_2021_2022_2023" // Mongolia - reduzco el cambio negativo en la pregunta  - 4.2 //
replace cj_q31g_norm=. if id_alex=="cj_English_0_989_2023" // Mongolia - reduzco el cambio negativo en la pregunta  - 4.6 //
replace cj_q15_norm=. if id_alex=="cj_English_1_410_2022_2023" // Mongolia - reduzco el cambio negativo en la pregunta  - 5.3 //
replace cj_q15_norm=. if id_alex=="cj_English_1_421_2023" // Mongolia - reduzco el cambio negativo en la pregunta  - 5.3 //
replace cc_q26b_norm=. if id_alex=="cc_English_0_64" // Mongolia - reduzco el cambio negativo en la pregunta  - 7.6 //
replace cc_q26b_norm=. if id_alex=="cc_English_0_269" // Mongolia - reduzco el cambio negativo en la pregunta  - 7.6 //
replace all_q86_norm=. if id_alex=="cc_English_0_952" // Mongolia - reduzco el cambio negativo en la pregunta  - 7.6 //
replace all_q86_norm=. if id_alex=="cc_English_0_64" // Mongolia - reduzco el cambio negativo en la pregunta  - 7.6 //

*Montenegro
drop if id_alex=="cc_English_1_302" // Montenegro (muy positivo)
drop if id_alex=="lb_English_0_245" // Montenegro (muy positivo)
replace all_q59_norm=. if id_alex=="cc_English_0_1064_2023" // Montenegro - reduzco el cambio negativo en la pregunta  - 2.2 //
replace all_q60_norm=. if id_alex=="cc_English_0_1064_2023" // Montenegro - reduzco el cambio negativo en la pregunta  - 2.2 //
replace all_q40_norm=. if id_alex=="cc_English_1_196" // Montenegro - reduzco el cambio positivo en la pregunta  - 3.2 //
replace all_q41_norm=. if id_alex=="cc_English_1_196" // Montenegro - reduzco el cambio positivo en la pregunta  - 3.2 //
replace all_q42_norm=. if id_alex=="cc_English_1_196" // Montenegro - reduzco el cambio positivo en la pregunta  - 3.2 //
replace all_q43_norm=. if id_alex=="cc_English_1_196" // Montenegro - reduzco el cambio positivo en la pregunta  - 3.2 //
replace all_q44_norm=. if id_alex=="cc_English_1_196" // Montenegro - reduzco el cambio positivo en la pregunta  - 3.2 //
replace all_q45_norm=. if id_alex=="cc_English_1_196" // Montenegro - reduzco el cambio positivo en la pregunta  - 3.2 //
replace all_q46_norm=. if id_alex=="cc_English_1_196" // Montenegro - reduzco el cambio positivo en la pregunta  - 3.2 //
replace all_q47_norm=. if id_alex=="cc_English_1_196" // Montenegro - reduzco el cambio positivo en la pregunta  - 3.2 //
replace all_q29_norm=. if id_alex=="cc_English_0_413_2023" // Montenegro - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cc_English_0_413_2023" // Montenegro - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cc_English_0_288_2023" // Montenegro - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cc_English_0_288_2023" // Montenegro - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q48_norm=. if id_alex=="lb_English_0_41_2023" // Montenegro - reduzco el cambio positivo en la pregunta  - 6.4 //
replace lb_q19a_norm=. if id_alex=="lb_English_0_536_2023" // Montenegro - reduzco el cambio positivo en la pregunta  - 6.4 //
replace all_q76_norm=. if id_alex=="cc_English_0_1064_2023" // Montenegro - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q77_norm=. if id_alex=="cc_English_0_1064_2023" // Montenegro - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q78_norm=. if id_alex=="cc_English_0_1064_2023" // Montenegro - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q79_norm=. if id_alex=="cc_English_0_1064_2023" // Montenegro - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q80_norm=. if id_alex=="cc_English_0_1064_2023" // Montenegro - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q81_norm=. if id_alex=="cc_English_0_1064_2023" // Montenegro - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q82_norm=. if id_alex=="cc_English_0_1064_2023" // Montenegro - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q80_norm=. if id_alex=="cc_English_0_1237_2023" // Montenegro - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q84_norm=. if id_alex=="cc_English_0_881" // Montenegro - reduzco el cambio negativo en la pregunta  - 7.6 //
replace all_q85_norm=. if id_alex=="cc_English_0_881" // Montenegro - reduzco el cambio negativo en la pregunta  - 7.6 //
replace cj_q7b_norm=. if id_alex=="cj_English_1_743" // Montenegro - reduzco el cambio negativo en la pregunta  - 8.2 //
replace cj_q21h_norm=. if id_alex=="cj_English_1_274" // Montenegro - reduzco el cambio positivo en la pregunta  - 8.3 //
replace cj_q21a_norm=.1111111 if id_alex=="cj_English_1_254" // Montenegro - reduzco el cambio positivo en la pregunta  - 8.3 //
replace cj_q12d_norm=. if id_alex=="cj_English_1_254" // Montenegro - reduzco el cambio positivo en la pregunta  - 8.4 //
replace cj_q20o_norm=. if id_alex=="cj_English_1_274" // Montenegro - reduzco el cambio negativo en la pregunta  - 8.4 //
replace cj_q20o_norm=. if id_alex=="cj_English_1_274" // Montenegro - reduzco el cambio negativo en la pregunta  - 8.5 //
replace cj_q40c_norm=. if id_alex=="cj_English_1_254" // Montenegro - reduzco el cambio positivo en la pregunta  - 8.6 //
replace cj_q20m_norm=. if id_alex=="cj_English_1_254" // Montenegro - reduzco el cambio positivo en la pregunta  - 8.6 //
replace cj_q20m_norm=0.5555556 if id_alex=="cj_English_1_254" // Montenegro - reduzco el cambio positivo en la pregunta  - 8.6 //
replace cj_q40c_norm=. if id_alex=="cj_English_1_743" // Montenegro - reduzco el cambio positivo en la pregunta  - 8.6 //

*Morocco
drop if id_alex=="cc_French_1_591" // Morocco (muy positivo)
drop if id_alex=="cc_French_1_410" // Morocco (muy positivo)

*Mozambique
replace all_q1_norm=. if id_alex=="cc_Arabic_1_152" // Mozambique - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q2_norm=. if id_alex=="cj_Arabic_0_172_2022_2023" // Mozambique - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q2_norm=. if id_alex=="cc_English_0_974_2022_2023" // Mozambique - reduzco el cambio negativo en la pregunta  - 1.2 //
replace cj_q31f_norm=. if id_alex=="cj_French_1_399" // Mozambique - reduzco el cambio positivo en la pregunta  - 4.6 //
replace cj_q42c_norm=. if id_alex=="cj_French_1_399" // Mozambique - reduzco el cambio positivo en la pregunta  - 4.6 //
drop if id_alex=="lb_Portuguese_0_459_2019_2021_2022_2023" // Mozambique (muy positivo)
replace all_q1_norm=. if country=="Mozambique" // Mozambique (se elimino el anio pasado)
replace cj_q6d_norm=. if country=="Mozambique" // Mozambique (se elimino el anio pasado)
replace cj_q3b_norm=. if country=="Mozambique" // Mozambique (se elimino el anio pasado)
replace cj_q3c_norm=. if country=="Mozambique" // Mozambique (se elimino el anio pasado)
replace all_q41_norm=. if id_alex=="lb_Portuguese_1_56" // Mozambique - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q42_norm=. if id_alex=="lb_Portuguese_1_56" // Mozambique - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q43_norm=. if id_alex=="lb_Portuguese_1_56" // Mozambique - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q47_norm=. if id_alex=="lb_Portuguese_1_56" // Mozambique - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q86_norm=. if id_alex=="lb_Portuguese_0_74_2018_2019_2021_2022_2023" // Mozambique - reduzco el cambio positivo en la pregunta  - 7.6 //
replace all_q86_norm=. if id_alex=="lb_English_1_272_2019_2021_2022_2023" // Mozambique - reduzco el cambio positivo en la pregunta  - 7.6 //
replace cj_q20m_norm=. if id_alex=="cj_Portuguese_1_518" // Mozambique - reduzco el cambio positivo en la pregunta  - 8.6 //

*Myanmar
drop if id_alex=="cc_English_0_852" // Myanmar (muy positivo)
drop if id_alex=="cj_English_0_430" // Myanmar (muy positivo)
drop if id_alex=="lb_English_1_92" // Myanmar (muy positivo)
replace cj_q11a_norm=. if country=="Myanmar" // Myanmar (se elimino el anio pasado)
replace cj_q11b_norm=. if country=="Myanmar" // Myanmar (se elimino el anio pasado)
replace cj_q6d_norm=. if country=="Myanmar" // Myanmar (se elimino el anio pasado)
replace cj_q11a_norm=. if country=="Myanmar" // Myanmar (se elimino el anio pasado)
replace cj_q36c_norm=. if id_alex=="cj_English_0_1154_2022_2023" // Myanmar - reduzco el cambio negativo en la pregunta  - 1.4 //
replace cj_q36c_norm=. if id_alex=="cj_English_1_19_2022_2023" // Myanmar - reduzco el cambio negativo en la pregunta  - 1.4 //
replace cj_q38_norm=. if id_alex=="cj_English_0_1154_2022_2023" // Myanmar - reduzco el cambio negativo en la pregunta  - 1.4 //
replace all_q18_norm=. if id_alex=="cc_English_1_733_2016_2017_2018_2019_2021_2022_2023" // Myanmar - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q13_norm=. if id_alex=="cj_English_1_19_2022_2023" // Myanmar - reduzco el cambio negativo en la pregunta  - 1.6 //
replace cj_q31e_norm=. if id_alex=="cj_English_1_19_2022_2023" // Myanmar - reduzco el cambio negativo en la pregunta  - 4.2 //
replace cj_q31f_norm=. if id_alex=="cj_English_1_19_2022_2023" // Myanmar - reduzco el cambio negativo en la pregunta  - 4.2 //
replace cj_q31g_norm=. if id_alex=="cj_English_1_19_2022_2023" // Myanmar - reduzco el cambio negativo en la pregunta  - 4.2 //
replace cj_q31f_norm=. if id_alex=="cj_English_0_190_2022_2023" // Myanmar - reduzco el cambio negativo en la pregunta  - 4.2 //
replace cj_q31g_norm=. if id_alex=="cj_English_0_190_2022_2023" // Myanmar - reduzco el cambio negativo en la pregunta  - 4.2 //
replace all_q49_norm=. if id_alex=="lb_English_0_288" // Myanmar - reduzco el cambio positivo en la pregunta  - 6.3 //
replace all_q50_norm=. if id_alex=="lb_English_0_288" // Myanmar - reduzco el cambio positivo en la pregunta  - 6.3 //
replace lb_q19a_norm=. if id_alex=="lb_English_0_288" // Myanmar - reduzco el cambio positivo en la pregunta  - 6.3 //
replace cj_q40b_norm=. if id_alex=="cj_English_1_19_2022_2023" // Myanmar - reduzco el cambio positivo en la pregunta  - 8.6 //
replace cj_q40c_norm=. if id_alex=="cj_English_1_19_2022_2023" // Myanmar - reduzco el cambio positivo en la pregunta  - 8.6 //
replace cj_q20m_norm=. if id_alex=="cj_English_1_19_2022_2023" // Myanmar - reduzco el cambio positivo en la pregunta  - 8.6 //
replace cj_q40b_norm=. if id_alex=="cj_English_0_190_2022_2023" // Myanmar - reduzco el cambio positivo en la pregunta  - 8.6 //
replace cj_q40c_norm=. if id_alex=="cj_English_0_190_2022_2023" // Myanmar - reduzco el cambio positivo en la pregunta  - 8.6 //
replace cj_q20m_norm=. if id_alex=="cj_English_0_190_2022_2023" // Myanmar - reduzco el cambio positivo en la pregunta  - 8.6 //
replace cj_q40b_norm=. if id_alex=="cj_English_0_1154_2022_2023" // Myanmar - reduzco el cambio positivo en la pregunta  - 8.6 //
replace cj_q40c_norm=. if id_alex=="cj_English_0_1154_2022_2023" // Myanmar - reduzco el cambio positivo en la pregunta  - 8.6 //
replace cj_q20m_norm=. if id_alex=="cj_English_0_1154_2022_2023" // Myanmar - reduzco el cambio positivo en la pregunta  - 8.6 //
replace cj_q40b_norm=. if id_alex=="cj_English_1_267_2022_2023" // Myanmar - reduzco el cambio positivo en la pregunta  - 8.6 //
replace cj_q40c_norm=. if id_alex=="cj_English_1_267_2022_2023" // Myanmar - reduzco el cambio positivo en la pregunta  - 8.6 //
replace cj_q20m_norm=. if id_alex=="cj_English_1_267_2022_2023" // Myanmar - reduzco el cambio positivo en la pregunta  - 8.6 //

*Namibia
replace all_q76_norm=. if country=="Namibia" // Namibia (se elimino el anio pasado)
replace all_q13_norm=. if id_alex=="cj_English_0_157_2023" // Namibia - muestro cambio negativo - 1.6 (Q) //
replace all_q14_norm=. if id_alex=="cj_English_0_157_2023" // Namibia - muestro cambio negativo - 1.6 (Q) //
replace all_q15_norm=. if id_alex=="cj_English_0_157_2023" // Namibia - muestro cambio negativo - 1.6 (Q) //
replace all_q16_norm=. if id_alex=="cj_English_0_157_2023" // Namibia - muestro cambio negativo - 1.6 (Q) //
replace all_q17_norm=. if id_alex=="cj_English_0_157_2023" // Namibia - muestro cambio negativo - 1.6 (Q) //
replace cj_q10_norm=. if id_alex=="cj_English_0_157_2023" // Namibia - muestro cambio negativo - 1.6 (Q) //
replace all_q94_norm=. if id_alex=="cj_English_0_157_2023" // Namibia - muestro cambio negativo - 1.6 (Q) //
replace all_q19_norm=. if id_alex=="cj_English_0_157_2023" // Namibia - muestro cambio negativo - 1.6 (Q) //
replace all_q20_norm=. if id_alex=="cj_English_0_157_2023" // Namibia - muestro cambio negativo - 1.6 (Q) //
replace all_q21_norm=. if id_alex=="cj_English_0_157_2023" // Namibia - muestro cambio negativo - 1.6 (Q) //
replace all_q13_norm=. if id_alex=="cj_English_0_1191" // Namibia - muestro cambio negativo - 1.6 (Q) //
replace all_q14_norm=. if id_alex=="cj_English_0_1191" // Namibia - muestro cambio negativo - 1.6 (Q) //
replace all_q15_norm=. if id_alex=="cj_English_0_1191" // Namibia - muestro cambio negativo - 1.6 (Q) //
replace all_q16_norm=. if id_alex=="cj_English_0_1191" // Namibia - muestro cambio negativo - 1.6 (Q) //
replace all_q17_norm=. if id_alex=="cj_English_0_1191" // Namibia - muestro cambio negativo - 1.6 (Q) //
replace cj_q10_norm=. if id_alex=="cj_English_0_1191" // Namibia - muestro cambio negativo - 1.6 (Q) //
replace all_q94_norm=. if id_alex=="cj_English_0_1191" // Namibia - muestro cambio negativo - 1.6 (Q) //
replace all_q19_norm=. if id_alex=="cj_English_0_1191" // Namibia - muestro cambio negativo - 1.6 (Q) //
replace all_q20_norm=. if id_alex=="cj_English_0_1191" // Namibia - muestro cambio negativo - 1.6 (Q) //
replace all_q21_norm=. if id_alex=="cj_English_0_1191" // Namibia - muestro cambio negativo - 1.6 (Q) //
replace all_q13_norm=. if id_alex=="cj_English_1_83_2019_2021_2022_2023" // Namibia - muestro cambio negativo - 1.6 (Q) //
replace all_q14_norm=. if id_alex=="cj_English_1_83_2019_2021_2022_2023" // Namibia - muestro cambio negativo - 1.6 (Q) //
replace all_q15_norm=. if id_alex=="cj_English_1_83_2019_2021_2022_2023" // Namibia - muestro cambio negativo - 1.6 (Q) //
replace all_q16_norm=. if id_alex=="cj_English_1_83_2019_2021_2022_2023" // Namibia - muestro cambio negativo - 1.6 (Q) //
replace all_q17_norm=. if id_alex=="cj_English_1_83_2019_2021_2022_2023" // Namibia - muestro cambio negativo - 1.6 (Q) //
replace cj_q10_norm=. if id_alex=="cj_English_1_83_2019_2021_2022_2023" // Namibia - muestro cambio negativo - 1.6 (Q) //
replace all_q94_norm=. if id_alex=="cj_English_1_83_2019_2021_2022_2023" // Namibia - muestro cambio negativo - 1.6 (Q) //
replace all_q19_norm=. if id_alex=="cj_English_1_83_2019_2021_2022_2023" // Namibia - muestro cambio negativo - 1.6 (Q) //
replace all_q20_norm=. if id_alex=="cj_English_1_83_2019_2021_2022_2023" // Namibia - muestro cambio negativo - 1.6 (Q) //
replace all_q21_norm=. if id_alex=="cj_English_0_960" // Namibia - muestro cambio negativo - 1.6 (Q) //
replace all_q30_norm=. if id_alex=="cc_English_0_1923_2018_2019_2021_2022_2023" // Myanmar - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cc_English_0_1775_2018_2019_2021_2022_2023" // Myanmar - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cc_English_0_1040_2022_2023" // Myanmar - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cc_English_0_1040_2022_2023" // Myanmar - reduzco el cambio positivo en la pregunta  - 4.5 //
replace lb_q16d_norm=. if id_alex=="lb_English_1_279" // Namibia - reduzco el cambio negativo en la pregunta  - 4.8 //
replace cj_q15_norm=. if id_alex=="cj_English_0_1191" // Namibia - reduzco el cambio negativo en la pregunta  - 5.3 //
replace cj_q15_norm=. if id_alex=="cj_English_1_305" // Namibia - reduzco el cambio negativo en la pregunta  - 5.3 //
replace all_q77_norm=. if id_alex=="cc_English_0_119" // Namibia - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q80_norm=. if id_alex=="cc_English_0_429" // Namibia - reduzco el cambio negativo en la pregunta  - 7.2 //

*Nepal
drop if id_alex=="cc_English_0_142" // Nepal (muy positivo)
drop if id_alex=="cj_English_1_622" // Nepal (muy positivo)
drop if id_alex=="lb_English_0_155" // Nepal (muy positivo)
replace cj_q32d_norm=. if country=="Nepal" // Nepal (se elimino el anio pasado)
replace cj_q11b_norm=. if country=="Nepal" // Nepal (se elimino el anio pasado)
replace all_q14_norm=. if id_alex=="cc_English_0_110_2022_2023" // Nepal - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q14_norm=. if id_alex=="cc_English_1_91" // Nepal - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q16_norm=. if id_alex=="cc_English_0_811" // Nepal - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q16_norm=. if id_alex=="cc_English_0_110_2022_2023" // Nepal - reduzco el cambio negativo en la pregunta  - 1.6 //
replace cj_q10_norm=. if id_alex=="cj_English_0_71" // Nepal - reduzco el cambio positivo en la pregunta  - 1.6 //
replace all_q27_norm=. if id_alex=="cc_English_0_110_2022_2023" // Nepal - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q27_norm=. if id_alex=="cc_English_0_1317_2022_2023" // Nepal - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q22_norm=. if id_alex=="cc_English_0_811" // Nepal - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q23_norm=. if id_alex=="cc_English_0_811" // Nepal - reduzco el cambio negativo en la pregunta  - 1.7 //
replace cj_q42d_norm=. if id_alex=="cj_English_1_864" // Nepal - reduzco el cambio negativo en la pregunta  - 4.2 //
replace cj_q10_norm=. if id_alex=="cj_English_1_864" // Nepal - reduzco el cambio negativo en la pregunta  - 4.2 //
replace all_q21_norm=. if id_alex=="cc_English_0_110_2022_2023" // Nepal - reduzco el cambio negativo en la pregunta  - 4.4 //
replace all_q21_norm=. if id_alex=="cc_English_0_1317_2022_2023" // Nepal - reduzco el cambio negativo en la pregunta  - 4.4 //
replace all_q19_norm=. if id_alex=="cc_English_0_110_2022_2023" // Nepal - reduzco el cambio negativo en la pregunta  - 4.7 //
replace all_q31_norm=. if id_alex=="cc_English_0_110_2022_2023" // Nepal - reduzco el cambio negativo en la pregunta  - 4.7 //
replace all_q32_norm=. if id_alex=="cc_English_0_110_2022_2023" // Nepal - reduzco el cambio negativo en la pregunta  - 4.7 //
replace all_q14_norm=. if id_alex=="cc_English_0_110_2022_2023" // Nepal - reduzco el cambio negativo en la pregunta  - 4.7 //
replace cj_q31f_norm=. if id_alex=="cj_English_1_864" // Nepal - reduzco el cambio negativo en la pregunta  - 4.7 //
replace cj_q31g_norm=. if id_alex=="cj_English_1_864" // Nepal - reduzco el cambio negativo en la pregunta  - 4.7 //
replace cj_q42c_norm=. if id_alex=="cj_English_1_864" // Nepal - reduzco el cambio negativo en la pregunta  - 4.7 //
replace cj_q42d_norm=. if id_alex=="cj_English_1_864" // Nepal - reduzco el cambio negativo en la pregunta  - 4.7 //
replace cj_q31f_norm=. if id_alex=="cj_English_1_417" // Nepal - reduzco el cambio negativo en la pregunta  - 4.7 //
replace cj_q31g_norm=. if id_alex=="cj_English_1_417" // Nepal - reduzco el cambio negativo en la pregunta  - 4.7 //
replace cj_q42d_norm=. if id_alex=="cj_English_1_1106_2022_2023" // Nepal - reduzco el cambio negativo en la pregunta  - 4.7 //
replace cj_q31f_norm=. if id_alex=="cj_English_0_71" // Nepal - reduzco el cambio negativo en la pregunta  - 4.7 //
replace cj_q31g_norm=. if id_alex=="cj_English_0_71" // Nepal - reduzco el cambio negativo en la pregunta  - 4.7 //
replace cj_q15_norm=. if id_alex=="cj_English_1_772_2023" // Nepal - reduzco el cambio negativo en la pregunta  - 5.3 //
replace cj_q15_norm=. if id_alex=="cj_English_0_820_2023" // Nepal - reduzco el cambio negativo en la pregunta  - 5.3 //
replace lb_q2d_norm=. if id_alex=="lb_English_1_320" // Nepal - reduzco el cambio negativo en la pregunta  - 6.3 //
replace lb_q3d_norm=. if id_alex=="lb_English_1_320" // Nepal - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q48_norm=. if id_alex=="lb_English_1_320" // Nepal - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q50_norm=. if id_alex=="lb_English_1_320" // Nepal - reduzco el cambio negativo en la pregunta  - 6.4 //
replace cc_q13_norm=. if id_alex=="cc_English_0_918_2023" // Nepal - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="cc_English_0_918_2023" // Nepal - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q13_norm=. if id_alex=="cc_English_1_698" // Nepal - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="cc_English_1_698" // Nepal - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cj_q12a_norm=. if id_alex=="cj_English_0_649_2022_2023" // Nepal - reduzco el cambio positivo en la pregunta  - 8.4 //
replace cj_q12b_norm=. if id_alex=="cj_English_0_649_2022_2023" // Nepal - reduzco el cambio positivo en la pregunta  - 8.4 //
replace cj_q12c_norm=. if id_alex=="cj_English_0_649_2022_2023" // Nepal - reduzco el cambio positivo en la pregunta  - 8.4 //
replace cj_q12d_norm=. if id_alex=="cj_English_0_649_2022_2023" // Nepal - reduzco el cambio positivo en la pregunta  - 8.4 //
replace cj_q12e_norm=. if id_alex=="cj_English_0_649_2022_2023" // Nepal - reduzco el cambio positivo en la pregunta  - 8.4 //
replace cj_q12f_norm=. if id_alex=="cj_English_0_649_2022_2023" // Nepal - reduzco el cambio positivo en la pregunta  - 8.4 //
replace cj_q20o_norm=. if id_alex=="cj_English_0_696" // Nepal - reduzco el cambio positivo en la pregunta  - 8.4 //
replace cj_q20o_norm=. if id_alex=="cj_English_1_864" // Nepal - reduzco el cambio positivo en la pregunta  - 8.4 //
replace cj_q22c_norm=. if id_alex=="cj_English_0_649_2022_2023" // Nepal - reduzco el cambio positivo en la pregunta  - 8.6 //

*Netherlands
drop if id_alex=="cc_English_0_1098" // Netherlands (muy negativo)
drop if id_alex=="lb_English_0_602" // Netherlands (muy negativo)
drop if id_alex=="cj_English_1_1091_2021_2022_2023" // Netherlands (muy negativo)
replace all_q1_norm=. if id_alex=="cc_English_0_1546" // Netherlands - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q1_norm=. if id_alex=="cc_English_1_615" // Netherlands - reduzco el cambio negativo en la pregunta  - 1.2 //
replace all_q21_norm=. if id_alex=="cj_English_0_372_2023" // Netherlands - reduzco el cambio negativo en la pregunta  - 1.6 //
replace all_q8_norm=. if id_alex=="cj_English_0_864" // Netherlands - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q22_norm=. if id_alex=="cj_English_0_864" // Netherlands - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q24_norm=. if id_alex=="cj_English_0_864" // Netherlands - reduzco el cambio negativo en la pregunta  - 1.7 //
replace all_q19_norm=. if id_alex=="cj_English_1_1015" // Netherlands - reduzco el cambio negativo en la pregunta  - 3.3 //
replace all_q19_norm=. if id_alex=="cc_English_0_368" // Netherlands - reduzco el cambio negativo en la pregunta  - 3.3 //
replace cc_q9a_norm=. if id_alex=="cc_English_1_44_2023" // Netherlands - reduzco el cambio negativo en la pregunta  - 3.3 //
replace cc_q11b_norm=. if id_alex=="cc_English_1_44_2023" // Netherlands - reduzco el cambio negativo en la pregunta  - 3.3 //
replace cc_q11b_norm=. if id_alex=="cc_English_0_1509" // Netherlands - reduzco el cambio negativo en la pregunta  - 3.3 //
replace cj_q42c_norm=. if id_alex=="cj_English_0_823" // Netherlands - reduzco el cambio negativo en la pregunta  - 4.6 //
replace cj_q42d_norm=. if id_alex=="cj_English_0_823" // Netherlands - reduzco el cambio negativo en la pregunta  - 4.6 //
replace all_q19_norm=. if id_alex=="cj_English_1_1015" // Netherlands - reduzco el cambio negativo en la pregunta  - 4.7 //
replace all_q82_norm=. if id_alex=="cc_English_0_407" // Netherlands - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q78_norm=. if id_alex=="lb_English_1_320_2017_2018_2019_2021_2022_2023" // Netherlands - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q79_norm=. if id_alex=="lb_English_1_320_2017_2018_2019_2021_2022_2023" // Netherlands - reduzco el cambio negativo en la pregunta  - 7.2 //
replace cc_q26b_norm=. if id_alex=="cc_English_0_1870" // Netherlands - reduzco el cambio positivo en la pregunta  - 7.6 //
replace all_q89_norm=. if id_alex=="cc_English_0_368" // Netherlands - reduzco el cambio negativo en la pregunta  - 7.7 //
replace all_q89_norm=. if id_alex=="cc_English_0_1018" // Netherlands - reduzco el cambio negativo en la pregunta  - 7.7 //

*New Zealand
drop if id_alex=="cc_English_1_745" // New Zealand (muy positivo)
replace all_q1_norm=. if id_alex=="lb_English_0_144" //New Zealand - reduzco el cambio positivo en la pregunta  - 1.2 //
replace all_q1_norm=. if id_alex=="lb_English_1_222" //New Zealand - reduzco el cambio positivo en la pregunta  - 1.2 //
replace all_q1_norm=. if id_alex=="lb_English_1_253" //New Zealand - reduzco el cambio positivo en la pregunta  - 1.2 //
replace all_q1_norm=. if id_alex=="cj_English_1_621_2022_2023" //New Zealand - reduzco el cambio positivo en la pregunta  - 1.2 //
replace all_q1_norm=. if id_alex=="cj_English_0_328_2022_2023" //New Zealand - reduzco el cambio positivo en la pregunta  - 1.2 //
replace cj_q38_norm=. if id_alex=="cj_English_1_938_2023" //New Zealand - reduzco el cambio negativo en la pregunta  - 1.4 //
replace cj_q38_norm=. if id_alex=="cj_English_0_772_2023" //New Zealand - reduzco el cambio negativo en la pregunta  - 1.4 //
replace cj_q24b_norm=. if id_alex=="cj_English_0_321_2022_2023" //New Zealand - reduzco el cambio positivo en la pregunta  - 2.2 //
replace cj_q24c_norm=. if id_alex=="cj_English_0_321_2022_2023" //New Zealand - reduzco el cambio positivo en la pregunta  - 2.2 //
replace all_q96_norm=. if id_alex=="cc_English_1_156" //New Zealand - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_1_1069" //New Zealand - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_1_261" //New Zealand - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="cc_English_0_135" //New Zealand - reduzco el cambio positivo en la pregunta  - 2.4 //
replace cj_q42c_norm=. if id_alex=="cj_English_0_580_2022_2023" //New Zealand - reduzco el cambio positivo en la pregunta  - 4.2 //
replace cj_q42d_norm=. if id_alex=="cj_English_0_580_2022_2023" //New Zealand - reduzco el cambio positivo en la pregunta  - 4.2 //
replace cj_q11a_norm=. if id_alex=="cj_English_0_580_2022_2023" //New Zealand - reduzco el cambio positivo en la pregunta  - 4.2 //
replace all_q29_norm=. if id_alex=="cj_English_0_1078_2022_2023" //New Zealand - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cj_English_0_1078_2022_2023" //New Zealand - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cj_English_0_456_2022_2023" //New Zealand - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cj_English_0_456_2022_2023" //New Zealand - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cj_English_1_89" //New Zealand - reduzco el cambio positivo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cj_English_1_89" //New Zealand - reduzco el cambio positivo en la pregunta  - 4.5 //
replace cj_q31f_norm=. if id_alex=="cj_English_0_1078_2022_2023" //New Zealand - reduzco el cambio positivo en la pregunta  - 4.6 //
replace cj_q31g_norm=. if id_alex=="cj_English_0_1078_2022_2023" //New Zealand - reduzco el cambio positivo en la pregunta  - 4.6 //
replace cj_q31f_norm=. if id_alex=="cj_English_0_456_2022_2023" //New Zealand - reduzco el cambio positivo en la pregunta  - 4.6 //
replace cj_q31g_norm=. if id_alex=="cj_English_0_456_2022_2023" //New Zealand - reduzco el cambio positivo en la pregunta  - 4.6 //
replace cj_q31g_norm=. if id_alex=="cj_English_0_772_2023" //New Zealand - reduzco el cambio positivo en la pregunta  - 4.6 //
replace cj_q42c_norm=. if id_alex=="cj_English_0_772_2023" //New Zealand - reduzco el cambio positivo en la pregunta  - 4.6 //
replace cj_q42d_norm=. if id_alex=="cj_English_0_772_2023" //New Zealand - reduzco el cambio positivo en la pregunta  - 4.6 //
replace cj_q31g_norm=. if id_alex=="cj_English_0_289_2023" //New Zealand - reduzco el cambio positivo en la pregunta  - 4.6 //
replace cj_q42c_norm=. if id_alex=="cj_English_0_289_2023" //New Zealand - reduzco el cambio positivo en la pregunta  - 4.6 //
replace cj_q42d_norm=. if id_alex=="cj_English_0_289_2023" //New Zealand - reduzco el cambio positivo en la pregunta  - 4.6 //
replace lb_q2d_norm=1 if id_alex=="lb_English_0_286" //New Zealand - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q62_norm=. if id_alex=="lb_English_1_183_2019_2021_2022_2023" //New Zealand - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q63_norm=. if id_alex=="lb_English_1_183_2019_2021_2022_2023" //New Zealand - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q62_norm=. if id_alex=="lb_English_0_144" //New Zealand - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q63_norm=. if id_alex=="lb_English_0_144" //New Zealand - reduzco el cambio negativo en la pregunta  - 6.3 //
replace cc_q22b_norm=. if id_alex=="cc_English_0_543_2023" //New Zealand - reduzco el cambio positivo en la pregunta  - 7.1 //
replace all_q74_norm=. if id_alex=="cc_English_1_261" //New Zealand - reduzco el cambio positivo en la pregunta  - 7.1 //
replace cc_q26a_norm=. if id_alex=="cc_English_1_1289_2022_2023" //New Zealand - reduzco el cambio negativo en la pregunta  - 7.6 //
replace cj_q20m_norm=. if id_alex=="cj_English_1_938_2023" //New Zealand - reduzco el cambio negativo en la pregunta  - 8.6 //

*Nicaragua
replace cc_q33_norm=. if id_alex=="cc_Spanish_1_1357_2022_2023" //Nicaragua - reduzco el cambio negativo en la pregunta  - 1.4 //
replace cc_q9c_norm=. if id_alex=="cc_Spanish_1_1357_2022_2023" //Nicaragua - reduzco el cambio negativo en la pregunta  - 3.4 //
replace cc_q9c_norm=. if id_alex=="cc_Spanish_0_334_2023" //Nicaragua - reduzco el cambio negativo en la pregunta  - 3.4 //
replace all_q29_norm=. if id_alex=="cj_Spanish_1_982_2021_2022_2023" //Nicaragua - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cj_Spanish_1_982_2021_2022_2023" //Nicaragua - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cj_Spanish_0_425" //Nicaragua - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cj_Spanish_0_425" //Nicaragua - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cc_Spanish_0_334_2023" //Nicaragua - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q30_norm=. if id_alex=="cc_Spanish_1_717_2023" //Nicaragua - reduzco el cambio negativo en la pregunta  - 4.5 //
replace cc_q16e_norm=. if id_alex=="cc_Spanish_0_334_2023" //Nicaragua - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q16g_norm=. if id_alex=="cc_English_0_1110_2023" //Nicaragua - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q14a_norm=. if id_alex=="cc_English_0_1110_2023" //Nicaragua - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q14b_norm=. if id_alex=="cc_English_0_1110_2023" //Nicaragua - reduzco el cambio negativo en la pregunta  - 6.5 //
replace cc_q12_norm=. if id_alex=="cc_Spanish_1_1357_2022_2023" //Nicaragua - reduzco el cambio positivo en la pregunta  - 7.1 //
replace cc_q12_norm=. if id_alex=="cc_Spanish_1_1452_2022_2023" //Nicaragua - reduzco el cambio positivo en la pregunta  - 7.1 //
replace all_q76_norm=. if id_alex=="cc_English_0_1110_2023" //Nicaragua - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q77_norm=. if id_alex=="cc_English_0_1110_2023" //Nicaragua - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q78_norm=. if id_alex=="cc_English_0_1110_2023" //Nicaragua - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q79_norm=. if id_alex=="cc_English_0_1110_2023" //Nicaragua - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q80_norm=. if id_alex=="cc_English_0_1110_2023" //Nicaragua - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q81_norm=. if id_alex=="cc_English_0_1110_2023" //Nicaragua - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q78_norm=. if id_alex=="cc_Spanish_0_334_2023" //Nicaragua - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q79_norm=. if id_alex=="cc_Spanish_0_334_2023" //Nicaragua - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q80_norm=. if id_alex=="cc_Spanish_0_334_2023" //Nicaragua - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q77_norm=. if id_alex=="cc_Spanish_1_895" //Nicaragua - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q78_norm=. if id_alex=="cc_Spanish_1_895" //Nicaragua - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q80_norm=. if id_alex=="cc_Spanish_1_895" //Nicaragua - reduzco el cambio negativo en la pregunta  - 7.2 //
replace all_q81_norm=. if id_alex=="cc_Spanish_1_895" //Nicaragua - reduzco el cambio negativo en la pregunta  - 7.2 //
replace cc_q14a_norm=. if id_alex=="cc_Spanish_0_334_2023" //Nicaragua - reduzco el cambio negativo en la pregunta  - 7.7 //
replace cc_q14b_norm=. if id_alex=="cc_English_0_1110_2023" //Nicaragua - reduzco el cambio negativo en la pregunta  - 7.7 //
replace cc_q14a_norm=. if id_alex=="cc_Spanish_0_1009" //Nicaragua - reduzco el cambio negativo en la pregunta  - 7.7 //
replace cc_q14b_norm=. if id_alex=="cc_Spanish_0_1009" //Nicaragua - reduzco el cambio negativo en la pregunta  - 7.7 //

*Niger
drop if id_alex=="cc_French_1_887" // Niger (muy positivo) (Q)
drop if id_alex=="cj_French_0_1345" // Niger (muy positivo) (Q)
drop if id_alex=="ph_French_0_692_2018_2019_2021_2022_2023" // Niger (muy positivo) (Q)
drop if id_alex=="cc_French_0_658" // Niger (muy positivo) (Q)
drop if id_alex=="cc_French_0_352_2023" // Niger (muy positivo) (Q)
replace lb_q2d_norm=. if country=="Niger" // Niger (se elimino el anio pasado)
replace lb_q19a_norm=. if country=="Niger" // Niger (se elimino el anio pasado)
replace cc_q11a_norm=. if country=="Niger" // Niger (se elimino el anio pasado)
replace cc_q16b_norm=. if country=="Niger" // Niger (se elimino el anio pasado)
replace cc_q16e_norm=. if country=="Niger" // Niger (se elimino el anio pasado)
replace all_q84_norm=. if country=="Niger" // Niger (se elimino el anio pasado)
replace all_q85_norm=. if country=="Niger" // Niger (se elimino el anio pasado)
replace all_q1_norm=. if id_alex=="lb_French_1_179" //Niger - reduzco el cambio positivo en la pregunta  - 1.2 //
replace all_q5_norm=. if id_alex=="cj_English_1_1245_2019_2021_2022_2023" //Niger - reduzco el cambio positivo en la pregunta  - 1.3 //
replace all_q7_norm=. if id_alex=="cc_French_0_1397_2019_2021_2022_2023" //Niger - reduzco el cambio positivo en la pregunta  - 1.3 //
replace cc_q33_norm=0 if id_alex=="cc_French_1_1276_2021_2022_2023" //Niger - reduzco el cambio positivo en la pregunta  - 1.4 //
replace cc_q33_norm=0 if id_alex=="cc_French_0_1589_2021_2022_2023" //Niger - reduzco el cambio positivo en la pregunta  - 1.4 //
replace all_q13_norm=. if id_alex=="cj_English_1_954_2021_2022_2023" //Niger - reduzco el cambio positivo en la pregunta  - 1.6 (Q) //
replace all_q13_norm=. if id_alex=="cj_English_0_718_2019_2021_2022_2023" //Niger - reduzco el cambio positivo en la pregunta  - 1.6  (Q)//
replace all_q14_norm=. if id_alex=="cj_English_1_954_2021_2022_2023" //Niger - reduzco el cambio positivo en la pregunta  - 1.6 (Q)//
replace all_q14_norm=. if id_alex=="cj_English_1_1245_2019_2021_2022_2023" //Niger - reduzco el cambio positivo en la pregunta  - 1.6 (Q)//
replace all_q15_norm=. if id_alex=="cc_French_0_1589_2021_2022_2023" //Niger - reduzco el cambio positivo en la pregunta  - 1.6 (Q)//
replace all_q15_norm=. if id_alex=="cc_French_0_1397_2019_2021_2022_2023" //Niger - reduzco el cambio positivo en la pregunta  - 1.6 (Q)//
replace all_q16_norm=. if id_alex=="cc_French_0_1397_2019_2021_2022_2023" //Niger - reduzco el cambio positivo en la pregunta  - 1.6 (Q)//
replace all_q16_norm=. if id_alex=="cc_French_0_1527_2019_2021_2022_2023" //Niger - reduzco el cambio positivo en la pregunta  - 1.6 (Q)//
replace all_q17_norm=. if id_alex=="cj_English_0_718_2019_2021_2022_2023" //Niger - reduzco el cambio positivo en la pregunta  - 1.6 (Q)//
replace all_q18_norm=. if id_alex=="cc_French_0_1589_2021_2022_2023" //Niger - reduzco el cambio positivo en la pregunta  - 1.6 (Q)//
replace all_q18_norm=. if id_alex=="cc_French_0_1527_2019_2021_2022_2023" //Niger - reduzco el cambio positivo en la pregunta  - 1.6 (Q)//
replace cj_q10_norm=. if id_alex=="cj_English_1_954_2021_2022_2023" //Niger - reduzco el cambio positivo en la pregunta  - 1.6 (Q)//
replace all_q20_norm=. if id_alex=="cc_French_1_904_2021_2022_2023" //Niger - reduzco el cambio positivo en la pregunta  - 1.6 (Q)//
replace all_q20_norm=. if id_alex=="cc_French_0_1397_2019_2021_2022_2023" //Niger - reduzco el cambio positivo en la pregunta  - 1.6 (Q)//
replace all_q21_norm=. if id_alex=="cj_French_1_921_2023" //Niger - reduzco el cambio positivo en la pregunta  - 1.6 //
replace cc_q9c_norm=. if id_alex=="cc_French_0_658" //Niger - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cc_q40a_norm=. if id_alex=="cc_French_0_658" //Niger - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cc_q40b_norm=. if id_alex=="cc_French_0_658" //Niger - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cj_q11a_norm=. if id_alex=="cj_English_1_954_2021_2022_2023" //Niger - reduzco el cambio positivo en la pregunta  - 4.2 (Q)/
replace cj_q11b_norm=. if id_alex=="cj_English_1_954_2021_2022_2023" //Niger - reduzco el cambio positivo en la pregunta  - 4.2 (Q)/
replace cj_q31e_norm=. if id_alex=="cj_English_1_1245_2019_2021_2022_2023" //Niger - reduzco el cambio positivo en la pregunta  - 4.2 (Q)/
replace cj_q42c_norm=. if id_alex=="cj_English_1_1245_2019_2021_2022_2023" //Niger - reduzco el cambio positivo en la pregunta  - 4.2 (Q)/
replace cj_q42d_norm=. if id_alex=="cj_French_0_1237_2019_2021_2022_2023" //Niger - reduzco el cambio positivo en la pregunta  - 4.2 (Q)/
replace cj_q10_norm=. if id_alex=="cj_French_1_591" //Niger - reduzco el cambio positivo en la pregunta  - 4.2 (Q)/
replace cj_q31f_norm=. if id_alex=="cj_French_1_921_2023" //Niger - reduzco el cambio positivo en la pregunta  - 4.6 (Q)/
replace cj_q31g_norm=. if id_alex=="cj_French_1_921_2023" //Niger - reduzco el cambio positivo en la pregunta  - 4.6 (Q)/
replace all_q19_norm=. if id_alex=="cc_French_0_1397_2019_2021_2022_2023" //Niger - reduzco el cambio positivo en la pregunta  - 4.7 (Q)/
replace all_q31_norm=. if id_alex=="cc_French_0_1397_2019_2021_2022_2023" //Niger - reduzco el cambio positivo en la pregunta  - 4.7 (Q)//
replace all_q32_norm=. if id_alex=="cc_French_0_1397_2019_2021_2022_2023" //Niger - reduzco el cambio positivo en la pregunta  - 4.7 (Q)//
replace all_q14_norm=. if id_alex=="cc_French_0_1397_2019_2021_2022_2023" //Niger - reduzco el cambio positivo en la pregunta  - 4.7 (Q)//
replace all_q62_norm=. if id_alex=="cc_French_0_658" //Niger - reduzco el cambio positivo en la pregunta  - 6.3 //
replace all_q63_norm=. if id_alex=="cc_French_0_658" //Niger - reduzco el cambio positivo en la pregunta  - 6.3 //
replace cc_q14b_norm=. if id_alex=="cc_French_0_658" //Niger - reduzco el cambio positivo en la pregunta  - 6.5 //
replace cc_q16c_norm=. if id_alex=="cc_French_0_658" //Niger - reduzco el cambio positivo en la pregunta  - 6.5 //
replace cc_q16f_norm=. if id_alex=="cc_French_0_658" //Niger - reduzco el cambio positivo en la pregunta  - 6.5 //
replace cc_q16g_norm=. if id_alex=="cc_French_0_658" //Niger - reduzco el cambio positivo en la pregunta  - 6.5 //
replace all_q78_norm=. if id_alex=="lb_French_1_179" //Niger - reduzco el cambio positivo en la pregunta  - 7.2  //
replace all_q79_norm=. if id_alex=="lb_French_1_179" //Niger - reduzco el cambio positivo en la pregunta  - 7.2  //
replace all_q80_norm=. if id_alex=="lb_French_1_179" //Niger - reduzco el cambio positivo en la pregunta  - 7.2  //
replace cc_q13_norm=. if id_alex=="cc_French_1_887" //Niger - reduzco el cambio positivo en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="cc_French_0_352_2023" //Niger - reduzco el cambio positivo en la pregunta  - 7.6 //
replace cc_q26a_norm=. if id_alex=="cc_French_0_352_2023" //Niger - reduzco el cambio positivo en la pregunta  - 7.6 //
replace cc_q26b_norm=. if id_alex=="cc_French_0_352_2023" //Niger - reduzco el cambio positivo en la pregunta  - 7.6 //
replace cj_q40b_norm=. if id_alex=="cj_English_1_954_2021_2022_2023" //Niger - reduzco el cambio positivo en la pregunta  - 8.6 //
replace cj_q40c_norm=. if id_alex=="cj_English_1_954_2021_2022_2023" //Niger - reduzco el cambio positivo en la pregunta  - 8.6 //

*Nigeria
replace all_q96_norm=. if id_alex=="cc_English_1_759" //Nigeria - reduzco el cambio positivo en la pregunta  - 2.4 //
replace all_q96_norm=. if id_alex=="lb_English_1_89" //Nigeria - reduzco el cambio positivo en la pregunta  - 2.4 //
replace cc_q9c_norm=. if id_alex=="cc_English_0_71" //Nigeria - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cc_q9c_norm=. if id_alex=="cc_English_1_1035_2022_2023" //Nigeria - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cc_q9c_norm=. if id_alex=="cc_English_1_1063" //Nigeria - reduzco el cambio positivo en la pregunta  - 3.4 //
replace all_q84_norm=. if id_alex=="cc_English_1_1035_2022_2023" //Nigeria - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q84_norm=. if id_alex=="cc_English_0_1092_2022_2023" //Nigeria - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q84_norm=. if id_alex=="cc_English_1_887_2023" //Nigeria - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q86_norm=. if id_alex=="cc_English_1_1035_2022_2023" //Nigeria - reduzco el cambio negativo en la pregunta  - 7.6 //
replace all_q86_norm=. if id_alex=="cc_English_0_1006" //Nigeria - reduzco el cambio negativo en la pregunta  - 7.6 //
replace all_q86_norm=. if id_alex=="cc_English_0_1745_2022_2023" //Nigeria - reduzco el cambio negativo en la pregunta  - 7.6 //
replace all_q87_norm=. if id_alex=="cc_English_0_1745_2022_2023" //Nigeria - reduzco el cambio negativo en la pregunta  - 7.6 //
replace cc_q26b_norm=. if id_alex=="cc_English_1_686_2022_2023" //Nigeria - reduzco el cambio negativo en la pregunta  - 7.6 //
replace cc_q26b_norm=. if id_alex=="cc_English_0_1745_2022_2023" //Nigeria - reduzco el cambio negativo en la pregunta  - 7.6 //
replace cc_q26b_norm=. if id_alex=="cc_English_0_1763_2022_2023" //Nigeria - reduzco el cambio negativo en la pregunta  - 7.6 //
replace cj_q40b_norm=. if id_alex=="cj_English_1_926" //Nigeria - reduzco el cambio negativo en la pregunta  - 8.6 //
replace cj_q40c_norm=. if id_alex=="cj_English_1_926" //Nigeria - reduzco el cambio negativo en la pregunta  - 8.6 //
replace cj_q20m_norm=. if id_alex=="cj_English_1_926" //Nigeria - reduzco el cambio negativo en la pregunta  - 8.6 //

*North Macedonia
replace cc_q40a_norm=. if country=="North Macedonia" // North Macedonia (se elimino el anio pasado)
replace cc_q9c_norm=. if id_alex=="cc_English_0_1455_2022_2023" //North Macedonia - reduzco el cambio positivo en la pregunta  - 3.4 //
replace cc_q9c_norm=. if id_alex=="cc_English_1_69" //North Macedonia - reduzco el cambio positivo en la pregunta  - 3.4 //
replace lb_q23f_norm=. if id_alex=="lb_English_0_177" //North Macedonia - reduzco el cambio positivo en la pregunta  - 4.8 //
replace lb_q23g_norm=. if id_alex=="lb_English_0_177" //North Macedonia - reduzco el cambio positivo en la pregunta  - 4.8 //
replace lb_q2d_norm=. if id_alex=="lb_English_1_62" //North Macedonia - reduzco el cambio negativo en la pregunta  - 6.3 //
replace lb_q3d_norm=. if id_alex=="lb_English_1_62" //North Macedonia - reduzco el cambio negativo en la pregunta  - 6.3 //
replace all_q84_norm=. if id_alex=="cc_English_1_507_2022_2023" //North Macedonia - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q85_norm=. if id_alex=="cc_English_1_507_2022_2023" //North Macedonia - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q13_norm=. if id_alex=="cc_English_1_507_2022_2023" //North Macedonia - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="cc_English_1_507_2022_2023" //North Macedonia - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q26a_norm=. if id_alex=="cc_English_1_507_2022_2023" //North Macedonia - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q26b_norm=. if id_alex=="cc_English_1_507_2022_2023" //North Macedonia - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q84_norm=. if id_alex=="cc_English_1_122" //North Macedonia - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q85_norm=. if id_alex=="cc_English_1_122" //North Macedonia - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q13_norm=. if id_alex=="cc_English_1_122" //North Macedonia - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="cc_English_1_122" //North Macedonia - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q26a_norm=. if id_alex=="cc_English_1_122" //North Macedonia - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q26b_norm=. if id_alex=="cc_English_1_122" //North Macedonia - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q84_norm=. if id_alex=="cc_English_1_532" //North Macedonia - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q85_norm=. if id_alex=="cc_English_1_532" //North Macedonia - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q13_norm=. if id_alex=="cc_English_1_532" //North Macedonia - reduzco el cambio negativo en la pregunta  - 7.5 //
replace all_q88_norm=. if id_alex=="cc_English_1_532" //North Macedonia - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q26a_norm=. if id_alex=="cc_English_1_532" //North Macedonia - reduzco el cambio negativo en la pregunta  - 7.5 //
replace cc_q26b_norm=. if id_alex=="cc_English_1_532" //North Macedonia - reduzco el cambio negativo en la pregunta  - 7.5 //

*Norway
replace all_q89_norm=. if country=="Norway" // Norway (se elimino el anio pasado)
replace all_q40_norm=. if id_alex=="lb_English_1_346" //Norway - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q41_norm=. if id_alex=="lb_English_1_346" //Norway - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q42_norm=. if id_alex=="lb_English_1_346" //Norway - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q43_norm=. if id_alex=="lb_English_1_346" //Norway - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q44_norm=. if id_alex=="lb_English_1_346" //Norway - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q45_norm=. if id_alex=="lb_English_1_346" //Norway - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q46_norm=. if id_alex=="lb_English_1_346" //Norway - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q47_norm=. if id_alex=="lb_English_1_346" //Norway - reduzco el cambio negativo en la pregunta  - 3.2 //

*Pakistan
replace cj_q38_norm=. if id_alex=="cj_English_0_890_2022_2023" //Pakistan - reduzco el cambio negativo en la pregunta  - 1.4 //
replace cj_q36c_norm=. if id_alex=="cj_English_0_774" //Pakistan - reduzco el cambio negativo en la pregunta  - 1.4 //
replace cj_q8_norm=. if id_alex=="cj_English_0_774" //Pakistan - reduzco el cambio negativo en la pregunta  - 1.4 //
replace all_q13_norm=. if id_alex=="cj_English_0_437_2016_2017_2018_2019_2021_2022_2023" //Pakistan - mayor cambio negativo  - 1.6 (Q) //
replace all_q14_norm=. if id_alex=="cj_English_0_437_2016_2017_2018_2019_2021_2022_2023" //Pakistan - mayor cambio negativo  - 1.6 (Q) //
replace all_q15_norm=. if id_alex=="cj_English_0_437_2016_2017_2018_2019_2021_2022_2023" //Pakistan - mayor cambio negativo  - 1.6 (Q) //
replace all_q16_norm=. if id_alex=="cj_English_0_437_2016_2017_2018_2019_2021_2022_2023" //Pakistan - mayor cambio negativo  - 1.6 (Q) //
replace all_q17_norm=. if id_alex=="cj_English_0_437_2016_2017_2018_2019_2021_2022_2023" //Pakistan - mayor cambio negativo  - 1.6 (Q) //
replace cj_q10_norm=. if id_alex=="cj_English_0_437_2016_2017_2018_2019_2021_2022_2023" //Pakistan - mayor cambio negativo  - 1.6 (Q) //
replace all_q18_norm=. if id_alex=="cj_English_0_437_2016_2017_2018_2019_2021_2022_2023" //Pakistan - mayor cambio negativo  - 1.6 (Q) //
replace all_q94_norm=. if id_alex=="cj_English_0_437_2016_2017_2018_2019_2021_2022_2023" //Pakistan - mayor cambio negativo  - 1.6 (Q) //
replace all_q14_norm=. if id_alex=="cc_English_0_1670_2022_2023" //Pakistan - mayor cambio negativo  - 1.6 (Q) //
replace all_q15_norm=. if id_alex=="cc_English_0_1473_2016_2017_2018_2019_2021_2022_2023" //Pakistan - mayor cambio negativo  - 1.6 (Q) //
replace all_q16_norm=. if id_alex=="cc_English_0_1473_2016_2017_2018_2019_2021_2022_2023" //Pakistan - mayor cambio negativo  - 1.6 (Q) //
replace cj_q10_norm=. if id_alex=="cj_English_1_244" //Pakistan - mayor cambio negativo  - 1.6 (Q) //
replace all_q15_norm=. if id_alex=="cj_English_1_369_2018_2019_2021_2022_2023" //Pakistan - mayor cambio negativo  - 1.6 (Q) //
replace all_q16_norm=. if id_alex=="cj_English_1_369_2018_2019_2021_2022_2023" //Pakistan - mayor cambio negativo  - 1.6 (Q) //
replace all_q18_norm=. if id_alex=="cj_English_1_369_2018_2019_2021_2022_2023" //Pakistan - mayor cambio negativo  - 1.6 (Q) //
replace all_q94_norm=0 if id_alex=="cc_English_0_668_2018_2019_2021_2022_2023" //Pakistan - mayor cambio negativo  - 1.6 (Q) //
replace all_q18_norm=0 if id_alex=="cc_English_0_668_2018_2019_2021_2022_2023" //Pakistan - mayor cambio negativo  - 1.6 (Q) //
replace all_q19_norm=. if id_alex=="cj_English_0_437_2016_2017_2018_2019_2021_2022_2023" //Pakistan - mayor cambio negativo  - 4.7  //
replace all_q31_norm=. if id_alex=="cj_English_0_437_2016_2017_2018_2019_2021_2022_2023" //Pakistan - mayor cambio negativo  - 4.7  //
replace all_q32_norm=. if id_alex=="cj_English_0_437_2016_2017_2018_2019_2021_2022_2023" //Pakistan - mayor cambio negativo  - 4.7  //
replace all_q19_norm=. if id_alex=="cc_English_0_1285_2017_2018_2019_2021_2022_2023" //Pakistan - mayor cambio negativo  - 4.7  //
replace all_q31_norm=. if id_alex=="cc_English_0_1285_2017_2018_2019_2021_2022_2023" //Pakistan - mayor cambio negativo  - 4.7  //
replace all_q32_norm=. if id_alex=="cc_English_0_1285_2017_2018_2019_2021_2022_2023" //Pakistan - mayor cambio negativo  - 4.7  //
replace all_q14_norm=. if id_alex=="cc_English_0_1285_2017_2018_2019_2021_2022_2023" //Pakistan - mayor cambio negativo  - 4.7  //
replace all_q87_norm=. if id_alex=="cc_English_1_397_2017_2018_2019_2021_2022_2023" //Pakistan - reduzco el cambio negativo en la pregunta  - 7.6 //
replace all_q87_norm=. if id_alex=="cc_English_1_1191_2018_2019_2021_2022_2023" //Pakistan - reduzco el cambio negativo en la pregunta  - 7.6 //
replace cc_q26b_norm=. if id_alex=="cc_English_1_1191_2018_2019_2021_2022_2023" //Pakistan - reduzco el cambio negativo en la pregunta  - 7.6 //
replace cj_q20o_norm=. if id_alex=="cj_English_0_337" //Pakistan - reduzco el cambio positivo en la pregunta  - 8.4 //
replace cj_q40b_norm=. if id_alex=="cj_English_0_437_2016_2017_2018_2019_2021_2022_2023" //Pakistan - mayor cambio negativo  - 8.6  //
replace cj_q40c_norm=. if id_alex=="cj_English_0_437_2016_2017_2018_2019_2021_2022_2023" //Pakistan - mayor cambio negativo  - 8.6  //
replace cj_q20m_norm=. if id_alex=="cj_English_0_437_2016_2017_2018_2019_2021_2022_2023" //Pakistan - mayor cambio negativo  - 8.6  //

*Panama
drop if id_alex=="cc_Spanish_0_1436" // Panama (muy negativo)
drop if id_alex=="cc_English_0_139" // Panama (muy negativo)
drop if id_alex=="cc_Spanish_0_1002" // Panama (muy negativo)
replace all_q6_norm=. if id_alex=="cc_Spanish_1_1280_2023" //Panama - reduzco el cambio negativo en la pregunta  - 1.3 //
replace all_q6_norm=. if id_alex=="cc_English_1_694" //Panama - reduzco el cambio negativo en la pregunta  - 1.3 //
replace cj_q38_norm=. if id_alex=="cj_Spanish_0_502_2017_2018_2019_2021_2022_2023" //Panama - reduzco el cambio negativo en la pregunta  - 1.4 //
replace cj_q38_norm=. if id_alex=="cj_Spanish_1_470_2017_2018_2019_2021_2022_2023" //Panama - reduzco el cambio negativo en la pregunta  - 1.4 //
replace cc_q33_norm=. if id_alex=="cc_Spanish_1_1143_2023" //Panama - reduzco el cambio negativo en la pregunta  - 1.4 //
replace cc_q39d_norm=. if id_alex=="cc_Spanish_1_801" //Panama - reduzco el cambio negativo en la pregunta  - 3.2 //
replace cc_q39e_norm=. if id_alex=="cc_English_1_1451_2023" //Panama - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q41_norm=. if id_alex=="cc_Spanish_1_1143_2023" //Panama - reduzco el cambio negativo en la pregunta  - 3.2 //
replace all_q29_norm=. if id_alex=="cc_Spanish_1_320_2023" //Panama - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cc_Spanish_1_1280_2023" //Panama - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q29_norm=. if id_alex=="cj_Spanish_0_650_2019_2021_2022_2023" //Panama - reduzco el cambio negativo en la pregunta  - 4.5 //
replace all_q48_norm=. if id_alex=="cc_Spanish_1_1280_2023" //Panama - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q49_norm=. if id_alex=="cc_Spanish_1_1280_2023" //Panama - reduzco el cambio negativo en la pregunta  - 6.4 //
replace all_q50_norm=. if id_alex=="cc_Spanish_1_1280_2023" //Panama - reduzco el cambio negativo en la pregunta  - 6.4 //
replace cc_q16b_norm=. if id_alex=="cc_Spanish_1_1143_2023" //Panama - reduzco el cambio negativo en la pregunta  - 6.4 //
replace cc_q16c_norm=. if id_alex=="cc_Spanish_1_1143_2023" //Panama - reduzco el cambio negativo en la pregunta  - 6.4 //
replace cc_q16d_norm=. if id_alex=="cc_Spanish_1_1143_2023" //Panama - reduzco el cambio negativo en la pregunta  - 6.4 //
replace cc_q16e_norm=. if id_alex=="cc_Spanish_1_1143_2023" //Panama - reduzco el cambio negativo en la pregunta  - 6.4 //
replace cc_q16f_norm=. if id_alex=="cc_Spanish_1_1143_2023" //Panama - reduzco el cambio negativo en la pregunta  - 6.4 //
replace cc_q26b_norm=. if id_alex=="cc_Spanish_1_1280_2023" //Panama - reduzco el cambio negativo en la pregunta  - 7.6 //
replace cc_q26b_norm=. if id_alex=="cc_Spanish_1_290_2023" //Panama - reduzco el cambio negativo en la pregunta  - 7.6 //
replace cc_q26b_norm=. if id_alex=="cc_English_0_62" //Panama - reduzco el cambio negativo en la pregunta  - 7.6 //
replace cc_q26b_norm=. if id_alex=="cc_Spanish_1_1143_2023" //Panama - reduzco el cambio negativo en la pregunta  - 7.6 //

*Paraguay
drop if id_alex=="cj_Spanish_1_687" // Paraguay (muy negativo)
replace cj_q42c_norm=. if country=="Paraguay" // Paraguay (se elimino el anio pasado)
replace cj_q42d_norm=. if country=="Paraguay" // Paraguay (se elimino el anio pasado)
replace cj_q8_norm =. if id_alex=="cj_Spanish_1_681" //Paraguay- Reduzco el cambio positivo en las preguntas  - 1.4 //
replace cj_q8_norm =0 if id_alex=="cj_Spanish_0_182_2023" //Paraguay- Reduzco el cambio positivo en las preguntas  - 1.4 //
replace cj_q9_norm =. if id_alex=="cj_Spanish_0_245" //Paraguay- Reduzco el cambio positivo en las preguntas  - 1.5 //
replace all_q96_norm =0 if id_alex=="cj_Spanish_0_448_2023" //Paraguay- Reduzco el cambio positivo en las preguntas  - 2.4 //
replace all_q96_norm =. if id_alex=="cj_Spanish_0_986" //Paraguay- Reduzco el cambio positivo en las preguntas  - 2.4 //
replace all_q96_norm =. if id_alex=="cj_Spanish_0_245" //Paraguay- Reduzco el cambio positivo en las preguntas  - 2.4 //
replace all_q29_norm =. if id_alex=="cc_Spanish_1_732" //Paraguay- Reduzco el cambio negativo en las preguntas  - 4.5 //
replace all_q29_norm =. if id_alex=="cj_Spanish_0_986" //Paraguay- Reduzco el cambio negativo en las preguntas  - 4.5 //
replace cj_q15_norm =. if id_alex=="cj_Spanish_0_248" //Paraguay- Reduzco el cambio negativo en las preguntas  - 5.3 //
replace cj_q15_norm =. if id_alex=="cj_Spanish_1_460" //Paraguay- Reduzco el cambio negativo en las preguntas  - 5.3 //
replace all_q62_norm =. if id_alex=="cc_Spanish_0_979_2023" //Paraguay- Reduzco el cambio negativo en las preguntas  - 6.3 //
replace all_q63_norm =. if id_alex=="cc_Spanish_0_979_2023" //Paraguay- Reduzco el cambio negativo en las preguntas  - 6.3 //
replace all_q62_norm =. if id_alex=="cc_Spanish_1_690_2023" //Paraguay- Reduzco el cambio negativo en las preguntas  - 6.3 //
replace all_q63_norm =. if id_alex=="cc_Spanish_1_690_2023" //Paraguay- Reduzco el cambio negativo en las preguntas  - 6.3 //
replace all_q62_norm =. if id_alex=="cc_Spanish_0_56_2022_2023" //Paraguay- Reduzco el cambio negativo en las preguntas  - 6.3 //
replace all_q63_norm =. if id_alex=="cc_Spanish_0_56_2022_2023" //Paraguay- Reduzco el cambio negativo en las preguntas  - 6.3 //
replace all_q51_norm =. if id_alex=="cc_Spanish_1_732" //Paraguay- Reduzco el cambio negativo en las preguntas  - 7.3 //
replace cc_q26b_norm =. if id_alex=="cc_Spanish_0_979_2023" //Paraguay- Reduzco el cambio negativo en las preguntas  - 7.6 //
replace all_q86_norm =. if id_alex=="lb_Spanish_0_219_2022_2023" //Paraguay- Reduzco el cambio negativo en las preguntas  - 7.6 //
replace all_q87_norm =. if id_alex=="lb_Spanish_0_219_2022_2023" //Paraguay- Reduzco el cambio negativo en las preguntas  - 7.6 //
replace cj_q20e_norm =. if id_alex=="cj_Spanish_0_245" //Paraguay- Reduzco el cambio positivo en las preguntas  - 8.2 //
replace cj_q28_norm =. if id_alex=="cj_Spanish_0_245" //Paraguay- Reduzco el cambio positivo en las preguntas  - 8.3 //
replace cj_q20o_norm =. if id_alex=="cj_Spanish_1_681" //Paraguay- Reduzco el cambio negativo en las preguntas  - 8.4 //
replace cj_q20o_norm =. if id_alex=="cj_Spanish_0_986" //Paraguay- Reduzco el cambio negativo en las preguntas  - 8.4 //

*Peru
drop if id_alex=="cc_Spanish_1_245" // Peru (muy positivo)
drop if id_alex=="lb_Spanish_1_771_2022_2023" // Peru (muy positivo)
drop if id_alex=="lb_Spanish_0_113_2021_2022_2023" // Peru (muy positivo)
drop if id_alex=="cc_Spanish_1_351" // Peru (muy positivo)
replace all_q86_norm =. if id_alex=="cc_Spanish_1_970_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 7.6 //
replace all_q86_norm =. if id_alex=="cc_Spanish_0_969_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 7.6 //
replace all_q86_norm =. if id_alex=="lb_Spanish_0_266_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 7.6 //
replace all_q87_norm =. if id_alex=="lb_Spanish_0_266_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 7.6 //
replace all_q86_norm =. if id_alex=="lb_Spanish_0_205_2016_2017_2018_2019_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 7.6 //
replace all_q87_norm =. if id_alex=="lb_Spanish_0_205_2016_2017_2018_2019_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 7.6 //
replace cc_q26b_norm =. if id_alex=="cc_Spanish_0_331_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 7.6 //
replace all_q89_norm =. if id_alex=="cc_Spanish_1_451" //Peru- Reduzco el cambio positivo en las preguntas  - 7.7 //
replace all_q59_norm =. if id_alex=="cc_Spanish_1_451" //Peru- Reduzco el cambio positivo en las preguntas  - 7.7 //
replace all_q90_norm =. if id_alex=="cc_Spanish_0_1886" //Peru- Reduzco el cambio positivo en las preguntas  - 7.7 //
replace all_q90_norm =. if id_alex=="cc_Spanish_1_970_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 7.7 //
replace all_q59_norm =. if id_alex=="cc_Spanish_1_970_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 7.7 //
replace cj_q21h_norm =. if id_alex=="cj_Spanish_0_506_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 8.3 //
replace cj_q21h_norm =. if id_alex=="cj_Spanish_0_1076" //Peru- Reduzco el cambio positivo en las preguntas  - 8.3 //
replace all_q13_norm =. if id_alex=="cc_Spanish_0_715_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q14_norm =. if id_alex=="cc_Spanish_0_715_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q15_norm =. if id_alex=="cc_Spanish_0_715_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q16_norm =. if id_alex=="cc_Spanish_0_715_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q17_norm =. if id_alex=="cc_Spanish_0_715_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q18_norm =. if id_alex=="cc_Spanish_0_715_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q19_norm =. if id_alex=="cc_Spanish_0_715_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q20_norm =. if id_alex=="cc_Spanish_0_715_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q21_norm =. if id_alex=="cc_Spanish_0_715_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q94_norm =. if id_alex=="cc_Spanish_0_715_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q13_norm =. if id_alex=="cj_Spanish_0_511_2017_2018_2019_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q14_norm =. if id_alex=="cj_Spanish_0_511_2017_2018_2019_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q15_norm =. if id_alex=="cj_Spanish_0_511_2017_2018_2019_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q16_norm =. if id_alex=="cj_Spanish_0_511_2017_2018_2019_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q17_norm =. if id_alex=="cj_Spanish_0_511_2017_2018_2019_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q18_norm =. if id_alex=="cj_Spanish_0_511_2017_2018_2019_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q19_norm =. if id_alex=="cj_Spanish_0_511_2017_2018_2019_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q20_norm =. if id_alex=="cj_Spanish_0_511_2017_2018_2019_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q21_norm =. if id_alex=="cj_Spanish_0_511_2017_2018_2019_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q94_norm =. if id_alex=="cj_Spanish_0_511_2017_2018_2019_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace cj_q10_norm =. if id_alex=="cj_Spanish_0_511_2017_2018_2019_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q13_norm =. if id_alex=="cj_Spanish_1_701_2017_2018_2019_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q14_norm =. if id_alex=="cj_Spanish_1_701_2017_2018_2019_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q15_norm =. if id_alex=="cj_Spanish_1_701_2017_2018_2019_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q16_norm =. if id_alex=="cj_Spanish_1_701_2017_2018_2019_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q17_norm =. if id_alex=="cj_Spanish_1_701_2017_2018_2019_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q18_norm =. if id_alex=="cj_Spanish_1_701_2017_2018_2019_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q19_norm =. if id_alex=="cj_Spanish_1_701_2017_2018_2019_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q20_norm =. if id_alex=="cj_Spanish_1_701_2017_2018_2019_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q21_norm =. if id_alex=="cj_Spanish_1_701_2017_2018_2019_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q94_norm =. if id_alex=="cj_Spanish_1_701_2017_2018_2019_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q13_norm =. if id_alex=="cj_Spanish_0_1026_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q14_norm =. if id_alex=="cj_Spanish_0_1026_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q15_norm =. if id_alex=="cj_Spanish_0_1026_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q16_norm =. if id_alex=="cj_Spanish_0_1026_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q17_norm =. if id_alex=="cj_Spanish_0_1026_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q18_norm =. if id_alex=="cj_Spanish_0_1026_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q19_norm =. if id_alex=="cj_Spanish_0_1026_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q20_norm =. if id_alex=="cj_Spanish_0_1026_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q21_norm =. if id_alex=="cj_Spanish_0_1026_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q94_norm =. if id_alex=="cj_Spanish_0_1026_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q14_norm =. if id_alex=="cc_Spanish_0_715_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q15_norm =. if id_alex=="cc_Spanish_0_715_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q16_norm =. if id_alex=="cc_Spanish_0_715_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q18_norm =. if id_alex=="cc_Spanish_0_715_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q19_norm =. if id_alex=="cc_Spanish_0_715_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q20_norm =. if id_alex=="cc_Spanish_0_715_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q21_norm =. if id_alex=="cc_Spanish_0_715_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q94_norm =. if id_alex=="cc_Spanish_0_715_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q14_norm =. if id_alex=="cc_Spanish_0_331_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q15_norm =. if id_alex=="cc_Spanish_0_331_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q16_norm =. if id_alex=="cc_Spanish_0_331_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q18_norm =. if id_alex=="cc_Spanish_0_331_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q19_norm =. if id_alex=="cc_Spanish_0_331_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q20_norm =. if id_alex=="cc_Spanish_0_331_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q21_norm =. if id_alex=="cc_Spanish_0_331_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q94_norm =. if id_alex=="cc_Spanish_0_331_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.4 (Q) //
replace all_q19_norm =. if id_alex=="cj_Spanish_0_1121_2019_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.7 //
replace all_q31_norm =. if id_alex=="cj_Spanish_0_1121_2019_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.7 //
replace all_q32_norm =. if id_alex=="cj_Spanish_0_1121_2019_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.7 //
replace all_q14_norm =. if id_alex=="cj_Spanish_0_1121_2019_2021_2022_2023" //Peru- Reduzco el cambio positivo en las preguntas  - 4.7 //

*Philippines
drop if id_alex=="cc_English_1_267" // Philippines (muy positivo)
drop if id_alex=="cj_English_1_902" // Philippines (muy positivo)
replace all_q46_norm=. if country=="Philippines" // Philippines (se elimino el anio pasado)
replace all_q47_norm=. if country=="Philippines" // Philippines (se elimino el anio pasado)
replace all_q88_norm=. if country=="Philippines" // Philippines (se elimino el anio pasado)
replace cc_q26a_norm=. if country=="Philippines" // Philippines (se elimino el anio pasado)
replace cj_q33c_norm =. if id_alex=="cj_English_1_319" //Philippines- Reduzco el cambio positivo en las preguntas  - 2.2 //
replace cj_q33d_norm =. if id_alex=="cj_English_1_319" //Philippines- Reduzco el cambio positivo en las preguntas  - 2.2 //
replace cj_q33e_norm =. if id_alex=="cj_English_1_319" //Philippines- Reduzco el cambio positivo en las preguntas  - 2.2 //
replace cj_q31b_norm =. if id_alex=="cj_English_0_473" //Philippines- Reduzco el cambio positivo  - 2.3 //
replace all_q96_norm =. if id_alex=="cc_English_0_309" //Philippines- Reduzco el cambio positivo  - 2.4 //
replace cc_q39a_norm =. if id_alex=="cc_English_1_135" //Philippines- Reduzco el cambio negativo  - 3.2 //
replace cc_q39b_norm =. if id_alex=="cc_English_1_135" //Philippines- Reduzco el cambio negativo  - 3.2 //
replace cc_q39c_norm =. if id_alex=="cc_English_1_135" //Philippines- Reduzco el cambio negativo  - 3.2 //
replace cc_q39d_norm =. if id_alex=="cc_English_1_135" //Philippines- Reduzco el cambio negativo  - 3.2 //
replace cc_q39e_norm =. if id_alex=="cc_English_1_135" //Philippines- Reduzco el cambio negativo  - 3.2 //
replace cc_q39d_norm =. if id_alex=="cc_English_0_394_2023" //Philippines- Reduzco el cambio negativo  - 3.2 //
replace cc_q39d_norm =. if id_alex=="cc_English_1_497" //Philippines- Reduzco el cambio negativo  - 3.2 //
replace cc_q39b_norm =. if id_alex=="cc_English_0_1600" //Philippines- Reduzco el cambio negativo  - 3.2 //
replace all_q41_norm =. if id_alex=="cc_English_1_781_2022_2023" //Philippines- Reduzco el cambio negativo  - 3.2 //
replace all_q42_norm =. if id_alex=="cc_English_1_781_2022_2023" //Philippines- Reduzco el cambio negativo  - 3.2 //
replace all_q43_norm =. if id_alex=="cc_English_1_781_2022_2023" //Philippines- Reduzco el cambio negativo  - 3.2 //
replace all_q41_norm =. if id_alex=="lb_English_1_407" //Philippines- Reduzco el cambio negativo  - 3.2 //
replace all_q42_norm =. if id_alex=="lb_English_1_407" //Philippines- Reduzco el cambio negativo  - 3.2 //
replace all_q43_norm =. if id_alex=="lb_English_1_407" //Philippines- Reduzco el cambio negativo  - 3.2 //
replace cc_q39d_norm =. if id_alex=="cc_English_1_781_2022_2023" //Philippines- Reduzco el cambio negativo  - 3.2 //
replace cc_q39b_norm =. if id_alex=="cc_English_0_375" //Philippines- Reduzco el cambio negativo  - 3.2 //
replace all_q44_norm =. if id_alex=="cc_English_1_497" //Philippines- Reduzco el cambio negativo  - 3.2 //
replace cc_q40a_norm =. if id_alex=="cc_English_0_394_2023" //Philippines- Reduzco el cambio negativo  - 3.4 //
replace cc_q40b_norm =. if id_alex=="cc_English_0_394_2023" //Philippines- Reduzco el cambio negativo  - 3.4 //
replace all_q29_norm =. if id_alex=="cc_English_0_1600" //Philippines- Reduzco el cambio negativo  - 4.5 //
replace all_q29_norm =. if id_alex=="cc_English_1_1333_2022_2023" //Philippines- Reduzco el cambio negativo  - 4.5 //
replace cc_q26b_norm =. if id_alex=="cc_English_0_1600" //Philippines- Reduzco el cambio negativo  - 7.6 //
replace all_q86_norm =. if id_alex=="cc_English_0_309" //Philippines- Reduzco el cambio negativo  - 7.6 //
replace all_q86_norm =. if id_alex=="cc_English_0_1600" //Philippines- Reduzco el cambio negativo  - 7.6 //
replace all_q87_norm =. if id_alex=="cc_English_0_1600" //Philippines- Reduzco el cambio negativo  - 7.6 //
replace all_q59_norm =. if id_alex=="lb_English_1_359" //Philippines- Reduzco el cambio negativo  - 7.7 //
replace cc_q26b_norm =. if id_alex=="cc_English_0_394_2023" //Philippines- Reduzco el cambio negativo  - 7.7 //
replace cc_q14a_norm =. if id_alex=="cc_English_0_1600" //Philippines- Reduzco el cambio negativo  - 7.7 //
replace cc_q14b_norm =. if id_alex=="cc_English_0_1600" //Philippines- Reduzco el cambio negativo  - 7.7 //

*Poland
drop if id_alex=="cc_English_0_504" // Poland (muy positivo)
drop if id_alex=="cc_English_0_1109" // Poland (muy positivo)
drop if id_alex=="cc_English_0_901" // Poland (muy positivo)
drop if id_alex=="cj_English_0_977" // Poland (muy positivo)
drop if id_alex=="lb_English_1_644" // Poland (muy positivo)
drop if id_alex=="cc_English_0_730" // Poland (muy positivo)
drop if id_alex=="cc_English_1_1113" // Poland (muy positivo)
replace cc_q25_norm=. if country=="Poland" // Poland (se elimino el anio pasado)
replace cj_q8_norm=. if country=="Poland" // Poland (se elimino el anio pasado)
replace all_q34_norm=. if country=="Poland" // Poland (se elimino el anio pasado)
replace cc_q39e_norm=. if country=="Poland" // Poland (se elimino el anio pasado)
replace all_q42_norm=. if country=="Poland" // Poland (se elimino el anio pasado)
replace cc_q40a_norm=. if country=="Poland" // Poland (se elimino el anio pasado)
replace all_q2_norm =. if id_alex=="cc_English_0_1035" //Poland- Reduzco el cambio positivo  - 1.2 //
replace all_q2_norm =. if id_alex=="cc_English_0_1270" //Poland- Reduzco el cambio positivo  - 1.2 //
replace cc_q33_norm =. if id_alex=="cc_English_0_1527" //Poland- Reduzco el cambio positivo  - 1.4 //
replace cc_q33_norm =. if id_alex=="cc_English_0_824" //Poland- Reduzco el cambio positivo  - 1.4 //
replace cc_q33_norm =. if id_alex=="cc_English_0_1301" //Poland- Reduzco el cambio positivo  - 1.4 //
replace cc_q33_norm =. if id_alex=="cc_English_0_1035" //Poland- Reduzco el cambio positivo  - 1.4 //
replace cc_q33_norm =. if id_alex=="cc_English_0_297" //Poland- Reduzco el cambio positivo  - 1.4 //
replace cc_q33_norm =. if id_alex=="cc_English_0_1625" //Poland- Reduzco el cambio positivo  - 1.4 //
replace cj_q36c_norm =. if id_alex=="cj_French_0_974" //Poland- Reduzco el cambio positivo  - 1.4 //
replace all_q21_norm =. if id_alex=="cj_English_0_222" //Poland- Reduzco el cambio positivo  - 1.6 //
replace all_q21_norm =. if id_alex=="cj_English_0_271" //Poland- Reduzco el cambio positivo  - 1.6 //
replace cj_q32c_norm =. if id_alex=="cj_English_0_734" //Poland- Reduzco el cambio negativo  - 2.3 //
replace cj_q32d_norm =. if id_alex=="cj_English_0_734" //Poland- Reduzco el cambio negativo  - 2.3 //
replace cj_q31a_norm =. if id_alex=="cj_English_0_734" //Poland- Reduzco el cambio negativo  - 2.3 //
replace cj_q31b_norm =. if id_alex=="cj_English_0_734" //Poland- Reduzco el cambio negativo  - 2.3 //
replace cj_q31a_norm =. if id_alex=="cj_English_0_936" //Poland- Reduzco el cambio negativo  - 2.3 //
replace cj_q31b_norm =. if id_alex=="cj_English_0_936" //Poland- Reduzco el cambio negativo  - 2.3 //
replace cj_q16j_norm =. if id_alex=="cj_English_0_222" //Poland- Reduzco el cambio negativo  - 2.3 //
replace cj_q18a_norm =. if id_alex=="cj_English_0_222" //Poland- Reduzco el cambio negativo  - 2.3 //
replace all_q96_norm =. if id_alex=="cc_English_0_297" //Poland- 2.4 //
replace all_q96_norm =. if id_alex=="cc_English_0_503" //Poland- 2.4 //
replace all_q96_norm =. if id_alex=="cj_English_0_936" //Poland- 2.4 //
replace cc_q39b_norm =. if id_alex=="cc_English_0_1035" //Poland- Reduzco el cambio positivo  - 3.2 //
replace cc_q39b_norm =. if id_alex=="cc_English_0_1194" //Poland- Reduzco el cambio positivo  - 3.2 //
replace cc_q39b_norm =. if id_alex=="cc_English_0_1527" //Poland- Reduzco el cambio positivo  - 3.2 //
replace all_q44_norm =. if id_alex=="cc_English_0_1035" //Poland- Reduzco el cambio positivo  - 3.2 //
replace all_q44_norm =. if id_alex=="cc_English_0_1035" //Poland- Reduzco el cambio positivo  - 3.2 //
replace all_q44_norm =. if id_alex=="cc_English_0_1035" //Poland- Reduzco el cambio positivo  - 3.2 //
replace all_q45_norm =. if id_alex=="cc_English_0_1194" //Poland- Reduzco el cambio positivo  - 3.2 //
replace all_q45_norm =. if id_alex=="cc_English_0_1194" //Poland- Reduzco el cambio positivo  - 3.2 //
replace all_q45_norm =. if id_alex=="cc_English_0_1194" //Poland- Reduzco el cambio positivo  - 3.2 //
replace all_q46_norm =. if id_alex=="cc_English_0_1527" //Poland- Reduzco el cambio positivo  - 3.2 //
replace all_q46_norm =. if id_alex=="cc_English_0_1527" //Poland- Reduzco el cambio positivo  - 3.2 //
replace all_q46_norm =. if id_alex=="cc_English_0_1527" //Poland- Reduzco el cambio positivo  - 3.2 //
replace cj_q31f_norm =. if id_alex=="cj_English_0_750" //Poland- Reduzco el cambio negativo  - 4.6 //
replace cj_q31g_norm =. if id_alex=="cj_English_0_750" //Poland- Reduzco el cambio negativo  - 4.6 //
replace cj_q31f_norm =. if id_alex=="cj_English_0_734" //Poland- Reduzco el cambio negativo  - 4.6 //
replace cj_q31g_norm =. if id_alex=="cj_English_0_734" //Poland- Reduzco el cambio negativo  - 4.6 //
replace cj_q31f_norm =. if id_alex=="cj_English_0_222" //Poland- Reduzco el cambio negativo  - 4.6 //
replace cj_q31g_norm =. if id_alex=="cj_English_0_222" //Poland- Reduzco el cambio negativo  - 4.6 //
replace cj_q15_norm =. if id_alex=="cj_English_0_1307" //Poland- Reduzco el cambio negativo  - 5.3 //
replace cj_q15_norm =1 if id_alex=="cj_English_0_623" //Poland- Reduzco el cambio negativo  - 5.3 //
replace cj_q15_norm =1 if id_alex=="cj_English_0_734" //Poland- Reduzco el cambio negativo  - 5.3 //
replace cj_q15_norm =1 if id_alex=="cj_English_0_1141" //Poland- Reduzco el cambio negativo  - 5.3 //
replace all_q54_norm =. if id_alex=="cc_English_0_1073" //Poland- Reduzco el cambio negativo  - 6.2 //
replace all_q54_norm =. if id_alex=="cc_English_0_1528" //Poland- Reduzco el cambio negativo  - 6.2 //
replace all_q54_norm =. if id_alex=="cc_English_0_297" //Poland- Reduzco el cambio negativo  - 6.2 //
replace all_q54_norm =. if id_alex=="cc_English_0_1763" //Poland- Reduzco el cambio negativo  - 6.2 //
replace cc_q16d_norm =. if id_alex=="cc_English_0_650" //Poland- Reduzco el cambio positivo  - 6.5 //
replace cc_q16e_norm =. if id_alex=="cc_English_0_650" //Poland- Reduzco el cambio positivo  - 6.5 //
replace cc_q16f_norm =. if id_alex=="cc_English_0_650" //Poland- Reduzco el cambio positivo  - 6.5 //
replace cc_q16d_norm =. if id_alex=="cc_English_0_244" //Poland- Reduzco el cambio positivo  - 6.5 //
replace cc_q16e_norm =. if id_alex=="cc_English_0_244" //Poland- Reduzco el cambio positivo  - 6.5 //
replace cc_q16f_norm =. if id_alex=="cc_English_0_244" //Poland- Reduzco el cambio positivo  - 6.5 //
replace  all_q80_norm =. if id_alex=="cc_English_0_1073" //Poland- Reduzco el cambio negativo  - 7.2 //
replace  all_q80_norm =. if id_alex=="cc_English_0_297" //Poland- Reduzco el cambio negativo  - 7.2 //
replace  all_q84_norm =. if id_alex=="cc_English_0_1025" //Poland- Reduzco el cambio negativo  - 7.5 //
replace  cc_q13_norm =. if id_alex=="cc_English_0_1025" //Poland- Reduzco el cambio negativo  - 7.5 //
replace  all_q84_norm =. if id_alex=="lb_English_1_394_2023" //Poland- Reduzco el cambio negativo  - 7.5 //
replace  all_q85_norm =. if id_alex=="cc_English_0_1625" //Poland- Reduzco el cambio negativo  - 7.5 //
replace  cc_q13_norm =. if id_alex=="cc_English_0_1146" //Poland- Reduzco el cambio negativo  - 7.5 //
replace  cc_q13_norm =. if id_alex=="cc_English_0_824" //Poland- Reduzco el cambio negativo  - 7.5 //
replace  cc_q26a_norm =. if id_alex=="cc_English_0_1763" //Poland- Reduzco el cambio negativo  - 7.5 //
replace  cc_q26a_norm =. if id_alex=="cc_English_0_298" //Poland- Reduzco el cambio negativo  - 7.5 //
replace  cc_q26a_norm =. if id_alex=="cc_English_0_1205" //Poland- Reduzco el cambio negativo  - 7.5 //
replace  cj_q27a_norm =. if id_alex=="cj_English_0_271" //Poland- Reduzco el cambio negativo  - 8.2 //
replace  cj_q27b_norm =. if id_alex=="cj_English_0_271" //Poland- Reduzco el cambio negativo  - 8.2 //
replace  cj_q27a_norm =. if id_alex=="cj_English_0_936" //Poland- Reduzco el cambio negativo  - 8.2 //
replace  cj_q27b_norm =. if id_alex=="cj_English_0_936" //Poland- Reduzco el cambio negativo  - 8.2 //
replace  cj_q27a_norm =. if id_alex=="cj_English_0_690" //Poland- Reduzco el cambio negativo  - 8.2 //
replace  cj_q27a_norm =. if id_alex=="cj_English_0_561" //Poland- Reduzco el cambio negativo  - 8.2 //
replace  cj_q20e_norm =. if id_alex=="cj_English_0_222" //Poland- Reduzco el cambio negativo  - 8.2 //
replace  cj_q20e_norm =. if id_alex=="cj_English_0_623" //Poland- Reduzco el cambio negativo  - 8.2 //
replace  cj_q20e_norm =. if id_alex=="cj_English_0_271" //Poland- Reduzco el cambio negativo  - 8.2 //
replace  cj_q20e_norm =. if id_alex=="cj_English_0_854" //Poland- Reduzco el cambio negativo  - 8.2 //
replace  cj_q20a_norm =. if id_alex=="cj_English_0_854" //Poland- Reduzco el cambio negativo  - 8.2 //
replace  cj_q20b_norm =. if id_alex=="cj_English_0_854" //Poland- Reduzco el cambio negativo  - 8.2 //
replace  cj_q20a_norm =. if id_alex=="cj_English_0_222" //Poland- Reduzco el cambio negativo  - 8.2 //
replace  cj_q20b_norm =. if id_alex=="cj_English_0_222" //Poland- Reduzco el cambio negativo  - 8.2 //
replace  cj_q27a_norm =. if id_alex=="cj_English_0_1307" //Poland- Reduzco el cambio negativo  - 8.2 //
replace  cj_q27a_norm =. if id_alex=="cj_English_0_153" //Poland- Reduzco el cambio negativo  - 8.2 //
replace  cj_q20e_norm =. if id_alex=="cj_English_0_936" //Poland- Reduzco el cambio negativo  - 8.2 //
replace  cj_q20a_norm =. if id_alex=="cj_English_0_750" //Poland- Reduzco el cambio negativo  - 8.2 //

*Portugal
drop if id_alex=="cj_Portuguese_0_952" // Portugal (muy negativo)
drop if id_alex=="cc_Portuguese_0_1850" // Portugal (muy negativo)
drop if id_alex=="cc_Portuguese_0_456" // Portugal (muy negativo)
drop if id_alex=="cc_Portuguese_0_1908" // Portugal (muy negativo)
drop if id_alex=="cc_Portuguese_0_987" // Portugal (muy negativo)
drop if id_alex=="lb_Portuguese_0_429" // Portugal (muy negativo)
drop if id_alex=="lb_Portuguese_0_237" // Portugal (muy negativo)
replace all_q21_norm =. if id_alex=="cj_Portuguese_0_1079" //Portugal- Reduzco el cambio negativo  - 1.2 //
replace all_q21_norm =. if id_alex=="lb_English_0_105" //Portugal- Reduzco el cambio negativo  - 1.2 //
replace cc_q25_norm =. if id_alex=="cc_English_0_1360" //Portugal- Reduzco el cambio negativo  - 1.3 //
replace cc_q25_norm =. if id_alex=="cc_English_0_1256" //Portugal- Reduzco el cambio negativo  - 1.3 //
replace all_q9_norm =. if id_alex=="cj_Portuguese_1_557" //Portugal- Reduzco el cambio negativo  - 1.4 //
replace cj_q10_norm =. if id_alex=="cj_Portuguese_0_1079" //Portugal- Reduzco el cambio negativo  - 1.6 //
replace cj_q10_norm =. if id_alex=="cj_Portuguese_0_1304" //Portugal- Reduzco el cambio negativo  - 1.6 //
replace cc_q39d_norm =. if id_alex=="cc_Portuguese_0_815_2023" //Portugal- Reduzco el cambio negativo  - 3.2 //
replace cc_q39d_norm =. if id_alex=="cc_English_1_1415_2023" //Portugal- Reduzco el cambio negativo  - 3.2 //
replace cc_q39d_norm =. if id_alex=="cc_Portuguese_0_856_2023" //Portugal- Reduzco el cambio negativo  - 3.2 //
replace cc_q39d_norm =. if id_alex=="cc_English_0_1360" //Portugal- Reduzco el cambio negativo  - 3.2 //
replace all_q42_norm =. if id_alex=="cc_Portuguese_0_1512" //Portugal- Reduzco el cambio negativo  - 3.2 //
replace all_q43_norm =. if id_alex=="cc_Portuguese_0_1512" //Portugal- Reduzco el cambio negativo  - 3.2 //
replace all_q47_norm =. if id_alex=="cc_Portuguese_0_1512" //Portugal- Reduzco el cambio negativo  - 3.2 //
replace all_q42_norm =. if id_alex=="cc_Portuguese_0_1433" //Portugal- Reduzco el cambio negativo  - 3.2 //
replace all_q43_norm =. if id_alex=="cc_Portuguese_0_1433" //Portugal- Reduzco el cambio negativo  - 3.2 //
replace all_q47_norm =. if id_alex=="cc_Portuguese_0_1433" //Portugal- Reduzco el cambio negativo  - 3.2 //
replace cc_q11b_norm =. if id_alex=="cc_Portuguese_0_1512" //Portugal- Reduzco el cambio negativo  - 3.3 //
replace cc_q11b_norm =. if id_alex=="cc_Portuguese_0_674" //Portugal- Reduzco el cambio negativo  - 3.3 //
replace cc_q11b_norm =. if id_alex=="cc_Portuguese_1_629_2022_2023" //Portugal- Reduzco el cambio negativo  - 3.3 //
replace cc_q40a_norm =. if id_alex=="cc_Portuguese_0_1789" //Portugal- Reduzco el cambio negativo  - 3.4 //
replace cc_q40a_norm =. if id_alex=="cc_Portuguese_0_1512" //Portugal- Reduzco el cambio negativo  - 3.4 //
replace lb_q16a_norm =. if id_alex=="lb_Portuguese_0_440" //Portugal- Reduzco el cambio negativo  - 4.1 //
replace lb_q16b_norm =. if id_alex=="lb_Portuguese_0_440" //Portugal- Reduzco el cambio negativo  - 4.1 //
replace lb_q16c_norm =. if id_alex=="lb_Portuguese_0_440" //Portugal- Reduzco el cambio negativo  - 4.1 //
replace lb_q16d_norm =. if id_alex=="lb_Portuguese_0_440" //Portugal- Reduzco el cambio negativo  - 4.1 //
replace lb_q16e_norm =. if id_alex=="lb_Portuguese_0_440" //Portugal- Reduzco el cambio negativo  - 4.1 //
replace lb_q16f_norm =. if id_alex=="lb_Portuguese_0_440" //Portugal- Reduzco el cambio negativo  - 4.1 //
replace cj_q12a_norm =. if id_alex=="cj_Portuguese_1_599" //Portugal- Reduzco el cambio negativo  - 4.1 //
replace cj_q12b_norm =. if id_alex=="cj_Portuguese_1_599" //Portugal- Reduzco el cambio negativo  - 4.1 //
replace cj_q12c_norm =. if id_alex=="cj_Portuguese_1_599" //Portugal- Reduzco el cambio negativo  - 4.1 //
replace cj_q12d_norm =. if id_alex=="cj_Portuguese_1_599" //Portugal- Reduzco el cambio negativo  - 4.1 //
replace cj_q12e_norm =. if id_alex=="cj_Portuguese_1_599" //Portugal- Reduzco el cambio negativo  - 4.1 //
replace cj_q12f_norm =. if id_alex=="cj_Portuguese_1_599" //Portugal- Reduzco el cambio negativo  - 4.1 //
replace cj_q12a_norm =. if id_alex=="cj_Portuguese_0_1340" //Portugal- Reduzco el cambio negativo  - 4.1 //
replace cj_q12b_norm =. if id_alex=="cj_Portuguese_0_1340" //Portugal- Reduzco el cambio negativo  - 4.1 //
replace cj_q12c_norm =. if id_alex=="cj_Portuguese_0_1340" //Portugal- Reduzco el cambio negativo  - 4.1 //
replace cj_q12d_norm =. if id_alex=="cj_Portuguese_0_1340" //Portugal- Reduzco el cambio negativo  - 4.1 //
replace cj_q12e_norm =. if id_alex=="cj_Portuguese_0_1340" //Portugal- Reduzco el cambio negativo  - 4.1 //
replace cj_q12f_norm =. if id_alex=="cj_Portuguese_0_1340" //Portugal- Reduzco el cambio negativo  - 4.1 //
replace cj_q10_norm =. if id_alex=="cj_Portuguese_0_1212" //Portugal- Reduzco el cambio negativo  - 4.2 //
replace all_q31_norm =. if id_alex=="cj_Portuguese_0_1304" //Portugal- Reduzco el cambio negativo  - 4.7 //
replace all_q31_norm =. if id_alex=="cj_Portuguese_0_855" //Portugal- Reduzco el cambio negativo  - 4.7 //
replace all_q48_norm =. if id_alex=="cc_English_0_1256" //Portugal- Reduzco el cambio positivo  - 6.4 //
replace all_q49_norm =. if id_alex=="cc_English_0_1256" //Portugal- Reduzco el cambio positivo  - 6.4 //
replace all_q50_norm =. if id_alex=="cc_English_0_1256" //Portugal- Reduzco el cambio positivo  - 6.4 //
replace all_q48_norm =. if id_alex=="lb_English_0_105" //Portugal- Reduzco el cambio positivo  - 6.4 //
replace all_q49_norm =. if id_alex=="lb_English_0_105" //Portugal- Reduzco el cambio positivo  - 6.4 //
replace all_q50_norm =. if id_alex=="lb_English_0_105" //Portugal- Reduzco el cambio positivo  - 6.4 //
replace lb_q19a_norm =. if id_alex=="lb_English_0_105" //Portugal- Reduzco el cambio positivo  - 6.4 //
replace cc_q10_norm =. if id_alex=="cc_Portuguese_0_1512" //Portugal- Reduzco el cambio negativo - 6.5 //
replace cc_q16a_norm =. if id_alex=="cc_Portuguese_0_1512" //Portugal- Reduzco el cambio negativo - 6.5 //
replace cc_q10_norm =. if id_alex=="cc_Portuguese_0_973" //Portugal- Reduzco el cambio negativo - 6.5 //
replace cc_q16a_norm =. if id_alex=="cc_Portuguese_0_973" //Portugal- Reduzco el cambio negativo - 6.5 //
replace all_q76_norm =. if id_alex=="cc_Portuguese_0_902" //Portugal- Reduzco el cambio negativo - 7.2 //
replace all_q77_norm =. if id_alex=="cc_Portuguese_0_902" //Portugal- Reduzco el cambio negativo - 7.2 //
replace all_q78_norm =. if id_alex=="cc_Portuguese_0_902" //Portugal- Reduzco el cambio negativo - 7.2 //
replace all_q79_norm =. if id_alex=="cc_Portuguese_0_902" //Portugal- Reduzco el cambio negativo - 7.2 //
replace all_q80_norm =. if id_alex=="cc_Portuguese_0_902" //Portugal- Reduzco el cambio negativo - 7.2 //
replace all_q81_norm =. if id_alex=="cc_Portuguese_0_902" //Portugal- Reduzco el cambio negativo - 7.2 //
replace all_q3_norm =. if id_alex=="cj_English_0_384" //Portugal- Reduzco el cambio negativo - 7.4 //
replace all_q84_norm =. if id_alex=="cc_Portuguese_0_1512" //Portugal- Reduzco el cambio negativo - 7.5 //
replace all_q85_norm =. if id_alex=="cc_Portuguese_0_1512" //Portugal- Reduzco el cambio negativo - 7.5 //
replace all_q84_norm =. if id_alex=="cc_Portuguese_0_674" //Portugal- Reduzco el cambio negativo - 7.5 //
replace all_q85_norm =. if id_alex=="cc_Portuguese_1_399" //Portugal- Reduzco el cambio negativo - 7.5 //
replace all_q88_norm =. if id_alex=="cc_Portuguese_0_902" //Portugal- Reduzco el cambio negativo - 7.5 //
replace all_q88_norm =. if id_alex=="cc_Portuguese_0_1512" //Portugal- Reduzco el cambio negativo - 7.5 //
replace cc_q26a_norm =. if id_alex=="cc_English_0_1360" //Portugal- Reduzco el cambio negativo - 7.5 //
replace cc_q26a_norm =. if id_alex=="cc_English_0_1659" //Portugal- Reduzco el cambio negativo - 7.5 //
replace cc_q26a_norm =. if id_alex=="cc_Portuguese_0_723_2022_2023" //Portugal- Reduzco el cambio negativo - 7.5 //
replace cc_q26a_norm =. if id_alex=="cc_Portuguese_1_629_2022_2023" //Portugal- Reduzco el cambio negativo - 7.5 //
replace cc_q26a_norm =. if id_alex=="cc_Portuguese_1_527_2023" //Portugal- Reduzco el cambio negativo - 7.5 //

*Romania
drop if id_alex=="cc_English_0_1239" //Romania (muy negativo)
drop if id_alex=="cc_English_0_1441" //Romania (muy negativo)
drop if id_alex=="cc_English_0_1176" //Romania (muy negativo)
drop if id_alex=="cc_English_0_279" //Romania (muy negativo)
drop if id_alex=="cc_English_0_1963" //Romania (muy negativo)
drop if id_alex=="cc_English_0_1203" //Romania (muy negativo)
drop if id_alex=="cj_English_0_199" //Romania (muy negativo)
drop if id_alex=="cj_English_0_226" //Romania (muy negativo)
drop if id_alex=="cj_English_0_1349" //Romania (muy negativo)
drop if id_alex=="lb_English_0_243" //Romania (muy negativo)
drop if id_alex=="lb_English_0_219" //Romania (muy negativo)
drop if id_alex=="cc_English_0_1955" //Romania (muy negativo)
drop if id_alex=="cc_English_0_744" //Romania (muy negativo)
drop if id_alex=="cc_English_1_438" //Romania (muy negativo)
drop if id_alex=="cj_Spanish_0_664_2023" //Romania (muy negativo)
drop if id_alex=="cc_English_0_1239" //Romania (muy negativo)
drop if id_alex=="cc_English_0_402" //Romania (muy negativo)
replace cj_q9_norm =. if id_alex=="cj_English_0_321" //Romania- Reduzco el cambio negativo  - 1.5 //
replace cj_q9_norm =. if id_alex=="cj_English_0_198" //Romania- Reduzco el cambio negativo  - 1.5 //
replace cj_q9_norm =1 if id_alex=="cj_English_0_234" //Romania- Reduzco el cambio negativo  - 1.5 //
replace all_q10_norm =. if id_alex=="cj_English_0_198" //Romania- Reduzco el cambio negativo  - 1.5 //
replace all_q11_norm =. if id_alex=="cj_English_0_198" //Romania- Reduzco el cambio negativo  - 1.5 //
replace all_q12_norm =. if id_alex=="cj_English_0_198" //Romania- Reduzco el cambio negativo  - 1.5 //
replace all_q10_norm =. if id_alex=="cj_French_0_398" //Romania- Reduzco el cambio negativo  - 1.5 //
replace all_q11_norm =. if id_alex=="cj_French_0_398" //Romania- Reduzco el cambio negativo  - 1.5 //
replace all_q12_norm =. if id_alex=="cj_French_0_398" //Romania- Reduzco el cambio negativo  - 1.5 //
replace all_q96_norm =. if id_alex=="cj_English_1_602" //Romania- Reduzco el cambio negativo  - 2.4 //
replace all_q96_norm =. if id_alex=="cj_English_0_198" //Romania- Reduzco el cambio negativo  - 2.4 //
replace all_q96_norm =. if id_alex=="cj_English_0_230" //Romania- Reduzco el cambio negativo  - 2.4 //
replace all_q96_norm =. if id_alex=="cj_English_0_610" //Romania- Reduzco el cambio negativo  - 2.4 //
replace all_q96_norm =. if id_alex=="cc_English_0_1167_2023" //Romania- Reduzco el cambio negativo  - 2.4 //
replace cc_q10_norm =. if id_alex=="cc_English_0_590" //Romania- Reduzco el cambio negativo  - 6.5 //
replace cc_q11a_norm =. if id_alex=="cc_English_0_590" //Romania- Reduzco el cambio negativo  - 6.5 //
replace cc_q16a_norm =. if id_alex=="cc_English_0_590" //Romania- Reduzco el cambio negativo  - 6.5 //
replace cc_q10_norm =. if id_alex=="cc_English_0_1784" //Romania- Reduzco el cambio negativo  - 6.5 //
replace cc_q16a_norm =. if id_alex=="cc_English_0_1784" //Romania- Reduzco el cambio negativo  - 6.5 //
replace cc_q14a_norm =. if id_alex=="cc_English_0_945" //Romania- Reduzco el cambio negativo  - 6.5 //
replace cc_q14b_norm =. if id_alex=="cc_English_0_945" //Romania- Reduzco el cambio negativo  - 6.5 //
replace cc_q16b_norm =. if id_alex=="cc_English_0_945" //Romania- Reduzco el cambio negativo  - 6.5 //
replace cc_q16c_norm =. if id_alex=="cc_English_0_945" //Romania- Reduzco el cambio negativo  - 6.5 //
replace cc_q16d_norm =. if id_alex=="cc_English_0_945" //Romania- Reduzco el cambio negativo  - 6.5 //
replace cc_q14a_norm =. if id_alex=="cc_English_0_734" //Romania- Reduzco el cambio negativo  - 6.5 //
replace cc_q14b_norm =. if id_alex=="cc_English_0_734" //Romania- Reduzco el cambio negativo  - 6.5 //
replace cc_q16b_norm =. if id_alex=="cc_English_0_734" //Romania- Reduzco el cambio negativo  - 6.5 //
replace cc_q16c_norm =. if id_alex=="cc_English_0_734" //Romania- Reduzco el cambio negativo  - 6.5 //
replace cc_q16d_norm =. if id_alex=="cc_English_0_734" //Romania- Reduzco el cambio negativo  - 6.5 //
replace cc_q16b_norm =. if id_alex=="cc_English_0_465" //Romania- Reduzco el cambio negativo  - 6.5 //
replace cc_q16d_norm =. if id_alex=="cc_English_0_465" //Romania- Reduzco el cambio negativo  - 6.5 //
replace cc_q16a_norm =. if id_alex=="cc_English_0_600" //Romania- Reduzco el cambio negativo  - 6.5 //
replace cc_q16a_norm =. if id_alex=="cc_English_0_945" //Romania- Reduzco el cambio negativo  - 6.5 //
replace cc_q16a_norm =. if id_alex=="cc_English_0_1432" //Romania- Reduzco el cambio negativo  - 6.5 //
replace cc_q16a_norm =. if id_alex=="cc_English_0_388" //Romania- Reduzco el cambio negativo  - 6.5 //
replace cc_q16a_norm =. if id_alex=="cc_English_0_1267" //Romania- Reduzco el cambio negativo  - 6.5 //
replace cc_q10_norm =. if id_alex=="cc_English_0_1142" //Romania- Reduzco el cambio negativo  - 6.5 //
replace cc_q10_norm =. if id_alex=="cc_English_0_600" //Romania- Reduzco el cambio negativo  - 6.5 //
replace cc_q11a_norm =. if id_alex=="cc_English_0_1142" //Romania- Reduzco el cambio negativo  - 6.5 //
replace all_q76_norm =. if id_alex=="lb_English_0_604" //Romania- Reduzco el cambio negativo  - 7.2 //
replace all_q77_norm =. if id_alex=="lb_English_0_604" //Romania- Reduzco el cambio negativo  - 7.2 //
replace all_q78_norm =. if id_alex=="lb_English_0_604" //Romania- Reduzco el cambio negativo  - 7.2 //
replace all_q79_norm =. if id_alex=="lb_English_0_604" //Romania- Reduzco el cambio negativo  - 7.2 //
replace all_q80_norm =. if id_alex=="lb_English_0_604" //Romania- Reduzco el cambio negativo  - 7.2 //
replace all_q81_norm =. if id_alex=="lb_English_0_604" //Romania- Reduzco el cambio negativo  - 7.2 //
replace all_q76_norm =. if id_alex=="lb_English_0_302_2023" //Romania- Reduzco el cambio negativo  - 7.2 //
replace all_q77_norm =. if id_alex=="lb_English_1_542" //Romania- Reduzco el cambio negativo  - 7.2 //
replace all_q78_norm =. if id_alex=="lb_English_1_542" //Romania- Reduzco el cambio negativo  - 7.2 //
replace all_q79_norm =. if id_alex=="lb_English_1_542" //Romania- Reduzco el cambio negativo  - 7.2 //
replace all_q80_norm =. if id_alex=="lb_English_1_542" //Romania- Reduzco el cambio negativo  - 7.2 //
replace all_q81_norm =. if id_alex=="lb_English_1_542" //Romania- Reduzco el cambio negativo  - 7.2 //
replace all_q6_norm =. if id_alex=="cc_English_0_480" //Romania- Reduzco el cambio negativo  - 7.4 //
replace all_q6_norm =. if id_alex=="cc_English_0_1128" //Romania- Reduzco el cambio negativo  - 7.4 //
replace cc_q11a_norm =. if id_alex=="cc_English_0_590" //Romania- Reduzco el cambio negativo  - 7.4 //
replace cc_q11a_norm =. if id_alex=="cc_English_0_1393" //Romania- Reduzco el cambio negativo  - 7.4 //
replace all_q4_norm =. if id_alex=="cj_English_0_198" //Romania- Reduzco el cambio negativo  - 7.4 //
replace all_q4_norm =. if id_alex=="cj_English_0_230" //Romania- Reduzco el cambio negativo  - 7.4 //
replace all_q4_norm =. if id_alex=="cj_English_1_910" //Romania- Reduzco el cambio negativo  - 7.4 //
replace all_q7_norm =. if id_alex=="cj_English_0_198" //Romania- Reduzco el cambio negativo  - 7.4 //
replace all_q7_norm =. if id_alex=="cj_English_0_230" //Romania- Reduzco el cambio negativo  - 7.4 //
replace all_q7_norm =. if id_alex=="cj_English_1_910" //Romania- Reduzco el cambio negativo  - 7.4 //
replace all_q84_norm =. if id_alex=="cc_English_0_1277" //Romania- Reduzco el cambio negativo  - 7.5 //
replace all_q84_norm =. if id_alex=="cc_English_0_686" //Romania- Reduzco el cambio negativo  - 7.5 //
replace all_q84_norm =. if id_alex=="cc_English_0_323" //Romania- Reduzco el cambio negativo  - 7.5 //
replace all_q84_norm =. if id_alex=="cc_English_0_945" //Romania- Reduzco el cambio negativo  - 7.5 //
replace all_q85_norm =. if id_alex=="cc_English_0_945" //Romania- Reduzco el cambio negativo  - 7.5 //
replace all_q85_norm =. if id_alex=="cc_English_0_323" //Romania- Reduzco el cambio negativo  - 7.5 //
replace all_q88_norm =. if id_alex=="cc_English_0_1277" //Romania- Reduzco el cambio negativo  - 7.5 //
*replace all_q88_norm =. if id_alex=="cc_English_0_402" //Romania- Reduzco el cambio negativo  - 7.5 //
replace all_q88_norm =. if id_alex=="cc_English_0_451" //Romania- Reduzco el cambio negativo  - 7.5 //
replace all_q88_norm =. if id_alex=="cc_English_0_452" //Romania- Reduzco el cambio negativo  - 7.5 //
replace all_q88_norm =. if id_alex=="cc_English_0_1393" //Romania- Reduzco el cambio negativo  - 7.5 //
replace cc_q26a_norm =. if id_alex=="cc_English_0_1277" //Romania- Reduzco el cambio negativo  - 7.5 //
*replace cc_q26a_norm =. if id_alex=="cc_English_0_402" //Romania- Reduzco el cambio negativo  - 7.5 //
replace cc_q26a_norm =. if id_alex=="cc_English_0_451" //Romania- Reduzco el cambio negativo  - 7.5 //
replace cc_q26a_norm =. if id_alex=="cc_English_0_452" //Romania- Reduzco el cambio negativo  - 7.5 //
replace cc_q26a_norm =. if id_alex=="cc_English_0_1393" //Romania- Reduzco el cambio negativo  - 7.5 //
replace cj_q21a_norm =. if id_alex=="cj_English_0_538" //Romania- Reduzco el cambio positivo  - 8.3 //
replace cj_q21g_norm =. if id_alex=="cj_English_0_538" //Romania- Reduzco el cambio positivo  - 8.3 //
replace cj_q28_norm =. if id_alex=="cj_English_0_538" //Romania- Reduzco el cambio positivo  - 8.3 //
replace cj_q21a_norm =. if id_alex=="cj_English_0_456" //Romania- Reduzco el cambio positivo  - 8.3 //
replace cj_q21g_norm =. if id_alex=="cj_English_0_456" //Romania- Reduzco el cambio positivo  - 8.3 //
replace cj_q21g_norm =. if id_alex=="cj_English_0_230" //Romania- Reduzco el cambio positivo  - 8.3 //
replace cj_q21g_norm =. if id_alex=="cj_English_0_412" //Romania- Reduzco el cambio positivo  - 8.3 //
replace cj_q28_norm =. if id_alex=="cj_English_0_631" //Romania- Reduzco el cambio positivo  - 8.3 //
replace cj_q21g_norm =. if id_alex=="cj_English_1_827_2023" //Romania- Reduzco el cambio positivo  - 8.3 //
replace cj_q28_norm =0 if id_alex=="cj_English_0_392" //Romania- Reduzco el cambio positivo  - 8.3 //
replace cj_q21e_norm =. if id_alex=="cj_English_0_1247" //Romania- Reduzco el cambio positivo  - 8.3 //
replace cj_q21e_norm =. if id_alex=="cj_English_0_511" //Romania- Reduzco el cambio positivo  - 8.3 //
replace cj_q28_norm =0 if id_alex=="cj_English_0_286" //Romania- Reduzco el cambio positivo  - 8.3 //
replace cj_q28_norm =. if id_alex=="cj_English_0_328" //Romania- Reduzco el cambio positivo  - 8.3 //
replace cj_q21a_norm =. if id_alex=="cj_English_0_304" //Romania- Reduzco el cambio positivo  - 8.3 //
replace cj_q21a_norm =. if id_alex=="cj_English_0_427" //Romania- Reduzco el cambio positivo  - 8.3 //
replace cj_q20m_norm =. if id_alex=="cj_English_0_198" //Romania- Reduzco el cambio negativo  - 8.6 //
replace cj_q20m_norm =. if id_alex=="cj_English_0_230" //Romania- Reduzco el cambio negativo  - 8.6 //
replace cj_q20m_norm =. if id_alex=="cj_English_1_910" //Romania- Reduzco el cambio negativo  - 8.6 //
replace cj_q20m_norm =. if id_alex=="cj_English_0_392" //Romania- Reduzco el cambio negativo  - 8.6 //
replace cj_q20m_norm =. if id_alex=="cj_English_0_412" //Romania- Reduzco el cambio negativo  - 8.6 //
replace cj_q40c_norm =. if id_alex=="cj_English_0_198" //Romania- Reduzco el cambio negativo  - 8.6 //
replace cj_q40c_norm =. if id_alex=="cj_English_0_230" //Romania- Reduzco el cambio negativo  - 8.6 //
replace cj_q40b_norm =. if id_alex=="cj_English_0_198" //Romania- Reduzco el cambio negativo  - 8.6 //
replace cj_q40b_norm =. if id_alex=="cj_English_0_230" //Romania- Reduzco el cambio negativo  - 8.6 //

*Russia
drop if id_alex=="cc_English_0_1615" //Russia (muy positivo)
drop if id_alex=="cc_Russian_0_851" //Russia (muy positivo)
drop if id_alex=="cj_English_1_380" //Russia (muy positivo)
replace cj_q11b_norm=. if country=="Russian Federation" // Russia (se elimino el anio pasado)
replace cj_q42d_norm=. if country=="Russian Federation" // Russia (se elimino el anio pasado)
replace lb_q3d_norm =. if id_alex=="lb_Russian_0_351" //Russia- Reduzco el cambio positivo  - 6.3 //

*Rwanda
drop if id_alex=="cc_English_1_1008" //Rwanda (muy positivo)
drop if id_alex=="cc_English_1_437" //Rwanda (muy positivo)
drop if id_alex=="cj_English_0_314" //Rwanda (muy positivo)
drop if id_alex=="lb_English_1_755_2021_2022_2023" //Rwanda (muy positivo) (Q)
drop if id_alex=="lb_English_0_374_2019_2021_2022_2023" //Rwanda (muy positivo)
replace cc_q33_norm=. if country=="Rwanda" // Rwanda (se elimino el anio pasado)
replace all_q54_norm=. if country=="Rwanda" // Rwanda (se elimino el anio pasado)
replace ph_q6a_norm=. if country=="Rwanda" // Rwanda (se elimino el anio pasado)
replace ph_q6b_norm=. if country=="Rwanda" // Rwanda (se elimino el anio pasado)
replace ph_q6c_norm=. if country=="Rwanda" // Rwanda (se elimino el anio pasado)
replace ph_q6d_norm=. if country=="Rwanda" // Rwanda (se elimino el anio pasado)
replace ph_q6e_norm=. if country=="Rwanda" // Rwanda (se elimino el anio pasado)
replace ph_q6f_norm=. if country=="Rwanda" // Rwanda (se elimino el anio pasado)
replace all_q78_norm=. if country=="Rwanda" // Rwanda (se elimino el anio pasado)
replace all_q79_norm=. if country=="Rwanda" // Rwanda (se elimino el anio pasado)
replace all_q29_norm=. if country=="Rwanda" // Rwanda (se elimino el anio pasado)
replace cc_q26a_norm=. if country=="Rwanda" // Rwanda (se elimino el anio pasado)
replace cj_q38_norm =. if id_alex=="cj_French_0_585" //Rwanda- Reduzco el cambio positivo - 1.4 //
replace all_q9_norm =. if id_alex=="cj_English_0_479_2023" //Rwanda- Reduzco el cambio positivo - 1.4 //
replace all_q58_norm =.6666667 if id_alex=="lb_English_0_229" //Rwanda- Reduzco el cambio positivo (pocas observaciones y sin variacion) - 2.2 //
replace all_q59_norm =.6666667 if id_alex=="lb_English_0_229" //Rwanda- Reduzco el cambio positivo (pocas observaciones y sin variacion) - 2.2 //
replace lb_q6c_norm =.6666667 if id_alex=="lb_English_0_229" //Rwanda- Reduzco el cambio positivo (pocas observaciones y sin variacion) - 2.2 //
replace all_q58_norm =.6666667 if id_alex=="lb_English_1_740_2022_2023" //Rwanda- Reduzco el cambio positivo (pocas observaciones y sin variacion) - 2.2 //
replace all_q59_norm =.6666667 if id_alex=="lb_English_1_740_2022_2023" //Rwanda- Reduzco el cambio positivo (pocas observaciones y sin variacion) - 2.2 //
replace lb_q6c_norm =.6666667 if id_alex=="lb_English_1_740_2022_2023" //Rwanda- Reduzco el cambio positivo (pocas observaciones y sin variacion) - 2.2 //
replace all_q58_norm =. if id_alex=="cc_English_0_498_2023" //Rwanda- Reduzco el cambio positivo (pocas observaciones y sin variacion) - 2.2 //
replace all_q59_norm =. if id_alex=="cc_English_0_498_2023" //Rwanda- Reduzco el cambio positivo (pocas observaciones y sin variacion) - 2.2 //
replace all_q58_norm =.6666667 if id_alex=="cc_English_0_498_2023" //Rwanda- Reduzco el cambio positivo (pocas observaciones y sin variacion) - 2.2 //
replace all_q59_norm =.6666667 if id_alex=="cc_English_0_498_2023" //Rwanda- Reduzco el cambio positivo (pocas observaciones y sin variacion) - 2.2 //
replace lb_q6c_norm =0 if id_alex=="lb_English_0_143_2022_2023" //Rwanda- Reduzco el cambio positivo (pocas observaciones y sin variacion) - 2.2 //
replace all_q59_norm =.6666667 if id_alex=="cc_English_0_1678_2022_2023" //Rwanda- Reduzco el cambio positivo (pocas observaciones y sin variacion) - 2.2 //
replace cc_q39b_norm =. if id_alex=="cc_English_1_1149" //Rwanda- Reduzco el cambio negativo - 3.2 //
replace cc_q39c_norm =. if id_alex=="cc_English_1_1149" //Rwanda- Reduzco el cambio negativo - 3.2 //
replace cc_q39d_norm =. if id_alex=="cc_English_0_1935_2018_2019_2021_2022_2023" //Rwanda- Reduzco el cambio negativo  - 3.2 //
replace all_q42_norm =. if id_alex=="cc_French_1_984_2019_2021_2022_2023" //Rwanda- Reduzco el cambio negativo  - 3.2 //
replace all_q43_norm =. if id_alex=="cc_French_1_984_2019_2021_2022_2023" //Rwanda- Reduzco el cambio negativo  - 3.2 //
replace all_q47_norm =. if id_alex=="cc_French_1_984_2019_2021_2022_2023" //Rwanda- Reduzco el cambio negativo  - 3.2 //
replace all_q42_norm =. if id_alex=="lb_English_0_229" //Rwanda- Reduzco el cambio negativo  - 3.2 //
replace all_q43_norm =. if id_alex=="lb_English_0_229" //Rwanda- Reduzco el cambio negativo  - 3.2 //
replace all_q47_norm =. if id_alex=="lb_English_0_229" //Rwanda- Reduzco el cambio negativo  - 3.2 //
replace cc_q39d_norm =. if id_alex=="cc_French_1_984_2019_2021_2022_2023" //Rwanda- Reduzco el cambio negativo  - 3.2 //
replace cc_q9c_norm =.6666667 if id_alex=="cc_English_0_498_2023" //Rwanda- Reduzco el cambio negativo  - 3.4 //
replace lb_q16f_norm =0 if id_alex=="lb_English_0_229" //Rwanda - 4.1 (solo hay un experto, y pasaria de 0 a 1) //
replace cj_q10_norm =. if id_alex=="cj_English_0_306" //Rwanda - 4.2 Reduzco el cambio positivo //
replace cj_q11b_norm =. if id_alex=="cj_English_0_306" //Rwanda - 4.2 Reduzco el cambio positivo //
replace cj_q31e_norm =. if id_alex=="cj_English_0_306" //Rwanda - 4.2 Reduzco el cambio positivo //
replace cj_q11a_norm =. if id_alex=="cj_English_1_702_2023" //Rwanda - 4.2 Reduzco el cambio positivo //
replace cj_q42d_norm =. if id_alex=="cj_English_1_702_2023" //Rwanda - 4.2 Reduzco el cambio positivo //
replace cj_q10_norm =. if id_alex=="cj_French_0_69_2019_2021_2022_2023" //Rwanda - 4.2 Reduzco el cambio positivo //
replace all_q13_norm =. if id_alex=="cj_English_0_306" //Rwanda - 4.4 Reduzco el cambio positivo //
replace all_q14_norm =. if id_alex=="cj_English_0_306" //Rwanda - 4.4 Reduzco el cambio positivo //
replace all_q15_norm =. if id_alex=="cj_English_0_306" //Rwanda - 4.4 Reduzco el cambio positivo //
replace all_q16_norm =. if id_alex=="cj_English_0_306" //Rwanda - 4.4 Reduzco el cambio positivo //
replace all_q17_norm =. if id_alex=="cj_English_0_306" //Rwanda - 4.4 Reduzco el cambio positivo //
replace all_q18_norm =. if id_alex=="cj_English_0_306" //Rwanda - 4.4 Reduzco el cambio positivo //
replace all_q94_norm =. if id_alex=="cj_English_1_702_2023" //Rwanda - 4.4 Reduzco el cambio positivo //
replace all_q19_norm =. if id_alex=="cj_English_0_306" //Rwanda - 4.4 Reduzco el cambio positivo //
replace all_q20_norm =. if id_alex=="lb_English_1_740_2022_2023" //Rwanda - 4.4 Reduzco el cambio positivo //
replace all_q21_norm =. if id_alex=="lb_English_0_143_2022_2023" //Rwanda - 4.4 Reduzco el cambio positivo //
replace all_q13_norm =. if id_alex=="lb_English_0_143_2022_2023" //Rwanda - 4.4 Reduzco el cambio positivo //
replace all_q31_norm =. if id_alex=="cj_English_0_1118_2018_2019_2021_2022_2023" //Rwanda - 4.7 Reduzco el cambio positivo //
replace all_q32_norm =. if id_alex=="cc_English_0_498_2023" //Rwanda - 4.7 Reduzco el cambio positivo //
replace all_q32_norm =. if id_alex=="cc_English_1_1149" //Rwanda - 4.7 Reduzco el cambio positivo //
replace all_q14_norm =. if id_alex=="cc_English_0_1935_2018_2019_2021_2022_2023" //Rwanda - 4.7 Reduzco el cambio positivo //
replace lb_q17e_norm =.6666667 if id_alex=="lb_English_0_229" //Rwanda - 6.2  //
replace all_q55_norm =. if id_alex=="cc_French_0_998_2021_2022_2023" //Rwanda - 6.2  //
replace all_q55_norm =. if id_alex=="cc_English_0_498_2023" //Rwanda - 6.2  //
replace all_q76_norm =0 if id_alex=="cc_English_0_1678_2022_2023" //Rwanda - Reduzco el cambio positivo (es muy positivo) 7.2  //
replace all_q77_norm =0 if id_alex=="cc_English_0_1678_2022_2023" //Rwanda - Reduzco el cambio positivo (es muy positivo) 7.2  //
replace all_q80_norm =0 if id_alex=="cc_English_0_1678_2022_2023" //Rwanda - Reduzco el cambio positivo (es muy positivo) 7.2  //
replace all_q81_norm =0 if id_alex=="cc_English_0_1678_2022_2023" //Rwanda - Reduzco el cambio positivo (es muy positivo) 7.2  //
replace all_q82_norm =0 if id_alex=="cc_English_0_1678_2022_2023" //Rwanda - Reduzco el cambio positivo (es muy positivo) 7.2  //
replace lb_q6c_norm =. if id_alex=="lb_English_1_516" //Rwanda - Reduzco el cambio positivo (es muy positivo) 7.3  //
replace all_q51_norm =. if id_alex=="cc_English_0_498_2023" //Rwanda - Reduzco el cambio positivo (es muy positivo) 7.3  //
replace all_q28_norm =. if id_alex=="cc_English_0_1678_2022_2023" //Rwanda - Reduzco el cambio positivo (es muy positivo) 7.3  //
replace all_q57_norm =. if id_alex=="lb_English_1_516" //Rwanda - Reduzco el cambio positivo (es muy positivo) 7.3  //
replace all_q58_norm =. if id_alex=="lb_English_1_516" //Rwanda - Reduzco el cambio positivo (es muy positivo) 7.3  //
replace all_q59_norm =. if id_alex=="lb_English_1_516" //Rwanda - Reduzco el cambio positivo (es muy positivo) 7.3  //
replace cj_q40b_norm =. if id_alex=="cj_English_0_306" //Rwanda - 8.6 Reduzco el cambio positivo //
replace cj_q40c_norm =. if id_alex=="cj_English_0_306" //Rwanda - 8.6 Reduzco el cambio positivo //

*Senegal
drop if id_alex=="cj_French_1_367" //Senegal (muy positivo)
drop if id_alex=="cj_English_1_173" //Senegal (muy positivo)
replace all_q20_norm =. if id_alex=="cj_French_0_768_2023" //Senegal- Ajusto porque no muestra cambio (contradice long) - 1.2 //
replace all_q2_norm =. if id_alex=="cc_French_1_439_2022_2023" //Senegal- Ajusto porque no muestra cambio (contradice long) - 1.2 //
replace all_q20_norm =. if id_alex=="lb_English_0_513" //Senegal- Ajusto porque no muestra cambio (contradice long) - 1.2 //
replace all_q21_norm =. if id_alex=="lb_English_0_513" //Senegal- Ajusto porque no muestra cambio (contradice long) - 1.2 //
replace all_q19_norm =. if id_alex=="cj_French_0_274" //Senegal- Ajusto porque no muestra cambio (contradice long) - 1.6 //
replace all_q19_norm =. if id_alex=="cj_French_0_423" //Senegal- Ajusto porque no muestra cambio (contradice long) - 1.6 //
replace all_q29_norm =. if id_alex=="cj_French_0_274" //Senegal- Reduzco el cambio positivo - 4.5 //
replace all_q30_norm =. if id_alex=="cj_French_0_274" //Senegal- Reduzco el cambio positivo - 4.5 //
replace all_q29_norm =. if id_alex=="cj_French_0_423" //Senegal- Reduzco el cambio positivo - 4.5 //
replace all_q30_norm =. if id_alex=="cj_French_0_423" //Senegal- Reduzco el cambio positivo - 4.5 //

*Serbia
drop if id_alex=="cc_English_1_1530_2021_2022_2023" //Serbia (muy positivo)
drop if id_alex=="lb_English_1_46" //Serbia (muy positivo)
replace all_q22_norm =. if id_alex=="lb_English_1_590_2021_2022_2023" //Serbia- Reduzco el cambio negativo - 1.7 //
replace all_q23_norm =. if id_alex=="lb_English_1_590_2021_2022_2023" //Serbia- Reduzco el cambio negativo - 1.7 //
replace all_q24_norm =. if id_alex=="lb_English_1_590_2021_2022_2023" //Serbia - Reduzco el cambio negativo - 1.7 //
replace all_q25_norm =. if id_alex=="lb_English_1_590_2021_2022_2023" //Serbia- Reduzco el cambio negativo - 1.7 //
replace all_q26_norm =. if id_alex=="lb_English_1_590_2021_2022_2023" //Serbia- Reduzco el cambio negativo - 1.7 //
replace all_q27_norm =. if id_alex=="lb_English_1_590_2021_2022_2023" //Serbia- Reduzco el cambio negativo - 1.7 //
replace all_q8_norm =. if id_alex=="lb_English_1_590_2021_2022_2023" //Serbia- Reduzco el cambio negativo - 1.7 //
replace cc_q40b_norm =. if id_alex=="cc_English_1_862" //Serbia- Ajusto porque no muestra cambio (contradice long) - 3.4 //
replace cc_q40b_norm =. if id_alex=="cc_English_0_117" //Serbia- Ajusto porque no muestra cambio (contradice long) - 3.4 //
replace all_q19_norm =. if id_alex=="cc_English_1_710_2017_2018_2019_2021_2022_2023" //Serbia- Ajusto porque no muestra cambio (contradice long) - 4.7 //
replace all_q31_norm =. if id_alex=="cc_English_1_710_2017_2018_2019_2021_2022_2023" //Serbia- Ajusto porque no muestra cambio (contradice long) - 4.7 //
replace cj_q40b_norm =. if id_alex=="cj_English_0_1130" //Serbia- Reduzco el cambio positivo - 8.6 //
replace cj_q40c_norm =. if id_alex=="cj_English_0_1130" //Serbia- Reduzco el cambio positivo - 8.6 //
replace cj_q20m_norm =. if id_alex=="cj_English_0_1130" //Serbia- Reduzco el cambio positivo - 8.6 //

*Sierra Leone
drop if id_alex=="cc_English_0_683_2019_2021_2022_2023" //Sierra Leone (muy negativo)
drop if id_alex=="cj_English_0_772" //Sierra Leone (muy negativo)
replace cj_q21h_norm=. if country=="Sierra Leone" // Sierra Leone (se elimino el anio pasado)
replace all_q49_norm =. if id_alex=="cc_English_0_1596" //Sierra Leone- Reduzco el cambio negativo - 6.4 //
replace cc_q16b_norm =. if id_alex=="cc_English_1_213_2021_2022_2023" //Sierra Leone- Reduzco el cambio negativo - 6.5 //
replace cc_q16d_norm =. if id_alex=="cc_English_1_213_2021_2022_2023" //Sierra Leone- Reduzco el cambio negativo - 6.5 //
replace cc_q16d_norm =. if id_alex=="cc_English_0_1657_2019_2021_2022_2023" //Sierra Leone- Reduzco el cambio negativo - 6.5 //
replace cc_q10_norm =. if id_alex=="cc_English_1_213_2021_2022_2023" //Sierra Leone- Reduzco el cambio negativo - 6.5 //
replace cc_q11a_norm =. if id_alex=="cc_English_1_213_2021_2022_2023" //Sierra Leone- Reduzco el cambio negativo - 6.5 //
replace cj_q16e_norm =. if id_alex=="cj_English_0_858" //Sierra Leone- Reduzco el cambio positivo - 8.1 //
replace cj_q27a_norm =. if id_alex=="cj_English_0_491" //Sierra Leone- Reduzco el cambio positivo - 8.2 //
replace cj_q27b_norm =. if id_alex=="cj_English_0_491" //Sierra Leone- Reduzco el cambio positivo - 8.2 //
replace cj_q27a_norm =. if id_alex=="cj_English_0_858" //Sierra Leone- Reduzco el cambio positivo - 8.2 //
replace cj_q27b_norm =. if id_alex=="cj_English_0_858" //Sierra Leone- Reduzco el cambio positivo - 8.2 //
replace cj_q20e_norm =. if id_alex=="cj_English_0_858" //Sierra Leone- Reduzco el cambio positivo - 8.2 //
replace cj_q22d_norm =. if id_alex=="cj_English_0_491" //Sierra Leone- Reduzco el cambio positivo - 8.7 //

*Singapore
drop if id_alex=="cc_English_0_546" //Singapore (muy positivo)
drop if id_alex=="lb_English_0_74" //Singapore (muy positivo)
drop if id_alex=="cj_English_1_141" //Singapore (muy positivo)
drop if id_alex=="cc_English_0_1456" //Singapore (muy positivo)
replace all_q6_norm=. if country=="Singapore" // Singapore (se elimino el anio pasado)
replace all_q17_norm=. if country=="Singapore" // Singapore (se elimino el anio pasado)
replace cj_q10_norm=. if country=="Singapore" // Singapore (se elimino el anio pasado)
replace cj_q36c_norm =. if id_alex=="cj_English_0_247" //Singapore- Reduzco el cambio negativo - 1.4 //
replace cj_q36c_norm =. if id_alex=="cj_English_0_408" //Singapore- Reduzco el cambio negativo - 1.4 //
replace cj_q36c_norm =. if id_alex=="cj_English_0_414" //Singapore- Reduzco el cambio negativo - 1.4 //
replace cj_q36c_norm =0 if id_alex=="cj_English_1_665" //Singapore- Reduzco el cambio negativo - 1.4 //
replace cj_q36c_norm =0 if id_alex=="cj_English_1_517" //Singapore- Reduzco el cambio negativo - 1.4 //
replace cj_q8_norm =. if id_alex=="cj_English_0_696_2022_2023" //Singapore- Reduzco el cambio negativo - 1.4 //
replace cj_q8_norm =. if id_alex=="cj_English_0_365_2023" //Singapore- Reduzco el cambio negativo - 1.4 //
replace cj_q8_norm =. if id_alex=="cj_English_1_885_2023" //Singapore- Reduzco el cambio negativo - 1.4 //
replace cj_q8_norm =. if id_alex=="cj_English_1_935_2023" //Singapore- Reduzco el cambio negativo - 1.4 //
replace cj_q8_norm =. if id_alex=="cj_English_0_124" //Singapore- Reduzco el cambio negativo - 1.4 //
replace cc_q40a_norm =. if id_alex=="cc_English_0_578_2022_2023" //Singapore- Reduzco el cambio negativo - 3.4 //
replace cc_q40a_norm =. if id_alex=="cc_English_0_477" //Singapore- Reduzco el cambio negativo - 3.4 //
replace cc_q40b_norm =. if id_alex=="cc_English_0_477" //Singapore- Reduzco el cambio negativo - 3.4 //
replace cc_q40a_norm =. if id_alex=="cc_English_1_383_2022_2023" //Singapore- Reduzco el cambio negativo - 3.4 //
replace cc_q40b_norm =. if id_alex=="cc_English_1_383_2022_2023" //Singapore- Reduzco el cambio negativo - 3.4 //
replace all_q48_norm =. if id_alex=="cc_English_0_367_2022_2023" //Singapore- Reduzco el cambio positivo - 6.4 //
replace all_q49_norm =. if id_alex=="cc_English_0_367_2022_2023" //Singapore- Reduzco el cambio positivo - 6.4 //
replace all_q50_norm =. if id_alex=="cc_English_0_367_2022_2023" //Singapore- Reduzco el cambio positivo - 6.4 //
replace all_q3_norm =. if id_alex=="cc_English_0_988_2022_2023" //Singapore- Reduzco el cambio positivo - 7.4 //
replace all_q4_norm =. if id_alex=="cc_English_0_988_2022_2023" //Singapore- Reduzco el cambio positivo - 7.4 //
replace all_q7_norm =. if id_alex=="cc_English_0_988_2022_2023" //Singapore- Reduzco el cambio positivo - 7.4 //
replace all_q3_norm =. if id_alex=="cc_English_0_1172_2022_2023" //Singapore- Reduzco el cambio positivo - 7.4 //
replace all_q4_norm =. if id_alex=="cc_English_0_1172_2022_2023" //Singapore- Reduzco el cambio positivo - 7.4 //
replace all_q7_norm =. if id_alex=="cc_English_0_1172_2022_2023" //Singapore- Reduzco el cambio positivo - 7.4 //
replace cj_q20o_norm =. if id_alex=="cj_English_0_696_2022_2023" //Singapore- Reduzco el cambio positivo - 8.4 //
replace cj_q20o_norm =. if id_alex=="cj_English_1_885_2023" //Singapore- Reduzco el cambio positivo - 8.4 //
replace cj_q20o_norm =. if id_alex=="cj_English_1_106" //Singapore- Reduzco el cambio positivo - 8.4 //
replace cj_q20o_norm =. if id_alex=="cj_English_1_793_2023" //Singapore- Reduzco el cambio positivo - 8.4 //
replace cj_q20o_norm =. if id_alex=="cj_English_1_1067_2023" //Singapore- Reduzco el cambio positivo - 8.4 //
replace cj_q12f_norm =. if id_alex=="cj_English_0_696_2022_2023" //Singapore- Reduzco el cambio positivo - 8.4 //
replace cj_q40b_norm =. if id_alex=="cj_English_1_1067_2023" //Singapore- Reduzco el cambio positivo - 8.4 //
replace cj_q40c_norm =. if id_alex=="cj_English_1_1067_2023" //Singapore- Reduzco el cambio positivo - 8.4 //
replace cj_q20m_norm =. if id_alex=="cj_English_1_1067_2023" //Singapore- Reduzco el cambio positivo - 8.4 //
replace cj_q40b_norm =. if id_alex=="cj_English_1_935_2023" //Singapore- Reduzco el cambio positivo - 8.4 //
replace cj_q40c_norm =. if id_alex=="cj_English_1_935_2023" //Singapore- Reduzco el cambio positivo - 8.4 //
replace cj_q20m_norm =. if id_alex=="cj_English_1_935_2023" //Singapore- Reduzco el cambio positivo - 8.4 //
replace cj_q40c_norm =. if id_alex=="cj_English_0_124" //Singapore- Reduzco el cambio positivo - 8.6 //

*Slovak Republic
drop if id_alex=="cj_English_0_992" //Slovak Republic (muy negativo)
drop if id_alex=="cc_English_0_1971" //Slovak Republic (muy negativo)
drop if id_alex=="cc_English_0_1671" //Slovak Republic (muy negativo)
replace cj_q32d_norm=. if country=="Slovak Republic" //Slovak Republic (se elimino el anio pasado)
replace cj_q34a_norm=. if country=="Slovak Republic" //Slovak Republic (se elimino el anio pasado)
replace cj_q34e_norm=. if country=="Slovak Republic" //Slovak Republic (se elimino el anio pasado)
replace all_q1_norm =. if id_alex=="cj_English_0_528" //Slovak Republic- Reduzco el cambio negativo - 1.2 //
replace all_q2_norm =. if id_alex=="cj_English_0_528" //Slovak Republic- Reduzco el cambio negativo - 1.2 //
replace all_q20_norm =. if id_alex=="cj_English_0_528" //Slovak Republic- Reduzco el cambio negativo - 1.2 //
replace all_q21_norm =. if id_alex=="cj_English_0_528" //Slovak Republic- Reduzco el cambio negativo - 1.2 //
replace all_q1_norm =. if id_alex=="cc_English_1_1054_2022_2023" //Slovak Republic- Reduzco el cambio negativo - 1.2 //
replace all_q21_norm =. if id_alex=="cc_English_0_1655" //Slovak Republic- Reduzco el cambio negativo - 1.2 //
replace all_q1_norm =. if id_alex=="cc_English_0_1655" //Slovak Republic- Reduzco el cambio negativo - 1.2 //
replace all_q2_norm =. if id_alex=="cc_English_0_1655" //Slovak Republic- Reduzco el cambio negativo - 1.2 //
replace all_q20_norm =. if id_alex=="cc_English_0_1655" //Slovak Republic- Reduzco el cambio negativo - 1.2 //
replace all_q21_norm =. if id_alex=="cc_English_0_1655" //Slovak Republic- Reduzco el cambio negativo - 1.2 //
replace cj_q8_norm =. if id_alex=="cj_English_0_528" //Slovak Republic- Reduzco el cambio positivo - 1.4 //
replace cj_q8_norm =. if id_alex=="cj_English_0_1251" //Slovak Republic- Reduzco el cambio positivo - 1.4 //
replace all_q9_norm =. if id_alex=="cc_English_0_458" //Slovak Republic- Reduzco el cambio positivo - 1.4 //
replace all_q9_norm =. if id_alex=="cc_English_0_1554" //Slovak Republic- Reduzco el cambio positivo - 1.4 //
replace all_q10_norm =. if id_alex=="lb_English_0_407" //Slovak Republic- Reduzco el cambio negativo - 1.5 //
replace all_q11_norm =. if id_alex=="lb_English_0_407" //Slovak Republic- Reduzco el cambio negativo - 1.5 //
replace all_q12_norm =. if id_alex=="lb_English_0_407" //Slovak Republic- Reduzco el cambio negativo - 1.5 //
replace all_q10_norm =. if id_alex=="lb_English_0_407" //Slovak Republic- Reduzco el cambio negativo - 1.5 //
replace all_q12_norm =. if id_alex=="cc_English_0_1003" //Slovak Republic- Reduzco el cambio negativo - 1.5 //
replace cj_q9_norm =. if id_alex=="cj_English_0_257_2023" //Slovak Republic- Reduzco el cambio negativo - 1.5 //
replace cj_q9_norm =. if id_alex=="cj_English_0_685" //Slovak Republic- Reduzco el cambio negativo - 1.5 //
replace all_q52_norm =. if id_alex=="cc_English_0_1479" //Slovak Republic- Reduzco el cambio negativo - 1.5 //
replace all_q53_norm =. if id_alex=="cc_English_0_1479" //Slovak Republic- Reduzco el cambio negativo - 1.5 //
replace all_q52_norm =. if id_alex=="cc_English_0_1032" //Slovak Republic- Reduzco el cambio negativo - 1.5 //
replace all_q53_norm =. if id_alex=="cc_English_0_1032" //Slovak Republic- Reduzco el cambio negativo - 1.5 //
replace all_q52_norm =. if id_alex=="cc_English_0_860" //Slovak Republic- Reduzco el cambio negativo - 1.5 //
replace all_q53_norm =. if id_alex=="cc_English_0_860" //Slovak Republic- Reduzco el cambio negativo - 1.5 //
replace all_q10_norm =. if id_alex=="lb_English_0_197" //Slovak Republic- Reduzco el cambio negativo - 1.5 //
replace all_q11_norm =. if id_alex=="lb_English_0_197" //Slovak Republic- Reduzco el cambio negativo - 1.5 //
replace all_q10_norm =. if id_alex=="lb_English_0_651_2023" //Slovak Republic- Reduzco el cambio negativo - 1.5 //
replace all_q11_norm =. if id_alex=="lb_English_0_651_2023" //Slovak Republic- Reduzco el cambio negativo - 1.5 //
replace all_q10_norm =. if id_alex=="cc_English_0_1003" //Slovak Republic- Reduzco el cambio negativo - 1.5 //
replace all_q13_norm =. if id_alex=="lb_English_0_387_2022_2023" //Slovak Republic- Reduzco el cambio negativo - 1.6 //
replace all_q14_norm =. if id_alex=="cc_English_0_1003" //Slovak Republic- Reduzco el cambio negativo - 1.6 //
replace all_q14_norm =. if id_alex=="cc_English_0_860" //Slovak Republic- Reduzco el cambio negativo - 1.6 //
replace all_q15_norm =. if id_alex=="cj_English_0_528" //Slovak Republic- Reduzco el cambio negativo - 1.6 //
replace all_q15_norm =. if id_alex=="cc_English_0_1003" //Slovak Republic- Reduzco el cambio negativo - 1.6 //
replace all_q15_norm =. if id_alex=="cc_English_0_860" //Slovak Republic- Reduzco el cambio negativo - 1.6 //
replace all_q16_norm =. if id_alex=="cj_English_0_528" //Slovak Republic- Reduzco el cambio negativo - 1.6 //
replace all_q16_norm =. if id_alex=="cc_English_0_1003" //Slovak Republic- Reduzco el cambio negativo - 1.6 //
replace all_q16_norm =. if id_alex=="cc_English_0_860" //Slovak Republic- Reduzco el cambio negativo - 1.6 //
replace all_q17_norm =. if id_alex=="lb_English_0_110" //Slovak Republic- Reduzco el cambio negativo - 1.6 //
replace all_q17_norm =. if id_alex=="cj_English_0_216" //Slovak Republic- Reduzco el cambio negativo - 1.6 //
replace all_q18_norm =. if id_alex=="cc_English_0_70_2022_2023" //Slovak Republic- Reduzco el cambio negativo - 1.6 //
replace all_q18_norm =. if id_alex=="cc_English_0_1011_2022_2023" //Slovak Republic- Reduzco el cambio negativo - 1.6 //
replace all_q18_norm =. if id_alex=="cc_English_1_1054_2022_2023" //Slovak Republic- Reduzco el cambio negativo - 1.6 //
replace all_q94_norm =. if id_alex=="cc_English_0_260" //Slovak Republic- Reduzco el cambio negativo - 1.6 //
replace all_q94_norm =. if id_alex=="lb_English_0_110" //Slovak Republic- Reduzco el cambio negativo - 1.6 //
replace all_q19_norm =. if id_alex=="cj_English_0_528" //Slovak Republic- Reduzco el cambio negativo - 1.6 //
replace all_q19_norm =. if id_alex=="cc_English_0_1003" //Slovak Republic- Reduzco el cambio negativo - 1.6 //
replace all_q19_norm =. if id_alex=="cc_English_0_860" //Slovak Republic- Reduzco el cambio negativo - 1.6 //
replace all_q20_norm =. if id_alex=="cj_English_0_528" //Slovak Republic- Reduzco el cambio negativo - 1.6 //
replace all_q20_norm =. if id_alex=="cc_English_0_1479" //Slovak Republic- Reduzco el cambio negativo - 1.6 //
replace all_q20_norm =. if id_alex=="cc_English_1_402" //Slovak Republic- Reduzco el cambio negativo - 1.6 //
replace all_q21_norm =. if id_alex=="cc_English_1_402" //Slovak Republic- Reduzco el cambio negativo - 1.6 //
replace all_q21_norm =. if id_alex=="cj_English_0_528" //Slovak Republic- Reduzco el cambio negativo - 1.6 //
replace all_q21_norm =. if id_alex=="cc_English_0_324" //Slovak Republic- Reduzco el cambio negativo - 1.6 //
replace all_q22_norm =. if id_alex=="cc_English_0_1003" //Slovak Republic- Reduzco el cambio negativo - 1.7 //
replace all_q23_norm =. if id_alex=="cc_English_0_1003" //Slovak Republic- Reduzco el cambio negativo - 1.7 //
replace all_q24_norm =. if id_alex=="cc_English_0_1003" //Slovak Republic- Reduzco el cambio negativo - 1.7 //
replace all_q25_norm =. if id_alex=="cc_English_0_1003" //Slovak Republic- Reduzco el cambio negativo - 1.7 //
replace all_q26_norm =. if id_alex=="cc_English_0_1003" //Slovak Republic- Reduzco el cambio negativo - 1.7 //
replace all_q22_norm =. if id_alex=="lb_English_0_407" //Slovak Republic- Reduzco el cambio negativo - 1.7 //
replace all_q23_norm =. if id_alex=="lb_English_0_407" //Slovak Republic- Reduzco el cambio negativo - 1.7 //
replace all_q24_norm =. if id_alex=="lb_English_0_407" //Slovak Republic- Reduzco el cambio negativo - 1.7 //
replace all_q25_norm =. if id_alex=="lb_English_0_407" //Slovak Republic- Reduzco el cambio negativo - 1.7 //
replace all_q26_norm =. if id_alex=="lb_English_0_407" //Slovak Republic- Reduzco el cambio negativo - 1.7 //
replace all_q22_norm =. if id_alex=="lb_English_0_197" //Slovak Republic- Reduzco el cambio negativo - 1.7 //
replace all_q23_norm =. if id_alex=="lb_English_0_197" //Slovak Republic- Reduzco el cambio negativo - 1.7 //
replace all_q24_norm =. if id_alex=="lb_English_0_197" //Slovak Republic- Reduzco el cambio negativo - 1.7 //
replace all_q25_norm =. if id_alex=="lb_English_0_197" //Slovak Republic- Reduzco el cambio negativo - 1.7 //
replace all_q26_norm =. if id_alex=="lb_English_0_197" //Slovak Republic- Reduzco el cambio negativo - 1.7 //
replace all_q22_norm =1 if id_alex=="cc_English_0_860" //Slovak Republic- Reduzco el cambio negativo - 1.7 //
replace all_q23_norm =1 if id_alex=="cc_English_0_860" //Slovak Republic- Reduzco el cambio negativo - 1.7 //
replace all_q24_norm =1 if id_alex=="cc_English_0_860" //Slovak Republic- Reduzco el cambio negativo - 1.7 //
replace all_q25_norm =1 if id_alex=="cc_English_0_860" //Slovak Republic- Reduzco el cambio negativo - 1.7 //
replace all_q26_norm =1 if id_alex=="cc_English_0_860" //Slovak Republic- Reduzco el cambio negativo - 1.7 //
replace all_q22_norm =1 if id_alex=="cj_English_0_528" //Slovak Republic- Reduzco el cambio negativo - 1.7 //
replace all_q23_norm =1 if id_alex=="cj_English_0_528" //Slovak Republic- Reduzco el cambio negativo - 1.7 //
replace all_q24_norm =1 if id_alex=="cj_English_0_528" //Slovak Republic- Reduzco el cambio negativo - 1.7 //
replace all_q97_norm =. if id_alex=="cc_English_0_1003" //Slovak Republic- Reduzco el cambio negativo - 2.1 //
replace all_q97_norm =. if id_alex=="cc_English_0_260" //Slovak Republic- Reduzco el cambio negativo - 2.1 //
replace all_q97_norm =. if id_alex=="cc_English_0_324" //Slovak Republic- Reduzco el cambio negativo - 2.1 //
replace ph_q7_norm =. if id_alex=="ph_English_0_743_2021_2022_2023" //Slovak Republic- Reduzco el cambio negativo - 2.1 //
replace all_q95_norm =. if id_alex=="lb_English_0_407" //Slovak Republic- Reduzco el cambio negativo - 2.1 //
replace all_q95_norm =. if id_alex=="lb_English_0_110" //Slovak Republic- Reduzco el cambio negativo - 2.1 //
replace all_q95_norm =. if id_alex=="cj_English_0_528" //Slovak Republic- Reduzco el cambio negativo - 2.1 //
replace cj_q32b_norm =. if id_alex=="cj_English_0_685" //Slovak Republic- Reduzco el cambio positivo - 2.2 //
replace cj_q24b_norm =. if id_alex=="cj_English_0_685" //Slovak Republic- Reduzco el cambio positivo - 2.2 //
replace cj_q24c_norm =. if id_alex=="cj_English_0_685" //Slovak Republic- Reduzco el cambio positivo - 2.2 //
replace cj_q33a_norm =. if id_alex=="cj_English_0_528" //Slovak Republic- Reduzco el cambio positivo - 2.2 //
replace cj_q33b_norm =. if id_alex=="cj_English_0_528" //Slovak Republic- Reduzco el cambio positivo - 2.2 //
replace cj_q33c_norm =. if id_alex=="cj_English_0_528" //Slovak Republic- Reduzco el cambio positivo - 2.2 //
replace cj_q33d_norm =. if id_alex=="cj_English_0_528" //Slovak Republic- Reduzco el cambio positivo - 2.2 //
replace cj_q33e_norm =. if id_alex=="cj_English_0_528" //Slovak Republic- Reduzco el cambio positivo - 2.2 //
replace all_q57_norm =. if id_alex=="cc_English_0_391" //Slovak Republic- Reduzco el cambio positivo - 2.2 //
replace all_q57_norm =. if id_alex=="cc_English_0_324" //Slovak Republic- Reduzco el cambio positivo - 2.2 //
replace cj_q34b_norm =. if id_alex=="cj_English_0_528" //Slovak Republic- Reduzco el cambio positivo - 2.3 //
replace cj_q34c_norm =. if id_alex=="cj_English_0_528" //Slovak Republic- Reduzco el cambio positivo - 2.3 //
replace cj_q34d_norm =. if id_alex=="cj_English_0_528" //Slovak Republic- Reduzco el cambio positivo - 2.3 //
replace all_q96_norm=. if id_alex=="lb_English_0_407" //Slovak Republic- Reduzco el cambio negativo - 2.4 //
replace all_q96_norm =. if id_alex=="lb_English_0_110" //Slovak Republic- Reduzco el cambio negativo - 2.4 //
replace all_q40_norm =. if id_alex=="cc_English_0_360" //Slovak Republic- Reduzco el cambio positivo - 3.2 //
replace all_q41_norm =. if id_alex=="cc_English_0_360" //Slovak Republic- Reduzco el cambio positivo - 3.2 //
replace all_q44_norm =. if id_alex=="cc_English_0_360" //Slovak Republic- Reduzco el cambio positivo - 3.2 //
replace all_q45_norm =. if id_alex=="cc_English_0_360" //Slovak Republic- Reduzco el cambio positivo - 3.2 //
replace all_q46_norm =. if id_alex=="cc_English_0_360" //Slovak Republic- Reduzco el cambio positivo - 3.2 //
replace all_q40_norm =. if id_alex=="cc_Russian_0_1307" //Slovak Republic- Reduzco el cambio positivo - 3.2 //
replace all_q41_norm =. if id_alex=="cc_Russian_0_1307" //Slovak Republic- Reduzco el cambio positivo - 3.2 //
replace all_q44_norm =. if id_alex=="cc_Russian_0_1307" //Slovak Republic- Reduzco el cambio positivo - 3.2 //
replace all_q45_norm =. if id_alex=="cc_Russian_0_1307" //Slovak Republic- Reduzco el cambio positivo - 3.2 //
replace all_q46_norm =. if id_alex=="cc_Russian_0_1307" //Slovak Republic- Reduzco el cambio positivo - 3.2 //
replace all_q40_norm =. if id_alex=="cc_English_0_1479" //Slovak Republic- Reduzco el cambio positivo - 3.2 //
replace all_q41_norm =. if id_alex=="cc_English_0_1479" //Slovak Republic- Reduzco el cambio positivo - 3.2 //
replace all_q44_norm =. if id_alex=="cc_English_0_1479" //Slovak Republic- Reduzco el cambio positivo - 3.2 //
replace all_q45_norm =. if id_alex=="cc_English_0_1479" //Slovak Republic- Reduzco el cambio positivo - 3.2 //
replace all_q46_norm =. if id_alex=="cc_English_0_1479" //Slovak Republic- Reduzco el cambio positivo - 3.2 //
replace all_q44_norm =. if id_alex=="cc_English_0_70_2022_2023" //Slovak Republic- Reduzco el cambio positivo - 3.2 //
replace all_q44_norm =. if id_alex=="cc_English_0_1011_2022_2023" //Slovak Republic- Reduzco el cambio positivo - 3.2 //
replace all_q44_norm =. if id_alex=="cc_English_1_1054_2022_2023" //Slovak Republic- Reduzco el cambio positivo - 3.2 //
replace all_q44_norm =. if id_alex=="cc_English_1_880_2022_2023" //Slovak Republic- Reduzco el cambio positivo - 3.2 //
replace all_q41_norm =. if id_alex=="cc_English_0_458" //Slovak Republic- Reduzco el cambio positivo - 3.2 //
replace all_q41_norm =. if id_alex=="cc_English_0_1913" //Slovak Republic- Reduzco el cambio positivo - 3.2 //
replace all_q41_norm =. if id_alex=="cc_English_0_1455" //Slovak Republic- Reduzco el cambio positivo - 3.2 //
replace all_q41_norm =. if id_alex=="cc_English_0_325" //Slovak Republic- Reduzco el cambio positivo - 3.2 //
replace cc_q39e_norm =. if id_alex=="cc_English_0_1554" //Slovak Republic- Reduzco el cambio positivo - 3.2 //
replace cc_q39e_norm =. if id_alex=="cc_English_0_360" //Slovak Republic- Reduzco el cambio positivo - 3.2 //
replace cc_q9a_norm =. if id_alex=="cc_Russian_0_1307" //Slovak Republic- Reduzco el cambio positivo - 3.3 //
replace cc_q32j_norm =. if id_alex=="cc_Russian_0_1307" //Slovak Republic- Reduzco el cambio positivo - 3.3 //
replace cc_q9c_norm =. if id_alex=="cc_English_0_1554" //Slovak Republic- Reduzco el cambio positivo - 3.3 //
replace cc_q40a_norm =. if id_alex=="cc_English_0_1554" //Slovak Republic- Reduzco el cambio positivo - 3.4 //
replace cc_q40b_norm =. if id_alex=="cc_English_0_1554" //Slovak Republic- Reduzco el cambio positivo - 3.4 //
replace cc_q9c_norm =. if id_alex=="cc_English_0_360" //Slovak Republic- Reduzco el cambio positivo - 3.4 //
replace cc_q40a_norm =. if id_alex=="cc_English_0_360" //Slovak Republic- Reduzco el cambio positivo - 3.4 //
replace cc_q40b_norm =. if id_alex=="cc_English_0_360" //Slovak Republic- Reduzco el cambio positivo - 3.4 //
replace cj_q11a_norm =. if id_alex=="cj_English_0_1120" //Slovak Republic- Reduzco el cambio negativo - 4.2 //
replace cj_q31e_norm =. if id_alex=="cj_English_0_528" //Slovak Republic- Reduzco el cambio negativo - 4.2 //
replace cj_q42c_norm =. if id_alex=="cj_English_0_528" //Slovak Republic- Reduzco el cambio negativo - 4.2 //
replace cj_q42c_norm =. if id_alex=="cj_English_0_1251" //Slovak Republic- Reduzco el cambio negativo - 4.2 //
replace all_q29_norm =. if id_alex=="cc_English_0_1554" //Slovak Republic- Reduzco el cambio positivo - 4.5 //
replace all_q30_norm =. if id_alex=="cc_English_0_1554" //Slovak Republic- Reduzco el cambio positivo - 4.5 //
replace all_q29_norm =. if id_alex=="cc_English_0_360" //Slovak Republic- Reduzco el cambio positivo - 4.5 //
replace all_q30_norm =. if id_alex=="cc_English_0_360" //Slovak Republic- Reduzco el cambio positivo - 4.5 //
replace all_q29_norm =. if id_alex=="cc_English_0_458" //Slovak Republic- Reduzco el cambio positivo - 4.5 //
replace all_q30_norm =. if id_alex=="cc_English_0_458" //Slovak Republic- Reduzco el cambio positivo - 4.5 //
replace all_q29_norm =. if id_alex=="cc_English_0_1913" //Slovak Republic- Reduzco el cambio positivo - 4.5 //
replace all_q30_norm =. if id_alex=="cc_English_0_1913" //Slovak Republic- Reduzco el cambio positivo - 4.5 //
replace cj_q31f_norm =. if id_alex=="cj_English_1_929" //Slovak Republic- Reduzco el cambio negativo - 4.6 //
replace cj_q31g_norm =. if id_alex=="cj_English_1_929" //Slovak Republic- Reduzco el cambio negativo - 4.6 //
replace cj_q31f_norm =. if id_alex=="cj_English_0_813" //Slovak Republic- Reduzco el cambio negativo - 4.6 //
replace cj_q31g_norm =. if id_alex=="cj_English_0_813" //Slovak Republic- Reduzco el cambio negativo - 4.6 //
replace cj_q31f_norm =. if id_alex=="cj_English_0_216" //Slovak Republic- Reduzco el cambio negativo - 4.6 //
replace cj_q31g_norm =. if id_alex=="cj_English_0_216" //Slovak Republic- Reduzco el cambio negativo - 4.6 //
replace cj_q31f_norm =. if id_alex=="cj_English_0_257_2023" //Slovak Republic- Reduzco el cambio negativo - 4.6 //
replace cj_q42c_norm =. if id_alex=="cj_English_0_1120" //Slovak Republic- Reduzco el cambio negativo - 4.6 //
replace cj_q42d_norm =. if id_alex=="cj_English_0_1120" //Slovak Republic- Reduzco el cambio negativo - 4.6 //
replace cj_q42c_norm =. if id_alex=="cj_English_0_216" //Slovak Republic- Reduzco el cambio negativo - 4.6 //
replace cj_q42d_norm =. if id_alex=="cj_English_0_216" //Slovak Republic- Reduzco el cambio negativo - 4.6 //
replace cj_q42d_norm =. if id_alex=="cj_English_0_137_2022_2023" //Slovak Republic- Reduzco el cambio negativo - 4.6 //
replace cj_q31f_norm =. if id_alex=="cj_English_1_540" //Slovak Republic- Reduzco el cambio negativo - 4.6 //
replace cj_q31g_norm =. if id_alex=="cj_English_1_540" //Slovak Republic- Reduzco el cambio negativo - 4.6 //
replace cj_q31f_norm =. if id_alex=="cj_English_0_685" //Slovak Republic- Reduzco el cambio negativo - 4.6 //
replace cj_q31g_norm =. if id_alex=="cj_English_0_685" //Slovak Republic- Reduzco el cambio negativo - 4.6 //
replace cj_q31f_norm =. if id_alex=="cj_English_0_1120" //Slovak Republic- Reduzco el cambio negativo - 4.6 //
replace all_q19_norm =. if id_alex=="cj_English_0_216" //Slovak Republic- Reduzco el cambio negativo - 4.7 //
replace all_q31_norm =. if id_alex=="cj_English_0_216" //Slovak Republic- Reduzco el cambio negativo - 4.7 //
replace all_q32_norm =. if id_alex=="cj_English_0_216" //Slovak Republic- Reduzco el cambio negativo - 4.7 //
replace all_q14_norm =. if id_alex=="cj_English_0_216" //Slovak Republic- Reduzco el cambio negativo - 4.7 //
replace all_q31_norm =. if id_alex=="cc_English_0_1479" //Slovak Republic- Reduzco el cambio negativo - 4.7 //
replace all_q32_norm =. if id_alex=="cc_English_0_1479" //Slovak Republic- Reduzco el cambio negativo - 4.7 //
replace all_q31_norm =. if id_alex=="cc_English_0_1952" //Slovak Republic- Reduzco el cambio negativo - 4.7 //
replace all_q32_norm =. if id_alex=="cc_English_0_1952" //Slovak Republic- Reduzco el cambio negativo - 4.7 //
replace all_q31_norm =. if id_alex=="cc_English_0_1032" //Slovak Republic- Reduzco el cambio negativo - 4.7 //
replace all_q32_norm =. if id_alex=="cc_English_0_1032" //Slovak Republic- Reduzco el cambio negativo - 4.7 //
replace all_q62_norm =. if id_alex=="cc_English_0_1893" //Slovak Republic- Reduzco el cambio positivo - 6.3 //
replace all_q63_norm =. if id_alex=="cc_English_0_1893" //Slovak Republic- Reduzco el cambio positivo - 6.3 //
replace all_q62_norm =. if id_alex=="cc_English_0_1554" //Slovak Republic- Reduzco el cambio positivo - 6.3 //
replace all_q63_norm =. if id_alex=="cc_English_0_1554" //Slovak Republic- Reduzco el cambio positivo - 6.3 //
replace all_q62_norm =. if id_alex=="lb_English_0_420_2022_2023" //Slovak Republic- Reduzco el cambio positivo - 6.3 //
replace all_q63_norm =. if id_alex=="lb_English_0_420_2022_2023" //Slovak Republic- Reduzco el cambio positivo - 6.3 //
replace all_q62_norm =. if id_alex=="lb_English_0_137" //Slovak Republic- Reduzco el cambio positivo - 6.3 //
replace all_q63_norm =. if id_alex=="lb_English_0_137" //Slovak Republic- Reduzco el cambio positivo - 6.3 //
replace lb_q2d_norm =. if id_alex=="lb_English_0_446_2021_2022_2023" //Slovak Republic- Reduzco el cambio positivo - 6.3 //
replace lb_q3d_norm =. if id_alex=="lb_English_0_446_2021_2022_2023" //Slovak Republic- Reduzco el cambio positivo - 6.3 //
replace cc_q10_norm =. if id_alex=="cc_English_0_347" //Slovak Republic- Reduzco el cambio negativo - 6.5 //
replace cc_q11a_norm =. if id_alex=="cc_English_0_347" //Slovak Republic- Reduzco el cambio negativo - 6.5 //
replace cc_q10_norm =. if id_alex=="cc_English_0_325" //Slovak Republic- Reduzco el cambio negativo - 6.5 //
replace cc_q11a_norm =. if id_alex=="cc_English_0_325" //Slovak Republic- Reduzco el cambio negativo - 6.5 //
replace cc_q10_norm =. if id_alex=="cc_English_0_260" //Slovak Republic- Reduzco el cambio negativo - 6.5 //
replace cc_q11a_norm =. if id_alex=="cc_English_0_260" //Slovak Republic- Reduzco el cambio negativo - 6.5 //
replace cc_q10_norm =. if id_alex=="cc_English_0_860" //Slovak Republic- Reduzco el cambio negativo - 6.5 //
replace cc_q11a_norm =. if id_alex=="cc_English_0_860" //Slovak Republic- Reduzco el cambio negativo - 6.5 //
replace all_q92_norm =. if id_alex=="cc_English_0_360" //Slovak Republic- Reduzco el cambio positivo - 7.1 //
replace all_q75_norm =. if id_alex=="cc_English_0_360" //Slovak Republic- Reduzco el cambio positivo - 7.1 //
replace all_q92_norm =. if id_alex=="cc_English_0_325" //Slovak Republic- Reduzco el cambio positivo - 7.1 //
replace all_q75_norm =. if id_alex=="cc_English_0_325" //Slovak Republic- Reduzco el cambio positivo - 7.1 //
replace all_q92_norm =. if id_alex=="lb_English_0_137" //Slovak Republic- Reduzco el cambio positivo - 7.1 //
replace cj_q26_norm =. if id_alex=="cj_English_0_1251" //Slovak Republic- Reduzco el cambio positivo - 7.1 //
replace cj_q26_norm =. if id_alex=="cj_English_0_1120" //Slovak Republic- Reduzco el cambio positivo - 7.1 //
replace cj_q26_norm =. if id_alex=="cj_English_0_216" //Slovak Republic- Reduzco el cambio positivo - 7.1 //
replace cj_q26_norm =. if id_alex=="cj_English_0_946" //Slovak Republic- Reduzco el cambio positivo - 7.1 //
replace cc_q12_norm =. if id_alex=="cc_English_0_260" //Slovak Republic- Reduzco el cambio positivo - 7.1 //
replace cc_q12_norm =. if id_alex=="cc_English_0_1650" //Slovak Republic- Reduzco el cambio positivo - 7.1 //
replace cc_q12_norm =. if id_alex=="cc_English_0_1479" //Slovak Republic- Reduzco el cambio positivo - 7.1 //
replace cc_q12_norm =. if id_alex=="cc_English_0_458" //Slovak Republic- Reduzco el cambio positivo - 7.1 //
replace cc_q12_norm =. if id_alex=="cc_English_0_1554" //Slovak Republic- Reduzco el cambio positivo - 7.1 //
replace cc_q12_norm =. if id_alex=="cc_English_0_360" //Slovak Republic- Reduzco el cambio positivo - 7.1 //
replace cc_q22a_norm =. if id_alex=="cc_English_0_1455" //Slovak Republic- Reduzco el cambio positivo - 7.1 //
replace cc_q22b_norm =. if id_alex=="cc_English_0_1455" //Slovak Republic- Reduzco el cambio positivo - 7.1 //
replace cc_q22c_norm =. if id_alex=="cc_English_0_1455" //Slovak Republic- Reduzco el cambio positivo - 7.1 //
replace all_q76_norm =. if id_alex=="cc_English_0_1655" //Slovak Republic- Reduzco el cambio positivo - 7.2 //
replace all_q77_norm =. if id_alex=="cc_English_0_1655" //Slovak Republic- Reduzco el cambio positivo - 7.2 //
replace all_q78_norm =. if id_alex=="cc_English_0_1655" //Slovak Republic- Reduzco el cambio positivo - 7.2 //
replace all_q79_norm =. if id_alex=="cc_English_0_1655" //Slovak Republic- Reduzco el cambio positivo - 7.2 //
replace all_q80_norm =. if id_alex=="cc_English_0_1655" //Slovak Republic- Reduzco el cambio positivo - 7.2 //
replace all_q81_norm =. if id_alex=="cc_English_0_1655" //Slovak Republic- Reduzco el cambio positivo - 7.2 //
replace all_q76_norm =. if id_alex=="cc_English_0_360" //Slovak Republic- Reduzco el cambio positivo - 7.2 //
replace all_q77_norm =. if id_alex=="cc_English_0_360" //Slovak Republic- Reduzco el cambio positivo - 7.2 //
replace all_q78_norm =. if id_alex=="cc_English_0_360" //Slovak Republic- Reduzco el cambio positivo - 7.2 //
replace all_q79_norm =. if id_alex=="cc_English_0_360" //Slovak Republic- Reduzco el cambio positivo - 7.2 //
replace all_q80_norm =. if id_alex=="cc_English_0_360" //Slovak Republic- Reduzco el cambio positivo - 7.2 //
replace all_q81_norm =. if id_alex=="cc_English_0_360" //Slovak Republic- Reduzco el cambio positivo - 7.2 //
replace all_q76_norm =. if id_alex=="cc_English_0_260" //Slovak Republic- Reduzco el cambio positivo - 7.2 //
replace all_q77_norm =. if id_alex=="cc_English_0_260" //Slovak Republic- Reduzco el cambio positivo - 7.2 //
replace all_q78_norm =. if id_alex=="cc_English_0_260" //Slovak Republic- Reduzco el cambio positivo - 7.2 //
replace all_q79_norm =. if id_alex=="cc_English_0_260" //Slovak Republic- Reduzco el cambio positivo - 7.2 //
replace all_q78_norm =. if id_alex=="cc_English_0_1554" //Slovak Republic- Reduzco el cambio positivo - 7.2 //
replace all_q79_norm =. if id_alex=="cc_English_0_1554" //Slovak Republic- Reduzco el cambio positivo - 7.2 //
replace all_q80_norm =. if id_alex=="cc_English_0_1554" //Slovak Republic- Reduzco el cambio positivo - 7.2 //
replace all_q81_norm =. if id_alex=="cc_English_0_1554" //Slovak Republic- Reduzco el cambio positivo - 7.2 //
replace cc_q13_norm =. if id_alex=="cc_English_0_1032" //Slovak Republic- Reduzco el cambio negativo - 7.5 //
replace cc_q13_norm =. if id_alex=="cc_English_0_1952" //Slovak Republic- Reduzco el cambio negativo - 7.5 //
replace cc_q13_norm =. if id_alex=="cc_English_0_1655" //Slovak Republic- Reduzco el cambio negativo - 7.5 //
replace all_q85_norm =. if id_alex=="cc_English_0_347" //Slovak Republic- Reduzco el cambio negativo - 7.5 //
replace all_q85_norm =. if id_alex=="cc_English_0_1292" //Slovak Republic- Reduzco el cambio negativo - 7.5 //
replace all_q85_norm =. if id_alex=="cc_Russian_0_1307" //Slovak Republic- Reduzco el cambio negativo - 7.5 //
replace all_q89_norm =. if id_alex=="cc_English_0_260" //Slovak Republic- Reduzco el cambio positivo - 7.7 //
replace all_q89_norm =. if id_alex=="cc_Russian_0_1307" //Slovak Republic- Reduzco el cambio positivo - 7.7 //
replace cj_q25a_norm =. if id_alex=="cj_English_0_216" //Slovak Republic- Reduzco el cambio positivo - 8.1 //
replace cj_q25b_norm =. if id_alex=="cj_English_0_216" //Slovak Republic- Reduzco el cambio positivo - 8.1 //
replace cj_q25a_norm =. if id_alex=="cj_English_0_528" //Slovak Republic- Reduzco el cambio positivo - 8.1 //
replace cj_q25b_norm =. if id_alex=="cj_English_0_528" //Slovak Republic- Reduzco el cambio positivo - 8.1 //
replace cj_q27a_norm =. if id_alex=="cj_English_0_1120" //Slovak Republic- Reduzco el cambio positivo - 8.2 //
replace cj_q7a_norm =. if id_alex=="cj_English_0_1120" //Slovak Republic- Reduzco el cambio positivo - 8.2 //
replace cj_q7b_norm =. if id_alex=="cj_English_0_1120" //Slovak Republic- Reduzco el cambio positivo - 8.2 //
replace cj_q7c_norm =. if id_alex=="cj_English_0_1120" //Slovak Republic- Reduzco el cambio positivo - 8.2 //
replace cj_q20a_norm =. if id_alex=="cj_English_0_1120" //Slovak Republic- Reduzco el cambio positivo - 8.2 //
replace cj_q20b_norm =. if id_alex=="cj_English_0_946" //Slovak Republic- Reduzco el cambio positivo - 8.2 //
replace cj_q7a_norm =. if id_alex=="cj_English_0_1251" //Slovak Republic- Reduzco el cambio positivo - 8.2 //
replace cj_q20e_norm =. if id_alex=="cj_English_0_1120" //Slovak Republic- Reduzco el cambio positivo - 8.2 //
replace cj_q20e_norm =. if id_alex=="cj_English_0_528" //Slovak Republic- Reduzco el cambio positivo - 8.2 //
replace cj_q21a_norm =. if id_alex=="cj_English_0_137_2022_2023" //Slovak Republic- Reduzco el cambio negativo - 8.3 //
replace cj_q28_norm =. if id_alex=="cj_English_0_1251" //Slovak Republic- Reduzco el cambio negativo - 8.3 //
replace cj_q21g_norm =. if id_alex=="cj_English_0_813" //Slovak Republic- Reduzco el cambio negativo - 8.3 //
replace cj_q12a_norm =. if id_alex=="cj_English_0_1120" //Slovak Republic- Reduzco el cambio positivo - 8.4 //     
replace cj_q12a_norm =. if id_alex=="cj_English_1_329_2023" //Slovak Republic- Reduzco el cambio positivo - 8.4 //     
replace cj_q12a_norm =. if id_alex=="cj_English_1_484" //Slovak Republic- Reduzco el cambio positivo - 8.4 //     
replace cj_q20o_norm =. if id_alex=="cj_English_0_1120" //Slovak Republic- Reduzco el cambio positivo - 8.4 // 
replace cj_q20o_norm =. if id_alex=="cj_English_1_484" //Slovak Republic- Reduzco el cambio positivo - 8.4 // 
replace cj_q12a_norm =. if id_alex=="cj_English_0_137_2022_2023" //Slovak Republic- Reduzco el cambio positivo - 8.4 //     
replace cj_q20o_norm =. if id_alex=="cj_English_1_418" //Slovak Republic- Reduzco el cambio positivo - 8.4 // 
replace cj_q34b_norm =. if id_alex=="cj_English_1_484" //Slovak Republic- Reduzco el cambio positivo - 8.5 // 
replace cj_q34c_norm =. if id_alex=="cj_English_1_484" //Slovak Republic- Reduzco el cambio positivo - 8.5 // 
replace cj_q34d_norm =. if id_alex=="cj_English_1_484" //Slovak Republic- Reduzco el cambio positivo - 8.5 // 
replace cj_q33a_norm =. if id_alex=="cj_English_1_484" //Slovak Republic- Reduzco el cambio positivo - 8.5 // 
replace cj_q33b_norm =. if id_alex=="cj_English_1_484" //Slovak Republic- Reduzco el cambio positivo - 8.5 // 
replace cj_q33c_norm =. if id_alex=="cj_English_1_484" //Slovak Republic- Reduzco el cambio positivo - 8.5 // 
replace cj_q33d_norm =. if id_alex=="cj_English_1_484" //Slovak Republic- Reduzco el cambio positivo - 8.5 // 
replace cj_q40b_norm =. if id_alex=="cj_English_1_929" //Slovak Republic- Reduzco el cambio negativo - 8.6 //
replace cj_q40c_norm =. if id_alex=="cj_English_1_929" //Slovak Republic- Reduzco el cambio negativo - 8.6 //
replace cj_q20m_norm =. if id_alex=="cj_English_1_929" //Slovak Republic- Reduzco el cambio negativo - 8.6 //
replace cj_q40b_norm =. if id_alex=="cj_English_0_1120" //Slovak Republic- Reduzco el cambio negativo - 8.6 //
replace cj_q40c_norm =. if id_alex=="cj_English_0_1120" //Slovak Republic- Reduzco el cambio negativo - 8.6 //
replace cj_q20m_norm =. if id_alex=="cj_English_0_1120" //Slovak Republic- Reduzco el cambio negativo - 8.6 //
replace cj_q40b_norm =. if id_alex=="cj_English_0_216" //Slovak Republic- Reduzco el cambio negativo - 8.6 //
replace cj_q40c_norm =. if id_alex=="cj_English_0_216" //Slovak Republic- Reduzco el cambio negativo - 8.6 //
replace cj_q20m_norm =. if id_alex=="cj_English_0_528" //Slovak Republic- Reduzco el cambio negativo - 8.6 //

*Slovenia
drop if id_alex=="cj_English_0_670" //Slovenia (muy positivo)
drop if id_alex=="cj_English_1_959" //Slovenia (muy positivo)
drop if id_alex=="cj_English_0_259_2022_2023" //Slovenia 
drop if id_alex=="cj_English_0_266" //Slovenia (muy positivo)
replace cc_q40a_norm=. if country=="Slovenia" // Slovenia (se elimino el anio pasado)
replace all_q2_norm =. if id_alex=="lb_English_0_71_2023" //Slovenia- Reduzco el cambio positivo - 1.2 //
replace all_q20_norm =. if id_alex=="lb_English_0_71_2023" //Slovenia- Reduzco el cambio positivo - 1.2 //
replace all_q21_norm =. if id_alex=="lb_English_0_71_2023" //Slovenia- Reduzco el cambio positivo - 1.2 //
replace all_q2_norm =. if id_alex=="lb_English_0_769_2017_2018_2019_2021_2022_2023" //Slovenia- Reduzco el cambio positivo - 1.2 //
replace all_q20_norm =. if id_alex=="lb_English_0_769_2017_2018_2019_2021_2022_2023" //Slovenia- Reduzco el cambio positivo - 1.2 //
replace all_q21_norm =. if id_alex=="lb_English_0_769_2017_2018_2019_2021_2022_2023" //Slovenia- Reduzco el cambio positivo - 1.2 //
replace all_q2_norm =. if id_alex=="cc_English_1_960_2022_2023" //Slovenia- Reduzco el cambio positivo - 1.2 //
replace all_q20_norm =. if id_alex=="cc_English_1_960_2022_2023" //Slovenia- Reduzco el cambio positivo - 1.2 //
replace all_q21_norm =. if id_alex=="cc_English_1_960_2022_2023" //Slovenia- Reduzco el cambio positivo - 1.2 //
replace cc_q25_norm =. if id_alex=="cc_English_0_1822" //Slovenia- Reduzco el cambio positivo - 1.3 //
replace all_q4_norm =. if id_alex=="cc_English_0_1822" //Slovenia- Reduzco el cambio positivo - 1.3 //
replace all_q5_norm =. if id_alex=="cc_English_0_1822" //Slovenia- Reduzco el cambio positivo - 1.3 //
replace all_q6_norm =. if id_alex=="cc_English_0_1822" //Slovenia- Reduzco el cambio positivo - 1.3 //
replace cc_q25_norm =. if id_alex=="cc_English_0_778" //Slovenia- Reduzco el cambio positivo - 1.3 //
replace all_q4_norm =. if id_alex=="cc_English_0_719" //Slovenia- Reduzco el cambio positivo - 1.3 //
replace all_q5_norm =. if id_alex=="cc_English_0_778" //Slovenia- Reduzco el cambio positivo - 1.3 //
replace all_q6_norm =. if id_alex=="cc_English_0_778" //Slovenia- Reduzco el cambio positivo - 1.3 //
replace cc_q27_norm =. if id_alex=="cc_English_0_681" //Slovenia- Reduzco el cambio negativo - 2.1 //
replace cc_q27_norm =. if id_alex=="cc_English_0_938" //Slovenia- Reduzco el cambio negativo - 2.1 //
replace cj_q33c_norm =.6666667 if id_alex=="cj_English_0_719" //Slovenia- Reduzco el cambio positivo - 2.2 //
replace cj_q33c_norm =.6666667 if id_alex=="cj_English_0_334" //Slovenia- Reduzco el cambio positivo - 2.2 //
replace cj_q33d_norm =. if id_alex=="cj_English_0_898" //Slovenia- Reduzco el cambio positivo - 2.2 //
replace cj_q33e_norm =. if id_alex=="cj_English_0_898" //Slovenia- Reduzco el cambio positivo - 2.2 //
replace cj_q32b_norm =. if id_alex=="cj_English_0_394_2022_2023" //Slovenia- Reduzco el cambio positivo - 2.2 //
replace all_q28_norm =. if id_alex=="cc_English_0_778" //Slovenia- Reduzco el cambio positivo - 2.2 //
replace all_q6_norm =. if id_alex=="cc_English_0_778" //Slovenia- Reduzco el cambio positivo - 2.2 //
replace all_q96_norm =. if id_alex=="cc_English_0_778" //Slovenia- Reduzco el cambio positivo - 2.4 //
replace all_q96_norm =. if id_alex=="cj_English_0_334" //Slovenia- Reduzco el cambio positivo - 2.4 //
replace all_q96_norm =. if id_alex=="lb_English_1_340" //Slovenia- Reduzco el cambio positivo - 2.4 //
replace all_q96_norm =. if id_alex=="lb_English_0_497" //Slovenia- Reduzco el cambio positivo - 2.4 //
replace cc_q9c_norm =. if id_alex=="cc_English_0_719" //Slovenia- Reduzco el cambio positivo - 3.4 //
replace cc_q9c_norm =. if id_alex=="cc_English_0_778" //Slovenia- Reduzco el cambio positivo - 3.4 //
replace all_q29_norm =. if id_alex=="cc_English_0_1822" //Slovenia- Reduzco el cambio positivo - 4.5 //
replace all_q30_norm =. if id_alex=="cc_English_0_1822" //Slovenia- Reduzco el cambio positivo - 4.5 //
replace all_q29_norm =. if id_alex=="cc_English_0_1610" //Slovenia- Reduzco el cambio positivo - 4.5 //
replace all_q30_norm =. if id_alex=="cc_English_0_1610" //Slovenia- Reduzco el cambio positivo - 4.5 //
replace all_q29_norm =. if id_alex=="cc_English_0_719" //Slovenia- Reduzco el cambio positivo - 4.5 //
replace all_q30_norm =. if id_alex=="cc_English_0_719" //Slovenia- Reduzco el cambio positivo - 4.5 //
replace all_q29_norm =. if id_alex=="cj_English_0_719" //Slovenia- Reduzco el cambio positivo - 4.5 //
replace all_q30_norm =. if id_alex=="cj_English_0_719" //Slovenia- Reduzco el cambio positivo - 4.5 //
replace all_q29_norm =. if id_alex=="cc_English_0_681" //Slovenia- Reduzco el cambio positivo - 4.5 //
replace all_q30_norm =. if id_alex=="cc_English_0_681" //Slovenia- Reduzco el cambio positivo - 4.5 //
replace all_q29_norm =. if id_alex=="cc_English_0_711_2023" //Slovenia- Reduzco el cambio positivo - 4.5 //
replace all_q30_norm =. if id_alex=="cc_English_0_711_2023" //Slovenia- Reduzco el cambio positivo - 4.5 //
replace all_q29_norm =. if id_alex=="cj_English_1_908_2022_2023" //Slovenia- Reduzco el cambio positivo - 4.5 //
replace all_q30_norm =. if id_alex=="cj_English_1_908_2022_2023" //Slovenia- Reduzco el cambio positivo - 4.5 //
replace cj_q31f_norm =. if id_alex=="cj_English_0_394_2022_2023" //Slovenia- Reduzco el cambio positivo - 4.6 //
replace cj_q31g_norm =. if id_alex=="cj_English_0_394_2022_2023" //Slovenia- Reduzco el cambio positivo - 4.6 //
replace cj_q42c_norm =. if id_alex=="cj_English_0_394_2022_2023" //Slovenia- Reduzco el cambio positivo - 4.6 //
replace cj_q31f_norm =. if id_alex=="cj_English_0_1023_2023" //Slovenia- Reduzco el cambio positivo - 4.6 //
replace cj_q31g_norm =. if id_alex=="cj_English_0_1023_2023" //Slovenia- Reduzco el cambio positivo - 4.6 //
replace cj_q42c_norm =. if id_alex=="cj_English_0_1023_2023" //Slovenia- Reduzco el cambio positivo - 4.6 //
replace lb_q2d_norm =1 if id_alex=="lb_English_0_497" //Slovenia- Reduzco el cambio negativo - 6.3 //
replace all_q48_norm =. if id_alex=="lb_English_1_321_2023" //Slovenia- Reduzco el cambio positivo - 6.4 //
replace cj_q20e_norm =. if id_alex=="cj_English_0_334" //Slovenia- Reduzco el cambio positivo - 8.2 //
replace cj_q7a_norm =. if id_alex=="cj_English_1_908_2022_2023" //Slovenia- Reduzco el cambio positivo - 8.2 //
replace cj_q7b_norm =. if id_alex=="cj_English_1_908_2022_2023" //Slovenia- Reduzco el cambio positivo - 8.2 //
replace cj_q21e_norm =. if id_alex=="cj_English_0_126" //Slovenia- Reduzco el cambio positivo - 8.3 //
replace cj_q21e_norm =. if id_alex=="cj_English_0_719" //Slovenia- Reduzco el cambio positivo - 8.3 //
replace cj_q21e_norm =. if id_alex=="cj_English_1_928" //Slovenia- Reduzco el cambio positivo - 8.3 //
replace cj_q28_norm =. if id_alex=="cj_English_0_334" //Slovenia- Reduzco el cambio positivo - 8.3 //
replace cj_q20o_norm =. if id_alex=="cj_English_0_252_2023" //Slovenia- Reduzco el cambio positivo - 8.4 //
replace cj_q20m_norm =. if id_alex=="cj_English_0_252_2023" //Slovenia- Reduzco el cambio positivo - 8.6 //
replace cj_q20m_norm =. if id_alex=="cj_English_1_837_2023" //Slovenia- Reduzco el cambio positivo - 8.6 //

*South Africa
replace cc_q13_norm =. if id_alex=="cc_English_1_519" //South Africa- Reduzco el cambio negativo - 7.5 //
replace cc_q13_norm =. if id_alex=="cc_English_1_639" //South Africa- Reduzco el cambio negativo - 7.5 //
replace cc_q26a_norm =. if id_alex=="cc_English_0_259_2022_2023" //South Africa- Reduzco el cambio negativo - 7.5 //
replace cc_q14a_norm =. if id_alex=="cc_English_1_1069_2023" //South Africa- Reduzco el cambio positivo - 7.7 //
replace cc_q14b_norm =. if id_alex=="cc_English_1_1069_2023" //South Africa- Reduzco el cambio positivo - 7.7 //
replace cc_q14a_norm =. if id_alex=="cc_English_0_1119_2023" //South Africa- Reduzco el cambio positivo - 7.7 //
replace cc_q14b_norm =. if id_alex=="cc_English_0_1119_2023" //South Africa- Reduzco el cambio positivo - 7.7 //

*Spain
drop if id_alex=="cc_Spanish_0_758" //Spain (muy negativo)
drop if id_alex=="cc_Spanish_0_1421_2022_2023" //Spain (muy negativo)
drop if id_alex=="cc_Spanish_0_1168" //Spain (muy negativo)
drop if id_alex=="cc_Spanish_1_398_2023" //Spain (muy negativo)
drop if id_alex=="cc_Spanish_0_1876" //Spain (muy negativo)
drop if id_alex=="cj_Spanish_0_1377" //Spain (muy negativo)
drop if id_alex=="cj_Spanish_1_122" //Spain (muy negativo)
drop if id_alex=="lb_Spanish_1_422_2022_2023" //Spain (muy negativo)
drop if id_alex=="lb_Spanish_0_486" //Spain (muy negativo)
drop if id_alex=="lb_Spanish_0_221" //Spain (muy negativo)
drop if id_alex=="ph_Spanish_1_269_2023" //Spain (muy negativo)
drop if id_alex=="lb_Spanish_1_239" //Spain (muy negativo)
drop if id_alex=="lb_Spanish_1_627" //Spain (muy negativo)
drop if id_alex=="cc_Spanish_0_1562" //Spain (muy negativo)
drop if id_alex=="cc_English_0_372_2022_2023" //Spain (muy negativo)
drop if id_alex=="cj_Spanish_0_576" //Spain (muy negativo)
drop if id_alex=="ph_Spanish_1_222_2023" //Spain (muy negativo)
replace all_q1_norm =. if id_alex=="cj_Spanish_0_1262" //Spain- Reduzco el cambio negativo - 1.2 //
replace all_q2_norm =. if id_alex=="cj_Spanish_0_1262" //Spain- Reduzco el cambio negativo - 1.2 //
replace all_q1_norm =. if id_alex=="cj_Spanish_1_542" //Spain- Reduzco el cambio negativo - 1.2 //
replace all_q2_norm =. if id_alex=="cj_Spanish_1_542" //Spain- Reduzco el cambio negativo - 1.2 //
replace all_q1_norm =. if id_alex=="cj_Spanish_0_29" //Spain- Reduzco el cambio negativo - 1.2 //
replace all_q2_norm =. if id_alex=="cj_Spanish_0_29" //Spain- Reduzco el cambio negativo - 1.2 //
replace all_q1_norm =. if id_alex=="cj_Spanish_0_797" //Spain- Reduzco el cambio negativo - 1.2 //
replace all_q2_norm =. if id_alex=="cj_Spanish_0_797" //Spain- Reduzco el cambio negativo - 1.2 //
replace all_q1_norm =. if id_alex=="lb_Spanish_0_130" //Spain- Reduzco el cambio negativo - 1.2 //
replace all_q2_norm =. if id_alex=="lb_Spanish_0_130" //Spain- Reduzco el cambio negativo - 1.2 //
replace all_q2_norm =. if id_alex=="cj_Spanish_0_1159" //Spain- Reduzco el cambio negativo - 1.2 //
replace all_q2_norm =. if id_alex=="cj_Spanish_0_665" //Spain- Reduzco el cambio negativo - 1.2 //
replace cc_q33_norm =. if id_alex=="cc_Spanish_0_1800" //Spain- Reduzco el cambio negativo - 1.4 //
replace cc_q33_norm =. if id_alex=="cc_Spanish_0_1662" //Spain- Reduzco el cambio negativo - 1.4 //
replace cc_q33_norm =. if id_alex=="cc_Spanish_0_912" //Spain- Reduzco el cambio negativo - 1.4 //
replace cj_q38_norm =. if id_alex=="cj_Spanish_1_1017_2022_2023" //Spain- Reduzco el cambio negativo - 1.4 //
replace cj_q38_norm =. if id_alex=="cj_Spanish_1_662_2023" //Spain- Reduzco el cambio negativo - 1.4 //
replace cj_q38_norm =. if id_alex=="cj_Spanish_0_711_2023" //Spain- Reduzco el cambio negativo - 1.4 //
replace cj_q38_norm =. if id_alex=="cj_Spanish_0_805" //Spain- Reduzco el cambio negativo - 1.4 //
replace all_q9_norm =. if id_alex=="cj_Spanish_0_922" //Spain- Reduzco el cambio negativo - 1.4 //
replace all_q9_norm =. if id_alex=="cj_Spanish_1_160" //Spain- Reduzco el cambio negativo - 1.4 //
replace all_q9_norm =. if id_alex=="lb_Spanish_0_130" //Spain- Reduzco el cambio negativo - 1.4 //
replace cj_q8_norm =1 if id_alex=="cj_Spanish_0_943" //Spain- Reduzco el cambio negativo - 1.4 //
replace all_q22_norm =. if id_alex=="cj_Spanish_0_695_2023" //Spain- Reduzco el cambio negativo - 1.7 //
replace all_q23_norm =. if id_alex=="cj_Spanish_0_695_2023" //Spain- Reduzco el cambio negativo - 1.7 //
replace all_q24_norm =. if id_alex=="cj_Spanish_0_695_2023" //Spain- Reduzco el cambio negativo - 1.7 //
replace all_q25_norm =. if id_alex=="cj_Spanish_0_695_2023" //Spain- Reduzco el cambio negativo - 1.7 //
replace all_q26_norm =. if id_alex=="cj_Spanish_0_695_2023" //Spain- Reduzco el cambio negativo - 1.7 //
replace all_q8_norm =. if id_alex=="cj_Spanish_0_695_2023" //Spain- Reduzco el cambio negativo - 1.7 //
replace all_q96_norm =. if id_alex=="cc_Spanish_1_1295_2022_2023" //Spain- Reduzco el cambio positivo - 2.4 //
replace all_q96_norm =. if id_alex=="cc_Spanish_1_883_2023" //Spain- Reduzco el cambio positivo - 2.4 //
replace cc_q39d_norm =. if id_alex=="cc_Spanish_1_413" //Spain- Reduzco el cambio negativo - 3.1 //
replace cc_q39d_norm =. if id_alex=="cc_Spanish_0_276" //Spain- Reduzco el cambio negativo - 3.1 //
replace cc_q39d_norm =. if id_alex=="cc_Spanish_0_731" //Spain- Reduzco el cambio negativo - 3.1 //
replace cc_q39d_norm =. if id_alex=="cc_Spanish_0_531" //Spain- Reduzco el cambio negativo - 3.1 //
replace cc_q9c_norm =. if id_alex=="cc_Spanish_1_590_2023" //Spain- Reduzco el cambio negativo - 3.4 //
replace cc_q9c_norm =. if id_alex=="cc_Spanish_0_531" //Spain- Reduzco el cambio negativo - 3.4 //
replace cc_q9c_norm =. if id_alex=="cc_English_0_1967" //Spain- Reduzco el cambio negativo - 3.4 //
replace all_q19_norm =1 if id_alex=="cj_Spanish_1_977" //Spain- Reduzco el cambio negativo - 4.6 //
replace all_q31_norm =1 if id_alex=="cj_Spanish_1_977" //Spain- Reduzco el cambio negativo - 4.6 //
replace lb_q2d_norm =1 if id_alex=="lb_English_1_733_2023" //Spain- Reduzco el cambio negativo - 6.3 //
replace lb_q3d_norm =1 if id_alex=="lb_English_1_733_2023" //Spain- Reduzco el cambio negativo - 6.3 //
replace all_q62_norm =. if id_alex=="lb_English_1_733_2023" //Spain- Reduzco el cambio negativo - 6.3 //
replace all_q63_norm =. if id_alex=="lb_English_1_733_2023" //Spain- Reduzco el cambio negativo - 6.3 //
replace all_q62_norm =. if id_alex=="cc_Spanish_1_661" //Spain- Reduzco el cambio negativo - 6.3 //
replace all_q63_norm =. if id_alex=="cc_Spanish_1_661" //Spain- Reduzco el cambio negativo - 6.3 //
replace all_q62_norm =. if id_alex=="cc_Spanish_0_793" //Spain- Reduzco el cambio negativo - 6.3 //
replace all_q63_norm =. if id_alex=="cc_Spanish_0_793" //Spain- Reduzco el cambio negativo - 6.3 //
replace all_q62_norm =. if id_alex=="cc_Spanish_0_1488" //Spain- Reduzco el cambio negativo - 6.3 //
replace all_q63_norm =. if id_alex=="cc_Spanish_0_1488" //Spain- Reduzco el cambio negativo - 6.3 //
replace all_q62_norm =. if id_alex=="cc_Spanish_0_500_2023" //Spain- Reduzco el cambio negativo - 6.3 //
replace all_q63_norm =. if id_alex=="cc_Spanish_0_500_2023" //Spain- Reduzco el cambio negativo - 6.3 //
replace cc_q14a_norm =. if id_alex=="cc_Spanish_0_1351_2022_2023" //Spain- Reduzco el cambio negativo - 6.5 //
replace cc_q14b_norm =. if id_alex=="cc_Spanish_0_1351_2022_2023" //Spain- Reduzco el cambio negativo - 6.5 //
replace cc_q16b_norm =. if id_alex=="cc_Spanish_0_1662" //Spain- Reduzco el cambio negativo - 6.5 //
replace cc_q16c_norm =. if id_alex=="cc_Spanish_1_386_2023" //Spain- Reduzco el cambio negativo - 6.5 //
replace cc_q16d_norm =. if id_alex=="cc_Spanish_0_1800" //Spain- Reduzco el cambio negativo - 6.5 //
replace cc_q16e_norm =. if id_alex=="cc_Spanish_1_661" //Spain- Reduzco el cambio negativo - 6.5 //
replace cc_q16f_norm =. if id_alex=="cc_Spanish_0_1901" //Spain- Reduzco el cambio negativo - 6.5 //
replace cc_q16g_norm =. if id_alex=="cc_Spanish_0_1489" //Spain- Reduzco el cambio negativo - 6.5 //
replace all_q84_norm =. if id_alex=="cc_Spanish_0_1338" //Spain- Reduzco el cambio negativo - 7.5 //
replace all_q84_norm =. if id_alex=="cc_Spanish_0_276" //Spain- Reduzco el cambio negativo - 7.5 //
replace all_q84_norm =. if id_alex=="cc_Spanish_0_531" //Spain- Reduzco el cambio negativo - 7.5 //
replace all_q85_norm =. if id_alex=="cc_Spanish_0_531" //Spain- Reduzco el cambio negativo - 7.5 //
replace all_q85_norm =. if id_alex=="cc_Spanish_1_577" //Spain- Reduzco el cambio negativo - 7.5 //
replace all_q84_norm =. if id_alex=="cc_Spanish_0_531" //Spain- Reduzco el cambio negativo - 7.5 //
replace all_q85_norm =. if id_alex=="cc_Spanish_0_531" //Spain- Reduzco el cambio negativo - 7.5 //
replace all_q84_norm =. if id_alex=="cc_Spanish_0_276" //Spain- Reduzco el cambio negativo - 7.5 //
replace all_q84_norm =. if id_alex=="cc_Spanish_1_577" //Spain- Reduzco el cambio negativo - 7.5 //
replace all_q85_norm =. if id_alex=="cc_Spanish_1_577" //Spain- Reduzco el cambio negativo - 7.5 //
replace all_q84_norm =. if id_alex=="cc_Spanish_0_359_2023" //Spain- Reduzco el cambio negativo - 7.5 //
replace all_q84_norm =. if id_alex=="cc_Spanish_0_1901" //Spain- Reduzco el cambio negativo - 7.5 //
replace all_q85_norm =. if id_alex=="cc_Spanish_0_1901" //Spain- Reduzco el cambio negativo - 7.5 //
replace all_q84_norm =. if id_alex=="cc_Spanish_0_1707" //Spain- Reduzco el cambio negativo - 7.5 //
replace all_q85_norm =. if id_alex=="cc_Spanish_0_1707" //Spain- Reduzco el cambio negativo - 7.5 //
replace all_q84_norm =. if id_alex=="cc_English_0_1967" //Spain- Reduzco el cambio negativo - 7.5 //
replace all_q84_norm =. if id_alex=="cc_Spanish_1_811" //Spain- Reduzco el cambio negativo - 7.5 //
replace all_q84_norm =. if id_alex=="cc_Spanish_0_599" //Spain- Reduzco el cambio negativo - 7.5 //
replace cc_q26a_norm =. if id_alex=="cc_Spanish_1_817" //Spain- Reduzco el cambio negativo - 7.5 //
replace cc_q26a_norm =. if id_alex=="cc_Spanish_1_1122" //Spain- Reduzco el cambio negativo - 7.5 //
replace cc_q26a_norm =. if id_alex=="cc_Spanish_1_514" //Spain- Reduzco el cambio negativo - 7.5 //
replace cc_q13_norm =. if id_alex=="cc_Spanish_0_1338" //Spain- Reduzco el cambio negativo - 7.5 //
replace cc_q13_norm =. if id_alex=="cc_Spanish_0_276" //Spain- Reduzco el cambio negativo - 7.5 //
replace cc_q13_norm =. if id_alex=="cc_Spanish_0_731" //Spain- Reduzco el cambio negativo - 7.5 //
replace all_q88_norm =. if id_alex=="cc_Spanish_0_988" //Spain- Reduzco el cambio negativo - 7.5 //
replace all_q88_norm =. if id_alex=="cc_English_0_1054" //Spain- Reduzco el cambio negativo - 7.5 //
replace all_q88_norm =. if id_alex=="cc_Spanish_0_1338" //Spain- Reduzco el cambio negativo - 7.5 //
replace all_q88_norm =. if id_alex=="cc_Spanish_0_276" //Spain- Reduzco el cambio negativo - 7.5 //
replace all_q88_norm =. if id_alex=="cc_Spanish_0_731" //Spain- Reduzco el cambio negativo - 7.5 //
replace cc_q26a_norm =. if id_alex=="cc_Spanish_1_811" //Spain- Reduzco el cambio negativo - 7.5 //
replace cc_q26a_norm =. if id_alex=="cc_Spanish_1_548" //Spain- Reduzco el cambio negativo - 7.5 //
replace cc_q26a_norm =. if id_alex=="cc_Spanish_0_648" //Spain- Reduzco el cambio negativo - 7.5 //
replace cc_q26a_norm =. if id_alex=="cc_Spanish_0_1707" //Spain- Reduzco el cambio negativo - 7.5 //
replace cc_q26a_norm =. if id_alex=="cc_Spanish_0_1463" //Spain- Reduzco el cambio negativo - 7.5 //
replace cc_q26a_norm =. if id_alex=="cc_Spanish_0_1852" //Spain- Reduzco el cambio negativo - 7.5 //
replace cc_q26a_norm =. if id_alex=="cc_Spanish_0_603" //Spain- Reduzco el cambio negativo - 7.5 //
replace cc_q26b_norm =. if id_alex=="cc_Spanish_1_817" //Spain- Reduzco el cambio negativo - 7.6 //
replace cc_q26b_norm =. if id_alex=="cc_Spanish_1_1122" //Spain- Reduzco el cambio negativo - 7.6 //
replace cc_q26b_norm =. if id_alex=="cc_Spanish_1_514" //Spain- Reduzco el cambio negativo - 7.6 //
replace cc_q26b_norm =. if id_alex=="cc_Spanish_0_1852" //Spain- Reduzco el cambio negativo - 7.6 //
replace cc_q26b_norm =. if id_alex=="cc_Spanish_0_603" //Spain- Reduzco el cambio negativo - 7.6 //
replace all_q86_norm =. if id_alex=="cc_Spanish_0_1604" //Spain- Reduzco el cambio negativo - 7.6 //
replace all_q87_norm =. if id_alex=="cc_Spanish_0_1604" //Spain- Reduzco el cambio negativo - 7.6 //
replace all_q86_norm =. if id_alex=="cc_Spanish_1_817" //Spain- Reduzco el cambio negativo - 7.6 //
replace all_q86_norm =. if id_alex=="cc_Spanish_0_1463" //Spain- Reduzco el cambio negativo - 7.6 //
replace all_q87_norm =. if id_alex=="cc_Spanish_0_1463" //Spain- Reduzco el cambio negativo - 7.6 //
replace all_q86_norm =. if id_alex=="cc_Spanish_0_1604" //Spain- Reduzco el cambio negativo - 7.6 //
replace all_q87_norm =. if id_alex=="cc_Spanish_0_1604" //Spain- Reduzco el cambio negativo - 7.6 //
replace all_q86_norm =. if id_alex=="cc_Spanish_1_817" //Spain- Reduzco el cambio negativo - 7.6 //
replace all_q86_norm =. if id_alex=="cc_Spanish_0_1463" //Spain- Reduzco el cambio negativo - 7.6 //
replace all_q87_norm =. if id_alex=="cc_Spanish_0_1463" //Spain- Reduzco el cambio negativo - 7.6 //
replace all_q86_norm =. if id_alex=="cc_Spanish_1_514" //Spain- Reduzco el cambio negativo - 7.6 //
replace all_q86_norm =1 if id_alex=="cc_Spanish_0_1521" //Spain- Reduzco el cambio negativo - 7.6 //

*Sri Lanka
drop if id_alex=="cc_English_0_1079" //Sri Lanka (muy positivo)
drop if id_alex=="cj_English_1_348" //Sri Lanka (muy positivo)
drop if id_alex=="lb_English_0_350" //Sri Lanka (muy positivo)
drop if id_alex=="cj_English_0_121" //Sri Lanka (muy negativo)
replace cj_q11b_norm=. if country=="Sri Lanka" // Sri Lanka (se elimino el anio pasado)
replace all_q87_norm=. if country=="Sri Lanka" // Sri Lanka (se elimino el anio pasado)
replace all_q29_norm =. if id_alex=="cj_English_0_121" //Sri Lanka- Reduzco el cambio negativo (Outlier, 1 new CJ) //
replace all_q29_norm =. if id_alex=="cc_English_0_1088_2022_2023" //Sri Lanka- Reduzco el cambio negativo //
replace all_q29_norm =. if id_alex=="cc_English_0_1496_2022_2023" //Sri Lanka- Reduzco el cambio negativo //
replace cj_q38_norm =. if id_alex=="cj_English_0_65" //Sri Lanka- Reduzco el cambio positivo 1.4 //
replace cj_q36c_norm =. if id_alex=="cj_English_0_65" //Sri Lanka- Reduzco el cambio positivo 1.4 //
replace all_q10_norm =. if id_alex=="cc_English_0_224_2023" //Sri Lanka- Reduzco el cambio positivo 1.5 //
replace all_q10_norm =. if id_alex=="cc_English_0_1253_2023" //Sri Lanka- Reduzco el cambio positivo 1.5 //
replace cj_q36a_norm =. if id_alex=="cj_English_1_819" //Sri Lanka- Reduzco el cambio positivo 1.5 //
replace cj_q36b_norm =. if id_alex=="cj_English_1_819" //Sri Lanka- Reduzco el cambio positivo 1.5 //
replace lb_q16b_norm =. if id_alex=="lb_English_0_501_2019_2021_2022_2023" //Sri Lanka- Reduzco el cambio negativo 4.1 //
replace cj_q42c_norm =. if id_alex=="cj_English_0_1068_2017_2018_2019_2021_2022_2023" //Sri Lanka- Reduzco el cambio negativo 4.6 //
replace cj_q42d_norm =. if id_alex=="cj_English_0_1068_2017_2018_2019_2021_2022_2023" //Sri Lanka- Reduzco el cambio negativo 4.6 //
replace cj_q31f_norm =. if id_alex=="cj_English_1_920_2018_2019_2021_2022_2023" //Sri Lanka- Reduzco el cambio negativo 4.6 //
replace all_q89_norm =. if id_alex=="cc_English_0_1141_2023" //Sri Lanka- Reduzco el cambio positivo 7.7 //
replace all_q59_norm =. if id_alex=="cc_English_0_1141_2023" //Sri Lanka- Reduzco el cambio positivo 7.7 //
replace all_q89_norm =. if id_alex=="cc_English_0_545" //Sri Lanka- Reduzco el cambio positivo 7.7 //
replace all_q59_norm =. if id_alex=="cc_English_0_545" //Sri Lanka- Reduzco el cambio positivo 7.7 //

*St. Kitts and Nevis
drop if id_alex=="cj_English_1_409" //St. Kitts and Nevis (muy positivo)
drop if id_alex=="lb_English_0_246" //St. Kitts and Nevis (muy positivo)
replace all_q90_norm=. if country=="St. Kitts and Nevis" // St. Kitts and Nevis (se elimino el anio pasado)
replace cc_q33_norm =. if id_alex=="cc_English_1_1114_2021_2022_2023" //St. Kitts and Nevis- Reduzco el cambio positivo de la pregunta //
replace cc_q9c_norm =. if id_alex=="cc_English_1_1114_2021_2022_2023" //St. Kitts and Nevis- Reduzco el cambio positivo en 3.4 //
replace cc_q40a_norm =. if id_alex=="cc_English_1_1114_2021_2022_2023" //St. Kitts and Nevis- Reduzco el cambio positivo en 3.4 //
replace cj_q11b_norm =. if id_alex=="cj_English_0_718_2017_2018_2019_2021_2022_2023" //St. Kitts and Nevis- Reduzco el cambio negativo en 4.2 //
replace cj_q42c_norm =. if id_alex=="cj_English_0_731_2017_2018_2019_2021_2022_2023" //St. Kitts and Nevis- Reduzco el cambio negativo en 4.6 //
replace lb_q16a_norm =.6666667 if id_alex=="lb_English_0_162_2016_2017_2018_2019_2021_2022_2023" //St. Kitts and Nevis- Reduzco el cambio positivo en 4.8 //
replace lb_q19a_norm =. if id_alex=="lb_English_0_577_2016_2017_2018_2019_2021_2022_2023" //St. Kitts and Nevis- Reduzco el cambio negativo en 6.4 //
replace cc_q26b_norm =. if id_alex=="cc_English_1_1114_2021_2022_2023" //St. Kitts and Nevis- Reduzco el cambio positivo en 7.6 //
replace all_q89_norm =.6666667 if id_alex=="lb_English_0_580" //St. Kitts and Nevis- Reduzco el cambio positivo en 7.7 //

*St. Lucia
drop if id_alex=="cj_English_0_596" //St. Lucia (muy positivo)
drop if id_alex=="cj_English_1_923_2018_2019_2021_2022_2023" //St. Lucia (muy positivo)
replace all_q2_norm =. if id_alex=="cc_English_1_1467_2022_2023" //St. Lucia - Reduzco el puntaje 1.2 (consistente con long) //
replace all_q2_norm =. if id_alex=="cc_English_1_1256_2023" //St. Lucia - Reduzco el puntaje 1.2 (consistente con long) //
replace all_q3_norm =. if id_alex=="cc_English_1_1467_2022_2023" //St. Lucia - Reduzco el puntaje 1.2 (consistente con long) //
replace all_q3_norm =. if id_alex=="lb_English_0_428" //St. Lucia - Reduzco el puntaje 1.2 (consistente con long) //
replace cj_q36c_norm =. if id_alex=="cj_English_1_576_2018_2019_2021_2022_2023" //St. Lucia - Cambio muy grande en las preguntas - Ajusto a la alza 4.8 //
replace cj_q36b_norm =. if id_alex=="cj_English_1_576_2018_2019_2021_2022_2023" //St. Lucia - Cambio muy grande en la pregunta - Ajusto a la baja //
replace cj_q36a_norm =. if id_alex=="cj_English_1_576_2018_2019_2021_2022_2023" //St. Lucia - Cambio muy grande en la pregunta - Ajusto a la baja //
replace all_q12_norm =. if id_alex=="cj_English_1_576_2018_2019_2021_2022_2023" //St. Lucia - Cambio muy grande en la pregunta - Ajusto a la baja //
replace all_q12_norm =. if id_alex=="cc_English_1_1256_2023" //St. Lucia - Cambio muy grande en la pregunta - Ajusto a la baja //
replace all_q53_norm =. if id_alex=="lb_English_0_294" //St. Lucia - Cambio muy grande en la pregunta - Ajusto a la baja //
replace all_q53_norm =. if id_alex=="lb_English_0_428" //St. Lucia - Cambio muy grande en la pregunta - Ajusto a la baja //
replace cj_q10_norm =. if id_alex=="cj_English_0_531_2016_2017_2018_2019_2021_2022_2023" //St. Lucia - Cambio muy grande en la pregunta - Ajusto a la baja 1.6 //
replace all_q26_norm =. if id_alex=="cc_English_0_241_2017_2018_2019_2021_2022_2023" //St. Lucia - Cambio muy grande en la pregunta - Ajusto a la baja 1.7 //
replace cj_q22b_norm =. if id_alex=="cj_English_0_619_2019_2021_2022_2023" //St. Lucia - Cambio muy grande en la pregunta - Ajusto a la baja 4.3 //
replace cj_q22a_norm =. if id_alex=="cj_English_0_531_2016_2017_2018_2019_2021_2022_2023" //St. Lucia - Cambio muy grande en la pregunta - Ajusto a la baja 4.3 //
replace cj_q22a_norm =. if id_alex=="cj_English_0_619_2019_2021_2022_2023" //St. Lucia - Cambio muy grande en la pregunta - Ajusto a la baja 4.3 //
replace cj_q22a_norm =. if id_alex=="cj_English_1_576_2018_2019_2021_2022_2023" //St. Lucia - Cambio muy grande en la pregunta - Ajusto a la baja 4.3 //
replace cj_q19e_norm =. if id_alex=="cj_English_1_576_2018_2019_2021_2022_2023" //St. Lucia - Cambio muy grande en la pregunta - Ajusto a la baja 4.3 //
replace cj_q2_norm =. if id_alex=="cj_English_0_531_2016_2017_2018_2019_2021_2022_2023" //St. Lucia - Cambio muy grande en la pregunta - Ajusto a la baja 4.3 //
replace cj_q25b_norm =. if id_alex=="cj_English_0_619_2019_2021_2022_2023" //St. Lucia - Cambio muy grande en la pregunta - Ajusto a la baja 4.3 //
replace all_q29_norm =. if id_alex=="cc_English_1_1256_2023" //St. Lucia - Cambio muy grande en la pregunta - Ajusto a la baja 4.5 /
replace all_q30_norm =. if id_alex=="cc_English_1_1256_2023" //St. Lucia - Cambio muy grande en la pregunta - Ajusto a la baja 4.5 /
replace cj_q31f_norm =.3333333 if id_alex=="cj_English_1_576_2018_2019_2021_2022_2023" //St. Lucia - Cambio muy grande en la pregunta - Ajusto a la baja 4.6 /
replace lb_q23f_norm =. if id_alex=="lb_English_0_294" //St. Lucia - Cambio muy grande en las preguntas - Ajusto a la alza 4.8 //
replace lb_q23g_norm =. if id_alex=="lb_English_0_294" //St. Lucia - Cambio muy grande en las preguntas - Ajusto a la alza 4.8 //
replace cj_q15_norm =. if id_alex=="cj_English_0_619_2019_2021_2022_2023" //St. Lucia - Cambio muy grande en las preguntas - Ajusto a la baja 5.3 //

*St. Vincent and the Grenadines
drop if id_alex=="cc_English_1_1489_2019_2021_2022_2023" //St. Vincent and the Grenadines (muy negativo)
drop if id_alex=="cc_English_1_784" //St. Vincent and the Grenadines (muy negativo)
drop if id_alex=="ph_English_0_183" //St. Vincent and the Grenadines (muy negativo)
replace all_q21_norm=. if country=="St. Vincent and the Grenadines" // St. Vincent and the Grenadines (se elimino el anio pasado)
replace all_q19_norm=. if country=="St. Vincent and the Grenadines" // St. Vincent and the Grenadines (se elimino el anio pasado)
replace cc_q40b_norm=. if country=="St. Vincent and the Grenadines" // St. Vincent and the Grenadines (se elimino el anio pasado)
replace cj_q31d_norm=. if country=="St. Vincent and the Grenadines" // St. Vincent and the Grenadines (se elimino el anio pasado)
replace cj_q22c_norm=. if country=="St. Vincent and the Grenadines" // St. Vincent and the Grenadines (se elimino el anio pasado)
replace all_q1_norm =. if id_alex=="cc_English_0_1258_2023" //St. Vincent and the Grenadines - Reduzco cambio negativo en la pregunta en 1.2 //
replace all_q1_norm =. if id_alex=="cc_English_0_1570" //St. Vincent and the Grenadines - Reduzco cambio negativo en la pregunta en 1.2 //
replace all_q41_norm =. if id_alex=="cc_English_1_1151" //St. Vincent and the Grenadines - Reduzco cambio negativo 3.2 //
replace all_q42_norm =. if id_alex=="cc_English_1_1151" //St. Vincent and the Grenadines - Reduzco cambio negativo 3.2 //
replace all_q43_norm =. if id_alex=="cc_English_1_1151" //St. Vincent and the Grenadines - Reduzco cambio negativo 3.2 //
replace all_q44_norm =. if id_alex=="cc_English_1_1151" //St. Vincent and the Grenadines - Reduzco cambio negativo 3.2 //
replace all_q45_norm =. if id_alex=="cc_English_1_1151" //St. Vincent and the Grenadines - Reduzco cambio negativo 3.2 //
replace all_q46_norm =. if id_alex=="cc_English_1_1151" //St. Vincent and the Grenadines - Reduzco cambio negativo 3.2 //
replace all_q47_norm =. if id_alex=="cc_English_1_1151" //St. Vincent and the Grenadines - Reduzco cambio negativo 3.2 //
replace all_q41_norm =. if id_alex=="lb_English_1_436" //St. Vincent and the Grenadines - Reduzco cambio negativo 3.2 //
replace all_q42_norm =. if id_alex=="lb_English_1_436" //St. Vincent and the Grenadines - Reduzco cambio negativo 3.2 //
replace all_q43_norm =. if id_alex=="lb_English_1_436" //St. Vincent and the Grenadines - Reduzco cambio negativo 3.2 //
replace all_q44_norm =. if id_alex=="lb_English_1_436" //St. Vincent and the Grenadines - Reduzco cambio negativo 3.2 //
replace all_q45_norm =. if id_alex=="lb_English_1_436" //St. Vincent and the Grenadines - Reduzco cambio negativo 3.2 //
replace all_q46_norm =. if id_alex=="lb_English_1_436" //St. Vincent and the Grenadines - Reduzco cambio negativo 3.2 //
replace all_q47_norm =. if id_alex=="lb_English_1_436" //St. Vincent and the Grenadines - Reduzco cambio negativo 3.2 //
replace all_q41_norm =. if id_alex=="lb_English_0_340" //St. Vincent and the Grenadines - Reduzco cambio negativo 3.2 //
replace all_q42_norm =. if id_alex=="lb_English_0_340" //St. Vincent and the Grenadines - Reduzco cambio negativo 3.2 //
replace all_q43_norm =. if id_alex=="lb_English_0_340" //St. Vincent and the Grenadines - Reduzco cambio negativo 3.2 //
replace all_q47_norm =. if id_alex=="lb_English_0_340" //St. Vincent and the Grenadines - Reduzco cambio negativo 3.2 //
replace all_q31_norm =. if id_alex=="cj_English_0_649" //St. Vincent and the Grenadines - Reduzco cambio negativo 4.7 //
replace all_q31_norm =. if id_alex=="cc_English_0_1144_2019_2021_2022_2023" //St. Vincent and the Grenadines - Reduzco cambio negativo 4.7 //
replace all_q32_norm =. if id_alex=="cj_English_0_649" //St. Vincent and the Grenadines - Reduzco cambio negativo 4.7 //
replace all_q14_norm =. if id_alex=="cc_English_1_1151" //St. Vincent and the Grenadines - Reduzco cambio negativo 4.7 //
replace  cj_q15_norm =. if id_alex=="cj_English_0_832" //St. Vincent and the Grenadines - Reduzco cambio negativo 5.3 //
replace  lb_q19a_norm =. if id_alex=="lb_English_0_340" //St. Vincent and the Grenadines - Reduzco cambio negativo 5.3 //
replace all_q80_norm =. if id_alex=="lb_English_1_454" //St. Vincent and the Grenadines - Reduzco cambio negativo 7.2 //
replace all_q80_norm =. if id_alex=="cc_English_0_1181_2023" //St. Vincent and the Grenadines - Reduzco cambio negativo 7.2 //
replace all_q81_norm =. if id_alex=="lb_English_1_454" //St. Vincent and the Grenadines - Reduzco cambio negativo 7.2 //
replace all_q82_norm =. if id_alex=="cc_English_1_1151" //St. Vincent and the Grenadines - Reduzco cambio negativo 7.2 //
replace all_q6_norm =. if id_alex=="cc_English_0_1589_2018_2019_2021_2022_2023" //St. Vincent and the Grenadines - Reduzco cambio negativo 7.4 //
replace all_q6_norm =. if id_alex=="cc_English_0_1144_2019_2021_2022_2023" //St. Vincent and the Grenadines - Reduzco cambio negativo 7.4 //
replace all_q6_norm =0.5 if id_alex=="lb_English_0_340" //St. Vincent and the Grenadines - Reduzco cambio negativo 7.4 //
replace all_q86_norm =. if id_alex=="cc_English_0_1570" //St. Vincent and the Grenadines - Reduzco cambio negativo 7.6 //
replace all_q87_norm =. if id_alex=="cc_English_0_1570" //St. Vincent and the Grenadines - Reduzco cambio negativo 7.6 //
replace all_q89_norm =. if id_alex=="cc_English_1_1151" //St. Vincent and the Grenadines - Reduzco cambio negativo 7.7 //
replace all_q89_norm =. if id_alex=="cc_English_0_1417" //St. Vincent and the Grenadines - Reduzco cambio negativo 7.7 //
replace all_q90_norm =. if id_alex=="cc_English_0_1417" //St. Vincent and the Grenadines - Reduzco cambio negativo 7.7 //
replace all_q91_norm =. if id_alex=="cc_English_0_1417" //St. Vincent and the Grenadines - Reduzco cambio negativo 7.7 //
replace all_q91_norm =. if id_alex=="cc_English_0_853" //St. Vincent and the Grenadines - Reduzco cambio negativo 7.7 //
replace cc_q14a_norm =. if id_alex=="cc_English_0_1417" //St. Vincent and the Grenadines - Reduzco cambio negativo 7.7 //

*Sudan
drop if id_alex=="cc_English_0_1278" //Sudan (muy positivo)
drop if id_alex=="lb_English_0_230" //Sudan (muy positivo)
drop if id_alex=="cj_Arabic_1_119" //Sudan (muy positivo)
replace cc_q12_norm=. if country=="Sudan" // Sudan (se elimino el anio pasado)
replace cj_q27b_norm=. if country=="Sudan" // Sudan (se elimino el anio pasado)
replace all_q22_norm=. if country=="Sudan" // Sudan (se elimino el anio pasado)
replace all_q23_norm=. if country=="Sudan" // Sudan (se elimino el anio pasado)
replace cj_q42c_norm=. if country=="Sudan" // Sudan (se elimino el anio pasado)
replace cj_q42d_norm=. if country=="Sudan" // Sudan (se elimino el anio pasado)
replace all_q1_norm =. if id_alex=="cc_English_1_451_2022_2023" //Sudan - Reduzco cambio positivo en la pregunta  //
replace all_q1_norm =. if id_alex=="cj_Arabic_0_309_2022_2023" //Sudan - Reduzco cambio positivo en la pregunta  //
replace all_q96_norm =. if id_alex=="cj_English_0_569" //Sudan - Reduzco cambio negativo en la pregunta  //
replace all_q96_norm =. if id_alex=="lb_English_1_603" //Sudan - Reduzco cambio negativo en la pregunta  //
replace cj_q11b_norm =. if id_alex=="cj_English_0_145_2022_2023" //Sudan - Reduzco cambio positivo en la pregunta  //
replace cc_q26h_norm =. if id_alex=="cc_English_1_202" //Sudan - Reduzco cambio positivo en la pregunta en 2.2 //
replace cc_q28e_norm =. if id_alex=="cc_English_1_202" //Sudan - Reduzco cambio positivo en la pregunta en 2.2 //
replace all_q57_norm =. if id_alex=="cc_English_1_202" //Sudan - Reduzco cambio positivo en la pregunta en 2.2 //
replace cj_q32b_norm =. if id_alex=="cj_Arabic_0_70_2022_2023" //Sudan - Reduzco cambio positivo en la pregunta en 2.2 //
replace cj_q32b_norm =. if id_alex=="cj_Arabic_0_70_2022_2023" //Sudan - Reduzco cambio positivo en la pregunta en 2.2 //
replace cc_q9c_norm =.3333333 if id_alex=="cc_English_0_383_2022_2023" //Sudan - Reduzco cambio positivo en la pregunta en 3.4 //
replace cc_q9c_norm =.3333333 if id_alex=="cc_English_0_305_2023" //Sudan - Reduzco cambio positivo en la pregunta en 3.4 //
replace all_q29_norm =. if id_alex=="cj_English_0_1107" //Sudan - Reduzco cambio negativo en la pregunta en 4.5 //
replace all_q29_norm =. if id_alex=="cj_English_0_569" //Sudan - Reduzco cambio negativo en la pregunta en 4.5 //
replace all_q30_norm =. if id_alex=="cc_English_0_383_2022_2023" //Sudan - Reduzco cambio negativo en la pregunta en 4.5 //
replace lb_q23f_norm =. if id_alex=="lb_English_1_603" //Sudan - Reduzco cambio negativo en la pregunta en 4.8 //
replace lb_q23g_norm =. if id_alex=="lb_English_1_603" //Sudan - Reduzco cambio negativo en la pregunta en 4.8 //
replace lb_q19a_norm =.6666667 if id_alex=="lb_English_0_61_2022_2023" //Sudan - Reduzco cambio negativo en la pregunta en 6.4 //
replace all_q80_norm =. if id_alex=="lb_English_1_603" //Sudan - Reduzco cambio negativo en la pregunta en 7.2 //
replace all_q81_norm =. if id_alex=="lb_English_1_603" //Sudan - Reduzco cambio negativo en la pregunta en 7.2 //
replace all_q81_norm =. if id_alex=="cc_English_1_202" //Sudan - Reduzco cambio negativo en la pregunta en 7.2 //
replace all_q81_norm =. if id_alex=="lb_Arabic_0_451_2021_2022_2023" //Sudan - Reduzco cambio negativo en la pregunta en 7.2 //
replace all_q82_norm =. if id_alex=="lb_English_0_61_2022_2023" //Sudan - Reduzco cambio negativo en la pregunta en 7.2 //
replace cj_q20o_norm =. if id_alex=="cj_English_0_569" //Sudan - Reduzco cambio positivo en la pregunta en 8.4 //

*Suriname
drop if id_alex=="cj_English_0_134" //Suriname (muy positivo)
drop if id_alex=="cj_English_1_282" //Suriname (muy positivo)
drop if id_alex=="lb_English_0_531" //Suriname (muy positivo)
replace all_q10_norm =. if id_alex=="cc_English_0_781" //Suriname - Reduzco cambio positivo en la pregunta  //
replace all_q12_norm =. if id_alex=="cc_English_0_781" //Suriname - Reduzco cambio positivo en la pregunta  //
replace cc_q13_norm =. if id_alex=="cc_English_1_706" //Suriname - Reduzco cambio positivo en la pregunta  //
replace cc_q26a_norm =. if id_alex=="cc_English_1_706" //Suriname - Reduzco cambio positivo en la pregunta  //
replace all_q84_norm =. if id_alex=="cc_English_0_284_2016_2017_2018_2019_2021_2022_2023" //Suriname - Reduzco cambio positivo en la pregunta  //

*Sweden
drop if id_alex=="cj_English_0_318" //Sweden (muy negativo)
drop if id_alex=="cj_English_0_1207" //Sweden (muy negativo)
drop if id_alex=="cj_English_1_834_2023" //Sweden (muy negativo)
replace cj_q38_norm =. if id_alex=="cj_English_0_1196" //Sweden - Reduzco cambio negativo en 1.4  //
replace cj_q36c_norm =. if id_alex=="cj_English_0_878_2023" //Sweden - Reduzco cambio negativo en 1.4  //
replace cj_q36c_norm =. if id_alex=="cj_English_0_410" //Sweden - Reduzco cambio negativo en 1.4  //
replace cj_q8_norm =. if id_alex=="cj_English_0_410" //Sweden - Reduzco cambio negativo en 1.4  //
replace all_q96_norm =. if id_alex=="cc_English_1_100_2022_2023" //Sweden - Reduzco cambio positivo en 2.4  //
replace all_q96_norm =. if id_alex=="cc_English_1_1071_2022_2023" //Sweden - Reduzco cambio positivo en 2.4  //
replace all_q96_norm =. if id_alex=="lb_English_0_733_2018_2019_2021_2022_2023" //Sweden - Reduzco cambio positivo en 2.4  //
replace all_q96_norm =. if id_alex=="lb_English_1_560_2018_2019_2021_2022_2023" //Sweden - Reduzco cambio positivo en 2.4  //
replace cc_q9b_norm =. if id_alex=="cc_English_0_1991" //Sweden - Reduzco cambio negativo en 3.2  //
replace cc_q39a_norm =. if id_alex=="cc_English_0_1991" //Sweden - Reduzco cambio negativo en 3.2  //
replace cc_q39b_norm =. if id_alex=="cc_English_0_1991" //Sweden - Reduzco cambio negativo en 3.2  //
replace cc_q39c_norm =. if id_alex=="cc_English_0_1991" //Sweden - Reduzco cambio negativo en 3.2  //
replace cc_q39d_norm =. if id_alex=="cc_English_0_1991" //Sweden - Reduzco cambio negativo en 3.2  //
replace all_q42_norm =. if id_alex=="cc_English_0_1368" //Sweden - Reduzco cambio negativo en 3.2  //
replace all_q43_norm =. if id_alex=="cc_English_0_540" //Sweden - Reduzco cambio negativo en 3.2  //
replace cc_q9c_norm =. if id_alex=="cc_English_0_1991" //Sweden - Reduzco cambio negativo en 3.4  //
replace cc_q9c_norm =. if id_alex=="cc_English_0_540" //Sweden - Reduzco cambio negativo en 3.4  //
replace all_q75_norm =. if id_alex=="cc_English_1_1071_2022_2023" //Sweden - Reduzco cambio positivo en 7.1  //
replace all_q75_norm =. if id_alex=="cc_English_1_1023_2022_2023" //Sweden - Reduzco cambio positivo en 7.1  //
replace all_q75_norm =. if id_alex=="lb_English_0_733_2018_2019_2021_2022_2023" //Sweden - Reduzco cambio positivo en 7.1  //
replace all_q75_norm =. if id_alex=="lb_English_0_553" //Sweden - Reduzco cambio positivo en 7.1  //
replace all_q71_norm =. if id_alex=="lb_English_0_703_2017_2018_2019_2021_2022_2023" //Sweden - Reduzco cambio positivo en 7.1  //
replace all_q71_norm =. if id_alex=="cc_English_1_1071_2022_2023" //Sweden - Reduzco cambio positivo en 7.1  //
replace all_q72_norm =. if id_alex=="cc_English_1_1071_2022_2023" //Sweden - Reduzco cambio positivo en 7.1  //
replace all_q71_norm =. if id_alex=="cc_English_0_1506" //Sweden - Reduzco cambio positivo en 7.1  //
replace all_q71_norm =. if id_alex=="cc_English_1_869" //Sweden - Reduzco cambio positivo en 7.1  //
replace all_q69_norm =. if id_alex=="cc_English_1_1071_2022_2023" //Sweden - Reduzco cambio positivo en 7.1  //
replace all_q76_norm =. if id_alex=="cc_English_0_213_2023" //Sweden - Reduzco cambio positivo en 7.2  //
replace all_q77_norm =. if id_alex=="cc_English_0_213_2023" //Sweden - Reduzco cambio positivo en 7.2  //
replace all_q78_norm =. if id_alex=="cc_English_0_213_2023" //Sweden - Reduzco cambio positivo en 7.2  //
replace all_q79_norm =. if id_alex=="cc_English_0_213_2023" //Sweden - Reduzco cambio positivo en 7.2  //
replace all_q80_norm =. if id_alex=="cc_English_0_213_2023" //Sweden - Reduzco cambio positivo en 7.2  //
replace all_q81_norm =. if id_alex=="cc_English_0_213_2023" //Sweden - Reduzco cambio positivo en 7.2  //
replace all_q82_norm =. if id_alex=="cc_English_0_213_2023" //Sweden - Reduzco cambio positivo en 7.2  //
replace all_q76_norm =. if id_alex=="cc_English_1_641" //Sweden - Reduzco cambio positivo en 7.2  //
replace all_q77_norm =. if id_alex=="cc_English_1_641" //Sweden - Reduzco cambio positivo en 7.2  //
replace all_q78_norm =. if id_alex=="cc_English_1_641" //Sweden - Reduzco cambio positivo en 7.2  //
replace all_q79_norm =. if id_alex=="cc_English_1_641" //Sweden - Reduzco cambio positivo en 7.2  //
replace all_q80_norm =. if id_alex=="cc_English_1_641" //Sweden - Reduzco cambio positivo en 7.2  //
replace all_q81_norm =. if id_alex=="cc_English_1_641" //Sweden - Reduzco cambio positivo en 7.2  //
replace all_q82_norm =. if id_alex=="cc_English_1_641" //Sweden - Reduzco cambio positivo en 7.2  //
replace all_q76_norm =. if id_alex=="cc_English_0_1991" //Sweden - Reduzco cambio positivo en 7.2  //
replace all_q77_norm =. if id_alex=="cc_English_0_1991" //Sweden - Reduzco cambio positivo en 7.2  //
replace all_q78_norm =. if id_alex=="cc_English_0_1991" //Sweden - Reduzco cambio positivo en 7.2  //
replace all_q79_norm =. if id_alex=="cc_English_0_1991" //Sweden - Reduzco cambio positivo en 7.2  //
replace all_q80_norm =. if id_alex=="cc_English_0_1991" //Sweden - Reduzco cambio positivo en 7.2  //
replace all_q81_norm =. if id_alex=="cc_English_0_1991" //Sweden - Reduzco cambio positivo en 7.2  //
replace all_q82_norm =. if id_alex=="cc_English_0_1991" //Sweden - Reduzco cambio positivo en 7.2  //
replace all_q76_norm =. if id_alex=="lb_English_1_287" //Sweden - Reduzco cambio positivo en 7.2  //
replace all_q77_norm =. if id_alex=="lb_English_1_287" //Sweden - Reduzco cambio positivo en 7.2  //
replace all_q78_norm =. if id_alex=="lb_English_1_287" //Sweden - Reduzco cambio positivo en 7.2  //
replace all_q79_norm =. if id_alex=="lb_English_1_287" //Sweden - Reduzco cambio positivo en 7.2  //
replace all_q80_norm =. if id_alex=="lb_English_1_287" //Sweden - Reduzco cambio positivo en 7.2  //
replace all_q81_norm =. if id_alex=="lb_English_1_287" //Sweden - Reduzco cambio positivo en 7.2  //
replace all_q82_norm =. if id_alex=="lb_English_1_287" //Sweden - Reduzco cambio positivo en 7.2  //

*Tanzania
drop if id_alex=="cj_English_1_813" //Tanzania (muy positivo)
drop if id_alex=="lb_English_0_400" //Tanzania (muy positivo)

*Thailand
drop if id_alex=="cj_English_1_179" //Thailand (muy positivo)
drop if id_alex=="cc_English_1_446" //Thailand (muy positivo)
drop if id_alex=="cc_English_1_1032" //Thailand (muy positivo)
drop if id_alex=="lb_English_0_283" //Thailand (muy positivo)
drop if id_alex=="ph_English_0_84" //Thailand (muy positivo)
replace all_q29_norm=. if country=="Thailand" // Thailand (se elimino el anio pasado)
replace cj_q21a_norm=. if country=="Thailand" // Thailand (se elimino el anio pasado)
replace all_q59_norm=. if country=="Thailand" // Thailand (se elimino el anio pasado)
replace all_q85_norm=. if country=="Thailand" // Thailand (se elimino el anio pasado)
replace all_q89_norm=. if country=="Thailand" // Thailand (se elimino el anio pasado)
replace cj_q21h_norm=. if country=="Thailand" // Thailand (se elimino el anio pasado)
replace all_q1_norm =. if id_alex=="cc_English_0_625_2016_2017_2018_2019_2021_2022_2023" //Thailand - Reduzco cambio positivo en 1.1  //
replace all_q1_norm =. if id_alex=="cc_English_1_90" //Thailand - Reduzco cambio positivo en 1.1  //
replace cc_q33_norm =. if id_alex=="cc_English_0_625_2016_2017_2018_2019_2021_2022_2023" //Thailand - Reduzco cambio positivo en 1.4  //
replace cj_q9_norm =. if id_alex=="cj_English_0_927_2017_2018_2019_2021_2022_2023" //Thailand - Reduzco cambio positivo en 1.6  //
replace cj_q9_norm =. if id_alex=="cj_English_0_1010_2021_2022_2023" //Thailand - Reduzco cambio positivo en 1.6  //
replace all_q88_norm =. if id_alex=="lb_English_1_506" //Thailand - Reduzco cambio positivo en 7.5  //
replace cc_q14a_norm =. if id_alex=="cc_English_0_530_2019_2021_2022_2023" //Thailand - Reduzco cambio positivo en 7.7  //
replace cj_q28_norm =. if id_alex=="cj_English_0_252" //Thailand - Reduzco cambio positivo en 8.3  //
replace cj_q20m_norm =. if id_alex=="cj_English_0_988_2023" //Thailand - Reduzco cambio negativo en 8.6  //

*Togo
replace all_q22_norm=. if country=="Togo" // Togo (se elimino el anio pasado)
replace all_q24_norm=. if country=="Togo" // Togo (se elimino el anio pasado)
replace all_q2_norm=. if country=="Togo" // Togo (se elimino el anio pasado)
replace cc_q25_norm =. if id_alex=="cc_French_1_1140_2023" //Togo - Pequeno cambio positivo en la pregunta en 1.3  //
replace all_q8_norm =. if id_alex=="cj_French_0_835_2023" //Togo - Pequeno cambio positivo en la pregunta en 1.7  //
replace all_q26_norm =. if id_alex=="cj_French_0_835_2023" //Togo - Pequeno cambio positivo en la pregunta en 1.7  //
replace all_q23_norm =. if id_alex=="cj_French_0_835_2023" //Togo - Reduzco el cambio positivo 1.7 (Q)  //
replace all_q25_norm =. if id_alex=="cj_French_0_835_2023" //Togo - Reduzco el cambio positivo 1.7 (Q)  //
replace all_q27_norm =. if id_alex=="cj_French_0_835_2023" //Togo - Reduzco el cambio positivo 1.7 (Q)  //
replace all_q23_norm =. if id_alex=="cc_French_0_1306_2022_2023" //Togo - Reduzco el cambio positivo 1.7 (Q)  //
replace all_q25_norm =. if id_alex=="cc_French_0_1306_2022_2023" //Togo - Reduzco el cambio positivo 1.7 (Q)  //
replace all_q26_norm =. if id_alex=="cc_French_0_1306_2022_2023" //Togo - Reduzco el cambio positivo 1.7 (Q)  //
replace all_q27_norm =. if id_alex=="cc_French_0_1306_2022_2023" //Togo - Reduzco el cambio positivo 1.7 (Q)  //
replace all_q8_norm =. if id_alex=="cc_French_0_1306_2022_2023" //Togo - Reduzco el cambio positivo 1.7 (Q)  //
replace all_q23_norm =. if id_alex=="lb_French_1_531_2022_2023" //Togo - Reduzco el cambio positivo 1.7 (Q)  //
replace all_q25_norm =. if id_alex=="lb_French_1_531_2022_2023" //Togo - Reduzco el cambio positivo 1.7 (Q)  //
replace all_q26_norm =. if id_alex=="lb_French_1_531_2022_2023" //Togo - Reduzco el cambio positivo 1.7 (Q)  //
replace all_q27_norm =. if id_alex=="lb_French_1_531_2022_2023" //Togo - Reduzco el cambio positivo 1.7 (Q)  //
replace all_q8_norm =. if id_alex=="lb_French_1_531_2022_2023" //Togo - Reduzco el cambio positivo 1.7 (Q)  //
replace all_q25_norm =. if id_alex=="cj_French_1_375" //Togo - Reduzco el cambio positivo 1.7 (Q)  //
replace all_q27_norm =. if id_alex=="cj_French_1_375" //Togo - Reduzco el cambio positivo 1.7 (Q)  //
replace all_q23_norm =. if id_alex=="cc_French_1_1183_2023" //Togo - Reduzco el cambio positivo 1.7 (Q)  //
replace all_q25_norm =. if id_alex=="cc_French_1_1183_2023" //Togo - Reduzco el cambio positivo 1.7 (Q)  //
replace all_q26_norm =. if id_alex=="cc_French_1_1183_2023" //Togo - Reduzco el cambio positivo 1.7 (Q)  //
replace all_q27_norm =. if id_alex=="cc_French_1_1183_2023" //Togo - Reduzco el cambio positivo 1.7 (Q)  //
replace all_q8_norm =. if id_alex=="cc_French_1_1183_2023" //Togo - Reduzco el cambio positivo 1.7 (Q)  //
replace lb_q23g_norm =. if id_alex=="lb_French_1_193_2019_2021_2022_2023" //Togo - Cambio grande en 4.8  //
replace lb_q23f_norm =. if id_alex=="lb_French_0_104_2021_2022_2023" //Togo - Cambio grande en 4.8  //
replace all_q48_norm =. if id_alex=="cc_French_1_1301_2021_2022_2023" //Togo - Cambio grande en la pregunta eb 6.4 (el cambio en lb_q19a_norm es probablemente un ajuste)  //
replace all_q49_norm =. if id_alex=="cc_French_1_1301_2021_2022_2023" //Togo - Cambio grande en la pregunta eb 6.4 (el cambio en lb_q19a_norm es probablemente un ajuste)  //
replace all_q48_norm =. if id_alex=="cc_English_0_1621_2021_2022_2023" //Togo - Cambio grande en la pregunta eb 6.4 (el cambio en lb_q19a_norm es probablemente un ajuste)  //
replace all_q49_norm =. if id_alex=="cc_English_0_1621_2021_2022_2023" //Togo - Cambio grande en la pregunta eb 6.4 (el cambio en lb_q19a_norm es probablemente un ajuste)  //
replace cc_q26b_norm =. if id_alex=="cc_English_0_1621_2021_2022_2023" //Togo - Reduzco el cambio negativo en 7.6  //
replace cc_q26b_norm =. if id_alex=="cc_French_0_796_2018_2019_2021_2022_2023" //Togo - Reduzco el cambio negativo en 7.6  //
replace all_q89_norm =. if id_alex=="cc_French_0_1413_2018_2019_2021_2022_2023" //Togo - Reduzco el cambio positivo en 7.7  //
replace all_q89_norm =. if id_alex=="cc_English_0_1297_2018_2019_2021_2022_2023" //Togo - Reduzco el cambio positivo en 7.7  //
replace all_q59_norm =. if id_alex=="cc_French_0_1413_2018_2019_2021_2022_2023" //Togo - Reduzco el cambio positivo en 7.7  //
replace cj_q20o_norm =0.6666667 if id_alex=="cj_French_1_596_2022_2023" //Togo - Reduzco el cambio negativo en 8.4  //
replace cj_q20o_norm =0.6666667 if id_alex=="cj_French_0_455_2021_2022_2023" //Togo - Reduzco el cambio negativo en 8.4  //
replace cj_q40b_norm =. if id_alex=="cj_French_1_375" //Togo - Reduzco el cambio positivo en 8.6  //
replace cj_q40c_norm =. if id_alex=="cj_French_1_375" //Togo - Reduzco el cambio positivo en 8.6  //

*Trinidad and Tobago
drop if id_alex=="cj_English_0_622" // Trinidad and Tobago (muy negativo)
drop if id_alex=="cj_English_0_499" // Trinidad and Tobago (muy negativo)
replace cc_q33_norm =. if id_alex=="cc_English_0_759" //Trinidad and Tobago - Cambio positivo en la pregunta en 1.4  //
replace cc_q26h_norm =. if id_alex=="cc_English_0_759" //Trinidad and Tobago - Cambio positivo en la pregunta en 2.2  //
replace cc_q28e_norm =. if id_alex=="cc_English_0_759" //Trinidad and Tobago - Cambio positivo en la pregunta en 2.2  //
replace all_q96_norm =. if id_alex=="cc_English_1_953_2023" //Trinidad and Tobago - Cambio muy negativo en la pregunta en 2.4  //  
replace all_q96_norm =. if id_alex=="cc_English_0_1016_2023" //Trinidad and Tobago - Cambio muy negativo en la pregunta en 2.4  //  
replace all_q96_norm =. if id_alex=="lb_English_1_711_2023" //Trinidad and Tobago - Cambio muy negativo en la pregunta en 2.4  //  
replace cc_q39e_norm =. if id_alex=="cc_English_1_1466_2022_2023" //Trinidad and Tobago - Cambio positivo en la pregunta en 3.2  //
replace cc_q40b_norm =. if id_alex=="cc_English_1_1466_2022_2023" //Trinidad and Tobago - Cambio positivo en la pregunta en 3.4  //
replace all_q29_norm =. if id_alex=="cc_English_0_872" //Trinidad and Tobago - Cambio positivo en la pregunta en 4.5  //
replace all_q62_norm =. if id_alex=="cc_English_1_1466_2022_2023" //Trinidad and Tobago - Pequeno ajuste en 6.3 (contrario a long)  //
replace all_q63_norm =. if id_alex=="cc_English_1_1466_2022_2023" //Trinidad and Tobago - Pequeno ajuste en 6.3 (contrario a long)  //
replace all_q80_norm =. if id_alex=="cc_English_1_783" //Trinidad and Tobago - Cambio negativo en la pregunta en 7.2  //
replace all_q80_norm =. if id_alex=="lb_English_0_420_2023" //Trinidad and Tobago - Cambio negativo en la pregunta en 7.2  //
replace cc_q26a_norm =. if id_alex=="cc_English_1_1466_2022_2023" //Trinidad and Tobago - Cambio negativo en la pregunta en 7.5  //
replace cc_q26a_norm =. if id_alex=="cc_English_0_721_2022_2023" //Trinidad and Tobago - Cambio negativo en la pregunta en 7.5  //
replace cc_q26b_norm =. if id_alex=="cc_English_0_721_2022_2023" //Trinidad and Tobago - Cambio negativo en la pregunta en 7.6  //
replace cc_q26b_norm =. if id_alex=="cc_English_1_953_2023" //Trinidad and Tobago - Cambio negativo en la pregunta en 7.6  //
replace all_q87_norm =. if id_alex=="cc_English_0_1462" //Trinidad and Tobago - Cambio negativo en la pregunta en 7.6  //
replace all_q89_norm =. if id_alex=="cc_English_1_398_2022_2023" //Trinidad and Tobago - Cambio negativo en la pregunta en 7.7  //
replace all_q59_norm =. if id_alex=="cc_English_0_874" //Trinidad and Tobago - Cambio negativo en la pregunta en 7.7  //
replace cc_q14a_norm =. if id_alex=="cc_English_1_520" //Trinidad and Tobago - Cambio negativo en la pregunta en 7.7  //
replace cc_q14b_norm =. if id_alex=="cc_English_1_520" //Trinidad and Tobago - Cambio negativo en la pregunta en 7.7  //

*Tunisia
drop if id_alex=="cj_English_1_623_2018_2019_2021_2022_2023" //Tunisia (muy positivo)
drop if id_alex=="cc_French_1_914" //Tunisia (muy positivo)
drop if id_alex=="cc_French_1_924_2021_2022_2023" //Tunisia (muy positivo)
drop if id_alex=="cc_French_0_87_2022_2023" //Tunisia (muy positivo)
drop if id_alex=="cc_French_0_660_2022_2023" //Tunisia (muy positivo) (Q)

replace all_q1_norm =. if id_alex=="cj_Arabic_0_22_2022_2023" //Tunisia - Reduzco la magnitud del cambio negativo del SF (Quite GPP) 1.2  //
replace all_q2_norm =. if id_alex=="cj_Arabic_0_22_2022_2023" //Tunisia - Reduzco la magnitud del cambio negativo del SF (Quite GPP) 1.2  //
replace all_q20_norm =. if id_alex=="cj_Arabic_0_22_2022_2023" //Tunisia - Reduzco la magnitud del cambio negativo del SF (Quite GPP) 1.2  //
replace all_q21_norm =. if id_alex=="cj_Arabic_0_22_2022_2023" //Tunisia - Reduzco la magnitud del cambio negativo del SF (Quite GPP) 1.2  //
replace all_q1_norm =. if id_alex=="lb_French_1_203" //Tunisia - Reduzco la magnitud del cambio negativo del SF (Quite GPP) 1.2  //
replace all_q1_norm =. if id_alex=="cj_French_0_45_2022_2023" //Tunisia - Reduzco la magnitud del cambio negativo del SF (Quite GPP) 1.2  //
replace all_q1_norm =. if id_alex=="cj_French_1_951_2022_2023" //Tunisia - Reduzco la magnitud del cambio negativo del SF (Quite GPP) 1.2  //
replace all_q1_norm =. if id_alex=="cc_French_0_264_2016_2017_2018_2019_2021_2022_2023" //Tunisia - Reduzco la magnitud del cambio negativo del SF (Quite GPP) 1.2  //
replace all_q2_norm =. if id_alex=="lb_French_1_326_2022_2023" //Tunisia - Pequeno cambio positivo en 1.3  //
replace all_q3_norm =. if id_alex=="lb_French_1_326_2022_2023" //Tunisia - Pequeno cambio positivo en 1.3  //
replace all_q4_norm =. if id_alex=="lb_French_1_326_2022_2023" //Tunisia - Pequeno cambio positivo en 1.3  //
replace all_q5_norm =. if id_alex=="lb_French_1_326_2022_2023" //Tunisia - Pequeno cambio positivo en 1.3  //
replace all_q6_norm =. if id_alex=="lb_French_1_326_2022_2023" //Tunisia - Pequeno cambio positivo en 1.3  //
replace all_q7_norm =. if id_alex=="lb_French_1_326_2022_2023" //Tunisia - Pequeno cambio positivo en 1.3  //
replace all_q8_norm =. if id_alex=="lb_French_1_326_2022_2023" //Tunisia - Pequeno cambio positivo en 1.3  //
replace all_q8_norm =. if id_alex=="lb_French_0_211_2023" //Tunisia - Pequeno cambio positivo en 1.3  //
replace all_q4_norm =. if id_alex=="cc_French_0_985_2022_2023" //Tunisia - Pequeno cambio positivo en 1.3  //
replace all_q94_norm =. if id_alex=="cj_French_0_921_2023" //Tunisia - Reduzco el cambio positivo en la pregunta 1.6 (Q)  //
replace cc_q25_norm =. if id_alex=="cc_French_1_135_2017_2018_2019_2021_2022_2023" //Tunisia - Pequeno cambio positivo en 1.3  //
replace cc_q25_norm =. if id_alex=="cc_French_0_1602_2022_2023" //Tunisia - Pequeno cambio positivo en 1.3  (contrario a long)//
replace all_q9_norm =. if id_alex=="lb_French_1_231_2014_2016_2017_2018_2019_2021_2022_2023" //Tunisia - Reduzco el cambio positivo en la pregunta 1.4  //
replace cj_q38_norm =. if id_alex=="cj_French_0_491_2017_2018_2019_2021_2022_2023" //Tunisia - Reduzco el cambio positivo en la pregunta 1.4  //
replace cj_q36c_norm =. if id_alex=="cj_English_1_198_2016_2017_2018_2019_2021_2022_2023" //Tunisia - Reduzco el cambio positivo en la pregunta 1.4  //
replace all_q22_norm =. if id_alex=="cc_French_0_985_2022_2023" //Tunisia - Pequeno cambio positivo en 1.7  (contrario a long)//
replace all_q23_norm =. if id_alex=="cc_French_0_985_2022_2023" //Tunisia - Pequeno cambio positivo en 1.7  (contrario a long)//
replace all_q24_norm =. if id_alex=="cc_French_0_985_2022_2023" //Tunisia - Pequeno cambio positivo en 1.7  (contrario a long)//
replace all_q25_norm =. if id_alex=="cc_French_0_985_2022_2023" //Tunisia - Pequeno cambio positivo en 1.7  (contrario a long)//
replace all_q26_norm =. if id_alex=="cc_French_0_985_2022_2023" //Tunisia - Pequeno cambio positivo en 1.7  (contrario a long)//
replace all_q27_norm =. if id_alex=="cc_French_0_985_2022_2023" //Tunisia - Pequeno cambio positivo en 1.7  (contrario a long)//
replace all_q8_norm =. if id_alex=="cc_French_0_985_2022_2023" //Tunisia - Pequeno cambio positivo en 1.7  (contrario a long)//
replace all_q22_norm =. if id_alex=="cc_French_0_690" //Tunisia - Pequeno cambio positivo en 1.7 (contrario a long) //
replace all_q23_norm =. if id_alex=="cc_French_0_690" //Tunisia - Pequeno cambio positivo en 1.7 (contrario a long) //
replace all_q24_norm =. if id_alex=="cc_French_0_690" //Tunisia - Pequeno cambio positivo en 1.7  (contrario a long)//
replace all_q25_norm =. if id_alex=="cc_French_0_690" //Tunisia - Pequeno cambio positivo en 1.7  (contrario a long)//
replace all_q26_norm =. if id_alex=="cc_French_0_690" //Tunisia - Pequeno cambio positivo en 1.7  (contrario a long)//
replace all_q27_norm =. if id_alex=="cc_French_0_690" //Tunisia - Pequeno cambio positivo en 1.7  (contrario a long)//
replace all_q8_norm =. if id_alex=="cc_French_0_690" //Tunisia - Pequeno cambio positivo en 1.7  (contrario a long)//
replace all_q22_norm =. if id_alex=="cj_French_1_1061_2022_2023" //Tunisia - Pequeno cambio positivo en 1.7 (contrario a long) //
replace all_q23_norm =. if id_alex=="cj_French_1_1061_2022_2023" //Tunisia - Pequeno cambio positivo en 1.7 (contrario a long) //
replace all_q24_norm =. if id_alex=="cj_French_1_1061_2022_2023" //Tunisia - Pequeno cambio positivo en 1.7  (contrario a long)//
replace all_q25_norm =. if id_alex=="cj_French_1_1061_2022_2023" //Tunisia - Pequeno cambio positivo en 1.7  (contrario a long)//
replace all_q26_norm =. if id_alex=="cj_French_1_1061_2022_2023" //Tunisia - Pequeno cambio positivo en 1.7  (contrario a long)//
replace all_q27_norm =. if id_alex=="cj_French_1_1061_2022_2023" //Tunisia - Pequeno cambio positivo en 1.7  (contrario a long)//
replace all_q8_norm =. if id_alex=="cj_French_1_1061_2022_2023" //Tunisia - Pequeno cambio positivo en 1.7  (contrario a long)//
replace all_q22_norm =. if id_alex=="cc_French_0_264_2016_2017_2018_2019_2021_2022_2023" //Tunisia - Pequeno cambio positivo en 1.7 (contrario a long) //
replace all_q23_norm =. if id_alex=="cc_French_0_264_2016_2017_2018_2019_2021_2022_2023" //Tunisia - Pequeno cambio positivo en 1.7  (contrario a long)//
replace all_q24_norm =. if id_alex=="cc_French_0_264_2016_2017_2018_2019_2021_2022_2023" //Tunisia - Pequeno cambio positivo en 1.7  (contrario a long)//
replace all_q25_norm =. if id_alex=="cc_French_0_264_2016_2017_2018_2019_2021_2022_2023" //Tunisia - Pequeno cambio positivo en 1.7  (contrario a long)//
replace all_q26_norm =. if id_alex=="cc_French_0_264_2016_2017_2018_2019_2021_2022_2023" //Tunisia - Pequeno cambio positivo en 1.7  (contrario a long)//
replace all_q27_norm =. if id_alex=="cc_French_0_264_2016_2017_2018_2019_2021_2022_2023" //Tunisia - Pequeno cambio positivo en 1.7  (contrario a long)//
replace all_q22_norm =. if id_alex=="cc_French_0_1483_2018_2019_2021_2022_2023" //Tunisia - Pequeno cambio positivo en 1.7 (contrario a long) //
replace all_q23_norm =. if id_alex=="cc_French_0_1483_2018_2019_2021_2022_2023" //Tunisia - Pequeno cambio positivo en 1.7  (contrario a long)//
replace all_q24_norm =. if id_alex=="cc_French_0_1483_2018_2019_2021_2022_2023" //Tunisia - Pequeno cambio positivo en 1.7  (contrario a long)//
replace all_q25_norm =. if id_alex=="cc_French_0_1483_2018_2019_2021_2022_2023" //Tunisia - Pequeno cambio positivo en 1.7  (contrario a long)//
replace all_q26_norm =. if id_alex=="cc_French_0_1483_2018_2019_2021_2022_2023" //Tunisia - Pequeno cambio positivo en 1.7  (contrario a long)//
replace all_q27_norm =. if id_alex=="cc_French_0_1483_2018_2019_2021_2022_2023" //Tunisia - Pequeno cambio positivo en 1.7  (contrario a long)//
replace cc_q32h_norm =. if id_alex=="cc_French_0_1616_2021_2022_2023" //Tunisia - Pequeno cambio en 3.1  //
replace cc_q32i_norm =. if id_alex=="cc_French_0_1616_2021_2022_2023" //Tunisia - Pequeno cambio en 3.1  //
replace cc_q39a_norm =. if id_alex=="cc_French_0_1483_2018_2019_2021_2022_2023" //Tunisia - Pequeno cambio en 3.2  //
replace cc_q39b_norm =. if id_alex=="cc_French_1_135_2017_2018_2019_2021_2022_2023" //Tunisia - Pequeno cambio en 3.2  //
replace cc_q39b_norm =. if id_alex=="cc_French_0_1483_2018_2019_2021_2022_2023" //Tunisia - Pequeno cambio en 3.2  //
replace cc_q9a_norm =. if id_alex=="cc_French_1_135_2017_2018_2019_2021_2022_2023" //Tunisia - Pequeno cambio en 3.3  //
replace cc_q32j_norm =. if id_alex=="cc_French_0_1274_2019_2021_2022_2023" //Tunisia - Pequeno cambio en 3.3  //
replace cc_q11b_norm =0 if id_alex=="cc_French_0_264_2016_2017_2018_2019_2021_2022_2023" //Tunisia - Pequeno cambio en 3.3  //
replace cc_q9c_norm =. if id_alex=="cc_French_0_1304_2022_2023" //Tunisia - Pequeno cambio en 3.4  //
replace cc_q9c_norm =. if id_alex=="cc_French_1_963" //Tunisia - Pequeno cambio en 3.4  //
replace cc_q40a_norm =. if id_alex=="cc_French_0_264_2016_2017_2018_2019_2021_2022_2023" //Tunisia - Pequeno cambio en 3.4  //
replace cc_q40b_norm =. if id_alex=="cc_French_0_264_2016_2017_2018_2019_2021_2022_2023" //Tunisia - Pequeno cambio en 3.4  //
replace cc_q40a_norm =. if id_alex=="cc_French_0_690" //Tunisia - Pequeno cambio en 3.4  //
replace cc_q40b_norm =. if id_alex=="cc_French_0_690" //Tunisia - Pequeno cambio en 3.4  //
replace cj_q11a_norm =. if id_alex=="cj_French_1_1074_2021_2022_2023" //Tunisia - Introduzco cambio negativo 4.2 (Q)  //
replace cj_q11b_norm =. if id_alex=="cj_French_1_1074_2021_2022_2023" //Tunisia - Introduzco cambio negativo 4.2 (Q)  //
replace cj_q31e_norm =. if id_alex=="cj_French_1_1074_2021_2022_2023" //Tunisia - Introduzco cambio negativo 4.2 (Q)  //
replace cj_q42c_norm =. if id_alex=="cj_French_1_1074_2021_2022_2023" //Tunisia - Introduzco cambio negativo 4.2 (Q)  //
replace cj_q42d_norm =. if id_alex=="cj_French_1_1074_2021_2022_2023" //Tunisia - Introduzco cambio negativo 4.2 (Q)  //
replace cj_q10_norm =. if id_alex=="cj_French_1_1074_2021_2022_2023" //Tunisia - Introduzco cambio negativo 4.2 (Q)  //
replace cj_q42d_norm =. if id_alex=="cj_French_0_921_2023" //Tunisia - Introduzco cambio negativo 4.2 (Q)  //
replace all_q30_norm =. if id_alex=="cj_French_0_45_2022_2023" //Tunisia - Reduzco cambio negativo 4.5  //
replace all_q30_norm =. if id_alex=="cj_French_1_951_2022_2023" //Tunisia - Reduzco cambio negativo 4.5  //
replace all_q19_norm =. if id_alex=="cj_French_0_491_2017_2018_2019_2021_2022_2023" //Tunisia - Aumento cambio negativo 4.5 (Q)  //
replace all_q31_norm =. if id_alex=="cj_French_0_491_2017_2018_2019_2021_2022_2023" //Tunisia - Aumento cambio negativo 4.5 (Q)  //
replace all_q32_norm =. if id_alex=="cj_French_0_491_2017_2018_2019_2021_2022_2023" //Tunisia - Aumento cambio negativo 4.5 (Q)  //
replace all_q14_norm =. if id_alex=="cj_French_0_491_2017_2018_2019_2021_2022_2023" //Tunisia - Aumento cambio negativo 4.5 (Q)  //
replace all_q49_norm =. if id_alex=="cc_French_0_264_2016_2017_2018_2019_2021_2022_2023" //Tunisia - Pequeno cambio en 6.4  //
replace all_q49_norm =. if id_alex=="lb_French_1_231_2014_2016_2017_2018_2019_2021_2022_2023" //Tunisia - Pequeno cambio en 6.4  //
replace all_q50_norm =. if id_alex=="cc_French_0_660_2022_2023" //Tunisia - Pequeno cambio en 6.4  //
replace all_q50_norm =. if id_alex=="cc_English_0_1034_2022_2023" //Tunisia - Pequeno cambio en 6.4  //
replace all_q18_norm =. if id_alex=="cc_French_0_1602_2022_2023" //Tunisia - Pequeno cambio en 4.4 (contrario a long) //
replace all_q18_norm =. if id_alex=="cc_French_0_192_2023" //Tunisia - Pequeno cambio en 4.4  (contrario a long) //
replace all_q94_norm =. if id_alex=="cj_French_1_1074_2021_2022_2023" //Tunisia - Pequeno cambio en 4.4  (contrario a long) //
replace all_q15_norm =. if id_alex=="cj_French_0_491_2017_2018_2019_2021_2022_2023" //Tunisia - Pequeno cambio en 4.4  (contrario a long) //
replace all_q16_norm =. if id_alex=="cj_French_0_491_2017_2018_2019_2021_2022_2023" //Tunisia - Pequeno cambio en 4.4  (contrario a long) //

*Turkiye
replace cj_q8_norm =0 if id_alex=="cj_English_1_1061_2023" //Turkiye - La variable se borro el anio pasado. Inputo valores para poder incluirla este anio (pero con un valor no tan alto)  //
replace cj_q8_norm =0 if id_alex=="cj_English_0_716_2023" //Turkiye - La variable se borro el anio pasado. Inputo valores para poder incluirla este anio (pero con un valor no tan alto)  //

*Uganda
drop if id_alex=="lb_English_1_638" //Uganda (muy positivo)
drop if id_alex=="cj_English_0_632" //Uganda (muy positivo)
drop if id_alex=="cj_English_0_545_2023" //Uganda (muy positivo)
drop if id_alex=="cc_English_1_110" //Uganda (muy positivo)
drop if id_alex=="cc_English_0_34" //Uganda (muy positivo)
drop if id_alex=="ph_English_1_583_2021_2022_2023" //Uganda (muy positivo)
replace ph_q7_norm =0 if id_alex=="ph_English_0_239_2022_2023" //Uganda - Cambio positivo en 2.1 (contradice long) (No hay variacion) //
replace ph_q7_norm =0 if id_alex=="ph_English_0_100_2023" //Uganda - Cambio positivo en 2.1 (contradice long) (No hay variacion) //
replace ph_q11b_norm =. if id_alex=="ph_English_0_100_2023" //Uganda - Cambio positivo en la pregunta   //
replace ph_q11c_norm =. if id_alex=="ph_English_0_100_2023" //Uganda - Cambio positivo en la pregunta //
replace cj_q33d_norm =. if id_alex=="cj_English_1_980" //Uganda - Outlier. Cambio positivo en 2.2  //
replace lb_q6c_norm =. if id_alex=="lb_English_0_450_2023" //Uganda - Outlier. Cambio positivo en 2.2  //
replace cj_q32b_norm =. if id_alex=="cj_English_0_791_2022_2023" //Uganda - Outlier. Cambio positivo en 2.2  //
replace cj_q33b_norm =. if id_alex=="cj_English_0_791_2022_2023" //Uganda - Outlier. Cambio positivo en 2.2  //
replace cj_q32d_norm =. if id_alex=="cj_English_0_230_2022_2023" //Uganda - Outlier. Cambio positivo en 2.2  //
replace cj_q34c_norm =. if id_alex=="cj_English_0_521_2022_2023" //Uganda - Outlier. Cambio positivo en 2.2  //
replace cj_q34d_norm =. if id_alex=="cj_English_0_521_2022_2023" //Uganda - Outlier. Cambio positivo en 2.2  //
replace all_q96_norm =. if id_alex=="cj_English_0_230_2022_2023" //Uganda - //
replace cj_q32c_norm =. if id_alex=="cj_English_0_230_2022_2023" //Uganda - Outlier. Cambio positivo en 2.3  //
replace cj_q32d_norm =. if id_alex=="cj_English_0_230_2022_2023" //Uganda - Outlier. Cambio positivo en 2.3  //
replace cj_q34b_norm =. if id_alex=="cj_English_0_230_2022_2023" //Uganda - Outlier. Cambio positivo en 2.3  //
replace cj_q34c_norm =. if id_alex=="cj_English_0_230_2022_2023" //Uganda - Outlier. Cambio positivo en 2.3  //
replace ph_q6a_norm =. if id_alex=="ph_English_1_442_2018_2019_2021_2022_2023" //Uganda - Cambio positivo en 4.1  //
replace ph_q6b_norm =. if id_alex=="ph_English_1_442_2018_2019_2021_2022_2023" //Uganda - Cambio positivo en 4.1  //
replace ph_q6c_norm =. if id_alex=="ph_English_1_442_2018_2019_2021_2022_2023" //Uganda - Cambio positivo en 4.1  //
replace ph_q6d_norm =. if id_alex=="ph_English_1_442_2018_2019_2021_2022_2023" //Uganda - Cambio positivo en 4.1  //
replace ph_q6e_norm =. if id_alex=="ph_English_1_442_2018_2019_2021_2022_2023" //Uganda - Cambio positivo en 4.1  //
replace ph_q6f_norm =. if id_alex=="ph_English_1_442_2018_2019_2021_2022_2023" //Uganda - Cambio positivo en 4.1  //
replace ph_q6d_norm =. if id_alex=="ph_English_0_108" //Uganda - Cambio positivo en 4.1  //
replace lb_q16a_norm =. if id_alex=="lb_English_1_480_2023" //Uganda - Cambio positivo en 4.1  //
replace lb_q16b_norm =. if id_alex=="lb_English_1_480_2023" //Uganda - Cambio positivo en 4.1  //
replace lb_q16c_norm =. if id_alex=="lb_English_1_480_2023" //Uganda - Cambio positivo en 4.1  //
replace lb_q16d_norm =. if id_alex=="lb_English_1_480_2023" //Uganda - Cambio positivo en 4.1  //
replace lb_q16e_norm =. if id_alex=="lb_English_1_480_2023" //Uganda - Cambio positivo en 4.1  //
replace lb_q16f_norm =. if id_alex=="lb_English_1_480_2023" //Uganda - Cambio positivo en 4.1  //
replace ph_q6f_norm =.6666667 if id_alex=="ph_English_0_108" //Uganda - Cambio positivo en 4.1  //
replace cj_q22d_norm =. if id_alex=="cj_English_0_230_2022_2023" //Uganda - Cambio positivo en 4.3  //
replace cj_q22b_norm =. if id_alex=="cj_English_0_230_2022_2023" //Uganda - Cambio positivo en 4.3  //
replace cj_q3a_norm =. if id_alex=="cj_English_0_521_2022_2023" //Uganda - Cambio positivo en 4.3  //
replace cj_q3b_norm =. if id_alex=="cj_English_0_521_2022_2023" //Uganda - Cambio positivo en 4.3  //
replace cj_q3c_norm =. if id_alex=="cj_English_0_521_2022_2023" //Uganda - Cambio positivo en 4.3  //
replace all_q29_norm =. if id_alex=="cc_English_0_510_2017_2018_2019_2021_2022_2023" //Uganda -  Cambio positivo en 4.5  //
replace all_q29_norm =. if id_alex=="cc_English_0_168_2018_2019_2021_2022_2023" //Uganda -  Cambio positivo en 4.5  //
replace all_q29_norm =. if id_alex=="cj_English_0_230_2022_2023" //Uganda -  Cambio positivo en 4.5  //
replace all_q30_norm =. if id_alex=="cj_English_0_230_2022_2023" //Uganda -  Cambio positivo en 4.5  //
replace all_q29_norm =. if id_alex=="cj_English_1_907_2022_2023" //Uganda -  Cambio positivo en 4.5  //
replace all_q30_norm =. if id_alex=="cj_English_1_907_2022_2023" //Uganda -  Cambio positivo en 4.5  //
replace ph_q9a_norm =. if id_alex=="ph_English_0_100_2023" //Uganda -  Salta mucho la pregunta. Solo hay dos observaciones  //
replace all_q85_norm=. if country=="Uganda" // Uganda (se elimino el anio pasado)
replace cj_q21a_norm =. if id_alex=="cj_English_0_787_2022_2023" //Uganda -  Cambio positivo en 8.3  //
replace cj_q12c_norm =. if id_alex=="cj_English_1_266" //Uganda -  Cambio positivo en 8.4  //
replace cj_q12d_norm =. if id_alex=="cj_English_1_266" //Uganda -  Cambio positivo en 8.4  //
replace cj_q12e_norm =. if id_alex=="cj_English_1_266" //Uganda -  Cambio positivo en 8.4  //
replace cj_q12c_norm =. if id_alex=="cj_English_1_166" //Uganda -  Cambio positivo en 8.4  //
replace cj_q12d_norm =. if id_alex=="cj_English_1_166" //Uganda -  Cambio positivo en 8.4  //
replace cj_q12e_norm =. if id_alex=="cj_English_1_166" //Uganda -  Cambio positivo en 8.4  //
replace cj_q20o_norm =. if id_alex=="cj_English_0_230_2022_2023" //Uganda -  Cambio positivo en 8.4  //
replace cj_q20o_norm =. if id_alex=="cj_English_1_907_2022_2023" //Uganda -  Cambio positivo en 8.4  //
replace cj_q20o_norm =. if id_alex=="cj_English_1_166" //Uganda -  Cambio positivo en 8.6  //
replace cj_q20o_norm =. if id_alex=="cj_English_1_980" //Uganda -  Cambio positivo en 8.6  //
replace cj_q21d_norm =. if id_alex=="cj_English_1_907_2022_2023" //Uganda -  Reduzco el cambio positivo en 8.7  //
replace cj_q21f_norm =. if id_alex=="cj_English_0_787_2022_2023" //Uganda -  Reduzco el cambio positivo en 8.7  //
replace cj_q31c_norm =. if id_alex=="cj_English_0_829_2023" //Uganda -  Reduzco el cambio positivo en 8.7  //
replace cj_q31d_norm =. if id_alex=="cj_English_0_829_2023" //Uganda -  Reduzco el cambio positivo en 8.7  //

*Ukraine
replace cj_q21e_norm =. if id_alex=="cj_Russian_0_1105" //Ukraine - Cambio positivo en 8.3 (contradice long) //
replace cj_q21g_norm =. if id_alex=="cj_Russian_0_1105" //Ukraine - Cambio positivo en 8.3 (contradice long) //
replace cj_q21h_norm =. if id_alex=="cj_Russian_0_1105" //Ukraine - Cambio positivo en 8.3 (contradice long) //
replace cj_q28_norm =. if id_alex=="cj_Russian_0_700" //Ukraine - Cambio positivo en 8.3 (contradice long) //
replace cj_q20o_norm =. if id_alex=="cj_English_0_1253" //Ukraine - Cambio positivo en 8.4  //

*UAE
drop if id_alex=="cj_Arabic_0_33" //UAE (muy positivo)
drop if id_alex=="cj_Arabic_0_609" //UAE (muy positivo)
drop if id_alex=="cc_English_0_1153_2023" //UAE (muy positivo)
replace cc_q33_norm=. if country=="United Arab Emirates" // UAE (se elimino el anio pasado)
replace all_q13_norm=. if country=="United Arab Emirates" // UAE (se elimino el anio pasado)
replace cc_q39a_norm =. if id_alex=="cc_English_0_1477_2021_2022_2023" //UAE - Cambio negativo en 3.2 (contradice long) //
replace cc_q39b_norm =. if id_alex=="cc_English_0_1477_2021_2022_2023" //UAE - Cambio negativo en 3.2 (contradice long) //
replace cc_q39c_norm =. if id_alex=="cc_English_0_1477_2021_2022_2023" //UAE - Cambio negativo en 3.2 (contradice long) //
replace cc_q39d_norm =. if id_alex=="cc_English_0_1477_2021_2022_2023" //UAE - Cambio negativo en 3.2 (contradice long) //
replace cc_q39e_norm =. if id_alex=="cc_English_0_1477_2021_2022_2023" //UAE - Cambio negativo en 3.2 (contradice long) //
replace all_q40_norm =. if id_alex=="cc_English_0_1477_2021_2022_2023" //UAE - Cambio negativo en 3.2 (contradice long) //
replace all_q41_norm =. if id_alex=="cc_English_0_1477_2021_2022_2023" //UAE - Cambio negativo en 3.2 (contradice long) //
replace all_q42_norm =. if id_alex=="cc_English_0_1477_2021_2022_2023" //UAE - Cambio negativo en 3.2 (contradice long) //
replace all_q43_norm =. if id_alex=="cc_English_0_1477_2021_2022_2023" //UAE - Cambio negativo en 3.2 (contradice long) //
replace all_q44_norm =. if id_alex=="cc_English_0_1477_2021_2022_2023" //UAE - Cambio negativo en 3.2 (contradice long) //
replace all_q45_norm =. if id_alex=="cc_English_0_1477_2021_2022_2023" //UAE - Cambio negativo en 3.2 (contradice long) //
replace all_q46_norm =. if id_alex=="cc_English_0_1477_2021_2022_2023" //UAE - Cambio negativo en 3.2 (contradice long) //
replace all_q47_norm =. if id_alex=="cc_English_0_1477_2021_2022_2023" //UAE - Cambio negativo en 3.2 (contradice long) //
replace cc_q39a_norm =. if id_alex=="cc_English_0_424_2021_2022_2023" //UAE - Cambio negativo en 3.2 (contradice long) //
replace cc_q39b_norm =. if id_alex=="cc_English_0_424_2021_2022_2023" //UAE - Cambio negativo en 3.2 (contradice long) //
replace cc_q39c_norm =. if id_alex=="cc_English_0_424_2021_2022_2023" //UAE - Cambio negativo en 3.2 (contradice long) //
replace cc_q39d_norm =. if id_alex=="cc_English_0_424_2021_2022_2023" //UAE - Cambio negativo en 3.2 (contradice long) //
replace cc_q39e_norm =. if id_alex=="cc_English_0_424_2021_2022_2023" //UAE - Cambio negativo en 3.2 (contradice long) //
replace all_q40_norm =. if id_alex=="cc_English_0_424_2021_2022_2023" //UAE - Cambio negativo en 3.2 (contradice long) //
replace all_q41_norm =. if id_alex=="cc_English_0_424_2021_2022_2023" //UAE - Cambio negativo en 3.2 (contradice long) //
replace all_q42_norm =. if id_alex=="cc_English_0_424_2021_2022_2023" //UAE - Cambio negativo en 3.2 (contradice long) //
replace all_q43_norm =. if id_alex=="cc_English_0_424_2021_2022_2023" //UAE - Cambio negativo en 3.2 (contradice long) //
replace all_q44_norm =. if id_alex=="cc_English_0_424_2021_2022_2023" //UAE - Cambio negativo en 3.2 (contradice long) //
replace all_q45_norm =. if id_alex=="cc_English_0_424_2021_2022_2023" //UAE - Cambio negativo en 3.2 (contradice long) //
replace all_q46_norm =. if id_alex=="cc_English_0_424_2021_2022_2023" //UAE - Cambio negativo en 3.2 (contradice long) //
replace all_q47_norm =. if id_alex=="cc_English_0_424_2021_2022_2023" //UAE - Cambio negativo en 3.2 (contradice long) //
replace cc_q9c_norm =. if id_alex=="cc_English_0_424_2021_2022_2023" //UAE - Cambio negativo en 3.4  //
replace cc_q40a_norm =. if id_alex=="cc_English_0_424_2021_2022_2023" //UAE - Cambio negativo en 3.4  //
replace cc_q9c_norm =. if id_alex=="cc_English_0_1477_2021_2022_2023" //UAE - Cambio negativo en 3.4  //
replace cc_q40a_norm =. if id_alex=="cc_English_0_1477_2021_2022_2023" //UAE - Cambio negativo en 3.4  //
replace cc_q9c_norm =. if id_alex=="cc_English_0_1345_2018_2019_2021_2022_2023" //UAE - Cambio negativo en 3.4  //
replace lb_q3d_norm=. if country=="United Arab Emirates" // UAE (se elimino el anio pasado)
replace cj_q42c_norm =. if id_alex=="cj_Arabic_1_482_2023" //UAE - Cambio negativo (Q) 4.2 //
replace cj_q42d_norm =. if id_alex=="cj_Arabic_1_482_2023" //UAE - Cambio negativo (Q) 4.2 //
replace cj_q10_norm =. if id_alex=="cj_Arabic_1_482_2023" //UAE - Cambio negativo (Q) 4.2 //
replace all_q49_norm =. if id_alex=="cc_Arabic_0_1743_2022_2023" //UAE - Cambio negativo en 6.4  //
replace cc_q26a_norm=. if country=="United Arab Emirates" // UAE (se elimino el anio pasado)
replace all_q84_norm =. if id_alex=="cc_English_0_606_2022_2023" //UAE - Cambio negativo en 7.5  //
replace all_q89_norm =. if id_alex=="cc_English_0_1068" //UAE - Cambio negativo en 7.7  //
replace all_q89_norm =. if id_alex=="cc_English_0_1422_2019_2021_2022_2023" //UAE - Cambio negativo en 7.7  //

*United Kingdom
replace all_q62_norm =. if id_alex=="lb_English_0_290" //UK - Cambio negativo en 6.3 //
replace all_q63_norm =. if id_alex=="lb_English_0_290" //UK - Cambio negativo en 6.3 //
replace all_q48_norm =. if id_alex=="cc_English_0_1145_2016_2017_2018_2019_2021_2022_2023" //UK - Cambio negativo en 6.4 //

*United States
drop if id_alex=="cj_English_1_242" //USA (muy negativo)
drop if id_alex=="cj_English_0_125" //USA (muy negativo)
drop if id_alex=="cc_English_0_1484" //USA (muy negativo)
drop if id_alex=="lb_English_0_544" //USA (muy negativo)
drop if id_alex=="cc_English_1_527" //USA (muy negativo)
replace cj_q38_norm =1 if id_alex=="cj_English_0_1031_2022_2023" //USA - Cambio negativo en 1.4 //
replace cj_q8_norm =. if id_alex=="cj_English_1_841_2022_2023" //USA - Cambio negativo en 1.4 //
replace cj_q9_norm =. if id_alex=="cj_English_1_50_2022_2023" //USA - Cambio negativo en 1.5 //
replace cj_q8_norm =. if id_alex=="cj_English_1_50_2022_2023" //USA - Cambio negativo en 1.5 //
replace all_q12_norm =. if id_alex=="cj_English_0_319_2023" //USA - Cambio negativo en 1.5 //
replace all_q12_norm =. if id_alex=="cc_English_0_825" //USA - Cambio negativo en 1.5 //
replace all_q41_norm =. if id_alex=="lb_English_0_273_2021_2022_2023" //USA - Cambio negativo en 3.2 //
replace all_q46_norm =. if id_alex=="lb_English_0_273_2021_2022_2023" //USA - Cambio negativo en 3.2 //
replace all_q47_norm =. if id_alex=="lb_English_0_273_2021_2022_2023" //USA - Cambio negativo en 3.2 //
replace all_q41_norm =. if id_alex=="cc_English_0_523" //USA - Cambio negativo en 3.2 //
replace all_q46_norm =. if id_alex=="cc_English_0_523" //USA - Cambio negativo en 3.2 //
replace all_q47_norm =. if id_alex=="cc_English_0_523" //USA - Cambio negativo en 3.2 //
replace cc_q39d_norm =. if id_alex=="cc_English_0_630_2022_2023" //USA - Cambio negativo en 3.2 //
replace cc_q39d_norm =. if id_alex=="cc_English_1_964" //USA - Cambio negativo en 3.2 //
replace cj_q31g_norm =. if id_alex=="cj_English_1_841_2022_2023" //USA - Cambio negativo en 3.2 //
replace cj_q42c_norm =. if id_alex=="cj_English_1_841_2022_2023" //USA - Cambio negativo en 3.2 //
replace cj_q42d_norm =. if id_alex=="cj_English_1_841_2022_2023" //USA - Cambio negativo en 3.2 //
replace cj_q42d_norm =. if id_alex=="cj_English_1_437" //USA - Cambio negativo en 3.2 //
replace all_q76_norm =. if id_alex=="cc_English_1_930" //USA - Cambio positivo en 7.2 //
replace all_q77_norm =. if id_alex=="cc_English_1_930" //USA - Cambio positivo en 7.2 //
replace all_q78_norm =. if id_alex=="cc_English_1_930" //USA - Cambio positivo en 7.2 //
replace all_q79_norm =. if id_alex=="cc_English_1_930" //USA - Cambio positivo en 7.2 //
replace all_q80_norm =. if id_alex=="cc_English_1_930" //USA - Cambio positivo en 7.2 //
replace all_q76_norm =. if id_alex=="lb_English_0_453" //USA - Cambio positivo en 7.2 //
replace all_q77_norm =. if id_alex=="lb_English_0_453" //USA - Cambio positivo en 7.2 //
replace all_q78_norm =. if id_alex=="lb_English_0_453" //USA - Cambio positivo en 7.2 //
replace all_q79_norm =. if id_alex=="lb_English_0_453" //USA - Cambio positivo en 7.2 //
replace all_q80_norm =. if id_alex=="lb_English_0_453" //USA - Cambio positivo en 7.2 //
replace all_q76_norm =. if id_alex=="lb_English_0_305_2021_2022_2023" //USA - Cambio positivo en 7.2 //
replace all_q77_norm =. if id_alex=="lb_English_0_305_2021_2022_2023" //USA - Cambio positivo en 7.2 //
replace all_q78_norm =. if id_alex=="lb_English_0_305_2021_2022_2023" //USA - Cambio positivo en 7.2 //
replace all_q79_norm =. if id_alex=="lb_English_0_305_2021_2022_2023" //USA - Cambio positivo en 7.2 //
replace all_q80_norm =. if id_alex=="lb_English_0_305_2021_2022_2023" //USA - Cambio positivo en 7.2 //
replace all_q76_norm =. if id_alex=="lb_English_1_229_2017_2018_2019_2021_2022_2023" //USA - Cambio positivo en 7.2 //
replace all_q77_norm =. if id_alex=="lb_English_1_229_2017_2018_2019_2021_2022_2023" //USA - Cambio positivo en 7.2 //
replace all_q78_norm =. if id_alex=="lb_English_1_229_2017_2018_2019_2021_2022_2023" //USA - Cambio positivo en 7.2 //
replace all_q79_norm =. if id_alex=="lb_English_1_229_2017_2018_2019_2021_2022_2023" //USA - Cambio positivo en 7.2 //
replace all_q80_norm =. if id_alex=="lb_English_1_229_2017_2018_2019_2021_2022_2023" //USA - Cambio positivo en 7.2 //
replace cc_q26b_norm =. if id_alex=="cc_English_0_630_2022_2023" //USA - Cambio negativo en 7.6 //
replace cc_q26b_norm =. if id_alex=="cc_English_1_365" //USA - Cambio negativo en 7.6 //
replace cc_q26b_norm =. if id_alex=="cc_English_1_980" //USA - Cambio negativo en 7.6 //
replace all_q86_norm =. if id_alex=="cc_English_0_1768" //USA - Cambio negativo en 7.6 //
replace all_q86_norm =. if id_alex=="lb_English_0_224_2023" //USA - Cambio negativo en 7.6 //
replace cj_q40b_norm =. if id_alex=="cj_English_1_437" //USA - Cambio negativo en 8.6 //
replace cj_q40c_norm =. if id_alex=="cj_English_1_437" //USA - Cambio negativo en 8.6 //
replace cj_q20m_norm =. if id_alex=="cj_English_1_437" //USA - Cambio negativo en 8.6 //
replace cj_q40b_norm =. if id_alex=="cj_English_0_538_2023" //USA - Cambio negativo en 8.6 //
replace cj_q40c_norm =. if id_alex=="cj_English_0_538_2023" //USA - Cambio negativo en 8.6 //
replace cj_q20m_norm =. if id_alex=="cj_English_0_538_2023" //USA - Cambio negativo en 8.6 //
replace cj_q40b_norm =. if id_alex=="cj_English_0_1031_2022_2023" //USA - Cambio negativo en 8.6 //
replace cj_q40c_norm =. if id_alex=="cj_English_0_1031_2022_2023" //USA - Cambio negativo en 8.6 //
replace cj_q20m_norm =. if id_alex=="cj_English_0_1031_2022_2023" //USA - Cambio negativo en 8.6 //
replace cj_q40b_norm =. if id_alex=="cj_English_1_635" //USA - Cambio negativo en 8.6 //
replace cj_q40c_norm =. if id_alex=="cj_English_1_635" //USA - Cambio negativo en 8.6 //
replace cj_q20m_norm =. if id_alex=="cj_English_1_635" //USA - Cambio negativo en 8.6 //
replace cj_q20m_norm =. if id_alex=="cj_English_0_319_2023" //USA - Cambio negativo en 8.6 //
replace cj_q40b_norm =. if id_alex=="cj_English_1_841_2022_2023" //USA - Cambio negativo en 8.6 //
replace cj_q40c_norm =. if id_alex=="cj_English_1_841_2022_2023" //USA - Cambio negativo en 8.6 //
replace cj_q40b_norm =. if id_alex=="cj_English_0_319_2023" //USA - Cambio negativo en 8.6 //

*Uruguay
drop if id_alex=="cc_Spanish_0_1566_2022_2023" //Uruguay  Puntaje muy positivo
drop if id_alex=="lb_Spanish_1_79_2021_2022_2023" //Uruguay Puntaje muy positivo
drop if id_alex=="cc_Spanish_1_240" //Uruguay Puntaje muy positivo
replace cc_q33_norm =. if id_alex=="cc_Spanish_0_45_2022_2023" //Uruguay - Cambio muy positivo en 1.4 //
replace cc_q33_norm =. if id_alex=="cc_Spanish_0_942_2023" //Uruguay - Cambio muy positivo en 1.4 //
replace cc_q33_norm =. if id_alex=="cc_Spanish_0_176_2023" //Uruguay - Cambio muy positivo en 1.4 //
replace cc_q33_norm =. if id_alex=="cc_Spanish_0_624" //Uruguay - Cambio muy positivo en 1.4 //
replace cc_q39b_norm =. if id_alex=="cc_Spanish_1_556_2022_2023" //Uruguay - Cambio muy positivo en 3.2 //
replace cc_q39b_norm =. if id_alex=="cc_Spanish_0_864_2023" //Uruguay - Cambio muy positivo en 3.2 //
replace all_q29_norm =. if id_alex=="cj_Spanish_1_227_2018_2019_2021_2022_2023" //Uruguay - Cambio negativo en 4.5 //
replace all_q30_norm =. if id_alex=="cc_English_1_1373_2022_2023" //Uruguay - Cambio negativo en 4.5 //
replace cj_q31f_norm =. if id_alex=="cj_Spanish_0_789_2017_2018_2019_2021_2022_2023" //Uruguay - Cambio positivo ligero en 4.6 //
replace all_q62_norm =. if id_alex=="cc_Spanish_0_624" //Uruguay - Cambio muy positivo en 6.3 //
replace all_q63_norm =. if id_alex=="cc_Spanish_0_624" //Uruguay - Cambio muy positivo en 6.3 //
replace all_q49_norm =. if id_alex=="cc_English_1_1373_2022_2023" //Uruguay - Cambio muy positivo en 6.4 //
replace all_q49_norm =. if id_alex=="cc_Spanish_0_45_2022_2023" //Uruguay - Cambio positivo en 6.5 //
replace cc_q16d_norm =. if id_alex=="cc_Spanish_1_1131_2022_2023" //Uruguay - Cambio positivo en 6.5 //
replace cc_q16d_norm =. if id_alex=="cc_Spanish_0_45_2022_2023" //Uruguay - Cambio positivo en 6.5 //
replace cc_q16a_norm =. if id_alex=="cc_Spanish_0_45_2022_2023" //Uruguay - Cambio positivo en 6.5 //
replace all_q84_norm =. if id_alex=="lb_Spanish_1_570_2018_2019_2021_2022_2023" //Uruguay - Cambio muy positivo en 7.5 //
replace all_q84_norm =. if id_alex=="lb_Spanish_1_115_2019_2021_2022_2023" //Uruguay - Cambio muy positivo en 7.5 //
replace all_q85_norm =. if id_alex=="cc_English_0_691_2022_2023" //Uruguay - Cambio muy positivo en 7.5 //
replace all_q85_norm =. if id_alex=="cc_Spanish_0_153_2022_2023" //Uruguay - Cambio muy positivo en 7.5 //
replace cc_q13_norm =. if id_alex=="cc_Spanish_1_556_2022_2023" //Uruguay - Cambio muy positivo en 7.5 //
replace cc_q13_norm =. if id_alex=="cc_Spanish_0_45_2022_2023" //Uruguay - Cambio muy positivo en 7.5 //
replace all_q88_norm =. if id_alex=="lb_Spanish_1_570_2018_2019_2021_2022_2023" //Uruguay - Cambio muy positivo en 7.5 //
replace cj_q33a_norm =.6666667 if id_alex=="cj_Spanish_1_227_2018_2019_2021_2022_2023" //Uruguay - Sin cambio en 8.5 (No hay variacion, todos son 1) //
replace cj_q33b_norm =.6666667 if id_alex=="cj_Spanish_1_227_2018_2019_2021_2022_2023" //Uruguay - Sin cambio en 8.5 (No hay variacion, todos son 1)  //
replace cj_q33c_norm =.6666667 if id_alex=="cj_Spanish_1_227_2018_2019_2021_2022_2023" //Uruguay - Sin cambio en 8.5 (No hay variacion, todos son 1)  //
replace cj_q33d_norm =.6666667 if id_alex=="cj_Spanish_1_227_2018_2019_2021_2022_2023" //Uruguay - Sin cambio en 8.5 (No hay variacion, todos son 1)  //
replace cj_q33e_norm =.6666667 if id_alex=="cj_Spanish_1_227_2018_2019_2021_2022_2023" //Uruguay - Sin cambio en 8.5 (No hay variacion, todos son 1)  //
replace cj_q40b_norm =. if id_alex=="cj_Spanish_0_266_2016_2017_2018_2019_2021_2022_2023" //Uruguay - Cambio positivo ligero en 8.6 //
replace cj_q40c_norm =. if id_alex=="cj_Spanish_0_266_2016_2017_2018_2019_2021_2022_2023" //Uruguay - Cambio positivo ligero en 8.6 //

*Uzbekistan
replace cc_q33_norm =. if id_alex=="cc_Russian_1_1341_2023" //Uzbekistan - Cambio muy negativo en 1.4 //
replace cc_q33_norm =. if id_alex=="cc_Russian_1_1095_2023" //Uzbekistan - Cambio muy negativo en 1.4 //
replace cc_q33_norm =. if id_alex=="cc_English_0_232_2022_2023" //Uzbekistan - Cambio muy negativo en 1.4 //
replace all_q41_norm =. if id_alex=="cc_Russian_1_1341_2023" //Uzbekistan - Observaciones viejas (el cambio positivo es probablemente mayor) //
replace all_q42_norm =. if id_alex=="cc_Russian_1_1341_2023" //Uzbekistan - Observaciones viejas (el cambio positivo es probablemente mayor) //
replace all_q43_norm =. if id_alex=="cc_Russian_1_1341_2023" //Uzbekistan - Observaciones viejas (el cambio positivo es probablemente mayor) //
replace all_q41_norm =. if id_alex=="lb_English_0_506_2013_2014_2016_2017_2018_2019_2021_2022_2023" //Uzbekistan - Observaciones viejas (el cambio positivo es probablemente mayor) //
replace all_q42_norm =. if id_alex=="lb_English_0_506_2013_2014_2016_2017_2018_2019_2021_2022_2023" //Uzbekistan - Observaciones viejas (el cambio positivo es probablemente mayor) //
replace all_q43_norm =. if id_alex=="lb_English_0_506_2013_2014_2016_2017_2018_2019_2021_2022_2023" //Uzbekistan - Observaciones viejas (el cambio positivo es probablemente mayor) //
replace cc_q39b_norm =. if id_alex=="cc_English_0_232_2022_2023" //Uzbekistan - Observaciones viejas (el cambio positivo es probablemente mayor) //
replace all_q29_norm =. if id_alex=="cj_Russian_1_989_2019_2021_2022_2023" //Uzbekistan - Observaciones muy negativas sobre libertad religiosa //
replace all_q29_norm =. if id_alex=="cc_Russian_1_705" //Uzbekistan - Observaciones muy negativas sobre libertad religiosa //
replace all_q76_norm =. if id_alex=="cc_Russian_0_543" //Uzbekistan - Observaciones muy negativas sobre 7.2 //
replace all_q77_norm =. if id_alex=="cc_Russian_0_543" //Uzbekistan - Observaciones muy negativas sobre 7.2 //
replace all_q78_norm =. if id_alex=="cc_Russian_0_543" //Uzbekistan - Observaciones muy negativas sobre 7.2 //
replace all_q79_norm =. if id_alex=="cc_Russian_0_543" //Uzbekistan - Observaciones muy negativas sobre 7.2 //
replace all_q80_norm =. if id_alex=="cc_Russian_0_543" //Uzbekistan - Observaciones muy negativas sobre 7.2 //
replace all_q79_norm =. if id_alex=="lb_English_0_506_2013_2014_2016_2017_2018_2019_2021_2022_2023" //Uzbekistan - Observaciones muy negativas sobre 7.2 //
replace all_q80_norm =. if id_alex=="cc_English_0_1706" //Uzbekistan - Observaciones muy negativas sobre 7.2 //
replace all_q81_norm =. if id_alex=="cc_English_0_1706" //Uzbekistan - Observaciones muy negativas sobre 7.2 //
replace all_q85_norm =. if id_alex=="cc_Russian_0_543" //Uzbekistan - Percepcion muy positiva de 7.5 y contradice long //
replace cc_q26a_norm =. if id_alex=="cc_Russian_1_1341_2023" //Uzbekistan - Percepcion muy positiva de 7.5 y contradice long //
replace cc_q26a_norm =. if id_alex=="cc_Russian_1_1095_2023" //Uzbekistan - Percepcion muy positiva de 7.5 y contradice long //
replace cc_q26a_norm =. if id_alex=="cc_Russian_0_900_2023" //Uzbekistan - Percepcion muy positiva de 7.5 y contradice long //
replace all_q88_norm =. if id_alex=="cc_Russian_1_1341_2023" //Uzbekistan - Percepcion muy positiva de 7.5 y contradice long //
replace cj_q40c_norm =. if id_alex=="cj_English_1_234_2016_2017_2018_2019_2021_2022_2023" //Uzbekistan - Percepcion muy negativa. Observaciones viejas //
replace cj_q40c_norm =. if id_alex=="cj_Russian_0_305_2018_2019_2021_2022_2023" //Uzbekistan - Percepcion muy negativa. Observaciones viejas //
replace cj_q40b_norm =. if id_alex=="cj_Russian_0_305_2018_2019_2021_2022_2023" //Uzbekistan - Percepcion muy negativa. Observaciones viejas //
replace cj_q33a_norm =. if id_alex=="cj_Russian_1_255_2023" //Uzbekistan - Percepcion muy negativa.  //
replace cj_q33b_norm =. if id_alex=="cj_Russian_1_255_2023" //Uzbekistan - Percepcion muy negativa.  //
replace cj_q33c_norm =. if id_alex=="cj_Russian_1_255_2023" //Uzbekistan - Percepcion muy negativa.  //
replace all_q62_norm =. if id_alex=="cc_Russian_1_1341_2023" //Uzbekistan - Percepcion muy negativa. Observaciones viejas //
replace all_q63_norm =. if id_alex=="cc_Russian_1_1341_2023" //Uzbekistan - Percepcion muy negativa. Observaciones viejas //

*Venezuela
drop if id_alex=="cc_Spanish_0_133_2022_2023" //Venezuela // Puntajes relativamente altos en 1.7 //
drop if id_alex=="lb_Spanish_1_577" //Venezuela //  Puntajes relativamente altos
replace all_q22_norm =. if id_alex=="cj_Spanish_1_1013_2023" //Venezuela // Puntajes relativamente altos en 1.7 //
replace all_q23_norm =. if id_alex=="cj_Spanish_1_1013_2023" //Venezuela // Puntajes relativamente altos en 1.7 //
replace all_q24_norm =. if id_alex=="cj_Spanish_1_1013_2023" //Venezuela // Puntajes relativamente altos en 1.7 //
replace all_q25_norm =. if id_alex=="cj_Spanish_1_1013_2023" //Venezuela // Puntajes relativamente altos en 1.7 //
replace all_q26_norm =. if id_alex=="cj_Spanish_1_1013_2023" //Venezuela // Puntajes relativamente altos en 1.7 //
replace all_q27_norm =. if id_alex=="cj_Spanish_1_1013_2023" //Venezuela // Puntajes relativamente altos en 1.7 //
replace all_q8_norm =. if id_alex=="cj_Spanish_1_1013_2023" //Venezuela // Puntajes relativamente altos en 1.7 //
replace all_q25_norm =. if id_alex=="cc_Spanish_0_49" //Venezuela // Puntajes relativamente altos en 1.7 //
replace all_q22_norm =. if id_alex=="cj_Spanish_0_68_2023" //Venezuela // Puntajes relativamente altos en 1.7 //
replace all_q23_norm =. if id_alex=="cj_Spanish_0_68_2023" //Venezuela // Puntajes relativamente altos en 1.7 //
replace all_q24_norm =. if id_alex=="cj_Spanish_0_68_2023" //Venezuela // Puntajes relativamente altos en 1.7 //
replace all_q25_norm =. if id_alex=="cj_Spanish_0_68_2023" //Venezuela // Puntajes relativamente altos en 1.7 //
replace all_q26_norm =. if id_alex=="cj_Spanish_0_68_2023" //Venezuela // Puntajes relativamente altos en 1.7 //
replace all_q27_norm =. if id_alex=="cj_Spanish_0_68_2023" //Venezuela // Puntajes relativamente altos en 1.7 //
replace all_q8_norm =. if id_alex=="cj_Spanish_0_68_2023" //Venezuela // Puntajes relativamente altos en 1.7 //
replace lb_q2d_norm =. if id_alex=="lb_Spanish_1_577" //Venezuela // Cambios muy positivos en 6.3  //
replace lb_q3d_norm =. if id_alex=="lb_Spanish_1_577" //Venezuela // Cambios muy positivos en 6.3  //
replace lb_q19a_norm =. if id_alex=="lb_Spanish_1_577" //Venezuela // Cambios muy positivos en 6.4 //
replace lb_q3d_norm =. if id_alex=="lb_Spanish_0_73_2023" //Venezuela // Cambios muy positivos en 6.3  //
replace lb_q2d_norm =. if id_alex=="lb_Spanish_0_356_2022_2023" //Venezuela // Cambios muy positivos en 6.3  //
replace lb_q3d_norm =. if id_alex=="lb_Spanish_0_356_2022_2023" //Venezuela // Cambios muy positivos en 6.3  //
replace lb_q2d_norm =. if id_alex=="lb_Spanish_1_500_2022_2023" //Venezuela // Cambios muy positivos en 6.3  //
replace lb_q3d_norm =. if id_alex=="lb_Spanish_1_500_2022_2023" //Venezuela // Cambios muy positivos en 6.3  //
replace lb_q19a_norm =. if id_alex=="lb_Spanish_0_73_2023" //Venezuela // Cambios muy positivos en 6.4 //
replace all_q80_norm =. if id_alex=="cc_English_1_330" //Venezuela // Cambios muy negativo en 7.2 //
replace all_q80_norm =. if id_alex=="cc_Spanish_0_81" //Venezuela // Cambios muy negativo en 7.2 //
replace all_q78_norm =. if id_alex=="cc_Spanish_0_1319" //Venezuela // Cambios muy negativo en 7.2 //
replace all_q79_norm =. if id_alex=="cc_Spanish_0_81" //Venezuela // Cambios muy negativo en 7.2 //
replace all_q80_norm =. if id_alex=="lb_Spanish_0_356_2022_2023" //Venezuela // Cambios muy negativo en 7.2 //
replace all_q87_norm =. if id_alex=="cc_Spanish_0_804" //Venezuela // Cambios muy negativo en 7.6 //
replace all_q52_norm =. if id_alex=="cc_Spanish_1_559" //Venezuela Outlier en 1.5 //
replace all_q13_norm =0 if id_alex=="cj_English_1_70" //Venezuela Outlier (muy alto) en 1.6 (Ha habido muertos en las calles por protestar los resultados de la eleccion. No puede subir el puntaje) //
replace all_q13_norm =0 if id_alex=="cj_Spanish_1_744" //Venezuela Outlier (muy alto) en 1.6 //
replace all_q13_norm =0 if id_alex=="cj_Spanish_0_133" //Venezuela Outlier (muy alto) en 1.6 //
replace all_q13_norm =0 if id_alex=="cj_Spanish_0_1029_2022_2023" //Venezuela Outlier (muy alto) en 1.6 //
replace all_q17_norm =0 if id_alex=="cj_Spanish_1_744" //Venezuela Outlier (muy alto) en 1.6 //
replace all_q17_norm =0 if id_alex=="cj_English_1_70" //Venezuela Outlier (muy alto) en 1.6 //
replace all_q17_norm =0 if id_alex=="cj_Spanish_0_306_2023" //Venezuela Outlier (muy alto) en 1.6 //
replace all_q13_norm =0 if id_alex=="cj_Spanish_0_306_2023" //Venezuela Outlier (muy alto) en 1.6 //
replace all_q13_norm =0 if id_alex=="cj_Spanish_1_869" //Venezuela Outlier (muy alto) en 1.6 //
replace all_q13_norm =. if id_alex=="cj_Spanish_0_469" //Venezuela Outlier (muy alto) en 1.6 / 

*Vietnam
drop if id_alex=="cc_English_0_164" //Vietnam /* Los puntajes de este experto son altos */
drop if id_alex=="cc_English_0_629" //Vietnam /* Los puntajes de este experto son altos */
replace cj_q28_norm=. if country=="Vietnam" // Vietnam /* El puntaje del anio pasado se borro, es igual a 1 */
drop if id_alex=="cj_English_0_303" //Vietnam /* Los puntajes de este experto son altos y es un experto nuevo */
replace all_q4_norm =. if id_alex=="cc_English_0_1188" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf1.3 (Ver long) */
replace all_q7_norm =. if id_alex=="cc_English_0_1188" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf1.3 (Ver long) */
replace all_q8_norm =. if id_alex=="cc_English_0_1188" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf1.3 (Ver long) */
replace all_q4_norm =. if id_alex=="cj_English_1_286" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf1.3 (Ver long)*/
replace all_q7_norm =. if id_alex=="cj_English_1_286" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf1.3 (Ver long)*/
replace all_q8_norm =. if id_alex=="cj_English_1_286" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf1.3 (Ver long)*/
replace cj_q40d_norm =. if id_alex=="cj_English_1_286" //Vietnam /* Cambio las variables originales que afectan el sf8.6 */
replace cj_q40c_norm =. if id_alex=="cj_English_1_286" //Vietnam /* Cambio las variables originales que afectan el sf8.6 */
replace cj_q41d_norm =. if id_alex=="cj_English_1_286" //Vietnam /* Cambio las variables originales que afectan el sf8.6 */
replace cc_q33_norm =. if id_alex=="cc_English_0_32" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf1.4 */
replace cj_q36c_norm =. if id_alex=="cj_English_1_638" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf1.4 */
replace cj_q8_norm =. if id_alex=="cj_English_1_638" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf1.4 */
replace cj_q36b_norm =. if id_alex=="cj_English_1_957_2023" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf1.5 */
replace all_q24_norm =. if id_alex=="cc_English_0_495_2022_2023" //Vietnam /* Experto muy positivo en sf1.7 */
replace all_q25_norm =. if id_alex=="cc_English_0_495_2022_2023" //Vietnam /* Experto muy positivo en sf1.7 */
replace all_q26_norm =. if id_alex=="cc_English_0_495_2022_2023" //Vietnam /* Experto muy positivo en sf1.7 */
replace all_q27_norm =. if id_alex=="cc_English_0_495_2022_2023" //Vietnam /* Experto muy positivo en sf1.7 */
replace all_q8_norm =. if id_alex=="cc_English_0_495_2022_2023" //Vietnam /* Experto muy positivo en sf1.7 */
replace all_q57_norm =. if id_alex=="lb_English_1_389_2018_2019_2021_2022_2023" //Vietnam /* Experto muy positivo en sf2.2 */
replace all_q58_norm =. if id_alex=="lb_English_1_389_2018_2019_2021_2022_2023" //Vietnam /* Experto muy positivo en sf2.2 */
replace all_q59_norm =. if id_alex=="lb_English_1_389_2018_2019_2021_2022_2023" //Vietnam /* Experto muy positivo en sf2.2 */
replace all_q60_norm =. if id_alex=="lb_English_1_389_2018_2019_2021_2022_2023" //Vietnam /* Experto muy positivo en sf2.2 */
replace cc_q26h_norm =. if id_alex=="cc_English_0_1188" //Vietnam /* Experto muy positivo en sf2.2 */
replace all_q28_norm =. if id_alex=="lb_English_1_389_2018_2019_2021_2022_2023" //Vietnam /* Experto muy positivo en sf2.2 */
replace all_q6_norm =. if id_alex=="lb_English_1_389_2018_2019_2021_2022_2023" //Vietnam /* Experto muy positivo en sf2.2 */
replace cj_q33d_norm =. if id_alex=="cj_English_1_286" //Vietnam /* Experto muy positivo en sf2.2 */
replace cj_q33e_norm =. if id_alex=="cj_English_1_286" //Vietnam /* Experto muy positivo en sf2.2 */
replace cc_q32i_norm =. if id_alex=="cc_French_1_88" //Vietnam /* Experto negativo en sf3.1
replace ph_q6a_norm =. if id_alex=="ph_English_1_416" //Vietnam /* Hay muy pocos expertos de PH. Este experto es muy positivo y afecta el puntaje de 4.1 */
replace ph_q6b_norm =. if id_alex=="ph_English_1_416" //Vietnam /* Hay muy pocos expertos de PH. Este experto es muy positivo y afecta el puntaje de 4.1 */
replace ph_q6c_norm =. if id_alex=="ph_English_1_416" //Vietnam /* Hay muy pocos expertos de PH. Este experto es muy positivo y afecta el puntaje de 4.1 */
replace ph_q6d_norm =. if id_alex=="ph_English_1_416" //Vietnam /* Hay muy pocos expertos de PH. Este experto es muy positivo y afecta el puntaje de 4.1 */
replace ph_q6e_norm =. if id_alex=="ph_English_1_416" //Vietnam /* Hay muy pocos expertos de PH. Este experto es muy positivo y afecta el puntaje de 4.1 */
replace cj_q25c_norm =. if id_alex=="cj_English_0_639_2022_2023" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf4.3 (Pocos expertos)*/
replace cj_q6a_norm =. if id_alex=="cj_English_0_639_2022_2023" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf4.3 (Pocos expertos)*/
replace cj_q6b_norm =. if id_alex=="cj_English_0_639_2022_2023" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf4.3 (Pocos expertos)*/
replace cj_q42c_norm =. if id_alex=="cj_English_0_1027_2022_2023" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf4.3 (Pocos expertos)*/
replace cj_q3a_norm =. if id_alex=="cj_English_0_1027_2022_2023" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf4.3 (Pocos expertos)*/
replace cj_q21a_norm =. if id_alex=="cj_English_1_286" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf4.3 (Pocos expertos)*/
replace all_q30_norm =. if id_alex=="cc_English_1_1012" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf4.5*/
replace all_q30_norm=. if id_alex=="cj_English_1_286" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf4.5*/
replace all_q29_norm=. if id_alex=="cj_English_0_1027_2022_2023" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf4.5*/
replace ph_q8a_norm =. if id_alex=="ph_English_1_179_2019_2021_2022_2023" //Vietnam /* Hay muy pocos expertos de PH. Este experto es muy positivo y afecta el puntaje de 6.2 */
replace ph_q8b_norm =. if id_alex=="ph_English_1_179_2019_2021_2022_2023" //Vietnam /* Hay muy pocos expertos de PH. Este experto es muy positivo y afecta el puntaje de 6.2 */
replace ph_q8c_norm =. if id_alex=="ph_English_1_179_2019_2021_2022_2023" //Vietnam /* Hay muy pocos expertos de PH. Este experto es muy positivo y afecta el puntaje de 6.2 */
replace ph_q8d_norm =. if id_alex=="ph_English_1_179_2019_2021_2022_2023" //Vietnam /* Hay muy pocos expertos de PH. Este experto es muy positivo y afecta el puntaje de 6.2 */
replace ph_q8e_norm =. if id_alex=="ph_English_1_179_2019_2021_2022_2023" //Vietnam /* Hay muy pocos expertos de PH. Este experto es muy positivo y afecta el puntaje de 6.2 */
replace all_q48_norm=. if id_alex=="lb_English_0_49" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf6.4*/
replace all_q49_norm=. if id_alex=="lb_English_0_49" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf6.4*/
replace all_q50_norm=. if id_alex=="lb_English_0_49" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf6.4*/
replace lb_q19a_norm=. if id_alex=="lb_English_0_49" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf6.4*/
replace cc_q12_norm=. if id_alex=="cc_English_0_941_2022_2023" //Vietnam /* Disminuyo la magnitud del cambio positivo en esa pregunta */
replace cc_q12_norm=. if id_alex=="cc_English_0_495_2022_2023" //Vietnam /* Disminuyo la magnitud del cambio positivo en esa pregunta */
replace cc_q26h_norm=. if id_alex=="cc_English_1_1163_2023" //Vietnam /* Disminuyo la magnitud del cambio positivo en esa pregunta (sf7.3) */
replace cc_q28e_norm=. if id_alex=="cc_English_1_1163_2023" //Vietnam /* Disminuyo la magnitud del cambio positivo en esa pregunta (sf7.3) */
replace all_q51_norm=. if id_alex=="lb_English_1_389_2018_2019_2021_2022_2023" //Vietnam /* Disminuyo la magnitud del cambio positivo en esa pregunta (sf7.3) */
replace all_q59_norm=. if id_alex=="lb_English_1_541_2018_2019_2021_2022_2023" //Vietnam /* Disminuyo la magnitud del cambio positivo en esa pregunta (sf7.3) */
replace all_q83_norm=. if id_alex=="lb_English_1_389_2018_2019_2021_2022_2023" //Vietnam /* Disminuyo la magnitud del cambio positivo en esa pregunta (sf7.3) */
replace all_q59_norm=. if id_alex=="cc_English_1_193" //Vietnam /* Disminuyo la magnitud del cambio positivo en esa pregunta (sf7.3) */
replace all_q86_norm=. if id_alex=="lb_English_0_342" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf7.6 (Dos nuevos expertos) */
replace all_q87_norm=. if id_alex=="lb_English_0_342" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf7.6 (Dos nuevos expertos) */
replace all_q86_norm=. if id_alex=="lb_English_0_49" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf7.6 (Dos nuevos expertos) */
replace all_q87_norm=. if id_alex=="lb_English_0_49" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf7.6 (Dos nuevos expertos) */
replace cj_q18e_norm =. if id_alex=="cj_English_0_639_2022_2023" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf8.1 (Pocos expertos)*/
replace cj_q16e_norm =. if id_alex=="cj_English_1_286" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf8.1 (Pocos expertos)*/
replace cj_q25b_norm =. if id_alex=="cj_English_0_639_2022_2023" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf8.1 (Pocos expertos)*/
replace cj_q25c_norm =. if id_alex=="cj_English_0_639_2022_2023" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf8.1 (Pocos expertos)*/
replace cj_q7a_norm =. if id_alex=="cj_English_1_286" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf8.2 (Pocos expertos)*/
replace cj_q7b_norm =. if id_alex=="cj_English_1_286" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf8.2 (Pocos expertos)*/
replace cj_q7c_norm =. if id_alex=="cj_English_1_286" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf8.2 (Pocos expertos)*/
replace cj_q21a_norm =. if id_alex=="cj_English_1_286" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf8.3 (Pocos expertos)*/
replace cj_q21h_norm =. if id_alex=="cj_English_1_286" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf8.3 (Pocos expertos)*/
replace cj_q21e_norm =. if id_alex=="cj_English_0_1027_2022_2023" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf8.3 (Pocos expertos)*/
replace cj_q40b_norm =. if id_alex=="cj_English_1_638" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf8.6 (Pocos expertos)*/
replace cj_q40c_norm =. if id_alex=="cj_English_1_638" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf8.6 (Pocos expertos)*/
replace cj_q40b_norm =. if id_alex=="cj_English_1_286" //Vietnam /* Disminuyo la magnitud del cambio positivo en sf8.6 (Pocos expertos)*/
drop if id_alex=="cj_English_1_1240_2019_2021_2022_2023" //Vietnam
replace cc_q26h_norm =. if id_alex=="cc_English_0_502_2023" //Vietnam 
replace cc_q28e_norm =. if id_alex=="cc_English_0_502_2023" //Vietnam 
replace ph_q8g_norm =. if id_alex=="ph_English_1_416" //Vietnam 
replace cc_q9c_norm =. if id_alex=="cc_English_0_941_2022_2023" //Vietnam 
replace cc_q9c_norm =. if id_alex=="cc_English_0_495_2022_2023" //Vietnam 
replace all_q30_norm =. if id_alex=="cc_English_0_1188" //Vietnam 
replace all_q29_norm =. if id_alex=="cc_English_0_941_2022_2023" //Vietnam 
replace all_q30_norm =. if id_alex=="cc_English_0_941_2022_2023" //Vietnam 
replace all_q30_norm =. if id_alex=="cj_English_1_314_2014_2016_2017_2018_2019_2021_2022_2023" //Vietnam 
replace all_q48_norm =. if id_alex=="cc_French_1_88" //Vietnam 
replace all_q49_norm =. if id_alex=="cc_French_1_88" //Vietnam 
replace all_q50_norm =. if id_alex=="cc_French_1_88" //Vietnam 
replace cc_q28e_norm =. if id_alex=="cc_English_0_495_2022_2023" //Vietnam
replace all_q51_norm =. if id_alex=="lb_English_1_385_2023" //Vietnam
replace all_q28_norm =. if id_alex=="lb_English_1_385_2023" //Vietnam
replace cj_q15_norm =. if id_alex=="cj_English_0_1394_2018_2019_2021_2022_2023" //Vietnam
replace cj_q32b_norm =. if id_alex=="cj_English_0_857_2014_2016_2017_2018_2019_2021_2022_2023" //Vietnam
replace cj_q32b_norm =. if id_alex=="cj_English_1_685_2017_2018_2019_2021_2022_2023" //Vietnam
replace all_q96_norm =. if id_alex=="cj_English_1_685_2017_2018_2019_2021_2022_2023" //Vietnam

*Zambia
drop if id_alex=="cc_English_0_567" //Zambia /* Los puntajes de este experto son altos y generan cambios positivos en f1 y f3 */
replace all_q96_norm =. if id_alex=="cj_English_0_669_2019_2021_2022_2023" //Zambia /* Disminuyo la magnitud del cambio negativo del sf2.4. Los expertos son viejos */
replace all_q96_norm =. if id_alex=="cj_English_0_888_2019_2021_2022_2023" //Zambia /* Disminuyo la magnitud del cambio negativo del sf2.4. Los expertos son viejos */
replace cc_q13_norm =. if id_alex=="cc_English_0_153" //Zambia /* Disminuyo la magnitud del cambio positivo del sf7.5 */
replace cc_q26a_norm =. if id_alex=="cc_English_0_1574" //Zambia /* Disminuyo la magnitud del cambio positivo del sf7.5 */
replace cc_q26b_norm =. if id_alex=="cc_English_0_1611_2022_2023" //Zambia /* Disminuyo la magnitud del cambio negativo del sf7.6 */
replace all_q59_norm =. if id_alex=="cc_English_0_465_2022_2023" //Zambia /* Disminuyo la magnitud del cambio positivo del sf7.7 */
replace cc_q14a_norm =. if id_alex=="cc_English_0_465_2022_2023" //Zambia /* Disminuyo la magnitud del cambio positivo del sf7.7 */
replace all_q90_norm=. if country=="Zambia" //Zambia /* Numeros muy altos. El anio pasado lo borramos */
replace all_q91_norm=. if country=="Zambia" //Zambia /* Numeros muy altos. El anio pasado lo borramos */
replace cc_q33_norm=. if id_alex=="cc_English_0_888_2022_2023" //Zambia /* Disminuyo la magnitud del cambio positivo del sf1.4 */
replace all_q24_norm=. if country=="Zambia" //Zambia /* Numeros muy altos. El anio pasado lo borramos */
replace cc_q9c_norm =. if id_alex=="cc_English_0_153" //Zambia /* Disminuyo la magnitud del cambio positivo del sf3.4 */
replace cc_q40a_norm =. if id_alex=="cc_English_0_153" //Zambia /* Disminuyo la magnitud del cambio positivo del sf3.4 */
replace cc_q40b_norm =. if id_alex=="cc_English_0_153" //Zambia /* Disminuyo la magnitud del cambio positivo del sf3.4 */
replace cc_q40a_norm =.6666667 if id_alex=="cc_English_0_888_2022_2023" //Zambia /* Disminuyo la magnitud del cambio positivo del sf3.4 */
replace cc_q40b_norm =.6666667 if id_alex=="cc_English_0_888_2022_2023" //Zambia /* Disminuyo la magnitud del cambio positivo del sf3.4 */
replace cj_q42c_norm =. if id_alex=="cj_English_0_1026_2019_2021_2022_2023" //Zambia /* Disminuyo la magnitud del cambio negativo del sf4.6 */
replace cj_q42d_norm =. if id_alex=="cj_English_0_1026_2019_2021_2022_2023" //Zambia /* Disminuyo la magnitud del cambio negativo del sf4.6 */
replace cj_q42d_norm =. if id_alex=="cj_English_1_583_2018_2019_2021_2022_2023" //Zambia /* Disminuyo la magnitud del cambio negativo del sf4.6 */
replace cj_q15_norm =. if id_alex=="cj_English_0_233_2013_2014_2016_2017_2018_2019_2021_2022_2023" //Zambia /* Disminuyo la magnitud del cambio negativo del sf5.3 */
replace cj_q15_norm =. if id_alex=="cj_English_0_123_2013_2014_2016_2017_2018_2019_2021_2022_2023" //Zambia /* Disminuyo la magnitud del cambio negativo del sf5.3 */
replace cc_q26b_norm =. if id_alex=="cc_English_1_513" //Zambia /* Disminuyo la magnitud del cambio negativo del sf7.6 */
replace all_q59_norm =. if id_alex=="lb_English_0_491_2022_2023" //Zambia /* Disminuyo la magnitud del cambio positivo del sf7.7 */
drop if id_alex=="cj_English_0_233_2013_2014_2016_2017_2018_2019_2021_2022_2023" //Zambia
drop if id_alex=="cc_English_0_503_2018_2019_2021_2022_2023" //Zambia
replace cj_q31f_norm =. if id_alex=="cj_English_0_669_2019_2021_2022_2023" //Zambia 
replace cj_q31g_norm =. if id_alex=="cj_English_0_669_2019_2021_2022_2023" //Zambia 
replace cj_q15_norm =. if id_alex=="cj_English_0_888_2019_2021_2022_2023" //Zambia 
replace cj_q20o_norm =. if id_alex=="cj_English_0_1026_2019_2021_2022_2023" //Zambia 
replace all_q59_norm =. if id_alex=="lb_English_0_389_2013_2014_2016_2017_2018_2019_2021_2022_2023" //Zambia 
replace all_q59_norm =. if id_alex=="cc_English_0_128_2013_2014_2016_2017_2018_2019_2021_2022_2023" //Zambia 
replace cj_q31f_norm =. if id_alex=="cj_English_0_876" //Zambia 
replace cj_q31g_norm =. if id_alex=="cj_English_0_876" //Zambia 
replace cj_q42c_norm =. if id_alex=="cj_English_0_876" //Zambia 

*Zimbabwe
replace cc_q40a_norm=. if country=="Zimbabwe" /* Zimbabwe */
replace all_q2_norm=. if id_alex=="cc_English_0_844" /* Zimbabwe */
replace all_q2_norm=. if id_alex=="lb_English_1_498_2023" /* Zimbabwe */
replace all_q2_norm=. if id_alex=="cj_English_0_530" /* Zimbabwe */
replace all_q21_norm=. if id_alex=="cc_English_0_1302_2022_2023" /* Zimbabwe */
replace cj_q36c_norm=. if id_alex=="cj_English_0_120" /* Zimbabwe */
replace cj_q36c_norm=. if id_alex=="cj_English_0_809_2022_2023" /* Zimbabwe */
replace cj_q36c_norm=. if id_alex=="cj_English_1_797_2023" /* Zimbabwe */
replace cj_q36c_norm=. if id_alex=="cj_English_1_117_2023" /* Zimbabwe */
replace cj_q38_norm=. if id_alex=="cj_English_1_797_2023" /* Zimbabwe */
replace cj_q8_norm=. if id_alex=="cj_English_1_236_2023" /* Zimbabwe */
replace all_q96_norm=. if id_alex=="cc_English_1_802" /* Zimbabwe */
replace all_q29_norm=. if id_alex=="cc_English_1_1409_2023" /* Zimbabwe */
replace all_q29_norm=. if id_alex=="cj_English_0_494" /* Zimbabwe */
replace all_q29_norm=. if id_alex=="cj_English_1_860_2023" /* Zimbabwe */
replace all_q30_norm=. if id_alex=="cj_English_1_860_2023" /* Zimbabwe */
replace all_q30_norm=. if id_alex=="cj_English_0_494" /* Zimbabwe */
replace all_q19_norm=. if id_alex=="cj_English_0_530" /* Zimbabwe */
replace all_q54_norm=. if id_alex=="cc_English_0_844" /* Zimbabwe */
replace  cc_q28c_norm=. if id_alex=="cc_English_0_496" /* Zimbabwe */
replace  all_q63_norm=. if id_alex=="lb_English_1_601_2023" /* Zimbabwe */
replace  lb_q2d_norm=. if id_alex=="lb_English_0_331" /* Zimbabwe */
replace  lb_q3d_norm=. if id_alex=="lb_English_0_331" /* Zimbabwe */
replace  cc_q10_norm=. if id_alex=="cc_English_0_802_2023" /* Zimbabwe */
replace  cc_q10_norm=. if id_alex=="cc_English_0_903_2023" /* Zimbabwe */
replace  cj_q26_norm=. if id_alex=="cj_English_1_324" /* Zimbabwe */
replace  all_q70_norm=. if id_alex=="cc_English_1_372_2023" /* Zimbabwe */
replace  all_q70_norm=. if id_alex=="lb_English_1_706_2023" /* Zimbabwe */
replace  all_q92_norm=. if id_alex=="cc_English_1_372_2023" /* Zimbabwe */
replace  all_q78_norm=. if id_alex=="cc_English_1_800" /* Zimbabwe */
replace  all_q79_norm=. if id_alex=="cc_English_1_800" /* Zimbabwe */
replace  all_q80_norm=. if id_alex=="cc_English_1_800" /* Zimbabwe */
replace  all_q80_norm=. if id_alex=="lb_English_1_61" /* Zimbabwe */
replace  all_q84_norm=. if id_alex=="cc_English_0_496" /* Zimbabwe */
replace  cc_q13_norm=. if id_alex=="cc_English_0_143_2022_2023" /* Zimbabwe */
replace  cc_q13_norm=. if id_alex=="cc_English_0_903_2023" /* Zimbabwe */
replace  cj_q20a_norm=. if id_alex=="cj_English_0_494" /* Zimbabwe */
replace  cj_q20a_norm=. if id_alex=="cj_English_0_55" /* Zimbabwe */
replace  cj_q20a_norm=. if id_alex=="cj_English_0_926_2022_2023" /* Zimbabwe */
replace  cj_q20a_norm=. if id_alex=="cj_English_1_797_2023" /* Zimbabwe */
replace  cj_q20b_norm=. if id_alex=="cj_English_0_926_2022_2023" /* Zimbabwe */
replace  cj_q7b_norm=. if id_alex=="cj_English_0_926_2022_2023" /* Zimbabwe */
replace  cj_q12b_norm=. if id_alex=="cj_English_0_489" /* Zimbabwe */
replace  cj_q12c_norm=. if id_alex=="cj_English_0_489" /* Zimbabwe */
replace  cj_q12d_norm=. if id_alex=="cj_English_0_489" /* Zimbabwe */
replace  cj_q12e_norm=. if id_alex=="cj_English_0_489" /* Zimbabwe */
replace  cj_q12f_norm=. if id_alex=="cj_English_0_489" /* Zimbabwe */
replace  cj_q40b_norm=. if id_alex=="cj_English_0_809_2022_2023" /* Zimbabwe */
replace  cj_q40c_norm=. if id_alex=="cj_English_1_797_2023" /* Zimbabwe */
replace  cj_q40b_norm=. if id_alex=="cj_English_0_809_2022_2023" /* Zimbabwe */
replace  cj_q40c_norm=. if id_alex=="cj_English_1_797_2023" /* Zimbabwe */
replace  cc_q28a_norm=. if id_alex=="cc_English_1_601_2023" /* Zimbabwe */
replace  cc_q14a_norm=. if id_alex=="cc_English_0_903_2023" /* Zimbabwe */
replace  cc_q14a_norm=. if id_alex=="cc_English_0_802_2023" /* Zimbabwe */
replace  cc_q14b_norm=. if id_alex=="cc_English_0_802_2023" /* Zimbabwe */
replace  cc_q16g_norm=. if id_alex=="cc_English_1_601_2023" /* Zimbabwe */
replace  cj_q20e_norm=. if id_alex=="cj_English_0_926_2022_2023" /* Zimbabwe */
replace  cj_q20e_norm=. if id_alex=="cj_English_1_797_2023" /* Zimbabwe */
replace  cj_q7a_norm=. if id_alex=="cj_English_0_120" /* Zimbabwe */
replace  cj_q7a_norm=. if id_alex=="cj_English_0_926_2022_2023" /* Zimbabwe */
replace  cj_q12d_norm=. if id_alex=="cj_English_1_308" /* Zimbabwe */
replace  cj_q40c_norm=. if id_alex=="cj_English_0_809_2022_2023" /* Zimbabwe */
replace  cj_q20m_norm=. if id_alex=="cj_English_0_809_2022_2023" /* Zimbabwe */
replace  cj_q40b_norm=. if id_alex=="cj_English_1_797_2023" /* Zimbabwe */
replace  cj_q20m_norm=. if id_alex=="cj_English_1_797_2023" /* Zimbabwe */
replace  cj_q40b_norm=. if id_alex=="cj_English_0_489" /* Zimbabwe */
replace  cj_q40c_norm=. if id_alex=="cj_English_0_489" /* Zimbabwe */
replace  cj_q20m_norm=. if id_alex=="cj_English_0_489" /* Zimbabwe */
replace  cc_q26b_norm=. if id_alex=="cc_English_0_1302_2022_2023" /* Zimbabwe */
replace  all_q78_norm=. if id_alex=="cc_English_1_327" /* Zimbabwe */
replace  all_q79_norm=. if id_alex=="cc_English_1_327" /* Zimbabwe */
replace  all_q80_norm=. if id_alex=="cc_English_1_327" /* Zimbabwe */
replace  cj_q27a_norm=. if id_alex=="cj_English_0_809_2022_2023" /* Zimbabwe */
replace  cj_q27a_norm=. if id_alex=="cj_English_1_797_2023" /* Zimbabwe */
replace  cj_q20a_norm=. if id_alex=="cj_English_0_530" /* Zimbabwe */
replace  all_q10_norm =. if id_alex=="cc_English_1_802" /* Zimbabwe */
replace  all_q12_norm =. if id_alex=="cc_English_0_844" /* Zimbabwe */
replace  all_q11_norm =. if id_alex=="cj_English_0_746_2022_2023" /* Zimbabwe */
replace  all_q16_norm =. if id_alex=="cc_English_0_844" /* Zimbabwe */
replace  all_q16_norm =. if id_alex=="cc_English_0_1302_2022_2023" /* Zimbabwe */
replace  all_q25_norm =. if id_alex=="cj_English_1_860_2023" /* Zimbabwe */
replace  lb_q17b_norm =. if id_alex=="lb_English_1_601_2023" /* Zimbabwe */
replace  all_q97_norm =. if id_alex=="cc_English_1_290" /* Zimbabwe */
replace  cc_q27_norm =. if id_alex=="cc_English_0_844" /* Zimbabwe */
replace  all_q94_norm =. if id_alex=="cc_English_1_290" /* Zimbabwe */
replace  all_q94_norm =. if id_alex=="cc_English_1_802" /* Zimbabwe */
replace  all_q32_norm =. if id_alex=="cc_English_0_143_2022_2023" /* Zimbabwe */
replace  all_q32_norm =. if id_alex=="cc_English_0_1302_2022_2023" /* Zimbabwe */
replace  all_q32_norm =. if id_alex=="cc_English_1_372_2023" /* Zimbabwe */
replace  all_q32_norm =. if id_alex=="cc_English_1_144_2023" /* Zimbabwe */
replace  all_q19_norm =. if id_alex=="cj_English_0_746_2022_2023" /* Zimbabwe */
replace  all_q19_norm =. if id_alex=="cc_English_0_143_2022_2023" /* Zimbabwe */
replace  all_q96_norm =. if id_alex=="cc_English_1_290" /* Zimbabwe */
replace  cc_q33_norm =. if id_alex=="cc_English_0_1302_2022_2023" /* Zimbabwe */
replace  all_q62_norm =. if id_alex=="cc_English_1_802" /* Zimbabwe */
replace  all_q63_norm =. if id_alex=="lb_English_1_498_2023" /* Zimbabwe */
replace  lb_q2d_norm =. if id_alex=="lb_English_1_601_2023" /* Zimbabwe */
replace  all_q48_norm =. if id_alex=="cc_English_0_844" /* Zimbabwe */
replace  all_q78_norm =. if id_alex=="cc_English_0_1302_2022_2023" /* Zimbabwe */
replace  all_q79_norm =. if id_alex=="cc_English_0_1302_2022_2023" /* Zimbabwe */
replace  all_q80_norm =. if id_alex=="cc_English_0_1302_2022_2023" /* Zimbabwe */
replace  all_q75_norm =0 if id_alex=="cc_English_1_144_2023" /* Zimbabwe */
replace  cj_q26_norm =. if id_alex=="cj_English_0_809_2022_2023" /* Zimbabwe */
replace  cj_q36c_norm =. if id_alex=="cj_English_0_489" /* Zimbabwe */
replace  all_q19_norm =. if id_alex=="cj_English_0_746_2022_2023" /* Zimbabwe */
replace  all_q25_norm =. if id_alex=="cc_English_1_1409_2023" /* Zimbabwe */
replace  all_q25_norm =. if id_alex=="cj_English_0_809_2022_2023" /* Zimbabwe */
replace  all_q23_norm =. if id_alex=="cj_English_1_860_2023" /* Zimbabwe */
replace  all_q8_norm =. if id_alex=="cj_English_1_860_2023" /* Zimbabwe */
replace  all_q16_norm =. if id_alex=="cc_English_0_1302_2022_2023" /* Zimbabwe */
replace  all_q94_norm =. if id_alex=="cc_English_1_802" /* Zimbabwe */
replace  all_q18_norm =. if id_alex=="cc_English_0_844" /* Zimbabwe */
replace  all_q17_norm =. if id_alex=="lb_English_0_352_2022_2023" /* Zimbabwe */
replace  cj_q10_norm =. if id_alex=="cj_English_0_489" /* Zimbabwe */
replace  cj_q26_norm =. if id_alex=="cj_English_0_746_2022_2023" /* Zimbabwe */
replace  all_q75_norm =0 if id_alex=="cc_English_1_601_2023" /* Zimbabwe */
replace  all_q69_norm =. if id_alex=="cc_English_0_143_2022_2023" /* Zimbabwe */
replace  all_q70_norm =. if id_alex=="cc_English_0_143_2022_2023" /* Zimbabwe */
replace  all_q69_norm =. if id_alex=="cc_English_1_601_2023" /* Zimbabwe */
replace  all_q70_norm =. if id_alex=="cc_English_1_601_2023" /* Zimbabwe */
replace  all_q71_norm =. if id_alex=="cc_English_1_601_2023" /* Zimbabwe */
replace  all_q72_norm =. if id_alex=="cc_English_1_601_2023" /* Zimbabwe */
replace  all_q71_norm =. if id_alex=="cc_English_0_773" /* Zimbabwe */
replace  all_q72_norm =. if id_alex=="cc_English_0_773" /* Zimbabwe */
replace  cc_q9c_norm =. if id_alex=="cc_English_0_639" /* Zimbabwe */
replace  all_q37_norm =. if id_alex=="cc_English_0_844" /* Zimbabwe */
replace  all_q32_norm =. if id_alex=="cc_English_0_773" /* Zimbabwe */
replace  lb_q23f_norm =. if id_alex=="lb_English_0_352_2022_2023" /* Zimbabwe */
replace  lb_q23g_norm =. if id_alex=="lb_English_0_352_2022_2023" /* Zimbabwe */
replace  lb_q23b_norm =. if id_alex=="lb_English_0_86_2023" /* Zimbabwe */
replace  all_q72_norm =. if id_alex=="lb_English_0_86_2023" /* Zimbabwe */
replace  all_q92_norm =. if id_alex=="lb_English_1_498_2023" /* Zimbabwe */
replace  cj_q7a_norm =. if id_alex=="cj_English_1_797_2023" /* Zimbabwe */
replace  cj_q20a_norm =. if id_alex=="cj_English_0_489" /* Zimbabwe */
replace  cj_q20e_norm =. if id_alex=="cj_English_0_489" /* Zimbabwe */
replace  cc_q28e_norm =. if id_alex=="cc_English_0_639" /* Zimbabwe */
replace  cj_q32b_norm =. if id_alex=="cj_English_0_926_2022_2023" /* Zimbabwe */
replace  cj_q16d_norm =. if id_alex=="cj_English_0_120" /* Zimbabwe */
replace  cj_q16f_norm =. if id_alex=="cj_English_0_120" /* Zimbabwe */
replace  cj_q16g_norm =. if id_alex=="cj_English_0_120" /* Zimbabwe */
replace  cj_q16h_norm =. if id_alex=="cj_English_0_120" /* Zimbabwe */
replace  cj_q16i_norm =. if id_alex=="cj_English_0_120" /* Zimbabwe */
replace  cj_q25a_norm =. if id_alex=="cj_English_0_530" /* Zimbabwe */
replace  cj_q25b_norm =. if id_alex=="cj_English_0_530" /* Zimbabwe */
replace  cj_q25c_norm =. if id_alex=="cj_English_0_530" /* Zimbabwe */
replace  all_q48_norm =. if id_alex=="lb_English_1_320_2018_2019_2021_2022_2023" /* Zimbabwe */
replace  all_q49_norm =. if id_alex=="lb_English_1_320_2018_2019_2021_2022_2023" /* Zimbabwe */
replace  all_q50_norm =. if id_alex=="lb_English_1_320_2018_2019_2021_2022_2023" /* Zimbabwe */
replace  cj_q36c_norm =. if id_alex=="cj_English_0_494" /* Zimbabwe */
replace  cj_q36a_norm =. if id_alex=="cj_English_0_494" /* Zimbabwe */
replace  cj_q7b_norm =. if id_alex=="cj_English_1_797_2023" /* Zimbabwe */  
replace  cj_q7a_norm =. if id_alex=="cj_English_1_860_2023" /* Zimbabwe */  
replace  cj_q36c_norm =. if id_alex=="cj_English_0_55" /* Zimbabwe */  

*/
*/



br question year country longitudinal id_alex total_score ROLI f_1 f_2 f_3 f_4 f_6 f_7 f_8  if country=="Vietnam" 





drop total_score_mean
bysort country: egen total_score_mean=mean(total_score)

save "$path2data\qrq.dta", replace


/*=================================================================================================================
					VIII. Number of surveys per discipline, year, and country
=================================================================================================================*/

drop count_cc count_cj count_lb count_ph cc_total cj_total lb_total ph_total tail_cc tail_cj tail_lb tail_ph cc_total_tail cj_total_tail lb_total_tail ph_total_tail percentage_tail_cc percentage_tail_cj percentage_tail_lb percentage_tail_ph

gen aux_cc=1 if question=="cc"
gen aux_cj=1 if question=="cj"
gen aux_lb=1 if question=="lb"
gen aux_ph=1 if question=="ph"

local i=2013
	while `i'<=2024 {
		gen aux_cc_`i'=1 if question=="cc" & year==`i'
		gen aux_cj_`i'=1 if question=="cj" & year==`i'
		gen aux_lb_`i'=1 if question=="lb" & year==`i'
		gen aux_ph_`i'=1 if question=="ph" & year==`i'
	local i=`i'+1 
}	

gen aux_cc_24_long=1 if question=="cc" & year==2024 & longitudinal==1
gen aux_cj_24_long=1 if question=="cj" & year==2024 & longitudinal==1
gen aux_lb_24_long=1 if question=="lb" & year==2024 & longitudinal==1
gen aux_ph_24_long=1 if question=="ph" & year==2024 & longitudinal==1

bysort country: egen cc_total=total(aux_cc)
bysort country: egen cj_total=total(aux_cj)
bysort country: egen lb_total=total(aux_lb)
bysort country: egen ph_total=total(aux_ph)

local i=2013
	while `i'<=2024 {
		bysort country: egen cc_total_`i'=total(aux_cc_`i')
		bysort country: egen cj_total_`i'=total(aux_cj_`i')
		bysort country: egen lb_total_`i'=total(aux_lb_`i')
		bysort country: egen ph_total_`i'=total(aux_ph_`i')
	local i=`i'+1 
}	

bysort country: egen cc_total_2024_long=total(aux_cc_24_long)
bysort country: egen cj_total_2024_long=total(aux_cj_24_long)
bysort country: egen lb_total_2024_long=total(aux_lb_24_long)
bysort country: egen ph_total_2024_long=total(aux_ph_24_long)

egen tag = tag(country)

*Short counts

br country cc_total cj_total lb_total ph_total cc_total_2024 cj_total_2024 lb_total_2024 ph_total_2024 cc_total_2024_long cj_total_2024_long lb_total_2024_long ph_total_2024_long if tag==1

*All counts

br country cc_total cj_total lb_total ph_total ///
cc_total_2024 cj_total_2024 lb_total_2024 ph_total_2024 ///
cc_total_2023 cj_total_2023 lb_total_2023 ph_total_2023 ///
cc_total_2022 cj_total_2022 lb_total_2022 ph_total_2022 /// 
cc_total_2021 cj_total_2021 lb_total_2021 ph_total_2021 /// 
cc_total_2019 cj_total_2019 lb_total_2019 ph_total_2019 /// 
cc_total_2018 cj_total_2018 lb_total_2018 ph_total_2018 /// 
cc_total_2017 cj_total_2017 lb_total_2017 ph_total_2017 /// 
cc_total_2016 cj_total_2016 lb_total_2016 ph_total_2016 /// 
cc_total_2014 cj_total_2014 lb_total_2014 ph_total_2014 /// 
cc_total_2013 cj_total_2013 lb_total_2013 ph_total_2013 if tag==1


drop  aux_cc-tag


/*=================================================================================================================
					IX. Country Averages
=================================================================================================================*/

//cc_q6a_usd cc_q6a_gni 
foreach var of varlist cc_q1_norm- all_q105_norm {
	bysort country: egen CO_`var'=mean(`var')
}

egen tag = tag(country)
keep if tag==1
drop cc_q1- all_q105_norm //cc_q6a_usd cc_q6a_gni

rename CO_* *
drop tag
drop question id_alex language
sort country

drop WJP_login longitudinal year regular
drop total_score- total_score_mean

*order WJP_password cc_q6a_usd cc_q6a_gni, last
order WJP_password, last
drop WJP_password
save "$path2data\qrq_country_averages.dta", replace

br







