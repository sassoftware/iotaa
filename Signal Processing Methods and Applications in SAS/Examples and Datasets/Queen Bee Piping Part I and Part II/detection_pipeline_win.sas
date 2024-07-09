/* This script is the pipeline for bee piping detection */
/*ods graphics /NXYBINSMAX= 4100000   MAXOBS=2957312;*/
ods graphics /NXYBINSMAX= 4100000  DISCRETEMAX=2300 MaxOBS=2957312 ANTIALIASMAX=595000;

/* 1. Set up the important paths, note .\ is the current path where the SAS client is running */

	/* Where SAS programs that we need to use to process the data */
%let current_path = C:\LYW\Projects\Signal_Processing\IoT\Bee_Data\Audio_Processing\Code\SGF_Demo;
%let codelib = &current_path\codelib; 
%put &codelib;

libname h "C:\LYW\Projects\Signal_Processing\IoT\Bee_Data\Audio_Processing\Code\SGF_Demo\data";

%include "&codelib\saswav.sas";
%include "&codelib\writewav.sas";
%include "&codelib\heatmap.sas";


/* Where the data is */
%let datapath = &current_path\data;

%let QUEEN_PIPING = 1;
%let WORKER_PIPING = 2;
%let data_set = &QUEEN_PIPING;

%let piping_data_in  = piping_data_original; 
%let piping_data_new = piping_data; 

%if &data_set eq &QUEEN_PIPING %then %do;
	%let spectral_data = spectral_queen;
%end;
%else %do;
	%let spectral_data = spectral_worker;
%end;

%let down_sample_factor = 4;

/* 2. Reading in a piping sound file  */
%macro read_piping_wav(data_set_num);
	%if &data_set eq &QUEEN_PIPING %then %do;
		%let wav_file_name = "&datapath\queen-piping_d.wav";
	%end;
	%else %do;
		%let wav_file_name = "&datapath\worker_piping.wav";
	%end;
	%put Loading...&wav_file_name;

	%read_wav(file=&wav_file_name,_out=&piping_data_in);

	proc sgplot data=work.&piping_data_in;
	  title "Piping Data Original";
	  series x=time y=channel1;
	  xaxis label= "Time (second)";
	  yaxis label= "Amplitude";
 	run;
%mend;
%read_piping_wav(&data_set)


/*3. Downsample the data by to 1/4 sampling rate */
%macro down_sample_data(factor);
	%let cutoff_freq = %sysevalf(1.0/&factor);
	%put &cutoff_freq;

	proc iml;
		use work.&piping_data_in;
		read all var {time, channel1};
		close work.&piping_data_in;

		t = time;
		x = channel1;

		filter_name = "butter";
		filter_type = "lowpass";
		n = 10;
		Wc = &cutoff_freq;

		call dfdesign(b, a, z, p, k, filter_name, filter_type, n, Wc);
		y = dfsosfilt(x, z, p, k);
	
		dim = dimension(y);
		len = dim[1];

		idx = do(1, len, &factor);
		time = t[idx];
		channel1 = y[idx];

		create work.&piping_data_new var {time, channel1};
		append;
		close work.&piping_data_new;
	quit;

	proc sgplot data=work.&piping_data_new;
	  title "Piping Data Downsampled";
	  series x=time y=channel1;
	  xaxis label= "Time (second)";
	  yaxis label= "Amplitude";
 	run;
%mend;
%down_sample_data(&down_sample_factor)

/*4. Calculate the TF heatmap based on Yule-Walker method */
%put &data_set;
%if &data_set eq &QUEEN_PIPING %then %do;
	%let win_len_t = 0.15;
	%let order = 50;
%end;
%else %do;
	%let win_len_t = 0.3;
	%let order = 50;
%end;

