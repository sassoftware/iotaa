/*********************************************************************************************************
NOMINALDR with Gaussian Process Classification on Mushroom Data

This example shows nominal data can be analyzed by the models that only accept interval variables 
after preprocessing with PROC NOMINALDR. The nominal Mushroom dataset is used, and the 
Gaussian process classification model is applied as the downstream model which requires interval inputs. 

The Mushroom dataset is from the UCI Machine Learning Repository (1981), 
available at https://archive.ics.uci.edu/dataset/73/mushroom. 
It describes hypothetical samples of 23 species of gilled mushrooms in the Agaricus and Lepiota Family. 
The data is split into 80% training and 20% testing sets, saved as mushroomTrain.csv and mushroomTest.csv. 

Gaussian process classification is a nonparametric probabilistic model for classification. 
The GPCLASS procedure (SAS Institute Inc. 2025a) trains Gaussian process classification models 
for binary classification and it accepts only interval variables. 

Copyright � 2025, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0
*********************************************************************************************************/

proc import datafile="/sasuser/mushroomTrain.csv"
    out=Train dbms=csv replace; getnames=yes;
run;

proc import datafile="/sasuser/mushroomTest.csv"
    out=Test dbms=csv replace; getnames=yes;
run;

%let dimension=5;

%let mushroom_nominal_vars = cap_shape cap_surface cap_color bruises odor gill_attachment gill_spacing gill_size gill_color stalk_shape stalk_root stalk_surface_above_ring stalk_surface_below_ring stalk_color_above_ring stalk_color_below_ring veil_type veil_color ring_number ring_type spore_print_color population habitat;

/* Dimension Reduction using MCA */
proc NOMINALDR data=Train dimension=&dimension method=MCA prefix=mca_rv;
  input &mushroom_nominal_vars / level=nominal; 
  output out=mcaTrain copyVars=poisonous;
  savestate RSTORE=mcaSTORE;
run;
proc astore;
   score data=Test rstore=mcaSTORE 
       out=mcaTest copyVars=poisonous;
quit; 

proc stdize data=mcaTrain out=mcaStdTrain OUTSTAT=mcaStdSTAT method=std;
      var mca_rv1-mca_rv&dimension;
run;

proc stdize data=mcaTest out=mcaStdTest method=in(mcaStdSTAT);
      var mca_rv1-mca_rv&dimension;
run;

proc GPCLASS data=mcaStdTrain TESTDATA=mcaStdTrain seed=12345;
    input mca_rv1-mca_rv&dimension;
    target poisonous /LEVEL=NOMINAL;
    kernel gaussian(sigma=1);
    inference LA(maxIter=10 threshold=0.001);
    output out=GPCLASS_mcaStd_train copyVars=poisonous;
    savestate rstore=mcaStdModel;
run;

proc astore;
    score data=mcaStdTest rstore=mcaStdModel out=GPCLASS_mcaStd_test copyVars=poisonous;
run;

proc print data=GPCLASS_mcaStd_train(obs=5);
    title "First Five Observations from PROC GPCLASS on MCA-Reduced and Standardized Mushroom Data";
run;

proc assess data=GPCLASS_mcaStd_train ncuts=20 nbins=5;
    var P_poisonousp;
    target poisonous / event="p" level=nominal;
    fitstat pvar=P_poisonouse / pevent="e";
    ods output FitStat=fitstat_mcaStd_train;
run;

proc assess data=GPCLASS_mcaStd_test ncuts=20 nbins=5;
    var P_poisonousp;
    target poisonous / event="p" level=nominal;
    fitstat pvar=P_poisonouse / pevent="e";
    ods output FitStat=fitstat_mcaStd_test ROCInfo=ROCInfo_mcaStd_test;
run;

%macro calc_fitstat_gpclass(averageSquaredError, loglikelihood, accuracy);
   &averageSquaredError = ASE;
   &loglikelihood = MCLL;
   &accuracy = 1 - MCE;
%mend calc_fitstat_gpclass;

data GPCLASS_FITSTAT_MCAStd;
    Data = 'MCA-Reduced';
    set fitstat_mcaStd_train(keep=ASE MCLL MCE);
    %calc_fitstat_gpclass(ASETrn, LogLikeTrn, AccTrn);
    set fitstat_mcaStd_test(keep=ASE MCLL MCE);
    %calc_fitstat_gpclass(ASETst, LogLikeTst, AccTst);

    output;
    drop ASE MCLL MCE;
run;

proc print data=GPCLASS_FITSTAT_MCAStd;
    title "Scoring Statistics of PROC GPCLASS for the MCA-Reduced and Standardized Mushroom Data";
run;
title;

