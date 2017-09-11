****************************************************************************************************;
**CSV or TXT(pipe delimited) to SAS                       										 ***;
**out=name of the final dataset example: if out=bank then final data will be bank3				 ***
**in=name of input file with location for example:C:\Users\Bank transactional data.csv			 ***
**delimit = file delimiter for example if .csv file then: %str(','), if pipe-delimited .txt file ***
**   		then  %str('|')        																 ***
***************************************************************************************************;

%macro csvtxt2sas(out= , in= ,delimit=);
	OPTIONS OBS = 1;
	data info;
         infile &in. delimiter = '##' MISSOVER DSD lrecl=32767 firstobs=01  termstr=crlf;
         informat VAR1  $2000. ;   
         format VAR1 $2000. ;
      	 input VAR1 $ ;
	run;
	OPTIONS OBS=MAX ;

	data varname ;
		set info ;
		count=1 ;
		labl = scan(var1,count,&delimit.);
		do while (labl ne '');
			labl = scan(var1,count,&delimit.);
			output;
			count+1;
		end;
	run;
	data INFO4NAME ;
		set varname end=eof;
		name = tranwrd(strip(labl),'','_') ;
		name = tranwrd(strip(name),'/','_') ;
		if eof then delete;
	run;
			
	PROC SQL NOPRINT;
		SELECT COUNT(NAME) INTO: TOTVAR
		FROM INFO4NAME;
		SELECT NAME INTO: VAR1 - :VAR%SYSFUNC(STRIP(&TOTVAR))
		FROM INFO4NAME;
		SELECT LABL INTO: LABL1 - :LABL%SYSFUNC(STRIP(&TOTVAR))
		FROM INFO4NAME;
	QUIT;
	%put _user_ ;

	data &out.;
         infile &in. delimiter = &delimit. MISSOVER DSD lrecl=32767 firstobs=01  termstr=crlf;
         informat VAR1 - VAR%SYSFUNC(STRIP(&TOTVAR)) $200. ;   
         format VAR1 - VAR%SYSFUNC(STRIP(&TOTVAR)) $200. ;
      	 input VAR1 - VAR%SYSFUNC(STRIP(&TOTVAR)) $ ;
	run;
	
	data &out.1;
		set &out.;
		array extra{*} var1 - VAR%SYSFUNC(STRIP(&TOTVAR));
		count = 0;
		do i = 1 to dim(extra);
			if missing(extra{i}) then do;
				count+1;
			end;
			if count eq %SYSFUNC(STRIP(&TOTVAR)) then do;
				*put var1-VAR%SYSFUNC(STRIP(&TOTVAR)) count;
				delete;
			end;
		end;
		drop i count;
	run;
	
    data &out.2;
		set &out.1(firstobs=2 ); 
		rename 
		%do i = 1 %to %SYSFUNC(STRIP(&TOTVAR)) ;
			%let newvar = var&i;
			var%SYSFUNC(STRIP(&i)) = &&&newvar 
		%end;
		 ;
	run;	
	
	data &out.3;
		attrib 
		%do i = 1 %to %SYSFUNC(STRIP(&TOTVAR)) ;
			%let lablvar = labl&i;
			%let newvar = var&i;
			&&&newvar		LABEL = "&&&lablvar"
		%end;
		;
		set &out.2;
	run;
	
%mend;


