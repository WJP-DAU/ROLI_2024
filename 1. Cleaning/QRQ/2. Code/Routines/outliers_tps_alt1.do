/*=================================================================================================================
Project:		Global ROLI QRQ cleaning and analysis
Routine:		TPS benchmark routine
Author(s):		Natalia Rodriguez 	(nrodriguez@worldjusticeproject.org)
Dependencies:  	World Justice Project
Creation Date:	February, 2025

Description:
This routine will create the analysis for the TPS as benchmarks for the QRQ ROLI data. 

=================================================================================================================*/

/*=================================================================================================================
					TPS analysis
=================================================================================================================*/

*** INTERMEDIATE

*Renaming factor/sub-factor scores at the individual level to run this step (will rename them back after)
foreach v in f_1_2_A f_1_2 f_1_3_A f_1_3 f_1_4 f_1_5_1_A f_1_5_1 f_1_5_2 f_1_5_3 f_1_5_4_A f_1_5_4 f_1_5 f_1_6_1_A f_1_6_1 f_1_6_2_A f_1_6_2 f_1_6_3_A f_1_6_3_B f_1_6_3 f_1_6 f_1_7_A f_1_7_B f_1_7 f_2_1_1_A f_2_1_1_B f_2_1_1 f_2_1_2_1_A f_2_1_2_1 f_2_1_2_2_A f_2_1_2_2 f_2_1_2_3 f_2_1_2 f_2_1_3 f_2_1 f_2_2_1 f_2_2_2 f_2_2 f_2_3_A f_2_3 f_2_4 f_3_1_1 f_3_1 f_3_2_2 f_3_2_3 f_3_2_4 f_3_2_5 f_3_2_6 f_3_2 f_3_3_1_A_1 f_3_3_1_A f_3_3_1_B_1 f_3_3_1_B f_3_3_1_C_1 f_3_3_1_C_2 f_3_3_1_C f_3_3_1 f_3_3_2_1 f_3_3_2 f_3_3_3 f_3_3 f_3_4 f_4_1_1_A f_4_1_1 f_4_1_2_A f_4_1_2 f_4_1_3_A f_4_1_3 f_4_1_4_A f_4_1_4 f_4_1_5_A f_4_1_5 f_4_1_6_A f_4_1_6 f_4_1 f_4_2 f_4_3_1 f_4_3_2_1 f_4_3_2 f_4_3_3 f_4_3_4 f_4_3_5 f_4_3 f_4_4_1_A f_4_4_1 f_4_4_2_A f_4_4_2 f_4_4_3_A f_4_4_3_B f_4_4_3_C f_4_4_3 f_4_4 f_4_5_A f_4_5_B f_4_5 f_4_6 f_4_7_A f_4_7 f_4_8_1_A f_4_8_1 f_4_8_2_A f_4_8_2 f_4_8_3 f_4_8 f_5_3 f_6_1_1_A f_6_1_1 f_6_1_2_A f_6_1_2 f_6_1_3 f_6_1 f_6_2_1_A f_6_2_1 f_6_2_2_1_A f_6_2_2_1 f_6_2_2_2_A f_6_2_2_2 f_6_2_2 f_6_2 f_6_3_A f_6_3 f_6_4 f_6_5_1 f_6_5_2 f_6_5 f_7_1_1 f_7_1_2 f_7_1_3 f_7_1_4 f_7_1_5_A f_7_1_5 f_7_1 f_7_2 f_7_3_1 f_7_3_2_A f_7_3_2 f_7_3 f_7_4_A f_7_4 f_7_5_1 f_7_5_2 f_7_5 f_7_6_1 f_7_6_2 f_7_6 f_7_7_1 f_7_7_3 f_7_7_4 f_7_7_5 f_7_7 f_8_1_1_A f_8_1_1_B f_8_1_1 f_8_1 f_8_2_1 f_8_2_2_A f_8_2_2 f_8_2 f_8_3 f_8_4_1_A f_8_4_1 f_8_4_2 f_8_4 f_8_5_1_A f_8_5_1 f_8_5_2_A f_8_5_2 f_8_5 f_8_6 f_8_7_1 f_8_7_2_A f_8_7_2 f_8_7_3 f_8_7_4 f_8_7_5 f_8_7 f_1 f_2 f_3 f_4 f_5 f_6 f_7 f_8 ROLI {
	rename `v' `v'_obs
}


*Merging rankings from SCENARIO 2 (starting point of this scenario) - ALL COUNTRIES SHOULD MATCH
merge m:1 country using "$path2data\2. Scenarios\Alternative\qrq_rankings_s2_p.dta"
drop _merge


*Merging dataset with scores and rankings for TPS. ALL COUNTRIES SHOULD MATCH
merge m:1 country using "${path2SP}\TPS\1. Data\2. Clean\TPS_benchmark.dta"
drop _merge


