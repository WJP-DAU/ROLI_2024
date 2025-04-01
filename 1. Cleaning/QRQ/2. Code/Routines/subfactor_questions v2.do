/*=================================================================================================================
Project:		Global ROLI QRQ cleaning and analysis
Routine:		Questions in sub-factors
Author(s):		Natalia Rodriguez 	(nrodriguez@worldjusticeproject.org)
Dependencies:  	World Justice Project
Creation Date:	March, 2025

Description:
This routine will generate each XXX

=================================================================================================================*/


* Change the delimitation for each command, to allow better understanding of the do file. 
*After this point all the commmands need to finish with a  " ; "
#delimit ;

*                                   Factor 1 ; 

global f_1_2 "all_q1_norm
all_q2_norm
all_q20_norm
all_q21_norm" ; 

global f_1_3 "
all_q2_norm
all_q3_norm
cc_q25_norm
all_q4_norm
all_q5_norm
all_q6_norm
all_q7_norm
all_q8_norm" ; 

global f_1_4 "
cc_q33_norm
all_q9_norm
cj_q38_norm
cj_q36c_norm
cj_q8_norm" ; 

global f_1_5_1 "
all_q52_norm
all_q53_norm
all_q93_norm" ; 

global f_1_5_2 "
all_q10_norm
all_q11_norm" ; 

global f_1_5_3 " 
all_q12_norm" ; 

global f_1_5_4 "
cj_q36b_norm
cj_q36a_norm
cj_q9_norm
cj_q8_norm" ; 

global f_1_5 "f_1_5_1 f_1_5_2 f_1_5_3 f_1_5_4" ;

global f_1_6_1 "
all_q13_norm
all_q14_norm" ; 

global f_1_6_2 "
all_q15_norm
all_q16_norm
all_q17_norm
cj_q10_norm
all_q18_norm
all_q94_norm" ; 

global f_1_6_3_A "
all_q19_norm" ; 

global f_1_6_3_B "
all_q20_norm
all_q21_norm" ; 

global f_1_6_3 "f_1_6_3*" ;  


global f_1_6 "f_1_6_1 f_1_6_2 f_1_6_3" ;

global f_1_7_A "
all_q23_norm"; 

global f_1_7_B "
all_q27_norm" ; 

global f_1_7 "
all_q22_norm
all_q24_norm
all_q25_norm
all_q26_norm
all_q8_norm
f_1_7_A
f_1_7_B"; 

*                                   Factor 2 ; 

global f_2_1_1_A "
cc_q27_norm
all_q97_norm" ; 

global f_2_1_1_B "
ph_q5a_norm
ph_q5b_norm
ph_q7_norm " ; 

global f_2_1_1 "f_2_1_1_*" ; 


global f_2_1_2_1_A "
cc_q28a_norm
cc_q28b_norm
cc_q28c_norm
cc_q28d_norm
all_q56_norm
lb_q17e_norm
lb_q17c_norm
ph_q8d_norm" ; 

global f_2_1_2_1 "f_2_1_2_1_*" ; 

global f_2_1_2_2_A "
lb_q17b_norm
ph_q8c_norm
ph_q8e_norm
ph_q8g_norm
ph_q9d_norm
ph_q11b_norm
ph_q11c_norm
ph_q12a_norm
ph_q12b_norm
ph_q12c_norm
ph_q12d_norm
ph_q12e_norm" ; 
 
global f_2_1_2_2 "f_2_1_2_2_*" ; 

global f_2_1_2_3 "
all_q54_norm
all_q55_norm" ; 

global f_2_1_2 "f_2_1_2_1 f_2_1_2_2 f_2_1_2_3" ; 
 
global f_2_1_3 "
all_q95_norm" ; 

global f_2_1 "f_2_1_1 f_2_1_2 f_2_1_3" ; 

global f_2_2_1 "
all_q57_norm
all_q58_norm
all_q59_norm
all_q60_norm
cc_q26h_norm
cc_q28e_norm
lb_q6c_norm  " ; 

