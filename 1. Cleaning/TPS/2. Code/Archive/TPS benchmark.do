/*=================================================================================================================
Project:		Global Rule of Law Index
Routine:		Index TPS BENCHMARK
Author(s):		Natalia Rodriguez 	(nrodriguez@worldjusticeproject.org)
Dependencies:  	World Justice Project
Creation Date:	June, 2024

Description:
This routine will create the rankings and benchmarks for the QRQ experts' iteration.
The dataset used is the clean version from the "TPS for checks" routine.

=================================================================================================================*/

clear all
set more off, perm
cls


/*=================================================================================================================
					Pre-settings
=================================================================================================================*/

*--- Required packages:
* NONE

*--- Defining paths to SharePoint & your local Git Repo copy:

*------ (a) Natalia Rodriguez:
if (inlist("`c(username)'", "nrodriguez")) {
	global path2SP "C:\Users\nrodriguez\OneDrive - World Justice Project\Programmatic\Data Analytics\7. WJP ROLI\ROLI_2024\1. Cleaning\TPS"
	global path2GH ""
}

*------ (b) Any other user: PLEASE INPUT YOUR PERSONAL PATH TO THE SHAREPOINT DIRECTORY:
else {
	global path2SP ""
	global path2GH ""
}

*--- Defining path to Data and DoFiles:

**Path2data: Path to data folder. 
global path2data "${path2SP}\1. Data"


**Path 2dos: Path to do-files (Routines). 
global path2dos  "${path2GH}\2. Code"

/*=================================================================================================================
					1. Importing the datasets
=================================================================================================================*/


use "${path2data}\2. Clean\TPS_current.dta", clear

global rol_tps "fh_rol_norm v2x_rule_norm bti_rol_norm wgi_rol_norm"
global f_1_tps "fh_functiongovt_norm bti_sep_norm v2exrescon_norm wgi_account_norm"
global f_1_2_tps "v2xlg_legcon_norm	v2lginvstp_norm"
global f_1_3_tps "v2x_jucon_norm v2jupoatck_norm"								
global f_1_4_tps "v2lgotovst_norm"
global f_1_5_tps "bti_abuse_norm v2juaccnt_norm"
global f_1_7_tps "bti_fairelection_norm	pei_norm fh_electoral_norm fh_pluralism_norm v2xel_frefair_norm	v2elffelr_norm"
global f_2_tps	"bti_anticorr_norm fh_corr_norm hf_corruption_norm v2x_corr_norm wgi_controlofcorruption_norm cpi_norm"					
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
global f_4_8_tps "ewf_coll_norm hf_laborfreedom_norm fh_unions"
*global f_5 "hfi_security_norm wgi_pol_norm"
global f_6_1_tps "wgi_reg_norm"
global f_6_5_tps "hf_prop_rights_norm ewf_prop_norm bti_privateprop_norm bti_propright_norm fh_property_norm"
global f_7_2_tps "ewf_impartialcourts_norm"
global f_7_3_tps "ewf_legal_norm"
global f_7_4_tps "bti_independentjud_norm ewf_jud_norm"
global f_7_6_tps "fh_judicial_norm hf_jud_norm ewf_contracts_norm"
global f_8_1_tps "ewf_police_norm"
global f_8_7_tps "fh_force_norm fh_due_process_norm"





















