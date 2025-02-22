/*=================================================================================================================
Project:		Global ROLI QRQ cleaning and analysis
Routine:		Normalization routine
Author(s):		Natalia Rodriguez 	(nrodriguez@worldjusticeproject.org)
Dependencies:  	World Justice Project
Creation Date:	April, 2024

Description:
This routine will create normalized variables for all questions within the QRQ Global ROLI.

=================================================================================================================*/

/*=================================================================================================================
					Normalization
=================================================================================================================*/

/*----------*/
/* 1. Civil */
/*----------*/

foreach var of varlist cc_q1- cc_q5c cc_q7a- cc_q40b {
	gen `var'_norm=.
}

/* Cases */
replace cc_q1_norm=1 if cc_q1==1
replace cc_q1_norm=0 if cc_q1==2 | cc_q1==3

replace cc_q15_norm=(cc_q15-1)/2

/* Dummy  */
replace cc_q12_norm=0 if cc_q12==2
replace cc_q12_norm=1 if cc_q12==1

/* Likert 3 Values: Positive */
# delimit;
foreach var of varlist 
	cc_q31a cc_q31b cc_q31c cc_q31d cc_q31e cc_q31f cc_q31g cc_q31h
	cc_q33 cc_q38 {;
	replace `var'_norm=(`var'-1)/2; 
};
# delimit cr;

/* Likert 3 Values: Negative */
replace cc_q25_norm=1-((cc_q25-1)/2)
replace cc_q27_norm=1-((cc_q27-1)/2)

/* Likert 4 Values: Positive */
# delimit;
foreach var of varlist 
	cc_q5a cc_q5b cc_q5c
	cc_q8
	cc_q9a cc_q9b cc_q9c
	cc_q10
	cc_q11a cc_q11b
	cc_q13
	cc_q14a cc_q14b
	cc_q16a cc_q16b cc_q16c cc_q16d cc_q16e cc_q16f cc_q16g
	cc_q22a cc_q22b cc_q22c
	cc_q24
	cc_q29a cc_q29b cc_q29c
	cc_q30a cc_q30b cc_q30c
	cc_q32a cc_q32b cc_q32c cc_q32d cc_q32e cc_q32f cc_q32h cc_q32i cc_q32j cc_q32k cc_q32l
	cc_q34a cc_q34b cc_q34c cc_q34d cc_q34e cc_q34f cc_q34g cc_q34h cc_q34i cc_q34j cc_q34k cc_q34l
	cc_q35a cc_q35b cc_q35c cc_q35d cc_q35e cc_q35f cc_q35g
	cc_q36a cc_q36b cc_q36c cc_q36d cc_q36e cc_q36f cc_q36g 
	cc_q39a cc_q39b cc_q39c cc_q39d cc_q39e 
	cc_q40a cc_q40b {;
		replace `var'_norm=(`var'-1)/3; 
};
# delimit cr;

/* Likert 4 Values: Negative */
# delimit;
foreach var of varlist 
	cc_q7a cc_q7b cc_q7c cc_q7d
	cc_q19a cc_q19b cc_q19c cc_q19d cc_q19e cc_q19f cc_q19g cc_q19h cc_q19i cc_q19j cc_q19k cc_q19l
	cc_q23a cc_q23b cc_q23c cc_q23d cc_q23e cc_q23f
	cc_q28a cc_q28b cc_q28c cc_q28d cc_q28e cc_q28f
	cc_q29d
	cc_q36h 
	cc_q37a cc_q37b cc_q37c cc_q37d cc_q37e {;
		replace `var'_norm=1-((`var'-1)/3); 
};
# delimit cr;

/* Likert 5 Values: Positive */
# delimit;
foreach var of varlist 
	cc_q3a cc_q3b cc_q3c
	cc_q4a cc_q4b cc_q4c {;
		replace `var'_norm=(`var'-1)/4; 
};
# delimit cr;

/* Likert 6 Values: Positive */
replace cc_q20a_norm=1 if cc_q20a==6
replace cc_q20a_norm=0.75 if cc_q20a==5
replace cc_q20a_norm=0.5 if cc_q20a==4
replace cc_q20a_norm=0.25 if cc_q20a==3
replace cc_q20a_norm=0.05 if cc_q20a==2
replace cc_q20a_norm=0 if cc_q20a==1