proc iml;
	use work.&piping_data_new;
	read all var {time, channel1};
	close work.&piping_data_new;

	t = time;
	x = channel1;

	/* get data length */
	d = dimension(x);
   	sig_len = d[1];
		
	/* get sampling rate */
	Fs = 1/(t[2]-t[1]);

	create work.Fs var {Fs};
		append;
	close work.Fs;

	/* compute the window length by # of samples */
	win_len = round(Fs * &win_len_t);
	NFFT = 2##(ceil(log(win_len)/log(2))); 

	/*loop through all windows to compute the Yule-Walker estimation */
	num_wins = floor(sig_len/(win_len/2));
	s = j(NFFT, num_wins, 0);
	do i = 1 to 1;
	    
       	cur_win_start = (i-1)* win_len/2+1;
      	cur_win_end = min(cur_win_start+win_len - 1, sig_len);
       	cur_sig = x[cur_win_start:cur_win_end];
		cur_win_len = cur_win_end - cur_win_start + 1;

	   	/*use proc autoreg with YuleWalker method */
		
		y = cur_sig;
		t1 = do(1, cur_win_len, 1);
		create work.myWindowData var {y t1};
			append;
		close work.myWindowData;

        submit;
			ods exclude all;
			ods select ARParameterEstimates;
			ods output ARParameterEstimates=work.myWindowEst;
			proc autoreg data=work.myWindowData;
		   		model y = t1 / nlag=&order method=yw;
	    	run;
		endsubmit;

		use work.myWindowEst;
		read all var {"estimate"};
		close work.myWindowEst;
	
		a = 1 // estimate;
		b = 1;
		da = dimension(a);
		h = dffreqz(b, a, NFFT);
		w1 = h[,3] / constant('pi');
		w2 = w1 * Fs/2;
	    logh = 20*log10(sqrt(h[,1]##2+h[,2]##2) + 1e-16);

		s[,i] = logh;
		/*title "Frequency Response";
		call series(w1,logh) grid= {X Y};*/
	end;

	create work.&spectral_data from s;
		append from s;
	close work.&spectral_data;

	create work.freq from w2;
		append from w2;
	close work.freq;

quit;
/* commented for now, because don't want to overwrite it */
/*data h.spectral;
	set work.spectral;
run;
*/ 

/*data h.freq;
	set work.freq;
run;*/

data work.&spectral_data;
	set h.&spectral_data;
run;
%if &data_set eq &QUEEN_PIPING %then %do;
	%let first = 45;
	%let last = 0;
	%let freq_cutoff = 5000;
%end;
%else %do;
	%let first = 5;
	%let last = 0;
	%let freq_cutoff = 6000;
%end;

%createHeatmap(work.&spectral_data, work.freq, "Yule-Walker Spectral Estimation", dB, &freq_cutoff, &first., &last.);


/*5.  Adaptive adjust the spectral magnitude */
%macro adaptive_magnitude_adjustment();
data work.&spectral_data;
	set h.&spectral_data;
run;

proc iml;
	use work.&spectral_data;
	read all var _NUM_ into s;
	close work.&spectral_data;

	ds = dimension(s);
	num_freq = ds[1];
	num_wins = ds[2];

	avg_vec = s[, +]/num_wins;
	da = dimension(avg_vec);

	max_db_avg = max(avg_vec);
	avg_vec_inv = max_db_avg - avg_vec;
	avg_mat = repeat(avg_vec_inv, 1, num_wins);
	s_adj   = s + avg_mat;

	create work.spectral_adj from s_adj;
		append from s_adj;
	close work.spectral_adj;
quit;

%if &data_set eq &QUEEN_PIPING %then %do;
	%let first = 33;
	%let last = 0;
	%let freq_cutoff = 5000;
%end;
%else %do;
	%let first = 10;
	%let last = 0;
	%let freq_cutoff = 6000;
%end;
%createHeatmap(work.spectral_adj, work.freq, "After Adaptive Magnitude Adjustment", dB, &freq_cutoff, &first., &last.);
%mend;
%adaptive_magnitude_adjustment();


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
	start findPK(val, idx, x, minHeight, minDistance);
		n = nrow(x);
		val = {};
		idx = {};
		
		if n <= 1 then do;
			return;
		end;
	
		/* find the local maxima first */
		diff_vec = dif(x);
		diff_vec = diff_vec[2:n];

		sign_vec = j(n-1, 1, -1);
		sign_vec[loc(diff_vec>0)] = 1;

		diff_sign = dif(sign_vec);
		diff_sign = diff_sign[2:n-1];
		idx = loc(diff_sign < 0);

		if isempty(idx) then do;
			return;
		end;

		idx = idx + 1;
		val = x[idx];

		/* Check if the peaks exceed minHeight */
		idx_val = loc(val>minHeight);

		if isempty(idx_val) then do;
			val = {};
			idx = {};
			return;
		end;

		idx = idx[idx_val];
		val = x[idx];

		nidx = nrow(idx);
		/* Check if the distance between peaks exceeds the minDistance */
		call sortndx(idx_sort, val, 1, 1);
		delete_idx = j(nidx, 1, 0);
		do j=1 to nidx-1;
		    cur_idx = idx[idx_sort[j]];
			if delete_idx[j] = 0 then do;
				do k=j+1 to nidx;
					next_idx = idx[idx_sort[k]];
					cur_dist = abs(cur_idx - next_idx);
					if cur_dist < minDistance then do;
						delete_idx[k] = 1;
				    end;
				end;
			end;
		end;

		idx = idx[idx_sort[loc(delete_idx < 1)]];
		call sort(idx, 1);
		val = x[idx];
	finish;

	use work.spectral_adj;
	read all var _NUM_ into s_new;
	close work.spectral_adj;

	use work.Fs;
	read all var _NUM_ into Fs;
	close work.Fs;
	
	if &data_set = &QUEEN_PIPING then do;
		select_win_num = 150;
	end;
	else do;
		select_win_num = 331;
	end;
	

	ds = dimension(s_new);
	num_freq = ds[1];
	num_wins = ds[2];

	freq_x = do(1, num_freq, 1)*Fs/(2*num_freq);

	minH = mean(s_new[:]);
	minD = round(100*2*num_freq/Fs); /*no two peaks within 100 Hz */

	idx_seg = do(1, num_freq, 1);
	do i = select_win_num to select_win_num;
		cur_seg = s_new[, i];
		call findPK(val, idx, cur_seg, minH, minD);

		if isempty(idx) then do;
			print "empty peaks";
			print i;
			goto CONTINUE;
		end;

		/* Search for the fundamental frequency */
		minFidx = 300*2*num_freq/Fs;
		maxFidx = 500*2*num_freq/Fs;

		idx_F = loc(idx < maxFidx & idx > minFidx);

		if isempty(idx_F) then do;
			print "empty fundamental frequency";
			print i;
			goto CONTINUE;
		end;
		
		temp_idx = loc(max(val[idx_F]));
		start_idx = idx_F[temp_idx];
		F_idx = idx[start_idx];
		F_val = val[start_idx];

		F0 = F_idx*Fs/(2*num_freq);
		print F0;

		tolerance = 80 * 2*num_freq/Fs;
		nidx = nrow(idx);
		harmonics_idx = j(nidx, 1, 0);
		do j= start_idx+1 to nidx;
			cur_idx = idx[j];
			r = mod(cur_idx, F_idx);
			r_c = F_idx - r;
			if (r < tolerance) | (r_c < tolerance) then do;
				harmonics_idx[j] = 1;
			end;
		end;

		temp_idx = loc(harmonics_idx>0);
		h_idx = idx[temp_idx];
		h_val = val[temp_idx];
	
		if isempty(h_idx) then do;
			print "empty harmonics";
			print i;
			goto CONTINUE;
		end;

		create plotData var {idx_seg, cur_seg, F_idx, F_val, h_idx, h_val};
		append;
		close plotData; 
		submit;
			proc sgplot data=plotData;
				series  x=idx_seg y=cur_seg / lineattrs=(thickness=2) legendlabel="Spectral Curve";
				scatter x=h_idx y=h_val / filledoutlinedmarkers 
   									  markerfillattrs=(color=green) 
   									  markeroutlineattrs=(color=green thickness=2)
   									  markerattrs=(symbol=circlefilled size=13)
                                      legendlabel="Harmonics";
				scatter x=F_idx y=F_val / filledoutlinedmarkers 
   									  markerfillattrs=(color=red) 
   									  markeroutlineattrs=(color=red thickness=2)
   									  markerattrs=(symbol=circlefilled size=13)
                                      legendlabel="Fundamental Frequency";
				xaxis label="Frequency (Hz)";
				yaxis label="Magnitude (dB)";
			    title "Current Window";
			run;
	    endsubmit;
	CONTINUE:
	end;
quit;
