/*=================================================================================================================
Project:		Global ROLI QRQ cleaning and analysis
Routine:		Checks
Author(s):		Natalia Rodriguez 	(nrodriguez@worldjusticeproject.org)
Dependencies:  	World Justice Project
Creation Date:	May, 2025

Description:
This routine will create the automatic checks for the QRQ Global ROLI data.

=================================================================================================================*/

/*=================================================================================================================
					                1. Empty surveys
=================================================================================================================*/

*Create total_score (temperature indicator for each expert)
egen total_score=rowmean(cc_q1_norm- ph_q14_norm)

*Drop empty surveys
drop if total_score==.

/*=================================================================================================================
					                 2. Duplicates
=================================================================================================================*/

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

/*=================================================================================================================
					          3. Drop questionnaires with very few observations
=================================================================================================================*/

*----- Generating the number of non-missing observations per expert
egen total_n=rownonmiss(cc_q1_norm- ph_q14_norm)

*----- Total number of experts by country
bysort country: gen N=_N

*----- Total number of experts by country and discipline
bysort country question: gen N_questionnaire=_N

*Number of questions per QRQ
*CC: 162
*CJ: 197
*LB: 134
*PH: 49

*----- Drop surveys with less than 25 nonmissing values. Erin cleaned empty suveys and surveys with low responses. There are countries with low total_n because we removed the DN/NA at the beginning of the do file
tab country if total_n<=25
drop if total_n<=25 & N>=20

*----- Dropping variables no longer needed
drop N N_questionnaire

/*=================================================================================================================
					                 4. Dropping the tail / old experts
=================================================================================================================*/

sort country question year total_score

*----- Counting the number of experts per discipline
foreach x in cc cj lb ph {
gen count_`x'=1 if question=="`x'"
}

*----- Creating total counts by country per discipline
foreach x in cc cj lb ph {
bys country: egen `x'_total=total(count_`x')
}

*----- Counting the number of experts per discipline and year (if they are in the tail)
foreach x in cc cj lb ph {
gen tail_`x'=1 if count_`x'==1 & year<2022
}

foreach x in cc cj lb ph {
bys country: egen `x'_total_tail=total(tail_`x')
}

*----- Counting the number of NEW experts (2022-2024)
foreach x in cc cj lb ph {
gen new_`x'=1 if count_`x'==1 & year>=2022
}

foreach x in cc cj lb ph {
bys country: egen `x'_total_new=total(new_`x')
}

*----- Creating percentages for the tail
foreach x in cc cj lb ph {
gen percentage_tail_`x'=`x'_total_tail/`x'_total
}


*----- Drop the tail per discipline (% of the tail is small (less or equal than 50%))
tab country if cc_total_new>=15
tab country if cj_total_new>=15
tab country if lb_total_new>=15
tab country if ph_total_new>=15

drop if tail_cc==1 & cc_total_new>=15
drop if tail_cj==1 & cj_total_new>=15
drop if tail_lb==1 & lb_total_new>=15
drop if tail_ph==1 & ph_total_new>=15

*----- Dropping variables no longer needed
*drop count_cc count_cj count_lb count_ph cc_total cj_total lb_total ph_total tail_cc tail_cj tail_lb tail_ph cc_total_tail cj_total_tail lb_total_tail ph_total_tail new_cc new_cj new_lb new_ph cc_total_new cj_total_new lb_total_new ph_total_new percentage_tail_cc percentage_tail_cj percentage_tail_lb percentage_tail_ph

/*=================================================================================================================
					                 5. Outliers
=================================================================================================================*/

*----- Total number of experts by country
bysort country: gen N=_N

*----- Total number of experts by country and discipline
bysort country question: gen N_questionnaire=_N

*----- Average score and standard deviation (for outliers)
bysort country: egen total_score_mean=mean(total_score)
bysort country: egen total_score_sd=sd(total_score)

*----- Generating outlier variable
gen outlier=0
replace outlier=1 if total_score>=(total_score_mean+2.5*total_score_sd) & total_score!=.
replace outlier=1 if total_score<=(total_score_mean-2.5*total_score_sd) & total_score!=.

bysort country: egen outlier_CO=max(outlier)

*----- Shows the number of experts of low count countries have and if the country has outliers
tab country outlier_CO if N<=20

*----- Shows the number of outlies per each low count country
tab country outlier if N<=20

*----- Dropping general outliers
drop if outlier==1 & N>20 & N_questionnaire>5


*----- Dropping variables no longer needed
drop N N_questionnaire total_score_mean total_score_sd outlier outlier_CO