/* Likert 6 Values: Negative */
replace cc_q20b_norm=0 if cc_q20b==6
replace cc_q20b_norm=0.05 if cc_q20b==5
replace cc_q20b_norm=0.25 if cc_q20b==4
replace cc_q20b_norm=0.5 if cc_q20b==3
replace cc_q20b_norm=0.75 if cc_q20b==2
replace cc_q20b_norm=1 if cc_q20b==1

replace cc_q21_norm=0 if cc_q21==6
replace cc_q21_norm=0.05 if cc_q21==5
replace cc_q21_norm=0.25 if cc_q21==4
replace cc_q21_norm=0.5 if cc_q21==3
replace cc_q21_norm=0.75 if cc_q21==2
replace cc_q21_norm=1 if cc_q21==1

/* Likert 10 Values: Negative */
# delimit;
foreach var of varlist 
	cc_q26a cc_q26b cc_q26c cc_q26d cc_q26e cc_q26f cc_q26g cc_q26h cc_q26i cc_q26j cc_q26k {;
		replace `var'_norm=1-((`var'-1)/9); 
};
# delimit cr;


/*-------------*/
/* 2. Criminal */
/*-------------*/

foreach var of varlist cj_q1- cj_q42h {
	gen `var'_norm=.
}

/* Cases */
gen alex=0 if cj_q38~=. 
replace alex=1 if cj_q38==4
bysort country: egen alex_co=mean(alex)
replace cj_q38_norm=1-((cj_q38-1)/2) if alex_co<0.5
replace cj_q38_norm=. if cj_q38==4
drop alex_co alex

replace cj_q8_norm=(cj_q8-1)/2
replace cj_q9_norm=(cj_q9-1)/2
replace cj_q14_norm=(cj_q14-1)

/* Likert 4 Values: Positive */
# delimit;
foreach var of varlist 
	cj_q3a cj_q3b cj_q3c
	cj_q4
	cj_q26
	cj_q35a cj_q35b cj_q35c cj_q35d
	cj_q36a cj_q36b cj_q36c cj_q36d
	cj_q39a cj_q39b cj_q39c cj_q39d cj_q39e cj_q39f cj_q39g cj_q39h cj_q39i cj_q39j cj_q39k cj_q39l
	cj_q40a cj_q40b cj_q40c cj_q40d cj_q40e cj_q40f cj_q40g cj_q40h
	cj_q41a cj_q41b cj_q41c cj_q41d cj_q41e cj_q41f cj_q41g {;
		replace `var'_norm=(`var'-1)/3; 
};
# delimit cr;

/* Likert 4 Values: Negative */
# delimit;
foreach var of varlist 
	cj_q1
	cj_q2
	cj_q6a cj_q6b cj_q6c cj_q6d
	cj_q7a cj_q7b cj_q7c 
	cj_q10
	cj_q11a cj_q11b
	cj_q12a cj_q12b cj_q12c cj_q12d cj_q12e cj_q12f
	cj_q13a cj_q13b cj_q13c cj_q13d cj_q13e cj_q13f
	cj_q15
	cj_q29a cj_q29b
	cj_q31a cj_q31b cj_q31c cj_q31d cj_q31e cj_q31f cj_q31g
	cj_q32b cj_q32c cj_q32d
	cj_q33a cj_q33b cj_q33c cj_q33d cj_q33e 
	cj_q34a cj_q34b cj_q34c cj_q34d cj_q34e 
	cj_q41h
	cj_q42a cj_q42b cj_q42c cj_q42d cj_q42e cj_q42f cj_q42g cj_q42h {;
		replace `var'_norm=1-((`var'-1)/3); 
};
# delimit cr;

/* Likert 5 Values: Positive */
# delimit;
foreach var of varlist 
	cj_q27a cj_q27b {;
		replace `var'_norm=(`var'-1)/4; 
};
# delimit cr;

