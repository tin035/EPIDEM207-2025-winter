/**************************************************************************
Program Title: EPIDEM 207 Assignment 4 Analysis Code
Date Created: 3/18/2025
Purpose: To create table 1-4 for assignment 4
**************************************************************************/

libname loc "C:\Users\u6045324\Desktop\EPIDEM 207 Files\CHIS Adult 2020"; 

*formats;
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
		  -1					  = "Never used marijuana"
           1                      = "Did not use in last 30 days"
           2                      = "1-2 days"
           3                      = "3-5 days"
           4                      = "6-9 days"
           5                      = "10-19 days"
           6                      = "20-29 days"
           7                      = "30 days or more"
	;	
run;

*Use the cleaned dataset for CHIS 2020 data and create temp dataset;
data chis2020cleana2;
	set loc.chis2020cleana2;
run;

*Since we are interested in racial/ethnic disparities, we will stratify our columns by race/ethnicity;
proc sort data=chis2020cleana2;
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

%Table1(DSName=chis2020cleana2,
        GroupVar=RESTLESSBIN,
        /*NumVars=DISTRESS,*/
        FreqVars= MJ_MONTH AGECAT SRSEX RACECAT EDUCCAT INCOMECAT EMPLOYMENT MARIT UR_CLRT2 SMOKING ILLIDRUG AJ31 RESTLESSHL AC117V2,
        Mean=Y,
        Median=N,
        Total=RC,
        P=N, /*no p-values -->no interested in p-values*/
        Fisher= , /*list of var where fisher exact should be used --> prob none*/
        KW= , /*list of var for wilcoxon rank-sum --> prob none*/
        FreqCell=N(CP),
        Missing=N, /*should we include missing?*/
        Print=N,
        Label=L, /*labels variable with variable label*/
        Out=EPIDEM207Table1, /*output dataset name printed into table1print macro*/
        Out1way=)

*options mprint  symbolgen mlogic;
run;

ods pdf file="&results.\EPIDEM207 Assignment 4 Table 1.pdf";
title 'Table 1. Characteristics of the Sample Population in CHIS 2020, Unweighted (N = 12,098)';
%Table1Print(DSname=EPIDEM207Table1,Space=Y)
ods pdf close;
run;

/***Table 1 Weighted Descriptive Statistics***/

/*We were unable to incorporate the proc surveymeans and proc surveyfreq into the Table 1 macros, so we decided to 
run these procs and fill in an excel sheet*/

*for categorical variables;
proc surveyfreq data=chis2020cleana2 varmethod=jackknife;
	weight rakedw0;
	repweight rakedw1-rakedw80/jkcoefs=1;
	tables RESTLESSBIN*(MJ_MONTH AGECAT SRSEX RACECAT EDUCCAT INCOMECAT EMPLOYMENT MARIT UR_CLRT2 SMOKING ILLIDRUG AJ31 RESTLESSHL AC117V2)/row;
run;

/***Table 2***/
proc freq data=chis2020cleana2;
	table RESTLESSBIN*MJ_MONTH;
run;

*Table 2 Model 1;
proc surveylogistic data=chis2020cleana2 varmethod=jackknife;
	weight rakedw0;
	repweight rakedw1-rakedw80/JKCOEFS=1;  
	class RESTLESSBIN(ref="No")/param=ref;
	model MJ_MONTH(ref="No") = RESTLESSBIN/clparm;
run;

*Table 2 Model 2;
proc surveylogistic data=chis2020cleana2 varmethod=jackknife;
	weight rakedw0;
	repweight rakedw1-rakedw80/JKCOEFS=1;  
	class RESTLESSBIN(ref="No") AGECAT(ref="65+") SRSEX(ref="Female")/param=ref;
	model MJ_MONTH(ref="No") = RESTLESSBIN AGECAT SRSEX/clparm;
run;