global f_2_2_2 "
cj_q32b_norm
all_q28_norm
all_q6_norm
cj_q24b_norm
cj_q24c_norm
cj_q33a_norm
cj_q33b_norm
cj_q33c_norm
cj_q33d_norm
cj_q33e_norm" ;

global f_2_2 "f_2_2_1 f_2_2_2" ; 
 
global f_2_3_A " 
cj_q32c_norm
cj_q32d_norm
all_q61_norm
cj_q31a_norm
cj_q31b_norm
cj_q34a_norm
cj_q34b_norm
cj_q34c_norm
cj_q34d_norm
cj_q34e_norm
cj_q16j_norm
cj_q18a_norm" ; 

global f_2_3 "f_2_3_*" ; 

global f_2_4 "
all_q96_norm" ; 

*                                Factor 3 ; 

global f_3_1_1 "
all_q33_norm
all_q34_norm
all_q35_norm
all_q36_norm
all_q37_norm
all_q38_norm
cc_q32h_norm
cc_q32i_norm" ; 

global f_3_1 "f_3_1_*" ; 

global f_3_2_2 " 
cc_q9b_norm
cc_q39a_norm "; 

global f_3_2_3 " 
cc_q39b_norm " ; 

global f_3_2_4 " 
cc_q39d_norm " ; 

global f_3_2_5 "
cc_q39c_norm
cc_q39e_norm " ; 

global f_3_2_6 " 
all_q40_norm
all_q41_norm
all_q42_norm
all_q43_norm
all_q44_norm
all_q45_norm
all_q46_norm
all_q47_norm " ; 

global f_3_2 " f_3_2_*" ; 

global f_3_3_1_A_1 "
all_q13_norm
all_q14_norm" ; 

global f_3_3_1_A "f_3_3_1_A_* " ; 

global f_3_3_1_B_1 " 
all_q15_norm
all_q16_norm
all_q17_norm
cj_q10_norm
all_q18_norm
all_q94_norm" ; 

global f_3_3_1_B "f_3_3_1_B_*" ; 

global f_3_3_1_C_1 " 
all_q19_norm"; 

global f_3_3_1_C_2 " 
all_q20_norm
all_q21_norm" ; 

global f_3_3_1_C " f_3_3_1_C_1 f_3_3_1_C_2" ; 

global f_3_3_1 " f_3_3_1_A f_3_3_1_B f_3_3_1_C " ; 

global f_3_3_2_1 " 
all_q19_norm
all_q31_norm
all_q32_norm
all_q14_norm" ; 

global f_3_3_2 " f_3_3_2_*" ; 

global f_3_3_3 " 
cc_q9a_norm
cc_q11b_norm
cc_q32j_norm
all_q105_norm " ; 

global f_3_3 " f_3_3_1 f_3_3_2 f_3_3_3  "; 
 
global f_3_4 "
cc_q9c_norm 
cc_q40a_norm 
cc_q40b_norm" ; 


*                                  Factor 4 ; 

global f_4_1_1_A "
cj_q12a_norm" ; 

global f_4_1_1 "
all_q76_norm
lb_q16a_norm
ph_q6a_norm
f_4_1_1_A " ; 

global f_4_1_2_A "
cj_q12b_norm" ; 

global f_4_1_2 "
all_q77_norm
lb_q16b_norm
ph_q6b_norm
f_4_1_2_A " ; 

global f_4_1_3_A "
cj_q12c_norm" ; 

global f_4_1_3 "
all_q78_norm
lb_q16c_norm
ph_q6c_norm
f_4_1_3_A "; 

global f_4_1_4_A "
cj_q12d_norm" ; 

global f_4_1_4 "
all_q79_norm
lb_q16d_norm
ph_q6d_norm
f_4_1_4_A "; 

global f_4_1_5_A "
cj_q12e_norm" ; 

global f_4_1_5 "
all_q80_norm
lb_q16e_norm
ph_q6e_norm
f_4_1_5_A" ; 

global f_4_1_6_A "
cj_q12f_norm"; 

global f_4_1_6 "
all_q81_norm
lb_q16f_norm
ph_q6f_norm
f_4_1_6_A " ; 

