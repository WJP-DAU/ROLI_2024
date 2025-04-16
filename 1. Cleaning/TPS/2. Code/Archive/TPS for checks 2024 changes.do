/*=================================================================================================================
Project:		Global Rule of Law Index
Routine:		Index TPS Checks - Changes over time
Author(s):		Natalia Rodriguez 	(nrodriguez@worldjusticeproject.org)
Dependencies:  	World Justice Project
Creation Date:	June, 2024

Description:
Do file that cleans and normalized the Index TPS for checks. 
This do file imports the original datasets from each source and cleans them.
Then, we export the excel file that summarizes the sources by theme

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


/*



use "BTI", clear

foreach var of varlist bti_dogmas bti_fairelection bti_assembly bti_expression bti_rol bti_sep bti_independentjud bti_abuse bti_civilrights bti_sociobarrier bti_privateprop bti_propright bti_equalopp bti_anticorr {
rename `v' `v'_2024

}

save "
*/

/*=================================================================================================================
					1. Merging datasets
=================================================================================================================*/

**2. Merge datasets
use "countries.dta", clear

merge 1:1 country using "BTI old.dta"
drop if _merge==2
drop _merge

merge 1:1 country using "CPI old.dta"
drop if _merge==2
drop _merge

merge 1:1 country using "EF old.dta"
drop if _merge==2
drop _merge

merge 1:1 country using "FH old.dta"
drop if _merge==2
drop _merge

merge 1:1 country using "HFI old.dta"
drop if _merge==2
drop _merge

merge 1:1 country using "vdem old.dta"
drop if _merge==2
drop _merge

merge 1:1 country using "WGI old.dta"
drop if _merge==2
drop _merge

drop year* wdi_code

br
/*
foreach v of varlist bti_dogmas bti_fairelection bti_assembly bti_expression bti_rol bti_sep bti_independentjud bti_abuse bti_civilrights bti_sociobarrier bti_privateprop bti_propright bti_equalopp bti_anticorr cpi_2022 ewf_judicialindependence ewf_impartialcourts ewf_prop ewf_military ewf_legalsystemintegrity ewf_contracts ewf_police ewf_collectivebargaining fh_electoral fh_elec_lgbt fh_pluralism fh_corr fh_open fh_functiongovt fh_fotp fh_relig fh_free_view fh_expression fh_assembly fh_association fh_judicial fh_due_process fh_force fh_discrim fh_rol fh_property fh_autonomy fh_civilrights hfi_security v2x_freexp_altinf v2x_frassoc_thick v2xel_frefair v2xcl_rol v2x_jucon v2xlg_legcon v2x_cspart v2xeg_eqprotec v2elffelr v2exrescon v2exbribe v2exembez v2excrptps v2lginvstp v2lgotovst v2lgcrrpt v2jupoatck v2juaccnt v2clrelig v2mecenefm v2meharjrn v2caassemb v2xnp_regcorr v2x_corr v2x_pubcorr v2x_execorr v2x_rule wgi_account wgi_pol wgi_reg wgi_rol wgi_controlofcorruption {
rename `v' `v'_old
}
*/
save "TPS changes", replace



