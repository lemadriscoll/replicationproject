 
******************************************************************
* CPS Dataset Replication (Difference-in-Differences Model)  
*******************************************************************

***********************************************
* Setup
***********************************************

clear all

*Close existing log files
capture log close

*Start logging
log using "C:\Users\Ariana.Lema001\Documents\UMass Boston\ECON 652 Quant 2\Replication\RepLog.log", replace

*Change directory
cd "C:\Users\Ariana.Lema001\Documents\UMass Boston\ECON 652 Quant 2\Replication\Data\CPS"

*Toggle off "more" function 
set more off

*Load dataset
use "C:\Users\Ariana.Lema001\Documents\UMass Boston\ECON 652 Quant 2\Replication\Data\CPS\CPSData.dta", clear

*Count number of observations
count

*Sort by household and position in HH
sort serial cpsid relate


***********************************************
* Create necessary variables
***********************************************

*Pre-policy indicator
gen pretreat=1 if year>=1992 & year<=1995
replace pretreat=0 if year>=1998 & year<=2002

*Post-policy indicator
gen posttreat=1 if year>=1998 & year<=2002
replace posttreat=0 if year>=1992 & year<=1995
sum posttreat

*Female dummy
gen female=0 if sex==1
replace female=1 if sex==2

*White indicator
gen white=race==100

*Not working indicator
gen nowork=0 if empstat==10 | empstat==1
replace nowork=1 if empstat>10

