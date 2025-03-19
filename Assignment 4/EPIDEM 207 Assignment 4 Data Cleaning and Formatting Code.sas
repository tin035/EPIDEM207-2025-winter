/************************************************************************
Program Title: EPIDEM 207 Assignment 4 Data Cleaning
Date : 3/18/2025
*************************************************************************/

libname loc "C:\Users\u6045324\Desktop\EPIDEM 207 Files\CHIS Adult 2020";

/***Formats from CHIS Proc format file and new formats***/
proc format;
	VALUE  YESNOF
	       1                      = "Yes"
	       2                      = "No"
	;
	VALUE  SRSEXF
	       1                      = "Male"
	       2                      = "Female"
	;
	VALUE AGECATF
		   1					  =	"18-34"
		   2					  = "35-49"
		   3					  = "50-64"
		   4					  = "65+"
	;
	VALUE  MARITF
	       1                      = "Married"
	       2                      = "Other/Sep/Div/Living with partner"
	       3                      = "Never married"
	;
	VALUE  RACECATF
	       1                      = "Hispanic or Latino"
	       2                      = "Non-Hispanic White"
	       3                      = "Non-Hispanic Asian"
	       4                      = "Non-Hispanic Black"
	       5                      = "Non-Hispanic Other/Two or more races";
	;
	VALUE EDUCATF
		   1					  = "University degree or higher"
		   2					  = "Some college"
		   3					  = "High school or less";
	;
	VALUE INCOMECATF
		   1					  = "<$50,000"
		   2					  = "$50,000-$99,999"
		   3					  = ">=$100,000"
		;
	VALUE EMPLOYF
		   1					  = "Employed"
		   2					  = "Unemployed"
	;
	VALUE URBANF
		   1					 =  "Urban"
		   2					 =  "Rural"
	;
	VALUE SMOKINGF
     	   1                      = "Currently smokes"
           2                      = "Quit smoking"
    	   3                      = "Never smoked regularly"
	;
	VALUE  AB10X
           1                      = "All of the time"
           2                      = "Most of the time"
           3                      = "Some of the time"
           4                      = "A little of the time"
           5                      = "Not at all"
	;
	VALUE RESTLESSF
		   1					  = "High levels of restlessness"
		   2					  = "Low levels of restlessness"
		   3					  = "No restlessness"
	;
	VALUE AC117V2F
           -1,1                   = "0 days"
           2                      = "1-2 days"
           3                      = "3-5 days"
           4                      = "6-9 days"
           5                      = "10-19 days"
           6                      = "20-29 days"
           7                      = "30 days or more"
	;	
run;


*Check distribution among original variables of interest;
proc freq data=loc.adult;
	table SRAGE_P1 SRSEX OMBSRR_P1 SREDUC AK22_P1 WRKST_P1 MARIT UR_CLRT2 SMOKING ILLIDRUG AJ31 AC115 AC116_P1 AC117V2;
run;

