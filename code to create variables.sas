***for log****;
dm 'log; clear;';
dm 'output; clear;';

***compile macro csvtxt2sas to convert csv file to sas dataset****;
%include "C:\Users\HP\Desktop\sugi17\csvtxt2sas.sas" ;
***calling macro csvtxt2sas to create bankdata3******;
%csvtxt2sas(out=bankdata , in=%str('C:\Users\HP\Desktop\sugi17\Bank transactional data.csv'), delimit=%str(',') );

****modify the data to automate the process****;
libname xxx "C:\Users\HP\Desktop\sugi17";
data xxx.bankdata3(drop=amount_);
	set BANKDATA3(rename=(amount=amount_));
	***convert amount from character to numeric to get the statistics***;
	amount = input(amount_,best.) ;
	trandate = input(scan(time_stamp,1,''),mmddyy10.);
	format trandate mmddyy10.;
run;
%macro duration(dsinmain= ,trandate= , keyvar= ,mon= );
	proc sort data = &dsinmain. out=bank;
		by &keyvar. &trandate.; run;
	data cutoffdt1(keep=&keyvar. cutoffdt);
		set bank;
		by  &keyvar. &trandate.;
		if first.&keyvar.; 
		cutoffdt=&trandate.+(&mon.*30); format cutoffdt mmddyy10.; run;
	proc sort data = cutoffdt1; by &keyvar.; run;
	data bankmon&mon.;
		merge bank(in=a) cutoffdt1(in=b);
		by &keyvar.; 
		if &trandate. le cutoffdt;	run;
%mend duration;

****************************************************************************************************;
**Get summary statistics of different transactions on bank data     							 ***;
**dsinmain=name of the main input dataset                   									 ***
**stat1 = first summary statistics																 ***
**stat2 = second summary statistics																 ***
**stat3 = third summary statistics																 ***
**stat4 = fourth summary statistics																 ***
**stat5 = fifth summary statistics																 ***
**nstat = total number of statistics we want to calculate.If we want to process stat1 to stat3 then*
**        nstat will be 3, if stat1 to stat5 then nstat will be 5                                ***
**keyvar= key variable in the data for example: customer id in case of bank data				 ***
**month = months for which we want to calculate the statistics. The values should be sepeated by ***
**        blank space. For example - month = 1 2 3 or month= 3 6                                 ***
**trandate = numeric value of date in the main input dataset, time part not attached to date     ***
****************************************************************************************************;
options mprint  mlogic nosymbolgen;
%macro autobank(dsinmain= ,stat1=sum, stat2=count, stat3=max, stat4=min ,stat5=avg, nstat=5,keyvar= ,month= ,trandate=);
	%local dsin mon;
	%let counter=1 ;
	%let mon = %scan(&month,&counter);
	%do %while(&mon ne ) ;
			%duration(dsinmain=&dsinmain.,trandate=&trandate., keyvar=&keyvar.,mon=&mon.);
			%let dsin=bankmon&mon. ;
		    proc sql noprint;
				select distinct strip(Transction) into:newtran separated by ',' 
				from &dsin.;
			quit;
			%put &newtran. ;
			****macro to calculate statistics on one transaction***;
			%macro bank;
				***get distinct value of keyvariables in data***;
				proc sql noprint;
					create table base as
					select distinct &keyvar.
					from &dsin.;
				***repeat this process for different statistics as required***;
				%do i = 1 %to &nstat. ;
				  /***calculate statistics like sum,count,max,min,avg*/
					proc sql noprint;
					  create table stat&i. as (
					   select &keyvar. ,&&stat&i.  (case when Transction="&dsname" then Amount else . end) as mon&mon.&dsname&&stat&i.
					   from &dsin.
					   Group by &keyvar.);
					 %if &i. eq 1 %then %do;
						  create table f&dsname.&i. as
						   select a.&keyvar.,b.mon&mon.&dsname&&stat&i.
						   from base as a left join stat&i. as b
						   on a.&keyvar. = b.&keyvar.;
						quit;
					 %end;
					 %else %if &i. gt 1 %then %do;
					    create table f&dsname.&i. as
						select a.*,b.mon&mon.&dsname&&stat&i.
						from f&dsname.%eval(&i.-1)  as a left join stat&i. as b
						on a.&keyvar. = b.&keyvar.;
					 %end;
					 %if &i. eq &nstat. %then %do;
					 	create table &dsname. as
						select *
						from f&dsname.&i. ;
					 %end;
					quit;
				%end;
			%mend bank;

			***macro to calculate statistics on different transactions****;
			%macro transactions/parmbuff; 
				%put Syspbuff contains: &syspbuff; 
					%let num=1; 
					%let dsname=%scan(&syspbuff,&num); 
				%do %while(&dsname ne );
					%bank ;
					%if &num eq 1 %then %do;
						proc sort data = &dsname. out=mon&mon.final;
							by &keyvar.;
						run;
					%end;
					%if &num gt 1 %then %do;
						proc sort data = &dsname.;
							by &keyvar.;
						run;
						data mon&mon.final;
							merge mon&mon.final(in=a) &dsname.(in=b);
							by &keyvar.;
							if a=1 or b=1;
						run;
					%end;
					%let num=%eval(&num+1); 
					%let dsname=%scan(&syspbuff,&num); 
			    %end; 
			%mend transactions; 
			%transactions(&newtran.) ;
		%if &counter eq 1 %then %do;
			data final;
				set mon&mon.final; run;
			proc sort data = final; 
				by &keyvar.; run;  
		%end;
		%if &counter gt 1 %then %do;
			proc sort data = mon&mon.final;
				by &keyvar.;
			run;
			data final;
				merge final(in=a) mon&mon.final(in=b);
				by &keyvar.;
			run;
		%end;
		%let counter=%eval(&counter+1) ;
		%let mon = %scan(&month,&counter.);
	%end;	
%mend autobank;

%autobank(dsinmain=xxx.bankdata3,stat1=sum, stat2=count, stat3=max, stat4=min ,stat5=avg,nstat=5,keyvar=customer_id,
          month=3 6,trandate=trandate);    



ods listing;
ods csv file = "C:\Users\HP\Desktop\sugi17\result.csv";
options missing=" ";
ods csv close;
DM log 'log; file "C:\Users\HP\Desktop\sugi17\code.log" replace' log;
