ods graphics /NXYBINSMAX= 4100000  DISCRETEMAX=2300 MaxOBS=2957312 ANTIALIASMAX=595000;
%let current_path = C:\Users\lagonz\OneDrive - SAS\Documents\My assignments\techpaper\Bee;
%let codelib = &current_path; 
%put &codelib;
%include "&codelib\heatmap.sas";

libname myWork "U:\Bee\Bee\";


%let piping_data_new = bee; 

%let win_len_t = 0.15;
%let order = 50;

%let first = 33;
%let last = 0;
%let freq_cutoff = 5000;

/*%createHeatmap(MyWork.spectral_adj, myWork.freq, "After Adaptive Magnitude Adjustment", dB, &freq_cutoff, &first., &last.);*/
/*6. Detect the peaks in each window to find the fundamental frequency and it's harmonics */
proc iml;
    /*IML function to find peaks of a vector */
    /* 
		val: upon return, val contains the values of the peaks 
        idx: upon return, idx contains the indices of the peaks, 
        x: input data vector;
        minHeight: minimum height of the peaks (in DB)
        minDistance: minDistance of the peaks (in number of windows) 

	*/

	use myWork.spectral_adj;
	read all var _NUM_ into s_new;
	close myWork.spectral_adj;
/**/
/*	use myWork.Fs;*/
/*	read all var _NUM_ into Fs;*/
/*	close myWork.Fs;*/
	Fs = 11025;
	select_win_num = 150;

	ds = dimension(s_new);
	num_freq = ds[1];
	num_wins = ds[2];

	freq_x = do(1, num_freq, 1)*Fs/(2*num_freq);

	minH = mean(s_new[:]);
	minD = round(100*2*num_freq/Fs); /*no two peaks within 100 Hz */
	
	/* Search for the fundamental frequency */
	minFidx = 300*2*num_freq/Fs;
	maxFidx = 500*2*num_freq/Fs;
/*	print maxFidx, minFidx;*/

	idx_seg = do(1, num_freq, 1);
	filter = minH // . // . // . // . // minD;

	/* create var for dataset for instanttfa example */
	all_wins = .;
	all_F0s  = .;

	
	do i = 30 to 60;
	print i;
		cur_seg = s_new[, i];

		idx = peakloc(cur_seg, filter);

		val = j(1, max(nrow(cur_seg),ncol(cur_seg)), .);
		val[idx] = cur_seg[idx];

/*		title "Filtered Peaks";*/
/*		call series(freq_x, cur_seg) grid={x y}*/
/*   		scatterX=freq_x scatterY=val*/
/*   		scatterOption="markerattrs=(size=12)"*/
/*   		scatterOnTop=0;*/


		idx_F = loc(idx < maxFidx & idx > minFidx);
		
		
		if isempty(idx_F) then do;
			print "empty fundamental frequency";
			print i;
			goto CONTINUE;
		end;
/*		print(idx_F);*/
		temp_idx = loc(max(val[idx_F]));
		start_idx = idx_F[temp_idx];
		F_idx = idx[start_idx];
		F_val = val[F_idx];
/*		print start_idx;*/
		
		/* check if promimence is high enough to be a fundamental frequency */
		min_prom= 5;
		call peakinfo(output1, labels1, cur_seg,F_idx);
		if(output1[1,9]<min_prom) then do;
					print "Prominence too low";
					print(output1[1,9]);
			goto CONTINUE;
		end;

		F0 = F_idx*Fs/(2*num_freq);
/*		print F0;*/
		all_wins = all_wins // i;
		all_F0s = all_F0s // F0;

		tolerance = 80 * 2*num_freq/Fs;
		nidx = max(nrow(idx),ncol(idx));
		harmonics_idx = j(nidx, 1, 0);


/*		print nidx;*/
		hflag = 0;
/*		print F_idx;*/
		do j= start_idx+1 to nidx;
			cur_idx = idx[j];
/*			print cur_idx;*/
			r = mod(cur_idx, F_idx);
			r_c = F_idx - r;

			if (r < tolerance) | (r_c < tolerance) then do;
				harmonics_idx[j] = 1;
				hflag = 1;
			end;
		end;
		
		if (hflag<1) then do;
			print "no harmonics found: hflag 0";
			goto CONTINUE;
		end;

	

		temp_idx = loc(harmonics_idx>0);
		h_idx = idx[temp_idx];
		h_val = val[h_idx];

/*		print(val);*/
/*		print(idx);*/
/*		print(temp_idx);*/
/*		print(h_idx);*/
/*		print(h_val);*/

		if isempty(h_idx) then do;
			print "empty harmonics h_idx empty";
			print i;
			goto CONTINUE;
		end;
		h_freqval=h_idx*Fs/(2*num_freq);
	    F_freqval=F_idx*Fs/(2*num_freq);
		
		 create plotData var {freq_x, cur_seg, F_freqval, F_val, h_freqval, h_val};
		append;
		close plotData;  
allpks = F_idx // h_idx;
call peakinfo(output1, labels1, cur_seg,allpks);
print(nrow(labels1));
print(ncol(labels1));
labels = labels1[1] || labels1[9] || labels1[14];

print (output1[,{1 9 14}]`)[r=labels c=('Peak1':'Peak8') format=best5.];

/*print (output1`)[r=labels1 c=('Peak1':'Peak8') format=best5.];*/

		
/*		call series(idx_seg, cur_seg) grid={x y}*/
/*   		scatterX=h_freqval scatterY=h_val*/
/*   		scatterOption="markerattrs=(size=12)"*/
/*		scatterX=F_idx scatterY=F_val*/
/*   		scatterOption="markerattrs=(size=20)"*/
/*   		scatterOnTop=0;*/




		 submit;
			proc sgplot data=plotData;
				series  x=freq_x y=cur_seg / lineattrs=(thickness=2) legendlabel="Spectral Curve";
				scatter x=h_freqval y=h_val / filledoutlinedmarkers 
   									  markerfillattrs=(color=green) 
   									  markeroutlineattrs=(color=green thickness=2)
   									  markerattrs=(symbol=circlefilled size=13)
                                      legendlabel="Harmonics";
				scatter x=F_freqval y=F_val / filledoutlinedmarkers 
   									  markerfillattrs=(color=red) 
   									  markeroutlineattrs=(color=red thickness=2)
   									  markerattrs=(symbol=circlefilled size=13)
                                      legendlabel="Fundamental Frequency";
				xaxis label="Frequency (Hz)";
				yaxis label="Magnitude (dB)";
			    title "F0 and harmonics";
			run;
	    endsubmit; 
	CONTINUE:
	end; 

	create Mywork.fundFreq var {all_wins, all_F0s};
	append;
	close Mywork.fundFreq;
quit;
