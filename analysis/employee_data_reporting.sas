/*
  Employee Data Integration and Donation Reporting | SAS 9.4
  Individual academic project

  Requirements: three SAS input datasets in a library folder:
    employee_organization.sas7bdat
    employee_addresses.sas7bdat
    employee_donations.sas7bdat

  Set project_dir to an accessible directory in your SAS environment.
  The source datasets are not distributed with this repository.
  This version has not been executed or revalidated independently.
*/

%let project_dir = /path/to/your/SAS/project/folder;
libname data "&project_dir";


/* Three separate SAS datasets are provided:*/
proc contents data=data.employee_organization;
run;

proc contents data=data.employee_addresses;
run;

proc contents data=data.employee_donations;
run;


/* sort datasets before the merging */
proc sort data=data.employee_organization out=employee_organization;
    by Employee_ID;
run;

proc sort data=data.employee_addresses out=employee_addresses;
    by Employee_ID;
run;

proc sort data=data.employee_donations out=employee_donations;
    by Employee_ID;
run;

/* merge datasets */
data Employee;
    merge employee_organization employee_addresses employee_donations;
    by Employee_ID;
run;

/* to see the merged data */
proc print data=Employee;
run;


/* create address as a unique object */
data Employee_address;
    set Employee;
    ADDRESS = catx(', ', Street_Number, Street_Name, City, State);
run;

/* keep only employees with registered address and at least one donation */
data Employee_final;
    set Employee_address;
    if ADDRESS ne "" and
       (Qtr1 > 0 or Qtr2 > 0 or Qtr3 > 0 or Qtr4 > 0);
run;


/* First report */
ods rtf file="&project_dir/report.rtf";
title "First report of employees with address and donation";

proc report data=Employee_final headline;
    columns Employee_ID Department ADDRESS;

    define Employee_ID / display "Employee ID";
    define Department / display "Department";
    define ADDRESS    / display "Complete Address";
run;

title;

/* Second report */


/* sort data */
proc sort data=Employee_final out=Employee_sorted2;
    by Department Job_Title Employee_ID;
run;

/* create donation summary variables */
data Employee_report2;
    set Employee_sorted2;
    DON_MEAN = mean(Qtr1, Qtr2, Qtr3, Qtr4);
    DON_MAX  = max(Qtr1, Qtr2, Qtr3, Qtr4);
    DON_MIN  = min(Qtr1, Qtr2, Qtr3, Qtr4);
run;


title "Second report by department and job role";

proc report data=Employee_report2 ;
    columns Department Job_Title Employee_ID DON_MEAN DON_MAX DON_MIN;

    define Department  / group "Department";
    define Job_Title   / group "Job Role";
    define Employee_ID / display "Employee ID";
    define DON_MEAN    / display "Mean Donation";
    define DON_MAX     / display "Max Donation";
    define DON_MIN     / display "Min Donation";
run;

title;

/* Table: mean, min and max donation by department and period */
/* sort by department */
proc sort data=Employee_final out=Employee_dep;
    by Department;
run;

/* Qtr1 */
proc means data=Employee_dep ;
    by Department;
    var Qtr1;
    output out=dept_qtr1 mean=Mean min=Min max=Max;
run;

data dept_qtr1;
    set dept_qtr1;
    Period = "Qtr1";
run;

/* Qtr2 */
proc means data=Employee_dep noprint;
    by Department;
    var Qtr2;
    output out=dept_qtr2 mean=Mean min=Min max=Max;
run;

data dept_qtr2;
    set dept_qtr2;
    Period = "Qtr2";
run;

/* Qtr3 */
proc means data=Employee_dep noprint;
    by Department;
    var Qtr3;
    output out=dept_qtr3 mean=Mean min=Min max=Max;
run;

data dept_qtr3;
    set dept_qtr3;
    Period = "Qtr3";
run;

/* Qtr4 */
proc means data=Employee_dep noprint;
    by Department;
    var Qtr4;
    output out=dept_qtr4 mean=Mean min=Min max=Max;
run;

