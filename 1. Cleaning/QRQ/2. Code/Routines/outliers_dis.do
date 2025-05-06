/*=================================================================================================================
Project:		Global ROLI QRQ cleaning and analysis
Routine:		Outliers routine
Author(s):		Natalia Rodriguez 	(nrodriguez@worldjusticeproject.org)
Dependencies:  	World Justice Project
Creation Date:	February, 2025

Description:
This routine will create the outlier flags within the dataset for the QRQ Global ROLI. 
This code will flag general outliers by discipline.
=================================================================================================================*/

/*=================================================================================================================
					By total score & discipline
=================================================================================================================*/

bysort country question: egen total_score_mean_qrq=mean(total_score)
bysort country question: egen total_score_sd_qrq=sd(total_score)

foreach x in cc cj lb ph {
	gen outlier_`x'_lo=0
	replace outlier_`x'_lo=1 if total_score<=(total_score_mean_qrq-2.5*total_score_sd_qrq) & total_score!=. & question=="`x'"
	
	gen outlier_`x'_hi=0
	replace outlier_`x'_hi=1 if total_score>=(total_score_mean_qrq+2.5*total_score_sd_qrq) & total_score!=. & question=="`x'"
}


****** IQR 

bysort country question: egen total_score_qrq_iqr=iqr(total_score)
bysort country question: egen total_score_qrq_q1=pctile(total_score), p(25)
bysort country question: egen total_score_qrq_q3=pctile(total_score), p(75)


foreach x in cc cj lb ph {
	gen outlier_iqr_`x'_lo=0
	replace outlier_iqr_`x'_lo=1 if total_score<=(total_score_qrq_q1-1.5*total_score_qrq_iqr) & total_score!=. & question=="`x'"
	
	gen outlier_iqr_`x'_hi=0
	replace outlier_iqr_`x'_hi=1 if total_score>=(total_score_qrq_q3+1.5*total_score_qrq_iqr) & total_score!=. & question=="`x'"
}

/*
gen outlier_qrq_hi=0
replace outlier_qrq_hi=1 if total_score>=(total_score_mean_qrq+2.5*total_score_sd_qrq) & total_score~=.

gen outlier_qrq_lo=0
replace outlier_qrq_lo=1 if total_score<=(total_score_mean_qrq-2.5*total_score_sd_qrq) & total_score~=.

gen outlier_qrq_iqr=0
replace outlier_qrq_iqr=1 if total_score>=(total_score_qrq_q3+1.5*total_score_qrq_iqr) & total_score~=.
replace outlier_qrq_iqr=1 if total_score<=(total_score_qrq_q1-1.5*total_score_qrq_iqr) & total_score~=.
*/

****** Min-max values

bysort country question: egen total_score_qrq_max=max(total_score)
bysort country question: egen total_score_qrq_min=min(total_score)
