/*=================================================================================================================
Project:		Global Index
Routine:		GPP Index Scores
Author(s):		Natalia Rodriguez 	(nrodriguez@worldjusticeproject.org)
Dependencies:  	World Justice Project
Creation Date:	May, 2024

Description:
Master dofile that produces the GPP scores for the Index.

=================================================================================================================*/

clear all
set more off, perm
cls


/*=================================================================================================================
					Pre-settings
=================================================================================================================*/

*--- Stata Version
version 15

*--- Required packages:
* NONE

*--- Defining paths to SharePoint & your local Git Repo copy:

*------ (a) Natalia Rodriguez:
if (inlist("`c(username)'", "nrodriguez")) {
	global path2SP "C:\Users\nrodriguez\OneDrive - World Justice Project\Programmatic"
	global path2GH "C:\Users\nrodriguez\OneDrive - World Justice Project\Natalia\GitHub"
}

*------ (b) Alex Ponce:
else if (inlist("`c(username)'", "poncea")) {
	global path2SP ""
}

*Path2data: Path to merged dataset with ALL GPPs
global path2data "${path2SP}\General Population Poll\GPP 2024\Merged Files\Historical Files\"


/**--- Defining path to Data and DoFiles:

**Path2data: Path to master GPP dataset
For Natalia: GPP folder (Sharepoint)
*/



/*=================================================================================================================
					1. Data import and year's selection
=================================================================================================================*/


*------ We use the historical database that has all the countries and years
use "$path2data\Merged.dta", replace

*------ Create a variable that marks the most recent database for each country
gen updated=1 if year>=2017

*------ Remove older data from countries that were polled in 2019
replace updated=. if country_year=="Afghanistan_2017"
replace updated=. if country_year=="Afghanistan_2018"
replace updated=. if country_year=="Pakistan_2017"

*------ Remove older data from countries that were polled in 2021

replace updated=. if country_year=="United States_2018"

*------Save most recent file by country 
replace updated=. if country_year=="United States_2017"
replace updated=. if country_year=="United Kingdom_2017"
replace updated=1 if country_year=="Cambodia_2014"
replace updated=1 if country_year=="United Arab Emirates_2011"
replace updated=1 if country_year=="Belarus_2014"

**------EXT GPP
replace updated=. if country_year=="Belize_2017"
replace updated=. if country_year=="Belize_2019"
replace updated=1 if country_year=="Belize_2021"
replace updated=. if country_year=="Belize_2022"
replace updated=1 if country_year=="El Salvador_2018"
replace updated=. if country_year=="El Salvador_2021"
replace updated=. if country_year=="El Salvador_2022"
replace updated=. if country_year=="Guatemala_2018"
replace updated=1 if country_year=="Guatemala_2021"
replace updated=. if country_year=="Guatemala_2022"
replace updated=. if country_year=="Honduras_2017"
replace updated=. if country_year=="Honduras_2019"
replace updated=1 if country_year=="Honduras_2021"
replace updated=. if country_year=="Honduras_2022"
replace updated=. if country_year=="Nicaragua_2017"
replace updated=1 if country_year=="Nicaragua_2019"
replace updated=. if country_year=="Nicaragua_2021"
replace updated=. if country_year=="Panama_2017"
replace updated=. if country_year=="Panama_2019"
replace updated=1 if country_year=="Panama_2021"
replace updated=. if country_year=="Panama_2022"

*------ Remove older data from countries that were polled in 2022
replace updated=1 if country_year=="Antigua and Barbuda_2018"
replace updated=. if country_year=="Argentina_2018"
replace updated=. if country_year=="Bahamas_2018"
replace updated=1 if country_year=="Barbados_2018"
replace updated=. if country_year=="Bolivia_2018"
replace updated=. if country_year=="Brazil_2017"
replace updated=. if country_year=="Costa Rica_2017"
replace updated=. if country_year=="Costa Rica_2019"
replace updated=. if country_year=="Colombia_2018"
replace updated=. if country_year=="Dominica_2018"
replace updated=. if country_year=="Dominican Republic_2018"
replace updated=. if country_year=="Ecuador_2017"
replace updated=. if country_year=="Grenada_2018"
replace updated=1 if country_year=="Guyana_2018"
replace updated=. if country_year=="Haiti_2021"
replace updated=. if country_year=="Jamaica_2017"
replace updated=. if country_year=="Jamaica_2019"
replace updated=. if country_year=="Peru_2018" 
replace updated=1 if country_year=="St. Kitts and Nevis_2018"
replace updated=. if country_year=="St. Kitts and Nevis_2022"
replace updated=. if country_year=="St. Lucia_2018"
replace updated=1 if country_year=="St. Vincent and the Grenadines_2018"
replace updated=. if country_year=="Suriname_2018"
replace updated=. if country_year=="Trinidad and Tobago_2018"
replace updated=1 if country_year=="Venezuela, RB_2016"
replace updated=1 if country_year=="Venezuela, RB_2018"
replace updated=. if country_year=="Venezuela, RB_2022"

*------ Remove older data from countries that were polled in 2023
replace updated=. if country_year=="North Macedonia_2017"

*------ From 2019 GPP Index - Problematic countries from 2017 and 2018

replace updated=. if country_year=="Uzbekistan_2014"
replace updated=. if country_year=="Uzbekistan_2018"

replace updated=1 if country_year=="Philippines_2016"
replace updated=. if country_year=="Philippines_2018"

replace updated=1 if country_year=="Bangladesh_2016"
replace updated=. if country_year=="Bangladesh_2018"

replace updated=1 if country_year=="Russian Federation_2016"

*------ Remove older data from countries that were polled in 2024 - EU
replace updated=. if country_year=="Austria_2017"
replace updated=. if country_year=="Belgium_2018"
replace updated=. if country_year=="Bulgaria_2018"
replace updated=. if country_year=="Croatia_2018"
replace updated=. if country_year=="Cyprus_2021"
replace updated=. if country_year=="Czechia_2017"
replace updated=. if country_year=="Denmark_2017"
replace updated=. if country_year=="Estonia_2017"
replace updated=. if country_year=="Finland_2017"
replace updated=. if country_year=="France_2018"
replace updated=. if country_year=="Germany_2018"
replace updated=. if country_year=="Greece_2017"
replace updated=. if country_year=="Hungary_2017"
replace updated=. if country_year=="Ireland_2021"
replace updated=. if country_year=="Italy_2017"
replace updated=. if country_year=="Latvia_2021"
replace updated=. if country_year=="Lithuania_2021"
replace updated=. if country_year=="Luxembourg_2021"
replace updated=. if country_year=="Malta_2021"
replace updated=. if country_year=="Netherlands_2018"
replace updated=. if country_year=="Poland_2018"
replace updated=. if country_year=="Portugal_2017"
replace updated=. if country_year=="Romania_2018"
replace updated=. if country_year=="Slovak Republic_2021"
replace updated=. if country_year=="Slovenia_2017"
replace updated=. if country_year=="Spain_2018"
replace updated=. if country_year=="Sweden_2018"

*------ Remove US 2024 from Index
replace updated=. if country_year=="United States_2024"


/*=================================================================================================================
					2. Problematic Countries
=================================================================================================================*/


//READ: These are countries from 2017. Before, we removed the datasets for this countries and added the average scores. This part will replicate the scores.

*------ Belarus: 2014 and 2017
replace updated=1 if country_year=="Belarus_2014"
replace updated=. if country_year=="Belarus_2012"

foreach var of varlist q1a_norm- qpi2f_norm  {
	replace `var'=round(`var', .001) if country_year=="Belarus_2014"
}

append using "$path2data\Problematic countries\Belarus_2017_index.dta"
replace updated=1 if country_year=="Belarus_2017"

/*
sum q43_G2_norm	q44_G1_norm	q44_G2_norm	q45a_G1_norm q45a_G2_norm q45b_G1_norm q45b_G2_norm	q45d_G1_norm q45c_G2_norm q45e_G1_norm q45d_G2_norm	q45e_G2_norm ///
q2a_norm q2b_norm q2c_norm q2d_norm	q2g_norm q18a_norm q18b_norm q18c_norm q18d_norm q18e_norm q18f_norm q6a_norm q6b_norm q6c_norm	q7a_norm q7b_norm q7c_norm ///
q4a_norm q4e_norm q9_norm q48c_G1_norm q48d_G1_norm	q46a_G2_norm q46b_G1_norm q46b_G2_norm q46c_G1_norm	q46c_G2_norm q46d_G2_norm q46e_G2_norm q46d_G1_norm	///
q46f_G2_norm q46e_G1_norm q46g_G2_norm q46f_G1_norm	q46h_G2_norm q46g_G1_norm q46h_G1_norm q43_G1_norm ///
if country_year=="Belarus_2014" | country_year=="Belarus_2017"
*/ 


*------ Egypt: 2017
replace updated=1 if country_year=="Egypt, Arab Rep._2017"
replace updated=. if country_year=="Egypt, Arab Rep._2012"
replace updated=. if country_year=="Egypt, Arab Rep._2014"

*To make the scores exactly the same as the ones in the file of problematic scores we have to round the values
foreach var of varlist q1a_norm- qpi2f_norm  {
	replace `var'=round(`var', .001) if country_year=="Egypt, Arab Rep._2017" 
}


*------ Vietnam: 2011 and 2017
replace updated=. if country_year=="Vietnam_2014"
replace updated=1 if country_year=="Vietnam_2017"

