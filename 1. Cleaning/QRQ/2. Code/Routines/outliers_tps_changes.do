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


*Creating 10% highest and lowest experts
sort country total_score
by country: egen top_per_c=pctile(total_score), p(90)
gen top_c= 0
replace top_c = 1 if total_score >= top_per_c

sort country total_score
by country: egen low_per_c=pctile(total_score), p(10)
gen low_c= 0
replace low_c = 1 if total_score <= low_per_c 


* Total number of experts by country (for this exercise)
bysort country: gen N=_N

* Total number of experts by country and discipline (for this exercise)
bysort country question: gen N_questionnaire=_N

