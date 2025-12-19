/*********************************************************************************************************
NOMINALDR with Neural Network on Molecular Biology Data

This example uses the Molecular Biology (Splice-junction Gene Sequences) dataset and multilayer 
perceptron neural networks to illustrate the benefits of using PROC NOMINALDR as preprocessing step.

The Molecular Biology (Splice-junction Gene Sequences) dataset is derived from molecular biology research 
and is available from the UCI Machine Learning Repository (1991) 
at https://archive.ics.uci.edu/dataset/69/molecular+biology+splice+junction+gene+sequences. 
The dataset is split into 80% training and 20% testing sets, which are stored as 
the comma-separated-value (CSV) files molecularBiologyTrain.csv and molecularBiologyTest.csv, respectively. 

The multilayer perceptron neural network is a supervised learning method designed to model complex, 
non-linear relationship between the predictors and the target.
The NNET procedure (SAS Institute Inc. 2025c) is used to train the network for classification 
on the Molecular Biology dataset. 

Copyright � 2025, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*********************************************************************************************************/


proc import datafile="molecularBiologyTrain.csv" /*or user-defined location*/
    out=Train dbms=csv replace; getnames=yes;
run;

proc import datafile="molecularBiologyTest.csv" /*or user-defined location*/
    out=Test dbms=csv replace; getnames=yes;
run;

proc print data=Train(obs=5);
    title "First Five Observations of the Original Molecular Biology Training Data";
run;
title;

/* NNET with Original Data */
%let t0=%sysfunc(datetime());
proc nnet data=Train;
    input  Base1-Base60 / level=nominal;
    target class / level=nominal;
    autotune useparameters=custom objective=MCE searchmethod=GA
            tuningparameters=(nhidden(VALUES=(1) INIT=1)
                              nunits1(LB=1 UB=10 INIT=1)
                              );
    OUTPUT out=nnetTrain copyVars=class; 
    TRAIN OUTMODEL=nnetModel seed=12345;
run;
%let nnet_time_original_train=%sysevalf(%sysfunc(datetime())-&t0);

%let t0=%sysfunc(datetime());
proc nnet data=Test inmodel=NNetModel;
    OUTPUT out=NNetTest copyVars=class; 
run;
%let nnet_time_original_test=%sysevalf(%sysfunc(datetime())-&t0);

proc print data=nnetTrain(obs=5);
    title "First Five Observations of Prediction from PROC NNET on the Original Molecular Biology Training Data";
run;
title;

proc assess data=nnetTrain ncuts=20 nbins=2;
   var P_classN;
   target class / event="N" level=nominal;
   fitstat pvar=P_classEI P_classIE / pevent="EI IE" delimiter=" ";
   ods output FitStat=fitstat_original_train;
run;

proc assess data=nnetTest ncuts=20 nbins=2;
   var P_classN;
   target class / event="N" level=nominal;
   fitstat pvar=P_classEI P_classIE / pevent="EI IE" delimiter=" ";
   ods output FitStat=fitstat_original_test ROCInfo=ROCInfo_original_test;
run;

%macro calc_fitstat_nnet(averageSquaredError, loglikelihood, accuracy);
   &averageSquaredError = ASE;
   &loglikelihood = MCLL;
   &accuracy = 1 - MCE;
%mend calc_fitstat_nnet;

data NNET_FITSTAT_ORIGINAL;
    Data = "Original";
    TimeTrain = &nnet_time_original_train;
    TimeTest = &nnet_time_original_test;
    set fitstat_original_train(keep=ASE MCLL MCE);
    %calc_fitstat_nnet(ASETrn, LogLikeTrn, AccTrn);
    set fitstat_original_test(keep=ASE MCLL MCE);
    %calc_fitstat_nnet(ASETst, LogLikeTst, AccTst);
    output;
    drop ASE MCLL MCE;
run;

proc print data=NNET_FITSTAT_ORIGINAL noobs;
    title "Runtimes and Scoring Statistics of PROC NNET for the Original Molecular Biology Data";
run;
title;

proc sgplot data=ROCInfo_original_test noborder nowall;
   series x=FPR y=Sensitivity / lineattrs=(color=blue thickness=2);
   xaxis label="False Positive Rate";
   yaxis label="True Positive Rate (Sensitivity)";
