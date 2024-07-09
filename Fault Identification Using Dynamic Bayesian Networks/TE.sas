/*********************************************************************************************************
Using Dynamic Bayesian Network for Tennessee Eastman Process
This example demonstrates the use of a dynamic Bayesian network on Tennessee Eastman process data. 
The Tennessee Eastman (TE) process is a realistic model of a typical chemical industrial process. 
This process produces two products from four reactants and has five major unit operators: reactor, product 
condenser, vapor-liquid separator, recycle compressor, and product stripper. 
This process is widely used for studying process control and fault detection. 
MATLAB simulation code from Ricker (2002) was translated into PROC IML code and was then used to generate 
the TE process data that are used in the subsequent illustration of PROC DYNBNET. Data were generated for 
the normal operations of the process (that is, no faults) and for five fault conditions.

Copyright © 2024, SAS Institute Inc., Cary, NC, USA.  All Rights Reserved.
SPDX-License-Identifier: Apache-2.0

*********************************************************************************************************/

/*---NOTE: you need to set up your CAS session first. ---*
 *---Here it is assumed that the CAS libname is casuser.---*/
 
/*---put the correct location of the data folder here---*/

libname d '.\TE';

data casuser.variableRoles;
   length varname $20;
   input varname $ varrole $;
datalines;
Time                TIMEID
YY[1..50]           HIDDEN
Sensor[1..22]       OBSERVED
Fault[1..5]         HIDDEN
;

data casuser.variableLevels;
   length varname $20;
   length varlevel $20;
   input varname $ varlevel $;
datalines;
Fault[1..5]         Working
Fault[1..5]         Fail
;

data casuser.variableLinks;
   length parent $20 child $20;
   input  parent $ child $ stage;
datalines;
Time                YY[1..50]               1
YY[1..50]           YY[1..50]               2
Fault[1..5]         YY[1..50]               2
YY[41]              Sensor[1]               1
Fault[4]            Sensor[1]               1
YY[39]              Sensor[2]               1
YY[40]              Sensor[3]               1
YY[42]              Sensor[4]               1
Fault[5]            Sensor[4]               1
YY[10..18]          Sensor[5]               1
YY[28..36]          Sensor[5]               1
YY[43]              Sensor[5]               1
YY[1..9]            Sensor[6]               1
YY[28..36]          Sensor[6]               1
YY[1..9]            Sensor[7]               1
YY[4..9]            Sensor[8]               1
YY[4..9]            Sensor[9]               1
YY[10..18]          Sensor[10]              1
YY[44]              Sensor[10]              1
YY[13..18]          Sensor[11]              1
YY[13..18]          Sensor[12]              1
YY[10..18]          Sensor[13]              1
YY[13..18]          Sensor[14]              1
YY[45]              Sensor[14]              1
YY[19..27]          Sensor[15]              1
YY[28..36]          Sensor[16]              1
YY[19..27]          Sensor[17]              1
YY[46]              Sensor[17]              1
YY[19..27]          Sensor[18]              1
YY[19..27]          Sensor[19]              1
YY[47]              Sensor[19]              1
YY[10..18]          Sensor[20]              1
YY[28..36]          Sensor[20]              1
YY[37]              Sensor[21]              1
YY[38]              Sensor[22]              1
;

data initialBeliefs;
   length intervalvar $20 nominalvar $20 varlevel $20;
   input Time intervalvar $ mean nominalvar $ varlevel $;
datalines;
0.000277777777778 Fault[1..5]      0.95              Fault[1..5]      Working
0.000277777777778 Fault[1..5]      0.05              Fault[1..5]      Fail
0.000277777777778 yy[1]           10.40491389        .                .
0.000277777777778 yy[2]            4.363996017       .                .
0.000277777777778 yy[3]            7.570059737       .                .
0.000277777777778 yy[4]            0.4230042431      .                .
0.000277777777778 yy[5]           24.15513437        .                .
0.000277777777778 yy[6]            2.942597645       .                .
0.000277777777778 yy[7]          154.3770655         .                .
0.000277777777778 yy[8]          159.186596          .                .
0.000277777777778 yy[9]            2.808522723       .                .
0.000277777777778 yy[10]          63.75581199        .                .
0.000277777777778 yy[11]          26.74026066        .                .
0.000277777777778 yy[12]          46.38532432        .                .
0.000277777777778 yy[13]           0.2464521543      .                .
0.000277777777778 yy[14]          15.20484404        .                .
0.000277777777778 yy[15]           1.852266172       .                .
0.000277777777778 yy[16]          52.44639459        .                .
0.000277777777778 yy[17]          41.20394008        .                .
0.000277777777778 yy[18]           0.569931776       .                .
0.000277777777778 yy[19]           0.4306056376      .                .
0.000277777777778 yy[20]           0.0079906200783   .                .
0.000277777777778 yy[21]           0.9056036089      .                .
0.000277777777778 yy[22]           0.016054258216    .                .
0.000277777777778 yy[23]           0.7509759687      .                .
0.000277777777778 yy[24]           0.088582855955    .                .
0.000277777777778 yy[25]          48.27726193        .                .
0.000277777777778 yy[26]          39.38459028        .                .
0.000277777777778 yy[27]           0.3755297257      .                .
0.000277777777778 yy[28]         107.7562698         .                .
0.000277777777778 yy[29]          29.77250546        .                .
0.000277777777778 yy[30]          88.32481135        .                .
0.000277777777778 yy[31]          23.03929507        .                .
0.000277777777778 yy[32]          62.85848794        .                .
0.000277777777778 yy[33]           5.546318688       .                .
0.000277777777778 yy[34]          11.92244772        .                .
0.000277777777778 yy[35]           5.555448243       .                .
0.000277777777778 yy[36]           0.9218489762      .                .
0.000277777777778 yy[37]          94.59927549        .                .
0.000277777777778 yy[38]          77.29698353        .                .
0.000277777777778 yy[39]          63.05263039        .                .
0.000277777777778 yy[40]          53.97970677        .                .
0.000277777777778 yy[41]          24.64355755        .                .
0.000277777777778 yy[42]          61.30192144        .                .
0.000277777777778 yy[43]          22.21              .                .
0.000277777777778 yy[44]          40.06374673        .                .
0.000277777777778 yy[45]          38.1003437         .                .
0.000277777777778 yy[46]          46.53415582        .                .
0.000277777777778 yy[47]          47.44573456        .                .
0.000277777777778 yy[48]          41.10581288        .                .
0.000277777777778 yy[49]          18.11349055        .                .
0.000277777777778 yy[50]          50.                .                .
;
data casuser.initialBeliefs;
    set initialBeliefs;
    std = mean / 1000.0;
run;

