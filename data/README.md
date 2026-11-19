# Data availability

The three original SAS tables are not distributed in this repository:

- `employee_organization.sas7bdat`
- `employee_addresses.sas7bdat`
- `employee_donations.sas7bdat`

The code requires an SAS library containing those tables. Set `%let project_dir = ...;` in `analysis/employee_data_reporting.sas` to the path of that library. The output RTF file will be written to the same location.

