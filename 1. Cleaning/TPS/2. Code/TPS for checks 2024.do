/*=================================================================================================================
Project:		Global Rule of Law Index
Routine:		Index TPS Checks
Author(s):		Natalia Rodriguez 	(nrodriguez@worldjusticeproject.org)
Dependencies:  	World Justice Project
Creation Date:	June, 2024

Description:
Do file that cleans and normalized the Index TPS for checks. 
This do file imports the original datasets from each source and cleans them.
Then, we export the excel file that summarizes the sources by theme.
Finally, the do-file calculates the changes over time for the TPS that have historical data.

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

*------ BTI

*2024
import excel "${path2data}\1. Original\BTI\BTI_2006-2024_Scores.xlsx", sheet("BTI 2024") firstrow
drop if Regions1EastCentralandSo==""

rename Regions1EastCentralandSo country
rename Q13Nointerferenceofreli bti_dogmas
rename Q21Freeandfairelections bti_fairelection 
rename Q23Associationassembly bti_assembly
rename Q24Freedomofexpression bti_expression 
rename Q3RuleofLaw bti_rol
rename Q31Separationofpowers bti_sep
rename Q32Independentjudiciary bti_independentjud
rename Q33Prosecutionofofficea bti_abuse
rename Q34Civilrights bti_civilrights
rename Q61Socioeconomicbarriers bti_sociobarrier
rename Q9PrivateProperty bti_privateprop
rename Q91Propertyrights bti_propright
rename Q102Equalopportunity bti_equalopp
rename Q153Anticorruptionpolicy bti_anticorr

replace country="Congo, Rep." if country=="Congo"
replace country="Congo, Dem. Rep." if country=="Congo, DR"
replace country="Cote d'Ivoire" if country=="Côte d'Ivoire"
replace country="Czechia" if country=="Czech Republic"
replace country="Egypt, Arab Rep." if country=="Egypt"
replace country="Finland" if country=="Finland "
replace country="Iran, Islamic Rep." if country=="Iran"
replace country="Korea, Rep." if country=="South Korea"
replace country="Kyrgyz Republic" if country=="Kyrgyzstan"
replace country="North Macedonia" if country=="Macedonia"
replace country="Russian Federation" if country=="Russia"
replace country="Slovak Republic" if country=="Slovakia"
replace country="Turkiye" if country=="Türkiye"
replace country="Venezuela, RB" if country=="Venezuela"

keep country bti*

gen year_bti=2024

save "${path2data}\2. Clean\BTI.dta", replace


*2022 - previous year for BTI

import excel "${path2data}\1. Original\BTI\BTI_2006-2024_Scores.xlsx", sheet("BTI 2022") firstrow clear
drop if Regions1EastCentralandSo==""

rename Regions1EastCentralandSo country
rename Q13Nointerferenceofreli bti_dogmas
rename Q21Freeandfairelections bti_fairelection 
rename Q23Associationassembly bti_assembly
rename Q24Freedomofexpression bti_expression 
rename Q3RuleofLaw bti_rol
rename Q31Separationofpowers bti_sep
rename Q32Independentjudiciary bti_independentjud
rename Q33Prosecutionofofficea bti_abuse
rename Q34Civilrights bti_civilrights
rename Q61Socioeconomicbarriers bti_sociobarrier
rename Q9PrivateProperty bti_privateprop
rename Q91Propertyrights bti_propright
rename Q102Equalopportunity bti_equalopp
rename Q153Anticorruptionpolicy bti_anticorr

replace country="Congo, Rep." if country=="Congo"
replace country="Congo, Dem. Rep." if country=="Congo, DR"
replace country="Cote d'Ivoire" if country=="Côte d'Ivoire"
replace country="Czechia" if country=="Czech Republic"
replace country="Egypt, Arab Rep." if country=="Egypt"
replace country="Finland" if country=="Finland "
replace country="Iran, Islamic Rep." if country=="Iran"
replace country="Korea, Rep." if country=="South Korea"
replace country="Kyrgyz Republic" if country=="Kyrgyzstan"
replace country="North Macedonia" if country=="Macedonia"
replace country="Russian Federation" if country=="Russia"
replace country="Slovak Republic" if country=="Slovakia"
replace country="Turkiye" if country=="Turkey"
replace country="Venezuela, RB" if country=="Venezuela"

keep country bti*

gen year_bti=2022

save "${path2data}\2. Clean\BTI_old.dta", replace


*------ CPI

import excel "${path2data}\1. Original\Corruption Perceptions Index\CPI2023_Global_Results__Trends.xlsx", sheet("CPI Timeseries 2012 - 2023") cellrange(A4:AT185) firstrow clear

rename CountryTerritory country
keep country CPIscore2023 CPIscore2022

replace country="Bahamas" if country=="Bahamas, The"
replace country="Congo, Rep." if country=="Congo"
replace country="Congo, Dem. Rep." if country=="Democratic Republic of the Congo"
replace country="Cote d'Ivoire" if country=="Ivory Coast (Cote d'Ivoire)"
replace country="Czechia" if country=="Czech Republic"
replace country="Egypt, Arab Rep." if country=="Egypt"
replace country="Finland" if country=="Finland "
replace country="Iran, Islamic Rep." if country=="Iran"
replace country="Korea, Rep." if country=="Korea, South"
replace country="Kyrgyz Republic" if country=="Kyrgyzstan"
replace country="North Macedonia" if country=="Macedonia"
replace country="Russian Federation" if country=="Russia"
replace country="St. Lucia" if country=="Saint Lucia"
replace country="St. Vincent and the Grenadines" if country=="Saint Vincent and the Grenadines"
replace country="Slovak Republic" if country=="Slovakia"
replace country="Turkiye" if country=="Turkey"
replace country="United States" if country=="United States of America"
replace country="Venezuela, RB" if country=="Venezuela"
replace country="Hong Kong SAR, China" if country=="Hong Kong"

rename CPIscore2023 cpi

preserve
keep country cpi
save "${path2data}\2. Clean\CPI", replace
restore

keep country CPIscore2022
rename CPIscore2022 cpi
save "${path2data}\2. Clean\CPI_old", replace


*------ Economic Freedom of the World

import excel "${path2data}\1. Original\Economic Freedom of the World\economic-freedom-of-the-world-2023-master-index-data-for-researchers-iso.xlsx", sheet("EFW Ratings 1970-2021") cellrange(B5:CL4654) firstrow clear

keep if Year>=2020
keep Countries Year AJudicialindependence BImpartialcourts CPropertyrights DMilitaryinterference ELegalintegrity FContracts HPoliceandcrime BiiiFlexiblewagedeterminati

rename Countries country
replace country="Bahamas" if country=="Bahamas, The"
replace country="Congo, Rep." if country=="Congo"
replace country="Congo, Dem. Rep." if country=="Democratic Republic of the Congo"
replace country="Cote d'Ivoire" if country=="Côte d'Ivoire"
replace country="Czechia" if country=="Czech Republic"
replace country="Egypt, Arab Rep." if country=="Egypt"
replace country="Finland" if country=="Finland "
replace country="Iran, Islamic Rep." if country=="Iran"
replace country="Korea, Rep." if country=="South Korea"
replace country="Kyrgyz Republic" if country=="Kyrgyzstan"
replace country="North Macedonia" if country=="Macedonia"
replace country="Russian Federation" if country=="Russia"
replace country="St. Lucia" if country=="Saint Lucia"
replace country="St. Vincent and the Grenadines" if country=="Saint Vincent and the Grenadines"
replace country="Slovak Republic" if country=="Slovakia"
replace country="Turkiye" if country=="Türkiye"
replace country="United States" if country=="United States of America"
replace country="Venezuela, RB" if country=="Venezuela"
replace country="Gambia" if country=="Gambia, The"

rename (AJudicialindependence BImpartialcourts CPropertyrights DMilitaryinterference ELegalintegrity FContracts HPoliceandcrime BiiiFlexiblewagedeterminati) ///
(ewf_jud ewf_courts ewf_prop ewf_military ewf_legal ewf_contracts ewf_police ewf_coll)

rename Year year_ef

preserve
keep if year_ef==2020
save "${path2data}\2. Clean\EF_old", replace
restore

keep if year_ef==2021
save "${path2data}\2. Clean\EF", replace


*------ EIU

import excel "${path2data}\1. Original\Economist Intelligence Unit Democracy Index\Democracy Index 2023 Table 2.xlsx", sheet("Sheet1") firstrow clear

drop OverallScore Rank ChangeFromPreviousYear IIIPoliticalParticipation IVPoliticalCulture
rename Country country

replace country="Bahamas" if country=="Bahamas, The"
replace country="Congo, Rep." if country=="Republic of Congo"
replace country="Congo, Dem. Rep." if country=="Democratic Republic of Congo"
replace country="Cote d'Ivoire" if country=="Côte d’Ivoire"
replace country="Czechia" if country=="Czech Republic"
replace country="Egypt, Arab Rep." if country=="Egypt"
replace country="Finland" if country=="Finland "
replace country="Hong Kong SAR, China" if country=="Hong Kong, SAR, China"
replace country="Iran, Islamic Rep." if country=="Iran"
replace country="Korea, Rep." if country=="South Korea"
replace country="Kyrgyz Republic" if country=="Kyrgyzstan"
replace country="North Macedonia" if country=="Macedonia"
replace country="Russian Federation" if country=="Russia"
replace country="St. Lucia" if country=="Saint Lucia"
replace country="St. Vincent and the Grenadines" if country=="Saint Vincent and the Grenadines"
replace country="Slovak Republic" if country=="Slovakia"
replace country="Turkiye" if country=="Turkey"
replace country="United States" if country=="United States of America"
replace country="Venezuela, RB" if country=="Venezuela"
replace country="United Kingdom" if country=="United Kindom"

rename (IElectoralprocessandpluralis IIFunctioningofGovernment VCivilLiberties) ///
(eiu_electoralprocess eiu_fun_gov eiu_civilliberties)

save "${path2data}\2. Clean\EIU", replace


*------ Fragile States Index
/*
import excel "Fragile States Index\FSI-2023-DOWNLOAD.xlsx", sheet("Sheet1") firstrow clear

keep Country C1SecurityApparatus P1StateLegitimacy P3HumanRights

rename Country country
replace country="Bahamas" if country=="Bahamas, The"
replace country="Congo, Rep." if country=="Congo Republic"
replace country="Congo, Dem. Rep." if country=="Congo Democratic Republic"
replace country="Cote d'Ivoire" if country=="Ivory Coast (Cote d'Ivoire)"
replace country="Czechia" if country=="Czech Republic"
replace country="Egypt, Arab Rep." if country=="Egypt"
replace country="Finland" if country=="Finland "
replace country="Iran, Islamic Rep." if country=="Iran"
replace country="Korea, Rep." if country=="South Korea"
replace country="Kyrgyz Republic" if country=="Kyrgyzstan"
replace country="North Macedonia" if country=="Macedonia"
replace country="Russian Federation" if country=="Russia"
replace country="St. Lucia" if country=="Saint Lucia"
replace country="St. Vincent and the Grenadines" if country=="Saint Vincent and the Grenadines"
replace country="Slovak Republic" if country=="Slovakia"
replace country="Turkiye" if country=="Turkey"
replace country="United States" if country=="United States of America"
replace country="Venezuela, RB" if country=="Venezuela"

rename (P1StateLegitimacy P3HumanRights C1SecurityApparatus) (fsi_open fsi_rol fsi_sec)

save "2023 TPS checks\FSI", replace
*/