proc fcmp casoutlib = casuser.nonlinears.TE;
  function getxmws1(xst[*], xmw[*]);
    ret_val = 0;
    do i__ = 1 to 8;
      ret_val = ret_val + xst[i__] * xmw[i__];
    end;
    return (ret_val);
  endsub;

  function getxmws2(xst[*], xmw[*]);
    ret_val = 0;
    do i__ = 1 to 8;
      ret_val = ret_val + xst[i__ + 1 + 7] * xmw[i__];
    end;
    return (ret_val);
  endsub;

  function getxmws9(xst[*], xmw[*]);
    ret_val = 0;
    do i__ = 1 to 8;
      ret_val = ret_val + xst[i__ + 1 + 63] * xmw[i__];
    end;
    return (ret_val);
  endsub;

  function getxmws10(xst[*], xmw[*]);
    ret_val = 0;
    do i__ = 1 to 8;
      ret_val = ret_val + xst[i__ + 1 + 71] * xmw[i__];
    end;
    return (ret_val);
  endsub;

  subroutine get_vv(YY[*], ucvv[*], utvv, xvv[*]);
    outargs ucvv, utvv, xvv;
    utvv = 0;
    do i__ = 1 to 8;
      ucvv[i__] = YY[27 + i__];
      utvv = utvv + ucvv[i__];
    end;
    do i__ = 1 to 8;
      xvv[i__] = ucvv[i__] / utvv;
    end;
  endsub;

  subroutine get_ucvs(YY[*], ucvs[*]);
    outargs ucvs;
    do i__ = 1 to 3;
      ucvs[i__] = YY[i__ + 9];
    end;
  endsub;

  subroutine get_ls(YY[*], ucls[*], utls, xls[*]);
    outargs ucls, utls, xls;
    utls = 0;
    do i__ = 1 to 3;
      ucls[i__] = 0;
      utls = utls + ucls[i__];
    end;
    do i__ = 4 to 8;
      ucls[i__] = YY[i__ + 9];
      utls = utls + ucls[i__];
    end;
    do i__ = 1 to 8;
      xls[i__] = ucls[i__] / utls;
    end;
  endsub;

  subroutine get_lc(YY[*], uclc[*], utlc, xlc[*]);
    outargs uclc, utlc, xlc;
    utlc = 0;
    do i__ = 1 to 8;
      uclc[i__] = YY[i__ + 18];
      utlc = utlc + uclc[i__];
    end;
    do i__ = 1 to 8;
      xlc[i__] = uclc[i__] / utlc;
    end;
  endsub;

  subroutine get_ps(ucvs[*], tks, vvs, tcs, xls[*], pps[*], pts, xvs[*]);
    outargs pps, pts, xvs;

    array avp[8];
    array bvp[8];
    array cvp[8];

    avp[1] = 0.;
    avp[2] = 0.;
    avp[3] = 0.;
    avp[4] = 15.92;
    avp[5] = 16.35;
    avp[6] = 16.35;
    avp[7] = 16.43;
    avp[8] = 17.21;
    bvp[1] = 0.;
    bvp[2] = 0.;
    bvp[3] = 0.;
    bvp[4] = -1444.;
    bvp[5] = -2114.;
    bvp[6] = -2114.;
    bvp[7] = -2748.;
    bvp[8] = -3318.;
    cvp[1] = 0.;
    cvp[2] = 0.;
    cvp[3] = 0.;
    cvp[4] = 259.;
    cvp[5] = 265.5;
    cvp[6] = 265.5;
    cvp[7] = 232.9;
    cvp[8] = 249.6;

    rg = 998.9;
    do i__ = 1 to 3;
      pps[i__] = ucvs[i__] * rg * tks / vvs;
    end;

    do i__ = 4 to 8;
      vpr = exp(avp[i__] + bvp[i__] / (tcs + cvp[i__]));
      pps[i__] = vpr * xls[i__];
    end;

    pts = 0;
    do i__ = 1 to 8;
      pts = pts + pps[i__];
    end;
    do i__ = 1 to 8;
      xvs[i__] = pps[i__] / pts;
    end;

  endsub;

  subroutine getxst65to72(xvs[*], xst[*]);

    outargs xst;
    do i__ = 1 to 8;
        xst[i__ + 63 + 1] = xvs[i__];
    end;

  endsub;

  subroutine getxst73to80(xvs[*], xst[*]);

    outargs xst;
    do i__ = 1 to 8;
        xst[i__ + 71 + 1] = xvs[i__];
    end;

  endsub;

  function getxmws9(xst[*], xmw[*]);

    xmws9 = 0;
    do i__ = 1 to 8;
      xmws9 = xmws9 + xst[i__ + 63 + 1] * xmw[i__];
    end;

    return (xmws9);

  endsub;

  function getftm9(ptv, pts, xmws[*], vpos[*]);

    cpflmx = 280275.;
    cpprmx = 1.3;

    pr = ptv / pts;
    if (pr < 1.) then
      pr = 1.;
    if (pr > cpprmx) then
      pr = cpprmx;
    flcoef = cpflmx / 1.197;
    d__1 = pr;
    flms = cpflmx + flcoef * (1. - d__1 * (d__1 * d__1));
    dlp = ptv - pts;
    if (dlp < 0.) then
      dlp = 0.;
    flms = flms - vpos[5] * 53.349 * sqrt(dlp);
    if (flms < .001) then
      flms = .001;
    ftm9 = flms / xmws[9];

    return (ftm9);

  endsub;

  subroutine getucvr1to3(YY[*], ucvr[*]);

    outargs ucvr;

    do i__ = 1 to 3;
      ucvr[i__] = YY[i__];
    end;

  endsub;

  subroutine get_lr(YY[*], uclr[*], utlr, xlr[*]);

    outargs uclr, utlr, xlr;

    do i__ = 1 to 3;
      uclr[i__] = 0.;
    end;

    do i__ = 4 to 8;
      uclr[i__] = YY[i__];
    end;

    utlr = 0;
    do i__ = 1 to 8;
      utlr = utlr + uclr[i__];
    end;

    do i__ = 1 to 8;
      xlr[i__] = uclr[i__] / utlr;
    end;

  endsub;

  subroutine get_pr(ucvr[*], tkr, vvr, ppr[*], tcr, xlr[*], ptr);

    outargs ppr, ptr;

    array avp[8];
    array bvp[8];
    array cvp[8];

    avp[1] = 0.;
    avp[2] = 0.;
    avp[3] = 0.;
    avp[4] = 15.92;
    avp[5] = 16.35;
    avp[6] = 16.35;
    avp[7] = 16.43;
    avp[8] = 17.21;
    bvp[1] = 0.;
    bvp[2] = 0.;
    bvp[3] = 0.;
    bvp[4] = -1444.;
    bvp[5] = -2114.;
    bvp[6] = -2114.;
    bvp[7] = -2748.;
    bvp[8] = -3318.;
    cvp[1] = 0.;
    cvp[2] = 0.;
    cvp[3] = 0.;
    cvp[4] = 259.;
    cvp[5] = 265.5;
    cvp[6] = 265.5;
    cvp[7] = 232.9;
    cvp[8] = 249.6;

    rg = 998.9;

    do i__ = 1 to 3;
      ppr[i__] = ucvr[i__] * rg * tkr / vvr;
    end;

    do i__ = 4 to 8;
      vpr = exp(avp[i__] + bvp[i__] / (tcr + cvp[i__]));
      ppr[i__] = vpr * xlr[i__];
    end;

    ptr = 0;
    do i__ = 1 to 8;
      ptr = ptr + ppr[i__];
    end;

  endsub;

  subroutine getxst41to48(xvv[*], xst[*]);

    outargs xst;

    do i__ = 1 to 8;
      xst[i__ + 1 + 39] = xvv[i__];
    end;

  endsub;

  function getxmws6(xst[*], xmw[*]);

    xmws6 = 0;
    do i__ = 1 to 8;
      xmws6 = xmws6 + xst[i__ + 39 + 1] * xmw[i__];
    end;

    return (xmws6);

  endsub;

  function getftm6(ptv, ptr, xmws[*]);

    dlp = ptv - ptr;
    if (dlp < 0.) then
    dlp = 0.;
    flms = sqrt(dlp) * 1937.6;
    ftm6 = flms / xmws[6];
    return (ftm6);

  endsub;

  function getftm10(vpos[*], pts, xmws[*]);

    dlp = pts - 760.0;
    if (dlp < 0.) then
      dlp = 0.;
    flms = vpos[6] * .151169 * sqrt(dlp);
    ftm10 = flms / xmws[10];
    return (ftm10);

  endsub;

  function getcpdh(tcs, ptv, pts, xmws[*]);

    cpflmx = 280275.;
    cpprmx = 1.3;

    pr = ptv / pts;
    if (pr < 1.) then
      pr = 1.;
    if (pr > cpprmx) then
      pr = cpprmx;
    flcoef = cpflmx / 1.197;

    d__1 = pr;
    flms = cpflmx + flcoef * (1. - d__1 * (d__1 * d__1));

    cpdh = flms *(tcs+273.15)* 1.8e-6 * 1.9872 *(ptv - pts)/(xmws[9] * pts);
    return (cpdh);

  endsub;

  function tesub1_(z__[*], t, ity, xmw[*]);

    array ah[8];
    array bh[8];
    array ch[8];
    array ag[8];
    array bg[8];
    array cg[8];
    array av[8];

    ah[1] = 1e-6;
    ah[2] = 1e-6;
    ah[3] = 1e-6;
    ah[4] = 9.6e-7;
    ah[5] = 5.73e-7;
    ah[6] = 6.52e-7;
    ah[7] = 5.15e-7;
    ah[8] = 4.71e-7;
    bh[1] = 0.;
    bh[2] = 0.;
    bh[3] = 0.;
    bh[4] = 8.7e-9;
    bh[5] = 2.41e-9;
    bh[6] = 2.18e-9;
    bh[7] = 5.65e-10;
    bh[8] = 8.7e-10;
    ch[1] = 0.;
    ch[2] = 0.;
    ch[3] = 0.;
    ch[4] = 4.81e-11;
    ch[5] = 1.82e-11;
    ch[6] = 1.94e-11;
    ch[7] = 3.82e-12;
    ch[8] = 2.62e-12;

    av[1] = 1e-6;
    av[2] = 1e-6;
    av[3] = 1e-6;
    av[4] = 8.67e-5;
    av[5] = 1.6e-4;
    av[6] = 1.6e-4;
    av[7] = 2.25e-4;
    av[8] = 2.09e-4;
    ag[1] = 3.411e-6;
    ag[2] = 3.799e-7;
    ag[3] = 2.491e-7;
    ag[4] = 3.567e-7;
    ag[5] = 3.463e-7;
    ag[6] = 3.93e-7;
    ag[7] = 1.7e-7;
    ag[8] = 1.5e-7;
    bg[1] = 7.18e-10;
    bg[2] = 1.08e-9;
    bg[3] = 1.36e-11;
    bg[4] = 8.51e-10;
    bg[5] = 8.96e-10;
    bg[6] = 1.02e-9;
    bg[7] = 0.;
    bg[8] = 0.;
    cg[1] = 6e-13;
    cg[2] = -3.98e-13;
    cg[3] = -3.93e-14;
    cg[4] = -3.12e-13;
    cg[5] = -3.27e-13;
    cg[6] = -3.12e-13;
    cg[7] = 0.;
    cg[8] = 0.;

    if (ity = 0) then do;
      h__ = 0.;
      do i__ = 1 to 8;
        d__1 = t;
        hi = t * (ah[i__] +
                  bh[i__] * t / 2. +
                  ch[i__] * (d__1 * d__1) / 3.);
        hi = hi * 1.8;
        h__ = h__ + z__[i__] * xmw[i__] * hi;
      end;
    end;
    else do;
      h__ = 0.;
      do i__ = 1 to 8;
        d__1 = t;
        hi = t * (ag[i__] +
                  bg[i__] * t / 2. +
                  cg[i__] * (d__1 * d__1) / 3.);
        hi = hi * 1.8;
        hi = hi + av[i__];
        h__ = h__ + z__[i__] * xmw[i__] * hi;
      end;
    end;

    if (ity = 2) then do;
      r__ = 3.57696e-6;
      h__ = h__ - r__ * (t + 273.15);
    end;

    return (h__);
  endsub;

  subroutine tesub2_(z__[*], t, h__, ity, xmw[*]);

    outargs t;

    tin = t;
    jumpout = 0;
    counter = 0;
    do until (jumpout > 0);
      htest = tesub1_(z__, t, ity, xmw);
      err = htest - h__;
      dh = tesub3_(z__, t, ity, xmw);
      dt = -err / dh;
      t = t + dt;
      counter = counter + 1;

      if (abs(dt) < 1e-12) then jumpout = 1;
      else if (counter = 100) then do;
         jumpout = 1;
         t = tin;
      end;
    end;

  endsub;

  function tesub3_(z__[*], t, ity, xmw[*]);

    array ah[8];
    array bh[8];
    array ch[8];
    array ag[8];
    array bg[8];
    array cg[8];

    ah[1] = 1e-6;
    ah[2] = 1e-6;
    ah[3] = 1e-6;
    ah[4] = 9.6e-7;
    ah[5] = 5.73e-7;
    ah[6] = 6.52e-7;
    ah[7] = 5.15e-7;
    ah[8] = 4.71e-7;
    bh[1] = 0.;
    bh[2] = 0.;
    bh[3] = 0.;
    bh[4] = 8.7e-9;
    bh[5] = 2.41e-9;
    bh[6] = 2.18e-9;
    bh[7] = 5.65e-10;
    bh[8] = 8.7e-10;
    ch[1] = 0.;
    ch[2] = 0.;
    ch[3] = 0.;
    ch[4] = 4.81e-11;
    ch[5] = 1.82e-11;
    ch[6] = 1.94e-11;
    ch[7] = 3.82e-12;
    ch[8] = 2.62e-12;

    ag[1] = 3.411e-6;
    ag[2] = 3.799e-7;
    ag[3] = 2.491e-7;
    ag[4] = 3.567e-7;
    ag[5] = 3.463e-7;
    ag[6] = 3.93e-7;
    ag[7] = 1.7e-7;
    ag[8] = 1.5e-7;
    bg[1] = 7.18e-10;
    bg[2] = 1.08e-9;
    bg[3] = 1.36e-11;
    bg[4] = 8.51e-10;
    bg[5] = 8.96e-10;
    bg[6] = 1.02e-9;
    bg[7] = 0.;
    bg[8] = 0.;
    cg[1] = 6e-13;
    cg[2] = -3.98e-13;
    cg[3] = -3.93e-14;
    cg[4] = -3.12e-13;
    cg[5] = -3.27e-13;
    cg[6] = -3.12e-13;
    cg[7] = 0.;
    cg[8] = 0.;

    if (ity = 0) then do;
      dh = 0.;
      do i__ = 1 to 8;
        d__1 = t;
        dhi = ah[i__] +
              bh[i__] * t +
              ch[i__] * (d__1 * d__1);
        dhi = dhi * 1.8;
        dh = dh + z__[i__] * xmw[i__] * dhi;
      end;
    end;
    else do;
      dh = 0.;
      do i__ = 1 to 8;
        d__1 = t;
        dhi = ag[i__] +
              bg[i__] * t +
              cg[i__] * (d__1 * d__1);
        dhi = dhi * 1.8;
        dh = dh + z__[i__] * xmw[i__] * dhi;
      end;
    end;

    if (ity = 2) then do;
      r__ = 3.57696e-6;
      dh = dh - r__;
    end;

    return (dh);
  endsub;

  function tesub4_(x[*], t, xmw[*]);

    array ad[8];
    array bd[8];
    array cd[8];

    ad[1] = 1.;
    ad[2] = 1.;
    ad[3] = 1.;
    ad[4] = 23.3;
    ad[5] = 33.9;
    ad[6] = 32.8;
    ad[7] = 49.9;
    ad[8] = 50.5;
    bd[1] = 0.;
    bd[2] = 0.;
    bd[3] = 0.;
    bd[4] = -.07;
    bd[5] = -.0957;
    bd[6] = -.0995;
    bd[7] = -.0191;
    bd[8] = -.0541;
    cd[1] = 0.;
    cd[2] = 0.;
    cd[3] = 0.;
    cd[4] = -2e-4;
    cd[5] = -1.52e-4;
    cd[6] = -2.33e-4;
    cd[7] = -4.25e-4;
    cd[8] = -1.5e-4;

    v = 0.;
    do i__ = 1 to 8;
      v = v + x[i__] * xmw[i__] /
           (ad[i__] + (bd[i__] + cd[i__] * t) * t);
    end;
    r__ = 1.0 / v;
    return (r__);
  endsub;

  subroutine tesub5_(index, s, sp,
        hspan, hzero, sspan, szero, spspan, idvflag,
        adist[*], bdist[*], cdist[*], ddist[*], tnext[*], tlast[*], randuni);
    outargs adist, bdist, cdist, ddist, tnext, randuni;

    i__    = -1;
    h__ = 1.0/3600.0;
    tmpval = 0;

    CALL tesub7_(i__, tmpval, randuni);
    s1     = sspan * tmpval * idvflag + szero;
    CALL tesub7_(i__, tmpval, randuni);
    s1p = spspan * tmpval * idvflag;

    adist[index] = s;
    bdist[index] = sp;
    d__1   = h__;
    cdist[index] = ((s1 - s) * 3. - h__ * (s1p + sp * 2.)) / (d__1 * d__1);
    d__1   = h__;
    ddist[index] = ((s - s1) * 2. + h__ * (s1p + sp)) / (d__1 * (d__1 * d__1));

    tnext[index] = tlast[index] + h__;

  endsub;

  subroutine tesub7_(i__, ret_val, randuni);
    outargs ret_val, randuni;

    c_b78 = 4294967296.;

    if (i__ >= 0) then do;
      d__1 = randuni;

      d__1 = d__1 * 9228907.;
      d__1 = mod(d__1, c_b78);
      randuni = d__1;

      ret_val = d__1 / 4294967296.;

    end;

    if (i__ < 0) then do;
      d__1 = randuni;

      d__1 = d__1 * 9228907.;
      d__1 = mod(d__1, c_b78);
      randuni = d__1;

      ret_val = d__1 * 2.0 / 4294967296. - 1.;
    end;

  endsub;

  function tesub8_(i__, adist[*], bdist[*], cdist[*], ddist[*]);
    h__ = 1/3600;
    ret_val = adist[i__] +
                h__ * (bdist[i__] +
                    h__ * (cdist[i__] +
                         h__ * ddist[i__]));
    return (ret_val);
  endsub;

  subroutine Sensor(Fault[*] $, YY[*], index, mean, sdev);
    outargs mean, sdev;

    array idv[29];
    array ppr[8];
    array pps[8];
    array uclr[8];
    array ucls[8];
    array uclc[8];
    array ucvr[8];
    array ucvs[8];
    array ucvv[8];
    array vpos[12];
    array vrng[12];
    array xlr[8];
    array xls[8];
    array xlc[8];
    array xmw[8];
    array xmw_t[8];
    array xmws[13];
    array xns[41];
    array xst[104];
    array xvs[8];
    array xvv[8];

    array adist[20];
    array bdist[20];
    array cdist[20];
    array ddist[20];

    xst[1] = 0.;
    xst[2] = 1e-4;
    xst[3] = 0.;
    xst[4] = .9999;
    xst[5] = 0.;
    xst[6] = 0.;
    xst[7] = 0.;
    xst[8] = 0.;
    xst[9] = 0.;
    xst[10] = 0.;
    xst[11] = 0.;
    xst[12] = 0.;
    xst[13] = .9999;
    xst[14] = 1e-4;
    xst[15] = 0.;
    xst[16] = 0.;

      rg = 998.9;
      vrng[1] = 400.;
      vrng[2] = 400.;
      vrng[3] = 100.;
      vrng[4] = 1500.;
      vrng[7] = 1500.;
      vrng[8] = 1e3;
      vrng[9] = .03;
      vrng[10] = 1e3;
      vrng[11] = 1200.;
      vtr = 1300;
      vts = 3500;
      vtv = 5e3;
      vtc = 156.5;
      xns[1] = .0012;
      xns[2] = 18.;
      xns[3] = 22.;
      xns[4] = .05;
      xns[5] = .2;
      xns[6] = .21;
      xns[7] = .3;
      xns[8] = .5;
      xns[9] = .01;
      xns[10] = .0017;
      xns[11] = .01;
      xns[12] = 1.;
      xns[13] = .3;
      xns[14] = .125;
      xns[15] = 1.;
      xns[16] = .3;
      xns[17] = .115;
      xns[18] = .01;
      xns[19] = 1.15;
      xns[20] = .2;
      xns[21] = .01;
      xns[22] = .01;
      xns[23] = .25;
      xns[24] = .1;
      xns[25] = .25;
      xns[26] = .1;
      xns[27] = .25;
      xns[28] = .025;
      xns[29] = .25;
      xns[30] = .1;
      xns[31] = .25;
      xns[32] = .1;
      xns[33] = .25;
      xns[34] = .025;
      xns[35] = .05;
      xns[36] = .05;
      xns[37] = .01;
      xns[38] = .01;
      xns[39] = .01;
      xns[40] = .5;
      xns[41] = .5;
      xmw[1] = 2.;
      xmw[2] = 25.4;
      xmw[3] = 28.;
      xmw[4] = 32.;
      xmw[5] = 46.;
      xmw[6] = 48.;
      xmw[7] = 62.;
      xmw[8] = 76.;

    do i__ = 1 to 8;
      xmw_t[i__] = xmw[i__];
    end;
    xmws[1] = getxmws1(xst, xmw_t);
    xmws[2] = getxmws2(xst, xmw_t);

    if index = 1 then do;
      idv[6] = 0.5;
      if (Fault[4] = 'Working') then
        idv[6] = 0;
      vpos[3] = YY[41];
      ftm3 = vpos[3] * (1 - idv[6]) * vrng[3] / 100;
      mean = ftm3 * .359 / 35.3145;
      sdev = xns[1];
    end;
    else if index = 2 then do;
      vpos[1] = YY[39];
      ftm1 = vpos[1] * vrng[1] / 100;
      mean = ftm1 * xmws[1] * 0.454;
      sdev = xns[2];
    end;
    else if index = 3 then do;
      vpos[2] = YY[40];
      ftm2 = vpos[2] * vrng[2] / 100;
      mean = ftm2 * xmws[2] * 0.454;
      sdev = xns[3];
    end;
    else if index = 4 then do;
      idv[7] = 1;
      if (Fault[5] = 'Working') then
        idv[7] = 0;
      vpos[4] = YY[42];
      ftm4 = vpos[4]  * (1. - idv[7] * .2) * vrng[4] / 100. + 1e-10;
      mean = ftm4 * .359 / 35.3145;
      sdev = xns[4];
    end;
    else if index = 5 then do;
      CALL get_vv(YY, ucvv, utvv, xvv);
      etv = YY[36];
      esv = etv / utvv;
      tcv = 0;
      CALL tesub2_(xvv, tcv, esv, 2, xmw_t);
      tkv = tcv + 273.15;
      ptv = utvv * rg * tkv / vtv;
      CALL get_ucvs(YY, ucvs);
      CALL get_ls(YY, ucls, utls, xls);
      ets = YY[18];
      ess = ets / utls;
      tcs = 0;
      CALL tesub2_(xls, tcs, ess, 0, xmw_t);
      dls = tesub4_(xls, tcs, xmw_t);
      vls = utls / dls;
      tks = tcs + 273.15;
      vvs = vts - vls;
      CALL get_ps(ucvs, tks, vvs, tcs, xls, pps, pts, xvs);
      vpos[5] = YY[43];
      CALL getxst65to72(xvs, xst);
      xmws[9] = getxmws9(xst, xmw_t);
      ftm9 = getftm9(ptv, pts, xmws, vpos);
      mean = ftm9 * .359 / 35.3145;
      sdev = xns[5];
    end;
    else if index = 6 then do;
      CALL get_vv(YY, ucvv, utvv, xvv);
      etv = YY[36];
      esv = etv / utvv;
      tcv = 0;
      CALL tesub2_(xvv, tcv, esv, 2, xmw_t);
      tkv = tcv + 273.15;
      ptv = utvv * rg * tkv / vtv;
      CALL getucvr1to3(YY, ucvr);
      CALL get_lr(YY, uclr, utlr, xlr);
      etr = YY[9];
      esr = etr / utlr;
      tcr = 0;
      CALL tesub2_(xlr, tcr, esr, 0, xmw_t);
      dlr = tesub4_(xlr, tcr, xmw_t);
      vlr = utlr / dlr;
      tkr = tcr + 273.15;
      vvr = vtr - vlr;
      CALL get_pr(ucvr, tkr, vvr, ppr, tcr, xlr, ptr);
      CALL getxst41to48(xvv, xst);
      xmws[6] = getxmws6(xst, xmw_t);
      ftm6 = getftm6(ptv, ptr, xmws);
      mean = ftm6 * .359 / 35.3145;
      sdev = xns[6];
    end;
    else if index = 7 then do;
      CALL getucvr1to3(YY, ucvr);
      CALL get_lr(YY, uclr, utlr, xlr);
      etr = YY[9];
      esr = etr / utlr;
      tcr = 0;
      CALL tesub2_(xlr, tcr, esr, 0, xmw_t);
      dlr = tesub4_(xlr, tcr, xmw_t);
      vlr = utlr / dlr;
      tkr = tcr + 273.15;
      vvr = vtr - vlr;
      CALL get_pr(ucvr, tkr, vvr, ppr, tcr, xlr, ptr);
      mean = (ptr - 760.) / 760. * 101.325;
      sdev = xns[7];
    end;
    else if index = 8 then do;
      CALL get_lr(YY, uclr, utlr, xlr);
      etr = YY[9];
      esr = etr / utlr;
      tcr = 0;
      CALL tesub2_(xlr, tcr, esr, 0, xmw_t);
      dlr = tesub4_(xlr, tcr, xmw_t);
      vlr = utlr / dlr;
      mean = (vlr - 84.6) / 666.7 * 100.;
      sdev = xns[8];
    end;
    else if index = 9 then do;
      CALL get_lr(YY, uclr, utlr, xlr);
      etr = YY[9];
      esr = etr / utlr;
      tcr = 0;
      CALL tesub2_(xlr, tcr, esr, 0, xmw_t);
      mean = tcr;
      sdev = xns[9];
    end;

    else if index = 10 then do;
      CALL get_ucvs(YY, ucvs);
      CALL get_ls(YY, ucls, utls, xls);
      ets = YY[18];
      ess = ets / utls;
      tcs = 0;
      CALL tesub2_(xls, tcs, ess, 0, xmw_t);
      dls = tesub4_(xls, tcs, xmw_t);
      vls = utls / dls;
      tks = tcs + 273.15;
      vvs = vts - vls;
      CALL get_ps(ucvs, tks, vvs, tcs, xls, pps, pts, xvs);
      CALL getxst73to80(xvs, xst);
      xmws[10] = getxmws10(xst, xmw_t);
      vpos[6] = YY[44];

      ftm10 = getftm10(vpos, pts, xmws);
      mean = ftm10 * 0.359 / 35.3145;
      sdev = xns[10];
    end;

    else if index = 11 then do;
      CALL get_ls(YY, ucls, utls, xls);
      ets = YY[18];
      ess = ets / utls;
      tcs = 0;
      CALL tesub2_(xls, tcs, ess, 0, xmw_t);
      mean = tcs;
      sdev = xns[11];
    end;

    else if index = 12 then do;
      CALL get_ls(YY, ucls, utls, xls);
      ets = YY[18];
      ess = ets / utls;
      tcs = 0;
      CALL tesub2_(xls, tcs, ess, 0, xmw_t);
      dls = tesub4_(xls, tcs, xmw_t);
      vls = utls / dls;
      mean = (vls - 27.5) / 290.0 * 100.0;
      sdev = xns[12];
    end;

    else if index = 13 then do;
      CALL get_ucvs(YY, ucvs);
      CALL get_ls(YY, ucls, utls, xls);
      ets = YY[18];
      ess = ets / utls;
      tcs = 0;
      CALL tesub2_(xls, tcs, ess, 0, xmw_t);
      dls = tesub4_(xls, tcs, xmw_t);
      vls = utls / dls;
      tks = tcs + 273.15;
      vvs = vts - vls;
      CALL get_ps(ucvs, tks, vvs, tcs, xls, pps, pts, xvs);
      mean = (pts - 760.0) / 760.0 * 101.325;
      sdev = xns[13];
    end;

    else if index = 14 then do;
      vpos[7] = YY[45];
      ftm11 = vpos[7] * vrng[7] / 100.0;
      CALL get_ls(YY, ucls, utls, xls);
      ets = YY[18];
      ess = ets / utls;
      tcs = 0;
      CALL tesub2_(xls, tcs, ess, 0, xmw_t);
      dls = tesub4_(xls, tcs, xmw_t);
      mean = ftm11 / dls / 35.3145;
      sdev = xns[14];
    end;

    else if index = 15 then do;
      CALL get_lc(YY, uclc, utlc, xlc);
      etc = YY[27];
      esc = etc / utlc;
      tcc = 0;
      CALL tesub2_(xlc, tcc, esc, 0, xmw_t);
      dlc = tesub4_(xlc, tcc, xmw_t);
      vlc = utlc / dlc;
      mean = (vlc - 78.25) / vtc * 100.0;
      sdev = xns[15];
    end;

    else if index = 16 then do;
      CALL get_vv(YY, ucvv, utvv, xvv);
      etv = YY[36];
      esv = etv / utvv;
      tcv = 0;
      CALL tesub2_(xvv, tcv, esv, 2, xmw_t);
      tkv = tcv + 273.15;
      ptv = utvv * rg * tkv / vtv;
      mean = (ptv - 760.0) / 760.0 * 101.325;
      sdev = xns[16];
    end;

    else if index = 17 then do;
      vpos[8] = YY[46];
      ftm13 = vpos[8] * vrng[8] / 100;
      CALL get_lc(YY, uclc, utlc, xlc);
      etc = YY[27];
      esc = etc / utlc;
      tcc = 0;
      CALL tesub2_(xlc, tcc, esc, 0, xmw_t);
      dlc = tesub4_(xlc, tcc, xmw_t);
      mean = ftm13 / dlc / 35.3145;
      sdev = xns[17];
    end;

    else if index = 18 then do;
      CALL get_lc(YY, uclc, utlc, xlc);
      etc = YY[27];
      esc = etc / utlc;
      tcc = 0;
      CALL tesub2_(xlc, tcc, esc, 0, xmw_t);
      mean = tcc;
      sdev = xns[18];
    end;

    else if index = 19 then do;
      vpos[9] = YY[47];
      do i__ = 1 to 20;
        adist[i__] = 0;
        bdist[i__] = 0;
        cdist[i__] = 0;
        ddist[i__] = 0;
      end;
      tmpval = tesub8_(9, adist, bdist, cdist, ddist) + 1.0;
      uac = vpos[9] * vrng[9] * tmpval / 100.0;
      CALL get_lc(YY, uclc, utlc, xlc);
      etc = YY[27];
      esc = etc / utlc;
      tcc = 0;
      CALL tesub2_(xlc, tcc, esc, 0, xmw_t);
      quc = 0.;
      if (tcc < 100.) then
        quc = uac * (100. - tcc);
      mean = quc * 1040 * 0.454;
      sdev = xns[19];
    end;

    else if index = 20 then do;
      CALL get_vv(YY, ucvv, utvv, xvv);
      etv = YY[36];
      esv = etv / utvv;
      tcv = 0;
      CALL tesub2_(xvv, tcv, esv, 2, xmw_t);
      tkv = tcv + 273.15;
      ptv = utvv * rg * tkv / vtv;

      CALL get_ucvs(YY, ucvs);
      CALL get_ls(YY, ucls, utls, xls);
      ets = YY[18];
      ess = ets / utls;
      tcs = 0;
      CALL tesub2_(xls, tcs, ess, 0, xmw_t);
      dls = tesub4_(xls, tcs, xmw_t);
      vls = utls / dls;
      tks = tcs + 273.15;
      vvs = vts - vls;
      CALL get_ps(ucvs, tks, vvs, tcs, xls, pps, pts, xvs);

      CALL getxst65to72(xvs, xst);

      xmws[9] = getxmws9(xst, xmw_t);

      cpdh = getcpdh(tcs, ptv, pts, xmws);

      mean = cpdh * 293.07;
      sdev = xns[20];
    end;

    else if index = 21 then do;
      mean = YY[37];
      sdev = xns[21];
    end;

    else if index = 22 then do;
      mean = YY[38];
      sdev = xns[22];
    end;

  endsub;

  subroutine d_YY(time, YY[*], Fault[*] $, d_YY[*], sdev[*]);
    outargs d_YY, sdev;

    array yp[50];
    array uclr[8];
    array ucvr[8];
    array xlr[8];
    array xvr[8];
    array ppr[8];
    array crxr[8];
    array rr[4];
    array ucls[8];
    array ucvs[8];
    array xls[8];
    array xvs[8];
    array pps[8];
    array uclc[8];
    array xlc[8];
    array ucvv[8];
    array xvv[8];
    array vcv[12];
    array vrng[12];
    array vtau[12];
    array ftm[13];
    array fcm[104];
    array xst[104];
    array xmws[13];
    array hst[13];
    array tst[13];
    array sfr[8,1];
    array htr[3];
    array xdel[41];
    array xdeladd[24];
    array xns[41];
    array xnsadd[34];
    array vst[12];
    array ivst[12];
    array adist[20];
    array bdist[20];
    array cdist[20];
    array ddist[20];
    array tlast[20];
    STATIC tlast;
    array tnext[20];
    STATIC tnext;
    array hspan[20];
    array hzero[20];
    array sspan[20];
    array szero[20];
    array spspan[20];
    array idvwlk[20];
    array xmeas[41];
    array xmeasadd[32];
    array xmeasdist[21];
    array xmeasmonitor[62];
    array xmeascomp[96];
    array xmv[12];
    array idv[29];
    array avp[8];
    array bvp[8];
    array cvp[8];
    array ah[8];
    array bh[8];
    array ch[8];
    array ag[8];
    array bg[8];
    array cg[8];
    array av[8];
    array ad[8];
    array bd[8];
    array cd[8];
    array xmw[8];
    array vpos[12];

    do i__ = 1 to 20;
      adist[i__] = 0;
      bdist[i__] = 0;
      cdist[i__] = 0;
      ddist[i__] = 0;
    end;

    tstart = 1.0/3600;

    STATIC tlastcomp;
    if (MISSING(tlastcomp))
      then tlastcomp = -1;

    randuni = 1431655765.;

    c__50 = 50;
    c__12 = 12;
    c__21 = 21;
    c__153 = 153;
    c__586 = 586;
    c__139 = 139;
    c__6 = 6;
    c__1 = 1;
    c__0 = 0;
    c__41 = 41;
    c__2 = 2;
    c__3 = 3;
    c__4 = 4;
    c__5 = 5;
    c__7 = 7;
    c__8 = 8;
    c_b73 = 1.1544;
    c_b74 = .3735;
    c__9 = 9;
    c__10 = 10;
    c__11 = 11;
    c_b123 = 4294967296.;
    c__13 = 13;
    c__14 = 14;
    c__15 = 15;
    c__16 = 16;
    c__17 = 17;
    c__18 = 18;
    c__19 = 19;
    c__20 = 20;

    xmw[1] = 2.;
    xmw[2] = 25.4;
    xmw[3] = 28.;
    xmw[4] = 32.;
    xmw[5] = 46.;
    xmw[6] = 48.;
    xmw[7] = 62.;
    xmw[8] = 76.;

    avp[1] = 0.;
    avp[2] = 0.;
    avp[3] = 0.;
    avp[4] = 15.92;
    avp[5] = 16.35;
    avp[6] = 16.35;
    avp[7] = 16.43;
    avp[8] = 17.21;
    bvp[1] = 0.;
    bvp[2] = 0.;
    bvp[3] = 0.;
    bvp[4] = -1444.;
    bvp[5] = -2114.;
    bvp[6] = -2114.;
    bvp[7] = -2748.;
    bvp[8] = -3318.;
    cvp[1] = 0.;
    cvp[2] = 0.;
    cvp[3] = 0.;
    cvp[4] = 259.;
    cvp[5] = 265.5;
    cvp[6] = 265.5;
    cvp[7] = 232.9;
    cvp[8] = 249.6;

    ad[1] = 1.;
    ad[2] = 1.;
    ad[3] = 1.;
    ad[4] = 23.3;
    ad[5] = 33.9;
    ad[6] = 32.8;
    ad[7] = 49.9;
    ad[8] = 50.5;
    bd[1] = 0.;
    bd[2] = 0.;
    bd[3] = 0.;
    bd[4] = -.07;
    bd[5] = -.0957;
    bd[6] = -.0995;
    bd[7] = -.0191;
    bd[8] = -.0541;
    cd[1] = 0.;
    cd[2] = 0.;
    cd[3] = 0.;
    cd[4] = -2e-4;
    cd[5] = -1.52e-4;
    cd[6] = -2.33e-4;
    cd[7] = -4.25e-4;
    cd[8] = -1.5e-4;

    ah[1] = 1e-6;
    ah[2] = 1e-6;
    ah[3] = 1e-6;
    ah[4] = 9.6e-7;
    ah[5] = 5.73e-7;
    ah[6] = 6.52e-7;
    ah[7] = 5.15e-7;
    ah[8] = 4.71e-7;
    bh[1] = 0.;
    bh[2] = 0.;
    bh[3] = 0.;
    bh[4] = 8.7e-9;
    bh[5] = 2.41e-9;
    bh[6] = 2.18e-9;
    bh[7] = 5.65e-10;
    bh[8] = 8.7e-10;
    ch[1] = 0.;
    ch[2] = 0.;
    ch[3] = 0.;
    ch[4] = 4.81e-11;
    ch[5] = 1.82e-11;
    ch[6] = 1.94e-11;
    ch[7] = 3.82e-12;
    ch[8] = 2.62e-12;

    av[1] = 1e-6;
    av[2] = 1e-6;
    av[3] = 1e-6;
    av[4] = 8.67e-5;
    av[5] = 1.6e-4;
    av[6] = 1.6e-4;
    av[7] = 2.25e-4;
    av[8] = 2.09e-4;
    ag[1] = 3.411e-6;
    ag[2] = 3.799e-7;
    ag[3] = 2.491e-7;
    ag[4] = 3.567e-7;
    ag[5] = 3.463e-7;
    ag[6] = 3.93e-7;
    ag[7] = 1.7e-7;
    ag[8] = 1.5e-7;
    bg[1] = 7.18e-10;
    bg[2] = 1.08e-9;
    bg[3] = 1.36e-11;
    bg[4] = 8.51e-10;
    bg[5] = 8.96e-10;
    bg[6] = 1.02e-9;
    bg[7] = 0.;
    bg[8] = 0.;
    cg[1] = 6e-13;
    cg[2] = -3.98e-13;
    cg[3] = -3.93e-14;
    cg[4] = -3.12e-13;
    cg[5] = -3.27e-13;
    cg[6] = -3.12e-13;
    cg[7] = 0.;
    cg[8] = 0.;

    do i = 1 to 12;
      xmv[i] = YY[i + 38];
      vcv[i] = xmv[i];
      vst[i] = 2.;

      ivst[i] = 0.;
    end;

    rg = 998.9;

    vrng[1] = 400.;
    vrng[2] = 400.;
    vrng[3] = 100.;
    vrng[4] = 1500.;
    vrng[7] = 1500.;
    vrng[8] = 1e3;
    vrng[9] = .03;
    vrng[10] = 1e3;
    vrng[11] = 1200.;

    vtr = 1300.;
    vts = 3500.;
    vtc = 156.5;
    vtv = 5e3;

    htr[1] = .06899381054;
    htr[2] = .05;
    hwr = 7060.;
    hws = 11138.;
    sfr[1] = .995;
    sfr[2] = .991;
    sfr[3] = .99;
    sfr[4] = .916;
    sfr[5] = .936;
    sfr[6] = .938;
    sfr[7] = .058;
    sfr[8] = .0301;

    xst[1] = 0.;
    xst[2] = 1e-4;
    xst[3] = 0.;
    xst[4] = .9999;
    xst[5] = 0.;
    xst[6] = 0.;
    xst[7] = 0.;
    xst[8] = 0.;

    xst[9] = 0.;
    xst[10] = 0.;
    xst[11] = 0.;
    xst[12] = 0.;
    xst[13] = .9999;
    xst[14] = 1e-4;
    xst[15] = 0.;
    xst[16] = 0.;
    tst[2] = 45.;

    xst[17] = .9999;
    xst[18] = 1e-4;
    xst[19] = 0.;
    xst[20] = 0.;
    xst[21] = 0.;
    xst[22] = 0.;
    xst[23] = 0.;
    xst[24] = 0.;
    tst[3] = 45.;

    xst[25] = .485;
    xst[26] = .005;
    xst[27] = .51;
    xst[28] = 0.;
    xst[29] = 0.;
    xst[30] = 0.;
    xst[31] = 0.;
    xst[32] = 0.;

    cpflmx = 280275.;
    cpprmx = 1.3;

    vtau[1] = 8.;
    vtau[2] = 8.;
    vtau[3] = 6.;
    vtau[4] = 9.;
    vtau[5] = 7.;
    vtau[6] = 5.;
    vtau[7] = 5.;
    vtau[8] = 5.;
    vtau[9] = 120.;
    vtau[10] = 5.;
    vtau[11] = 5.;
    vtau[12] = 5.;

    do i = 1 to 12;
      vtau[i] = vtau[i] / 3600.;
    end;

    g = 1431655765.;
    measnoise = 1431655765.;
    procdist = 1431655765.;

    xns[1] = .0012;
    xns[2] = 18.;
    xns[3] = 22.;
    xns[4] = .05;
    xns[5] = .2;
    xns[6] = .21;
    xns[7] = .3;
    xns[8] = .5;
    xns[9] = .01;
    xns[10] = .0017;
    xns[11] = .01;
    xns[12] = 1.;
    xns[13] = .3;
    xns[14] = .125;
    xns[15] = 1.;
    xns[16] = .3;
    xns[17] = .115;
    xns[18] = .01;
    xns[19] = 1.15;
    xns[20] = .2;
    xns[21] = .01;
    xns[22] = .01;
    xns[23] = .25;
    xns[24] = .1;
    xns[25] = .25;
    xns[26] = .1;
    xns[27] = .25;
    xns[28] = .025;
    xns[29] = .25;
    xns[30] = .1;
    xns[31] = .25;
    xns[32] = .1;
    xns[33] = .25;
    xns[34] = .025;
    xns[35] = .05;
    xns[36] = .05;
    xns[37] = .01;
    xns[38] = .01;
    xns[39] = .01;
    xns[40] = .5;
    xns[41] = .5;

    xnsadd[1] = .01;
    xnsadd[2] = .01;
    xnsadd[3] = .01;
    xnsadd[4] = .01;
    xnsadd[5] = .01;
    xnsadd[6] = .125;
    xnsadd[7] = .01;
    xnsadd[8] = .125;
    xnsadd[9] = .01;
    xnsadd[10] = .01;
    xnsadd[11] = .25;
    xnsadd[12] = .1;
    xnsadd[13] = .25;
    xnsadd[14] = .1;
    xnsadd[15] = .25;
    xnsadd[16] = .025;
    xnsadd[17] = .25;
    xnsadd[18] = .1;
    xnsadd[19] = .25;
    xnsadd[20] = .1;
    xnsadd[21] = .25;
    xnsadd[22] = .025;
    xnsadd[23] = .25;
    xnsadd[24] = .1;
    xnsadd[25] = .25;
    xnsadd[26] = .1;
    xnsadd[27] = .25;
    xnsadd[28] = .025;
    xnsadd[29] = .25;
    xnsadd[30] = .1;
    xnsadd[31] = .25;
    xnsadd[32] = .1;
    xnsadd[33] = .25;
    xnsadd[34] = .025;

    hspan[1] = .2;
    hzero[1] = .5;
    sspan[1] = .03;
    szero[1] = .485;
    spspan[1] = 0.;

    hspan[2] = .7;
    hzero[2] = 1.;
    sspan[2] = .003;
    szero[2] = .005;
    spspan[2] = 0.;

    hspan[3] = .25;
    hzero[3] = .5;
    sspan[3] = 10.;
    szero[3] = 45.;
    spspan[3] = 0.;

    hspan[4] = .7;
    hzero[4] = 1.;
    sspan[4] = 10.;
    szero[4] = 45.;
    spspan[4] = 0.;

    hspan[5] = .15;
    hzero[5] = .25;
    sspan[5] = 10.;
    szero[5] = 35.;
    spspan[5] = 0.;

    hspan[6] = .15;
    hzero[6] = .25;
    sspan[6] = 10.;
    szero[6] = 40.;
    spspan[6] = 0.;

    hspan[7] = 1.;
    hzero[7] = 2.;
    sspan[7] = .25;
    szero[7] = 1.;
    spspan[7] = 0.;

    hspan[8] = 1.;
    hzero[8] = 2.;
    sspan[8] = .25;
    szero[8] = 1.;
    spspan[8] = 0.;

    hspan[9] = .4;
    hzero[9] = .5;
    sspan[9] = .25;
    szero[9] = 0.;
    spspan[9] = 0.;

    hspan[10] = 1.5;
    hzero[10] = 2.;
    sspan[10] = 0.;
    szero[10] = 0.;
    spspan[10] = 0.;

    hspan[11] = 2.;
    hzero[11] = 3.;
    sspan[11] = 0.;
    szero[11] = 0.;
    spspan[11] = 0.;

    hspan[12] = 1.5;
    hzero[12] = 2.;
    sspan[12] = 0.;
    szero[12] = 0.;
    spspan[12] = 0.;

    hspan[13] = .15;
    hzero[13] = .25;
    sspan[13] = 10.;
    szero[13] = 45.;
    spspan[13] = 0.;

    hspan[14] = .25;
    hzero[14] = .5;
    sspan[14] = 10.;
    szero[14] = 45.;
    spspan[14] = 0.;

    hspan[15] = .15;
    hzero[15] = .25;
    sspan[15] = 5.;
    szero[15] = 100.;
    spspan[15] = 0.;

    hspan[16] = .25;
    hzero[16] = .5;
    sspan[16] = 20.;
    szero[16] = 400.;
    spspan[16] = 0.;

    hspan[17] = .25;
    hzero[17] = .5;
    sspan[17] = 20.;
    szero[17] = 400.;
    spspan[17] = 0.;

    hspan[18] = .7;
    hzero[18] = 1.;
    sspan[18] = 75.;
    szero[18] = 1500.;
    spspan[18] = 0.;

    hspan[19] = .1;
    hzero[19] = .2;
    sspan[19] = 50.;
    szero[19] = 1e3;
    spspan[19] = 0.;

    hspan[20] = .1;
    hzero[20] = .2;
    sspan[20] = 60.;
    szero[20] = 1200.;
    spspan[20] = 0.;

    tcr = 0;
    tcs = 0;
    tcc = 0;
    tcv = 0;

    array fin[8];
    array xcmp[41];
    array xcmpadd[24];

    array distindex[17];

    do i = 1 to 28;
      idv[i] = 0.;
    end;

    tcwr = 35;
    if (Fault[1] = 'Fail') then tcwr = 40;
    tcws = 40;
    if (Fault[2] = 'Fail') then tcws = 45;
    tst[1] = 45;
    if (Fault[3] = 'Fail') then tst[1] = 50;
    if (Fault[4] = 'Fail') then idv[6] = 0.5;
    if (Fault[5] = 'Fail') then idv[7] = 1;
    tst[4] = 45;
    r1forig = 1;
    r2forig = 1;
    xst[25] = 0.485;
    xst[26] = 0.005;
    xst[27] = 1.0 - xst[25] - xst[26];

      do i__ = 1 to 28;
        if (idv[i__] < 0) then idv[i__] = 0;
        if (idv[i__] > 1) then idv[i__] = 1;
      end;

      idvwlk[1]  = idv[8];
      idvwlk[2]  = idv[8];
      idvwlk[3]  = idv[9];
      idvwlk[4]  = idv[10];
      idvwlk[5]  = idv[11];
      idvwlk[6]  = idv[12];
      idvwlk[7]  = idv[13];
      idvwlk[8]  = idv[13];
      idvwlk[9]  = idv[16];
      idvwlk[10] = idv[17];
      idvwlk[11] = idv[18];
      idvwlk[12] = idv[20];
      idvwlk[13] = idv[21];
      idvwlk[14] = idv[22];
      idvwlk[15] = idv[23];
      idvwlk[16] = idv[24];
      idvwlk[17] = idv[25];
      idvwlk[18] = idv[26];
      idvwlk[19] = idv[27];
      idvwlk[20] = idv[28];

        do i__ = 1 to 20;
          adist[i__] = szero[i__];
          bdist[i__] = 0.;
          cdist[i__] = 0.;
          ddist[i__] = 0.;
          tlast[i__] = 0.;
          tnext[i__] = time + 1.0/3600.0;
        end;

      distnum = 0;
      i__ = 1;
      do until (i__ > 20);
        if (time >= tnext[i__]) then do;
          distnum = distnum + 1;
          distindex[distnum] = i__;
        end;

        if(i__ = 9) then
            i__ = i__ + 3;
        i__ = i__ + 1;
      end;
      
      do i__ = 2 to distnum;
        distindch = distindex[i__];
        j__ = i__;
        ksave = 0;
        do k__ = j__ to 2 by -1;
          if (tnext[distindex[k__ - 1]] > tnext[distindch]) then do;
            distindex[k__] = distindex[k__ - 1];
            ksave = k__;
          end;
        end;
        if (ksave > 0) then j__ = ksave - 1;
        distindex[j__] = distindch;
      end;

      distnum = 0;
      do i__ = 10 to 12;
        if (time >= tnext[i__]) then do;
          distnum = distnum + 1;
          distindex[distnum] = i__;
        end;
      end;

      do i__ = 2 to distnum;
        distindch = distindex[i__];
        j__ = i__;
        ksave = 0;
        do k__ = j__ to 2 by -1;
          if (tnext[distindex[k__ - 1]] > tnext[distindch]) then do;
            distindex[k__] = distindex[k__ - 1];
            ksave = k__;
          end;
        end;
        if (ksave > 0) then j__ = ksave - 1;
        distindex[j__] = distindch;
      end;

      do i__ = 1 to distnum;
        hwlk = tnext[distindex[i__]] - tlast[distindex[i__]];

        swlk = adist[distindex[i__]] +
               hwlk * (bdist[distindex[i__]] +
               hwlk * (cdist[distindex[i__]] +
               hwlk * ddist[distindex[i__]]));

        spwlk = bdist[distindex[i__]] +
                hwlk * (cdist[distindex[i__]] * 2. +
                hwlk * 3. * ddist[distindex[i__]]);

        tlast[distindex[i__]] = tnext[distindex[i__]];
        if (swlk > .1) then do;
          adist[distindex[i__]] = swlk;
          bdist[distindex[i__]] = spwlk;
          cdist[distindex[i__]] = -(swlk * 3. + spwlk * .2) / .01;
          ddist[distindex[i__]] = (swlk * 2. + spwlk * .1) / .001;
          tnext[distindex[i__]] = tlast[distindex[i__]] + 1.0/3600.0;
        end;
        else do;
          aux = -1;
          hwlk = 1.0/3600.0;
          adist[distindex[i__]] = swlk;
          bdist[distindex[i__]] = spwlk;

          /* Computing 2nd power */
          d__1 = hwlk;
          cdist[distindex[i__]] = (idvwlk[distindex[i__]]
                                    - 2*spwlk*d__1) / (d__1 * d__1);
          ddist[distindex[i__]] = spwlk / (d__1 * d__1);
          tnext[distindex[i__]] = tlast[distindex[i__]] + hwlk;
        end;
      end;

        do i__ = 1 to 20;
          adist[i__] = szero[i__];
          bdist[i__] = 0.;
          cdist[i__] = 0.;
          ddist[i__] = 0.;
          tlast[i__] = 0.;
          tnext[i__] = 1.0/3600.0;
        end;
        
      r1f = r1forig;
      r2f = r2forig;

      tst[3]   = tesub8_(c__13, adist, bdist, cdist, ddist);
      tst[2]   = tesub8_(c__14, adist, bdist, cdist, ddist);
      vrng[3]  = tesub8_(c__15, adist, bdist, cdist, ddist);
      vrng[1]  = tesub8_(c__16, adist, bdist, cdist, ddist);
      vrng[2]  = tesub8_(c__17, adist, bdist, cdist, ddist);
      vrng[4]  = tesub8_(c__18, adist, bdist, cdist, ddist);
      vrng[10]  = tesub8_(c__19, adist, bdist, cdist, ddist);
      vrng[11] = tesub8_(c__20, adist, bdist, cdist, ddist);

      xmeasdist[1]  = xst[25]*100;
      xmeasdist[2]  = xst[26]*100;
      xmeasdist[3]  = xst[27]*100;
      xmeasdist[4]  = tst[1];
      xmeasdist[5]  = tst[4];
      xmeasdist[6]  = tcwr;
      xmeasdist[7]  = tcws;
      xmeasdist[8]  = r1f;
      xmeasdist[9]  = r2f;
      xmeasdist[10]  = tesub8_(c__9, adist, bdist, cdist, ddist);
      xmeasdist[11] = tesub8_(c__10, adist, bdist, cdist, ddist);
      xmeasdist[12] = tesub8_(c__11, adist, bdist, cdist, ddist);
      xmeasdist[13] = tesub8_(c__12, adist, bdist, cdist, ddist);
      xmeasdist[14] = tst[3];
      xmeasdist[15] = tst[2];
      xmeasdist[16] = vrng[3]*0.454;
      xmeasdist[17] = vrng[1]*0.454;
      xmeasdist[18] = vrng[2]*0.454;
      xmeasdist[19] = vrng[4]*0.454;
      xmeasdist[20] = vrng[10]*0.003785411784 * 60.;
      xmeasdist[21] = vrng[11]*0.003785411784 * 60.;

      do i__ = 1 to 3;
        ucvr[i__] = YY[i__];
        ucvs[i__] = YY[i__ + 9];
        uclr[i__] = 0.;
        ucls[i__] = 0.;
      end;

      do i__ = 4 to 8;
        uclr[i__] = YY[i__];
        ucls[i__] = YY[i__ + 9];
      end;


      do i__ = 1 to 8;
        uclc[i__] = YY[i__ + 18];
        ucvv[i__] = YY[i__ + 27];
      end;

      etr = YY[9];
      ets = YY[18];
      etc = YY[27];
      etv = YY[36];
      twr = YY[37];
      tws = YY[38];
      do i__ = 1 to 12;
        vpos[i__] = YY[i__ + 38];
      end;

      utlr = 0.;
      utls = 0.;
      utlc = 0.;
      utvv = 0.;
      do i__ = 1 to 8;
        utlr = utlr + uclr[i__];
        utls = utls + ucls[i__];
        utlc = utlc + uclc[i__];
        utvv = utvv + ucvv[i__];
      end;

      do i__ = 1 to 8;
        xlr[i__] = uclr[i__] / utlr;
        xls[i__] = ucls[i__] / utls;
        xlc[i__] = uclc[i__] / utlc;
        xvv[i__] = ucvv[i__] / utvv;
      end;

      esr = etr / utlr;
      ess = ets / utls;
      esc = etc / utlc;
      esv = etv / utvv;

      tcr = 0;
      CALL tesub2_(xlr, tcr, esr, c__0, xmw);
      tkr = tcr + 273.15;

      tcs = 0;
      CALL tesub2_(xls, tcs, ess, c__0, xmw);
      tks = tcs + 273.15;

      tcc = 0;
      CALL tesub2_(xlc, tcc, esc, c__0, xmw);

      tcv = 0;
      CALL tesub2_(xvv, tcv, esv, c__2, xmw);
      tkv = tcv + 273.15;

      dlr = tesub4_(xlr, tcr, xmw);
      dls = tesub4_(xls, tcs, xmw);
      dlc = tesub4_(xlc, tcc, xmw);
      
      vlr = utlr / dlr;
      vls = utls / dls;
      vlc = utlc / dlc;
      vvr = vtr - vlr;
      vvs = vts - vls;

      ptr = 0.;
      pts = 0.;

      rg = 998.9;
      do i__ = 1 to 3;
        ppr[i__] = ucvr[i__] * rg * tkr / vvr;
        ptr = ptr + ppr[i__];

        pps[i__] = ucvs[i__] * rg * tks / vvs;
        pts = pts + pps[i__];
      end;

      do i__ = 4 to 8;
        vpr = exp(avp[i__] + bvp[i__] / (tcr + cvp[i__]));
        ppr[i__] = vpr * xlr[i__];
        ptr = ptr + ppr[i__];

        vpr = exp(avp[i__] + bvp[i__] / (tcs + cvp[i__]));
        pps[i__] = vpr * xls[i__];
        pts = pts + pps[i__];
      end;

      ptv = utvv * rg * tkv / vtv;

      do i__ = 1 to 8;
        xvr[i__] = ppr[i__] / ptr;
        xvs[i__] = pps[i__] / pts;
      end;

      utvr = ptr * vvr / rg / tkr;
      utvs = pts * vvs / rg / tks;

      do i__ = 4 to 8;
        ucvr[i__] = utvr * xvr[i__];
        ucvs[i__] = utvs * xvs[i__];
      end;

      rr[1] = exp(31.5859536 - 20130.85052843482 / tkr) * r1f;
      rr[2] = exp(3.00094014 - 10065.42526421741 / tkr) * r2f;
      rr[3] = exp(53.4060443 - 30196.27579265224 / tkr);
      rr[4] = rr[2] * 0.767488334;

      if (ppr[1] > 0. & ppr[3] > 0.) then do;
        r1f = ppr[1] ** c_b73;
        r2f = ppr3 ** c_b74;

        rr[1] = rr[1] * r1f * r2f * ppr[4];
        rr[2] = rr[2] * r1f * r2f * ppr[5];
      end;
      else do;
        rr[1] = 0.;
        rr[2] = 0.;
      end;
      rr[3] = rr[3] * ppr[1] * ppr[5];
      rr[4] = rr[4] * ppr[1] * ppr[4];

      do i__ = 1 to 4;
       rr[i__] = rr[i__] * vvr;
      end;

      crxr[1] = -rr[1] - rr[2] - rr[3];
      crxr[3] = -rr[1] - rr[2];
      crxr[4] = -rr[1] - rr[4] * 1.5;
      crxr[5] = -rr[2] - rr[3];
      crxr[6] =  rr[3] + rr[4];
      crxr[7] =  rr[1];
      crxr[8] =  rr[2];
      rh = rr[1] * htr[1] + rr[2] * htr[2];


      xmws[1] = 0.;
      xmws[2] = 0.;
      xmws[6] = 0.;
      xmws[8] = 0.;
      xmws[9] = 0.;
      xmws[10] = 0.;

      do i__ = 1 to 8;
      xst[i__ + 1 + 39] = xvv[i__];
      xst[i__ + 1 + 55] = xvr[i__];
      xst[i__ + 1 + 63] = xvs[i__];
      xst[i__ + 1 + 71] = xvs[i__];
      xst[i__ + 1 + 79] = xls[i__];
      xst[i__ + 1 + 95] = xlc[i__];
      xmws[1] = xmws[1] + xst[i__] * xmw[i__];
      xmws[2] = xmws[2] + xst[i__ + 7 + 1] * xmw[i__];
      xmws[6] = xmws[6] + xst[i__ + 39 + 1] * xmw[i__];
      xmws[8] = xmws[8] + xst[i__ + 55 + 1] * xmw[i__];
      xmws[9] = xmws[9] + xst[i__ + 63 + 1] * xmw[i__];
      xmws[10] = xmws[10] + xst[i__ + 71 + 1] * xmw[i__];
      end;

      tst[6] = tcv;
      tst[8] = tcr; 
      tst[9] = tcs;
      tst[10] = tcs;
      tst[11] = tcs;
      tst[13] = tcc;

      array axst[8];
      do i__ = 1 to 8;
        axst[i__] = xst[i__];
      end;
      hst[1] = tesub1_(axst, tst[1], c__1, xmw);
      do i__ = 1 to 8;
        axst[i__] = xst[i__+8];
      end;
      hst[2] = tesub1_(axst, tst[2], c__1, xmw);
      do i__ = 1 to 8;
        axst[i__] = xst[i__+16];
      end;
      hst[3] = tesub1_(axst, tst[3], c__1, xmw);
      do i__ = 1 to 8;
        axst[i__] = xst[i__+24];
      end;
      hst[4] = tesub1_(axst, tst[4], c__1, xmw);
      do i__ = 1 to 8;
        axst[i__] = xst[i__+40];
      end;
      hst[6] = tesub1_(axst, tst[6], c__1, xmw);
      do i__ = 1 to 8;
        axst[i__] = xst[i__+56];
      end;
      hst[8] = tesub1_(axst, tst[8], c__1, xmw);
      do i__ = 1 to 8;
        axst[i__] = xst[i__+64];
      end;
      hst[9] = tesub1_(axst, tst[9], c__1, xmw);
      hst[10] = hst[9]; 
      do i__ = 1 to 8;
        axst[i__] = xst[i__+80];
      end;
      hst[11] = tesub1_(axst, tst[11], c__0, xmw);
      do i__ = 1 to 8;
        axst[i__] = xst[i__+96];
      end;
      hst[13] = tesub1_(axst, tst[13], c__0, xmw);

      vpos[1] = YY[39];
      ftm[1] = vpos[1] * vrng[1] / 100.;
      vpos[2] = YY[40];
      ftm[2] = vpos[2] * vrng[2] / 100.;
      vpos[3] = YY[41];
      ftm[3] = vpos[3] * (1. - idv[6]) * vrng[3] / 100.;;
      vpos[4] = YY[42];
      ftm[4] = vpos[4] * (1. - idv[7] * .2) * vrng[4] / 100. + 1e-10;
      ftm[11] = vpos[7] * vrng[7] / 100.;
      ftm[13] = vpos[8] * vrng[8] / 100.;

      uac = vpos[9] * vrng[9]*(tesub8_(c__9,adist,bdist,cdist,ddist)+1.)/100.;
      fwr = vpos[10] * vrng[10] / 100.;
      fws = vpos[11] * vrng[11] / 100.;
      agsp = (vpos[12] + 150.) / 100.;

      dlp = ptv - ptr;
      if (dlp < 0.) then
      dlp = 0.;
      flms = sqrt(dlp) * 1937.6;
      ftm[6] = flms / xmws[6];

      dlp = ptr - pts;
      if (dlp < 0.) then
      dlp = 0.;
      flms = sqrt(dlp) * 4574.21 *
                (1. - tesub8_(c__12, adist, bdist, cdist, ddist) * .25);
      ftm[8] = flms / xmws[8];

      dlp = pts - 760.;
      if (dlp < 0.) then
      dlp = 0.;

      flms = vpos[6] * .151169 * sqrt(dlp);
      ftm[10] = flms / xmws[10];
      pr = ptv / pts;
      if (pr < 1.) then
        pr = 1.;
      if (pr > cpprmx) then
      pr = cpprmx;
      flcoef = cpflmx / 1.197;

      d__1 = pr;
      flms = cpflmx +
           flcoef * (1. - d__1 * (d__1 * d__1));
      cpdh = flms * (tcs + 273.15) * 1.8e-6 * 1.9872 *
         (ptv - pts) /
           (xmws[9] * pts);
      dlp = ptv - pts;
      if (dlp < 0.) then
      dlp = 0.;
      flms = flms - vpos[5] * 53.349 * sqrt(dlp);
      if (flms < .001) then
      flms = .001;
      ftm[9] = flms / xmws[9];
      hst[9] = hst[9] + cpdh / ftm[9];

      do i__ = 1 to 8;
        fcm[i__] = xst[i__] * ftm[1];
        fcm[i__ + 8] = xst[i__ + 8] * ftm[2];
        fcm[i__ + 16] = xst[i__ + 16] * ftm[3];
        fcm[i__ + 24] = xst[i__ + 24] * ftm[4];
        fcm[i__ + 40] = xst[i__ + 40] * ftm[6];
        fcm[i__ + 56] = xst[i__ + 56] * ftm[8];
        fcm[i__ + 64] = xst[i__ + 64] * ftm[9];
        fcm[i__ + 72] = xst[i__ + 72] * ftm[10];
        fcm[i__ + 80] = xst[i__ + 80] * ftm[11];
        fcm[i__ + 96] = xst[i__ + 96] * ftm[13];
      end;

      if (ftm[11] > .1)then do;
        if (tcc > 170.) then
          tmpfac = tcc - 120.262;
        else if (tcc < 5.292) then
          tmpfac = .1;
        else
          tmpfac = 363.744 / (177. -
                   tcc) - 2.22579488;

        vovrl = ftm[4] / ftm[11] * tmpfac;
        sfr[4] = vovrl *  8.501  / (vovrl * 8.501 + 1.);
        sfr[5] = vovrl * 11.402  / (vovrl * 11.402 + 1.);
        sfr[6] = vovrl * 11.795  / (vovrl * 11.795 + 1.);
        sfr[7] = vovrl *   .048  / (vovrl * .048 + 1.);
        sfr[8] = vovrl *   .0242 / (vovrl * .0242 + 1.);
      end;
      else do;
        sfr[4] = .9999;
        sfr[5] = .999;
        sfr[6] = .999;
        sfr[7] = .99;
        sfr[8] = .98;
      end; 

      do i__ = 1 to 8;
        fin[i__] = 0.;
        fin[i__] = fin[i__] + fcm[i__ + 24];
        fin[i__] = fin[i__] + fcm[i__ + 80];
      end;

      ftm[5] = 0.;
      ftm[12] = 0.;
      do i__ = 1 to 8;
        fcm[i__ + 32] = sfr[i__] * fin[i__];
        fcm[i__ + 88] = fin[i__] - fcm[i__ + 32];
        ftm[5] = ftm[5] + fcm[i__ + 32];
        ftm[12] = ftm[12] + fcm[i__ + 88];
      end;

      do i__ = 1 to 8;
        xst[i__ + 32] = fcm[i__ + 32] / ftm[5];
        xst[i__ + 88] = fcm[i__ + 88] / ftm[12];
      end;

      tst[5] = tcc;
      tst[12] = tcc;
      do i__ = 1 to 8;
        axst[i__] = xst[i__+32];
      end;
      hst[5] = tesub1_(axst, tst[5], c__1, xmw);
      do i__ = 1 to 8;
        axst[i__] = xst[i__+88];
      end;
      hst[12] = tesub1_(axst, tst[12], c__0, xmw);
      ftm[7] = ftm[6];
      hst[7] = hst[6];
      tst[7] = tst[6];
      do i__ = 1 to 8;
        xst[i__ + 48] = xst[i__ + 40];
        fcm[i__ + 48] = fcm[i__ + 40];
      end;

      if (vlr / 7.8 > 50.) then
        uarlev = 1.;
      else if (vlr / 7.8 < 10.) then
        uarlev = 0.;
      else uarlev = vlr * .025 / 7.8 - .25;

      d__1 = agsp;
      uar = uarlev *
            (d__1 * d__1 * -.5 +
            agsp * 2.75 - 2.5) * .85549;
      qur = uar *
            (twr - tcr) *
            (1. - tesub8_(c__10, adist, bdist, cdist, ddist) * .35);

      d__1  = ftm[8] / 3528.73;
      d__1  = d__1 * d__1;
      uas   = (1. - 1. / (d__1 * d__1 + 1.)) * .404655;
      qus = uas * (tws - tst[8])
                * (1. - tesub8_(c__11, adist, bdist, cdist, ddist) * .25);

      quc = 0.;
      if (tcc < 100.) then
        quc = uac * (100. - tcc);

      tlastcomp = time;

    crxr[2] = 0;

    do i__ = 1 to 8;
      yp[i__] = fcm[i__ + 48] - fcm[i__ + 56] + crxr[i__];
      yp[i__ + 9] = fcm[i__ + 56]-fcm[i__ + 64]-fcm[i__ + 72]-fcm[i__ + 80];
      yp[i__ + 18] = fcm[i__ + 88] - fcm[i__ + 96];
      yp[i__ + 27] = fcm[i__] + fcm[i__ + 8]  + fcm[i__ + 16] + fcm[i__ + 32]+
                     fcm[i__ + 64] - fcm[i__ + 40];
    end;

    yp[9] = hst[7] * ftm[7] -
            hst[8] * ftm[8] +
            rh + qur;
    yp[18] =
           hst[8]  * ftm[8] -
           hst[9]  * ftm[9] -
           hst[10]  * ftm[10] -
           hst[11] * ftm[11]+
           qus;
    yp[27] =
           hst[4]  * ftm[4] +
           hst[11] * ftm[11]-
           hst[5]  * ftm[5] -
           hst[13] * ftm[13]+
           quc;
    yp[36] =
           hst[1] * ftm[1] +
           hst[2] * ftm[2] +
           hst[3] * ftm[3] +
           hst[5] * ftm[5] +
           hst[9] * ftm[9] -
           hst[6] * ftm[6];

    yp[37] = (fwr * 500.53 *
              (tcwr - twr) -
              qur * 1e6 / 1.8) /
              hwr;
    yp[38] = (fws * 500.53 *
              (tcws - tws) -
              qus * 1e6 / 1.8) /
              hws;

    ivst[10]  = idv[14];
    ivst[11] = idv[15];
    ivst[5]  = idv[19];
    ivst[7]  = idv[19];
    ivst[8]  = idv[19];
    ivst[9]  = idv[19];
    do i__ = 1 to 12;
      if ((time < tstart + 0.000001) | abs( vcv[i__] - xmv[i__] )
        > vst[i__] * ivst[i__]) then
        vcv[i__] = xmv[i__];

      if (vcv[i__ ] < 0.) then
        vcv[i__] = 0.;
      if (vcv[i__] > 100.) then
        vcv[i__] = 100.;

      yp[i__ + 38] =
        (vcv[i__] - vpos[i__]) /
        vtau[i__];
    end;

    do i__ = 1 to 50;
      d_YY[i__] = yp[i__];
    end;

    sdev[1] =         10.40491389/20000;
    sdev[2] =         4.363996017/20000;
    sdev[3] =           7.570059737/20000;
    sdev[4] =           0.4230042431/20000;
    sdev[5] =          24.15513437/20000;
    sdev[6] =           2.942597645/20000;
    sdev[7] =         154.3770655/20000;
    sdev[8] =         159.186596/20000;
    sdev[9] =           2.808522723/20000;
    sdev[10]=          63.75581199/20000;
    sdev[11]=          26.74026066/20000;
    sdev[12]=          46.38532432/20000;
    sdev[13]=           0.2464521543/20000;
    sdev[14]=          15.20484404/20000;
    sdev[15]=           1.852266172/20000;
    sdev[16]=          52.44639459/20000;
    sdev[17]=          41.20394008/20000;
    sdev[18]=           0.569931776/20000;
    sdev[19]=           0.4306056376/20000;
    sdev[20]=           0.0079906200783/20000;
    sdev[21]=           0.9056036089/20000;
    sdev[22]=           0.016054258216/20000;
    sdev[23]=           0.7509759687/20000;
    sdev[24]=           0.088582855955/20000;
    sdev[25]=          48.27726193/20000;
    sdev[26]=          39.38459028/20000;
    sdev[27]=           0.3755297257/20000;
    sdev[28]=         107.7562698/20000;
    sdev[29]=          29.77250546/20000;
    sdev[30]=          88.32481135/20000;
    sdev[31]=          23.03929507/20000;
    sdev[32]=          62.85848794/20000;
    sdev[33]=           5.546318688/20000;
    sdev[34]=          11.92244772/20000;
    sdev[35]=           5.555448243/20000;
    sdev[36]=           0.9218489762/20000;
    sdev[37]=          94.59927549/20000;
    sdev[38]=          77.29698353/20000;
    sdev[39]=          63.05263039/20000;
    sdev[40]=          53.97970677/20000;
    sdev[41]=          24.64355755/20000;
    sdev[42]=          61.30192144/20000;
    sdev[43]=          22.21/20000;
    sdev[44]=          40.06374673/20000;
    sdev[45]=          38.1003437/20000;
    sdev[46]=          46.53415582/20000;
    sdev[47]=          47.44573456/20000;
    sdev[48]=          41.10581288/20000;
    sdev[49]=          18.11349055/20000;
    sdev[50]=          50.0/20000;

  endsub;
quit;
proc fcmp setcascmplib="casuser.nonlinears" getcascmplib; run;

data casuser.chemData;
set d.te_normal;
run;

proc dynbnet data = casuser.chemData
           odeapprox = ALL;
     varroles data = casuser.variableRoles;
     varlevels data = casuser.variableLevels;
     links data = casuser.variableLinks;
     initbeliefs data = casuser.initialBeliefs;
     output out = casuser.chemOut;
run;