/*

**3. Rename and normalize

rename (ewf_judicialindependence2019 ewf_judicialindependence2020) (ewf_jud2019 ewf_jud2020)
rename (ewf_legalsystemintegrity2019 ewf_legalsystemintegrity2020) (ewf_legal2019 ewf_legal2020)
rename (ewf_collectivebargaining2019 ewf_collectivebargaining2020) (ewf_coll2019 ewf_coll2020)

foreach var of varlist bti_dogmas2020-wgi_controlofcorruption2021 {
egen double `var'_max=max(`var')
egen double `var'_min=min(`var')
gen double `var'_norm=(`var'-`var'_min)/(`var'_max-`var'_min)
}

drop *_min *_max

** Check scale of NORM variables for anything greater than 1 or less than 0

sum *_norm

foreach var of varlist *_norm {
	list `var' if `var'>1 & `var'!=.
}

foreach var of varlist *_norm {
	list `var' if `var'<0 & `var'!=.
}


keep country *_norm

foreach var of varlist v2x_pubcorr* v2x_corr* v2x_execorr* gpi_safety* gpi_conflict* gpi_terrorism* {
replace `var'=1-`var'
}

**4. Calculate differences

*BTI
local va "bti_dogmas bti_fairelection bti_assembly bti_expression bti_rol bti_sep bti_independentjud bti_abuse bti_civilrights bti_sociobarrier bti_privateprop bti_propright bti_equalopp bti_anticorr bti_civil"
foreach v in `va' {
gen d_`v'=(`v'2022_norm-`v'2020_norm)/`v'2020_norm
}


*EWF
local va "ewf_jud ewf_impartialcourts ewf_prop ewf_military ewf_legal ewf_contracts ewf_police ewf_coll"
foreach v in `va' {
gen d_`v'=(`v'2020_norm-`v'2019_norm)/`v'2019_norm
}


*FH
local va "fh_electoral fh_elec_lgbt fh_pluralism fh_corr fh_open fh_functiongovt fh_fotp fh_relig fh_free_view fh_expression fh_assembly fh_association fh_judicial fh_due_process fh_force fh_discrim fh_rol fh_property fh_autonomy fh_civilrights"
foreach v in `va' {
gen d_`v'=(`v'2023_norm-`v'2022_norm)/`v'2022_norm
}

*HFI
local va "hfi_security"
foreach v in `va' {
gen d_`v'=(`v'2020_norm-`v'2019_norm)/`v'2020_norm
}


*Vdem
local va "v2x_freexp_altinf v2x_frassoc_thick v2xel_frefair v2xcl_rol v2x_jucon v2xlg_legcon v2x_cspart v2xeg_eqprotec v2elffelr v2exrescon v2exbribe v2exembez v2excrptps v2lginvstp v2lgotovst v2lgcrrpt v2jupoatck v2juaccnt v2clrelig v2mecenefm v2meharjrn v2caassemb v2xnp_regcorr v2x_corr v2x_execorr v2x_pubcorr v2x_rule"
foreach v in `va' {
gen d_`v'=(`v'2022_norm-`v'2021_norm)/`v'2021_norm
}

*WDI
local va "wgi_account wgi_pol wgi_reg wgi_rol wgi_controlofcorruption"
foreach v in `va' {
gen d_`v'=(`v'2021_norm-`v'2020_norm)/`v'2020_norm
}

keep country d_*

renvars d_*, subst(d_ )

foreach var of varlist bti_dogmas bti_fairelection bti_assembly bti_expression bti_rol bti_sep bti_independentjud bti_abuse bti_civilrights bti_sociobarrier bti_privateprop bti_propright bti_equalopp bti_anticorr bti_civil ewf_jud ewf_impartialcourts ewf_prop ewf_military ewf_legal ewf_contracts ewf_police ewf_coll fh_electoral fh_elec_lgbt fh_pluralism fh_corr fh_open fh_functiongovt fh_fotp fh_relig fh_free_view fh_expression fh_assembly fh_association fh_judicial fh_due_process fh_force fh_discrim fh_rol fh_property fh_autonomy fh_civilrights hfi_security v2x_freexp_altinf v2x_frassoc_thick v2xel_frefair v2xcl_rol v2x_jucon v2xlg_legcon v2x_cspart v2xeg_eqprotec v2elffelr v2exrescon v2exbribe v2exembez v2excrptps v2lginvstp v2lgotovst v2lgcrrpt v2jupoatck v2juaccnt v2clrelig v2mecenefm v2meharjrn v2caassemb v2xnp_regcorr v2x_corr v2x_execorr v2x_pubcorr v2x_rule wgi_account wgi_pol wgi_reg wgi_rol wgi_controlofcorruption {
rename `var' `var'_norm
}