/***Preparing CHIS dataset required for analysis***/
data loc.chis2020cleana2;
	set loc.adult;

		**Variables for Age, Race, Educational attainment, and Household income are coded differently in the CHIS codebook
		so they are transformed/recoded to match the categories of the Matthews et al 2023 paper;

		*Recode age;
		AGECAT=.;
		if SRAGE_P1 in (18:30) then AGECAT=1; 		*18-34;
		else if SRAGE_P1 in (35:45) then AGECAT=2;	*35-49;
		else if SRAGE_P1 in (50:60) then AGECAT=3;	*50-64;
		else if SRAGE_P1 in (65:85) then AGECAT=4;	*65+;

		*Recode race;
		RACECAT=.;
		if OMBSRR_P1=1 then RACECAT=1;				*Hispanic or Latino;
		else if OMBSRR_P1=2 then RACECAT=2;			*Non-Hispanic White;
		else if OMBSRR_P1=5 then RACECAT=3;			*Non-Hispanic Asian;
		else if OMBSRR_P1=3 then RACECAT=4;			*Non-Hispanic Black;
		else if OMBSRR_P1 in (4 6) then RACECAT=5;  *Non-Hispanic Other/Two or more races;
	
		*Recode education;
		EDDUCCAT=.;
		if SREDUC = 4 then EDUCCAT=1;				*University degree or higher;
		else if SREDUC = 3 then EDUCCAT=2;			*Some college;
		else if SREDUC in (1:2) then EDUCCAT=3;		*High school of less;

		*Recode income; 
		INCOMECAT=.;
		if AK22_P1 in (1:5) then INCOMECAT=1;		 *<$50,000;
		else if AK22_P1 in (6:10) then INCOMECAT=2;	 *$50,000 - $99,999;
		else if AK22_P1 in (11:19) then INCOMECAT=3; *>=$100,000;

		*Recode working status (this not included in the analysis but is part of the inclusion/exclusion criteria);
		EMPLOYMENT=.;
		if WRKST_P1 in (1:3) then EMPLOYMENT=1;		 *employed;
		else if WRKST_P1 in (4:5) then EMPLOYMENT=2; *unemployed;

		*Code new exposure variable for ever feel restlessness in last 30 days;
		RESTLESSBIN=.;
		if AJ31 in (1:4) then RESTLESSBIN=1;		 *any restlessness;
		else if AJ31=5 then RESTLESSBIN=2;			 *no restlessness;

		*Code new exposure variable for high vs low levels of feeling restlessness in last 30 days;
		RESTLESSHL=.;
		if AJ31 in (1:2) then RESTLESSHL=1;			 *high level of restlessness;
		else if AJ31 in (3:4) then RESTLESSHL=2;	 *low level of restlessness;
		else if AJ31=5 then RESTLESSHL=3;			 *no restlessness;

		*Code for outcome for how long since last marijuana use among ever users;
		MJ_MONTH=.;
		if AC116_P1=1 then MJ_MONTH=1;				 *use within last month;
		else if AC116_P1 in (2:6)then MJ_MONTH=2;	 *did not use in the last month;

		**Inclusion criteria;
			
			*No missing sociodemographic information;
			if AGECAT ne .;
			if SRSEX ne .;
			if RACECAT ne .;
			if EDUCCAT ne .;
			if INCOMECAT ne .;
			if EMPLOYMENT ne .;
			if MARIT ne .;
			if UR_CLRT2 ne .;
			
			*No missing behavioral variables;
			if SMOKING ne .;
			if ILLIDRUG ne .;
			
			*No missing outcome variables;
			if RESTLESSBIN ne .;
			if RESTLESSHL ne .;
			if AC115=1 or MJ_MONTH ne .;			*ever used marijuana = Yes;

		*Formats for variables;
		format AGECAT AGECATF. SRSEX SRSEXF. RACECAT RACECATF. EDUCCAT EDUCATF.   
		INCOMECAT INCOMECATF. EMPLOYMENT EMPLOYF. MARIT MARITF. UR_CLRT2 URBANF. SMOKING SMOKINGF.
		AJ31 AB10X. RESTLESSHL RESTLESSF. ILLIDRUG RESTLESSBIN AC115 MJ_MONTH YESNOF. AC117V2 AC117V2F.;

		*Labels for variables;	
		label 
			AGECAT	      =  "Age, Categorical"
			SRSEX         =  "Sex"
			RACECAT		  =  "Race/Ethnicity"
			EDUCCAT       =  "Educational attainment"
			INCOMECAT     =  "Household income (annual U.S. dollars), categorical"
			EMPLOYMENT	  =  "Employment status"	
			MARIT         =  "Marital status"
			UR_CLRT2	  =  "Residency"
			SMOKING		  =  "Current smoking habits"
			ILLIDRUG	  =  "Illicit drug use in the past year"
			AJ31		  =  "Feel restlessness in past 30 days"
			RESTLESSBIN   =  "Experienced any restlessness in last 30 days"
			RESTLESSHL    =  "Level of feeling restlessness in last 30 days"
			AC115		  =  "Ever tried marijuana or hashish"
			MJ_MONTH	  =  "Ever used marijuana use within last 30 days"
			AC117V2		  =  "Frequency of marijuana/hashish/THC product use in the past 30 days"
		;	

	*Only keep variables needed for analysis + employment (inclusion criteria);
	keep AGECAT SRSEX RACECAT EDUCCAT INCOMECAT EMPLOYMENT MARIT UR_CLRT2 SMOKING ILLIDRUG AJ31 RESTLESSBIN RESTLESSHL AC115 MJ_MONTH AC117V2 RAKEDW0--RAKEDW80;
run;

proc freq data=loc.chis2020cleana2;
table mj_month AC117V2;
run;