*------ Freedom House

import excel "${path2data}\1. Original\Freedom House\All_data_FIW_2013-2024.xlsx", sheet("FIW13-24") cellrange(A2:AR2517) firstrow clear

keep if Edition>=2023
rename Edition year
drop Region CT Status AddQ AddA
drop A1 A2 A3 B1 B2 B3 C1 PR D3 E2 G1 G3 G4 PRrating CLrating Total

rename CountryTerritory country

replace country="Bahamas" if country=="Bahamas, The"
replace country="Congo, Rep." if country=="Congo (Brazzaville)"
replace country="Congo, Dem. Rep." if country=="Congo (Kinshasa)"
replace country="Cote d'Ivoire" if country=="Ivory Coast (Cote d'Ivoire)"
replace country="Czechia" if country=="Czech Republic"
replace country="Egypt, Arab Rep." if country=="Egypt"
replace country="Finland" if country=="Finland "
replace country="Hong Kong SAR, China" if country=="Hong Kong"
replace country="Iran, Islamic Rep." if country=="Iran"
replace country="Korea, Rep." if country=="South Korea"
replace country="Kyrgyz Republic" if country=="Kyrgyzstan"
replace country="North Macedonia" if country=="Macedonia"
replace country="Russian Federation" if country=="Russia"
replace country="St. Lucia" if country=="Saint Lucia"
replace country="St. Vincent and the Grenadines" if country=="Saint Vincent and the Grenadines"
replace country="Slovak Republic" if country=="Slovakia"
replace country="Turkiye" if country=="Turkey"
replace country="United States" if country=="United States of America"
replace country="Venezuela, RB" if country=="Venezuela"
replace country="Gambia" if country=="The Gambia"
					