global f_4_1 "f_4_1_1 f_4_1_2 f_4_1_3 f_4_1_4 f_4_1_5 f_4_1_6 " ; 

global f_4_2 "
cj_q11a_norm
cj_q11b_norm
cj_q31e_norm
cj_q42c_norm
cj_q42d_norm
cj_q10_norm"; 

global f_4_3_1 "
cj_q22d_norm
cj_q22b_norm
cj_q25b_norm
cj_q25c_norm
cj_q25a_norm
cj_q31c_norm
cj_q31d_norm
cj_q22e_norm" ; 

global f_4_3_2_1 "
cj_q6a_norm
cj_q6b_norm
cj_q6c_norm
cj_q6d_norm
cj_q29a_norm
cj_q29b_norm
cj_q42c_norm
cj_q42d_norm
cj_q22a_norm" ; 

global f_4_3_2 "
f_4_3_2_1"; 

global f_4_3_3 "
cj_q1_norm
cj_q2_norm
cj_q11a_norm
cj_q22c_norm"; 

global f_4_3_4 "
cj_q3a_norm
cj_q3b_norm
cj_q3c_norm
cj_q19a_norm
cj_q19b_norm
cj_q19c_norm
cj_q19e_norm
cj_q4_norm"; 

global f_4_3_5 "
cj_q21a_norm
cj_q21b_norm
cj_q21c_norm
cj_q21d_norm
cj_q21f_norm"; 

global f_4_3 "f_4_3_1 f_4_3_2 f_4_3_3 f_4_3_4 f_4_3_5 " ; 

global f_4_4_1_A "
all_q13_norm
all_q14_norm" ; 

global f_4_4_1 "
f_4_4_1_A" ; 

global f_4_4_2_A "
all_q15_norm
all_q16_norm
all_q17_norm
cj_q10_norm
all_q18_norm
all_q94_norm" ; 

global f_4_4_2 "f_4_4_2_*" ; 

global f_4_4_3_A "
all_q19_norm" ; 

global f_4_4_3_B "
all_q20_norm
all_q21_norm" ; 

global f_4_4_3_C "
f_4_4_3_B"; 


global f_4_4_3 "f_4_4_3_A f_4_4_3_C " ; 

global f_4_4 "f_4_4_1 f_4_4_2 f_4_4_3 " ; 

global f_4_5_A "
all_q29_norm" ; 

global f_4_5_B "
all_q30_norm";

global f_4_5 "f_4_5_*" ; 


global f_4_6 "
cj_q31f_norm
cj_q31g_norm
cj_q42c_norm
cj_q42d_norm"; 

global f_4_7_A "
all_q19_norm
all_q31_norm
all_q32_norm
all_q14_norm" ; 

global f_4_7 "f_4_7_*" ; 


global f_4_8_1_A "
lb_q16a_norm
lb_q16b_norm
lb_q16c_norm
lb_q16d_norm
lb_q16e_norm
lb_q16f_norm" ; 

global f_4_8_1 "
f_4_8_1_A"; 

global f_4_8_2_A "
lb_q23a_norm
lb_q23b_norm
lb_q23c_norm
lb_q23d_norm
lb_q23e_norm" ; 

global f_4_8_2 "
f_4_8_2_A" ; 

global f_4_8_3 "
lb_q23f_norm
lb_q23g_norm"; 

global f_4_8 "f_4_8_1 f_4_8_2 f_4_8_3 " ; 

* 									Factor 5 ; 

global f_5_3 " 
cj_q15_norm" ; 

* 								Factor 6 ; 


global f_6_1_1_A "
lb_q8_norm
lb_q9_norm
lb_q22_norm
lb_q15a_norm
lb_q15b_norm
lb_q15c_norm
lb_q15d_norm
lb_q15e_norm
lb_q18a_norm
lb_q18b_norm
lb_q18c_norm" ; 

global f_6_1_1 "
f_6_1_1_A"; 

global f_6_1_2_A "
cc_q1_norm
cc_q29a_norm
cc_q29b_norm
cc_q29c_norm" ; 

global f_6_1_2 "
f_6_1_2_A" ; 