*For these questions, we use the values of 2011, not 2017
replace q4e_norm=. if country_year=="Vietnam_2017"
replace q46b_G1_norm=. if country_year=="Vietnam_2017"
replace q46f_G1_norm=. if country_year=="Vietnam_2017"
replace q46g_G1_norm=. if country_year=="Vietnam_2017"

foreach v in q1a_norm q1b_norm q1c_norm q1d_norm q1e_norm q1f_norm q1g_norm q1h_norm q1i_norm q1j_norm q2a_norm q2b_norm q2c_norm q2d_norm q2e_norm q2f_norm q2g_norm q3a_norm q4a_norm q3b_norm q4b_norm q3c_norm q4c_norm q3d_norm q4d_norm q3e_norm  q5_norm q6a_norm q6b_norm q6c_norm q7a_norm q7b_norm q7c_norm q8a_norm q8b_1_norm q8b_2_norm q8b_3_norm q8b_4_norm q8b_5_norm q8b_6_norm q8b_7_norm q8b_8_norm q8b_9_norm q8b_10_norm q8b_11_norm q8b_12_norm q8b_13_norm q8b_14_norm q8b_15_norm q8b_16_norm q8b_17_norm q8b_18_norm q8d_norm q8e_norm q8f_norm q9_norm q10a_norm q10b_norm q10c_norm q10d_norm q10e_norm q11a_norm q11b_norm q11c_norm q11d_norm q11e_norm q11f_norm q11g_norm q11h_norm q11i1_norm q11i2_norm q11j_norm q13b_norm q13d_norm q13e_norm q13f_norm q13g_norm q13h_norm q13i_norm q13j_norm q14b_norm q14d_norm q14e_norm q14f_norm q14g_norm q14h_norm q14i_norm q14j_norm q15a_norm q15b_norm q15c_norm q15d_norm q15e1_norm q15e2_norm q15f_norm q16a_norm q16b_norm q16c_norm q16d_norm q16e_norm q17_1_norm q17_2_norm q17_3_norm q17_4_norm q17_5_norm q17_6_norm q17_7_norm q17_8_norm q17_9_norm q17_10_norm q17_11_norm q17_12_norm q17_13_norm q17_14_norm q17_15_norm q17_16_norm q18a_norm q18b_norm q18c_norm q18d_norm q18e_norm q18f_norm q19_A1_norm q19_A2_norm q19_A3_norm q19_B1_norm q19_B2_norm q19_B3_norm q19_B4_norm q19_C1_norm q19_C2_norm q19_C3_norm q19_C4_norm q19_D1_norm q19_D2_norm q19_D3_norm q19_D4_norm q19_D5_norm q19_D6_norm q19_E1_norm q19_E2_norm q19_E3_norm q19_F1_norm q19_F2_norm q19_G1_norm q19_G2_norm q19_G3_norm q19_H1_norm q19_H2_norm q19_H3_norm q19_I1_norm q19_J1_norm q19_J2_norm q19_J3_norm q19_J4_norm q19_K1_norm q19_K2_norm q19_K3_norm q19_L1_norm q19_L2_norm q20_A1_norm q20_A2_norm q20_A3_norm q20_B1_norm q20_B2_norm q20_B3_norm q20_B4_norm q20_C1_norm q20_C2_norm q20_C3_norm q20_C4_norm q20_D1_norm q20_D2_norm q20_D3_norm q20_D4_norm q20_D5_norm q20_D6_norm q20_E1_norm q20_E2_norm q20_E3_norm q20_F1_norm q20_F2_norm q20_G1_norm q20_G2_norm q20_G3_norm q20_H1_norm q20_H2_norm q20_H3_norm q20_I1_norm q20_J1_norm q20_J2_norm q20_J3_norm q20_J4_norm q20_K1_norm q20_K2_norm q20_K3_norm q20_L1_norm q20_L2_norm q22a_norm q22b_norm q23_norm q24_norm q25_1_norm q25_2_norm q25_3_norm q25_4_norm q25_5_norm q25_6_norm q25_7_norm q25_8_norm q25_9_norm q26_norm q27_norm q28_norm q32a_norm q32b_norm q32c_norm q32d_norm q32e_norm q32f_norm q32g_norm q34_norm q36a_norm q36b_norm q36c_norm q37c_norm q37d_norm q38_norm q39_norm q41a_norm q41b_norm q41c_norm q41d_norm q42a_norm q42b_norm q42c_norm q42d_norm q42g_norm q42h_norm q43_G1_norm q43_G2_norm q44_G1_norm q44_G2_norm q45a_G1_norm q45a_G2_norm q45b_G1_norm q45b_G2_norm q45c_G1_norm q45c_G2_norm q45d_G1_norm q45d_G2_norm q45e_G1_norm q45e_G2_norm q46a_G1_norm q46a_G2_norm  q46b_G2_norm q46c_G1_norm q46c_G2_norm q46d_G1_norm q46d_G2_norm q46e_G1_norm q46e_G2_norm  q46f_G2_norm q46g_G2_norm q46h_G1_norm q46h_G2_norm q46i_G1_norm q46j_G1_norm q46k_G1_norm q47_norm q48a_G1_norm q48a_G2_norm q48b_G1_norm q48b_G2_norm q48c_G1_norm q48c_G2_norm q48d_G1_norm q48d_G2_norm q48e_G1_norm q48e_G2_norm q48f_G1_norm q48f_G2_norm q48g_G1_norm q48g_G2_norm q48h_G1_norm q49a_norm q49b_G1_norm q49b_G2_norm q49c_G1_norm q49c_G2_norm q49d_G1_norm q49d_G2_norm q49e_G1_norm q49e_G2_norm q50_norm q51_norm q52_norm qpi1_norm qpi2a_norm qpi2b_norm qpi2c_norm qpi2d_norm qpi2e_norm qpi2f_norm {
replace `v'=. if country_year=="Vietnam_2011"
}

*To make the scores exactly the same as the ones in the file of problematic scores we have to round the values
foreach var of varlist q1a_norm- qpi2f_norm  {
	replace `var'=round(`var', .001) if country_year=="Vietnam_2011"
}

replace updated=1 if country_year=="Vietnam_2011"

*To make the scores exactly the same as the ones in the file of problematic scores we have to round the values
foreach var of varlist q1a_norm- qpi2f_norm  {
	replace `var'=round(`var', .001) if country_year=="Vietnam_2017"
}

sum q43_G2_norm	q44_G1_norm	q44_G2_norm	q45a_G1_norm q45a_G2_norm q45b_G1_norm q45b_G2_norm q45d_G1_norm q45c_G2_norm q45e_G1_norm q45d_G2_norm	q45e_G2_norm ///
q2a_norm q2b_norm q2c_norm q2d_norm q2g_norm q18a_norm q18b_norm q18c_norm q18d_norm q18e_norm q18f_norm q6a_norm q6b_norm q6c_norm q7a_norm q7b_norm q7c_norm ///
q4a_norm q4e_norm q9_norm q48c_G1_norm q48d_G1_norm	q46a_G2_norm q46b_G1_norm q46b_G2_norm q46c_G1_norm	q46c_G2_norm q46d_G2_norm q46e_G2_norm q46d_G1_norm	q46f_G2_norm ///
q46e_G1_norm q46g_G2_norm q46f_G1_norm q46h_G2_norm	q46g_G1_norm q46h_G1_norm q43_G1_norm ///
if country_year=="Vietnam_2017"


*------ Zambia: 2012 and 2017
replace updated=. if country_year=="Zambia_2014"
replace updated=1 if country_year=="Zambia_2017"

*To make the scores exactly the same as the ones in the file of problematic scores we have to round the values
foreach var of varlist q1a_norm- qpi2f_norm  {
	replace `var'=round(`var', .001) if country_year=="Zambia_2017"
}

*For these questions we use the values of 2012, not 2017
replace q44_G2_norm=. if country_year=="Zambia_2017"
replace q45a_G1_norm=. if country_year=="Zambia_2017"
replace q45a_G2_norm=. if country_year=="Zambia_2017"
replace q45b_G1_norm=. if country_year=="Zambia_2017"
replace q45d_G2_norm=. if country_year=="Zambia_2017"
replace q45e_G2_norm=. if country_year=="Zambia_2017"
replace q4a_norm=. if country_year=="Zambia_2017"
replace q4e_norm=. if country_year=="Zambia_2017"
replace q48c_G1_norm=. if country_year=="Zambia_2017"
replace q46a_G2_norm=. if country_year=="Zambia_2017"
replace q46c_G2_norm=. if country_year=="Zambia_2017"
replace q46d_G2_norm=. if country_year=="Zambia_2017"
replace q46e_G2_norm=. if country_year=="Zambia_2017"
replace q46d_G1_norm=. if country_year=="Zambia_2017"
replace q46f_G2_norm=. if country_year=="Zambia_2017"
replace q46e_G1_norm=. if country_year=="Zambia_2017"
replace q46g_G2_norm=. if country_year=="Zambia_2017"
replace q46f_G1_norm=. if country_year=="Zambia_2017"
replace q43_G1_norm=. if country_year=="Zambia_2017"

