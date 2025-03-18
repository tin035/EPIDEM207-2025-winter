/**************************************************************************
Program Title: EPIDEM 207 Assignment 4 Data Dictionary Code
Date Created: 3/18/2025
Purpose: To create a data dictionary for Assignment 4
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
           5                      = "Not at allL"
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

proc contents data=chis2020cleana2;
run;

/***Create data dictionary***/

*Add a new attribute for potential values to the dataset;
proc datasets library=work;
modify chis2020cleana2;
	xattr set var
			AGECAT	     	(Values = "1 = 18-34, 2 = 35-49, 3 = 50-64, 4 = 65+")
			SRSEX        	(Values = "1 = Male, 2 = Female")
			RACECAT		 	(Values = "1 = Hispanic or Latino, 2 = Non-Hispanic White, 3 = Non-Hispanic Asian, 4 = Non-Hispanic Black, 5 = Non-Hispanic Other/Two or more races")
			EDUCCAT      	(Values = "1 = University degree or higher, 2 = Some college, 3 = High school or less")
			INCOMECAT    	(Values = "1 = Less than $50,000; 2 = $50,000 - $99,999; 3 = Greater than or equal to $100,000")
			EMPLOYMENT		(Values = "1 = Employed, 2= Unemployed")
			MARIT        	(Values = "1 = Married, 2 = Other/Seperated/Divorced/Living with Partner, 3 = Never Married")
			UR_CLRT2		(Values = "1 = Urban, 2 = Rural")
			SMOKING			(Values = "1 = Currently Smokes, 2 = Quit Smoking, 3 = Never Smoked Regularly")
			ILLIDRUG		(Values = "1 = Yes, 2 = No")
			AJ31			(Values = "1 = All of the time, 2 = Most of the time, 3 = Some of the time, 4 = A little of the time, 5 = Not at all")
			RESTLESSBIN		(Values = "1 = Yes, 2 = No")
			RESTLESSHL		(Values = "1 = High, 2 = Low, 3 = No restlessness")
			AC115			(Values = "1 = Yes, 2 = No")
			MJ_MONTH		(Values = "1 = Yes, 2 = No")
			AC117V2			(Values = "-1 = Never used marijuana, 1 = Did not use in last 30 days, 2 = 1-2 days, 3 = 3-5 days, 4 = 6-9 days, 5 = 10-19 days, 6 = 20-29 days, 7 = 30 days or more")
	;
quit;

ods output variables = varlist;
ods output ExtendedAttributesVar=exvarlist;

proc contents data=chis2020cleana2; run;	

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

data loc.datadictionarya2;
	merge varlist (drop=member pos num) exvarlist2(drop=_NAME_ _Label_);
	by variable;
run;

proc datasets library=loc;
modify datadictionarya2;
	label variable = "Variable Name"
		  type = "Variable Type"
		  len = "Variable Length"
		  label = "Variable Description"
		  format = "Name of Format Applied"
		  values = "Possible Values";
run;
quit;

proc sort data=loc.datadictionarya2;
	by variable;
run;

ods tagsets.excelxp file="C:\Users\u6045324\Desktop\EPIDEM 207 Files\CHIS Adult 2020\EPI207 Assignment 4 Data Dictionary.xls"
style=statistical;

proc print data=loc.datadictionarya2 noobs label; run;

ods tagsets.excelxp close;
