/**************************************************************************
Program Title: EPIDEM 207 Assignment 1 Codebook Code
Programmer Name:
Date Created: 1/27/2025
Purpose: To create a codebook for the Matthews et al 2023 paper
**************************************************************************/

libname loc "C:\Users\u6045324\Desktop\EPIDEM 207 Files\CHIS Adult 2020"; 

*Formats from CHIS Proc format file and new formats;
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

*Use the cleaned dataset for CHIS 2020 data and create temp dataset;
data chis2020clean;
	set loc.chis2020clean;
run;

*remove formatting for codebook;
proc datasets lib=work ;
   modify chis2020clean;
     attrib _all_ format=;
run;
quit;

/***Codebook, with unweighted frequencies***/

ods excel file="C:\Users\u6045324\Desktop\EPIDEM 207 Files\CHIS Adult 2020\EPI207 Assignment 1 Codebook.xlsx" options (sheet_interval="none" sheet_name="Variables of Interest");
ods noptitle;

*Macro for codebook;
%macro codebook;
%let varlist = CV7_1 CV7_2 CV7_3 CSTRESSCAT SRSEX AGECAT RACECAT MARIT EDUCCAT INCOMECAT INS CITIZEN2 EMPLOYMENT DISTRESS;

*For the categorical variables;
%do i=1 %to %sysfunc(countw(&varlist));
%let var = %scan(&varlist, &i);

proc print data=loc.datadictionary noobs;
	var variable label values;
	where variable="&var";
run;

proc freq data=chis2020clean;
	tables &var;
run;

%end;

proc sgplot data=chis2020clean;
	histogram DISTRESS;
	title "DISTRESS";
run;

*For the weighting variables;
%let vars =;
%do j=0 %to 80;
	%let vars = &vars RAKEDW&j;
%end;

%do k=1 %to %sysfunc(countw(&vars));
%let var = %scan(&vars, &k);

proc print data=loc.datadictionary noobs;
	var variable label values;
	where variable="&var";
run;

proc sgplot data=chis2020clean;
	histogram &var;
	title "&var";
run;

%end;

%mend;

%codebook;

ods excel close;

/***Codebook, with weighted frequencies***/

ods excel file="C:\Users\u6045324\Desktop\EPIDEM 207 Files\CHIS Adult 2020\EPI207 Assignment 1 Codebook Weighted.xlsx" options (sheet_interval="none" sheet_name="Variables of Interest");
ods noptitle;

*macro for weighted frequencies codebook;
%macro codebookweighted;
%let varlist = CV7_1 CV7_2 CV7_3 CSTRESSCAT SRSEX AGECAT RACECAT MARIT EDUCCAT INCOMECAT INS CITIZEN2 EMPLOYMENT DISTRESS;

*For the categorical variables;
%do i=1 %to %sysfunc(countw(&varlist));
%let var = %scan(&varlist, &i);

proc print data=loc.datadictionary noobs;
	var variable label values;
	where variable="&var";
run;

proc surveyfreq data=chis2020clean varmethod=jackknife;
	weight rakedw0;
	repweight rakedw1-rakedw80/jkcoefs=1;
	tables &var;
run;

%end;

*For the weighting variables;
%let vars =;
%do j=0 %to 80;
	%let vars = &vars RAKEDW&j;
%end;

%do k=1 %to %sysfunc(countw(&vars));
%let var = %scan(&vars, &k);

proc print data=loc.datadictionary noobs;
	var variable label values;
	where variable="&var";
run;

proc sgplot data=chis2020clean;
	histogram &var;
	title "&var";
run;

%end;

%mend;

%codebookweighted;

ods excel close;


