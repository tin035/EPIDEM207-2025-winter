/************************************************************************
Program Title: EPIDEM 207 Assignment 3 Code
Name:
Date: 2/26/2025
Purpose: Attempt to replicate Assignment 2 from another student
*************************************************************************/

libname loc "C:\Users\u6045324\Desktop\EPIDEM 207 Files\CHIS Adult 2023";

*Formats;
proc format;
	VALUE  YESNOF
	        1              = "Yes"
	        2              = "No"
	;
	VALUE  SRSEXF
	        1              = "Male"
	        2              = "Female"
	;
	VALUE AGECATF
		1		= "18-25"
		2		= "26-34"
		3		= "35-44"
		4		= "45-54"
		5		= "55-64"
		6		= "65+"
	;
	VALUE  RACECATF
	        1               = "Hispanic"
	        2               = "White, Non-Hispanic"
		3		= "African American, Non-Hispanic"
	        4               = "American Indian/Alaskan Native, NH"
	        5               = "Asian, Non-Hispanic"
	        6               = "Other/Two or more races";
	;
	VALUE SPDLVLF
		1		= "Acute SPD"
		2		= "Recent SPD"
		3		= "No SPD"
	; 
	VALUE EDULVLF
		1		= "Less than high school degree"
		2		= "High school graduate"
		3		= "Some college"
		4		= "College or more"
	;
	VALUE POVLVLF
		1		= "<100% FPL"
		2		= "100%-199% FPL"
		3		= "200%-399% FPL"
		4		= "=400% FPL"
	;
	VALUE MAR2F
		1		= "Married"
		2		= "Not married"
	;
	VALUE MAR3F
		1		= "Married"
		2		= "Other"
		3		= "Never married"
	;
run;


/***Data Cleaning***/
data loc.chis2023clean;
	set loc.adult(rename=(srsex=gender OMBSRR_P1=race BINGE30=binge DISTRESS=spd DSTRS30=spd_month DSTRS12=spd_year
		AF81=subuse_mental MARIT=marital_3cat WRKST_P1=emply_status RAKEDW0=weight));

		*Recode age;
		age_cat=.;
		if SRAGE_P1 = 18 then age_cat=1; 			*18-25;
		else if SRAGE_P1 in (26:30) then age_cat=2;		*26-34;
		else if SRAGE_P1 in (35:40) then age_cat=3;		*35-44;
		else if SRAGE_P1 in (45:50) then age_cat=4;		*45-54;
		else if SRAGE_P1 in (55:60) then age_cat=5;		*55-64;
		else if SRAGE_P1 in (65:85) then age_cat=6;		*65+;
		
		*Recode education level;
		edu_lvl=.;
		if AHEDC_P1 in (1:2) then edu_lvl=1;			*less than high school;
		else if AHEDC_P1=3 then edu_lvl=2;			*high school graduate (Ref);
		else if AHEDC_P1=4 then edu_lvl=3;			*some college;
		else if AHEDC_P1 in (5:9) then edu_lvl=4;		*college or more;	

		*Recode poverty level;
		poverty_lvl=.;
		if POVLL2_P1V2 < 1 then poverty_lvl=1;			*<100% FPL (Ref);
		else if 1<=POVLL2_P1V2<2 then poverty_lvl=2;		*100%-199% FPL;
		else if 2<=POVLL2_P1V2<4 then poverty_lvl=3;		*200%-399% FPL;
		else if 4<=POVLL2_P1V2 then poverty_lvl=4;		*= 400% FPL;


		*Recode has kids;
		kids=.;
		if FAMT4 in (3:4) then kids=1;				*has kids;
		else if FAMT4 in (1:2) then kids=2;			*no kids;

		*Recode martial status 2 categories;
		marital_2cat=.;
		if marital_3cat=1 then marital_2cat=1;			*Married;
		else if marital_3cat in (2:3) then marital_2cat=2;	*Not Married;

		*Code distress level;
		spd_lvl = .;
		if spd_month=1 then spd_lvl=1;				*acute spd;
 		else if spd_month=2 and spd_year=1 then spd_lvl=2;	*recent spd;
		else if spd_month=2 then spd_lvl=3;			*no spd;

		label 
		age_cat = "Age (5 cat)"
		gender = "Gender"
	  	race = "Race/Ethnicity (6 cat)"
	    	spd_lvl = "Serious Psychological Distress (3 cat)"
		spd_month = "SPD in the past month"
		spd_year = "SPD in the past year"
	   	edu_lvl = "Educational Attainment (3 cat)"
		poverty_lvl = "Poverty level (4 cat)"
		marital_3cat = "Marital Status (3 cat)"
		marital_2cat = "Marital Status (2 cat)"
	    	subuse_mental = "Needed Help for Substance/Mental Problem"
		kids = "Has kids"
		binge = "Binge drinking in the past 30 days"
		weight = "CHIS 2023 FINAL RAKED WEIGHT"
		;

		*Inclusion criteria;
		if spd_lvl ne .;
		if proxy ne .;
		if subuse_mental;

		*Formats for variables;
		format age_cat AGECATF. gender SRSEXF. race RACECATF. edu_lvl EDULVLF. poverty_lvl POVLVLF. marital_2cat MAR2F. marital_3cat MAR3F.
		spd_lvl SPDLVLF. binge spd_month spd_year subuse_mental kids YESNOF.;

		*Keep only variables required for analysis;
		keep age_cat gender race edu_lvl poverty_lvl marital_2cat marital_3cat spd_lvl binge spd_month spd_year subuse_mental kids weight;
		
