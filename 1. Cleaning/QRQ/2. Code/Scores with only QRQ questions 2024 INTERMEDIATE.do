/*=================================================================================================================
Project:		QRQ 2024
Routine:		QRQ scores intermediate (master do file)
Author(s):		Natalia Rodriguez (nrodriguez@worldjusticeproject.org)
Dependencies:  	World Justice Project
Creation Date:	May, 2025

Description:
This routine will create the factor, sub-factor and other scores using ONLY the QRQ Global ROLI data.
The data used in this code is the INTERMEDIATE data from 2024, corresponding to Map 2 - 8_28_24

=================================================================================================================*/

/*=================================================================================================================
					Pre-settings
=================================================================================================================*/


*--- Stata Version
*version 15

*--- Required packages:
* NONE

*--- Years of analysis
global year_current "2024"
global year_previous "2023"

*--- Defining paths to SharePoint & your local Git Repo copy:

*------ (a) Natalia Rodriguez:
if (inlist("`c(username)'", "nrodriguez")) {
	global path2SP "C:\Users\nrodriguez\OneDrive - World Justice Project\Programmatic\Data Analytics\7. WJP ROLI\ROLI_${year_current}\1. Cleaning\QRQ"
	global path2GH "C:\Users\nrodriguez\OneDrive - World Justice Project\Natalia\GitHub\ROLI_${year_current}\1. Cleaning\QRQ"
	
	*global path2data "C:\Users\nrodriguez\OneDrive - World Justice Project\Programmatic\QRQ\QRQ 2024\Final Data\excel"
	*global path2exp  "C:\Users\nrodriguez\OneDrive - World Justice Project\Programmatic\Index Data & Analysis\2024\QRQ"
	*global path2dos  "C:\Users\nrodriguez\OneDrive - World Justice Project\Programmatic\QRQ do files\2024"
}


*--- Defining path to Data and DoFiles:

*Path2data: Path to original exports from Alchemer by QRQ team. 
global path2data "${path2SP}\1. Data"

*Path2exp: Path to folder with final datasets (QRQ.dta and qrq_country_averages.dta". 

*Path 2dos: Path to do-files (Routines). 
global path2dos  "${path2GH}\2. Code"


/*=================================================================================================================
					IX. Country Averages
=================================================================================================================*/

clear all
cls

*Importing final question averages from MAP
import excel "$path2data\3. Final\qrq_scores_int_2024.xlsx", sheet("Sheet2") firstrow


*Create scores
do "${path2dos}\Routines\scores.do"

*Saving final dataset
save "$path2data\3. Final\qrq_country_averages_${year_current}_int.dta", replace



