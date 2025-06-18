/*=================================================================================================================
Project:		Global ROLI QRQ cleaning and analysis
Routine:		TPS CHANGES benchmark routine
Author(s):		Natalia Rodriguez 	(nrodriguez@worldjusticeproject.org)
Dependencies:  	World Justice Project
Creation Date:	February, 2025

Description:
This routine will create the analysis for the TPS CHANGES OVER TIME as benchmarks for the QRQ ROLI data. 

=================================================================================================================*/

/*=================================================================================================================
					TPS changes analysis
=================================================================================================================*/




*Merging dataset with changes over time for TPS. ALL COUNTRIES SHOULD MATCH
merge m:1 country using "${path2SP}\TPS\1. Data\2. Clean\TPS_changes_over_time.dta"
drop _merge


*Merging changes over time dataset. ALL COUNTRIES SHOULD MATCH
merge m:1 country using "$path2data\3. Final\qrq_change_2324.dta"
drop _merge

*Create aggregate direction for ROLI changes - ONLY FOR FACTORS (without F5)
foreach v in f_1 f_2 f_3 f_4 f_6 f_7 f_8 ROLI {
	display as result "`v'"
		gen dp_`v'_c= (change_`v'>0 & change_`v'!=.)
		label var dp_`v'_c "Positive dummy `v' change"
		
		gen dn_`v'_c= (change_`v'<0 & change_`v'!=.)
		label var dn_`v'_c "Negative dummy `v' change"
}


*Creating aggregate measure for # and % of factors with positive and negative changes
egen positive_WJP_n=rowtotal(dp_f_1_c dp_f_2_c dp_f_3_c dp_f_4_c dp_f_6_c dp_f_7_c dp_f_8_c dp_ROLI_c)
egen negative_WJP_n=rowtotal(dn_f_1_c dn_f_2_c dn_f_3_c dn_f_4_c dn_f_6_c dn_f_7_c dn_f_8_c dn_ROLI_c)

label var positive_WJP_n "Total non-missing positive change in factors"
label var negative_WJP_n "Total non-missing negative change in factors"

*Creating number of total factors per country - non missing observations 
egen WJP_total=rownonmiss(change_f_1 change_f_2 change_f_3 change_f_4 change_f_6 change_f_7 change_f_8 change_ROLI)
label var WJP_total "Total WJP factors per country"

*Creating % of positive and negative TPS above the thresholds
gen positive_WJP=positive_WJP_n/WJP_total
gen negative_WJP=negative_WJP_n/WJP_total

label var positive_WJP "% of positive factors"
label var negative_WJP "% of negative factors"

gen WJP_direction_change=""
replace WJP_direction_change="Positive" if positive_WJP>0.5
replace WJP_direction_change="Negative" if negative_WJP>0.5
replace WJP_direction_change="No change" if WJP_direction_change==""
label var WJP_direction_change "WJP direction change"


*Creating 10% highest and lowest experts
sort country total_score
by country: egen top_per_c=pctile(total_score), p(90)
label var top_per_c "Top decile score - change"
gen top_c= 0
replace top_c = 1 if total_score >= top_per_c
label var top_c "Top 10% experts - change"

sort country total_score
by country: egen low_per_c=pctile(total_score), p(10)
label var low_per_c "Bottom decile score - change"
gen low_c= 0
replace low_c = 1 if total_score <= low_per_c 
label var low_c "Bottom 10% experts - change"

* Total number of experts by country (for this exercise)
bysort country: gen N=_N
label var N "Total # of experts per country"

* Total number of experts by country and discipline (for this exercise)
bysort country question: gen N_questionnaire=_N
label var N_questionnaire "Total # of experts per discipline/country"