run;


/***Create data dictionary***/

*Add a new attribute for potential values to the dataset;
proc datasets library=loc;
modify chis2023clean;
	xattr set var
		age_cat (Values = "1 = 18-25; 2 = 26-34; 3 = 35-44; 4 = 45-54; 5 = 55-64; 6 = 65+")
		gender (Values = "1 = Male; 2 = Female")
	    	race (Values = "1 = Hispanic; 2 = White, Non-Hispanic; 3 = African American, Non-Hispanic; 4 = American Indian/Alaskan Native, NH; 5 = Asian, Non-Hispanic; 6 = Other/Two ore more races")
	   	spd_lvl (Values = "1 = Acute SPD; 2 = Recent SPD; 3 = No SPD")
		spd_month (Values = "1 = Yes; 2= No")
		spd_year (Values = "1 = Yes; 2= No")
	    	edu_lvl (Values = "1 = Less than high school degree; 2 = High school graduate; 3 = Some college; 4 = College or more")
		poverty_lvl (Values = "1 = <100% FPL; 2 = 100%-199% FPL; 3 = 200-399% FPL; 4 = = 400% FPL")
		marital_3cat (Values = "1 = Married; 2 = Other; 3 = Never married")
		marital_2cat (Values = "1 = Married; 2 = Not married")
	    	subuse_mental (Values = "1 = Yes; 2= No")
		kids (Values = "1 = Yes; 2= No")
		binge (Values = "1 = Yes; 2= No")
	;
quit;

ods output variables = varlist;
ods output ExtendedAttributesVar=exvarlist;

proc contents data=loc.chis2023clean; run;	

proc sort data=exvarlist; by attributevariable; run;

proc transpose data=exvarlist out=exvarlist2;
	by attributevariable;
	id extendedattribute;
	var AttributeCharValue;
run;

proc datasets library=work;
modify exvarlist2;
	rename attributevariable = variable;
run;
quit;

proc sort data=varlist; by variable; run;
proc sort data=exvarlist2; by variable; run;

data loc.datadictionarya3;
	merge varlist (drop=member pos num) exvarlist2(drop=_NAME_ _Label_);
	by variable;
run;

proc datasets library=loc;
modify datadictionarya3;
	label variable = "Variable Name"
		  type = "Variable Type"
		  len = "Variable Length"
		  label = "Variable Description"
		  format = "Name of Format Applied"
		  values = "Possible Values";
run;
quit;

proc sort data=loc.datadictionarya3;
	by variable;
run;

ods tagsets.excelxp file="C:\Users\u6045324\Desktop\EPIDEM 207 Files\EPI207 Assignment 3 Data Dictionary.xls"
style=statistical;

proc print data=loc.datadictionarya3 noobs label; run;

ods tagsets.excelxp close;

/***Codebook Code***/

*Use the cleaned dataset for CHIS 2020 data and create temp dataset;
data chis2023clean;
	set loc.chis2023clean;
run;

*remove formatting for codebook;
proc datasets lib=work ;
   modify chis2023clean;
     attrib _all_ format=;
run;
quit;

*Creating codebook in excel;
ods excel file="C:\Users\u6045324\Desktop\EPIDEM 207 Files\EPI207 Assignment 3 Codebook.xlsx" options (sheet_interval="none" sheet_name="Variables of Interest");
ods noptitle;