/* Likert 6 Values: Positive */
# delimit;
foreach var of varlist 
	cj_q22a cj_q22b cj_q22d cj_q22e
	cj_q24a {;
		replace `var'_norm=1 if `var'==6;
		replace `var'_norm=0.75 if `var'==5;
		replace `var'_norm=0.5 if `var'==4;
		replace `var'_norm=0.25 if `var'==3;
		replace `var'_norm=0.05 if `var'==2;
		replace `var'_norm=0 if `var'==1; 
};
# delimit cr;

/* Likert 6 Values: Negative */
# delimit;
foreach var of varlist 
	cj_q22c
	cj_q24b cj_q24c
	cj_q25a cj_q25b cj_q25c
	cj_q28 {;
		replace `var'_norm=0 if `var'==6;
		replace `var'_norm=0.05 if `var'==5;
		replace `var'_norm=0.25 if `var'==4;
		replace `var'_norm=0.5 if `var'==3;
		replace `var'_norm=0.75 if `var'==2;
		replace `var'_norm=1 if `var'==1; 
};
# delimit cr;

/* Likert 10 Values: Negative */
# delimit;
foreach var of varlist 
	cj_q16a cj_q16b cj_q16c cj_q16d cj_q16e cj_q16f cj_q16g cj_q16h cj_q16i cj_q16j cj_q16k cj_q16l cj_q16m
 	cj_q18a cj_q18b cj_q18c cj_q18d cj_q18e
	cj_q19a cj_q19b cj_q19c cj_q19d cj_q19e cj_q19f cj_q19g
	cj_q20a cj_q20b cj_q20c cj_q20d cj_q20e cj_q20f cj_q20g cj_q20h cj_q20i cj_q20j cj_q20k cj_q20l cj_q20m cj_q20n cj_q20o cj_q20p
	cj_q21a cj_q21b cj_q21c cj_q21d cj_q21e cj_q21f cj_q21g cj_q21h cj_q21i cj_q21j cj_q21k 
	cj_q37a cj_q37b cj_q37c cj_q37d {;
		replace `var'_norm=1-((`var'-1)/9); 
};
# delimit cr;


/*----------*/
/* 3. Labor */
/*----------*/

foreach var of varlist lb_q2a-lb_q4d lb_q6a-lb_q28b {
	gen `var'_norm=.
}

/* Cases */
replace lb_q8_norm=(lb_q8-1)/2

replace lb_q9_norm=0 if lb_q9==1 | lb_q9==4
replace lb_q9_norm=0.5 if lb_q9==2
replace lb_q9_norm=1 if lb_q9==3

replace lb_q22_norm=1-((lb_q22-1)/2)

/* Likert 3 Values: Positive */
# delimit;
foreach var of varlist 
	lb_q15a lb_q15b lb_q15c lb_q15d lb_q15e {;
	replace `var'_norm=(`var'-1)/2; 
};
# delimit cr;

/* Likert 3 Values: Positive */
# delimit;
foreach var of varlist 
	lb_q20a lb_q20b lb_q20c lb_q20d lb_q20e lb_q20f lb_q20g lb_q20h {;
	replace `var'_norm=(`var'-1)/2; 
};
# delimit cr;

/* Likert 4 Values: Positive */
# delimit;
foreach var of varlist 
	lb_q4a lb_q4b lb_q4c lb_q4d
	lb_q7
	lb_q14
	lb_q18a lb_q18b lb_q18c 
	lb_q19a lb_q19b lb_q19c lb_q19d
	lb_q21a lb_q21b lb_q21c lb_q21d lb_q21e lb_q21f lb_q21g lb_q21i lb_q21j
	lb_q23a lb_q23b lb_q23c lb_q23d lb_q23e lb_q23f lb_q23g
	lb_q24a lb_q24b lb_q24c lb_q24d lb_q24e lb_q24f lb_q24g lb_q24h
	lb_q25a lb_q25b lb_q25c lb_q25d lb_q25e lb_q25f lb_q25g lb_q25h lb_q25i 
	lb_q28a lb_q28b {;
		replace `var'_norm=(`var'-1)/3; 
};
# delimit cr;