*Table 2 Model 3;
proc surveylogistic data=chis2020cleana2 varmethod=jackknife;
	weight rakedw0;
	repweight rakedw1-rakedw80/JKCOEFS=1;  
	class RESTLESSBIN(ref="No") AGECAT(ref="65+") SRSEX(ref="Female") RACECAT(ref="Non-Hispanic White") 
	EDUCCAT(ref="University degree or higher") INCOMECAT(ref=">=$100,000") EMPLOYMENT(ref="Employed")
	MARIT(ref="Married") UR_CLRT2(ref="Urban")/param=ref;
	model MJ_MONTH(ref="No") = RESTLESSBIN AGECAT SRSEX RACECAT EDUCCAT INCOMECAT EMPLOYMENT MARIT UR_CLRT2/clparm;
run;

*Table 2 Model 4;
proc surveylogistic data=chis2020cleana2 varmethod=jackknife;
	weight rakedw0;
	repweight rakedw1-rakedw80/JKCOEFS=1;  
	class RESTLESSBIN(ref="No") AGECAT(ref="65+") SRSEX(ref="Female") RACECAT(ref="Non-Hispanic White") 
	EDUCCAT(ref="University degree or higher") INCOMECAT(ref=">=$100,000") EMPLOYMENT(ref="Employed")
	MARIT(ref="Married") UR_CLRT2(ref="Urban") SMOKING(ref="Never smoked regularly") ILLIDRUG(ref="No")/param=ref;
	model MJ_MONTH(ref="No") = RESTLESSBIN AGECAT SRSEX RACECAT EDUCCAT INCOMECAT EMPLOYMENT MARIT UR_CLRT2 SMOKING ILLIDRUG/clparm;
run;

/***Table 3***/

*Table 3 Model 1;
%macro table3model1;
%let varlist = RESTLESSBIN;

%do i=1 %to 4;
data age&i;
	set chis2020cleana2;
	if AGECAT = &i;
run;

%do j=1 %to %sysfunc(countw(&varlist));
%let var = %scan(&varlist, &j);

proc freq data=age&i;
	table &var*MJ_MONTH;
run;

proc surveylogistic data=age&i varmethod=jackknife;
	weight rakedw0;
	repweight rakedw1-rakedw80/JKCOEFS=1;  
	class &var(ref="No")/param=ref;
	model MJ_MONTH(ref="No") = &var/clparm;
run;

%end;
%end;
%mend;

%table3Model1;

*Table 3 Model 2;
%macro table3model2;
%let varlist = RESTLESSBIN;

%do i=1 %to 4;
data age&i;
	set chis2020cleana2;
	if AGECAT = &i;
run;

%do j=1 %to %sysfunc(countw(&varlist));
%let var = %scan(&varlist, &j);

proc freq data=age&i;
	table &var*MJ_MONTH;
run;

proc surveylogistic data=age&i varmethod=jackknife;
	weight rakedw0;
	repweight rakedw1-rakedw80/JKCOEFS=1;  
	class &var(ref="No") RESTLESSBIN(ref="No") AGECAT SRSEX(ref="Female")/param=ref;
	model MJ_MONTH(ref="No") = &var AGECAT SRSEX/clparm;
run;

%end;
%end;

%mend;

%table3model2;

*Table 3 Model 3;
%macro table3model3;
%let varlist = RESTLESSBIN;

%do i=1 %to 4;
data age&i;
	set chis2020cleana2;
	if AGECAT = &i;
run;

%do j=1 %to %sysfunc(countw(&varlist));
%let var = %scan(&varlist, &j);

proc freq data=age&i;
	table &var*MJ_MONTH;
run;

proc surveylogistic data=age&i varmethod=jackknife;
	weight rakedw0;
	repweight rakedw1-rakedw80/JKCOEFS=1;  
	class &var(ref="No") AGECAT SRSEX(ref="Female") RACECAT(ref="Non-Hispanic White") 
	EDUCCAT(ref="University degree or higher") INCOMECAT(ref=">=$100,000") EMPLOYMENT(ref="Employed")
	MARIT(ref="Married") UR_CLRT2(ref="Urban")/param=ref;
	model MJ_MONTH(ref="No") = &var AGECAT SRSEX RACECAT EDUCCAT INCOMECAT EMPLOYMENT MARIT UR_CLRT2/clparm;
