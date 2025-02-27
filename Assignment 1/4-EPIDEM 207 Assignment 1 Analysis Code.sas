/**************************************************************************
Program Title: EPIDEM 207 Assignment 1 Analysis Code
Programmer Name: 
Date Created: 1/23/2025
Purpose: To create a table 1-3 for the Matthews et al 2023 paper
**************************************************************************/

libname loc "C:\Users\u6045324\Desktop\EPIDEM 207 Files\CHIS Adult 2020"; 

*formats;
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



*Since we are interested in racial/ethnic disparities, we will stratify our columns by race/ethnicity;
proc sort data=chis2020clean;
	by RACECAT;
run;

/***Table 1 Unweighted Descriptive Statistics***/

*macro code for table 1;
options nodate nocenter ls = 147 ps = 47 orientation = landscape;

/** change this to location where you saved the .sas files**/
%let MacroDir=C:\Users\u6045324\Desktop\EPIDEM 207 Files\Table 1 Macros;

filename tab1  "&MacroDir./Table1.sas";
%include tab1;

/***********************/
/****UTILITY SASJOBS****/
/***********************/
filename tab1prt  "&MacroDir./Table1Print.sas";
%include tab1prt;

filename npar1way  "&MacroDir./Npar1way.sas";
%include npar1way;

filename CheckVar  "&MacroDir./CheckVar.sas";
%include CheckVar;

filename Uni  "&MacroDir./Univariate.sas";
%include Uni;

filename Varlist  "&MacroDir./Varlist.sas";
%include Varlist;

filename Words  "&MacroDir./Words.sas";
%include Words;

filename Append  "&MacroDir./Append.sas";
%include Append;

/** specify folder in which to store results***/

%let results=C:\Users\u6045324\Desktop\EPIDEM 207 Files\CHIS Adult 2020;

%Table1(DSName=chis2020clean,
        GroupVar=RACECAT,
        NumVars=DISTRESS,
        FreqVars=CV7_1 CV7_2 CV7_3 CSTRESSCAT SRSEX AGECAT MARIT EDUCCAT INCOMECAT INS CITIZEN2,
        Mean=Y,
        Median=N,
        Total=RC,
        P=N, /*no p-values -->no interested in p-values*/
        Fisher= , /*list of var where fisher exact should be used --> prob none*/
        KW= , /*list of var for wilcoxon rank-sum --> prob none*/
        FreqCell=N(RP),
        Missing=N, /*should we include missing?*/
        Print=N,
        Label=L, /*labels variable with variable label*/
        Out=EPIDEM207Table1, /*output dataset name printed into table1print macro*/
        Out1way=)

*options mprint  symbolgen mlogic;
run;

ods pdf file="&results.\EPIDEM207 Assignment1 Table 1.pdf";
title 'Table 1. Characteristics of the Sample Population in CHIS 2020, Unweighted (N = 12,113)';
%Table1Print(DSname=EPIDEM207Table1,Space=Y)
ods pdf close;
run;

/***Table 1 Weighted Descriptive Statistics***/

/*We were unable to incorporate the proc surveymeans and proc surveyfreq into the Table 1 macros, so we decided to 
run these procs and fill in an excel sheet*/

*for continuous variables;
proc surveymeans data=chis2020clean varmethod=jackknife;
	weight rakedw0;
	repweight rakedw1-rakedw80/jkcoefs=1;
	var DISTRESS;
	by RACECAT;
run;

*for categorical variables;
proc surveyfreq data=chis2020clean varmethod=jackknife;
	weight rakedw0;
	repweight rakedw1-rakedw80/jkcoefs=1;
	tables RACECAT*(CV7_1 CV7_2 CV7_3 CSTRESSCAT SRSEX AGECAT MARIT EDUCCAT INCOMECAT INS CITIZEN2)/row;
run;

/***Table 2***/
proc freq data=chis2020clean;
	table (cv7_1 cv7_2 cv7_3 CSTRESSCAT)*distress;
run;

*Table 2 Model 1;
%macro table2model1;
%let varlist = cv7_1 cv7_2 cv7_3;

%do j=1 %to %sysfunc(countw(&varlist));
%let var = %scan(&varlist, &j);

proc surveyreg data=chis2020clean varmethod=jackknife;
	weight rakedw0;
	repweight rakedw1-rakedw80/JKCOEFS=1;  
	class &var(ref="No") agecat srsex;
	model DISTRESS = &var agecat SRSEX/solution clparm;
run;

%end;

proc surveyreg data=chis2020clean varmethod=jackknife;
	weight rakedw0;
	repweight rakedw1-rakedw80/JKCOEFS=1;  
	class CSTRESSCAT(ref="No stressor") AGECAT SRSEX;
	model DISTRESS = CSTRESSCAT AGECAT SRSEX/solution clparm;
run;

%mend;

%table2model1;

*Table 2 Model 2;
%macro table2model2;
%let varlist = cv7_1 cv7_2 cv7_3;

%do j=1 %to %sysfunc(countw(&varlist));
%let var = %scan(&varlist, &j);

proc surveyreg data=chis2020clean varmethod=jackknife;
	weight rakedw0;
	repweight rakedw1-rakedw80/JKCOEFS=1;  
	class &var(ref="No") AGECAT SRSEX MARIT EDUCCAT INCOMECAT INS CITIZEN2;
	model DISTRESS = &var AGECAT SRSEX MARIT EDUCCAT INCOMECAT INS CITIZEN2/solution clparm;
run;

%end;

proc surveyreg data=chis2020clean varmethod=jackknife;
	weight rakedw0;
	repweight rakedw1-rakedw80/JKCOEFS=1;  
	class CSTRESSCAT(ref="No stressor") AGECAT SRSEX MARIT EDUCCAT INCOMECAT INS CITIZEN2;
	model DISTRESS = CSTRESSCAT AGECAT SRSEX MARIT EDUCCAT INCOMECAT INS CITIZEN2/solution clparm;
run;

%mend;

%table2model2;

/***Table 3***/

*Stratify by race/ethnicity;

*Table 3 Model 1;
%macro table3model1;
%let varlist = cv7_1 cv7_2 cv7_3;

%do i=1 %to 5;
data race&i;
	set chis2020clean;
	if racecat = &i;
run;

%do j=1 %to %sysfunc(countw(&varlist));
%let var = %scan(&varlist, &j);

proc freq data=race&i;
	table &var*distress;
run;

proc surveyreg data=race&i varmethod=jackknife;
	weight rakedw0;
	repweight rakedw1-rakedw80/JKCOEFS=1;  
	class &var(ref="No") agecat srsex;
	model DISTRESS = &var agecat SRSEX/solution clparm;
run;

%end;

%end;

%mend;

%table3model1;

*Table 3 Model 2;
%macro table3model2;
%let varlist = cv7_1 cv7_2 cv7_3;

%do i=1 %to 5;
data race&i;
	set chis2020clean;
	if racecat = &i;
run;

%do j=1 %to %sysfunc(countw(&varlist));
%let var = %scan(&varlist, &j);

proc surveyreg data=race&i varmethod=jackknife;
	weight rakedw0;
	repweight rakedw1-rakedw80/JKCOEFS=1;  
	class &var(ref="No") AGECAT SRSEX MARIT EDUCCAT INCOMECAT INS CITIZEN2;
	model DISTRESS = &var AGECAT SRSEX MARIT EDUCCAT INCOMECAT INS CITIZEN2/solution clparm;
run;

%end;

%end;

%mend;

%table3model2;