*Education variables (less than high school, high school, some college, college grad
drop if educ99==0 | educ99==.

gen edcat1=1 if educ99<=9
replace edcat1=0 if educ99>9

gen edcat2=1 if educ99==10
replace edcat2=0 if educ99!=10

gen edcat3=1 if educ99>=11 & educ99<=14
replace edcat3=0 if educ99<11 | educ99>14

gen edcat4=1 if educ99==15
replace edcat4=0 if educ99<15 | educ99>15
*Over college grad is excluded

*Part-Time Dummy Variable
gen parttime=1 if uhrswork1<35
replace parttime=0 if uhrswork1>=35
replace uhrswork1=. if uhrswork1>996

*Self-employed dummy
gen selfemp=1 if classwkr>=10 & classwkr<=14
replace selfemp=0 if classwkr>14 | classwkr<10

*Part-Time Dummy Variable 2
gen pt=1 if ahrsworkt<35
replace pt=0 if ahrsworkt>=35
replace pt=. if ahrsworkt>996

*Hours worked
gen hrsworked=ahrsworkt
replace hrsworked=0 if ahrsworkt>900

*Region dummies
gen south=0
replace south=1 if region>=31 & region<=33

gen midwest=0
replace midwest=1 if region==21 | region==22

gen west=0
replace west=1 if region==41 | region==42

gen northeast=0 
replace northeast=1 if region==11 | region==12

*Veteran indicator
gen vet=0
replace vet=1 if vetstat==2

*Exclude female veterans due to small numbers
drop if female==1 & vetstat==2
drop if female==0 & vetstat_sp==2

*Drop wives under 19
drop if age<20 & female==1
drop if age_sp<20 & female==0

*Substitute Weekly Earnings
gen weeklyearnings=incwage/52

*Ln Weekly Earnings
gen lninc=log(weeklyearnings)

*Gen 1996-1997 variable time-variable for regression
gen midtreat=0
replace midtreat=1 if year==1996 | year==1997

**********************************
* Husband-Specific Characteristics
**********************************

*Current miltary personnel
gen husbactive=0
replace husbactive=1 if empstat==1 & female==0
replace husbactive=1 if empstat_sp==1 & female==1

*Husband veteran status
gen husbvet=0 if vetstat==1
replace husbvet=1 if vetstat==2 & female==0
replace husbvet=1 if vetstat_sp==2 & female==1

*Husband age
gen husbage=age if female==0
replace husbage=age_sp if female==1

*Cluster var men for regression
gen yrvet=year*vet

*Cluster var wives for regression
gen hyrvet=year*husbvet

***********************************************
* Define sample
***********************************************

*Limit to married couples
drop if marst>1
drop if relate>201

*Drop husbands under 55 and over 64
keep if (age>=55 & age<=64 & female==0) | (husbage>=55 & husbage<=64 & female==1)

*Replace missing earnings with zero
replace ahrsworkt=0 if ahrsworkt>=999

***********************************************
* Descriptive Statistics
***********************************************

*********************************
* Husband Descriptive Statistics
*********************************

*Husbands Descriptive Statistics*
*Summary Statistics Husbands Pre-Treatment, Veterans
estpost sum age white edcat* northeast midwest south west nowork pt selfemp hrsworked if husbvet==1 & pretreat==1 & female==0
esttab . using "summary1.rtf", cells("mean(fmt(2)) count(fmt(0))") noobs collabels("Mean" "N") label replace nonum

*Summary Statistics Husbands Pre-Treatment, Non-Veterans
estpost sum age white edcat* northeast midwest south west nowork pt selfemp hrsworked if husbvet==0 & pretreat==1 & female==0
esttab . using "summary2.rtf", cells("mean(fmt(2)) count(fmt(0))") noobs collabels("Mean" "N") label replace nonum

*Summary Statistics Husbands Post-Treatment, Veterans
estpost sum age white edcat* northeast midwest south west nowork pt selfemp hrsworked if husbvet==1 & posttreat==1 & female==0
esttab . using "summary3.rtf", cells("mean(fmt(2)) count(fmt(0))") noobs collabels("Mean" "N") label replace nonum

*Summary Statistics Husbands Post-Treatment, Non-Veterans
estpost sum age white edcat* northeast midwest south west nowork pt selfemp hrsworked if husbvet==0 & posttreat==1 & female==0
esttab . using "summary4.rtf", cells("mean(fmt(2)) count(fmt(0))") noobs collabels("Mean" "N") label replace nonum


*********************************
* Wives Descriptive Statistics
*********************************

*Summary Statistics Wives Pre-Treatment, Veterans
estpost sum age white edcat* northeast midwest south west nowork pt selfemp hrsworked if husbvet==1 & pretreat==1 & female==1
esttab . using "summary5.rtf", cells("mean(fmt(2)) count(fmt(0))") noobs collabels("Mean" "N") label replace nonum

*Summary Statistics Wives Pre-Treatment, Non-Veterans
estpost sum age white edcat* northeast midwest south west nowork pt selfemp hrsworked if husbvet==0 & pretreat==1 & female==1
esttab . using "summary6.rtf", cells("mean(fmt(2)) count(fmt(0))") noobs collabels("Mean" "N") label replace nonum

*Summary Statistics Wives Post-Treatment, Veterans
estpost sum age white edcat* northeast midwest south west nowork pt selfemp hrsworked if husbvet==1 & posttreat==1 & female==1
esttab . using "summary7.rtf", cells("mean(fmt(2)) count(fmt(0))") noobs collabels("Mean" "N") label replace nonum

*Summary Statistics Wives Post-Treatment, Non-Veterans
estpost sum age white edcat* northeast midwest south west nowork pt selfemp hrsworked if husbvet==0 & posttreat==1 & female==1
esttab . using "summary8.rtf", cells("mean(fmt(2)) count(fmt(0))") noobs collabels("Mean" "N") label replace nonum

***********************************************
* Primary Regression Models
***********************************************

*Difference in Difference Model for Veterans
*Not working
eststo r1: reg nowork i.vet##i.posttreat age white i.statefip edcat* i.year if female==0 & midtreat==0, r cluster(yrvet)

eststo r2: reg nowork i.vet##i.posttreat age white edcat* i.year##i.statefip pension gotvpens if female==0 & midtreat==0, r cluster(yrvet)

*Part-Time
*In their regression, this N=26.4k, the others are close at 41k

eststo r3: reg pt i.vet##i.posttreat age white i.statefip edcat* i.year if female==0 & midtreat==0, r cluster(yrvet)

eststo r4: reg pt i.vet##i.posttreat age white edcat* i.year##i.statefip pension gotvpens if female==0 & midtreat==0, r cluster(yrvet)

*Self-Employed
eststo r5: reg selfemp i.vet##i.posttreat age white edcat* i.year i.statefip if female==0 & midtreat==0, r cluster(yrvet)

eststo r6: reg selfemp i.vet##i.posttreat age white edcat* i.year##i.statefip pension gotvpens if female==0 & midtreat==0, r cluster(yrvet)

esttab r1 r2 r3 r4 r5 r6 using "T2.rtf", replace stats(N r2,fmt(0 2)) se brackets label nobaselevels starlevels( * 0.10 ** 0.05 *** 0.010)
*Print regressions 1-6 as Table 2
*Tables named based on replication paper

*Difference in Difference Model for Veterans' Wives
*Not working
eststo r7: reg nowork i.husbvet##i.posttreat age white i.statefip edcat* i.year if female==1 & midtreat==0, r cluster(hyrvet)

eststo r8: reg nowork i.husbvet##i.posttreat age edcat* i.year##i.statefip pension gotvpens if female==1 & midtreat==0, r cluster(hyrvet)

*Hours Worked Last Week
*In their regression, this N=26.4k, the others are close at 41k

eststo r9: reg ahrsworkt i.husbvet##i.posttreat age white i.statefip edcat* i.year if female==1 & midtreat==0, r cluster(hyrvet)

eststo r10: reg ahrsworkt i.husbvet##i.posttreat age white edcat* i.year##i.statefip pension gotvpens if female==1 & midtreat==0, r cluster(hyrvet)

*Hours Worked Last Week, if Hours > 0
eststo r11: reg ahrsworkt i.husbvet##i.posttreat age white i.statefip edcat* i.year if female==1 & midtreat==0 & ahrsworkt>0, r cluster(hyrvet)

eststo r12: reg ahrsworkt i.husbvet##i.posttreat age white edcat* i.year##i.statefip pension gotvpens if female==1 & midtreat==0 & ahrsworkt>0, r cluster(hyrvet)

*Earnings
eststo r13: reg weeklyearnings i.husbvet##i.posttreat age white i.statefip edcat* i.year if female==1 & midtreat==0, r cluster(hyrvet)

eststo r14: reg weeklyearnings i.husbvet##i.posttreat age white edcat* i.year##i.statefip pension gotvpens if female==1 & midtreat==0, r cluster(hyrvet)

*Ln(Earnings)
eststo r15: reg lninc i.husbvet##i.posttreat age white i.statefip edcat* i.year if female==1 & midtreat==0, r cluster(hyrvet)

eststo r16: reg lninc i.husbvet##i.posttreat age white edcat* i.year##i.statefip pension gotvpens if female==1 & midtreat==0, r cluster(hyrvet)

*Print regressions 7-16
esttab r7 r8 r9 r10 r11 r12 r13 r14 r15 r16 using "T3.rtf", replace stats(N r2,fmt(0 2)) se brackets label nobaselevels starlevels( * 0.10 ** 0.05 *** 0.010)

***********************************************
* Test Regression Models
***********************************************

***Falsification exercise***
gen fakepost=1 if year>=1994 & year<=1995
replace fakepost=0 if year>=1996 | year<=1993

*Not working
eststo r17: reg nowork i.vet##i.fakepost age white i.statefip edcat* i.year if female==0 & midtreat==0, r cluster(yrvet)

eststo r18: reg nowork i.vet##i.fakepost age white edcat* i.year##i.statefip pension gotvpens if female==0 & midtreat==0, r cluster(yrvet)

*Part-Time
eststo r19: reg pt i.vet##i.fakepost age white i.statefip edcat* i.year if female==0 & midtreat==0, r cluster(yrvet)

eststo r20: reg pt i.vet##i.fakepost age white edcat* i.year##i.statefip pension gotvpens if female==0 & midtreat==0, r cluster(yrvet)

*Self-Employed
eststo r21: reg selfemp i.vet##i.fakepost age white edcat* i.year i.statefip if female==0 & midtreat==0, r cluster(yrvet)

eststo r22: reg selfemp i.vet##i.fakepost age white edcat* i.year##i.statefip pension gotvpens if female==0 & midtreat==0, r cluster(yrvet)

*Print regressions 17-22
esttab r17 r18 r19 r20 r21 r22 using "T3a.rtf", replace stats(N r2,fmt(0 2)) se brackets label nobaselevels starlevels( * 0.10 ** 0.05 *** 0.010)


***Education Levels- with high school or less vs some college/college
gen lowed=1 if edcat1==1 | edcat2==1
replace lowed=0 if edcat3==1 | edcat4==1

gen highed=1 if edcat3==1 | edcat4==1
replace highed=0 if edcat1==1 | edcat2==1

**Low ed**
*Not working
eststo r23: reg nowork i.husbvet##i.posttreat age white i.statefip edcat* i.year if female==1 & midtreat==0 & lowed==1, r cluster(hyrvet)

eststo r24: reg nowork i.husbvet##i.posttreat age edcat* i.year##i.statefip pension gotvpens if female==1 & midtreat==0 & lowed==1, r cluster(hyrvet)

*Hours Worked Last Week
*In their regression, this N=26.4k, the others are close at 41k

eststo r25: reg ahrsworkt i.husbvet##i.posttreat age white i.statefip edcat* i.year if female==1 & midtreat==0 & lowed==1, r cluster(hyrvet)

eststo r26: reg ahrsworkt i.husbvet##i.posttreat age white edcat* i.year##i.statefip pension gotvpens if female==1 & midtreat==0 & lowed==1, r cluster(hyrvet)

*Hours Worked Last Week, if Hours > 0
eststo r27: reg ahrsworkt i.husbvet##i.posttreat age white i.statefip edcat* i.year if female==1 & midtreat==0 & ahrsworkt>0 & lowed==1 & lowed==1, r cluster(hyrvet)

eststo r28: reg ahrsworkt i.husbvet##i.posttreat age white edcat* i.year##i.statefip pension gotvpens if female==1 & midtreat==0 & ahrsworkt>0 & lowed==1, r cluster(hyrvet)

*Earnings
eststo r29: reg weeklyearnings i.husbvet##i.posttreat age white i.statefip edcat* i.year if female==1 & midtreat==0 & lowed==1, r cluster(hyrvet)

eststo r30: reg weeklyearnings i.husbvet##i.posttreat age white edcat* i.year##i.statefip pension gotvpens if female==1 & midtreat==0 & lowed==1, r cluster(hyrvet)

*Ln(Earnings)
eststo r31: reg lninc i.husbvet##i.posttreat age white i.statefip edcat* i.year if female==1 & midtreat==0 & lowed==1, r cluster(hyrvet)

eststo r32: reg lninc i.husbvet##i.posttreat age white edcat* i.year##i.statefip pension gotvpens if female==1 & midtreat==0 & lowed==1, r cluster(hyrvet)

*Print regressions 23-32
esttab r23 r24 r25 r26 r27 r28 r29 r30 r31 r32 using "T3b.rtf", replace stats(N r2,fmt(0 2)) se brackets label nobaselevels starlevels( * 0.10 ** 0.05 *** 0.010)

**High ed**
*Not working
eststo r33: reg nowork i.husbvet##i.posttreat age white i.statefip edcat* i.year if female==1 & midtreat==0 & highed==1, r cluster(hyrvet)

eststo r34: reg nowork i.husbvet##i.posttreat age edcat* i.year##i.statefip pension gotvpens if female==1 & midtreat==0 & highed==1, r cluster(hyrvet)

*Hours Worked Last Week
*In their regression, this N=26.4k, the others are close at 41k

eststo r35: reg ahrsworkt i.husbvet##i.posttreat age white i.statefip edcat* i.year if female==1 & midtreat==0 & highed==1, r cluster(hyrvet)

eststo r36: reg ahrsworkt i.husbvet##i.posttreat age white edcat* i.year##i.statefip pension gotvpens if female==1 & midtreat==0 & highed==1, r cluster(hyrvet)

*Hours Worked Last Week, if Hours > 0
eststo r37: reg ahrsworkt i.husbvet##i.posttreat age white i.statefip edcat* i.year if female==1 & midtreat==0 & ahrsworkt>0 & highed==1, r cluster(hyrvet)

eststo r38: reg ahrsworkt i.husbvet##i.posttreat age white edcat* i.year##i.statefip pension gotvpens if female==1 & midtreat==0 & ahrsworkt>0 & highed==1, r cluster(hyrvet)

*Earnings
eststo r39: reg weeklyearnings i.husbvet##i.posttreat age white i.statefip edcat* i.year if female==1 & midtreat==0 & highed==1, r cluster(hyrvet)

eststo r40: reg weeklyearnings i.husbvet##i.posttreat age white edcat* i.year##i.statefip pension gotvpens if female==1 & midtreat==0 & highed==1, r cluster(hyrvet)

*Ln(Earnings)
eststo r41: reg lninc i.husbvet##i.posttreat age white i.statefip edcat* i.year if female==1 & midtreat==0 & highed==1, r cluster(hyrvet)

eststo r42: reg lninc i.husbvet##i.posttreat age white edcat* i.year##i.statefip pension gotvpens if female==1 & midtreat==0 & highed==1, r cluster(hyrvet)

*Print regressions 33-42
esttab r33 r34 r35 r36 r37 r38 r39 r40 r41 r42 using "T3c.rtf", replace stats(N r2,fmt(0 2)) se brackets label nobaselevels starlevels( * 0.10 ** 0.05 *** 0.010)

**Insurance coverage last year (Table 5)**
*Coverage indicator
gen hasinsurance=1 if inclugh==2
replace hasinsurance=0 if inclugh<2

*Among those that have insurance
*Not working
eststo r43: reg nowork i.husbvet##i.posttreat age white i.statefip edcat* i.year if female==1 & midtreat==0 & hasinsurance==1, r cluster(hyrvet)

eststo r44: reg pt i.husbvet##i.posttreat age white i.statefip edcat* i.year if female==1 & midtreat==0 & hasinsurance==1, r cluster(hyrvet)

*Hours Worked Last Week
*In their regression, this N=26.4k, the others are close at 41k

eststo r45: reg ahrsworkt i.husbvet##i.posttreat age white i.statefip edcat* i.year if female==1 & midtreat==0 & hasinsurance==1, r cluster(hyrvet)

*Hours Worked Last Week, if Hours > 0
eststo r47: reg ahrsworkt i.husbvet##i.posttreat age white i.statefip edcat* i.year if female==1 & midtreat==0 & ahrsworkt>0 & hasinsurance==1, r cluster(hyrvet)

*Earnings
eststo r49: reg weeklyearnings i.husbvet##i.posttreat age white i.statefip edcat* i.year if female==1 & midtreat==0 & hasinsurance==1, r cluster(hyrvet)

*Ln(Earnings)
eststo r51: reg lninc i.husbvet##i.posttreat age white i.statefip edcat* i.year if female==1 & midtreat==0 & hasinsurance==1, r cluster(hyrvet)

*Print regressions 43-51
esttab r43 r44 r45 r47 r49 r51 using "T5a.rtf", replace stats(N r2,fmt(0 2)) se brackets label nobaselevels starlevels( * 0.10 ** 0.05 *** 0.010)


*Among those that do not have insurance
*Not working
eststo r53: reg nowork i.husbvet##i.posttreat age white i.statefip edcat* i.year if female==1 & midtreat==0 & hasinsurance==0, r cluster(hyrvet)

*Part Time
eststo r54: reg pt i.husbvet##i.posttreat age white i.statefip edcat* i.year if female==1 & midtreat==0 & hasinsurance==0, r cluster(hyrvet)

*Hours Worked Last Week
*In their regression, this N=26.4k, the others are close at 41k

eststo r55: reg ahrsworkt i.husbvet##i.posttreat age white i.statefip edcat* i.year if female==1 & midtreat==0 & hasinsurance==0, r cluster(hyrvet)

*Hours Worked Last Week, if Hours > 0
eststo r57: reg ahrsworkt i.husbvet##i.posttreat age white i.statefip edcat* i.year if female==1 & midtreat==0 & ahrsworkt>0 & hasinsurance==0, r cluster(hyrvet)

*Earnings
eststo r59: reg weeklyearnings i.husbvet##i.posttreat age white i.statefip edcat* i.year if female==1 & midtreat==0 & hasinsurance==0, r cluster(hyrvet)

*Ln(Earnings)
eststo r61: reg lninc i.husbvet##i.posttreat age white i.statefip edcat* i.year if female==1 & midtreat==0 & hasinsurance==0, r cluster(hyrvet)

*Print regressions 53-61
esttab r53 r54 r55 r57 r59 r61 using "T5b.rtf", replace stats(N r2,fmt(0 2)) se brackets label nobaselevels starlevels( * 0.10 ** 0.05 *** 0.010)



*Close log
log close
translate "C:\Users\Ariana.Lema001\Documents\UMass Boston\ECON 652 Quant 2\Replication\RepLog.log" "RepLog.pdf"