sum q43_G2_norm	q44_G1_norm	q44_G2_norm	q45a_G1_norm	q45a_G2_norm	q45b_G1_norm	q45b_G2_norm	q45d_G1_norm	q45c_G2_norm	q45e_G1_norm	q45d_G2_norm	q45e_G2_norm	q2a_norm	q2b_norm	q2c_norm	q2d_norm	q2g_norm	q18a_norm	q18b_norm	q18c_norm	q18d_norm	q18e_norm	q18f_norm	q6a_norm	q6b_norm	q6c_norm	q7a_norm	q7b_norm	q7c_norm	q4a_norm	q4e_norm	q9_norm	q48c_G1_norm	q48d_G1_norm	q46a_G2_norm	q46b_G1_norm	q46b_G2_norm	q46c_G1_norm	q46c_G2_norm	q46d_G2_norm	q46e_G2_norm	q46d_G1_norm	q46f_G2_norm	q46e_G1_norm	q46g_G2_norm	q46f_G1_norm	q46h_G2_norm	q46g_G1_norm	q46h_G1_norm	q43_G1_norm ///
if country_year=="Zambia_2017"

foreach v in q1a_norm q1b_norm q1c_norm q1d_norm q1e_norm q1f_norm q1g_norm q1h_norm q1i_norm q1j_norm q2a_norm q2b_norm q2c_norm q2d_norm q2e_norm q2f_norm q2g_norm q3a_norm  q3b_norm q4b_norm q3c_norm q4c_norm q3d_norm q4d_norm q3e_norm  q5_norm q6a_norm q6b_norm q6c_norm q7a_norm q7b_norm q7c_norm q8a_norm q8b_1_norm q8b_2_norm q8b_3_norm q8b_4_norm q8b_5_norm q8b_6_norm q8b_7_norm q8b_8_norm q8b_9_norm q8b_10_norm q8b_11_norm q8b_12_norm q8b_13_norm q8b_14_norm q8b_15_norm q8b_16_norm q8b_17_norm q8b_18_norm q8d_norm q8e_norm q8f_norm q9_norm q10a_norm q10b_norm q10c_norm q10d_norm q10e_norm q11a_norm q11b_norm q11c_norm q11d_norm q11e_norm q11f_norm q11g_norm q11h_norm q11i1_norm q11i2_norm q11j_norm q13b_norm q13d_norm q13e_norm q13f_norm q13g_norm q13h_norm q13i_norm q13j_norm q14b_norm q14d_norm q14e_norm q14f_norm q14g_norm q14h_norm q14i_norm q14j_norm q15a_norm q15b_norm q15c_norm q15d_norm q15e1_norm q15e2_norm q15f_norm q16a_norm q16b_norm q16c_norm q16d_norm q16e_norm q17_1_norm q17_2_norm q17_3_norm q17_4_norm q17_5_norm q17_6_norm q17_7_norm q17_8_norm q17_9_norm q17_10_norm q17_11_norm q17_12_norm q17_13_norm q17_14_norm q17_15_norm q17_16_norm q18a_norm q18b_norm q18c_norm q18d_norm q18e_norm q18f_norm q19_A1_norm q19_A2_norm q19_A3_norm q19_B1_norm q19_B2_norm q19_B3_norm q19_B4_norm q19_C1_norm q19_C2_norm q19_C3_norm q19_C4_norm q19_D1_norm q19_D2_norm q19_D3_norm q19_D4_norm q19_D5_norm q19_D6_norm q19_E1_norm q19_E2_norm q19_E3_norm q19_F1_norm q19_F2_norm q19_G1_norm q19_G2_norm q19_G3_norm q19_H1_norm q19_H2_norm q19_H3_norm q19_I1_norm q19_J1_norm q19_J2_norm q19_J3_norm q19_J4_norm q19_K1_norm q19_K2_norm q19_K3_norm q19_L1_norm q19_L2_norm q20_A1_norm q20_A2_norm q20_A3_norm q20_B1_norm q20_B2_norm q20_B3_norm q20_B4_norm q20_C1_norm q20_C2_norm q20_C3_norm q20_C4_norm q20_D1_norm q20_D2_norm q20_D3_norm q20_D4_norm q20_D5_norm q20_D6_norm q20_E1_norm q20_E2_norm q20_E3_norm q20_F1_norm q20_F2_norm q20_G1_norm q20_G2_norm q20_G3_norm q20_H1_norm q20_H2_norm q20_H3_norm q20_I1_norm q20_J1_norm q20_J2_norm q20_J3_norm q20_J4_norm q20_K1_norm q20_K2_norm q20_K3_norm q20_L1_norm q20_L2_norm q22a_norm q22b_norm q23_norm q24_norm q25_1_norm q25_2_norm q25_3_norm q25_4_norm q25_5_norm q25_6_norm q25_7_norm q25_8_norm q25_9_norm q26_norm q27_norm q28_norm q32a_norm q32b_norm q32c_norm q32d_norm q32e_norm q32f_norm q32g_norm q34_norm q36a_norm q36b_norm q36c_norm q37c_norm q37d_norm q38_norm q39_norm q41a_norm q41b_norm q41c_norm q41d_norm q42a_norm q42b_norm q42c_norm q42d_norm q42g_norm q42h_norm q43_G2_norm q44_G1_norm   q45b_G2_norm q45c_G1_norm q45c_G2_norm q45d_G1_norm  q45e_G1_norm  q46a_G1_norm  q46b_G1_norm q46b_G2_norm q46c_G1_norm q46g_G1_norm  q46h_G1_norm q46h_G2_norm q46i_G1_norm q46j_G1_norm q46k_G1_norm q47_norm q48a_G1_norm q48a_G2_norm q48b_G1_norm q48b_G2_norm  q48c_G2_norm q48d_G1_norm q48d_G2_norm q48e_G1_norm q48e_G2_norm q48f_G1_norm q48f_G2_norm q48g_G1_norm q48g_G2_norm q48h_G1_norm q49a_norm q49b_G1_norm q49b_G2_norm q49c_G1_norm q49c_G2_norm q49d_G1_norm q49d_G2_norm q49e_G1_norm q49e_G2_norm q50_norm q51_norm q52_norm qpi1_norm qpi2a_norm qpi2b_norm qpi2c_norm qpi2d_norm qpi2e_norm qpi2f_norm {
replace `v'=. if country_year=="Zambia_2012"
}

*To make the scores exactly the same as the ones in the file of problematic scores we have to round the values
foreach var of varlist q1a_norm- qpi2f_norm  {
	replace `var'=round(`var', .001) if country_year=="Zambia_2012"
}

sum q43_G2_norm	q44_G1_norm	q44_G2_norm	q45a_G1_norm	q45a_G2_norm	q45b_G1_norm	q45b_G2_norm	q45d_G1_norm	q45c_G2_norm	q45e_G1_norm	q45d_G2_norm	q45e_G2_norm	q2a_norm	q2b_norm	q2c_norm	q2d_norm	q2g_norm	q18a_norm	q18b_norm	q18c_norm	q18d_norm	q18e_norm	q18f_norm	q6a_norm	q6b_norm	q6c_norm	q7a_norm	q7b_norm	q7c_norm	q4a_norm	q4e_norm	q9_norm	q48c_G1_norm	q48d_G1_norm	q46a_G2_norm	q46b_G1_norm	q46b_G2_norm	q46c_G1_norm	q46c_G2_norm	q46d_G2_norm	q46e_G2_norm	q46d_G1_norm	q46f_G2_norm	q46e_G1_norm	q46g_G2_norm	q46f_G1_norm	q46h_G2_norm	q46g_G1_norm	q46h_G1_norm	q43_G1_norm ///
if country_year=="Zambia_2012"

replace updated=1 if country_year=="Zambia_2012"


*------ United Arab Emirates: 2011 and 2017 
replace updated=1 if country_year=="United Arab Emirates_2011"

*To make the scores exactly the same as the ones in the file of problematic scores we have to round the values
foreach var of varlist q1a_norm- qpi2f_norm  {
	replace `var'=round(`var', .001) if country_year=="United Arab Emirates_2011"
}

*Dataset created in 2019 by Natalia
append using "$path2data\Problematic countries\UAE_2017_index.dta", force

*To make the scores exactly the same as the ones in the file of problematic scores we have to round the values
foreach var of varlist q1a_norm- qpi2f_norm  {
	replace `var'=round(`var', .001) if country_year=="United Arab Emirates_2017"
}

replace updated=1 if country_year=="United Arab Emirates_2017"

sum q43_G2_norm	q44_G1_norm	q44_G2_norm	q45a_G1_norm	q45a_G2_norm	q45b_G1_norm	q45b_G2_norm	q45d_G1_norm	q45c_G2_norm	q45e_G1_norm	q45d_G2_norm	q45e_G2_norm	q2a_norm	q2b_norm	q2c_norm	q2d_norm	q2g_norm	q18a_norm	q18b_norm	q18c_norm	q18d_norm	q18e_norm	q18f_norm	q6a_norm	q6b_norm	q6c_norm	q7a_norm	q7b_norm	q7c_norm	q4a_norm	q4e_norm	q9_norm	q48c_G1_norm	q48d_G1_norm	q46a_G2_norm	q46b_G1_norm	q46b_G2_norm	q46c_G1_norm	q46c_G2_norm	q46d_G2_norm	q46e_G2_norm	q46d_G1_norm	q46f_G2_norm	q46e_G1_norm	q46g_G2_norm	q46f_G1_norm	q46h_G2_norm	q46g_G1_norm	q46h_G1_norm	q43_G1_norm ///
if country_year=="United Arab Emirates_2011" | country_year=="United Arab Emirates_2017"