run;

/* NOMINALDR with MCA */
%let t0=%sysfunc(datetime());
proc NOMINALDR data=Train dimension=10 method=MCA prefix=mca_rv;
   input Base1-Base60 /LEVEL=NOMINAL;
   output out=mcaTrain copyVars=class;
   savestate RSTORE=mcaSTORE;
run;
%let McaTimeTrn=%sysevalf(%sysfunc(datetime())-&t0);

%let t0=%sysfunc(datetime());
proc astore;
   SCORE data=Test rstore=mcaSTORE 
       out=mcaTest copyVars=class;
quit; 
%let McaTimeTst=%sysevalf(%sysfunc(datetime())-&t0);

proc print data=mcaTrain(obs=5);
    title "First Five Observations of the MCA-Reduced Molecular Biology Training Data";
run;
title;

/* NNET with MCA-Reduced Data */
%let t0=%sysfunc(datetime());
proc nnet data=mcaTrain;
    input  mca_rv1-mca_rv10 / level=interval;
    target class / level=nominal;
    autotune useparameters=custom objective=MCE searchmethod=GA
            tuningparameters=(nhidden(VALUES=(1) INIT=1)
                              nunits1(LB=1 UB=10 INIT=1)
                              );
    OUTPUT out=mcaNNetTrain copyVars=class; 
    TRAIN OUTMODEL=mcaNNetModel seed=12345;
run;
%let nnet_time_mca_train=%sysevalf(%sysfunc(datetime())-&t0);

%let t0=%sysfunc(datetime());
proc nnet data=mcaTest inmodel=mcaNNetModel;
    OUTPUT out=mcaNNetTest copyVars=class;
run;
%let nnet_time_mca_test=%sysevalf(%sysfunc(datetime())-&t0);

proc assess data=mcaNNetTrain ncuts=20 nbins=5;
   var P_classN;
   target class / event="N" level=nominal;
   fitstat pvar=P_classEI P_classIE / pevent="EI IE" delimiter=" ";
   ods output FitStat=fitstat_mca_train;
run;

proc assess data=mcaNNetTest ncuts=20 nbins=5;
   var P_classN;
   target class / event="N" level=nominal;
   fitstat pvar=P_classEI P_classIE / pevent="EI IE" delimiter=" ";
   ods output FitStat=fitstat_mca_test ROCInfo=ROCInfo_mca_test;
run;

data NNET_FITSTAT_MCA;
    Data = "MCA-Reduced";
    TimeTrain = &nnet_time_mca_train;
    TimeTest = &nnet_time_mca_test;
    set fitstat_mca_train(keep=ASE MCLL MCE);
    %calc_fitstat_nnet(ASETrn, LogLikeTrn, AccTrn);
    set fitstat_mca_test(keep=ASE MCLL MCE);
    %calc_fitstat_nnet(ASETst, LogLikeTst, AccTst);
    output;
    drop ASE MCLL MCE;
run;

proc print data=NNET_FITSTAT_MCA noobs;
    title "Runtimes and Scoring Statistics of PROC NNET for the MCA-Reduced Molecular Biology Data";
run;
title;

proc sgplot data=ROCInfo_mca_test noborder nowall;
   series x=FPR y=Sensitivity / lineattrs=(color=blue thickness=2);
   xaxis label="False Positive Rate";
   yaxis label="True Positive Rate (Sensitivity)";
run;

/* NOMINALDR with LPCA */
%let t0=%sysfunc(datetime());
proc NOMINALDR data=Train dimension=10 method=LPCA m=3 prefix=lpca_rv;
   input Base1-Base60 /LEVEL=NOMINAL;
   output out=lpcaTrain copyVars=class;
   savestate RSTORE=lpcaSTORE;
run;
%let nominaldrTimeLpcaTrn=%sysevalf(%sysfunc(datetime())-&t0);
%let t0=%sysfunc(datetime());
proc astore;
   SCORE data=Test rstore=lpcaSTORE 
       out=lpcaTest copyVars=class;
