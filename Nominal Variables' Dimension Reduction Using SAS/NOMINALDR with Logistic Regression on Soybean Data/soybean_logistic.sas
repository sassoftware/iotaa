/*********************************************************************************************************
NOMINALDR with Logistic Regression on Soybean Data

This example uses the Soybean (Large) dataset and the logistic regression model. 

The dataset is from the Michalski, R.S. and Chilausky, R.L. UCI Machine Learning Repository (1980),
available at https://archive.ics.uci.edu/dataset/90/soybean+large. 
The dataset describes soybean plants affected by different diseases with each observation described 
by nominal attributes such as leaf conditions, stem condition and seed appearance. 
The downloaded training and testing files (soybean-large.data and soybean-large.test) 
include these nominal attributes encoded numerically (first category = 0, second = 1 and so forth). 
Both files have no header row, and missing values are indicated by a question mark (“?”). 
For convenience, column headers are added, and missing values are replaced with “.”. 

Logistic regression can classify datasets with multiple nominal target labels 
such as the Soybean dataset used in this example. 
The LOGISTIC procedure (SAS Institute Inc. 2025b) is used to train the logistic regression model. 

Copyright � 2025, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*********************************************************************************************************/

proc import datafile="/sasuser/soybean-large.data"
    out=Train dbms=csv replace; getnames=yes;
run;

proc import datafile="/sasuser/soybean-large.test"
    out=Test dbms=csv replace; getnames=yes;
run;

%let dimension=8;
%let m=10;
%let nominal_vars = plant_stand precip temp hail crop_hist area_damaged severity seed_tmt germination plant_growth leaves leafspots_halo leafspots_marg leafspot_size leaf_shread leaf_malf leaf_mild stem lodging stem_cankers canker_lesion fruiting_bodies external_decay mycelium int_discolor sclerotia fruit_pods fruit_spots seed mold_growth seed_discolor seed_size shriveling roots;

%macro calc_loglike_accuracy_logistic(loglikelihood, accuracy);
   &loglikelihood = LogLike;
   &accuracy = 1 - MisClass;
%mend calc_loglike_accuracy_logistic;


/* Original */
%let t0=%sysfunc(datetime());
proc logistic data=Train outmodel=LOGISTICMODELOriginal;
   class &nominal_vars;
   model class= date &nominal_vars / LINK=GLOGIT;
   score fitstat;
   ods output ScoreFitStat=ScoreFitStatTrain; 
run;
%let logisticTimeOrigTrn=%sysevalf(%sysfunc(datetime())-&t0);
%let t0=%sysfunc(datetime());
proc logistic inmodel=LOGISTICMODELOriginal;
   score data=Test out=logisticTestOriginal fitstat;
   ods output ScoreFitStat=ScoreFitStatTest; 
run;
%let logisticTimeOrigTst=%sysevalf(%sysfunc(datetime())-&t0);

data Logistic_Original_Soybean;
    Data = 'Original'; 

    TimeTrain = &logisticTimeOrigTrn;
    TimeTest = &logisticTimeOrigTst;

    set ScoreFitStatTrain(keep=LogLike MisClass);
    %calc_loglike_accuracy_logistic(LogLikeTrn, AccTrn);
    set ScoreFitStatTest(keep=LogLike MisClass);
    %calc_loglike_accuracy_logistic(LogLikeTst, AccTst);
    output;

    drop LogLike MisClass;
run;

proc print data=Logistic_Original_Soybean;
    title "Runtimes and Scoring Statistics of PROC LOGISTIC for the Original Soybean Data";
run;
title;

/* MCA */
proc NOMINALDR data=Train dimension=&dimension method=MCA prefix=mca_rv;
    input  &nominal_vars / level=nominal;  
    output out=mcaTrain copyVars=(class date);
    savestate RSTORE=mcaSTORE;
run;
proc astore;
    score data=Test rstore=mcaSTORE 
        out=mcaTest copyVars=(class date);
quit;

