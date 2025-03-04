/*=================================================================================================================
Project:		Global ROLI QRQ cleaning and analysis
Routine:		Normalization routine
Author(s):		Natalia Rodriguez 	(nrodriguez@worldjusticeproject.org)
Dependencies:  	World Justice Project
Creation Date:	February, 2025

Description:
This routine will create the outlier flags within the dataset for the QRQ Global ROLI.
=================================================================================================================*/

/*=================================================================================================================
					Outliers
=================================================================================================================*/

*                            *
*--     By total score     --*
*                            *

bysort country: egen total_score_mean=mean(total_score)
bysort country: egen total_score_sd=sd(total_score)

gen outlier=0
replace outlier=1 if total_score>=(total_score_mean+2.5*total_score_sd) & total_score~=.
replace outlier=1 if total_score<=(total_score_mean-2.5*total_score_sd) & total_score~=.

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
replace outlier_iqr=1 if total_score>=(total_score_q3+1.5*total_score_iqr) & total_score~=.
replace outlier_iqr=1 if total_score<=(total_score_q1-1.5*total_score_iqr) & total_score~=.


*                                 *
*-- By total score & discipline --*
*                                 *

bysort country question: egen total_score_mean_qrq=mean(total_score)
bysort country question: egen total_score_sd_qrq=sd(total_score)

gen outlier_qrq=0
replace outlier_qrq=1 if total_score>=(total_score_mean_qrq+2.5*total_score_sd_qrq) & total_score~=.
replace outlier_qrq=1 if total_score<=(total_score_mean_qrq-2.5*total_score_sd_qrq) & total_score~=.


****** IQR 

bysort country question: egen total_score_qrq_iqr=iqr(total_score)
bysort country question: egen total_score_qrq_q1=pctile(total_score), p(25)
bysort country question: egen total_score_qrq_q3=pctile(total_score), p(75)

gen outlier_qrq_iqr=0
replace outlier_qrq_iqr=1 if total_score>=(total_score_qrq_q3+1.5*total_score_qrq_iqr) & total_score~=.
replace outlier_qrq_iqr=1 if total_score<=(total_score_qrq_q1-1.5*total_score_qrq_iqr) & total_score~=.


*                            *
*--     For ROLI score     --*
*                            *

bysort country: egen ROLI_mean=mean(ROLI)
bysort country: egen ROLI_sd=sd(ROLI)

g outlier_ROLI=0
replace outlier_ROLI=1 if ROLI>=(ROLI_mean+2.5*ROLI_sd) & ROLI~=.
replace outlier_ROLI=1 if ROLI<=(ROLI_mean-2.5*ROLI_sd) & ROLI~=.


****** IQR 

bysort country: egen ROLI_iqr=iqr(ROLI)
bysort country: egen ROLI_q1=pctile(ROLI), p(25)
bysort country: egen ROLI_q3=pctile(ROLI), p(75)

gen outlier_ROLI_iqr=0
replace outlier_ROLI_iqr=1 if ROLI>=(ROLI_q3+1.5*ROLI_iqr) & ROLI~=.
replace outlier_ROLI_iqr=1 if ROLI<=(ROLI_q1-1.5*ROLI_iqr) & ROLI~=.


*                            *
*--     By factors/sub     --*
*                            *

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
	bysort country: egen `v'_mean=mean(`v') ;
	bysort country: egen `v'_sd=sd(`v') ;

	g outlier_`v'=0 ;
	replace outlier_`v'=1 if `v'>=(`v'_mean+2.5*`v'_sd) & `v'~=. ;
	replace outlier_`v'=1 if `v'<=(`v'_mean-2.5*`v'_sd) & `v'~=. ;
	
	drop `v'_mean `v'_sd ;
};
#delimit cr


****** IQR 

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
	bysort country: egen `v'_iqr=iqr(`v') ;
	bysort country: egen `v'_q1=pctile(`v'), p(25) ;
	bysort country: egen `v'_q3=pctile(`v'), p(75) ;

	g outlier_`v'_iqr=0 ;
	replace outlier_`v'_iqr=1 if `v'>=(`v'_q3+1.5*`v'_iqr) & `v'~=. ;
	replace outlier_`v'_iqr=1 if `v'<=(`v'_q1-1.5*`v'_iqr) & `v'~=. ;
	
	drop `v'_iqr `v'_q1 `v'_q3 ;
};
#delimit cr


*                            *
*--      By question       --*
*                            *

foreach v of varlist *_norm {
	bysort country: egen `v'_max=max(`v')
	bysort country: egen `v'_min=min(`v')
	
	g outlier_hi_`v'=0
	replace outlier_hi_`v'=1 if `v'==`v'_max & `v'!=.
	
	g outlier_lo_`v'=0
	replace outlier_lo_`v'=1 if `v'==`v'_min & `v'!=.
	
	drop `v'_max `v'_min
}







/* DOESN't WORK
foreach v of varlist *_norm {
	bysort country: egen `v'_mean=mean(`v')
	bysort country: egen `v'_sd=sd(`v')

	g outlier_`v'=0 
	replace outlier_`v'=1 if `v'>=(`v'_mean+2.5*`v'_sd) & `v'~=.
	replace outlier_`v'=1 if `v'<=(`v'_mean-2.5*`v'_sd) & `v'~=.
}
*/

****** IQR 
/*
foreach v of varlist *_norm {
bysort country: egen `v'_iqr=iqr(`v')
bysort country: egen `v'_q1=pctile(`v'), p(25)
bysort country: egen `v'_q3=pctile(`v'), p(75)

g outlier_`v'_iqr=0 
replace outlier_`v'_iqr=1 if `v'>=(`v'_q3+1.5*`v'_iqr) & `v'~=.
replace outlier_`v'_iqr=1 if `v'<=(`v'_q1-1.5*`v'_iqr) & `v'~=.
}
*/
