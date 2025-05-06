/*=================================================================================================================
Project:		Global ROLI QRQ cleaning and analysis
Routine:		Outliers routine
Author(s):		Natalia Rodriguez 	(nrodriguez@worldjusticeproject.org)
Dependencies:  	World Justice Project
Creation Date:	February, 2025

Description:
This routine will create the outlier flags within the dataset for the QRQ Global ROLI. 
This code will flag outlier by factors/sub-factors.
=================================================================================================================*/

/*=================================================================================================================
					By factors/sub
=================================================================================================================*/

#delimit ;
foreach v in 
f_1_2 f_1_3 f_1_4 f_1_5 f_1_6 f_1_7 
f_2_1 f_2_2 f_2_3 f_2_4
f_3_1 f_3_2 f_3_3 f_3_4
f_4_1 f_4_2 f_4_3 f_4_4 f_4_5 f_4_6 f_4_7 f_4_8
f_5_3
f_6_1 f_6_2 f_6_3 f_6_4 f_6_5
f_7_1 f_7_2 f_7_3 f_7_4 f_7_5 f_7_6 f_7_7
f_8_1 f_8_2 f_8_3 f_8_4 f_8_5 f_8_6 f_8_7
f_1 f_2 f_3 f_4 f_5 f_6 f_7 f_8 
{;
	bysort country: egen `v'_mean=mean(`v') ;
	bysort country: egen `v'_sd=sd(`v') ;

	g outlier_`v'_hi=0 ;
	replace outlier_`v'_hi=1 if `v'>=(`v'_mean+2.5*`v'_sd) & `v'!=. ;
	
	g outlier_`v'_lo=0 ;
	replace outlier_`v'_lo=1 if `v'<=(`v'_mean-2.5*`v'_sd) & `v'!=. ;
	
	*Min-max values for factor-sub-factor
	bysort country: egen `v'_max=max(`v') ;
	bysort country: egen `v'_min=min(`v') ;
	
	* Min-max values (Includes questionnaire too)
	bysort country question: egen `v'_qrq_max=max(`v') ;
	bysort country question: egen `v'_qrq_min=min(`v') ;
	
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
f_7_1 f_7_2 f_7_3 f_7_4 f_7_5 f_7_6 f_7_7
f_8_1 f_8_2 f_8_3 f_8_4 f_8_5 f_8_6 f_8_7
f_1 f_2 f_3 f_4 f_5 f_6 f_7 f_8 
{;
	bysort country: egen `v'_iqr=iqr(`v') ;
	bysort country: egen `v'_q1=pctile(`v'), p(25) ;
	bysort country: egen `v'_q3=pctile(`v'), p(75) ;

	g outlier_`v'_iqr_hi=0 ;
	replace outlier_`v'_iqr_hi=1 if `v'>=(`v'_q3+1.5*`v'_iqr) & `v'!=. ;
	
	g outlier_`v'_iqr_lo=0 ;
	replace outlier_`v'_iqr_lo=1 if `v'<=(`v'_q1-1.5*`v'_iqr) & `v'!=. ;
	
	drop `v'_iqr `v'_q1 `v'_q3 ;
};
#delimit cr



