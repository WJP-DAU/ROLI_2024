/*=================================================================================================================
Project:		Global ROLI QRQ cleaning and analysis
Routine:		Dropping extra TPS after tests
Author(s):		Natalia Rodriguez 	(nrodriguez@worldjusticeproject.org)
Dependencies:  	World Justice Project
Creation Date:	February, 2025

Description:
This routine will drop the extra vars included for the TPS analysis (rankings)

=================================================================================================================*/

*Dropping country scores and rankings (NO LONGER NEEDED) 
foreach v in f_1_2 f_1_3 f_1_4 f_1_5 f_1_6 f_1_7 f_2_1 f_2_2 f_2_3 f_2_4 f_3_1 f_3_2 f_3_3 f_3_4 f_4_1 f_4_2 f_4_3 f_4_4 f_4_5 f_4_6 f_4_7 f_4_8 f_5_3 f_6_1 f_6_2 f_6_3 f_6_4 f_6_5 f_7_1 f_7_2 f_7_3 f_7_4 f_7_5 f_7_6 f_7_7 f_8_1 f_8_2 f_8_3 f_8_4 f_8_5 f_8_6 f_8_7 f_1 f_2 f_3 f_4 f_6 f_7 f_8 ROLI {
	display as result "`v'"
		drop `v' `v'_r
}


*Dropping TPS analysis (NO LONGER NEEDED)
foreach v in f_1_2 f_1_3 f_1_4 f_1_5 f_1_6 f_1_7 f_2_1 f_2_2 f_2_3 f_2_4 f_3_1 f_3_2 f_3_3 f_3_4 f_4_1 f_4_2 f_4_3 f_4_4 f_4_5 f_4_6 f_4_7 f_4_8 f_5_3 f_6_1 f_6_2 f_6_3 f_6_4 f_6_5 f_7_1 f_7_2 f_7_3 f_7_4 f_7_5 f_7_6 f_7_7 f_8_1 f_8_2 f_8_3 f_8_4 f_8_5 f_8_6 f_8_7 f_1 f_2 f_3 f_4 f_6 f_7 f_8 ROLI {
	display as result "`v'"
	foreach x of global `v'_tps {
		display as error "`x'" 
		drop d_`v'_`x'
}
}

foreach v in f_1_2 f_1_3 f_1_4 f_1_5 f_1_6 f_1_7 f_2_1 f_2_2 f_2_3 f_2_4 f_3_1 f_3_2 f_3_3 f_3_4 f_4_1 f_4_2 f_4_3 f_4_4 f_4_5 f_4_6 f_4_7 f_4_8 f_5_3 f_6_1 f_6_2 f_6_3 f_6_4 f_6_5 f_7_1 f_7_2 f_7_3 f_7_4 f_7_5 f_7_6 f_7_7 f_8_1 f_8_2 f_8_3 f_8_4 f_8_5 f_8_6 f_8_7 f_1 f_2 f_3 f_4 f_6 f_7 f_8 ROLI {
	display as result "`v'"
	foreach x of global `v'_tps {
		display as error "`x'" 
		drop dn_`v'_`x'
		drop dp_`v'_`x'
}
}

foreach v in bti_dogmas bti_fairelection bti_assembly bti_expression bti_rol bti_sep bti_independentjud bti_abuse bti_civilrights bti_sociobarrier bti_privateprop bti_propright bti_equalopp bti_anticorr cpi ewf_jud ewf_courts ewf_prop ewf_military ewf_legal ewf_contracts ewf_police ewf_coll eiu_electoralprocess eiu_fun_gov eiu_civilliberties fh_electoral fh_elec_lgbt fh_pluralism fh_corr fh_open fh_functiongovt fh_fotp fh_relig fh_free_view fh_expression fh_assembly fh_unions fh_association fh_judicial fh_due_process fh_force fh_discrim fh_rol fh_property fh_autonomy fh_civilrights hf_prop_rights hf_corruption hf_jud hf_freedom hf_laborfreedom hfi_security open_budget_index pei pressfree v2x_freexp_altinf v2x_frassoc_thick v2xel_frefair v2xcl_rol v2x_jucon v2xlg_legcon v2x_cspart v2xeg_eqprotec v2elffelr v2exrescon v2exbribe v2exembez v2excrptps v2lginvstp v2lgotovst v2lgcrrpt v2jupoatck v2juaccnt v2clrelig v2mecenefm v2meharjrn v2caassemb v2xnp_regcorr v2x_corr v2x_pubcorr v2x_execorr v2x_rule wgi_account wgi_pol wgi_reg wgi_rol wgi_corr {
	display as result "`v'"
	drop `v'_norm `v'_norm_r
}


