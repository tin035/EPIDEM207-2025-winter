/**************************************************************************
Program Title: EPIDEM 207 Assignment 1 Data Cleaning and Formatting Code
Programmer Name: 
Date Created: 1/23/2025
Purpose: To create a cleaned dataset used in the Matthews et al 2023 paper
**************************************************************************/

libname loc "C:\Users\u6045324\Desktop\EPIDEM 207 Files\CHIS Adult 2020";

/***Formats from CHIS Proc format file and new formats***/
proc format;
	VALUE  YESNOF
	       -9                     = "NOT ASCERTAINED"
	       -8                     = "DON'T KNOW"
	       -7                     = "REFUSED"
	       -5                     = "ADULT/HOUSEHOLD INFO NOT COLLECTED"
	       -2                     = "PROXY SKIPPED"
	       -1                     = "INAPPLICABLE"
	       1                      = "Yes"
	       2                      = "No"
	;
	VALUE  SRSEXF
	       1                      = "Male"
	       2                      = "Female"
	;
	VALUE AGECATF
		  -9					  = "Missing"
		   1					  =	"18-34"
		   2					  = "35-49"
		   3					  = "50-64"
		   4					  = "65+"
	;
	VALUE  MARITF
	       -9                     = "Not ascertained"
	       1                      = "Married"
	       2                      = "Other/Sep/Div/Living with partner"
	       3                      = "Never married"
	;
	VALUE  RACECATF
		  -9 					  = "Missing"
	       1                      = "Hispanic or Latino"
	       2                      = "Non-Hispanic White"
	       3                      = "Non-Hispanic Asian"
	       4                      = "Non-Hispanic Black"
	       5                      = "Non-Hispanic Other/Two or more races";
	;
	VALUE EDUCATF
		  -9					  = "Missing"
		   1					  = "University degree or higher"
		   2					  = "Some college"
		   3					  = "High school or less";
	;
	VALUE INCOMECATF
		  -9					  = "Missing"
		   1					  = "<$50,000"
		   2					  = "$50,000-$99,999"
		   3					  = ">=$100,000"
	;
	VALUE  CITZN2F
	       -9                     = "Not ascertained"
	       1                      = "U.S.-born citizen"
	       2                      = "Naturalized citizen"
	       3                      = "Non-citizen"
	;
	VALUE STRESSORSF
		  -9					  = "Missing"
		   0					  = "No stressor"
		   1					  = "1 stressor"
		   2					  = "2 or more stressors"
	;
	VALUE INSF
		   1					  = "Insured"
		   2					  = "Uninsured"
	;
	VALUE EMPLOYF
		   1					  = "Employed"
		   2					  = "Unemployed"
	;
run;

/***Preparing CHIS dataset required for analysis***/
data loc.chis2020clean;
	set loc.adult;

		**Variables for Age, Race, Educational attainment, and Household income are coded differently in the CHIS codebook
		so they are transformed/recoded to match the categories of the Matthews et al 2023 paper;

		*Recode age;
		if SRAGE_P1 in (18:30) then AGECAT=1; 		*18-34;
		else if SRAGE_P1 in (35:45) then AGECAT=2;	*35-49;
		else if SRAGE_P1 in (50:60) then AGECAT=3;	*50-64;
		else if SRAGE_P1 in (65:85) then AGECAT=4;	*65+;
		else AGECAT=-9;								*Missing;

		*Recode race;
		if OMBSRR_P1=1 then RACECAT=1;				*Hispanic or Latino;
		else if OMBSRR_P1=2 then RACECAT=2;			*Non-Hispanic White;
		else if OMBSRR_P1=5 then RACECAT=3;			*Non-Hispanic Asian;
		else if OMBSRR_P1=3 then RACECAT=4;			*Non-Hispanic Black;
		else if OMBSRR_P1 in (4 6) then RACECAT=5;  *Non-Hispanic Other/Two or more races;
		else RACECAT=-9;							*Missing;

		*Recode education;
		if SREDUC = 4 then EDUCCAT=1;				*University degree or higher;
		else if SREDUC = 3 then EDUCCAT=2;			*Some college;
		else if SREDUC in (1:2) then EDUCCAT=3;		*High school of less;
		else EDUCCAT=-9;							*Missing;

		*Recode income; 
		if AK22_P1 in (1:5) then INCOMECAT=1;		 *<$50,000;
		else if AK22_P1 in (6:10) then INCOMECAT=2;	 *$50,000 - $99,999;
		else if AK22_P1 in (11:19) then INCOMECAT=3; *>=$100,000;
		else INCOMECAT=-9;							 *Missing;

		*Recode working status (this not included in the analysis but is part of the inclusion/exclusion criteria);
		if AK1 in (1:3) then EMPLOYMENT=1;			 *employed;
		else if AK1=4 then EMPLOYMENT=2;			 *unemployed;

		*Code new exposure variable cumulative work stressor;
		sumcwork=SUM(CV7_1,CV7_2,CV7_3);
		if sumcwork=6 then CSTRESSCAT=0; 			*No stressor;
		else if sumcwork=5 then CSTRESSCAT=1; 		*1 stressor;
		else if sumcwork in (3:4) then CSTRESSCAT=2;*2 or more stressors;
		else CSTRESSCAT=-9;							*Missing;

		**Inclusion criteria;
			
			*No missing sociodemographic information;
			if CV7_1 in (1:2);
			if CV7_2 in (1:2);
			if CV7_3 in (1:2);
			if CSTRESSCAT in (0:2);
			if DISTRESS in (0:24);
			if SRSEX in (1:2);
			if AGECAT in (1:4);
			if MARIT in (1:3);
			if EDUCCAT in (1:3);
			if INCOMECAT in (1:3);
			if RACECAT in (1:5);
			if INS in (1:2);
			if CITIZEN2 in (1:3);
			
			*If work status last week is not unemployed;
			if AK1 ne 4;

		*Formats for variables;
		format CV7_1 CV7_2 CV7_3 YESNOF. SRSEX SRSEXF. agecat AGECATF. RACECAT RACECATF. MARIT MARITF. EDUCCAT EDUCATF. 
		INCOMECAT INCOMECATF. CITIZEN2 CITZN2F. CSTRESSCAT STRESSORSF. INS INSF. EMPLOYMENT EMPLOYF.;
		
		*Labels for variables;	
		label 
			CV7_1         =  "Job loss"
			CV7_2         =  "Reduced work hours"
			CV7_3         =  "Working from home"
			CSTRESSCAT	  =  "Cumulative work stressors"
			DISTRESS      =  "Psychological distress"
			SRSEX         =  "Sex"
			AGECAT	      =  "Age, Categorical"
			MARIT         =  "Marital status"
			EDUCCAT       =  "Educational attainment"
			INCOMECAT     =  "Household income (annual U.S. dollars), categorical"
			RACECAT		  =  "Race/Ethnicity"
			INS           =  "Insurance"
			CITIZEN2      =  "Citizenship Status"
			EMPLOYMENT	  =  "Work status last week"
		;	

	*Only keep variables needed for analysis + employment (inclusion criteria);
	keep CV7_1 CV7_2 CV7_3 CSTRESSCAT DISTRESS SRSEX SRAGE_P1 AGECAT RACECAT MARIT EDUCCAT INCOMECAT INS CITIZEN2 EMPLOYMENT RAKEDW0--RAKEDW80;
run;
