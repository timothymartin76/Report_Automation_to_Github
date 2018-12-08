Sys.setenv(JAVA_HOME='C:\\Program Files\\Java\\jdk1.6.0_45')

library(scales)
library(ggplot2)
library(reshape2)
library(lubridate)
library(tidyr)
library(plotly)
library(dplyr)
##library(leaflet)
##library(flexdashboard)
##library(shiny)
library(DT)
library(RJDBC)

setwd("C:/Filings_Comparison/Data")

drv <- JDBC("oracle.bi.jdbc.AnaJdbcDriver","jarfile.jar")
conn <- dbConnect(drv, "jdbc:oraclebi://sprdorabiw-hq.buildings.nycnet:9703/", "username", "password")


### BIS filings data from Oracle
mydata<- dbGetQuery(conn, "SELECT \"- Pre-File Date (A Status)\".\"Pre-File Date\" saw_0, \"- Application Process Date / Data Entry Complete Date ( D Status)\".\"Application Process Date\" saw_1, CASE WHEN \"- 15 - Construction Equipment\".Fence  =  'Y' THEN 'Fence' WHEN \"- 15 - Construction Equipment\".\"Supported Scaffold\" = 'Y' THEN 'Scaffold' WHEN \"- 15 - Construction Equipment\".\"Sidewalk Shed\" ='Y' THEN 'Sidewalk Shed' WHEN\"- Key Job Information (Job Number and Status)\".\"Job Type\" = 'SG' THEN 'Sign'  WHEN \"- 6 - Work Types\".\"Plumbing Flag\" =  'X' THEN 'Plumbing' WHEN \"- 6 - Work Types\".\"Standpipe Flag\" =  'X' THEN 'Standpipe' WHEN \"- 6 - Work Types\".\"Sprinkler Flag\" =  'X' THEN 'Sprinkler' END saw_2, \"- Key Job Information (Job Number and Status)\".\"Job Number\" saw_3, \"- Key Job Information (Job Number and Status)\".\"Job Document Number\" saw_4, \"- Key Job Information (Job Number and Status)\".\"Job Type\" saw_5, \"- Key Job Information (Job Number and Status)\".\"Current Job Status\" saw_6, \"- Key Job Information (Job Number and Status)\".\"Withdrawal Description\" saw_7, \"- 4 - Filing Status\".\"Filing Type Description\" saw_8, case WHEN \"- 4 - Filing Status\".\"Pro-Cert Description\" = 'Application via Plan Examination' then 'Standard Plan Exam' else \"- 4 - Filing Status\".\"Pro-Cert Description\" end saw_9, \"- 4 - Filing Status\".\"Self Certify Objections Only\" saw_10, case WHEN \"- 5 - Job Type\".\"Directive 14 Acceptance (Flag)\" = 'N' then 'Non-Dir' WHEN \"- 5 - Job Type\".\"Directive 14 Acceptance (Flag)\" IN ('X', 'Y') then 'Dir-14' else \"- 5 - Job Type\".\"Directive 14 Acceptance (Flag)\" end saw_11, \"- 6 - Work Types\".\"Curb Cut Flag\" saw_12, \"- 6 - Work Types\".\"Antennae Flag\" saw_13, \"- 6 - Work Types\".\"OT Code\" saw_14, \"- 6 - Work Types\".\"OT Code Description\" saw_15, \"- 15 - Construction Equipment\".Fence saw_16, \"- 15 - Construction Equipment\".\"Supported Scaffold\" saw_17, \"- 15 - Construction Equipment\".\"Sidewalk Shed\" saw_18, \"- Job Flags\".\"NYC Development HUB Flag Description\" saw_19, \"- Job Flags\".\"Hub Self Service Application Filed\" saw_20, \"- Job Flags\".\"Hub Full Service Application Filed\" saw_21, CASE WHEN (\"- Job Flags\".\"NYC Development HUB Flag Description\" = 'Not Involved') AND (\"- Job Flags\".\"Hub Self Service Application Filed\" <> 'Y') AND \"- Job Flags\".\"Hub Full Service Application Filed\" <> 'Y' THEN 'Borough Office' WHEN  \"- Job Flags\".\"Hub Self Service Application Filed\" = 'Y' THEN 'HUB SS'  WHEN \"- Job Flags\".\"Hub Full Service Application Filed\" = 'Y' THEN 'HUB FS' WHEN \"- Job Flags\".\"NYC Development HUB Flag Description\" = 'Loaded At Hub' THEN 'DEV HUB'  WHEN  \"- Job Flags\".\"NYC Development HUB Flag Description\" = 'Added In-Flight' THEN 'DEV HUB' END saw_22, \"- 1- Location Information\".\"Borough Name\" saw_23, \"- 2 - Applicant Information\".\"Applicant First Name\" saw_24, \"- 2 - Applicant Information\".\"Applicant Last Name\" saw_25, \"- 2 - Applicant Information\".\"Applicant Business Name\" saw_26, \"- 2 - Applicant Information\".\"Applicant License Number\" saw_27, \"- Non PW-1 Fields\".J_PRE_FILING_OPER_ID saw_28, \"- Pre-File Date (A Status)\".D_YEAR saw_29, \"- Pre-File Date (A Status)\".D_CAL_MONTH_VERBOSE saw_30, \"- 6 - Work Types\".\"Plumbing Flag\" saw_31, \"- 6 - Work Types\".\"Standpipe Flag\" saw_32, \"- 6 - Work Types\".\"Sprinkler Flag\" saw_33, \"- 4 - Filing Status\".PAA saw_34 FROM \"DOB - Job Filings, v 3.0\" 

WHERE ((\"- 15 - Construction Equipment\".Fence IN ('Y', 'X')) OR (\"- 15 - Construction Equipment\".\"Supported Scaffold\" = 'Y') OR (\"- 15 - Construction Equipment\".\"Sidewalk Shed\" IN ('X', 'Y')) OR (\"- Key Job Information (Job Number and Status)\".\"Job Type\" = 'SG') OR (\"- 6 - Work Types\".\"Plumbing Flag\" IN ('P', 'X')) OR (\"- 6 - Work Types\".\"Standpipe Flag\" = 'X') OR (\"- 6 - Work Types\".\"Sprinkler Flag\" = 'X') OR (\"- 6 - Work Types\".\"OT Code Description\" LIKE '%antenna%') OR (\"- 6 - Work Types\".\"OT Code Description\" LIKE '%curb%') OR (\"- 6 - Work Types\".\"Antennae Flag\" IN ('X', 'Y')) OR (\"- 6 - Work Types\".\"Curb Cut Flag\" IN ('Q', 'X'))) AND (\"- 4 - Filing Status\".PAA <> 'Y') AND (\"- 4 - Filing Status\".\"Filing Type Description\" = 'Initial Filing') AND (\"- Application Process Date / Data Entry Complete Date ( D Status)\".\"Application Process Date\" >= timestamp '2017-01-01 00:00:00') ORDER BY saw_0, saw_1, saw_2, saw_3, saw_4, saw_5, saw_6, saw_7, saw_8, saw_9, saw_10, saw_11, saw_12, saw_13, saw_14, saw_15, saw_16, saw_17, saw_18, saw_19, saw_20, saw_21, saw_22, saw_23, saw_24, saw_25, saw_26, saw_27, saw_28, saw_29, saw_30, saw_31, saw_32, saw_33, saw_34")


## Change column names
names(mydata)<- c("Prefile.Date", "Application.Process.Date", "Work.Type", "Job.Number", "Job.Document.Number", "Job.Type", "Current.Job.Status", "Withdrawal.Description", "Filing.Type.Description", "Filed.As", "Self.Cert.Objections", "D14", "Curb.Cut.Flag", "Antenna.Flag", "OT.Code", "OT.Code.Description", "Fence", "Supported.Scaffold", "Sidewalk.Shed", "NYC.Development.HUB.Flag.Description", "Hub.Self.Service", "Hub.Full.Service", "Hub.Job", "Borough.Name", "Applicant.First.Name", "Applicant.Last.Name", "Applicant.Business.Name", "Applicant.License.Number", "PRE_FILING_ID", "D_YEAR", "D_MONTH","Plumbing.Flag", "Standpipe.Flag", "Sprinkler.Flag", "PAA")



### DOB NOW filings data from Oracle
mydata2<- dbGetQuery(conn, "SELECT \"- Filing Date\".Date saw_0, \"Job Filing\".\"Job Number\" saw_1, \"Job Filing\".FilingStatusType saw_2, \"Job Filing\".JobType saw_3, \"Job Filing\".CurrentFilingStatus saw_4, \"Job Filing\".CPEAssignedDate saw_5, \"Job Filing\".CreatedOn saw_6, \"Job Filing\".ProfessionalCertificate saw_7, \"Job Filing\".Bin saw_8, \"Job Filing\".Block saw_9, \"Job Filing\".Lot saw_10, \"Job Filing\".\"House Number\" saw_11, \"Job Filing\".\"Street Name\" saw_12, \"Job Filing\".Address saw_13, \"Job Filing\".Borough saw_14, \"Job Filing\".\"Community Board\" saw_15, \"Work Type\".\"Work Type Name\" saw_16, \"- CPE Assigned Date\".Date saw_17, \"Work Permit\".\"Permit Issued Date\" saw_18, \"Work Permit\".\"Permit Expiration Date\" saw_19, \"Work Permit\".\"Plan Aprroved Date\" saw_20, \"Work Permit\".\"Permit Signed Off Date\" saw_21 FROM \"DOB NOW - Build\" WHERE (\"Job Filing\".statuscode = 'Active') AND (\"Job Filing\".FilingStatusType = 'New Job Filing') AND (\"- Filing Date\".Date >= timestamp '2017-01-01 00:00:00') ORDER BY saw_0, saw_1, saw_2, saw_3, saw_4, saw_5, saw_6, saw_7, saw_8, saw_9, saw_10, saw_11, saw_12, saw_13, saw_14, saw_15, saw_16, saw_17, saw_18, saw_19, saw_20, saw_21")

## Change column names
names(mydata2)<- c("Filing.Date", "Job.Number", "Filing.Type", "JobType", "Filing.Status", "CPEAssignedDate", "CreatedOn", "ProfessionalCertificate", "Bin", "Block", "Lot", "House.Number", "Street.Name", "Address", "Borough", "Community.Board", "Work.Type.Name", "Date", "Permit.Issued.Date", "Permit.Expiration.Date", "Plan.Approved.Date", "Permit.Signed.Off.Date")

### Elevators BIS data
Elevators_BIS<- dbGetQuery(conn, "SELECT \"- IN_INSP_DATE\".D_DATE saw_0, \"- Basic Inspection Data\".\"Device Number\" saw_1, \"- Basic Inspection Data\".HOUSE_NUMBER saw_2, \"- Basic Inspection Data\".STREET_NAME saw_3, \"- Basic Inspection Data\".BORO_BLOCK_LOT saw_4, \"- Basic Inspection Data\".\"Borough Name\" saw_5, \"- DOB Elevator Device\".\"Device Status\" saw_6, \"- Facts\".\"Count Distinct Elevator Inspections\" saw_7, \"- DOB Elevator Device\".\"Device Type\" saw_8, \"- DOB Elevator Device\".\"Device Type Description\" saw_9 FROM \"DOB - Inspections - Elevators\" WHERE (\"- IN_INSP_DATE\".D_DATE >= date '2017-01-01') AND (case WHEN \"- Basic Inspection Data\".\"Inspection Types Description\" = 'SPECIAL' then 'Elevator Acceptance Test' else \"- Basic Inspection Data\".\"Inspection Types Description\" end = 'Elevator Acceptance Test') ORDER BY saw_0, saw_1, saw_2, saw_3, saw_4, saw_5, saw_6, saw_8, saw_9")

## Change column names (Elevators BIS)
names(Elevators_BIS)<- c("Inspection.Date", "Device.Number", "House.Number", "Street.Name", "BBL", "Borough", "Device.Status", "Count.Distinct", "Device.Type", "Device.Type.Description")


## Elevators_DOB_NOW
Elevators_DOB_NOW<- dbGetQuery(conn, "SELECT \"- Filing Date\".Date saw_0, \"- Filing Date\".\"Year\" saw_1, \"- Filing Date\".\"Month\" saw_2, \"- Application Highlights\".\"Filing Type\" saw_3, \"- Application Highlights\".\"Job Number\" saw_4 FROM \"DOB NOW - Build - Elevators\" WHERE \"- Filing Date\".Date >= timestamp '2017-01-01 00:00:00' ORDER BY saw_0, saw_1, saw_2, saw_3, saw_4")

## Change column names (Elevators DOB NOW)
names(Elevators_DOB_NOW)<- c("Filing.Date", "Year", "Month", "Filing.Type", "Job.Number")


## Electrical BIS filings
Electrical_BIS<- dbGetQuery(conn, "SELECT \"- Electrical Application Key Fields\".\"Application Number\" saw_0, \"- (ED 16A, 1) License\".Electrical_License_Number saw_1, case WHEN \"- Electrical Application Key Fields\".\"Application Status Description\" IN ('ADMINISTRATIVELY CLOSED (MINOR WORK)', 'CLOSED/CANCELLED', 'COMPLETED') then 'Closed' WHEN \"- Electrical Application Key Fields\".\"Application Status Description\" IN ('ASSIGNED TO BORO MANAGER', 'ASSIGNED TO INSPECTOR', 'AWAITING INSPECTION REQUEST', 'HPD JOB AWAIT INSP REQ', 'LOCATION PROBLEM', 'NO ACCESS', 'NO JOB PROGRESS', 'SIGN SHOP JOB AWAIT INSP REQ', 'VIOLATION PENDING AT OWNER', 'VIOLATN PENDING AT CONTRACTOR') then 'Open' else \"- Electrical Application Key Fields\".\"Application Status Description\" end saw_2, \"- Electrical Application Key Fields\".\"Application Status Description\" saw_3, \"- Electrical Application Key Fields\".\"Active Code Descritpion\" saw_4, \"- Electrical Application Key Fields\".\"E-Filed Flag\" saw_5, \"- (ED 16A, 5) Job Location\".\"Borough Name\" saw_6, \"- (ED 16A, 5) Job Location\".BIN saw_7, \"- (ED 16A, 5) Job Location\".\"House Number\" saw_8, \"- (ED 16A, 5) Job Location\".\"Street Name\" saw_9, \"- Initial Entry Date\".D_DATE saw_10, \"Electrical Master Facts\".\"Count Distinct Applications\" saw_11 FROM \"DOB - Inspections - Electrical, v2.0\" WHERE (\"- Initial Entry Date\".D_DATE >= date '2017-01-01') AND (\"- Electrical Application Key Fields\".\"Application Status Description\" <> '(SEE DOB NOW BUILD)') ORDER BY saw_0, saw_1, saw_2, saw_3, saw_4, saw_5, saw_6, saw_7, saw_8, saw_9, saw_10")

## Change column names (Electrical BIS)
names(Electrical_BIS)<- c("Application.Number", "License.Number", "Open.Closed", "Description", "Active.Code.Description", "Efile", "Borough", "BIN", "House.Number", "Street.Name", "Filing.Date", "Count")




## Electrical DOB NOW
Electrical_DOB_NOW<- dbGetQuery(conn, "SELECT \"- Filing Date\".Date saw_0, \"- Fields\".Filingstatus saw_1, \"- Fields\".Filingstatustype saw_2, \"- Fields\".\"Ed16a  Job Filing Number\" saw_3 FROM \"DOB NOW - Build - Electrical\" WHERE (\"- Filing Date\".Date >= timestamp '2017-01-01 00:00:00') AND (\"- Fields\".Filingstatustype = 'New Job Filing') ORDER BY saw_0, saw_1, saw_2, saw_3")

## Change column names (Electrical DOB NOW)
names(Electrical_DOB_NOW)<- c("Filing.Date", "Filing.Status", "Filing.Status.Type", "ED16a.Job.Number")






## Read in BIS data 
## mydata<- read.csv("BIS.csv", header=T, sep=',')
mydata$Application.Process.Date <- ymd_hms(mydata$Application.Process.Date)
mydata$Application.Process.Date<- floor_date(mydata$Application.Process.Date, "month")

## Read in DOB NOW data 
##mydata2<- read.csv("DOB_NOW.csv", header=T, sep=',')
## Remove duplicate job numbers
mydata2<- mydata2[!duplicated(mydata2[c('Job.Number')]),]





########## PLUMBING
## use dplyr to aggregate by month
Plumbing_BIS<- mydata %>% count(Plumbing.Flag, Application.Process.Date)
## Delete null values
Plumbing_BIS<- Plumbing_BIS[!(is.na(Plumbing_BIS$Plumbing.Flag) | Plumbing_BIS$Plumbing.Flag==""), ]
## Delete first column
Plumbing_BIS <- Plumbing_BIS[ c(2:3) ]

## Subset plumbing jobs
Plumbing_DOB_NOW <- subset(mydata2, Work.Type.Name == c('Plumbing'))
Plumbing_DOB_NOW$Filing.Date <- ymd_hms(Plumbing_DOB_NOW$Filing.Date)
Plumbing_DOB_NOW$Filing.Date<- floor_date(Plumbing_DOB_NOW$Filing.Date, "month")
Plumbing_DOB_NOW<- Plumbing_DOB_NOW %>% count(Filing.Date)

## Merge the dateframes by month
names(Plumbing_BIS)<- c("Filing.Date", "Volume")
names(Plumbing_DOB_NOW)<- c("Filing.Date", "Volume")
## Perform outer merge
Plumbing_Merge<- merge(Plumbing_BIS,Plumbing_DOB_NOW,by="Filing.Date", all=T)
names(Plumbing_Merge)<- c("FDate", "BIS", "DOB NOW")

#### new CSVs
write.csv(Plumbing_Merge, "Plumbing_Merge.csv", row.names=FALSE, na="")





########## FENCE
## use dplyr to aggregate by month
Fence_BIS<- mydata %>% count(Fence, Application.Process.Date)
## Delete null values
Fence_BIS<- Fence_BIS[!(is.na(Fence_BIS$Fence) | Fence_BIS$Fence==""), ]
## Delete first column
Fence_BIS <- Fence_BIS[ c(2:3) ]

## Subset fence jobs
Fence_DOB_NOW <- subset(mydata2, Work.Type.Name == c('Fence'))
Fence_DOB_NOW$Filing.Date <- ymd_hms(Fence_DOB_NOW$Filing.Date)
Fence_DOB_NOW$Filing.Date<- floor_date(Fence_DOB_NOW$Filing.Date, "month")
Fence_DOB_NOW<- Fence_DOB_NOW %>% count(Filing.Date)

## Merge the dateframes by month
names(Fence_BIS)<- c("Filing.Date", "Volume")
names(Fence_DOB_NOW)<- c("Filing.Date", "Volume")
## Perform outer merge
Fence_Merge<- merge(Fence_BIS,Fence_DOB_NOW,by="Filing.Date", all=T)
names(Fence_Merge)<- c("FDate", "BIS", "DOB NOW")

#### new CSVs
write.csv(Fence_Merge, "Fence_Merge.csv", row.names=FALSE, na="")




########## SHED
## use dplyr to aggregate by month
Shed_BIS<- mydata %>% count(Sidewalk.Shed, Application.Process.Date)
## Delete null values
Shed_BIS<- Shed_BIS[!(is.na(Shed_BIS$Sidewalk.Shed) | Shed_BIS$Sidewalk.Shed==""), ]
## Delete first column
Shed_BIS <- Shed_BIS[ c(2:3) ]

## Subset Shed jobs
Shed_DOB_NOW <- subset(mydata2, Work.Type.Name == c('Side Walk Shed'))
Shed_DOB_NOW$Filing.Date <- ymd_hms(Shed_DOB_NOW$Filing.Date)
Shed_DOB_NOW$Filing.Date<- floor_date(Shed_DOB_NOW$Filing.Date, "month")
Shed_DOB_NOW<- Shed_DOB_NOW %>% count(Filing.Date)

## Merge the dateframes by month
names(Shed_BIS)<- c("Filing.Date", "Volume")
names(Shed_DOB_NOW)<- c("Filing.Date", "Volume")
## Perform outer merge
Shed_Merge<- merge(Shed_BIS,Shed_DOB_NOW,by="Filing.Date", all=T)
names(Shed_Merge)<- c("FDate", "BIS", "DOB NOW")

#### new CSV
write.csv(Shed_Merge, "Shed_Merge.csv", row.names=FALSE, na="")







########## STANDPIPE
## use dplyr to aggregate by month
Standpipe_BIS<- mydata %>% count(Standpipe.Flag, Application.Process.Date)
## Delete null values
Standpipe_BIS<- Standpipe_BIS[!(is.na(Standpipe_BIS$Standpipe.Flag) | Standpipe_BIS$Standpipe.Flag==""), ]
## Delete first column
Standpipe_BIS <- Standpipe_BIS[ c(2:3) ]

## Subset Standpipe jobs
Standpipe_DOB_NOW <- subset(mydata2, Work.Type.Name == c('Standpipe'))
Standpipe_DOB_NOW$Filing.Date <- ymd_hms(Standpipe_DOB_NOW$Filing.Date)
Standpipe_DOB_NOW$Filing.Date<- floor_date(Standpipe_DOB_NOW$Filing.Date, "month")
Standpipe_DOB_NOW<- Standpipe_DOB_NOW %>% count(Filing.Date)

## Merge the dateframes by month
names(Standpipe_BIS)<- c("Filing.Date", "Volume")
names(Standpipe_DOB_NOW)<- c("Filing.Date", "Volume")
## Perform outer merge
Standpipe_Merge<- merge(Standpipe_BIS,Standpipe_DOB_NOW,by="Filing.Date", all=T)
names(Standpipe_Merge)<- c("FDate", "BIS", "DOB NOW")

#### new CSVs
write.csv(Standpipe_Merge, "Standpipe_Merge.csv", row.names=FALSE, na="")





########## SPRINKLER
## use dplyr to aggregate by month
Sprinkler_BIS<- mydata %>% count(Sprinkler.Flag, Application.Process.Date)
## Delete null values
Sprinkler_BIS<- Sprinkler_BIS[!(is.na(Sprinkler_BIS$Sprinkler.Flag) | Sprinkler_BIS$Sprinkler.Flag==""), ]
## Delete first column
Sprinkler_BIS <- Sprinkler_BIS[ c(2:3) ]

## Subset Sprinkler jobs
Sprinkler_DOB_NOW <- subset(mydata2, Work.Type.Name == c('Sprinklers'))
Sprinkler_DOB_NOW$Filing.Date <- ymd_hms(Sprinkler_DOB_NOW$Filing.Date)
Sprinkler_DOB_NOW$Filing.Date<- floor_date(Sprinkler_DOB_NOW$Filing.Date, "month")
Sprinkler_DOB_NOW<- Sprinkler_DOB_NOW %>% count(Filing.Date)

## Merge the dateframes by month
names(Sprinkler_BIS)<- c("Filing.Date", "Volume")
names(Sprinkler_DOB_NOW)<- c("Filing.Date", "Volume")
## Perform outer merge
Sprinkler_Merge<- merge(Sprinkler_BIS,Sprinkler_DOB_NOW,by="Filing.Date", all=T)
names(Sprinkler_Merge)<- c("FDate", "BIS", "DOB NOW")

#### new CSVs
write.csv(Sprinkler_Merge, "Sprinkler_Merge.csv", row.names=FALSE, na="")





########## SCAFFOLD
## use dplyr to aggregate by month
Scaffold_BIS<- mydata %>% count(Supported.Scaffold, Application.Process.Date)
## Delete null values
Scaffold_BIS<- Scaffold_BIS[!(is.na(Scaffold_BIS$Supported.Scaffold) | Scaffold_BIS$Supported.Scaffold==""), ]
## Delete first column
Scaffold_BIS <- Scaffold_BIS[ c(2:3) ]

## Subset Scaffold jobs
Scaffold_DOB_NOW <- subset(mydata2, Work.Type.Name == c('Scaffold'))
Scaffold_DOB_NOW$Filing.Date <- ymd_hms(Scaffold_DOB_NOW$Filing.Date)
Scaffold_DOB_NOW$Filing.Date<- floor_date(Scaffold_DOB_NOW$Filing.Date, "month")
Scaffold_DOB_NOW<- Scaffold_DOB_NOW %>% count(Filing.Date)

## Merge the dateframes by month
names(Scaffold_BIS)<- c("Filing.Date", "Volume")
names(Scaffold_DOB_NOW)<- c("Filing.Date", "Volume")
## Perform outer merge
Scaffold_Merge<- merge(Scaffold_BIS,Scaffold_DOB_NOW,by="Filing.Date", all=T)
names(Scaffold_Merge)<- c("FDate", "BIS", "DOB NOW")

#### new CSVs
write.csv(Scaffold_Merge, "Scaffold_Merge.csv", row.names=FALSE, na="")







########## SIGN
Sign_BIS <- subset(mydata, Job.Type == c('SG'))
##Sign_BIS$Application.Process.Date <- mdy_hm(Sign_BIS$Application.Process.Date)
Sign_BIS$Application.Process.Date<- floor_date(Sign_BIS$Application.Process.Date, "month")
Sign_BIS<- Sign_BIS %>% count(Application.Process.Date)

## Subset Sign jobs
Sign_DOB_NOW <- subset(mydata2, Work.Type.Name == c('Sign'))
Sign_DOB_NOW$Filing.Date <- ymd_hms(Sign_DOB_NOW$Filing.Date)
Sign_DOB_NOW$Filing.Date<- floor_date(Sign_DOB_NOW$Filing.Date, "month")
Sign_DOB_NOW<- Sign_DOB_NOW %>% count(Filing.Date)

## Merge the dateframes by month
names(Sign_BIS)<- c("Filing.Date", "Volume")
names(Sign_DOB_NOW)<- c("Filing.Date", "Volume")
## Perform outer merge
Sign_Merge<- merge(Sign_BIS,Sign_DOB_NOW,by="Filing.Date", all=T)
names(Sign_Merge)<- c("FDate", "BIS", "DOB NOW")

#### new CSVs
write.csv(Sign_Merge, "Sign_Merge.csv", row.names=FALSE, na="")






########## ANTENNA
Antenna_BIS <- subset(mydata, Antenna.Flag == "Y" | OT.Code.Description=="ANTENNA")
Antenna_BIS $Application.Process.Date<- floor_date(Antenna_BIS $Application.Process.Date, "month")
Antenna_BIS <- Antenna_BIS  %>% count(Application.Process.Date)

## Subset Antenna jobs
Antenna_DOB_NOW <- subset(mydata2, Work.Type.Name == c('Antenna'))
Antenna_DOB_NOW$Filing.Date <- ymd_hms(Antenna_DOB_NOW$Filing.Date)
Antenna_DOB_NOW$Filing.Date<- floor_date(Antenna_DOB_NOW$Filing.Date, "month")
Antenna_DOB_NOW<- Antenna_DOB_NOW %>% count(Filing.Date)

## Merge the dateframes by month
names(Antenna_BIS)<- c("Filing.Date", "Volume")
names(Antenna_DOB_NOW)<- c("Filing.Date", "Volume")
## Perform outer merge
Antenna_Merge<- merge(Antenna_BIS,Antenna_DOB_NOW,by="Filing.Date", all=T)
names(Antenna_Merge)<- c("FDate", "BIS", "DOB NOW")

#### new CSVs
write.csv(Antenna_Merge, "Antenna_Merge.csv", row.names=FALSE, na="")







########## CURB CUT
Curbcut_BIS <- subset(mydata, Curb.Cut.Flag == "X" | OT.Code.Description=="CURB CUT")
Curbcut_BIS $Application.Process.Date<- floor_date(Curbcut_BIS $Application.Process.Date, "month")
Curbcut_BIS <- Curbcut_BIS  %>% count(Application.Process.Date)

## Subset Curb Cut jobs
Curbcut_DOB_NOW <- subset(mydata2, Work.Type.Name == c('Curb Cut'))
Curbcut_DOB_NOW$Filing.Date <- ymd_hms(Curbcut_DOB_NOW$Filing.Date)
Curbcut_DOB_NOW$Filing.Date<- floor_date(Curbcut_DOB_NOW$Filing.Date, "month")
Curbcut_DOB_NOW<- Curbcut_DOB_NOW %>% count(Filing.Date)

## Merge the dateframes by month
names(Curbcut_BIS)<- c("Filing.Date", "Volume")
names(Curbcut_DOB_NOW)<- c("Filing.Date", "Volume")
## Perform outer merge
Curbcut_Merge<- merge(Curbcut_BIS,Curbcut_DOB_NOW,by="Filing.Date", all=T)
names(Curbcut_Merge)<- c("FDate", "BIS", "DOB NOW")

#### new CSVs
write.csv(Curbcut_Merge, "Curbcut_Merge.csv", row.names=FALSE, na="")






########## Elevators
### Convert Elevators Inspection.Date to date
Elevators_BIS$Inspection.Date<- ymd(Elevators_BIS$Inspection.Date)
Elevators_DOB_NOW$Filing.Date<- ymd_hms(Elevators_DOB_NOW$Filing.Date)
Elevators_BIS$Inspection.Date<- floor_date(Elevators_BIS$Inspection.Date, "month")
Elevators_BIS<- Elevators_BIS %>% count(Inspection.Date)
Elevators_DOB_NOW$Filing.Date<- floor_date(Elevators_DOB_NOW$Filing.Date, "month")
Elevators_DOB_NOW<- Elevators_DOB_NOW %>% count(Filing.Date)

## Merge the dateframes by month
names(Elevators_BIS)<- c("Filing.Date", "Volume")
names(Elevators_DOB_NOW)<- c("Filing.Date", "Volume")

## convert POSIXct to Date
Elevators_DOB_NOW$Filing.Date<- ymd(Elevators_DOB_NOW$Filing.Date)  

## Perform outer merge
Elevators_Merge<- merge(Elevators_BIS,Elevators_DOB_NOW,by="Filing.Date", all=T)
names(Elevators_Merge)<- c("FDate", "BIS", "DOB NOW")

#### new CSVs
write.csv(Elevators_Merge, "Elevators_Merge.csv", row.names=FALSE, na="")





########## Electrical
### Convert Electrical Filing.Date to date
Electrical_BIS$Filing.Date<- ymd(Electrical_BIS$Filing.Date)
Electrical_DOB_NOW$Filing.Date<- ymd_hms(Electrical_DOB_NOW$Filing.Date)
Electrical_BIS$Filing.Date<- floor_date(Electrical_BIS$Filing.Date, "month")
Electrical_BIS<- Electrical_BIS %>% count(Filing.Date)
Electrical_DOB_NOW$Filing.Date<- floor_date(Electrical_DOB_NOW$Filing.Date, "month")
Electrical_DOB_NOW<- Electrical_DOB_NOW %>% count(Filing.Date)

## Merge the dateframes by month
names(Electrical_BIS)<- c("Filing.Date", "Volume")
names(Electrical_DOB_NOW)<- c("Filing.Date", "Volume")

## convert POSIXct to Date
Electrical_DOB_NOW$Filing.Date<- ymd(Electrical_DOB_NOW$Filing.Date)  


## Perform outer merge
Electrical_Merge<- merge(Electrical_BIS,Electrical_DOB_NOW,by="Filing.Date", all=T)
names(Electrical_Merge)<- c("FDate", "BIS", "DOB NOW")

#### new CSVs
write.csv(Electrical_Merge, "Electrical_Merge.csv", row.names=FALSE, na="")



