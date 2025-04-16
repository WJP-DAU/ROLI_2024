clear
set more off, perm
cd "C:\Users\nrodriguez\OneDrive - World Justice Project\Programmatic\Index Third Party Sources\2024 Index\Quantitative Checks\TPS\2024 scores"

use "TPS index", replace

keep country country battle_deaths_2023_norm casualties_one_sided_2023_norm

** Battle Related Deaths
/* Methodology:
0-9=1
10-250=.75
251-500=.5
501-1,000=.25
>1,000=0 
*/

gen battle_deaths_2023=.
replace battle_deaths_2023=1 if battle_deaths_2023_norm<10 & battle_deaths_2023_norm!=.
replace battle_deaths_2023=0.75 if battle_deaths_2023_norm>=10 & battle_deaths_2023_norm<=250
replace battle_deaths_2023=0.5 if battle_deaths_2023_norm>=251 & battle_deaths_2023_norm<=500
replace battle_deaths_2023=0.25 if battle_deaths_2023_norm>=501 & battle_deaths_2023_norm<=1000
replace battle_deaths_2023=0 if battle_deaths_2023_norm>=1001

** One-Sided Casualties
/*
Methodology:
0=1
1-25=.9
26-50=.8
51-75=.7
76-100=.6
101-125=.5
126-150=.4
151-175=.3
176-200=.2
201-225=.1
>225=0
*/

** Proposed version of indicator for casualites
gen casualties_one_sided_2023=1 if casualties_one_sided_2023_norm==0
replace casualties_one_sided_2023=0.9 if casualties_one_sided_2023_norm>=1 & casualties_one_sided_2023_norm<=25
replace casualties_one_sided_2023=0.8 if casualties_one_sided_2023_norm>=26 & casualties_one_sided_2023_norm<=50
replace casualties_one_sided_2023=0.7 if casualties_one_sided_2023_norm>=51 & casualties_one_sided_2023_norm<=75
replace casualties_one_sided_2023=0.6 if casualties_one_sided_2023_norm>=76 & casualties_one_sided_2023_norm<=100
replace casualties_one_sided_2023=0.5 if casualties_one_sided_2023_norm>=101 & casualties_one_sided_2023_norm<=125
replace casualties_one_sided_2023=0.4 if casualties_one_sided_2023_norm>=126 & casualties_one_sided_2023_norm<=150
replace casualties_one_sided_2023=0.3 if casualties_one_sided_2023_norm>=151 & casualties_one_sided_2023_norm<=175
replace casualties_one_sided_2023=0.2 if casualties_one_sided_2023_norm>=176 & casualties_one_sided_2023_norm<=200
replace casualties_one_sided_2023=0.1 if casualties_one_sided_2023_norm>=201 & casualties_one_sided_2023_norm<=225
replace casualties_one_sided_2023=0 if casualties_one_sided_2023_norm>=226


** For this year's Map
br country battle_deaths_2023 casualties_one_sided_2023
