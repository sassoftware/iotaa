/*-----
* MACRO WRITE_WAV
* READS WRITE WAV FILES FROM CHANNEL DATA
* CREATES A WAVE FILE
* ARGUMENTS
* INDATA (IN): SAS DATSET CONTAINING THE CHANNEL DATA
* SAMPLING_FREQUENCY: THE SAMPLING FREQUENCY, MUST BE PROVIDED, TYPICAL VALUE IS 22050.
* _OUT  (OUT) : PATH TO THE OUTPUT WAV FILE
*
* OPTIONAL ARGUMENT:
* NUM_CHANNELS : The number of channels. If num_channels=2, say, columns, CHANNEL1, CHANNEL2
                 must exist in the dataset.

* FILRF (IN) : The FILEREF ASSIGNED TO THE INPUT FILE, DEFAULT
          VALUE IS FWAV344. CHANGE THIS IF THIS NAME CLASHES WITH AN
          EXISTING FILEREF IN YOUR SESSION.
*
* NOT SUPPORTED. USE AT YOUR OWN RISK. 
*
* Sample usage:   
    %write_wav(indata=work.abc,sampling_frequency=22050,_out=%nrbquote(C:\Public\temp\def.wav) );
*/

%macro write_wav(
        indata=,
        num_channels=1,
        filrf=fwav344,
        sampling_frequency=,
        _out=);

%local bits_per_sample;
%let bits_per_sample=16;

%if "%datatyp(&sampling_frequency)" ^= "NUMERIC" %then %do;
    %put ERROR: INVALID SAMPLING_FREQUENCY VALUE;
    %return;
%end;

%if "%datatyp(&num_channels)" ^= "NUMERIC" %then %do;
    %put ERROR: INVALID NUM_CHANNELS VALUES;
    %return;
%end;


%let _out=%superq(_out);

%if "&_out" = "" %then %do;
    %put ERROR: OUTPUT WAV FILE MUST BE PROVIDED;
    %return;
%end;

%local error;
%let error=0;

data _null_;

dsid = open("&indata");
if ^dsid then do;
    put "ERROR: UNABLE TO READ INPUT DATA";
    dsid = 0;
    goto error;
end;

do i = 1 to &num_channels;
    if ^varnum(dsid,catt("channel",left(put(i,best.))) ) then do;
        put "ERROR: EXPECTED CHANNEL DATA NOT FOUND";
        goto ERROR;
    end;
end;

rc = close(dsid);
stop;

error:
call symputx("error","1",'l');
if dsid then rc = close(dsid);
stop;
run;

%if "&error" = "1" %then %do;
    %return;
%end;

filename &filrf "&_out" recfm=n;
data _null_;
file &filrf recfm=n;
if 0 then set &indata nobs=NumSamples;

retain Subchunk1Size 16;
retain AudioFormat   1;
retain NumChannels &num_channels;
retain SampleRate &sampling_frequency;
retain ByteRate;
retain BitsPerSample &bits_per_sample;
retain BlockAlign;
retain SubChunk2Size;
retain sf %sysevalf(2**(&bits_per_sample-1));
ByteRate = SampleRate * NumChannels * BitsPerSample/8;
BlockAlign = NumChannels * BitsPerSample/8;

SubChunk2Size = NumSamples * NumChannels * BitsPerSample/8;

put @1 "RIFF.`(.WAVEfmt ";
put @17 Subchunk1Size ib4.; 
put @21 AudioFormat   ib2.;
put @23 NumChannels   ib2.;
put @25 SampleRate    ib4.;
put @29 ByteRate      ib4.;
put @33 BlockAlign    ib2.;
put @35 BitsPerSample ib2.;
put @37 "data";
put @41 SubChunk2Size ib4.;

%if &Num_Channels > 1 %then %do;
    array channel{*} channel1 -channel&Num_Channels;
%end;
%else %do;
    array channel{*} channel1;
%end;

do i = 1 to NumSamples;
    set &indata point=i;
    offset = 45 + (i-1)*NumChannels * 2;
    do j = 1 to NumChannels;
        v = floor(channel{j}*sf);
        put @(offset+(j-1)*2) v ib2.;
    end;
end;
stop;
run;
filename &filrf clear;

%mend;
