/*********************************************************************************************************
Using Dynamic Bayesian Network for Two-Tank Example
This example demonstrates how to use a dynamic Bayesian network model for a hypothetical, although 
somewhat realistic, example of a system of two tanks. This example is similar to the five-tank scenario 
from Lerner et al. (2000). For our example, there are two tanks connected by a pipe. There is liquid 
flowing into Tank 1 at a flow rate of f1_in and flowing out of Tank 1 at a flow rate of f1_(out), where 
C1_out denotes the conductance (that is, the reciprocal of resistance) for the pipe coming out of Tank 1. 
As mentioned previously, there is a pipe that connects Tank 1 and Tank 2, and liquid is flowing through 
it from Tank 1 to Tank 2 at a flow rate of f12, where C12 denotes the conductance of this connecting pipe. 
Liquid is also flowing out of Tank 2 at a flow rate of f2_out, where C2_out denotes the conductance of the 
pipe coming out of Tank 2. Let A_1 and A_2 denote the cross-sectional areas of Tank 1 and Tank 2, 
respectively, and let h_1 and h_2 denote the heights of the liquid in Tank 1 and Tank 2, respectively. 
A potential fault in this system is a leak in the pipe that goes from Tank 1 to Tank 2. When this leak 
fault is present, liquid leaks out of the pipe at a flow rate of f_leak, where C_leak denotes the 
conductance of the leak in the pipe. Finally, f1_outRd and f2_outRd are the sensor measurements for f1_out
and f2_out, respectively, with measurement error. 

Copyright © 2024, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0

*********************************************************************************************************/

/*---NOTE: you need to set up your CAS session first. ---*
 *---Here it is assumed that the CAS libname is casuser.---*/
 
/*---put the correct location of the data folder here---*/

libname d '.\two_tank';

data casuser.variableRoles;
   length varname $20;
   input varname $ varrole $;
datalines;
Time		TIMEID
H1		HIDDEN
H2		HIDDEN
Cleak		HIDDEN
Fault		HIDDEN
F1out_rd	OBSERVED
F2out_rd	OBSERVED
;

data casuser.variableLevels;
   length varname $20;
   length varlevel $20;
   input varname $ varlevel $;
datalines;
Fault	None
Fault	Leak
;

data casuser.variableLinks;
   length parent $20 child $20;
   input  parent $ child $ stage;
datalines;
Time            H1          1
Time            H2          1
Time            Cleak       1
H1              H1          2
H2              H2          2
Cleak           Cleak       2
Cleak           H1          2
H2              H1          2
H1              H2          2
H1              F1out_rd    1
H2              F2out_rd    1
Fault           Cleak       1
;

data casuser.initialBeliefs;
   length intervalvar $20 nominalvar $20 varlevel $20;
   input Time intervalvar $ mean std nominalvar $ varlevel $;
datalines;
1       H1         20               0.001           .               .
1       H2          2               0.001           .               .
1       Cleak       0               0.0001          .               .
1       .           0.95             .              Fault           None
1       .           0.05             .              Fault           Leak
;

proc fcmp casoutlib = casuser.nonlinears.tank;

     /****************************************************/
     /* subroutine to get derivative of variable Cleak   */
     /* over different branches of nominal variable;     */
     /* std is the noise in the ODE model of Cleak       */
     /****************************************************/
     subroutine d_Cleak(Time, Cleak, Fault $, d_Cleak, std);
         outargs d_Cleak, std;
         if Fault = 'Leak' then do;
             d_Cleak = 1 / 120; * leak_rate;
             std = 0.0001;
         end;
         else do;
             d_Cleak = 0;
             std = 0.0001;
         end;
     endsub;


     /************************************************************/
     /* subroutine to get derivative of variable H1              */
     /* as a function of variables Time, Cleak, H1, and H2; 	 */
     /* std is the noise in the ODE model of H1                  */
     /************************************************************/
     subroutine d_H1(Time, Cleak, H1, H2, d_H1, std);
         outargs d_H1, std;
         A1 = 200;
         f1in = 1;
         C1out = 0.5;
         C12 = 1; 
         d_H1 = (1/A1)*f1in - (C12+Cleak+C1out)/A1 * H1
                 + (C12)/A1 * H2;
         std = 0.001;
     endsub;

     /**********************************************************/
     /* subroutine to get derivative of variable H2            */
     /* as a function of variables Time, H1, and H2;           */
     /* std is the noise in the ODE model of H2                */
     /**********************************************************/
     subroutine d_H2(Time, H1, H2, d_H2, std);
         outargs d_H2, std;
         A2 = 100;
         C2out = 1;
         C12 = 1; 
         d_H2 = C12/A2 * H1
                 - ((C12+C2out)/A2) * H2;
         std = 0.001;
     endsub;

     /**********************************************************/
     /* subroutine to get value of variable F1out_rd           */
     /* as a function of variable H1;                          */
     /* std is the noise in this function                      */
     /**********************************************************/
     subroutine F1out_rd(H1, mean, std);
         outargs mean, std;
         C1out = 0.5;
         mean = H1 * C1out;
         std = 0.0001;
     endsub;

     /**********************************************************/
     /* subroutine to get value of variable F2out_rd           */
     /* as a function of variable H2;                          */
     /* std is the noise in this function                      */
     /**********************************************************/
     subroutine F2out_rd(H2, mean, std);
         outargs mean, std;
         C2out = 1;
         mean = H2 * C2out;
         std = 0.0001;
     endsub;
quit;

proc fcmp setcascmplib="casuser.nonlinears" getcascmplib; run;

data casuser.tankData;
set d.tank_noleak;
run;

proc dynbnet data = casuser.tankData
           odeapprox = NONE
           outdetails = casuser.tankOutd;
     varroles data = casuser.variableRoles;
     varlevels data = casuser.variableLevels;
     links data = casuser.variableLinks; 
     initbeliefs data = casuser.initialBeliefs;
     output out = casuser.tankOut;
run;

