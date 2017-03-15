subroutine mechanism_rates(p,t,y,mnsp)
    USE photolysisRates
    USE zenithData1
    USE constraints
  use envVars, only: ro2

    implicit none

    ! calculates rate constants from arrhenius informtion
    double precision, intent(out) :: p(*)
    double precision, intent(in) :: t
    integer, intent(in) :: mnsp
    double precision, intent(in) :: y(mnsp)
    double precision:: temp, pressure, dummy
    double precision:: N2, O2, M, RH, H2O, DEC, BLH, DILUTE, JFAC, ROOFOPEN
    double precision:: KRO2NO, KRO2HO2, KAPHO2, KAPNO, KRO2NO3, KNO3AL, KDEC, KROPRIM, KROSEC, KCH3O2
    double precision:: K298CH3O2, K14ISOM1, KD0, KDI, KRD, FCD, NCD, FD, KBPAN, KC0
    double precision:: KCI, KRC, FCC, NC, FC, KFPAN, K10, K1I, KR1, FC1
    double precision:: NC1, F1, KMT01, K20, K2I, KR2, FC2, NC2, F2, KMT02
    double precision:: K30, K3I, KR3, FC3, NC3, F3, KMT03, K40, K4I, KR4
    double precision:: FC4, NC4, F4, KMT04, KMT05, KMT06, K70, K7I, KR7, FC7
    double precision:: NC7, F7, KMT07, K80, K8I, KR8, FC8, NC8, F8, KMT08
    double precision:: K90, K9I, KR9, FC9, NC9, F9, KMT09, K100, K10I, KR10
    double precision:: FC10, NC10, F10, KMT10, K1, K3, K4, K2, KMT11, K120
    double precision:: K12I, KR12, FC12, NC12, F12, KMT12, K130, K13I, KR13, FC13
    double precision:: NC13, F13, KMT13, K140, K14I, KR14, FC14, NC14, F14, KMT14
    double precision:: K150, K15I, KR15, FC15, NC15, F15, KMT15, K160, K16I, KR16
    double precision:: FC16, NC16, F16, KMT16, K170, K17I, KR17, FC17, NC17, F17
    double precision:: KMT17, KMT18, KPPN0, KPPNI, KRPPN, FCPPN, NCPPN, FPPN, KBPPN



    ! declare variables missed in MCM definition
    integer :: i
    double precision::  photoRateAtT

  include 'modelConfiguration/mechanism-rate-declarations.f90'

    call ro2sum(ro2, y)
    dummy = y(1)

    dec = -1e16

    call getEnvVarsAtT(t,temp,rh,h2o,dec,pressure,m,blh,dilute,jfac,roofOpen)

  call atmosphere(O2, N2,m)




    !O2 = 0.2095*m
    !N2 = 0.7809*m



    ! * **** SIMPLE RATE COEFFICIENTS *****                     *    !* Generic Rate Coefficients ;
    !*;
    KRO2NO = 2.7D-12*EXP(360/TEMP)
    KRO2HO2 = 2.91D-13*EXP(1300/TEMP)
    KAPHO2 = 5.2D-13*EXP(980/TEMP)
    KAPNO = 7.5D-12*EXP(290/TEMP)
    KRO2NO3 = 2.3D-12
    KNO3AL = 1.4D-12*EXP(-1860/TEMP)
    KDEC = 1.00D+06
    KROPRIM = 2.50D-14*EXP(-300/TEMP)
    KROSEC = 2.50D-14*EXP(-300/TEMP)
    KCH3O2 = 1.03D-13*EXP(365/TEMP)
    K298CH3O2 = 3.5D-13
    K14ISOM1 = 3.00D7*EXP(-5300/TEMP)
    !*;
    !* Complex reactions ;
    !*;
    KD0 = 1.10D-05*M*EXP(-10100/TEMP)
    KDI = 1.90D17*EXP(-14100/TEMP)
    KRD = KD0/KDI
    FCD = 0.30
    NCD = 0.75-1.27*(LOG10(FCD))
    FD = 10**(LOG10(FCD)/(1+(LOG10(KRD)/NCD)**2))
    KBPAN = (KD0*KDI)*FD/(KD0+KDI)
    KC0 = 3.28D-28*M*(TEMP/300)**(-6.87)
    KCI = 1.125D-11*(TEMP/300)**(-1.105)
    KRC = KC0/KCI
    FCC = 0.30
    NC = 0.75-1.27*(LOG10(FCC))
    FC = 10**(LOG10(FCC)/(1+(LOG10(KRC)/NC)**2))
    KFPAN = (KC0*KCI)*FC/(KC0+KCI)
    K10 = 1.0D-31*M*(TEMP/300)**(-1.6)
    K1I = 5.0D-11*(TEMP/300)**(-0.3)
    KR1 = K10/K1I
    FC1 = 0.85
    NC1 = 0.75-1.27*(LOG10(FC1))
    F1 = 10**(LOG10(FC1)/(1+(LOG10(KR1)/NC1)**2))
    KMT01 = (K10*K1I)*F1/(K10+K1I)
    K20 = 1.3D-31*M*(TEMP/300)**(-1.5)
    K2I = 2.3D-11*(TEMP/300)**0.24
    KR2 = K20/K2I
    FC2 = 0.6
    NC2 = 0.75-1.27*(LOG10(FC2))
    F2 = 10**(LOG10(FC2)/(1+(LOG10(KR2)/NC2)**2))
    KMT02 = (K20*K2I)*F2/(K20+K2I)
    K30 = 3.6D-30*M*(TEMP/300)**(-4.1)
    K3I = 1.9D-12*(TEMP/300)**0.2
    KR3 = K30/K3I
    FC3 = 0.35
    NC3 = 0.75-1.27*(LOG10(FC3))
    F3 = 10**(LOG10(FC3)/(1+(LOG10(KR3)/NC3)**2))
    KMT03 = (K30*K3I)*F3/(K30+K3I)
    K40 = 1.3D-3*M*(TEMP/300)**(-3.5)*EXP(-11000/TEMP)
    K4I = 9.7D+14*(TEMP/300)**0.1*EXP(-11080/TEMP)
    KR4 = K40/K4I
    FC4 = 0.35
    NC4 = 0.75-1.27*(LOG10(FC4))
    F4 = 10**(LOG10(FC4)/(1+(LOG10(KR4)/NC4)**2))
    KMT04 = (K40*K4I)*F4/(K40+K4I)
    KMT05 = 1.44D-13*(1+(M/4.2D+19))
    KMT06 = 1 + (1.40D-21*EXP(2200/TEMP)*H2O)
    K70 = 7.4D-31*M*(TEMP/300)**(-2.4)
    K7I = 3.3D-11*(TEMP/300)**(-0.3)
    KR7 = K70/K7I
    FC7 = 0.81
    NC7 = 0.75-1.27*(LOG10(FC7))
    F7 = 10**(LOG10(FC7)/(1+(LOG10(KR7)/NC7)**2))
    KMT07 = (K70*K7I)*F7/(K70+K7I)
    K80 = 3.2D-30*M*(TEMP/300)**(-4.5)
    K8I = 3.0D-11
    KR8 = K80/K8I
    FC8 = 0.41
    NC8 = 0.75-1.27*(LOG10(FC8))
    F8 = 10**(LOG10(FC8)/(1+(LOG10(KR8)/NC8)**2))
    KMT08 = (K80*K8I)*F8/(K80+K8I)
    K90 = 1.4D-31*M*(TEMP/300)**(-3.1)
    K9I = 4.0D-12
    KR9 = K90/K9I
    FC9 = 0.4
    NC9 = 0.75-1.27*(LOG10(FC9))
    F9 = 10**(LOG10(FC9)/(1+(LOG10(KR9)/NC9)**2))
    KMT09 = (K90*K9I)*F9/(K90+K9I)
    K100 = 4.10D-05*M*EXP(-10650/TEMP)
    K10I = 6.0D+15*EXP(-11170/TEMP)
    KR10 = K100/K10I
    FC10 = 0.4
    NC10 = 0.75-1.27*(LOG10(FC10))
    F10 = 10**(LOG10(FC10)/(1+(LOG10(KR10)/NC10)**2))
    KMT10 = (K100*K10I)*F10/(K100+K10I)
    K1 = 2.40D-14*EXP(460/TEMP)
    K3 = 6.50D-34*EXP(1335/TEMP)
    K4 = 2.70D-17*EXP(2199/TEMP)
    K2 = (K3*M)/(1+(K3*M/K4))
    KMT11 = K1 + K2
    K120 = 2.5D-31*M*(TEMP/300)**(-2.6)
    K12I = 2.0D-12
    KR12 = K120/K12I
    FC12 = 0.53
    NC12 = 0.75-1.27*(LOG10(FC12))
    F12 = 10**(LOG10(FC12)/(1.0+(LOG10(KR12)/NC12)**2))
    KMT12 = (K120*K12I*F12)/(K120+K12I)
    K130 = 2.5D-30*M*(TEMP/300)**(-5.5)
    K13I = 1.8D-11
    KR13 = K130/K13I
    FC13 = 0.36
    NC13 = 0.75-1.27*(LOG10(FC13))
    F13 = 10**(LOG10(FC13)/(1+(LOG10(KR13)/NC13)**2))
    KMT13 = (K130*K13I)*F13/(K130+K13I)
    K140 = 9.0D-5*EXP(-9690/TEMP)*M
    K14I = 1.1D+16*EXP(-10560/TEMP)
    KR14 = K140/K14I
    FC14 = 0.36
    NC14 = 0.75-1.27*(LOG10(FC14))
    F14 = 10**(LOG10(FC14)/(1+(LOG10(KR14)/NC14)**2))
    KMT14 = (K140*K14I)*F14/(K140+K14I)
    K150 = 8.6D-29*M*(TEMP/300)**(-3.1)
    K15I = 9.0D-12*(TEMP/300)**(-0.85)
    KR15 = K150/K15I
    FC15 = 0.48
    NC15 = 0.75-1.27*(LOG10(FC15))
    F15 = 10**(LOG10(FC15)/(1+(LOG10(KR15)/NC15)**2))
    KMT15 = (K150*K15I)*F15/(K150+K15I)
    K160 = 8D-27*M*(TEMP/300)**(-3.5)
    K16I = 3.0D-11*(TEMP/300)**(-1)
    KR16 = K160/K16I
    FC16 = 0.5
    NC16 = 0.75-1.27*(LOG10(FC16))
    F16 = 10**(LOG10(FC16)/(1+(LOG10(KR16)/NC16)**2))
    KMT16 = (K160*K16I)*F16/(K160+K16I)
    K170 = 5.0D-30*M*(TEMP/300)**(-1.5)
    K17I = 1.0D-12
    KR17 = K170/K17I
    FC17 = 0.17*EXP(-51/TEMP)+EXP(-TEMP/204)
    NC17 = 0.75-1.27*(LOG10(FC17))
    F17 = 10**(LOG10(FC17)/(1.0+(LOG10(KR17)/NC17)**2))
    KMT17 = (K170*K17I*F17)/(K170+K17I)
    KMT18 = 9.5D-39*O2*EXP(5270/TEMP)/(1+7.5D-29*O2*EXP(5610/TEMP))
    KPPN0 = 1.7D-03*EXP(-11280/TEMP)*M
    KPPNI = 8.3D+16*EXP(-13940/TEMP)
    KRPPN = KPPN0/KPPNI
    FCPPN = 0.36
    NCPPN = 0.75-1.27*(LOG10(FCPPN))
    FPPN = 10**(LOG10(FCPPN)/(1+(LOG10(KRPPN)/NCPPN)**2))
    KBPPN = (KPPN0*KPPNI)*FCPPN/(KPPN0+KPPNI)
    !****************************************************** ;
    !*;
    do i = 1, nrOfPhotoRates
        if (useConstantValues .eq. 0) then
            if (cosx.lt.1.00d-10) then
                j(ck(i)) = 1.0d-30
            else
                j(ck(i)) = cl(i)*cosx**( cmm(i))*exp(-cnn(i)*secx)*transmissionFactor(i)*roofOpen*jfac
            endif
        else
            j(ck(i)) = cl(i)
        endif
    enddo

    do  i =1,numConPhotoRates
        call getConstrainedQuantAtT2D(t,photoX,photoY,photoY2,photoNumberOfPoints(i),photoRateAtT, 2,i, &
            maxNumberOfDataPoints,numConPhotoRates)
        j(constrainedPhotoRatesNumbers(i)) = photoRateAtT
    enddo

    include 'modelConfiguration/mechanism-rate-coefficients.f90'
    return
end

include 'modelConfiguration/extraOutputSubroutines.f90'