global f_6_1_3 "
ph_q3_norm
ph_q4a_norm
ph_q4b_norm
ph_q4c_norm
ph_q9a_norm
ph_q9b_norm
ph_q9c_norm"; 

global f_6_1 "f_6_1_1 f_6_1_2 f_6_1_3";  

global f_6_2_1_A "
all_q54_norm
all_q55_norm" ; 

global f_6_2_1 "
f_6_2_1_A"; 

global f_6_2_2_1_A "
cc_q28a_norm
cc_q28b_norm
cc_q28c_norm
cc_q28d_norm
all_q56_norm
lb_q17e_norm
lb_q17c_norm
ph_q8d_norm" ; 

global f_6_2_2_1 "f_6_2_2_1_*" ; 

global f_6_2_2_2_A "
lb_q17b_norm
ph_q8a_norm
ph_q8b_norm
ph_q8c_norm
ph_q8e_norm
ph_q8f_norm
ph_q8g_norm
ph_q9d_norm
ph_q11a_norm
ph_q11b_norm
ph_q11c_norm
ph_q12a_norm
ph_q12b_norm
ph_q12c_norm
ph_q12d_norm
ph_q12e_norm" ; 

global f_6_2_2_2 "f_6_2_2_2_*" ; 

global f_6_2_2 "f_6_2_2_1 f_6_2_2_2 " ; 

global f_6_2 "f_6_2_1 f_6_2_2 ";

global f_6_3_A "
lb_q2d_norm
lb_q3d_norm" ; 

global f_6_3 "
f_6_3_A
all_q62_norm
all_q63_norm"; 


global f_6_4 "
all_q48_norm
all_q49_norm
all_q50_norm
lb_q19a_norm"; 

global f_6_5_1 "
cc_q10_norm
cc_q11a_norm
cc_q16a_norm"; 
 

global f_6_5_2 "
cc_q14a_norm
cc_q14b_norm
cc_q16b_norm
cc_q16c_norm
cc_q16d_norm
cc_q16e_norm
cc_q16f_norm
cc_q16g_norm"; 

global f_6_5 "f_6_5_1 f_6_5_2" ;  





* 											Factor 7 ; 
global f_7_1_1 "
all_q92_norm
cj_q26_norm
all_q75_norm"; 

global f_7_1_2 "
all_q65_norm
cc_q22a_norm
cc_q22b_norm
cc_q22c_norm"; 

global f_7_1_3 "
cc_q12_norm
all_q74_norm
all_q75_norm"; 

global f_7_1_4 "
all_q69_norm
all_q70_norm"; 

global f_7_1_5_A "
all_q71_norm
all_q72_norm" ; 

global f_7_1_5 "f_7_1_5_*"; 


global f_7_1 "f_7_1_1 f_7_1_2 f_7_1_3 f_7_1_4 f_7_1_5  " ; 

global f_7_2 "
all_q76_norm
all_q77_norm
all_q78_norm
all_q79_norm
all_q80_norm
all_q81_norm
all_q82_norm"; 


global f_7_3_1 " 
all_q57_norm
all_q58_norm
all_q59_norm
all_q83_norm
cc_q26h_norm
cc_q28e_norm
lb_q6c_norm"; 




global f_7_3_2_A "
all_q51_norm
all_q28_norm" ; 

global f_7_3_2 "
f_7_3_2_A"; 

global f_7_3 "f_7_3_1 f_7_3_2 ";  

global f_7_4_A "
cc_q11a_norm"; 

global f_7_4 "
all_q6_norm
all_q3_norm
all_q4_norm
all_q7_norm 
f_7_4_A" ; 


global f_7_5_1 " 
all_q84_norm
all_q85_norm
cc_q13_norm" ; 

global f_7_5_2 " 
all_q88_norm
cc_q26a_norm" ; 

global f_7_5 "f_7_5_*" ; 

global f_7_6_1 "
cc_q26b_norm"; 

global f_7_6_2 "
all_q86_norm
all_q87_norm"; 

global f_7_6 "f_7_6_*" ; 


global f_7_7_1 " 
all_q89_norm" ; 


