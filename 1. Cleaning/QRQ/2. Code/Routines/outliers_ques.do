/*=================================================================================================================
Project:		Global ROLI QRQ cleaning and analysis
Routine:		Outliers routine
Author(s):		Natalia Rodriguez 	(nrodriguez@worldjusticeproject.org)
Dependencies:  	World Justice Project
Creation Date:	February, 2025

Description:
This routine will create the outlier flags within the dataset for the QRQ Global ROLI. 
This code will flag outlier by question.
=================================================================================================================*/

/*=================================================================================================================
					By question 
=================================================================================================================*/


foreach v in $norm {
	display as result "`v'"
	
	*Min-max values per question/country
	bysort country: egen `v'_max=max(`v')
	bysort country: egen `v'_min=min(`v')
	
	g outlier_hi_`v'=0
	replace outlier_hi_`v'=1 if `v'==`v'_max & `v'!=.
	
	g outlier_lo_`v'=0
	replace outlier_lo_`v'=1 if `v'==`v'_min & `v'!=.
	
	*Generating # of answers per question
	bys country: egen `v'_c=count(`v')
	
	*Counting # of outliers (max values) per question
	bys country: egen `v'_hi_t=total(outlier_hi_`v')
	
	*Counting # of outliers (low values) per question
	bys country: egen `v'_lo_t=total(outlier_lo_`v')
	
	*Creating proportions for all outliers
	bys country: gen `v'_hi_p=`v'_hi_t/`v'_c
	bys country: gen `v'_lo_p=`v'_lo_t/`v'_c
	
	*drop `v'_max `v'_min `v'_hi_t `v'_lo_t
}