*------ Combining observations of various years without mergin the full data sets

/* Case: Bahamas - Combine 2018 and 2022 data for q43_G1_norm (Added by Alex, 2022) */
/* Case: Belize - Combine 2019 and 2021 data for two variables: q2a_norm q44_G1_norm (Added by Alex, 2022) */
/* Case: Brazil - Combine 2017 and 2021 data for the following variables: q46a_G2_norm q46b_G2_norm q46c_G2_norm q46d_G2_norm q46e_G2_norm q46f_G2_norm q46g_G2_norm q46h_G2_norm (Added by Alex, 2022) */
/* Case: Costa Rica - Combine 2019 and 2022 data for q2a_norm (Added by Alex, 2022) */
/* Case: Dominican Republic - Combine 2018 and 2022 data for q45b_G1_norm q44_G2_norm q45a_G1_norm q45a_G2_norm (Added by Alex, 2022) */
/* Case: Guatemala - Combine 2018 and 2021 data for q7a_norm q7b_norm q7c_norm (Added by Alex, 2022) */
/* Case: Hait - Combine 2021 and 2022 data for q44_G2_norm q2a_norm q6c_norm q18a_norm (Added by Alex, 2022) */
/* Case: Honduras - Combine 2019 and 2022 data for q44_G1_norm q44_G2_norm (Added by Alex, 2022) */
/* Case: Trinidad and Tobago - Combine 2018 and 2022 data for q44_G1_norm (Added by Alex, 2022)*/

gen combine_obs=1 if country_year=="Belize_2019" | country_year=="Belize_2021"

replace combine_obs=1 if country_year=="Bahamas_2018" | country_year=="Bahamas_2022"
replace combine_obs=1 if country_year=="Brazil_2017" | country_year=="Brazil_2022"
replace combine_obs=1 if country_year=="Costa Rica_2019" | country_year=="Costa Rica_2022"
replace combine_obs=1 if country_year=="Dominican Republic_2018" | country_year=="Dominican Republic_2022"
replace combine_obs=1 if country_year=="Guatemala_2018" | country_year=="Guatemala_2021"
replace combine_obs=1 if country_year=="Haiti_2021" | country_year=="Haiti_2022"
replace combine_obs=1 if country_year=="Honduras_2019" | country_year=="Honduras_2021"
replace combine_obs=1 if country_year=="Trinidad and Tobago_2018" | country_year=="Trinidad and Tobago_2022"

gen previous_year=1 if country_year=="Belize_2019"

replace combine_obs=1 if country_year=="Bahamas_2018" | country_year=="Bahamas_2022"

* EU 2024 
replace previous_year=1 if country_year=="Austria_2017"
replace previous_year=1 if country_year=="Belgium_2018"
replace previous_year=1 if country_year=="Bulgaria_2018" 
replace previous_year=1 if country_year=="Croatia_2018" 
replace previous_year=1 if country_year=="Cyprus_2021" 
replace previous_year=1 if country_year=="Czechia_2017"
replace previous_year=1 if country_year=="Denmark_2017"
replace previous_year=1 if country_year=="Estonia_2017"
replace previous_year=1 if country_year=="Finland_2017"
replace previous_year=1 if country_year=="France_2018" 
replace previous_year=1 if country_year=="Germany_2018"
replace previous_year=1 if country_year=="Greece_2017" 
replace previous_year=1 if country_year=="Hungary_2017"
replace previous_year=1 if country_year=="Ireland_2021"
replace previous_year=1 if country_year=="Italy_2017" 
replace previous_year=1 if country_year=="Latvia_2021"
replace previous_year=1 if country_year=="Lithuania_2021"
replace previous_year=1 if country_year=="Luxembourg_2021"
replace previous_year=1 if country_year=="Malta_2021" 
replace previous_year=1 if country_year=="Netherlands_2018" 
replace previous_year=1 if country_year=="Poland_2018" 
replace previous_year=1 if country_year=="Portugal_2017" 
replace previous_year=1 if country_year=="Romania_2018" 
replace previous_year=1 if country_year=="Slovak Republic_2021" 
replace previous_year=1 if country_year=="Slovenia_2017" 
replace previous_year=1 if country_year=="Spain_2018" 
replace previous_year=1 if country_year=="Sweden_2018"


* Keep only the needed years
keep if updated==1 | combine_obs==1 | previous_year==1


