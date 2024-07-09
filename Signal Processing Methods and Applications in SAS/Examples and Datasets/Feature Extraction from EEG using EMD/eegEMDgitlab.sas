/*Extraction from EEG using EMD'; */
/* Important: Download the file features_raw.csv from https://www.kaggle.com/datasets/samnikolas/eeg-dataset */
/* import it to SAS as a dataset */
/* Example code of how to import a csv file below: */
/*PROC IMPORT OUT= WORK.eeg*/
/*            DATAFILE= "YourPath\features_raw.csv" */
/*            DBMS=CSV REPLACE;*/
/*     GETNAMES=YES;*/
/*     DATAROW=0; */
/*     VARNAMEROW=0; */
/*RUN;*/


proc iml;
use work.eeg;            /* open the data set */
read all var {"Fp1" };    /* read 1st vars into vectors */

fs = 256;
tmestep = 1/fs;
eeg_rows = nrow(Fp1);

endtime = eeg_rows/fs;
time = do(0,endtime-tmestep,tmestep)`;
time_rows = nrow(time);

 call series(time[1:1000], Fp1[1:1000]);
 call EMD(IMF, residual, Fp1);

 totalIMFs = ncol(IMF);

title "IMFs of the EEG Time Series";
call panelSeries(time, IMF) grid="y" label={"time" "IMF"} NROWS= totalIMFs;

call HHT(Amp, Phase, hhtFreqs, time, IMF, fs);
Energy = Amp##2;

title "Instantaneous Frequencies of IMFs";
call PanelScatter(time, hhtFreqs)
                  colorvar=Energy
                  colorramp="Rainbow"
                  nrows = 10
                  option="markerattrs=(symbol=CircleFilled size=3)";


usefulIMFs = 5;
win_size = 5 * fs;
overlap = 2.5 * fs;

meanrows = floor((eeg_rows/overlap)-1);
eeg_mean = j(meanrows,usefulIMFs);
eeg_std = j(meanrows,usefulIMFs);
eeg_kur = j(meanrows,usefulIMFs);

do j = 1 to usefulIMFs;
	m_st = 1;
	m_end = win_size;
	currIMF = IMF[ ,j];

	do i = 1 to meanrows;
		eeg_mean[i,j] = mean(currIMF[m_st:m_end]);
		eeg_std[i,j] = sqrt(var(currIMF[m_st:m_end]));
		eeg_kur[i,j] = kurtosis(currIMF[m_st:m_end]);
		m_st  = m_st + overlap;
		m_end = m_end + overlap;
	end;
end;
quit;