rename (A B4 B) (fh_electoral fh_elec_lgbt fh_pluralism) 
rename (C2 C3 C ) (fh_corr fh_open fh_functiongovt)
rename (D1 D2 D4 D ) (fh_fotp fh_relig fh_free_view fh_expression)
rename (E1 E3 E) (fh_assembly fh_unions fh_association)
rename (F1 F2 F3 F4 F) (fh_judicial fh_due_process fh_force fh_discrim fh_rol)
rename (G2 G) (fh_property fh_autonomy)
rename CL fh_civilrights						

rename year year_fh

preserve
keep if year_fh==2023
save "${path2data}\2. Clean\FH_old", replace
restore

keep if year_fh==2024
save "${path2data}\2. Clean\FH", replace

/*
*------GPI

*Safety
import excel "Global Peace Index\GPI-2023-overall-scores-and-domains-2008-2023.xlsx", sheet("Safety and Security") cellrange(A4:Z167) firstrow clear
keep Country Q R

rename Q gpi_safety_2022
rename R gpi_safety_2023

rename Country country 
replace country="Bahamas" if country=="Bahamas, The"
replace country="Congo, Rep." if country=="Democratic Republic of the Congo"
replace country="Congo, Dem. Rep." if country=="Republic of the Congo"
replace country="Cote d'Ivoire" if country=="Cote d' Ivoire"
replace country="Czechia" if country=="Czech Republic"
replace country="Egypt, Arab Rep." if country=="Egypt"
replace country="Finland" if country=="Finland "
replace country="Gambia" if country=="The Gambia"
replace country="Hong Kong SAR, China" if country=="Hong Kong"
replace country="Iran, Islamic Rep." if country=="Iran"
replace country="Korea, Rep." if country=="South Korea"
replace country="Kyrgyz Republic" if country=="Kyrgyzstan"
replace country="Myanmar" if country=="Myanmar (Burma)"
replace country="North Macedonia" if country=="Macedonia"
replace country="Russian Federation" if country=="Russia"
replace country="St. Lucia" if country=="Saint Lucia"
replace country="St. Vincent and the Grenadines" if country=="Saint Vincent and the Grenadines"
replace country="Slovak Republic" if country=="Slovakia"
replace country="Turkiye" if country=="TÃ¼rkiye"
replace country="Tanzania" if country=="Tanzania, United Republic of"
replace country="United States" if country=="United States of America"
replace country="Venezuela, RB" if country=="Venezuela"
replace country="Moldova" if country=="Moldova, Republic of"
replace country="Bolivia" if country=="Bolivia, Plurinational State of"
replace country="Bosnia and Herzegovina" if country=="Bosnia-Herzegovina"
replace country="Morocco" if country=="Morocco / Western Sahara "

save "2023 TPS checks\GPI safety panel", replace

drop gpi_safety_2022

save "2023 TPS checks\GPI safety", replace

*Conflict
import excel "Global Peace Index\GPI-2023-overall-scores-and-domains-2008-2023.xlsx", sheet("Ongoing Conflict") cellrange(A4:Z167) firstrow clear
keep Country Q R

rename Q gpi_conflict_2022
rename R gpi_conflict_2023

rename Country country 
replace country="Bahamas" if country=="Bahamas, The"
replace country="Congo, Rep." if country=="Democratic Republic of the Congo"
replace country="Congo, Dem. Rep." if country=="Republic of the Congo"
replace country="Cote d'Ivoire" if country=="Cote d' Ivoire"
replace country="Czechia" if country=="Czech Republic"
replace country="Egypt, Arab Rep." if country=="Egypt"
replace country="Finland" if country=="Finland "
replace country="Gambia" if country=="The Gambia"
replace country="Hong Kong SAR, China" if country=="Hong Kong"
replace country="Iran, Islamic Rep." if country=="Iran"
replace country="Korea, Rep." if country=="South Korea"
replace country="Kyrgyz Republic" if country=="Kyrgyzstan"
replace country="Myanmar" if country=="Myanmar (Burma)"
replace country="North Macedonia" if country=="Macedonia"
replace country="Russian Federation" if country=="Russia"
replace country="St. Lucia" if country=="Saint Lucia"
replace country="St. Vincent and the Grenadines" if country=="Saint Vincent and the Grenadines"
replace country="Slovak Republic" if country=="Slovakia"
replace country="Turkiye" if country=="TÃ¼rkiye"
replace country="Tanzania" if country=="Tanzania, United Republic of"
replace country="United States" if country=="United States of America"
replace country="Venezuela, RB" if country=="Venezuela"
replace country="Moldova" if country=="Moldova, Republic of"
replace country="Bolivia" if country=="Bolivia, Plurinational State of"
replace country="Bosnia and Herzegovina" if country=="Bosnia-Herzegovina"
replace country="Morocco" if country=="Morocco / Western Sahara "

save "2023 TPS checks\GPI conflict panel", replace

drop gpi_conflict_2022

save "2023 TPS checks\GPI conflict", replace


*------ GTI
import excel "Global Peace Index\GTI-2023-Overall-scores-2011-2022.xlsx", sheet("Overall Scores") cellrange(A7:X170) firstrow clear
keep Country V X

rename V gpi_terrorism_2021
rename X gpi_terrorism_2022

rename Country country 
replace country="Bahamas" if country=="Bahamas, The"
replace country="Congo, Rep." if country=="Democratic Republic of the Congo"
replace country="Congo, Dem. Rep." if country=="Republic of the Congo"
replace country="Cote d'Ivoire" if country=="Cote d' Ivoire"
replace country="Czechia" if country=="Czech Republic"
replace country="Egypt, Arab Rep." if country=="Egypt"
replace country="Finland" if country=="Finland "
replace country="Gambia" if country=="The Gambia"
replace country="Hong Kong SAR, China" if country=="Hong Kong"
replace country="Iran, Islamic Rep." if country=="Iran"
replace country="Korea, Rep." if country=="South Korea"
replace country="Kyrgyz Republic" if country=="Kyrgyzstan"
replace country="Myanmar" if country=="Myanmar (Burma)"
replace country="North Macedonia" if country=="Macedonia"
replace country="Russian Federation" if country=="Russia"
replace country="St. Lucia" if country=="Saint Lucia"
replace country="St. Vincent and the Grenadines" if country=="Saint Vincent and the Grenadines"
replace country="Slovak Republic" if country=="Slovakia"
replace country="Turkiye" if country=="TÃ¼rkiye"
replace country="Tanzania" if country=="Tanzania, United Republic of"
replace country="United States" if country=="United States of America"
replace country="Venezuela, RB" if country=="Venezuela"
replace country="Moldova" if country=="Moldova, Republic of"
replace country="Bolivia" if country=="Bolivia, Plurinational State of"
replace country="Bosnia and Herzegovina" if country=="Bosnia-Herzegovina"
replace country="Morocco" if country=="Morocco / Western Sahara "

save "2023 TPS checks\GPI terrorism panel", replace

drop gpi_terrorism_2021

save "2023 TPS checks\GPI terrorism", replace
*/