data dept_qtr4;
    set dept_qtr4;
    Period = "Qtr4";
run;

/* combine quarter tables */
data Department_table;
    set dept_qtr1 dept_qtr2 dept_qtr3 dept_qtr4;
    keep Department Period Mean Min Max;
run;

/* Use proper variables to print inside a report.  */
title "Donation summary by department and period";

proc report data=Department_table ;
    columns Department Period Mean Min Max;

    define Department / group "Department";
    define Period     / display "Period";
    define Mean       / display "Mean";
    define Min        / display "Min";
    define Max        / display "Max";
run;

title;


/* Same operation by job role using a macro */

%macro donation_table(groupvar=, outtable=);

proc sort data=Employee_final out=Employee_sort;
    by &groupvar;
run;

/* Qtr1 */
proc means data=Employee_sort noprint;
    by &groupvar;
    var Qtr1;
    output out=&outtable._qtr1 mean=Mean min=Min max=Max;
run;

data &outtable._qtr1;
    set &outtable._qtr1;
    Period = "Qtr1";
run;

/* Qtr2 */
proc means data=Employee_sort noprint;
    by &groupvar;
    var Qtr2;
    output out=&outtable._qtr2 mean=Mean min=Min max=Max;
run;

data &outtable._qtr2;
    set &outtable._qtr2;
    Period = "Qtr2";
run;

/* Qtr3 */
proc means data=Employee_sort noprint;
    by &groupvar;
    var Qtr3;
    output out=&outtable._qtr3 mean=Mean min=Min max=Max;
run;

data &outtable._qtr3;
    set &outtable._qtr3;
    Period = "Qtr3";
run;

/* Qtr4 */
proc means data=Employee_sort noprint;
    by &groupvar;
    var Qtr4;
    output out=&outtable._qtr4 mean=Mean min=Min max=Max;
run;

data &outtable._qtr4;
    set &outtable._qtr4;
    Period = "Qtr4";
run;

/* combine all quarters */
data &outtable;
    set &outtable._qtr1
        &outtable._qtr2
        &outtable._qtr3
        &outtable._qtr4;
    keep &groupvar Period Mean Min Max;
run;

title "Donation summary by job role";

proc report data=&outtable ;
    columns &groupvar Period Mean Min Max;

    define &groupvar / group;
    define Period    / display "Period";
    define Mean      / display  "Mean";
    define Min       / display "Min";
    define Max       / display "Max";
run;

title;

%mend;

%donation_table(groupvar=Job_Title, outtable=JobRole_table);

/* create COUNT_DON, total donation and benefactor flag */
data Employee_benefactor;
    set Employee_final;

    array qtr[4] Qtr1 Qtr2 Qtr3 Qtr4;
     /* inizialise factor */
    COUNT_DON = 0;
    TOT_DON = 0;

    do i = 1 to 4;
        if qtr[i] > 0 then do;
            COUNT_DON = COUNT_DON + 1; /*counts the number of donations made*/
            TOT_DON = TOT_DON + qtr[i]; /* total amount */
        end;
    end;

    if COUNT_DON > 1 and TOT_DON > 30 then BNFL = "Y";
    else BNFL = "N";

    drop i;
run;

/* controllo*/
/* proc print data=Employee_benefactor(obs=20);
    var Employee_ID Job_Title Qtr1 Qtr2 Qtr3 Qtr4 COUNT_DON TOT_DON BNFL;
run;*/

/* Count job roles among benefactors only.
   Percent = share among benefactors, NOT benefactor rate within each job role. */
proc freq data=Employee_benefactor noprint;
    where BNFL = "Y";
    tables Job_Title / out=Role_BNFL_Freq;
run;

proc sort data=Role_BNFL_Freq;
    by descending count;
run;

title "Job roles associated with benefactors";

proc report data=Role_BNFL_Freq ;
    columns Job_Title Count Percent;

    define Job_Title / display "Job Role";
    define Count     / display "Frequency";
    define Percent   / display "Percent";
run;

title;
ods rtf close;



