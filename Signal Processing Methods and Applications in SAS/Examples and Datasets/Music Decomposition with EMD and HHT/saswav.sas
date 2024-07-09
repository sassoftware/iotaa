/*
* MACRO READ_WAV
* READS SIMPLE WAV FILES WITH DATA STORED IN PCM FORMAT AND
* CREATES AN OUTPUT SAS DATASET WITH VARIABLES TIME,CHANNEL1, ..., CHANNELn
* WHERE N IS THE NUMBER OF CHANNELS IN THE WAV FILE
* ONLY MS RIFF WAV FILES AND BROADCAST WAV FORMAT SUPPORTED
* ARGUMENTS
* FILE (IN) : PATH TO THE WAV FILE
* _OUT (OUT) : THE SAS DATASET WHERE TO STORE THE RESULT
*
* OPTIONAL ARGUMENT:
* FILRF (IN) : The FILEREF ASSIGNED TO THE INPUT FILE, DEFAULT
          VALUE IS FWAV344. CHANGE THIS IF THIS NAME CLASHES WITH AN
          EXISTING FILEREF IN YOUR SESSION.
*
* NOT SUPPORTED. USE AT YOUR OWN RISK. 
*
* Sample usage:
   %read_wav(file=X:\BabyElephantWalk60.wav,_out=work.out42);

*/

options mcompilenote=all;
%macro read_wav(
        file=,
        filrf=fwav344,
        _out=);


%macro setError;
    call symputx("error",'1','l');
%mend;

%macro abort_on_ovf;
    if (&offset + &nbytes) > &fsize then do;
        put "ERROR: DAMAGED WAV FILE";
        %seterror;
        stop;
    end;
%mend;

%macro get_str(offset,nbytes,str);
    %abort_on_ovf;
    &str = "";
    do i = 1 to &nbytes;
        input @((&offset-1)+i) c $1.;
        substr(&str,i,1) = c;
    end;
    put &str=;
%mend;

%macro expect_str(offset,nbytes,exp_str);
    %abort_on_ovf;
    str = "";
    pass = 0;
    input @(&offset) str $&nbytes..;
    exp_str=trim(left("&exp_str"));
    if str ^= exp_str then do;
        put "ERROR: INVALID WAV FILE";
    end;
    else pass = 1;
    put "EXPECT " exp_str "AT OFFSET:&offset BYTES:&nbytes FOUND:" str pass=;
    if ^pass then do;
        %seterror;
        stop;
    end;
%mend;

/*-----read nbytes assuming little endian sas----*/
%macro read_uint(offset,nbytes,var);
   input @(&offset) &var pibr&nbytes..;
   put &var=;
%mend;

%local error;
%local clearf;

%let error = 0;
%let clearf = 0;

%let syscc = 0;

%let file=%superq(file);
%if ^%sysfunc(fileexist(&file)) %then %do;
   %put ERROR: WAV FILE DOES NOT EXIST OR IS UNREADABLE;
   %goto ERROR;
%end;

filename &filrf "&file" recfm=n;
%if &error or (&syscc > 4) %then %goto error;
%let clearf = 1;

%local fsize;
%local min_fsize;
%let min_fsize = 45;
data _null_;
    fid=fopen("&filrf","i");
    if ^fid then do; 
      put "ERROR: WAV FILE DOES NOT EXIST OR IS UNREADABLE;";
      %seterror; 
      stop;
    end;
    fsize = input(finfo(fid,"File Size (bytes)"),best.);
    rc = fclose(fid);
    if ^fsize or (fsize < &min_fsize) then do;
       put "ERROR: WAV FILE HAS TOO FEW BYTES, POSSIBLY DAMAGED";
       %seterror; 
       stop;
    end;  
    call symputx("fsize",left(input(fsize,best.)),'l'); 
run;

%if &error or (&syscc > 4) %then %goto error;

%put File size in bytes is &fsize;

%local BytesPerSample;
%local DataOffset;
%local NumChannels;
%local NumSamples;
%local SampleRate;

data _null_;
infile &filrf recfm=n;
length str $4;
length current_chunk_name $4;
length c $1;
length k 8;
length count 8;
length current_chunk_offset 8;
length current_chunk_size 8;
length data_chunk_offset 8;
length fsize 8;
length done 4;

call missing(of _all_);
fsize = &fsize;


%expect_str(1,4,RIFF);
%expect_str(9,4,WAVE);

current_chunk_offset = 13;
done = 0;

/*----ignore all chunks except the fmt and data chunk----*/
/*----clearly something is wrong if there are more than 128 chunks---*/