*------ Heritage Foundation

import excel "${path2data}\1. Original\Heritage Foundation's Index of Economic Freedom\2024_indexofeconomicfreedom_data.xlsx", sheet("ef-country-scores") cellrange(A2:P186) firstrow clear

drop Region OverallScore TaxBurden GovernmentSpending FiscalHealth MonetaryFreedom TradeFreedom InvestmentFreedom FinancialFreedom 
rename Country country

replace country="Bahamas" if country=="The Bahamas"
replace country="Congo, Rep." if country=="Republic of Congo"
replace country="Congo, Dem. Rep." if country=="Democratic Republic of Congo"
replace country="Cote d'Ivoire" if country=="Côte d'Ivoire"
replace country="Czechia" if country=="Czech Republic"
replace country="Egypt, Arab Rep." if country=="Egypt"
replace country="Finland" if country=="Finland "
replace country="Gambia" if country=="The Gambia"
replace country="Hong Kong SAR, China" if country=="Hong Kong"
replace country="Iran, Islamic Rep." if country=="Iran"
replace country="Korea, Rep." if country=="South Korea"
replace country="Kyrgyz Republic" if country=="Kyrgyzstan"
replace country="Myanmar" if country=="Burma"
replace country="North Macedonia" if country=="Macedonia"
replace country="Philippines" if country=="The Philippines"
replace country="Russian Federation" if country=="Russia"
replace country="St. Lucia" if country=="Saint Lucia"
replace country="St. Vincent and the Grenadines" if country=="Saint Vincent and the Grenadines"
replace country="Slovak Republic" if country=="Slovakia"
replace country="Turkiye" if country=="Türkiye"
replace country="United States" if country=="United States of America"
replace country="Venezuela, RB" if country=="Venezuela"

rename (LaborFreedom PropertyRights JudicialEffectiveness GovernmentIntegrity BusinessFreedom) (hf_laborfreedom hf_prop_rights hf_jud hf_corruption hf_freedom)