run;

%end;
%end;

%mend;

%table3model3;

*Table 3 Model 4;
%macro table3model4;
%let varlist = RESTLESSBIN;

%do i=1 %to 4;
data age&i;
	set chis2020cleana2;
	if AGECAT = &i;
run;

%do j=1 %to %sysfunc(countw(&varlist));
%let var = %scan(&varlist, &j);

proc freq data=age&i;
	table &var*MJ_MONTH;
run;

proc surveylogistic data=age&i varmethod=jackknife;
	weight rakedw0;
	repweight rakedw1-rakedw80/JKCOEFS=1;  
	class &var(ref="No") AGECAT SRSEX(ref="Female") RACECAT(ref="Non-Hispanic White") 
	EDUCCAT(ref="University degree or higher") INCOMECAT(ref=">=$100,000") EMPLOYMENT(ref="Employed")
	MARIT(ref="Married") UR_CLRT2(ref="Urban") SMOKING(ref="Never smoked regularly") ILLIDRUG(ref="No")/param=ref;
	model MJ_MONTH(ref="No") = &var AGECAT SRSEX RACECAT EDUCCAT INCOMECAT EMPLOYMENT MARIT UR_CLRT2 SMOKING ILLIDRUG/clparm;
run;

%end;
%end;

%mend;

%table3model4;

***Table 4 Sensitivity Analysis;

*Table 4 Model 1;
proc freq data=chis2020cleana2;
	table RESTLESSHL*MJ_MONTH;
run;

*Table 4 Model 1;
proc surveylogistic data=chis2020cleana2 varmethod=jackknife;
	weight rakedw0;
	repweight rakedw1-rakedw80/JKCOEFS=1;  
	class RESTLESSHL(ref="No restlessness")/param=ref;
	model MJ_MONTH(ref="No") = RESTLESSHL/clparm link=clogit;
run;

*Table 4 Model 2;
proc surveylogistic data=chis2020cleana2 varmethod=jackknife;
	weight rakedw0;
	repweight rakedw1-rakedw80/JKCOEFS=1;  
	class RESTLESSHL(ref="No restlessness") AGECAT(ref="65+") SRSEX(ref="Female")/param=ref;
	model MJ_MONTH(ref="No") = RESTLESSHL AGECAT SRSEX/clparm link=clogit;
run;

*Table 4 Model 3;
proc surveylogistic data=chis2020cleana2 varmethod=jackknife;
	weight rakedw0;
	repweight rakedw1-rakedw80/JKCOEFS=1;  
	class RESTLESSHL(ref="No restlessness") AGECAT(ref="65+") SRSEX(ref="Female") RACECAT(ref="Non-Hispanic White") 
	EDUCCAT(ref="University degree or higher") INCOMECAT(ref=">=$100,000") EMPLOYMENT(ref="Employed")
	MARIT(ref="Married") UR_CLRT2(ref="Urban")/param=ref;
	model MJ_MONTH(ref="No") = RESTLESSHL AGECAT SRSEX RACECAT EDUCCAT INCOMECAT EMPLOYMENT MARIT UR_CLRT2/clparm link=clogit;
run;

*Table 4 Model 4;
proc surveylogistic data=chis2020cleana2 varmethod=jackknife;
	weight rakedw0;
	repweight rakedw1-rakedw80/JKCOEFS=1;  
	class RESTLESSHL(ref="No restlessness") AGECAT(ref="65+") SRSEX(ref="Female") RACECAT(ref="Non-Hispanic White") 
	EDUCCAT(ref="University degree or higher") INCOMECAT(ref=">=$100,000") EMPLOYMENT(ref="Employed")
	MARIT(ref="Married") UR_CLRT2(ref="Urban") SMOKING(ref="Never smoked regularly") ILLIDRUG(ref="No")/param=ref;
	model MJ_MONTH(ref="No") = RESTLESSHL AGECAT SRSEX RACECAT EDUCCAT INCOMECAT EMPLOYMENT MARIT UR_CLRT2 SMOKING ILLIDRUG/clparm link=clogit;
run;
