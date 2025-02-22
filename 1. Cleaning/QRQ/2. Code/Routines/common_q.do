/*=================================================================================================================
Project:		Global ROLI QRQ cleaning and analysis
Routine:		Common variables  
Author(s):		Natalia Rodriguez 	(nrodriguez@worldjusticeproject.org)
Dependencies:  	World Justice Project
Creation Date:	April, 2024

Description:
This routine will create the variables common in various questionnaires for the QRQ Global ROLI.

=================================================================================================================*/

/*=================================================================================================================
					Common variables
=================================================================================================================*/

gen all_q1=cc_q36h_norm if question=="cc"
replace all_q1=cj_q41h_norm if question=="cj"
replace all_q1=lb_q25j_norm if question=="lb"

gen all_q2=cc_q35a_norm if question=="cc"
replace all_q2=cj_q40a_norm if question=="cj"
replace all_q2=lb_q24a_norm if question=="lb"

gen all_q3=cc_q35d_norm if question=="cc"
replace all_q3=cj_q40d_norm if question=="cj"
replace all_q3=lb_q24d_norm if question=="lb"

gen all_q4=cc_q35b_norm if question=="cc"
replace all_q4=cj_q40b_norm if question=="cj"
replace all_q4=lb_q24b_norm if question=="lb"

gen all_q5=cc_q26k_norm if question=="cc"
replace all_q5=cj_q20m_norm if question=="cj"

gen all_q6=cc_q21_norm if question=="cc"
replace all_q6=lb_q12_norm if question=="lb"

gen all_q7=cc_q35c_norm if question=="cc"
replace all_q7=cj_q40c_norm if question=="cj"
replace all_q7=lb_q24c_norm if question=="lb"

gen all_q8=cc_q36d_norm if question=="cc"
replace all_q8=cj_q41d_norm if question=="cj"
replace all_q8=lb_q25d_norm if question=="lb"

gen all_q9=cc_q35e_norm if question=="cc"
replace all_q9=cj_q40e_norm if question=="cj"
replace all_q9=lb_q24e_norm if question=="lb"

gen all_q10=cc_q35f_norm if question=="cc"
replace all_q10=cj_q40f_norm if question=="cj"
replace all_q10=lb_q24f_norm if question=="lb"

gen all_q11=cj_q40g_norm if question=="cj"
replace all_q11=lb_q24g_norm if question=="lb"

gen all_q12=cc_q35g_norm if question=="cc"
replace all_q12=cj_q40h_norm if question=="cj"
replace all_q12=lb_q24h_norm if question=="lb"

gen all_q13=cj_q42a_norm if question=="cj"
replace all_q13=lb_q26a_norm if question=="lb"

gen all_q14=cc_q34e_norm if question=="cc"
replace all_q14=cj_q39e_norm if question=="cj"

gen all_q15=cc_q34h_norm if question=="cc"
replace all_q15=cj_q39h_norm if question=="cj"

gen all_q16=cc_q34i_norm if question=="cc"
replace all_q16=cj_q39i_norm if question=="cj"

gen all_q17=cj_q42b_norm if question=="cj"
replace all_q17=lb_q26b_norm if question=="lb"

gen all_q18=cc_q34j_norm if question=="cc"
replace all_q18=cj_q39j_norm if question=="cj"

gen all_q19=cc_q34a_norm if question=="cc"
replace all_q19=cj_q39a_norm if question=="cj"

gen all_q20=cc_q34k_norm if question=="cc"
replace all_q20=cj_q39k_norm if question=="cj"
replace all_q20=lb_q25h_norm if question=="lb"

gen all_q21=cc_q34l_norm if question=="cc"
replace all_q21=cj_q39l_norm if question=="cj"
replace all_q21=lb_q25i_norm if question=="lb"

gen all_q22=cc_q36a_norm if question=="cc"
replace all_q22=cj_q41a_norm if question=="cj"
replace all_q22=lb_q25a_norm if question=="lb"

gen all_q23=cc_q36f_norm if question=="cc"
replace all_q23=cj_q41f_norm if question=="cj"
replace all_q23=lb_q25f_norm if question=="lb"

gen all_q24=cc_q36b_norm if question=="cc"
replace all_q24=cj_q41b_norm if question=="cj"
replace all_q24=lb_q25b_norm if question=="lb"

gen all_q25=cc_q36c_norm if question=="cc"
replace all_q25=cj_q41c_norm if question=="cj"
replace all_q25=lb_q25c_norm if question=="lb"

gen all_q26=cc_q36e_norm if question=="cc"
replace all_q26=cj_q41e_norm if question=="cj"
replace all_q26=lb_q25e_norm if question=="lb"

gen all_q27=cc_q36g_norm if question=="cc"
replace all_q27=cj_q41g_norm if question=="cj"
replace all_q27=lb_q25g_norm if question=="lb"

