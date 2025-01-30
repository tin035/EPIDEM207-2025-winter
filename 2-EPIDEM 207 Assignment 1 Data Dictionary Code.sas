/**************************************************************************
Program Title: EPIDEM 207 Assignment 1 Data Dictionary Code
Programmer Name:
Date Created: 1/23/2025
Purpose: To create a data dictionary for the Matthews et al 2023 paper
that creates an excel file
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

proc contents data=chis2020clean;
run;

/***Create data dictionary***/

*Add a new attribute for potential values to the dataset;
proc datasets library=work;
modify chis2020clean;
	xattr set var
			CV7_1  		 	(Values = "1 = Yes, 2 = No") 
			CV7_2        	(Values = "1 = Yes, 2 = No")
			CV7_3        	(Values = "1 = Yes, 2 = No")
			CSTRESSCAT	 	(Values = "0 = No stressor, 1 = One stressor, 2 = Two or more stressors")
			DISTRESS     	(Values = "0 - 24")
			SRSEX        	(Values = "1 = Male, 2 = Female")
			AGECAT	     	(Values = "1 = 18-34, 2 = 35-49, 3 = 50-64, 4 = 65+")
			MARIT        	(Values = "1 = Married, 2 = Other/Seperated/Divorced/Living with Partner, 3 = Never Married")
			EDUCCAT      	(Values = "1 = University degree or higher, 2 = Some college, 3 = High school or less")
			INCOMECAT    	(Values = "1 = Less than $50,000; 2 = $50,000 - $99,999; 3 = Greater than or equal to $100,000")
			RACECAT		 	(Values = "1 = Hispanic or Latino, 2 = Non-Hispanic White, 3 = Non-Hispanic Asian, 4 = Non-Hispanic Black, 5 = Non-Hispanic Other/Two or more races")
			CITIZEN2     	(Values = "1 = U.S.-born citizen, 2 = Naturalized citizen, 3 = Non-citizen")
			INS				(Values = "1 = Insured, 2 = Uninsured")
			EMPLOYMENT		(Values = "1 = Employed, 2= Unemployed")
	;
quit;

ods output variables = varlist;
ods output ExtendedAttributesVar=exvarlist;

proc contents data=chis2020clean; run;	

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

data loc.datadictionary;
	merge varlist (drop=member pos num) exvarlist2(drop=_NAME_ _Label_);
	by variable;
run;

proc datasets library=loc;
modify datadictionary;
	label variable = "Variable Name"
		  type = "Variable Type"
		  len = "Variable Length"
		  label = "Variable Description"
		  format = "Name of Format Applied"
		  values = "Possible Values";
run;
quit;

proc sort data=loc.datadictionary;
	by variable;
run;

ods tagsets.excelxp file="C:\Users\u6045324\Desktop\EPIDEM 207 Files\CHIS Adult 2020\EPI207 Assignment 1 Data Dictionary.xls"
style=statistical;

proc print data=loc.datadictionary noobs label; run;

ods tagsets.excelxp close;