foreach var of varlist hf_prop_rights hf_jud hf_corruption hf_freedom hf_laborfreedom {
replace `var'="" if `var'=="N/A"
replace `var'="" if `var'=="N/N"
destring `var', replace
}

save "${path2data}\2. Clean\HF", replace


*------ Human Freedom Index

import excel "${path2data}\1. Original\Human Freedom Index\human-freedom-index-2023-datafile.xlsx", sheet("Sheet1") firstrow clear

rename A year
rename C country
keep country year BSafetySecurity

keep if year>=2020

replace country="Bahamas" if country=="Bahamas, The"
replace country="Congo, Rep." if country=="Congo, Republic of"
replace country="Congo, Dem. Rep." if country=="Congo, Democratic Republic of the Congo"
replace country="Cote d'Ivoire" if country=="Côte d'Ivoire"
replace country="Czechia" if country=="Czech Republic"
replace country="Egypt, Arab Rep." if country=="Egypt"
replace country="Finland" if country=="Finland "
replace country="Gambia" if country=="Gambia, The"
replace country="Hong Kong SAR, China" if country=="Hong Kong"
replace country="Iran, Islamic Rep." if country=="Iran"
replace country="Korea, Rep." if country=="South Korea"
replace country="Kyrgyz Republic" if country=="Kyrgyzstan"
replace country="Myanmar" if country=="Burma"
replace country="North Macedonia" if country=="Macedonia"
replace country="Russian Federation" if country=="Russia"
replace country="St. Lucia" if country=="Saint Lucia"
replace country="St. Vincent and the Grenadines" if country=="Saint Vincent and the Grenadines"
replace country="Slovak Republic" if country=="Slovakia"
replace country="Turkiye" if country=="Turkey"
replace country="United States" if country=="United States of America"
replace country="Venezuela, RB" if country=="Venezuela"

rename (BSafetySecurity year) (hfi_security year_hfi)

preserve
keep if year_hfi==2020
save "${path2data}\2. Clean\HFI_old", replace
restore

keep if year_hfi==2021
save "${path2data}\2. Clean\HFI", replace


*------ Open Budget Index

import excel "${path2data}\1. Original\Open Budget Index\ibp_data_2023.xlsx", sheet("CountryCodes") firstrow clear

save "${path2data}\1. Original\Open Budget Index\names", replace

import excel "${path2data}\1. Original\Open Budget Index\ibp_data_2023.xlsx", sheet("Summary") firstrow clear
rename COUNTRY COUNTRY_CODE
merge 1:1 COUNTRY_CODE using "${path2data}\1. Original\Open Budget Index\names.dta"
drop if _merge==2
drop _merge RANK COUNTRY_CODE YEAR

rename COUNTRY_NAME country
replace country="Bahamas" if country=="Bahamas, The"
replace country="Congo, Rep." if country=="Congo, Republic of"
replace country="Congo, Dem. Rep." if country=="Congo, The Democratic Republic of the"
replace country="Cote d'Ivoire" if country=="Côte d'Ivoire"
replace country="Czechia" if country=="Czech Republic"
replace country="Egypt, Arab Rep." if country=="Egypt"
replace country="Finland" if country=="Finland "
replace country="Gambia" if country=="Gambia, The"
replace country="Hong Kong SAR, China" if country=="Hong Kong"
replace country="Iran, Islamic Rep." if country=="Iran"
replace country="Korea, Rep." if country=="Korea, Republic of"
replace country="Kyrgyz Republic" if country=="Kyrgyzstan"
replace country="Myanmar" if country=="Burma"
replace country="North Macedonia" if country=="Macedonia"
replace country="Russian Federation" if country=="Russia"
replace country="St. Lucia" if country=="Saint Lucia"
replace country="St. Vincent and the Grenadines" if country=="Saint Vincent and the Grenadines"
replace country="Slovak Republic" if country=="Slovakia"
replace country="Turkiye" if country=="Turkey"
replace country="Tanzania" if country=="Tanzania, United Republic of"
replace country="United States" if country=="US"
replace country="Venezuela, RB" if country=="Venezuela"
replace country="Moldova" if country=="Moldova, Republic of"
replace country="Bolivia" if country=="Bolivia, Plurinational State of"
replace country="Bosnia and Herzegovina" if country=="Bosnia-Herzegovina"

rename OPEN_BUDGET_INDEX open_budget_index

save "${path2data}\2. Clean\open_budget_index", replace


*------ PEI

use "${path2data}\1. Original\Perceptions of Electoral Integrity\PEI country-level data (PEI_9.0).dta"

keep country PEIIndexi 

replace country="Bahamas" if country=="Bahamas, The"
replace country="Congo, Rep." if country=="Congo,  Republic of"
replace country="Congo, Dem. Rep." if country=="Congo, The Democratic Republic of the"
replace country="Cote d'Ivoire" if country=="Côte D'Ivoire"
replace country="Czechia" if country=="Czech Republic"
replace country="Egypt, Arab Rep." if country=="Egypt"
replace country="Finland" if country=="Finland "
replace country="Gambia" if country=="Gambia, The"
replace country="Hong Kong SAR, China" if country=="Hong Kong"
replace country="Iran, Islamic Rep." if country=="Iran"
replace country="Korea, Rep." if country=="Korea"
replace country="Kyrgyz Republic" if country=="Kyrgyzstan"
replace country="Myanmar" if country=="Myanmar (Burma)"
replace country="North Macedonia" if country=="Macedonia"
replace country="Russian Federation" if country=="Russia"
replace country="St. Lucia" if country=="Saint Lucia"
replace country="St. Vincent and the Grenadines" if country=="Saint Vincent and the Grenadines"
replace country="Slovak Republic" if country=="Slovakia"
replace country="Turkiye" if country=="Turkey"
replace country="Tanzania" if country=="Tanzania, United Republic of"
replace country="United States" if country=="US"
replace country="Venezuela, RB" if country=="Venezuela"
replace country="Moldova" if country=="Moldova, Republic of"
replace country="Bolivia" if country=="Bolivia, Plurinational State of"
replace country="Bosnia and Herzegovina" if country=="Bosnia"
replace country="Ukraine" if country=="Urkaine"

rename PEIIndexi pei

save "${path2data}\2. Clean\PEI", replace


*------ PFI

import delimited "${path2data}\1. Original\Press Freedom Index\2024.csv", delimiter(";") clear 

keep score country_en
replace score=subinstr(score,",",".",.)
destring score, replace

rename country_en country

replace country="Bahamas" if country=="Bahamas, The"
replace country="Congo, Rep." if country=="Congo-Brazzaville"
replace country="Congo, Dem. Rep." if country=="DR Congo"
replace country="Cote d'Ivoire" if country=="CÃ´te d'Ivoire"
replace country="Czechia" if country=="Czech Republic"
replace country="Egypt, Arab Rep." if country=="Egypt"
replace country="Finland" if country=="Finland "
replace country="Gambia" if country=="Gambia, The"
replace country="Hong Kong SAR, China" if country=="Hong Kong"
replace country="Iran, Islamic Rep." if country=="Iran"
replace country="Korea, Rep." if country=="South Korea"
replace country="Kyrgyz Republic" if country=="Kyrgyzstan"
replace country="Myanmar" if country=="Myanmar (Burma)"
replace country="North Macedonia" if country=="Macedonia"
replace country="Russian Federation" if country=="Russia"
replace country="St. Lucia" if country=="Saint Lucia"
replace country="St. Vincent and the Grenadines" if country=="Saint Vincent and the Grenadines"
replace country="Slovak Republic" if country=="Slovakia"
replace country="Turkiye" if country=="TÃ¼rkiye"
replace country="Tanzania" if country=="Tanzania, United Republic of"
replace country="United States" if country=="US"
replace country="Venezuela, RB" if country=="Venezuela"
replace country="Moldova" if country=="Moldova, Republic of"
replace country="Bolivia" if country=="Bolivia, Plurinational State of"
replace country="Bosnia and Herzegovina" if country=="Bosnia-Herzegovina"
replace country="Morocco" if country=="Morocco / Western Sahara "

rename score pressfree

save "${path2data}\2. Clean\PFI", replace


*------ V-Dem

use "${path2data}\1. Original\V-Dem\V-Dem-CY-Full+Others-v14.dta", clear

keep if year>=2022

bys country_name year: egen date=max(historical_date)
gen double as= historical_date
keep if date==as

keep country_name year ///
v2jupoatck v2mecenefm v2meharjrn v2x_jucon v2xlg_legcon	v2exrescon v2x_rule ///
v2x_freexp_altinf v2x_frassoc_thick	v2xel_frefair v2xcl_rol	v2x_cspart v2xeg_eqprotec v2elffelr v2clrelig v2meharjrn v2caassemb ///
v2lginvstp	v2juaccnt ///
v2exbribe v2exembez v2excrptps v2lgcrrpt v2xnp_regcorr v2x_corr v2x_execorr v2x_pubcorr ///
v2x_freexp_altinf	v2x_frassoc_thick	v2xel_frefair	v2x_jucon	v2xlg_legcon	v2xeg_eqprotec	v2x_pubcorr	v2x_execorr	v2xcl_rol	v2x_rule v2lgotovst

rename country_name country
replace country="Bahamas" if country=="The Bahamas"
replace country="Congo, Rep." if country=="Republic of the Congo"
replace country="Congo, Dem. Rep." if country=="Democratic Republic of the Congo"
replace country="Cote d'Ivoire" if country=="Ivory Coast"
replace country="Czechia" if country=="Czech Republic"
replace country="Egypt, Arab Rep." if country=="Egypt"
replace country="Finland" if country=="Finland "
replace country="Gambia" if country=="The Gambia"
replace country="Hong Kong SAR, China" if country=="Hong Kong"
replace country="Iran, Islamic Rep." if country=="Iran"
replace country="Korea, Rep." if country=="South Korea"
replace country="Kyrgyz Republic" if country=="Kyrgyzstan"
replace country="Myanmar" if country=="Burma/Myanmar"
replace country="North Macedonia" if country=="Macedonia"
replace country="Russian Federation" if country=="Russia"
replace country="St. Lucia" if country=="Saint Lucia"
replace country="St. Vincent and the Grenadines" if country=="Saint Vincent and the Grenadines"
replace country="Slovak Republic" if country=="Slovakia"
replace country="Turkiye" if country=="Türkiye"
replace country="Tanzania" if country=="Tanzania, United Republic of"
replace country="United States" if country=="United States of America"
replace country="Venezuela, RB" if country=="Venezuela"
replace country="Moldova" if country=="Moldova, Republic of"
replace country="Bolivia" if country=="Bolivia, Plurinational State of"
replace country="Bosnia and Herzegovina" if country=="Bosnia-Herzegovina"
replace country="Morocco" if country=="Morocco / Western Sahara "

rename year year_vdem

preserve
keep if year_vdem==2022
save "${path2data}\2. Clean\vdem_old.dta", replace
restore

keep if year_vdem==2023
save "${path2data}\2. Clean\vdem.dta", replace


*------ World Governance Indicators

use "${path2data}\1. Original\World Governance Indicators\wgidataset.dta", clear

keep if year>=2021
keep countryname year *r
drop ger

rename countryname country
replace country="Bahamas" if country=="Bahamas, The"
replace country="Congo, Rep." if country=="Congo-Brazzaville"
replace country="Congo, Dem. Rep." if country=="DR Congo"
replace country="Cote d'Ivoire" if country=="Côte d'Ivoire"
replace country="Czechia" if country=="Czech Republic"
replace country="Egypt, Arab Rep." if country=="Egypt"
replace country="Finland" if country=="Finland "
replace country="Gambia" if country=="Gambia, The"
replace country="Hong Kong SAR, China" if country=="Hong Kong"
replace country="Iran, Islamic Rep." if country=="Iran"
replace country="Korea, Rep." if country=="South Korea"
replace country="Kyrgyz Republic" if country=="Kyrgyzstan"
replace country="Myanmar" if country=="Myanmar (Burma)"
replace country="North Macedonia" if country=="Macedonia"
replace country="Russian Federation" if country=="Russia"
replace country="St. Lucia" if country=="Saint Lucia"
replace country="St. Vincent and the Grenadines" if country=="Saint Vincent and the Grenadines"
replace country="Slovak Republic" if country=="Slovakia"
replace country="Turkiye" if country=="Türkiye"
replace country="Tanzania" if country=="Tanzania, United Republic of"
replace country="United States" if country=="US"
replace country="Venezuela, RB" if country=="Venezuela"
replace country="Moldova" if country=="Moldova, Republic of"
replace country="Bolivia" if country=="Bolivia, Plurinational State of"
replace country="Bosnia and Herzegovina" if country=="Bosnia-Herzegovina"
replace country="Morocco" if country=="Morocco / Western Sahara "

rename (var pvr rqr rlr ccr) (wgi_account wgi_pol wgi_reg wgi_rol wgi_corr)

rename year year_wgi

preserve
keep if year_wgi==2021
save "${path2data}\2. Clean\WGI_old", replace
restore

keep if year_wgi==2022

save "${path2data}\2. Clean\WGI", replace


/*=================================================================================================================
					**2. Merge datasets
=================================================================================================================*/

use "${path2data}\2. Clean\general_info.dta", clear

replace country="Bahamas" if country=="The Bahamas"
replace country="Gambia" if country=="The Gambia"
replace country="Cote d'Ivoire" if country=="Côte d'Ivoire"

*filelist, list

merge 1:1 country using "${path2data}\2. Clean\BTI.dta"
drop if _merge==2
drop _merge

merge 1:1 country using "${path2data}\2. Clean\CPI.dta"
drop if _merge==2
drop _merge

merge 1:1 country using "${path2data}\2. Clean\EF.dta"
drop if _merge==2
drop _merge


merge 1:1 country using "${path2data}\2. Clean\EIU.dta"
drop if _merge==2
drop _merge

merge 1:1 country using "${path2data}\2. Clean\FH.dta"
drop if _merge==2
drop _merge
/*
merge 1:1 country using "FSI.dta"
drop if _merge==2
drop _merge

merge 1:1 country using "GPI conflict.dta"
drop if _merge==2
drop _merge

merge 1:1 country using "GPI safety.dta"
drop if _merge==2
drop _merge

merge 1:1 country using "GPI terrorism.dta"
drop if _merge==2
drop _merge
*/
merge 1:1 country using "${path2data}\2. Clean\HF.dta"
drop if _merge==2
drop _merge

merge 1:1 country using "${path2data}\2. Clean\HFI.dta"
drop if _merge==2
drop _merge

merge 1:1 country using "${path2data}\2. Clean\open_budget_index.dta"
drop if _merge==2
drop _merge

merge 1:1 country using "${path2data}\2. Clean\PEI.dta"
drop if _merge==2
drop _merge

merge 1:1 country using "${path2data}\2. Clean\PFI.dta"
drop if _merge==2
drop _merge

merge 1:1 country using "${path2data}\2. Clean\vdem.dta"
drop if _merge==2
drop _merge

merge 1:1 country using "${path2data}\2. Clean\WGI.dta"
drop if _merge==2
drop _merge

drop year* Year wdi_code

br 


/*=================================================================================================================
					3. Rename and normalize
=================================================================================================================*/

*rename gpi_conflict_2023 gpi_conflict
*rename gpi_safety_2023 gpi_safety
*rename gpi_terrorism_2022 gpi_terrorism

*foreach var of varlist bti_dogmas bti_fairelection bti_assembly bti_expression bti_rol bti_sep bti_independentjud bti_abuse bti_civilrights bti_sociobarrier bti_privateprop bti_propright bti_equalopp bti_anticorr bti_civil cpi ewf_judicialindependence ewf_courts ewf_prop ewf_military ewf_legalsystemintegrity ewf_contracts ewf_police ewf_collectivebargaining eiu_electoralprocess eiu_fun_gov eiu_civilliberties fh_electoral fh_elec_lgbt fh_pluralism fh_corr fh_open fh_functiongovt fh_fotp fh_relig fh_free_view fh_expression fh_assembly fh_association fh_judicial fh_due_process fh_force fh_discrim fh_rol fh_property fh_autonomy fh_civilrights fsi_open fsi_rol fsi_sec gpi_conflict gpi_safety gpi_terrorism hf_prop_rights hf_jud hf_corruption hf_freedom hf_laborfreedom hfi_security open_budget_index pei pressfree v2x_freexp_altinf v2x_frassoc_thick v2xel_frefair v2xcl_rol v2x_jucon v2xlg_legcon v2x_cspart v2xeg_eqprotec v2elffelr v2exrescon v2exbribe v2exembez v2excrptps v2lginvstp v2lgotovst v2lgcrrpt v2jupoatck v2juaccnt v2clrelig v2mecenefm v2meharjrn v2caassemb v2xnp_regcorr v2x_corr v2x_execorr v2x_pubcorr v2x_rule wgi_account wgi_pol wgi_reg wgi_rol wgi_corr {


*------ Define global for TPS to be analyzed

global tps "bti_dogmas bti_fairelection bti_assembly bti_expression bti_rol bti_sep bti_independentjud bti_abuse bti_civilrights bti_sociobarrier bti_privateprop bti_propright bti_equalopp bti_anticorr cpi ewf_jud ewf_courts ewf_prop ewf_military ewf_legal ewf_contracts ewf_police ewf_coll eiu_electoralprocess eiu_fun_gov eiu_civilliberties fh_electoral fh_elec_lgbt fh_pluralism fh_corr fh_open fh_functiongovt fh_fotp fh_relig fh_free_view fh_expression fh_assembly fh_unions fh_association fh_judicial fh_due_process fh_force fh_discrim fh_rol fh_property fh_autonomy fh_civilrights hf_prop_rights hf_corruption hf_jud hf_freedom hf_laborfreedom hfi_security open_budget_index pei pressfree v2x_freexp_altinf v2x_frassoc_thick v2xel_frefair v2xcl_rol v2x_jucon v2xlg_legcon v2x_cspart v2xeg_eqprotec v2elffelr v2exrescon v2exbribe v2exembez v2excrptps v2lginvstp v2lgotovst v2lgcrrpt v2jupoatck v2juaccnt v2clrelig v2mecenefm v2meharjrn v2caassemb v2xnp_regcorr v2x_corr v2x_pubcorr v2x_execorr v2x_rule wgi_account wgi_pol wgi_reg wgi_rol wgi_corr"


*------ Normalize TPS

*List of all variables to be normalized
foreach var in $tps {
egen double `var'_max=max(`var')
egen double `var'_min=min(`var')
gen double `var'_norm=(`var'-`var'_min)/(`var'_max-`var'_min)
}