gen all_q28=cc_q20b_norm if question=="cc"
replace all_q28=lb_q11b_norm if question=="lb"

gen all_q29=cc_q34f_norm if question=="cc"
replace all_q29=cj_q39f_norm if question=="cj"

gen all_q30=cc_q34g_norm if question=="cc"
replace all_q30=cj_q39g_norm if question=="cj"

gen all_q31=cc_q34c_norm if question=="cc"
replace all_q31=cj_q39c_norm if question=="cj"

gen all_q32=cc_q34d_norm if question=="cc"
replace all_q32=cj_q39d_norm if question=="cj"

gen all_q33=cc_q32a_norm if question=="cc"
replace all_q33=cj_q35a_norm if question=="cj"
replace all_q33=lb_q21a_norm if question=="lb"
replace all_q33=ph_q10a_norm if question=="ph"

gen all_q34=cc_q32b_norm if question=="cc"
replace all_q34=cj_q35c_norm if question=="cj"
replace all_q34=lb_q21b_norm if question=="lb"

gen all_q35=cc_q32c_norm if question=="cc"
replace all_q35=cj_q35b_norm if question=="cj"
replace all_q35=lb_q21c_norm if question=="lb"
replace all_q35=ph_q10b_norm if question=="ph"

gen all_q36=cc_q32d_norm if question=="cc"
replace all_q36=lb_q21d_norm if question=="lb"
replace all_q36=ph_q10c_norm if question=="ph"

gen all_q37=cc_q32e_norm if question=="cc"
replace all_q37=lb_q21f_norm if question=="lb"
replace all_q37=ph_q10e_norm if question=="ph"

gen all_q38=cc_q32f_norm if question=="cc"
replace all_q38=cj_q35d_norm if question=="cj"
replace all_q38=lb_q21g_norm if question=="lb"

gen all_q40=cc_q31a_norm if question=="cc"
replace all_q40=lb_q20a_norm if question=="lb"

gen all_q41=cc_q31b_norm if question=="cc"
replace all_q41=lb_q20b_norm if question=="lb"

gen all_q42=cc_q31c_norm if question=="cc"
replace all_q42=lb_q20c_norm if question=="lb"

gen all_q43=cc_q31d_norm if question=="cc"
replace all_q43=lb_q20d_norm if question=="lb"

gen all_q44=cc_q31e_norm if question=="cc"
replace all_q44=lb_q20e_norm if question=="lb"

gen all_q45=cc_q31f_norm if question=="cc"
replace all_q45=lb_q20f_norm if question=="lb"

gen all_q46=cc_q31g_norm if question=="cc"
replace all_q46=lb_q20g_norm if question=="lb"

gen all_q47=cc_q31h_norm if question=="cc"
replace all_q47=lb_q20h_norm if question=="lb"

gen all_q48=cc_q30a_norm if question=="cc"
replace all_q48=lb_q19b_norm if question=="lb"

gen all_q49=cc_q30b_norm if question=="cc"
replace all_q49=lb_q19c_norm if question=="lb"

gen all_q50=cc_q30c_norm if question=="cc"
replace all_q50=lb_q19d_norm if question=="lb"

gen all_q51=cc_q20a_norm if question=="cc"
replace all_q51=lb_q11a_norm if question=="lb"

gen all_q52=cc_q15_norm if question=="cc"
replace all_q52=ph_q2_norm if question=="ph"

gen all_q53=cc_q38_norm if question=="cc"
replace all_q53=lb_q8_norm if question=="lb"

gen all_q54=cc_q1_norm if question=="cc"
replace all_q54=ph_q3_norm if question=="ph"

gen all_q55=cc_q29d_norm if question=="cc"
replace all_q55=lb_q18d_norm if question=="lb"

gen all_q56=cc_q28f_norm if question=="cc"
replace all_q56=lb_q17d_norm if question=="lb"

gen all_q57=cc_q7a_norm if question=="cc"
replace all_q57=lb_q6a_norm if question=="lb"

gen all_q58=cc_q7b_norm if question=="cc"
replace all_q58=lb_q6b_norm if question=="lb"

gen all_q59=cc_q7c_norm if question=="cc"
replace all_q59=lb_q6d_norm if question=="lb"

gen all_q60=cc_q19j_norm if question=="cc"
replace all_q60=cj_q20k_norm if question=="cj"
replace all_q60=lb_q10j_norm if question=="lb"

gen all_q61=cc_q7d_norm if question=="cc"
replace all_q61=lb_q6e_norm if question=="lb"

gen all_q62=cc_q32k_norm if question=="cc"
replace all_q62=lb_q21i_norm if question=="lb"

gen all_q63=cc_q32l_norm if question=="cc"
replace all_q63=lb_q21j_norm if question=="lb"

gen all_q64=cc_q19l_norm if question=="cc"
replace all_q64=lb_q10l_norm if question=="lb"

gen all_q65=cc_q8_norm if question=="cc"
replace all_q65=lb_q7_norm if question=="lb"