* Check if we are using the correct data for each country (that we're not mixing years)
tab country_year

*Round decimals to three places (Included to match 2018's map)
*2017 scores were rounded but 2018 were not
foreach var of varlist q1a_norm- qpi2f_norm  {
	replace `var'=round(`var', .001) if year==2017
}


/*=================================================================================================================
					3. Sampling weights EU 2024
=================================================================================================================*/

rename nuts_id nuts

*- Czechia 

replace nuts="CZ020304" if nuts=="CZ02" | nuts=="CZ03" | nuts=="CZ04"
replace nuts="CZ0506" if nuts=="CZ05" | nuts=="CZ06"
replace nuts="CZ0708" if nuts=="CZ07" | nuts=="CZ08"


*- Finland

replace nuts="FI1C20" if nuts=="FI1C" | nuts=="FI20"


replace country="Slovakia" if country=="Slovak Republic"

*Merging weights
merge m:1 country nuts using "${path2SP}\Data Analytics\7. WJP ROLI\ROLI_2024\1. Cleaning\GPP\1. Data\0. Metadata\general_info_eu.dta"
drop _merge

replace country="Slovak Republic" if country=="Slovakia" 


/*=================================================================================================================
					4. Keeping only the variables used in the Index
=================================================================================================================*/

keep country q43_G2_norm q44_G1_norm q44_G2_norm q45a_G1_norm q45a_G2_norm q45b_G1_norm	q45b_G2_norm q45d_G1_norm q45c_G2_norm q45e_G1_norm	q45d_G2_norm q45e_G2_norm ///
q2a_norm q2b_norm q2c_norm q2d_norm	q2g_norm q18a_norm q18b_norm q18c_norm q18d_norm q18e_norm q18f_norm q6a_norm q6b_norm q6c_norm	q7a_norm q7b_norm q7c_norm ///
q4a_norm q4e_norm q9_norm q48c_G1_norm q48d_G1_norm q46a_G2_norm q46b_G1_norm q46b_G2_norm q46c_G1_norm	q46c_G2_norm q46d_G2_norm q46e_G2_norm q46d_G1_norm	q46f_G2_norm ///
q46e_G1_norm q46g_G2_norm q46f_G1_norm q46h_G2_norm q46g_G1_norm q46h_G1_norm q43_G1_norm updated combine_obs previous_year nuts regionpoppct country_year


** Check scale of NORM variables for anything greater than 1 or less than 0
foreach var of varlist *_norm {
	display "`var'"
	tab country if `var'>1 & `var'!=.
	*list `var' if `var'>1 & `var'!=.
}

foreach var of varlist *_norm  {
	display "`var'"
	tab country if `var'<0 & `var'!=.
	*list `var' if `var'<0 & `var'!=.
}

save "${path2SP}\Data Analytics\7. WJP ROLI\ROLI_2024\1. Cleaning\GPP\1. Data\data_partial_gpp_2024.dta", replace


/*=================================================================================================================
					5. Creating country scores and keeping one observation by country
=================================================================================================================*/


//Uzbekistan//
/*PROMEDIOS SE HICIERON EN EXCEL PARA UZBEKISTAN. Se hizo una ponderacion entre los scores de este año y los del Map anterior*/

gen EU_old=1 if previous_year==1 & country!="Belize"

gen EU=1 if country=="Austria" | country=="Belgium" | country=="Bulgaria" | country=="Croatia" | country=="Cyprus" | country=="Czechia" | country=="Denmark" | country=="Estonia" | country=="Finland" | country=="France" | country=="Germany" | country=="Greece" | country=="Hungary" | country=="Ireland" | country=="Italy" | country=="Latvia" | country=="Lithuania" | country=="Luxembourg" | country=="Malta" | country=="Netherlands" | country=="Poland" | country=="Portugal" | country=="Romania" | country=="Slovak Republic" | country=="Slovenia" | country=="Spain" | country=="Sweden"


*----- Creating NUTS averages for the EU
foreach v in q2a_norm q2b_norm q2c_norm q2d_norm q2g_norm q4a_norm q4e_norm q6a_norm q6b_norm q6c_norm q7a_norm q7b_norm q7c_norm q9_norm q18a_norm q18b_norm q18c_norm q18d_norm q18e_norm q18f_norm q43_G1_norm q43_G2_norm q44_G1_norm q44_G2_norm q45a_G1_norm q45a_G2_norm q45b_G1_norm q45b_G2_norm q45c_G2_norm q45d_G1_norm q45d_G2_norm q45e_G1_norm q45e_G2_norm q46a_G2_norm q46b_G1_norm q46b_G2_norm q46c_G1_norm q46c_G2_norm q46d_G1_norm q46d_G2_norm q46e_G1_norm q46e_G2_norm q46f_G1_norm q46f_G2_norm q46g_G1_norm q46g_G2_norm q46h_G1_norm q46h_G2_norm q48c_G1_norm q48d_G1_norm {
bysort country nuts: egen EU_`v'=mean(`v') if updated==1 & nuts!=""
}

* Applying weights to the NUTS averages
foreach v in q2a_norm q2b_norm q2c_norm q2d_norm q2g_norm q4a_norm q4e_norm q6a_norm q6b_norm q6c_norm q7a_norm q7b_norm q7c_norm q9_norm q18a_norm q18b_norm q18c_norm q18d_norm q18e_norm q18f_norm q43_G1_norm q43_G2_norm q44_G1_norm q44_G2_norm q45a_G1_norm q45a_G2_norm q45b_G1_norm q45b_G2_norm q45c_G2_norm q45d_G1_norm q45d_G2_norm q45e_G1_norm q45e_G2_norm q46a_G2_norm q46b_G1_norm q46b_G2_norm q46c_G1_norm q46c_G2_norm q46d_G1_norm q46d_G2_norm q46e_G1_norm q46e_G2_norm q46f_G1_norm q46f_G2_norm q46g_G1_norm q46g_G2_norm q46h_G1_norm q46h_G2_norm q48c_G1_norm q48d_G1_norm {
replace EU_`v'=EU_`v'*regionpoppct
}

* EU missing questions - previous years
foreach v in q44_G1_norm q44_G2_norm q45a_G1_norm q45a_G2_norm q45b_G1_norm q45b_G2_norm q45d_G1_norm q45c_G2_norm q45e_G1_norm q45d_G2_norm q45e_G2_norm q18a_norm q18b_norm q18c_norm q18d_norm q18e_norm q18f_norm q6a_norm q6b_norm q6c_norm q48c_G1_norm q48d_G1_norm q46h_G2_norm q43_G1_norm {
bysort country: egen EU_old_`v'=mean(`v') if EU==1
}

foreach v in q44_G1_norm q44_G2_norm q45a_G1_norm q45a_G2_norm q45b_G1_norm q45b_G2_norm q45d_G1_norm q45c_G2_norm q45e_G1_norm q45d_G2_norm q45e_G2_norm q18a_norm q18b_norm q18c_norm q18d_norm q18e_norm q18f_norm q6a_norm q6b_norm q6c_norm q48c_G1_norm q48d_G1_norm q46h_G2_norm q43_G1_norm {
replace EU_`v'=EU_old_`v' if EU==1 & EU_`v'==.
drop EU_old_`v' 
}

*----- Creating country scores for all questions - NON EU countries
foreach v in q2a_norm q2b_norm q2c_norm q2d_norm q2g_norm q4a_norm q4e_norm q6a_norm q6b_norm q6c_norm q7a_norm q7b_norm q7c_norm q9_norm q18a_norm q18b_norm q18c_norm q18d_norm q18e_norm q18f_norm q43_G1_norm q43_G2_norm q44_G1_norm q44_G2_norm q45a_G1_norm q45a_G2_norm q45b_G1_norm q45b_G2_norm q45c_G2_norm q45d_G1_norm q45d_G2_norm q45e_G1_norm q45e_G2_norm q46a_G2_norm q46b_G1_norm q46b_G2_norm q46c_G1_norm q46c_G2_norm q46d_G1_norm q46d_G2_norm q46e_G1_norm q46e_G2_norm q46f_G1_norm q46f_G2_norm q46g_G1_norm q46g_G2_norm q46h_G1_norm q46h_G2_norm q48c_G1_norm q48d_G1_norm {
bysort country: egen CO_`v'=mean(`v') if updated==1
}


/* Case: Belize - Combine 2019 and 2021 data for two variables: q2a_norm q43_G1_norm, and use 2019 data for one variable (q44_G1_norm) (Added by Alex, 2022) */
foreach var of varlist q2a_norm q43_G1_norm {
	egen AUX_`var'=mean(`var') if combine_obs==1 & country=="Belize"
	replace CO_`var'=AUX_`var' if country=="Belize"
	drop AUX_`var'
}
foreach var of varlist q44_G1_norm {
	egen AUX1_`var'=mean(`var') if previous_year==1 & country=="Belize"
	egen AUX2_`var'=max(AUX1_`var') if country=="Belize"
	replace CO_`var'=AUX2_`var' if country=="Belize"
	drop AUX1_`var' AUX2_`var'
}
/* Case: Bahamas - Combine 2018 and 2022 data for q43_G1_norm (Added by Alex, 2022) */
foreach var of varlist q43_G1_norm  {
	egen AUX_`var'=mean(`var') if combine_obs==1 & country=="Bahamas"
	replace CO_`var'=AUX_`var' if country=="Bahamas"
	drop AUX_`var'
}
/* Case: Brazil - Combine 2017 and 2021 data for the following variables: q46a_G2_norm q46b_G2_norm q46c_G2_norm q46d_G2_norm q46e_G2_norm q46f_G2_norm q46g_G2_norm q46h_G2_norm (Added by Alex, 2022) */
foreach var of varlist q46a_G2_norm q46b_G2_norm q46c_G2_norm q46d_G2_norm q46e_G2_norm q46f_G2_norm q46g_G2_norm q46h_G2_norm  {
	egen AUX_`var'=mean(`var') if combine_obs==1 & country=="Brazil"
	replace CO_`var'=AUX_`var' if country=="Brazil"
	drop AUX_`var'
}
/* Case: Costa Rica - Combine 2019 and 2022 data for q2a_norm (Added by Alex, 2022) */
foreach var of varlist q2a_norm  {
	egen AUX_`var'=mean(`var') if combine_obs==1 & country=="Costa Rica"
	replace CO_`var'=AUX_`var' if country=="Costa Rica"
	drop AUX_`var'
}
/* Case: Dominican Republic - Combine 2018 and 2022 data for q45b_G1_norm q44_G2_norm q45a_G1_norm q45a_G2_norm (Added by Alex, 2022) */
foreach var of varlist q45b_G1_norm q44_G2_norm q45a_G1_norm q45a_G2_norm  {
	egen AUX_`var'=mean(`var') if combine_obs==1 & country=="Dominican Republic"
	replace CO_`var'=AUX_`var' if country=="Dominican Republic"
	drop AUX_`var'
}
/* Case: Guatemala - Combine 2018 and 2021 data for q7a_norm q7b_norm q7c_norm (Added by Alex, 2022) */
foreach var of varlist q7a_norm q7b_norm q7c_norm  {
	egen AUX_`var'=mean(`var') if combine_obs==1 & country=="Guatemala"
	replace CO_`var'=AUX_`var' if country=="Guatemala"
	drop AUX_`var'
}
/* Case: Haiti - Combine 2021 and 2022 data for q44_G2_norm q2a_norm q6c_norm q18a_norm (Added by Alex, 2022) */
foreach var of varlist q44_G2_norm q2a_norm q6c_norm q18a_norm {
	egen AUX_`var'=mean(`var') if combine_obs==1 & country=="Haiti"
	replace CO_`var'=AUX_`var' if country=="Haiti"
	drop AUX_`var'
}
/* Case: Honduras - Combine 2019 and 2022 data for q44_G1_norm q44_G2_norm (Added by Alex, 2022) */
foreach var of varlist q44_G1_norm q44_G2_norm {
	egen AUX_`var'=mean(`var') if combine_obs==1 & country=="Honduras"
	replace CO_`var'=AUX_`var' if country=="Honduras"
	drop AUX_`var'
}
/* Case: Trinidad and Tobago - Combine 2018 and 2022 data for q44_G1_norm (Added by Alex, 2022)*/
foreach var of varlist q44_G1_norm  {
	egen AUX_`var'=mean(`var') if combine_obs==1 & country=="Trinidad and Tobago"
	replace CO_`var'=AUX_`var' if country=="Trinidad and Tobago"
	drop AUX_`var'
}


/* Ireland: The EU 2023 questionnaire for Ireland was abridged. This questionnaire is missing q7a-q7c */
foreach v in q7a_norm q7b_norm q7c_norm  {
	egen `v'_IR=mean(`v') if country=="Ireland"
	replace CO_`v'=`v'_IR if country=="Ireland"
}


drop if updated==.
egen tag_nuts_country=tag(country nuts)
egen tag=tag(country)
sort country

replace tag=1 if tag_nuts_country==1

/* Keep one observation per country */
keep if tag==1 


*----- Creating averages for EU countries with population weights
foreach v in q43_G2_norm q2a_norm q2b_norm q2c_norm q2d_norm q2g_norm q7a_norm q7b_norm q7c_norm q4a_norm q4e_norm q9_norm q46a_G2_norm q46b_G1_norm q46b_G2_norm q46c_G1_norm q46c_G2_norm q46d_G2_norm q46e_G2_norm q46d_G1_norm q46f_G2_norm q46e_G1_norm q46g_G2_norm q46f_G1_norm q46g_G1_norm q46h_G1_norm {
	bysort country: egen CO_EU_`v'=total(EU_`v') if EU_`v'!=.
}

foreach v in q44_G1_norm q44_G2_norm q45a_G1_norm q45a_G2_norm q45b_G1_norm q45b_G2_norm q45d_G1_norm q45c_G2_norm q45e_G1_norm q45d_G2_norm q45e_G2_norm q18a_norm q18b_norm q18c_norm q18d_norm q18e_norm q18f_norm q6a_norm q6b_norm q6c_norm q48c_G1_norm q48d_G1_norm q46h_G2_norm q43_G1_norm {
	gen CO_EU_`v'=EU_`v'
}