drop *_min *_max

*------ Check scale of NORM variables for anything greater than 1 or less than 0

sum *_norm

foreach var of varlist *_norm {
	list `var' if `var'>1 & `var'!=.
}

foreach var of varlist *_norm {
	list `var' if `var'<0 & `var'!=.
}

keep country *_norm


*------ Re-scaling normalized scores

*foreach var of varlist fsi_rol_norm v2x_pubcorr_norm v2x_corr_norm v2x_execorr_norm fsi_open_norm fsi_sec_norm gpi_safety_norm gpi_conflict_norm gpi_terrorism_norm {
foreach var of varlist v2x_pubcorr_norm v2x_corr_norm v2x_execorr_norm {
replace `var'=1-`var'
}

*replace country="The Bahamas" if country=="Bahamas"
*replace country="The Gambia" if country=="Gambia"

br

save "${path2data}\2. Clean\TPS_current.dta", replace


/*=================================================================================================================
					4. Rankings for BENCHMARK
=================================================================================================================*/

preserve

foreach v of varlist *_norm {
		display as error "`v'" 
		egen `v'_r=rank(`v'), field
}

save "${path2data}\2. Clean\TPS_benchmark.dta", replace
restore

/*=================================================================================================================
					5. Changes over time
=================================================================================================================*/

*------ Merge old datasets (previous year)

use "${path2data}\2. Clean\general_info.dta", clear

merge 1:1 country using "${path2data}\2. Clean\BTI_old.dta"
drop if _merge==2
drop _merge

merge 1:1 country using "${path2data}\2. Clean\CPI_old.dta"
drop if _merge==2
drop _merge

merge 1:1 country using "${path2data}\2. Clean\EF_old.dta"
drop if _merge==2
drop _merge

merge 1:1 country using "${path2data}\2. Clean\FH_old.dta"
drop if _merge==2
drop _merge

merge 1:1 country using "${path2data}\2. Clean\HFI_old.dta"
drop if _merge==2
drop _merge

merge 1:1 country using "${path2data}\2. Clean\vdem_old.dta"
drop if _merge==2
drop _merge

merge 1:1 country using "${path2data}\2. Clean\WGI_old.dta"
drop if _merge==2
drop _merge

drop year* wdi_code


*------ Define global for TPS to be analyzed over time (NOTE FOR NATALIA: IN AN IDEAL WORLD, TPS CURRENT AND CHANGES ARE THE SAME SOURCES)

global tps_changes "bti_dogmas bti_fairelection bti_assembly bti_expression bti_rol bti_sep bti_independentjud bti_abuse bti_civilrights bti_sociobarrier bti_privateprop bti_propright bti_equalopp bti_anticorr cpi ewf_jud ewf_courts ewf_prop ewf_military ewf_legal ewf_contracts ewf_police ewf_coll fh_electoral fh_elec_lgbt fh_pluralism fh_corr fh_open fh_functiongovt fh_fotp fh_relig fh_free_view fh_expression fh_assembly fh_unions fh_association fh_judicial fh_due_process fh_force fh_discrim fh_rol fh_property fh_autonomy fh_civilrights hfi_security v2x_freexp_altinf v2x_frassoc_thick v2xel_frefair v2xcl_rol v2x_jucon v2xlg_legcon v2x_cspart v2xeg_eqprotec v2elffelr v2exrescon v2exbribe v2exembez v2excrptps v2lginvstp v2lgotovst v2lgcrrpt v2jupoatck v2juaccnt v2clrelig v2mecenefm v2meharjrn v2caassemb v2xnp_regcorr v2x_corr v2x_pubcorr v2x_execorr v2x_rule wgi_account wgi_pol wgi_reg wgi_rol wgi_corr"

*------ Rename previous year as "old"
foreach v in $tps_changes {
rename `v' `v'_old
}

save "${path2data}\2. Clean\TPS_old.dta", replace


*------ Rename and normalize

foreach v in $tps_changes {
egen double `v'_old_max=max(`v'_old)
egen double `v'_old_min=min(`v'_old)
gen double `v'_old_norm=(`v'_old-`v'_old_min)/(`v'_old_max-`v'_old_min)
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

*gpi_safety* gpi_conflict* gpi_terrorism*
foreach var of varlist v2x_pubcorr* v2x_corr* v2x_execorr*  {
replace `var'=1-`var'
}


*------ Merge current TPS scores


merge 1:1 country using "${path2data}\2. Clean\TPS_current.dta"


*------ Calculate differences

foreach v in $tps_changes {
gen double d_`v'=(`v'_norm-`v'_old_norm)/(`v'_old_norm)
}

keep country d_*

rename d_* *_norm

save "${path2data}\2. Clean\TPS_changes_over_time.dta", replace