*Macro for codebook;
%macro codebook;
%let varlist = age_cat gender race edu_lvl poverty_lvl marital_2cat marital_3cat spd_lvl binge spd_month spd_year subuse_mental kids;

*For the categorical variables;
%do i=1 %to %sysfunc(countw(&varlist));
%let var = %scan(&varlist, &i);

proc print data=loc.datadictionarya3 noobs;
	var variable label values;
	where variable="&var";
run;

proc freq data=chis2023clean;
	tables &var;
run;

proc sgplot data=chis2023clean;
	histogram &var/scale=count;
	title "&var";
run;

%end;
%mend;
%codebook;

ods excel close;


/***Table 1 Unweighted Descriptive Statistics***/

*Use the cleaned dataset for CHIS 2020 data and create temp dataset;
data chis2023clean;
	set loc.chis2023clean;
run;

*Since we are interested in marital status (binary), we will stratify our columns by marital_2cat;
proc sort data=chis2023clean;
	by marital_2cat;
run;

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

/***specify folder in which to store results***/

%let results=C:\Users\u6045324\Desktop\EPIDEM 207 Files;

%Table1(DSName=chis2023clean,
        GroupVar=marital_2cat,
        /*NumVars=DISTRESS,*/
        FreqVars= age_cat gender race spd_lvl edu_lvl poverty_lvl subuse_mental,
        Mean=Y,
        Median=N,
        Total=R,
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

ods csv file="&results.\EPIDEM207 Assignment 3 Table 1.csv";
title 'Table 1. The population sociodemographic characteristics of California Health Interview Survey
(CHIS) 2023.';
%Table1Print(DSname=EPIDEM207Table1,Space=Y)
ods csv close;
run;


/***Table 2: Marital Status (2 cat)***/

**SPD in last month;
proc freq data=loc.chis2023clean;
	table marital_2cat*spd_month;
run;

*crude model;
proc logistic data=loc.chis2023clean;
	class marital_2cat(ref="Married")/param=ref;
	model spd_month(ref="No") = marital_2cat;
run;

*adjusted model;
proc logistic data=loc.chis2023clean;
	class marital_2cat(ref="Married") age_cat(ref="18-25") gender(ref="Female") race edu_lvl poverty_lvl subuse_mental/param=ref;
	model spd_month(ref="No") = marital_2cat age_cat gender race edu_lvl poverty_lvl subuse_mental/;
run;

**SPD in last year;
proc freq data=loc.chis2023clean;
	table marital_2cat*spd_year;
run;

*crude model;
proc logistic data=loc.chis2023clean;
	class marital_2cat(ref="Married")/param=ref;
	model spd_year(ref="No") = marital_2cat;
run;

*adjusted model;
proc logistic data=loc.chis2023clean;
	class marital_2cat(ref="Married") age_cat(ref="18-25") gender(ref="Female") race edu_lvl poverty_lvl subuse_mental/param=ref;
	model spd_year(ref="No") = marital_2cat age_cat gender race edu_lvl poverty_lvl subuse_mental/;
run;


/***Table 3: Marital Status (3 cat)***/

**SPD in last month;
proc freq data=loc.chis2023clean;
	table marital_3cat*spd_month;
run;

*crude model;
proc logistic data=loc.chis2023clean;
	class marital_3cat(ref="Married")/param=ref;
	model spd_month(ref="No") = marital_3cat;
run;

*adjusted model;
proc logistic data=loc.chis2023clean;
	class marital_3cat(ref="Married") age_cat(ref="18-25") gender(ref="Female") race edu_lvl poverty_lvl subuse_mental/param=ref;
	model spd_month(ref="No") = marital_3cat age_cat gender race edu_lvl poverty_lvl subuse_mental/;
run;

**SPD in last year;
proc freq data=loc.chis2023clean;
	table marital_3cat*spd_year;
run;

*crude model;
proc logistic data=loc.chis2023clean;
	class marital_3cat(ref="Married")/param=ref;
	model spd_year(ref="No") = marital_3cat;
run;

*adjusted model;
proc logistic data=loc.chis2023clean;
	class marital_3cat(ref="Married") age_cat(ref="18-25") gender(ref="Female") race edu_lvl poverty_lvl subuse_mental/param=ref;
	model spd_year(ref="No") = marital_3cat age_cat gender race edu_lvl poverty_lvl subuse_mental/;
run;