/* Likert 4 Values: Negative */
# delimit;
foreach var of varlist 
	lb_q6a lb_q6b lb_q6c lb_q6d lb_q6e
	lb_q10a lb_q10b lb_q10c lb_q10d lb_q10e lb_q10f lb_q10g lb_q10h lb_q10i lb_q10j lb_q10k lb_q10l
	lb_q13a lb_q13b lb_q13c lb_q13d lb_q13e lb_q13f
	lb_q16a lb_q16b lb_q16c lb_q16d lb_q16e lb_q16f
	lb_q17a lb_q17b lb_q17c lb_q17d lb_q17e
	lb_q18d
	lb_q25j
	lb_q26a lb_q26b lb_q26c lb_q26d lb_q26e lb_q26f lb_q26g {;
		replace `var'_norm=1-((`var'-1)/3); 
};
# delimit cr;

/* Likert 5 Values: Positive */
# delimit;
foreach var of varlist 
	lb_q2a lb_q2b lb_q2c lb_q2d
	lb_q3a lb_q3b lb_q3c lb_q3d {;
		replace `var'_norm=(`var'-1)/4; 
};
# delimit cr;

/* Likert 6 Values: Positive */
# delimit;
foreach var of varlist 
	lb_q11a {;
		replace `var'_norm=1 if `var'==6;
		replace `var'_norm=0.75 if `var'==5;
		replace `var'_norm=0.5 if `var'==4;
		replace `var'_norm=0.25 if `var'==3;
		replace `var'_norm=0.05 if `var'==2;
		replace `var'_norm=0 if `var'==1; 
};
# delimit cr;

/* Likert 6 Values: Negative */
# delimit;
foreach var of varlist 
	lb_q11b
	lb_q12 {;
		replace `var'_norm=0 if `var'==6;
		replace `var'_norm=0.05 if `var'==5;
		replace `var'_norm=0.25 if `var'==4;
		replace `var'_norm=0.5 if `var'==3;
		replace `var'_norm=0.75 if `var'==2;
		replace `var'_norm=1 if `var'==1; 
};
# delimit cr;


/*------------------*/
/* 4. Public Health */
/*------------------*/

foreach var of varlist ph_q1a - ph_q14{
	gen `var'_norm=.
}

/* Cases */
replace ph_q2_norm=(ph_q2-1)/2
replace ph_q7_norm=1-((ph_q7-1)/2)

replace ph_q3_norm=1 if ph_q3==1
replace ph_q3_norm=0 if ph_q3==2 | ph_q3==3

/* Likert 4 Values: Positive */
# delimit;
foreach var of varlist 
	ph_q1a ph_q1b ph_q1c 
	ph_q4a ph_q4b ph_q4c
	ph_q9a ph_q9b ph_q9c 
	ph_q10a ph_q10b ph_q10c ph_q10d ph_q10e ph_q10f
	ph_q13
	ph_q14 {;
		replace `var'_norm=(`var'-1)/3; 
};
# delimit cr;

/* Likert 4 Values: Negative */
# delimit;
foreach var of varlist 
	ph_q1d
	ph_q6a ph_q6b ph_q6c ph_q6d ph_q6e ph_q6f ph_q6g
	ph_q8a ph_q8b ph_q8c ph_q8d ph_q8e ph_q8f ph_q8g
	ph_q9d
	ph_q11a ph_q11b ph_q11c
	ph_q12a ph_q12b ph_q12c ph_q12d ph_q12e {;
		replace `var'_norm=1-((`var'-1)/3); 
};
# delimit cr;

/* Likert 6 Values: Positive */
# delimit;
foreach var of varlist 
	ph_q5a {;
		replace `var'_norm=1 if `var'==6;
		replace `var'_norm=0.75 if `var'==5;
		replace `var'_norm=0.5 if `var'==4;
		replace `var'_norm=0.25 if `var'==3;
		replace `var'_norm=0.05 if `var'==2;
		replace `var'_norm=0 if `var'==1; 
};
# delimit cr;

/* Likert 6 Values: Negative */
# delimit;
foreach var of varlist 
	ph_q5b ph_q5c ph_q5d {;
		replace `var'_norm=0 if `var'==6;
		replace `var'_norm=0.05 if `var'==5;
		replace `var'_norm=0.25 if `var'==4;
		replace `var'_norm=0.5 if `var'==3;
		replace `var'_norm=0.75 if `var'==2;
		replace `var'_norm=1 if `var'==1; 
};
# delimit cr;