*Replacing country scores with final weighted country averages - EU
foreach v in q2a_norm q2b_norm q2c_norm q2d_norm q2g_norm q4a_norm q4e_norm q6a_norm q6b_norm q6c_norm q7a_norm q7b_norm q7c_norm q9_norm q18a_norm q18b_norm q18c_norm q18d_norm q18e_norm q18f_norm q43_G1_norm q43_G2_norm q44_G1_norm q44_G2_norm q45a_G1_norm q45a_G2_norm q45b_G1_norm q45b_G2_norm q45c_G2_norm q45d_G1_norm q45d_G2_norm q45e_G1_norm q45e_G2_norm q46a_G2_norm q46b_G1_norm q46b_G2_norm q46c_G1_norm q46c_G2_norm q46d_G1_norm q46d_G2_norm q46e_G1_norm q46e_G2_norm q46f_G1_norm q46f_G2_norm q46g_G1_norm q46g_G2_norm q46h_G1_norm q46h_G2_norm q48c_G1_norm q48d_G1_norm {
	replace CO_`v'=CO_EU_`v' if nuts!=""
}

*For Ireland
foreach v in q7a_norm q7b_norm q7c_norm  {
	replace CO_`v'=`v'_IR if country=="Ireland"
}
drop q7a_norm_IR q7b_norm_IR q7c_norm_IR

*----- Renaming questions 
foreach v in q2a_norm q2b_norm q2c_norm q2d_norm q2g_norm q4a_norm q4e_norm q6a_norm q6b_norm q6c_norm q7a_norm q7b_norm q7c_norm q9_norm q18a_norm q18b_norm q18c_norm q18d_norm q18e_norm q18f_norm q43_G1_norm q43_G2_norm q44_G1_norm q44_G2_norm q45a_G1_norm q45a_G2_norm q45b_G1_norm q45b_G2_norm q45c_G2_norm q45d_G1_norm q45d_G2_norm q45e_G1_norm q45e_G2_norm q46a_G2_norm q46b_G1_norm q46b_G2_norm q46c_G1_norm q46c_G2_norm q46d_G1_norm q46d_G2_norm q46e_G1_norm q46e_G2_norm q46f_G1_norm q46f_G2_norm q46g_G1_norm q46g_G2_norm q46h_G1_norm q46h_G2_norm q48c_G1_norm q48d_G1_norm {
	drop `v' EU_`v' CO_EU_`v' 
	rename CO_`v' `v'
}

sort country

drop regionpoppct nuts tag_nuts_country tag

egen tag=tag(country)
keep if tag==1 

drop country_year EU_old EU


/*=================================================================================================================
					6. Replacing some observations for problematic countries
=================================================================================================================*/

/*---------------*/
/* Prior to 2018 */
/*------**********/

//Belarus//
replace q18a_norm =. if country == "Belarus"
replace q18b_norm =. if country == "Belarus"
replace q18c_norm =. if country == "Belarus"
replace q18d_norm =. if country == "Belarus"
replace q18e_norm =. if country == "Belarus"
replace q18f_norm =. if country == "Belarus"
replace q7a_norm =. if country == "Belarus"
replace q7a_norm =. if country == "Belarus"
replace q7b_norm =. if country == "Belarus"
replace q7c_norm =. if country == "Belarus"

//Bosnia and Herzegovina//
replace q2a_norm =. if country == "Bosnia and Herzegovina"


//Burkina Faso//
replace q2a_norm =. if country == "Burkina Faso"

//Cambodia// 
replace q45c_G2_norm =. if country == "Cambodia"
replace q6a_norm =. if country == "Cambodia"
replace q6b_norm =. if country == "Cambodia"
replace q6c_norm =. if country == "Cambodia"
replace q7a_norm =. if country == "Cambodia"
replace q7b_norm =. if country == "Cambodia"
replace q7c_norm =. if country == "Cambodia"
replace q46d_G1_norm =. if country == "Cambodia"
replace q46e_G1_norm =. if country == "Cambodia"
replace q43_G1_norm =. if country == "Cambodia"

//Chile//
replace q2a_norm =. if country == "Chile"
/*
//Cote d'Ivoire//
replace q18b_norm =. if country == "Cote d'Ivoire"
replace q6a_norm =. if country == "Cote d'Ivoire"
replace q6b_norm =. if country == "Cote d'Ivoire"
replace q6c_norm =. if country == "Cote d'Ivoire"
replace q7b_norm =. if country == "Cote d'Ivoire"
*/
//Egypt//
replace q44_G1_norm =. if country == "Egypt, Arab Rep."
replace q45a_G1_norm =. if country == "Egypt, Arab Rep."
replace q45a_G2_norm =. if country == "Egypt, Arab Rep."
replace q45b_G1_norm =. if country == "Egypt, Arab Rep."
replace q18d_norm =. if country == "Egypt, Arab Rep."
replace q18e_norm =. if country == "Egypt, Arab Rep."
replace q6b_norm =. if country == "Egypt, Arab Rep."
replace q6c_norm =. if country == "Egypt, Arab Rep."
replace q7a_norm =. if country == "Egypt, Arab Rep."
replace q7b_norm =. if country == "Egypt, Arab Rep."
replace q7c_norm =. if country == "Egypt, Arab Rep."
replace q46a_G2_norm =. if country == "Egypt, Arab Rep."
replace q46b_G1_norm =. if country == "Egypt, Arab Rep."
replace q46c_G1_norm =. if country == "Egypt, Arab Rep."
replace q46c_G2_norm =. if country == "Egypt, Arab Rep."
replace q46e_G2_norm =. if country == "Egypt, Arab Rep."
replace q46f_G2_norm =. if country == "Egypt, Arab Rep."
replace q46g_G2_norm =. if country == "Egypt, Arab Rep."
replace q46f_G1_norm =. if country == "Egypt, Arab Rep."


//Ethiopia//
replace q46b_G2_norm =. if country == "Ethiopia"

//Hong Kong SAR, China//
replace q44_G2_norm =. if country == "Hong Kong SAR, China"
replace q45a_G2_norm =. if country == "Hong Kong SAR, China"
replace q45b_G1_norm =. if country == "Hong Kong SAR, China"
replace q2c_norm =. if country == "Hong Kong SAR, China"
replace q46c_G2_norm =. if country == "Hong Kong SAR, China"
replace q46e_G2_norm =. if country == "Hong Kong SAR, China"

//Liberia//
replace q45a_G1_norm =. if country == "Liberia"
replace q7a_norm =. if country == "Liberia"
replace q46c_G1_norm =. if country == "Liberia"
replace q46c_G2_norm =. if country == "Liberia"
replace q46e_G1_norm =. if country == "Liberia"
replace q46g_G2_norm =. if country == "Liberia"

//Malawi//
replace q45a_G1_norm =. if country == "Malawi"
replace q6b_norm =. if country == "Malawi"
replace q7c_norm =. if country == "Malawi"
replace q43_G1_norm =. if country == "Malawi"

//Malaysia//
replace q45d_G2_norm =. if country == "Malaysia"
replace q45e_G2_norm =. if country == "Malaysia"
replace q6a_norm =. if country == "Malaysia"
replace q6b_norm =. if country == "Malaysia"
replace q6c_norm =. if country == "Malaysia"
replace q7a_norm =. if country == "Malaysia"
replace q7b_norm =. if country == "Malaysia"
replace q7c_norm =. if country == "Malaysia"
replace q46a_G2_norm =. if country == "Malaysia"
replace q46c_G1_norm =. if country == "Malaysia"
replace q46c_G2_norm =. if country == "Malaysia"
replace q46d_G1_norm =. if country == "Malaysia"
replace q46f_G2_norm =. if country == "Malaysia"
replace q46e_G1_norm =. if country == "Malaysia"
replace q46f_G1_norm =. if country == "Malaysia"
replace q46g_G1_norm =. if country == "Malaysia"

//Mexico//
replace q2a_norm =. if country == "Mexico"
replace q46h_G2_norm =. if country == "Mexico"

//Morocco//
replace q45a_G1_norm =. if country == "Morocco"

//Nepal// 
replace q6b_norm =. if country == "Nepal"
replace q6c_norm =. if country == "Nepal"

//Singapore//
replace q45a_G1_norm =. if country == "Singapore"
replace q45a_G2_norm =. if country == "Singapore"
replace q45b_G1_norm =. if country == "Singapore"


//Sri Lanka//
replace q18d_norm =. if country == "Sri Lanka"
replace q18f_norm =. if country == "Sri Lanka"
replace q6a_norm =. if country == "Sri Lanka"
replace q6b_norm =. if country == "Sri Lanka"
replace q6c_norm =. if country == "Sri Lanka"
replace q7a_norm =. if country == "Sri Lanka"
replace q7b_norm =. if country == "Sri Lanka"
replace q7c_norm =. if country == "Sri Lanka"
replace q46e_G2_norm =. if country == "Sri Lanka"

//Ukraine//

replace q6a_norm =. if country == "Ukraine"
replace q6b_norm =. if country == "Ukraine"
replace q6c_norm =. if country == "Ukraine"

//United Arab Emirates//
replace q44_G2_norm =. if country == "United Arab Emirates"
replace q45a_G2_norm =. if country == "United Arab Emirates" 
replace q45b_G1_norm =. if country == "United Arab Emirates"
replace q6a_norm =. if country == "United Arab Emirates"
replace q6b_norm =. if country == "United Arab Emirates"
replace q7a_norm =. if country == "United Arab Emirates" 
replace q7b_norm =. if country == "United Arab Emirates"
replace q7c_norm =. if country == "United Arab Emirates"
replace q46b_G2_norm =. if country == "United Arab Emirates"
replace q43_G1_norm =. if country == "United Arab Emirates"

