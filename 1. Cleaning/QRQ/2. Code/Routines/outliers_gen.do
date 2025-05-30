/*=================================================================================================================
Project:		Global ROLI QRQ cleaning and analysis
Routine:		Outliers routine
Author(s):		Natalia Rodriguez 	(nrodriguez@worldjusticeproject.org)
Dependencies:  	World Justice Project
Creation Date:	February, 2025

Description:
This routine will create the outlier flags within the dataset for the QRQ Global ROLI. 
This code will flag general outliers by total score and ROLI.
=================================================================================================================*/

/*=================================================================================================================
					By total score
=================================================================================================================*/

*----- Total number of experts by country
bysort country: gen N=_N

*----- Total number of experts by country and discipline
bysort country question: gen N_questionnaire=_N

*----- Average score and standard deviation (for outliers)
bysort country: egen total_score_mean=mean(total_score)
bysort country: egen total_score_sd=sd(total_score)

*----- Generating outlier variables
gen outlier_hi=0
replace outlier_hi=1 if total_score>=(total_score_mean+2.5*total_score_sd) & total_score!=. 

gen outlier_lo=0
replace outlier_lo=1 if total_score<=(total_score_mean-2.5*total_score_sd) & total_score!=.






/*



bysort country: egen outlier_CO=max(outlier)

*----- Shows the number of experts of low count countries have and if the country has outliers
tab country outlier_CO if N<=20

*----- Shows the number of outlies per each low count country
tab country outlier if N<=20

*----- Dropping general outliers
drop if outlier==1 & N>20 & N_questionnaire>5

*----- Dropping variables
drop N N_questionnaire total_score_mean total_score_sd outlier outlier_CO
