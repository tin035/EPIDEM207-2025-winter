/**************************************************************************
Program Title: EPIDEM 207 Assignment 4 Codebook Code
Date Created: 3/18/2025
Purpose: To create a codebook for Assignment 4
**************************************************************************/

libname loc "C:\Users\u6045324\Desktop\EPIDEM 207 Files\CHIS Adult 2020"; 

*Formats from CHIS Proc format file and new formats;
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

*remove formatting for codebook;
proc datasets lib=work ;
   modify chis2020cleana2;
     attrib _all_ format=;
run;
quit;

/***Codebook, with unweighted frequencies***/

ods excel file="C:\Users\u6045324\Desktop\EPIDEM 207 Files\CHIS Adult 2020\EPI207 Assignment 4 Codebook.xlsx" options (sheet_interval="none" sheet_name="Variables of Interest");
ods noptitle;

*Macro for codebook;
%macro codebook;
%let varlist = AGECAT SRSEX RACECAT EDUCCAT INCOMECAT EMPLOYMENT MARIT UR_CLRT2 SMOKING ILLIDRUG AJ31 RESTLESSBIN RESTLESSHL AC115 MJ_MONTH AC117V2;

*For the categorical variables;
%do i=1 %to %sysfunc(countw(&varlist));
%let var = %scan(&varlist, &i);

proc print data=loc.datadictionarya2 noobs;
	var variable label values;
	where variable="&var";
run;

proc freq data=chis2020cleana2;
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

proc print data=loc.datadictionarya2 noobs;
	var variable label values;
	where variable="&var";
run;

proc sgplot data=chis2020cleana2;
	histogram &var;
	title "&var";
run;

%end;

%mend;

%codebook;

ods excel close;

/***Codebook, with weighted frequencies***/

ods excel file="C:\Users\u6045324\Desktop\EPIDEM 207 Files\CHIS Adult 2020\EPI207 Assignment 4 Codebook Weighted.xlsx" options (sheet_interval="none" sheet_name="Variables of Interest");
ods noptitle;

*macro for weighted frequencies codebook;
%macro codebookweighted;
%let varlist = AGECAT SRSEX RACECAT EDUCCAT INCOMECAT EMPLOYMENT MARIT UR_CLRT2 SMOKING ILLIDRUG AJ31 RESTLESSBIN RESTLESSHL AC115 MJ_MONTH AC117V2;

*For the categorical variables;
%do i=1 %to %sysfunc(countw(&varlist));
%let var = %scan(&varlist, &i);

proc print data=loc.datadictionarya2 noobs;
	var variable label values;
	where variable="&var";
run;

proc surveyfreq data=chis2020cleana2 varmethod=jackknife;
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

proc print data=loc.datadictionarya2 noobs;
	var variable label values;
	where variable="&var";
run;

proc sgplot data=chis2020cleana2;
	histogram &var;
	title "&var";
run;

%end;

%mend;

%codebookweighted;

ods excel close;


