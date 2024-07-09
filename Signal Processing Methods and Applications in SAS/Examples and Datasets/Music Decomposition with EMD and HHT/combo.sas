/* Must replace the file locations (line 5,137,138) with your own before running this code */
/* Must have run the %read_wav and %write_wav macros before this code can work */

proc iml;
%read_wav(file=C:\yourInputFileLocation\combo.wav,_out=work.combo);

quit;
%let down_sample_factor = 10;
%macro down_sample_data(factor);
	%let cutoff_freq = %sysevalf(1.0/(&factor));
	%put &cutoff_freq;

	proc iml;
		use work.combo;
		read all var {time, channel1};
		close work.combo;

		t = time;
		x = channel1;

		filter_name = "butter";
		filter_type = "lowpass";
		n = 10;
		Wc = &cutoff_freq;
		print(Wc);

		call dfdesign(b, a, z, p, k, filter_name, filter_type, n, Wc);
		y = dfsosfilt(x, z, p, k);
	
		dim = dimension(y);
		len = dim[1];

		idx = do(1, len, &factor);
		time = t[idx];
		channel1 = y[idx];

		create work.combo_data_new var {time, channel1};
		append;
		close work.combo_data_new;
	quit;

	proc sgplot data=work.combo_data_new;
	  title " Data Downsampled";
	  series x=time y=channel1;
	  xaxis label= "Time (second)";
	  yaxis label= "Amplitude";
 	run;
%mend;
%down_sample_data(&down_sample_factor)
proc iml;
use work.combo_data_new;
   read all var {time channel1};
close;
SampRate = mean((time[2:10]-time[1:9]));
pi = constant("pi");
fs = 1/SampRate; /* according to sgf paper - Need to verify*/

signal = channel1;
tmestep = 1/fs;
music_rows = nrow(signal);

endtime = music_rows/fs;
time_rows = nrow(time);


print music_rows, time_rows;
print(time[music_rows]);

 call EMD(IMF, residual, signal);

 totalIMFs = ncol(IMF);
 print(totalIMFs);


title "IMFs Time Series Flute and Bass combination";
call panelSeries(time, IMF) grid="y" label={"time" "IMF"} NROWS= totalIMFs;


freqRes = .;
freqRange = .;
energyThreshold = 1;
format = 'SPARSE';

call HHT(Amp, Phase, hhtFreqs, time, IMF, fs);
Energy = Amp##2;


title "Instantaneous Frequencies of IMFs Flute and Bass combination";
call PanelScatter(time, hhtFreqs[,1:totalIMFs])
                  colorvar=Energy[,1:totalIMFs]
                  colorramp=palette("YLORRD",7)
                  nrows = 1
                  option="markerattrs=(symbol=CircleFilled size=3)";




title "Instantaneous Frequencies of IMFs Flute and Bass combination";
call HHTSPECTRUM(spectrum, specfreq, time, IMF, fs,
  freqRes, freqRange, energyThreshold, format);

varnames = {'time', 'channel1'};

e = (Energy[,2]);
create energy from e[colname=varnames];
append from e;
close energy;

fluterange = j(music_rows,2);
bassrange = fluterange;

fluteend = 5441;
temp1 = IMF[1:fluteend,1]+IMF[1:fluteend,2];
fluterange[1:fluteend,1] = time[1:fluteend,1];
fluterange[1:fluteend,2] = temp1;

create fluteout from fluterange[colname=varnames];
append from fluterange;
close fluteout;

temp2 = IMF[,3]+IMF[,4];
temp2[fluteend:music_rows] = temp2[fluteend:music_rows]+IMF[fluteend:music_rows,2];
bassrange[1:music_rows,1] = time;
bassrange[1:music_rows,2] = temp2;


create bassout from bassrange[colname=varnames];
append from bassrange;
close bassout;

create energy from e[colname=varnames];
append from e;
close energy;

quit;

%write_wav(indata=work.fluteout,sampling_frequency=5530,_out=%nrbquote(C:\yourOutputFileLocation\fluteout.wav) );
%write_wav(indata=work.bassout,sampling_frequency=5530,_out=%nrbquote(C:\yourOutputFileLocation\bassout.wav) );
