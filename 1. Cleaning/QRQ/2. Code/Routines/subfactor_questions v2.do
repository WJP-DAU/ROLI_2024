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

*1.2 ;
global f_1_2 "
all_q1_norm
all_q2_norm
all_q20_norm
all_q21_norm" ; 


*1.3 ;
global f_1_3 "
all_q2_norm
all_q3_norm
cc_q25_norm
all_q4_norm
all_q5_norm
all_q6_norm
all_q7_norm
all_q8_norm" ; 


*1.4 ;
global f_1_4 "
cc_q33_norm
all_q9_norm
cj_q38_norm
cj_q36c_norm
cj_q8_norm" ; 


*1.5 ;
global f_1_5 "
all_q52_norm
all_q53_norm
all_q93_norm

all_q10_norm
all_q11_norm 

all_q12_norm

cj_q36b_norm
cj_q36a_norm
cj_q9_norm
cj_q8_norm" ; 


*1.6 ;
global f_1_6 "
all_q13_norm
all_q14_norm

all_q15_norm
all_q16_norm
all_q17_norm
cj_q10_norm
all_q18_norm
all_q94_norm

all_q19_norm

all_q20_norm
all_q21_norm" ; 


*1.7 ;
global f_1_7 "
all_q23_norm 

all_q27_norm

all_q22_norm
all_q24_norm
all_q25_norm
all_q26_norm
all_q8_norm"; 



*                                   Factor 2 ; 


*2.1 ;
global f_2_1 "
cc_q27_norm
all_q97_norm

ph_q5a_norm
ph_q5b_norm
ph_q7_norm

cc_q28a_norm
cc_q28b_norm
cc_q28c_norm
cc_q28d_norm
all_q56_norm
lb_q17e_norm
lb_q17c_norm
ph_q8d_norm

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
ph_q12e_norm
 
all_q54_norm
all_q55_norm

all_q95_norm" ; 


*2.2 ;
global f_2_2 "
all_q57_norm
all_q58_norm
all_q59_norm
all_q60_norm
cc_q26h_norm
cc_q28e_norm
lb_q6c_norm 

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
 

*2.3 ; 
global f_2_3 " 
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


*2.4 ;
global f_2_4 "
all_q96_norm" ; 



*                                Factor 3 ; 

*3.1 ;
global f_3_1 "
all_q33_norm
all_q34_norm
all_q35_norm
all_q36_norm
all_q37_norm
all_q38_norm
cc_q32h_norm
cc_q32i_norm" ; 


*3.2 ;
global f_3_2 " 
cc_q9b_norm
cc_q39a_norm

cc_q39b_norm

cc_q39d_norm

cc_q39c_norm
cc_q39e_norm 

all_q40_norm
all_q41_norm
all_q42_norm
all_q43_norm
all_q44_norm
all_q45_norm
all_q46_norm
all_q47_norm " ; 


*3.3 ;
global f_3_3 "
all_q13_norm
all_q14_norm

all_q15_norm
all_q16_norm
all_q17_norm
cj_q10_norm
all_q18_norm
all_q94_norm

all_q19_norm

all_q20_norm
all_q21_norm

all_q19_norm
all_q31_norm
all_q32_norm
all_q14_norm

cc_q9a_norm
cc_q11b_norm
cc_q32j_norm
all_q105_norm " ; 


*3.4 ;
global f_3_4 "
cc_q9c_norm 
cc_q40a_norm 
cc_q40b_norm" ; 



*                                  Factor 4 ; 


*4.1 ;
global f_4_1 "
cj_q12a_norm 

all_q76_norm
lb_q16a_norm
ph_q6a_norm

cj_q12b_norm

all_q77_norm
lb_q16b_norm
ph_q6b_norm

cj_q12c_norm

all_q78_norm
lb_q16c_norm
ph_q6c_norm

cj_q12d_norm

all_q79_norm
lb_q16d_norm
ph_q6d_norm

cj_q12e_norm

all_q80_norm
lb_q16e_norm
ph_q6e_norm

cj_q12f_norm

all_q81_norm
lb_q16f_norm
ph_q6f_norm" ; 


*4.2 ;
global f_4_2 "
cj_q11a_norm
cj_q11b_norm
cj_q31e_norm
cj_q42c_norm
cj_q42d_norm
cj_q10_norm"; 


*4.3 ;
global f_4_3 "
cj_q22d_norm
cj_q22b_norm
cj_q25b_norm
cj_q25c_norm
cj_q25a_norm
cj_q31c_norm
cj_q31d_norm
cj_q22e_norm

cj_q6a_norm
cj_q6b_norm
cj_q6c_norm
cj_q6d_norm
cj_q29a_norm
cj_q29b_norm
cj_q42c_norm
cj_q42d_norm
cj_q22a_norm

cj_q1_norm
cj_q2_norm
cj_q11a_norm
cj_q22c_norm

cj_q3a_norm
cj_q3b_norm
cj_q3c_norm
cj_q19a_norm
cj_q19b_norm
cj_q19c_norm
cj_q19e_norm
cj_q4_norm

cj_q21a_norm
cj_q21b_norm
cj_q21c_norm
cj_q21d_norm
cj_q21f_norm"; 


*4.4 ;
global f_4_4 "
all_q13_norm
all_q14_norm

all_q15_norm
all_q16_norm
all_q17_norm
cj_q10_norm
all_q18_norm
all_q94_norm

all_q19_norm

all_q20_norm
all_q21_norm" ; 


*4.5 ;
global f_4_5 "
all_q29_norm

all_q30_norm";