*Define globals for TPS
global ROLI_tps "fh_rol_norm v2x_rule_norm bti_rol_norm wgi_rol_norm"
global f_1_tps "fh_functiongovt_norm bti_sep_norm v2exrescon_norm wgi_account_norm"
global f_1_2_tps "v2xlg_legcon_norm	v2lginvstp_norm"
global f_1_3_tps "v2x_jucon_norm v2jupoatck_norm"								
global f_1_4_tps "v2lgotovst_norm"
global f_1_5_tps "bti_abuse_norm v2juaccnt_norm"
global f_1_7_tps "bti_fairelection_norm	pei_norm fh_electoral_norm fh_pluralism_norm v2xel_frefair_norm	v2elffelr_norm"
global f_2_tps	"bti_anticorr_norm fh_corr_norm hf_corruption_norm v2x_corr_norm wgi_corr_norm cpi_norm"					
global f_2_1_tps "v2x_execorr_norm v2exbribe_norm v2excrptps_norm v2exembez_norm v2xnp_regcorr_norm v2x_pubcorr_norm"
global f_2_4_tps "v2lgcrrpt_norm"
global f_3_tps "fh_open_norm"
global f_3_2_tps "open_budget_index_norm"
global f_3_3_tps "bti_expression_norm fh_expression_norm pressfree_norm fh_fotp_norm fh_relig_norm fh_free_view_norm v2x_freexp_altinf_norm v2clrelig_norm	v2x_cspart_norm	v2mecenefm_norm	v2meharjrn_norm"
global f_4_tps	"bti_civilrights_norm eiu_civilliberties_norm fh_civilrights_norm fh_autonomy_norm"
global f_4_1_tps "v2xcl_rol_norm bti_sociobarrier_norm bti_equalopp_norm v2xeg_eqprotec_norm fh_elec_lgbt_norm fh_discrim_norm"
global f_4_3_tps "fh_force_norm fh_due_process_norm"
global f_4_4_tps "v2x_freexp_altinf_norm bti_expression_norm fh_expression_norm pressfree_norm v2mecenefm_norm v2meharjrn_norm"
global f_4_5_tps "bti_dogmas_norm fh_expression_norm"
global f_4_7_tps "v2x_frassoc_thick_norm bti_assembly_norm fh_association_norm fh_assembly_norm	v2caassemb_norm"
global f_4_8_tps "ewf_coll_norm hf_laborfreedom_norm fh_unions_norm"
*global f_5 "hfi_security_norm wgi_pol_norm"
global f_6_1_tps "wgi_reg_norm"
global f_6_5_tps "hf_prop_rights_norm ewf_prop_norm bti_privateprop_norm bti_propright_norm fh_property_norm"
global f_7_2_tps "ewf_courts_norm"
global f_7_3_tps "ewf_legal_norm"
global f_7_4_tps "bti_independentjud_norm ewf_jud_norm"
global f_7_6_tps "fh_judicial_norm hf_jud_norm ewf_contracts_norm"
global f_8_1_tps "ewf_police_norm"
global f_8_7_tps "fh_force_norm fh_due_process_norm"


*Matching each TPS with their corresponding indicator
foreach v in f_1_2 f_1_3 f_1_4 f_1_5 f_1_6 f_1_7 f_2_1 f_2_2 f_2_3 f_2_4 f_3_1 f_3_2 f_3_3 f_3_4 f_4_1 f_4_2 f_4_3 f_4_4 f_4_5 f_4_6 f_4_7 f_4_8 f_5_3 f_6_1 f_6_2 f_6_3 f_6_4 f_6_5 f_7_1 f_7_2 f_7_3 f_7_4 f_7_5 f_7_6 f_7_7 f_8_1 f_8_2 f_8_3 f_8_4 f_8_5 f_8_6 f_8_7 f_1 f_2 f_3 f_4 f_6 f_7 f_8 ROLI {
	display as result "`v'"
	foreach x of global `v'_tps {
		display as error "`x'" 
		gen d_`v'_`x'= (`v'_r - `x'_r)
}
}

*Creating positive and negative dummies for differences in rankings of more than 30 positions
foreach v in f_1_2 f_1_3 f_1_4 f_1_5 f_1_6 f_1_7 f_2_1 f_2_2 f_2_3 f_2_4 f_3_1 f_3_2 f_3_3 f_3_4 f_4_1 f_4_2 f_4_3 f_4_4 f_4_5 f_4_6 f_4_7 f_4_8 f_5_3 f_6_1 f_6_2 f_6_3 f_6_4 f_6_5 f_7_1 f_7_2 f_7_3 f_7_4 f_7_5 f_7_6 f_7_7 f_8_1 f_8_2 f_8_3 f_8_4 f_8_5 f_8_6 f_8_7 f_1 f_2 f_3 f_4 f_6 f_7 f_8 ROLI {
	display as result "`v'"
	foreach x of global `v'_tps {
		display as error "`x'" 
		gen dn_`v'_`x'= (d_`v'_`x'>=15 & d_`v'_`x'!=.) //Differences are positive, ROLI is more negative
		gen dp_`v'_`x'= (d_`v'_`x'<=-15 & d_`v'_`x'!=.) //Differences are negative, ROLI is more positive
}
}

*Creating aggregate measure for # and % of sources with significant differences in rankings
egen positive_TPS_n=rowtotal(dp_*)
egen negative_TPS_n=rowtotal(dn_*)

*Creating number of total TPS per country - non missing observations 
egen tps_total=rownonmiss(d_*_norm)

*Creating % of positive and negative TPS above the thresholds
gen positive_TPS=positive_TPS_n/tps_total
gen negative_TPS=negative_TPS_n/tps_total


*Creating ranking for experts
bys country: egen rank_expert_p=rank(total_score), field
bys country: egen rank_expert_n=rank(total_score), track

*Creating 10% highest and lowest experts
sort country total_score
by country: egen top_per=pctile(total_score), p(90)
gen top= 0
replace top = 1 if total_score >= top_per

sort country total_score
by country: egen low_per=pctile(total_score), p(10)
gen low= 0
replace low = 1 if total_score <= low_per 


* Total number of experts by country (for this exercise)
bysort country: gen N=_N

* Total number of experts by country and discipline (for this exercise)
bysort country question: gen N_questionnaire=_N

