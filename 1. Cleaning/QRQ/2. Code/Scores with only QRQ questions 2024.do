/*=================================================================================================================
Project:		Global Rule of Law Index
Routine:		Scores with only QRQ questions 2024
Author(s):		Natalia Rodriguez (nrodriguez@worldjusticeproject.org)
Dependencies:  	World Justice Project
Creation Date:	March, 2025

Description:
This routine creates the scores using only QRQ data. It uses the final output from the QRQ cleaning routing (post review)

=================================================================================================================*/

clear
set more off, perm
cls

/*=================================================================================================================
					Pre-settings
=================================================================================================================*/

*--- Stata Version
*version 15

*--- Required packages:
* NONE

*--- Defining paths to SharePoint & your local Git Repo copy:

*------ (a) Natalia Rodriguez:
if (inlist("`c(username)'", "nrodriguez")) {
	global path2SP "C:\Users\nrodriguez\OneDrive - World Justice Project\Programmatic\Data Analytics\7. WJP ROLI\ROLI_2024\1. Cleaning\QRQ"
	global path2GH "C:\Users\nrodriguez\OneDrive - World Justice Project\Natalia\GitHub\ROLI_2024\1. Cleaning\QRQ"
	
	*global path2data "C:\Users\nrodriguez\OneDrive - World Justice Project\Programmatic\QRQ\QRQ 2024\Final Data\excel"
	*global path2exp  "C:\Users\nrodriguez\OneDrive - World Justice Project\Programmatic\Index Data & Analysis\2024\QRQ"
	*global path2dos  "C:\Users\nrodriguez\OneDrive - World Justice Project\Programmatic\QRQ do files\2024"
}


*--- Defining path to Data and DoFiles:

**Path2data: Path to original exports from Alchemer by QRQ team. 
global path2data "${path2SP}\1. Data"

**Path2exp: Path to folder with final datasets (QRQ.dta and qrq_country_averages.dta". 

**Path 2dos: Path to do-files (Routines). 
global path2dos  "${path2GH}\2. Code"

/*=================================================================================================================
					I. Calculating Index Scores
=================================================================================================================*/


*Open the database with the country averages 
use "$path2data\3. Final\qrq_country_averages_2024.dta", clear

*Create scores
do "${path2dos}\Routines\scores.do"

save "$path2data\3. Final\qrq_scores_2024_final.dta", replace


br country f_1 f_1_2 f_1_3 f_1_4 f_1_5 f_1_6 f_1_7 ///
f_2 f_2_1 f_2_2 f_2_3 f_2_4 ///
f_3 f_3_1 f_3_2 f_3_3 f_3_4 ///
f_4 f_4_1 f_4_2 f_4_3 f_4_4 f_4_5 f_4_6 f_4_7 f_4_8 ///
f_5 f_5_3 ///
f_6 f_6_1 f_6_2 f_6_3 f_6_4 f_6_5 ///
f_7 f_7_1 f_7_2 f_7_3  f_7_4 f_7_5 f_7_6 f_7_7 ///
f_8 f_8_1 f_8_2 f_8_3 f_8_4 f_8_5 f_8_6 f_8_7 ///
f_1 f_2 f_3 f_4 f_5 f_6 f_7 f_8 ROL 





