//Vietnam//
replace q44_G2_norm =. if country == "Vietnam"
replace q45a_G1_norm =. if country == "Vietnam"
replace q45a_G2_norm=. if country == "Vietnam"
replace q45b_G1_norm =. if country == "Vietnam"
replace q2a_norm =. if country == "Vietnam"
replace q6a_norm =. if country == "Vietnam"
replace q6b_norm =. if country == "Vietnam"
replace q6c_norm =. if country == "Vietnam"
replace q7c_norm =. if country == "Vietnam"
replace q46d_G1_norm =. if country == "Vietnam"
replace q46e_G1_norm =. if country == "Vietnam"
replace q43_G1_norm=. if country == "Vietnam"

//Zambia//
replace q2a_norm =. if country == "Zambia"


/*------*/
/* 2018 */
/*------*/

//Albania//
replace q45d_G2_norm =. if country == "Albania"
replace q45e_G2_norm=. if country == "Albania"


//Cote d'Ivoire//
replace q6a_norm=. if country=="Cote d'Ivoire"


//Iran//
replace q2a_norm =. if country == "Iran, Islamic Rep."
//Jordan
replace q45a_G1_norm =. if country == "Jordan"
replace q45b_G1_norm =. if country == "Jordan"
replace q2a_norm =. if country == "Jordan"
//Kyrgyz Republic//
replace q45b_G1_norm =. if country == "Kyrgyz Republic"
replace q45a_G2_norm =. if country == "Kyrgyz Republic"
replace q45d_G2_norm =. if country == "Kyrgyz Republic"
replace q45e_G2_norm =. if country == "Kyrgyz Republic"
replace q43_G1_norm =. if country == "Kyrgyz Republic"
//Lebanon
replace q43_G1_norm =. if country == "Lebanon"
//Madagascar
replace q43_G1_norm =. if country == "Madagascar"
//Malaysia//
replace q43_G1_norm =. if country == "Malaysia"
//Morocco//
replace q2a_norm =. if country == "Morocco"
//Mongolia//
replace q43_G1_norm =. if country == "Mongolia"
//Myanmar//
replace q46e_G1_norm=. if country == "Myanmar"
replace q46f_G1_norm=. if country == "Myanmar"
replace q46c_G2_norm=. if country == "Myanmar"
replace q46d_G2_norm=. if country == "Myanmar"
replace q46e_G2_norm=. if country == "Myanmar"
replace q46f_G2_norm=. if country == "Myanmar"
replace q46g_G2_norm=. if country == "Myanmar"
replace q46h_G2_norm=. if country == "Myanmar"
replace q45d_G2_norm=. if country == "Myanmar"
replace q45e_G2_norm=. if country == "Myanmar"
replace q46a_G2_norm=. if country == "Myanmar"
replace q45a_G1_norm=. if country == "Myanmar"


//Russian Federation
replace q6c_norm=. if country == "Russian Federation"
replace q6b_norm=. if country == "Russian Federation"
replace q44_G1_norm=. if country == "Russian Federation"

//Rwanda
replace q2a_norm=. if country == "Rwanda"
replace q45a_G2_norm=. if country == "Rwanda"
replace q45c_G2_norm=. if country == "Rwanda"
replace q43_G1_norm=. if country == "Rwanda"
replace q6c_norm=. if country=="Rwanda"
replace q45d_G2_norm=. if country=="Rwanda"
replace q45e_G2_norm=. if country=="Rwanda"
replace q44_G2_norm=. if country=="Rwanda"
//Serbia
replace q18d_norm=. if country=="Serbia"
replace q18e_norm=. if country=="Serbia"
//Sierra Leone
replace q45d_G2_norm=. if country=="Sierra Leone"
replace q43_G1_norm=. if country == "Sierra Leone"
replace q44_G1_norm=. if country == "Sierra Leone"
//South Africa
replace q45a_G1_norm=. if country=="South Africa"
//Sri Lanka
replace q45d_G2_norm=. if country=="Sri Lanka"
replace q45e_G2_norm=. if country=="Sri Lanka"
*replace q45q_norm_2016=. if country=="Sri Lanka"
//Tanzania
replace q43_G1_norm=. if country=="Tanzania"
replace q45d_G2_norm=. if country=="Tanzania"
replace q45e_G2_norm=. if country=="Tanzania"
//Thailand
replace q45d_G2_norm=. if country=="Thailand"
replace q45e_G2_norm=. if country=="Thailand"
replace q45a_G2_norm=. if country=="Thailand"
replace q45e_G1_norm=. if country=="Thailand"
*replace q26c_norm_2017=. if country=="Thailand"
replace q43_G1_norm=. if country=="Thailand"
//Turkiye
replace q2a_norm=. if country=="Turkiye"
replace q45d_G2_norm=. if country=="Turkiye"
replace q45e_G2_norm=. if country=="Turkiye"
replace q46c_G1_norm=. if country=="Turkiye"
replace q46g_G2_norm=. if country=="Turkiye"
*replace q22a_norm_2017=. if country=="Turkiye"
replace q46h_G2_norm=. if country=="Turkiye"
replace q45b_G1_norm=. if country=="Turkiye"

//Zimbabwe
replace q45d_G2_norm=. if country=="Zimbabwe"


/*------*/
/* 2019 */
/*------*/

/* Second round adjustments */

/* Botswana */
replace q45d_G2_norm=. if country=="Botswana"

/* Hong Kong SAR, China */
replace q18b_norm=. if country=="Hong Kong SAR, China"
replace q18d_norm=. if country=="Hong Kong SAR, China"
/* Indonesia */
replace q18c_norm=. if country=="Indonesia"
replace q18d_norm=. if country=="Indonesia"
replace q18e_norm=. if country=="Indonesia"
/* Niger */
replace q6b_norm=. if country=="Niger"
replace q6c_norm=. if country=="Niger"
replace q45d_G2_norm=. if country=="Niger"
/* Pakistan */
replace q45b_G1_norm=. if country=="Pakistan"
replace q45a_G2_norm=. if country=="Pakistan"

/* Rwanda */
replace q6b_norm=. if country=="Rwanda"
/* Tanzania */
replace q44_G1_norm=. if country=="Tanzania"


/*------*/
/* 2021 */
/*------*/

*By Alicia and Natalia
replace q6a_norm=. if country == "Egypt, Arab Rep."



replace q2a_norm=. if country=="Paraguay"
replace q48c_G1_norm=. if country=="Philippines"


*By Alex
replace q43_G1_norm=. if country=="Benin"
replace q6b_norm=. if country=="Mozambique"

replace q2a_norm=. if country=="Sudan"
replace q44_G2_norm=. if country=="Sudan"
replace q45a_G2_norm=. if country=="Sudan"	
replace q45e_G1_norm=. if country=="Uzbekistan"


/*------*/
/* 2022 */
/*------*/

replace q9_norm=. if country=="Belize"
replace q18a_norm=. if country=="Belize"
replace q18b_norm=. if country=="Belize"
replace q18c_norm=. if country=="Belize"
replace q18d_norm=. if country=="Belize"
replace q18e_norm=. if country=="Belize"
replace q18f_norm=. if country=="Belize"
replace q18c_norm=. if country=="Egypt, Arab Rep."
replace q44_G1_norm=. if country=="Guatemala"
replace q45a_G1_norm=. if country=="Haiti"
replace q44_G1_norm=. if country=="Haiti"

replace q18c_norm=. if country=="Jordan"
replace q18d_norm=. if country=="Jordan"
replace q18e_norm=. if country=="Jordan"
replace q2a_norm=. if country=="Bolivia"
replace q45a_G2_norm=. if country=="Niger"

replace q45a_G1_norm=. if country=="Trinidad and Tobago"
replace q44_G2_norm=. if country=="Trinidad and Tobago"
replace q45a_G2_norm=. if country=="Trinidad and Tobago"
replace q7a_norm=. if country=="Trinidad and Tobago"
replace q7b_norm=. if country=="Trinidad and Tobago"
replace q7c_norm=. if country=="Trinidad and Tobago"
replace q46d_G1_norm=. if country=="Turkiye"
replace q6c_norm=. if country=="United Arab Emirates"


replace q6b_norm=. if country=="Nicaragua"
replace q6c_norm=. if country=="Nicaragua"
replace q2c_norm=. if country=="Argentina"
replace q44_G1_norm=. if country=="Argentina"
replace q44_G2_norm=. if country=="Ecuador"
replace q44_G1_norm=. if country=="Ecuador"
replace q2a_norm=. if country=="Ecuador"
replace q2g_norm=. if country=="Ecuador"
replace q2a_norm=. if country=="Bahamas"
replace q2d_norm=. if country=="Bahamas"
replace q44_G1_norm=. if country=="Bahamas"
replace q45a_G2_norm=. if country=="Barbados"
replace q44_G2_norm=. if country=="Brazil"
replace q44_G1_norm=. if country=="Brazil"
replace q18c_norm=. if country=="Dominica"
replace q18d_norm=. if country=="Dominica"
replace q44_G1_norm=. if country=="Dominica"
replace q45e_G1_norm=. if country=="Dominica"
replace q43_G1_norm=. if country=="Dominica"
replace q45b_G2_norm=. if country=="Grenada"
replace q18c_norm=. if country=="Grenada"
replace q18d_norm=. if country=="Grenada"
replace q18e_norm=. if country=="Grenada"
replace q45a_G1_norm=. if country=="Grenada"
replace q45b_G1_norm=. if country=="Grenada"
replace q45a_G2_norm=. if country=="Grenada"
replace q44_G1_norm=. if country=="St. Lucia"
replace q45b_G2_norm=. if country=="St. Lucia"
replace q46g_G1_norm=. if country=="St. Vincent and the Grenadines"
replace q45e_G2_norm=. if country=="St. Vincent and the Grenadines"
replace q46h_G2_norm=. if country=="St. Vincent and the Grenadines"
replace q45e_G1_norm=. if country=="St. Vincent and the Grenadines"
replace q45a_G2_norm=. if country=="Venezuela, RB"
replace q45b_G1_norm=. if country=="Venezuela, RB"