gen all_q66=cc_q19b_norm if question=="cc"
replace all_q66=lb_q10b_norm if question=="lb"

gen all_q67=cc_q19c_norm if question=="cc"
replace all_q67=lb_q10c_norm if question=="lb"

gen all_q68=cc_q19d_norm if question=="cc"
replace all_q68=lb_q10d_norm if question=="lb"

gen all_q69=cc_q19e_norm if question=="cc"
replace all_q69=lb_q10e_norm if question=="lb"

gen all_q70=cc_q19f_norm if question=="cc"
replace all_q70=lb_q10f_norm if question=="lb"

gen all_q71=cc_q5a_norm if question=="cc"
replace all_q71=lb_q4a_norm if question=="lb"

gen all_q72=cc_q5b_norm if question=="cc"
replace all_q72=lb_q4b_norm if question=="lb"

gen all_q73=cc_q19a_norm if question=="cc"
replace all_q73=lb_q10a_norm if question=="lb"

gen all_q74=cc_q19i_norm if question=="cc"
replace all_q74=lb_q10i_norm if question=="lb"

gen all_q75=cc_q19k_norm if question=="cc"
replace all_q75=lb_q10k_norm if question=="lb"

gen all_q76=cc_q23a_norm if question=="cc"
replace all_q76=lb_q13a_norm if question=="lb"

gen all_q77=cc_q23b_norm if question=="cc"
replace all_q77=lb_q13b_norm if question=="lb"

gen all_q78=cc_q23c_norm if question=="cc"
replace all_q78=lb_q13c_norm if question=="lb"

gen all_q79=cc_q23d_norm if question=="cc"
replace all_q79=lb_q13d_norm if question=="lb"

gen all_q80=cc_q23e_norm if question=="cc"
replace all_q80=lb_q13e_norm if question=="lb"

gen all_q81=cc_q23f_norm if question=="cc"
replace all_q81=lb_q13f_norm if question=="lb"

gen all_q82=cc_q19h_norm if question=="cc"
replace all_q82=lb_q10h_norm if question=="lb"

gen all_q83=cc_q19j_norm if question=="cc"
replace all_q83=lb_q10j_norm if question=="lb"

gen all_q84=cc_q3a_norm if question=="cc"
replace all_q84=lb_q2a_norm if question=="lb"

gen all_q85=cc_q3b_norm if question=="cc"
replace all_q85=lb_q2b_norm if question=="lb"

gen all_q86=cc_q4a_norm if question=="cc"
replace all_q86=lb_q3a_norm if question=="lb"

gen all_q87=cc_q4b_norm if question=="cc"
replace all_q87=lb_q3b_norm if question=="lb"

gen all_q88=cc_q19g_norm if question=="cc"
replace all_q88=lb_q10g_norm if question=="lb"

gen all_q89=cc_q5c_norm if question=="cc"
replace all_q89=lb_q4c_norm if question=="lb"

gen all_q90=cc_q3c_norm if question=="cc"
replace all_q90=lb_q2c_norm if question=="lb"

gen all_q91=cc_q4c_norm if question=="cc"
replace all_q91=lb_q3c_norm if question=="lb"

gen all_q92=cc_q24_norm if question=="cc"
replace all_q92=lb_q14_norm if question=="lb"

gen all_q93=cc_q37a_norm if question=="cc"
replace all_q93=cj_q42e_norm if question=="cj"
replace all_q93=lb_q26c_norm if question=="lb"

gen all_q94=cc_q37b_norm if question=="cc"
replace all_q94=cj_q42f_norm if question=="cj"
replace all_q94=lb_q26d_norm if question=="lb"

gen all_q95=cc_q37c_norm if question=="cc"
replace all_q95=cj_q42g_norm if question=="cj"
replace all_q95=lb_q26e_norm if question=="lb"

gen all_q96=cc_q37d_norm if question=="cc"
replace all_q96=cj_q42h_norm if question=="cj"
replace all_q96=lb_q26f_norm if question=="lb"

gen all_q97=cc_q37e_norm if question=="cc"
replace all_q97=lb_q26g_norm if question=="lb"

gen all_q103=cc_q40a_norm if question=="cc"
replace all_q103=lb_q28a_norm if question=="lb"

gen all_q104=cc_q40b_norm if question=="cc"
replace all_q104=lb_q28b_norm if question=="lb"

gen all_q105=cc_q34b_norm if question=="cc"
replace all_q105=cj_q39b_norm if question=="cj"
replace all_q105=lb_q21e_norm if question=="lb"

foreach var of varlist all_q1- all_q105 {
	rename `var' `var'_norm
}

** Check scale of NORM variables for anything greater than 1 or less than 0
foreach var of varlist *_norm {
	list `var' if `var'>1 & `var'!=.
}

foreach var of varlist *_norm {
	list `var' if `var'<0 & `var'!=.
}