do count = 1 to 128;
    %get_str(current_chunk_offset,4,current_chunk_name);
    %read_uint(current_chunk_offset+4,4,current_chunk_size);
    if current_chunk_name = "fmt" then do;
        fmt_chunk_offset = current_chunk_offset;
        done = done + 1;
    end;
    else if current_chunk_name = "data" then do;
        data_chunk_offset = current_chunk_offset;
        done = done + 1;
    end;

    if done = 2 then leave;
    current_chunk_offset = current_chunk_offset + 8 + current_chunk_size;
end;

if missing(data_chunk_offset) then do;
    put "ERROR: DAMAGED WAV FILE. DATA CHUNK NOT FOUND.";
    %seterror;
    stop;
end;

if missing(fmt_chunk_offset) then do;
    put "ERROR: DAMAGED WAV FILE. FORMAT CHUNK NOT FOUND.";
    %seterror;
    stop;
end;

%expect_str(fmt_chunk_offset,4,fmt);
%read_uint(fmt_chunk_offset+4,4,fmt_chunk_size);

%read_uint(fmt_chunk_offset+8,2,AudioFormat);
%read_uint(fmt_chunk_offset+10,2,NumChannels);
%read_uint(fmt_chunk_offset+12,4,SampleRate);
%read_uint(fmt_chunk_offset+16,4,ByteRate);
%read_uint(fmt_chunk_offset+20,2,BlockAlign);
%read_uint(fmt_chunk_offset+22,2,BitsPerSample);

if AudioFormat ^= 1 then do;
    put "ERROR: ONLY PCM FORMAT SUPPORTED";
    %seterror;
    stop;
end;

/*---Unexpected, but ignore it----*/
if AudioFormat = 1 and fmt_chunk_size ^= 16 then do;
    put "WARNING: Unexpected chunk size for PCM format";
end;

%expect_str(data_chunk_offset,4,data);
%read_uint(data_chunk_offset+4,4,data_size);
if (data_chunk_offset + 7 + data_size) > fsize then do;
    put "ERROR: DAMAGED WAV FILE";
    %seterror;
    stop;
end;

if( (BitsPerSample ^= floorz(BitsPerSample)) or 
    (mod(BitsPerSample,8) ^= 0) or (BitsPerSample > 32) ) then do;
    put "ERROR: DAMAGED WAV FILE. UNEXPECTED BitsPerSample VALUE";
    %seterror;
    stop;
end;

BytesPerSample = BitsPerSample/8;
DataOffset = data_chunk_offset + 8;
if (NumChannels <= 0) or missing(NumChannels) or (NumChannels ^= floorz(NumChannels)) then do;
    put "ERROR: DAMAGED WAV FILE. UNEXPECTED NumChannels VALUE";
    %seterror;
    stop;
end;

NumSamples = data_size / (BytesPerSample * NumChannels); 
if((NumSamples ^= floorz(NumSamples)) or (Numsamples < 0)) then do;
    put "ERROR: DAMAGED WAV FILE. UNEXPECTED NumSamples VALUE";
    %seterror;
    stop;
end;

call symputx("BytesPerSample",left(put(BytesPerSample,best.)),'l');
call symputx("DataOffset",left(put(DataOffset,best.)),'l');
call symputx("NumChannels",left(put(NumChannels,best.)),'l');
call symputx("NumSamples",left(put(NumSamples,best.)),'l');
call symputx("SampleRate",left(put(SampleRate,best.)),'l');
stop;
run;
%if &error or (&syscc > 4) %then %goto error;


data &_out;
length time 8;
infile &filrf recfm=n;
retain base_offset &DataOffset;
%if &NumChannels > 1 %then %do;
    array channel{*} channel1 -channel&NumChannels;
%end;
%else %do;
    array channel{*} channel1;
%end;

tf = 1/&SampleRate;
sf = 1/(2**((&BytesPerSample*8) - 1));

do i = 1 to &NumSamples;
    offset = base_offset + (i-1)*&BytesPerSample*&NumChannels;
    time = (i-1)*tf;
    do c = 1 to &NumChannels;
        input @(offset+(c-1)*&BytesPerSample) channel{c} ibr&bytespersample..;
        channel{c} = channel{c}*sf;
    end;
    output;
end;
stop;
keep time channel:;
run;
%if &error or (&syscc > 4) %then %goto error;

filename &filrf clear;

%return;


%ERROR:

%put ERROR: ERROR READING WAVE FILE;
%if &clearf %then %do;
    filename &filrf clear;
%end;
%return;
%mend;
