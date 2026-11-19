# SAS-employee-data-integration
SAS 9.4 project integrating employee, address and donation datasets, with automated reporting, descriptive statistics and benefactor classification.
# Employee Data Integration & Donation Reporting | SAS

**Individual Academic Project | Data Preparation · Data Integration · Automated Reporting**

**Tools:** SAS 9.4  
**Techniques:** DATA Step, `MERGE` with `BY`, `PROC SORT`, `PROC MEANS`, `PROC REPORT`, `PROC FREQ`, SAS macros, ODS RTF

## Project Overview

This university project demonstrates how SAS can be used to integrate employee records from separate sources, prepare data for analysis and automate structured reports. The exercise combines **synthetic** organisational information, employee addresses and quarterly donation records using a shared employee identifier.

The aim is to turn fragmented administrative data into consistent summaries that support reporting by department and job role.

## Data and Workflow

The original exercise provides three SAS datasets:

- **Employee organisation:** employee identifiers, departments and job titles.
- **Employee addresses:** address fields linked to employees.
- **Employee donations:** donation amounts recorded across four quarters.

The script implements the following workflow:

1. **Inspect and integrate data.** Use `PROC CONTENTS` to review source tables, sort them on `Employee_ID`, and merge the records in a DATA step.
2. **Prepare the employee dataset.** Construct a formatted address with `CATX` and retain records with a non-empty address and at least one positive quarterly donation.
3. **Build employee-level reports.** Use `PROC REPORT` to display employee information and quarterly donation statistics, organised by department and job title.
4. **Summarise donation patterns.** Calculate quarterly mean, minimum and maximum donation amounts by department with `PROC MEANS`.
5. **Automate repeated reporting.** Use a parameterised SAS macro to generate equivalent quarterly summaries by job title.
6. **Classify benefactors.** Flag employees with donations in **more than one quarter** and a **positive-donation total greater than 30**, then summarise the distribution of their job roles with `PROC FREQ`.

## Outputs

The SAS program creates several intermediate tables and produces a consolidated **RTF report** using the SAS Output Delivery System (`ODS RTF`). The outputs illustrate structured reporting and the use of macros to reduce repeated code.

The final `PROC FREQ` table shows **how benefactors are distributed across job titles**. It does not estimate the proportion of benefactors within each job title, which would require a different denominator.

## Project Files

- [SAS analysis script](analysis/employee_data_reporting.sas) — data integration, reporting and macro-based summaries.
- [Data availability and setup](data/README.md) — required datasets and configuration.
- [Project presentation](presentation.pdf) — slides explaining the original workflow and outputs, using fictional example records.

## Reproducibility and Data Privacy

The source records in this academic exercise are **fictional**. The three original SAS datasets and generated employee-level reports are **not published**. The script is therefore shared as **documented project code**, not as a fully reproducible package.

To execute the program, supply the authorised `.sas7bdat` input datasets in a SAS-accessible directory and change the `project_dir` macro variable at the beginning of the script. The repository version has not been independently executed or validated against the original output.

The presentation is included because the employee names and addresses shown in the exercise are fictional. It documents the original analysis and results.

---

*Individual university project by Lisa Rigo. No real organisation or employer engagement is implied.*