ods listing gpath='/sasuser' image_dpi=300;
ods graphics /  noborder imagename='ROC_GPCLASS_MCAStd' imagefmt=png ; 
proc sgplot data=ROCInfo_mcaStd_test noborder nowall;
   series x=FPR y=Sensitivity / lineattrs=(color=blue);
   xaxis label="false positive rate";
   yaxis label="true positive rate (sensitivity)";
run;
ods graphics off;

/* Dimension Reduction using LPCA */
proc NOMINALDR data=Train dimension=&dimension method=LPCA m=4 maxiter=200 prefix=lpca_rv;
    input &mushroom_nominal_vars / level=nominal; 
    output  out=lpcaTrain copyVars=poisonous;
    savestate RSTORE=lpcaSTORE;
 run;
proc astore;
score data=Test rstore=lpcaSTORE 
    out=lpcaTest copyVars=poisonous;
quit;

proc stdize data=lpcaTrain out=lpcaStdTrain OUTSTAT=lpcaStdSTAT method=std;
      var lpca_rv1-lpca_rv&dimension;
run;
proc stdize data=lpcaTest out=lpcaStdTest method=in(lpcaStdSTAT);
      var lpca_rv1-lpca_rv&dimension;
run;

proc GPCLASS data=lpcaStdTrain TESTDATA=lpcaStdTrain seed=12345;
    input lpca_rv1-lpca_rv&dimension;
    target poisonous /LEVEL=NOMINAL;
    kernel gaussian(sigma=1);
    inference LA(maxIter=10 threshold=0.001);
    output out=GPCLASS_lpcaStd_train copyVars=poisonous;
    savestate rstore=lpcaStdModel;
run;

proc astore;
    score data=lpcaStdTest rstore=lpcaStdModel out=GPCLASS_lpcaStd_test copyVars=poisonous;
run;

/* proc print data=GPCLASS_lpcaStd_train(obs=5); */ 
    /* title "First Five Observations from PROC GPCLASS on LPCA-Reduced and Standardized Mushroom Data"; */
/* run; */
/* title; */

proc assess data=GPCLASS_lpcaStd_train ncuts=20 nbins=2;
    var P_poisonousp;
    target poisonous / event="p" level=nominal;
    fitstat pvar=P_poisonouse / pevent="e";
    ods output FitStat=fitstat_lpcaStd_train;
run;

proc assess data=GPCLASS_lpcaStd_test ncuts=20 nbins=2;
    var P_poisonousp;
    target poisonous / event="p" level=nominal;
    fitstat pvar=P_poisonouse / pevent="e";
    ods output FitStat=fitstat_lpcaStd_test ROCInfo=ROCInfo_lpcaStd_test;
run;

data GPCLASS_FITSTAT_LPCAStd;
    Data = 'LPCA-Reduced';
    set fitstat_lpcaStd_train(keep=ASE MCLL MCE);
    %calc_fitstat_gpclass(ASETrn, LogLikeTrn, AccTrn);
    set fitstat_lpcaStd_test(keep=ASE MCLL MCE);
    %calc_fitstat_gpclass(ASETst, LogLikeTst, AccTst);

    output;
    drop ASE MCLL MCE;
run;

proc print data=GPCLASS_FITSTAT_LPCAStd;
    title "Scoring Statistics of PROC GPCLASS for the LPCA-Reduced and Standardized Mushroom Data";
run;

ods listing gpath='/sasuser' image_dpi=300;
ods graphics /  noborder imagename='ROC_GPCLASS_LPCAStd' imagefmt=png ; 
proc sgplot data=ROCInfo_lpcaStd_test noborder nowall;
   series x=FPR y=Sensitivity / lineattrs=(color=blue);
   xaxis label="false positive rate";
   yaxis label="true positive rate (sensitivity)";
run;
ods graphics off;

/* plot the ROC curves together */
/* Merge horizontally by CutOff */
data ROCInfo_all_test;
    merge ROCInfo_mcaStd_test(keep=CutOff FPR Sensitivity rename=(FPR=FPR_MCA Sensitivity=Sensitivity_MCA))
          ROCInfo_lpcaStd_test(keep=CutOff FPR Sensitivity rename=(FPR=FPR_LPCA Sensitivity=Sensitivity_LPCA));
    by CutOff;
run;

ods listing gpath='/sasuser' image_dpi=300;
ods graphics /  noborder imagename='ROC_GPCLASS_all' imagefmt=png ; 
proc sgplot data=ROCInfo_all_test noborder nowall;
   series x=FPR_MCA y=Sensitivity_MCA / lineattrs=(color=blue pattern=Dash thickness=2) 
          legendlabel="MCA-Reduced";
   series x=FPR_LPCA y=Sensitivity_LPCA / lineattrs=(color=red pattern=ShortDash thickness=2) 
          legendlabel="LPCA-Reduced";
   xaxis label="False Positive Rate";
   yaxis label="True Positive Rate (Sensitivity)";
   keylegend / location=inside position=bottomright;
run;
ods graphics off;