global f_7_7_3 "
all_q59_norm"; 

global f_7_7_4 " 
all_q90_norm
all_q91_norm"; 

global f_7_7_5 " 
cc_q14a_norm
cc_q14b_norm"; 
 
global f_7_7 "f_7_7_*" ; 



* 										Factor 8   ; 

global f_8_1_1_A "
cj_q16a_norm
cj_q16b_norm
cj_q16c_norm
cj_q16d_norm
cj_q16e_norm
cj_q16f_norm
cj_q16g_norm
cj_q16h_norm
cj_q16i_norm
cj_q16j_norm
cj_q16k_norm
cj_q16l_norm
cj_q16m_norm
cj_q18a_norm
cj_q18b_norm
cj_q18c_norm
cj_q18e_norm
cj_q18d_norm" ; 

global f_8_1_1_B "
cj_q25a_norm
cj_q25b_norm
cj_q25c_norm"; 

global f_8_1_1 "f_8_1_1_*" ; 


global f_8_1 "f_8_1_1" ; 


global f_8_2_1 "
cj_q27a_norm
cj_q27b_norm
cj_q7a_norm
cj_q7b_norm
cj_q7c_norm
cj_q20a_norm
cj_q20b_norm"; 

global f_8_2_2_A "
cj_q20e_norm" ; 

global f_8_2_2 "f_8_2_2_*" ; 

global f_8_2 "f_8_2_1 f_8_2_2 " ; 

global f_8_3 "
cj_q21a_norm
cj_q21e_norm
cj_q21g_norm
cj_q21h_norm
cj_q28_norm"; 


global f_8_4_1_A "
cj_q12a_norm
cj_q12b_norm
cj_q12c_norm
cj_q12d_norm
cj_q12e_norm
cj_q12f_norm" ; 

global f_8_4_1 "f_8_4_1_*"; 

global f_8_4_2 " 
cj_q20o_norm"; 

global f_8_4 "f_8_4_1 f_8_4_2 " ; 


global f_8_5_1_A "
cj_q32c_norm
cj_q32d_norm
cj_q31a_norm
cj_q31b_norm
cj_q34a_norm
cj_q34b_norm
cj_q34c_norm
cj_q34d_norm
cj_q34e_norm
cj_q33a_norm
cj_q33b_norm
cj_q33c_norm
cj_q33d_norm
cj_q33e_norm
cj_q16j_norm
cj_q18a_norm
cj_q18d_norm"; 

global f_8_5_1 "f_8_5_1_*"; 


global f_8_5_2_A " 
cj_q32b_norm
cj_q20k_norm
cj_q24b_norm
cj_q24c_norm" ; 

global f_8_5_2 " f_8_5_2_*"; 


global f_8_5 "f_8_5_1 f_8_5_2" ; 

global f_8_6 "
cj_q40b_norm
cj_q40c_norm
cj_q20m_norm"; 


global f_8_7_1 "
cj_q22d_norm
cj_q22b_norm
cj_q25b_norm
cj_q25c_norm
cj_q25a_norm
cj_q31c_norm
cj_q31d_norm
cj_q22e_norm"; 

global f_8_7_2_A " 
cj_q6a_norm
cj_q6b_norm
cj_q6c_norm
cj_q6d_norm
cj_q29a_norm
cj_q29b_norm
cj_q42c_norm
cj_q42d_norm
cj_q22a_norm";

global f_8_7_2 " 
f_8_7_2_A";  


global f_8_7_3 " 
cj_q1_norm
cj_q2_norm
cj_q11a_norm
cj_q22c_norm"; 

global f_8_7_4 "
cj_q3a_norm
cj_q3b_norm
cj_q3c_norm
cj_q19a_norm
cj_q19b_norm
cj_q19c_norm
cj_q19e_norm
cj_q4_norm"; 

global f_8_7_5 " 
cj_q21a_norm
cj_q21b_norm
cj_q21c_norm
cj_q21d_norm
cj_q21f_norm"; 

global f_8_7 "f_8_7_1 f_8_7_2 f_8_7_3 f_8_7_4 f_8_7_5" ;

#delimit cr