*4.6 ;
global f_4_6 "
cj_q31f_norm
cj_q31g_norm
cj_q42c_norm
cj_q42d_norm"; 


*4.7 ;
global f_4_7 "
all_q19_norm
all_q31_norm
all_q32_norm
all_q14_norm" ; 


*4.8 ;
global f_4_8 "
lb_q16a_norm
lb_q16b_norm
lb_q16c_norm
lb_q16d_norm
lb_q16e_norm
lb_q16f_norm

lb_q23a_norm
lb_q23b_norm
lb_q23c_norm
lb_q23d_norm
lb_q23e_norm

lb_q23f_norm
lb_q23g_norm"; 



* 									Factor 5 ; 

*5.3 ;
global f_5_3 " 
cj_q15_norm" ; 


* 								Factor 6 ; 


*6.1 ;
global f_6_1 "
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
lb_q18c_norm

cc_q1_norm
cc_q29a_norm
cc_q29b_norm
cc_q29c_norm 

ph_q3_norm
ph_q4a_norm
ph_q4b_norm
ph_q4c_norm
ph_q9a_norm
ph_q9b_norm
ph_q9c_norm"; 


*6.2 ;
global f_6_2 "
all_q54_norm
all_q55_norm

cc_q28a_norm
cc_q28b_norm
cc_q28c_norm
cc_q28d_norm
all_q56_norm
lb_q17e_norm
lb_q17c_norm
ph_q8d_norm

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


*6.3 ;
global f_6_3 "
lb_q2d_norm
lb_q3d_norm

all_q62_norm
all_q63_norm"; 


*6.4 ;
global f_6_4 "
all_q48_norm
all_q49_norm
all_q50_norm
lb_q19a_norm"; 


*6.5 ;
global f_6_5 "
cc_q10_norm
cc_q11a_norm
cc_q16a_norm

cc_q14a_norm
cc_q14b_norm
cc_q16b_norm
cc_q16c_norm
cc_q16d_norm
cc_q16e_norm
cc_q16f_norm
cc_q16g_norm"; 



* 											Factor 7 ; 


*7.1 ;
global f_7_1 "
all_q92_norm
cj_q26_norm
all_q75_norm

all_q65_norm
cc_q22a_norm
cc_q22b_norm
cc_q22c_norm

cc_q12_norm
all_q74_norm
all_q75_norm

all_q69_norm
all_q70_norm 

all_q71_norm
all_q72_norm" ; 


*7.2 ;
global f_7_2 "
all_q76_norm
all_q77_norm
all_q78_norm
all_q79_norm
all_q80_norm
all_q81_norm
all_q82_norm"; 

*7.3 ;
global f_7_3 " 
all_q57_norm
all_q58_norm
all_q59_norm
all_q83_norm
cc_q26h_norm
cc_q28e_norm
lb_q6c_norm

all_q51_norm
all_q28_norm" ; 


*7.4 ;
global f_7_4 "
cc_q11a_norm 

all_q6_norm
all_q3_norm
all_q4_norm
all_q7_norm" ; 


*7.5 ;
global f_7_5 " 
all_q84_norm
all_q85_norm
cc_q13_norm
 
all_q88_norm
cc_q26a_norm" ; 


*7.6 ;
global f_7_6 "
cc_q26b_norm

all_q86_norm
all_q87_norm"; 


*7.7 ;
global f_7_7 " 
all_q89_norm 

all_q59_norm

all_q90_norm
all_q91_norm

cc_q14a_norm
cc_q14b_norm"; 
 


* 										Factor 8   ; 


*8.1 ;
global f_8_1 "
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
cj_q18d_norm 

cj_q25a_norm
cj_q25b_norm
cj_q25c_norm"; 


*8.2 ;
global f_8_2 "
cj_q27a_norm
cj_q27b_norm
cj_q7a_norm
cj_q7b_norm
cj_q7c_norm
cj_q20a_norm
cj_q20b_norm

cj_q20e_norm" ; 


*8.3 ;
global f_8_3 "
cj_q21a_norm
cj_q21e_norm
cj_q21g_norm
cj_q21h_norm
cj_q28_norm"; 


*8.4 ;
global f_8_4 "
cj_q12a_norm
cj_q12b_norm
cj_q12c_norm
cj_q12d_norm
cj_q12e_norm
cj_q12f_norm

cj_q20o_norm"; 


*8.5 ;
global f_8_5 "
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
cj_q18d_norm

cj_q32b_norm
cj_q20k_norm
cj_q24b_norm
cj_q24c_norm" ; 


*8.6 ;
global f_8_6 "
cj_q40b_norm
cj_q40c_norm
cj_q20m_norm"; 


*8.7 ;
global f_8_7 "
cj_q22d_norm
cj_q22b_norm
cj_q25b_norm
cj_q25c_norm
cj_q25a_norm
cj_q31c_norm
cj_q31d_norm
cj_q22e_norm

cj_q6a_norm
cj_q6b_norm
cj_q6c_norm
cj_q6d_norm
cj_q29a_norm
cj_q29b_norm
cj_q42c_norm
cj_q42d_norm
cj_q22a_norm

cj_q1_norm
cj_q2_norm
cj_q11a_norm
cj_q22c_norm

cj_q3a_norm
cj_q3b_norm
cj_q3c_norm
cj_q19a_norm
cj_q19b_norm
cj_q19c_norm
cj_q19e_norm
cj_q4_norm

cj_q21a_norm
cj_q21b_norm
cj_q21c_norm
cj_q21d_norm
cj_q21f_norm"; 

#delimit cr