replace q45b_G1_norm=. if country=="Haiti"
replace q46f_G2_norm=. if country=="Russian Federation"
replace q46c_G1_norm=. if country=="Russian Federation"
replace q46a_G2_norm=. if country=="Russian Federation"

replace q6c_norm=. if country=="Sudan"
replace q7c_norm=. if country=="Sudan"

replace q45a_G2_norm=. if country=="Sri Lanka" //Not in the do file, but in the MAP
replace q46f_G2_norm=. if country=="Sri Lanka" //Not in the do file, but in the MAP
replace q46e_G1_norm=. if country=="Sri Lanka" //Not in the do file, but in the MAP
replace q46f_G1_norm=. if country=="Sri Lanka" //Not in the do file, but in the MAP


/*------*/
/* 2023 */
/*------*/

*replace q4a_norm=. if country=="Kuwait"
replace q4e_norm=. if country=="Kuwait"
replace q6a_norm=. if country=="Kuwait"
*replace q6b_norm=. if country=="Kuwait"
replace q6c_norm=. if country=="Kuwait"
replace q43_G1_norm=. if country=="Kuwait"
replace q44_G2_norm=. if country=="Kuwait"

replace q2a_norm=. if country=="North Macedonia" 
replace q45e_G1_norm=. if country=="North Macedonia" 
replace q45a_G1_norm=. if country=="North Macedonia" 
*---replace q44_G2_norm=. if country=="North Macedonia" // Alex //Fixed by Natalia to match the MAP
replace q45a_G1_norm=. if country=="Mali" // Alex
replace q45a_G2_norm=. if country=="Mali" // Alex
replace q45a_G1_norm=. if country=="Sudan" // Alex
replace q45b_G1_norm=. if country=="Sudan" // Alex
replace q46g_G2_norm=. if country=="Sudan" // Alex
replace q44_G2_norm=. if country=="Sudan" // Alex
replace q45a_G2_norm=. if country=="Sudan" // Alex

** From the Map but not in the do file - Added by Natalia
replace q45b_G1_norm=. if country=="Ethiopia"
replace q46c_G1_norm=. if country=="Ethiopia"


/*------*/
/* 2024 */
/*------*/

//Afghanistan
replace q46a_G2_norm=. if country=="Afghanistan" //Added by Alex
replace q46c_G1_norm=. if country=="Afghanistan" //Added by Alex
replace q46c_G2_norm=. if country=="Afghanistan" //Added by Alex
replace q46g_G2_norm=. if country=="Afghanistan" //Added by Alex


// Bulgaria
replace q6a_norm=. if country=="Bulgaria"
replace q2a_norm=. if country=="Bulgaria" //Added by Alex

//Burkina Faso
replace q45a_G1_norm=. if country=="Burkina Faso" //Added by Alex
replace q45a_G2_norm=. if country=="Burkina Faso" //Added by Alex
replace q46a_G2_norm=. if country=="Burkina Faso" //Added by Alex
replace q46c_G2_norm=. if country=="Burkina Faso" //Added by Alex
replace q46e_G2_norm=. if country=="Burkina Faso" //Added by Alex

//Cambodia
replace q46a_G2_norm=. if country=="Cambodia" //Added by Alex
replace q46f_G2_norm=. if country=="Cambodia" //Added by Alex

//Croatia
replace q2a_norm=. if country=="Croatia" //Added by Alex
replace q46d_G2_norm=. if country=="Croatia" //Added by Alex

//Denmark
replace q46c_G2_norm=. if country=="Denmark" //Added by Alex
replace q46d_G2_norm=. if country=="Denmark" //Added by Alex
replace q46g_G1_norm=. if country=="Denmark" //Added by Alex

//Estonia//
replace q43_G1_norm=. if country=="Estonia"

//France
replace q46c_G2_norm=. if country=="France" //Added by Alex
replace q46d_G2_norm=. if country=="France" //Added by Alex

//Germany
replace q46c_G2_norm=. if country=="Germany" //Added by Alex
replace q46d_G2_norm=. if country=="Germany" //Added by Alex

//Greece//
replace q43_G1_norm=. if country=="Greece"
replace q46c_G2_norm=. if country=="Greece" //Added by Alex
replace q2a_norm=. if country=="Greece" //Added by Alex

//Hungary
replace q18b_norm=. if country=="Hungary"
replace q18d_norm=. if country=="Hungary"
replace q6c_norm=. if country=="Hungary"
replace q43_G1_norm=. if country== "Hungary"
replace q46c_G2_norm=. if country=="Hungary" //Added by Alex


//Italy
replace q43_G1_norm =. if country == "Italy"

//Kazakhstan 
replace q6b_norm=. if country=="Kazakhstan" //Added by Alex

//Kuwait
replace q7b_norm=. if country=="Kuwait" //Added by Alex
replace q6b_norm=. if country=="Kuwait" //Added by Alex
replace q46f_G1_norm=. if country=="Kuwait" //Added by Alex
replace q46a_G2_norm=. if country=="Kuwait" //Added by Alex

//Latvia
replace q7b_norm=. if country=="Latvia" //Added by Alex

//Lithuania
replace q18a_norm=. if country=="Lithuania"
replace q2a_norm=. if country=="Lithuania" //Added by Natalia. Not in Alex' notes but in Map. Fixed to match the map

//Luxembourg
replace q18c_norm=. if country=="Luxembourg"
replace q18e_norm=. if country=="Luxembourg"
replace q46d_G2_norm=. if country=="Luxembourg" //Added by Alex

//Mali
replace q46g_G2_norm=. if country=="Mali" //Added by Alex
replace q46c_G1_norm=. if country=="Mali" //Added by Alex
replace q46a_G2_norm=. if country=="Mali" //Added by Alex
replace q46f_G1_norm=. if country=="Mali" //Added by Alex

//Pakistan
replace q46g_G2_norm=. if country=="Pakistan" //Added by Alex

//Poland
replace q45a_G2_norm=. if country == "Poland"
replace q6a_norm=. if country=="Poland"
replace q6c_norm=. if country=="Poland"
replace q46h_G2_norm=. if country=="Poland"
replace q43_G1_norm=. if country == "Poland"

//Slovenia
replace q2a_norm=. if country=="Slovenia" //Added by Alex
replace q46c_G2_norm=. if country=="Slovenia" //Added by Alex
replace q46d_G2_norm=. if country=="Slovenia" //Added by Alex

//Tunisia
replace q45a_G1_norm=. if country=="Tunisia" //Added by Alex
replace q45a_G2_norm=. if country=="Tunisia" //Added by Alex
replace q46g_G2_norm=. if country=="Tunisia" //Added by Alex
replace q46a_G2_norm=. if country=="Tunisia" //Added by Alex
replace q46c_G2_norm=. if country=="Tunisia" //Added by Alex







/*=================================================================================================================
					7. Final scores export
=================================================================================================================*/


drop combine_obs updated previous_year tag 
order country q43_G2_norm	q44_G1_norm	q44_G2_norm	q45a_G1_norm	q45a_G2_norm	q45b_G1_norm	q45b_G2_norm	q45d_G1_norm	q45c_G2_norm	q45e_G1_norm	q45d_G2_norm	q45e_G2_norm	q2a_norm	q2b_norm	q2c_norm	q2d_norm	q2g_norm	q18a_norm	q18b_norm	q18c_norm	q18d_norm	q18e_norm	q18f_norm	q6a_norm	q6b_norm	q6c_norm	q7a_norm	q7b_norm	q7c_norm	q4a_norm	q4e_norm	q9_norm	q48c_G1_norm	q48d_G1_norm	q46a_G2_norm	q46b_G1_norm	q46b_G2_norm	q46c_G1_norm	q46c_G2_norm	q46d_G2_norm	q46e_G2_norm	q46d_G1_norm	q46f_G2_norm	q46e_G1_norm	q46g_G2_norm	q46f_G1_norm	q46h_G2_norm	q46g_G1_norm	q46h_G1_norm	q43_G1_norm

sort country


*------ Adding final scores for Uzbekistan (Done in excel)
drop if country=="Uzbekistan"

append using "$path2data\Problematic countries\Uzbekistan_index.dta"

sort country

replace country ="Côte d'Ivoire" if country=="Cote d'Ivoire"
replace country="The Bahamas" if country=="Bahamas"
replace country="The Gambia" if country=="Gambia"

*------ Saving final dataset
save "${path2SP}\Data Analytics\7. WJP ROLI\ROLI_2024\1. Cleaning\GPP\1. Data\country_averages.dta", replace

br