proc print data =mcaTrain(obs=5);
    title "First Five Observations of the MCA-Reduced Soybean Data";
run;

%let t0=%sysfunc(datetime());
proc logistic data=mcaTrain outmodel=LOGISTICMODELMCA; 
   model class=date mca_rv1-mca_rv&dimension / LINK=GLOGIT;
   score fitstat;
   ods output ScoreFitStat=ScoreFitStatRVMCATrain; /* Fit statistics for scored data */
run;
%let logisticTimeMcaTrn=%sysevalf(%sysfunc(datetime())-&t0);
%let t0=%sysfunc(datetime());
proc logistic inmodel=LOGISTICMODELMCA;
   score data=mcaTest out=logisticTestMCA fitstat;
   ods output ScoreFitStat=ScoreFitStatRVMCATest; /* Fit statistics for scored data */
run;
%let logisticTimeMcaTst=%sysevalf(%sysfunc(datetime())-&t0);

data Logistic_MCA_Soybean;
    Data = 'MCA-Reduced'; 
    TimeTrain = &logisticTimeMcaTrn;
    TimeTest = &logisticTimeMcaTst;

    set ScoreFitStatRVMCATrain(keep=LogLike MisClass);
    %calc_loglike_accuracy_logistic(LogLikeTrn, AccTrn);
    set ScoreFitStatRVMCATest(keep=LogLike MisClass);
    %calc_loglike_accuracy_logistic(LogLikeTst, AccTst);
    output;

    drop LogLike MisClass;
run;

proc print data=Logistic_MCA_Soybean;
    title "Runtimes and Scoring Statistics of PROC LOGISTIC for the MCA-Reduced Soybean Data";
run;
title;

/* LPCA */
proc NOMINALDR data=Train dimension=&dimension method=LPCA m=&m maxiter=100 prefix=lpca_rv;
    input  &nominal_vars / level=nominal;  
    output out=lpcaTrain copyVars=(class date);
    savestate RSTORE=lpcaSTORE;
run;
proc astore;
    score data=Test rstore=lpcaSTORE 
        out=lpcaTest copyVars=(class date);
quit;

proc print data =lpcaTrain(obs=5);
    title "First Five Observations of the LPCA-Reduced Soybean Data";
run;

/* LPCA */
%let t0=%sysfunc(datetime());
proc logistic data=lpcaTrain Outmodel=LOGISTICMODELLPCA; 
   model class=date lpca_rv1-lpca_rv&dimension / LINK=GLOGIT;
   score fitstat;
   ods output ScoreFitStat=ScoreFitStatRVLPCATrain; /* Fit statistics for scored data */
run;
%let logisticTimeLpcaTrn=%sysevalf(%sysfunc(datetime())-&t0);
%let t0=%sysfunc(datetime());
proc logistic inmodel=LOGISTICMODELLPCA;
   score data=lpcaTest out=logisticTestLPCA fitstat;
   ods output ScoreFitStat=ScoreFitStatRVLPCATest; /* Fit statistics for scored data */
run;
%let logisticTimeLpcaTst=%sysevalf(%sysfunc(datetime())-&t0);


data Logistic_LPCA_Soybean;
    Data = 'LPCA-Reduced'; 
    TimeTrain = &logisticTimeLpcaTrn;
    TimeTest = &logisticTimeLpcaTst;

    set ScoreFitStatRVLPCATrain(keep=LogLike MisClass);
    %calc_loglike_accuracy_logistic(LogLikeTrn, AccTrn);
    set ScoreFitStatRVLPCATest(keep=LogLike MisClass);
    %calc_loglike_accuracy_logistic(LogLikeTst, AccTst);
    output;

    drop LogLike MisClass;
run;

proc print data=Logistic_LPCA_Soybean;
    title "Runtimes and Scoring Statistics of PROC LOGISTIC for the LPCA-Reduced Soybean Data";
run;
title;

/* proc datasets library=work kill; */
/* quit; */
/* proc datasets library=_SASUSR_ kill; */
/* quit; */