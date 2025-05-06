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


bysort country: egen total_score_mean=mean(total_score)
bysort country: egen total_score_sd=sd(total_score)

gen outlier=0
replace outlier=1 if total_score>=(total_score_mean+2.5*total_score_sd) & total_score!=.
replace outlier=1 if total_score<=(total_score_mean-2.5*total_score_sd) & total_score!=.

bysort country: egen outlier_CO=max(outlier)

*----- Shows the number of experts of low count countries have and if the country has outliers
tab country outlier_CO if N<=20

*----- Shows the number of outlies per each low count country
tab country outlier if N<=20


****** IQR 

bysort country: egen total_score_iqr=iqr(total_score)
bysort country: egen total_score_q1=pctile(total_score), p(25)
bysort country: egen total_score_q3=pctile(total_score), p(75)

gen outlier_iqr=0
replace outlier_iqr=1 if total_score>=(total_score_q3+1.5*total_score_iqr) & total_score!=.
replace outlier_iqr=1 if total_score<=(total_score_q1-1.5*total_score_iqr) & total_score!=.


/*=================================================================================================================
					For ROLI score
=================================================================================================================*/

bysort country: egen ROLI_mean=mean(ROLI)
bysort country: egen ROLI_sd=sd(ROLI)

g outlier_ROLI=0
replace outlier_ROLI=1 if ROLI>=(ROLI_mean+2.5*ROLI_sd) & ROLI!=.
replace outlier_ROLI=1 if ROLI<=(ROLI_mean-2.5*ROLI_sd) & ROLI!=.


****** IQR 

bysort country: egen ROLI_iqr=iqr(ROLI)
bysort country: egen ROLI_q1=pctile(ROLI), p(25)
bysort country: egen ROLI_q3=pctile(ROLI), p(75)

gen outlier_ROLI_iqr=0
replace outlier_ROLI_iqr=1 if ROLI>=(ROLI_q3+1.5*ROLI_iqr) & ROLI!=.
replace outlier_ROLI_iqr=1 if ROLI<=(ROLI_q1-1.5*ROLI_iqr) & ROLI!=.


****** Min-max values

bysort country question: egen total_score_rol_max=max(ROLI)
bysort country question: egen total_score_rol_min=min(ROLI)