quit; 
%let nominaldrTimeLpcaTst=%sysevalf(%sysfunc(datetime())-&t0);

proc print data=lpcaTrain(obs=5);
    title "First Five Observations of the LPCA-Reduced Molecular Biology Training Data";
run;
title;

/* NNET with LPCA-Reduced Data */
%let t0=%sysfunc(datetime());
proc nnet data=lpcaTrain;
    input  lpca_rv1-lpca_rv10 / level=interval;
    target class / level=nominal;
    autotune useparameters=custom objective=MCE searchmethod=GA
            tuningparameters=(nhidden(VALUES=(1) INIT=1)
                              nunits1(LB=1 UB=10 INIT=1)
                              );
    OUTPUT out=lpcaNNetTrain copyVars=class; 
    TRAIN OUTMODEL=lpcaNNetModel seed=12345;
run;
%let nnet_time_lpca_train=%sysevalf(%sysfunc(datetime())-&t0);
%let t0=%sysfunc(datetime());
proc nnet data=lpcaTest inmodel=lpcaNNetModel;
    OUTPUT out=lpcaNNetTest copyVars=class;
run;
%let nnet_time_lpca_test=%sysevalf(%sysfunc(datetime())-&t0);

proc assess data=lpcaNNetTrain ncuts=20 nbins=5;
   var P_classN;
   target class / event="N" level=nominal;
   fitstat pvar=P_classEI P_classIE / pevent="EI IE" delimiter=" ";
   ods output FitStat=fitstat_lpca_train;
run;

proc assess data=lpcaNNetTest ncuts=20 nbins=5;
   var P_classN;
   target class / event="N" level=nominal;
   fitstat pvar=P_classEI P_classIE / pevent="EI IE" delimiter=" ";
   ods output FitStat=fitstat_lpca_test ROCInfo=ROCInfo_lpca_test;
run;

data NNET_FITSTAT_LPCA;
    Data = "LPCA-Reduced";
    TimeTrain = &nnet_time_lpca_train;
    TimeTest = &nnet_time_lpca_test;
    set fitstat_lpca_train(keep=ASE MCLL MCE);
    %calc_fitstat_nnet(ASETrn, LogLikeTrn, AccTrn);
    set fitstat_lpca_test(keep=ASE MCLL MCE);
    %calc_fitstat_nnet(ASETst, LogLikeTst, AccTst);
    output;
    drop ASE MCLL MCE;
run;

proc print data=NNET_FITSTAT_LPCA noobs;
    title "Runtimes and Scoring Statistics of PROC NNET for the LPCA-Reduced Molecular Biology Data";
run;
title;

proc sgplot data=ROCInfo_lpca_test noborder nowall;
   series x=FPR y=Sensitivity / lineattrs=(color=blue thickness=2);
   xaxis label="False Positive Rate";
   yaxis label="True Positive Rate (Sensitivity)";
run;

/* Plot the ROC together */
/* Merge horizontally by CutOff */
data ROCInfoNNET_all_test;
    merge ROCInfo_original_test(keep=CutOff FPR Sensitivity rename=(FPR=FPR_Original Sensitivity=Sensitivity_Original))
          ROCInfo_mca_test(keep=CutOff FPR Sensitivity rename=(FPR=FPR_MCA Sensitivity=Sensitivity_MCA))
          ROCInfo_lpca_test(keep=CutOff FPR Sensitivity rename=(FPR=FPR_LPCA Sensitivity=Sensitivity_LPCA));
    by CutOff;
run;

proc sgplot data=ROCInfoNNET_all_test noborder nowall;
    series x=FPR_Original y=Sensitivity_Original / lineattrs=(color=black pattern=Solid thickness=2) legendlabel="Original";
    series x=FPR_MCA y=Sensitivity_MCA / lineattrs=(color=blue pattern=Dash thickness=2) legendlabel="MCA-reduced";
    series x=FPR_LPCA y=Sensitivity_LPCA / lineattrs=(color=red pattern=ShortDash thickness=2) legendlabel="LPCA-reduced";
    xaxis label="False Positive Rate";
    yaxis label="True Positive Rate (Sensitivity)";
    keylegend / location=inside position=bottomright;
run;