*Renaming INDIVIDUAL factor/sub-factor scores fot next step
foreach v in f_1_2_A f_1_2 f_1_3_A f_1_3 f_1_4 f_1_5_1_A f_1_5_1 f_1_5_2 f_1_5_3 f_1_5_4_A f_1_5_4 f_1_5 f_1_6_1_A f_1_6_1 f_1_6_2_A f_1_6_2 f_1_6_3_A f_1_6_3_B f_1_6_3 f_1_6 f_1_7_A f_1_7_B f_1_7 f_2_1_1_A f_2_1_1_B f_2_1_1 f_2_1_2_1_A f_2_1_2_1 f_2_1_2_2_A f_2_1_2_2 f_2_1_2_3 f_2_1_2 f_2_1_3 f_2_1 f_2_2_1 f_2_2_2 f_2_2 f_2_3_A f_2_3 f_2_4 f_3_1_1 f_3_1 f_3_2_2 f_3_2_3 f_3_2_4 f_3_2_5 f_3_2_6 f_3_2 f_3_3_1_A_1 f_3_3_1_A f_3_3_1_B_1 f_3_3_1_B f_3_3_1_C_1 f_3_3_1_C_2 f_3_3_1_C f_3_3_1 f_3_3_2_1 f_3_3_2 f_3_3_3 f_3_3 f_3_4 f_4_1_1_A f_4_1_1 f_4_1_2_A f_4_1_2 f_4_1_3_A f_4_1_3 f_4_1_4_A f_4_1_4 f_4_1_5_A f_4_1_5 f_4_1_6_A f_4_1_6 f_4_1 f_4_2 f_4_3_1 f_4_3_2_1 f_4_3_2 f_4_3_3 f_4_3_4 f_4_3_5 f_4_3 f_4_4_1_A f_4_4_1 f_4_4_2_A f_4_4_2 f_4_4_3_A f_4_4_3_B f_4_4_3_C f_4_4_3 f_4_4 f_4_5_A f_4_5_B f_4_5 f_4_6 f_4_7_A f_4_7 f_4_8_1_A f_4_8_1 f_4_8_2_A f_4_8_2 f_4_8_3 f_4_8 f_5_3 f_6_1_1_A f_6_1_1 f_6_1_2_A f_6_1_2 f_6_1_3 f_6_1 f_6_2_1_A f_6_2_1 f_6_2_2_1_A f_6_2_2_1 f_6_2_2_2_A f_6_2_2_2 f_6_2_2 f_6_2 f_6_3_A f_6_3 f_6_4 f_6_5_1 f_6_5_2 f_6_5 f_7_1_1 f_7_1_2 f_7_1_3 f_7_1_4 f_7_1_5_A f_7_1_5 f_7_1 f_7_2 f_7_3_1 f_7_3_2_A f_7_3_2 f_7_3 f_7_4_A f_7_4 f_7_5_1 f_7_5_2 f_7_5 f_7_6_1 f_7_6_2 f_7_6 f_7_7_1 f_7_7_3 f_7_7_4 f_7_7_5 f_7_7 f_8_1_1_A f_8_1_1_B f_8_1_1 f_8_1 f_8_2_1 f_8_2_2_A f_8_2_2 f_8_2 f_8_3 f_8_4_1_A f_8_4_1 f_8_4_2 f_8_4 f_8_5_1_A f_8_5_1 f_8_5_2_A f_8_5_2 f_8_5 f_8_6 f_8_7_1 f_8_7_2_A f_8_7_2 f_8_7_3 f_8_7_4 f_8_7_5 f_8_7 f_1 f_2 f_3 f_4 f_5 f_6 f_7 f_8 ROLI {
	rename `v'_obs `v'
}