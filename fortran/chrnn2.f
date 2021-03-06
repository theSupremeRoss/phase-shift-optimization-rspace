      subroutine chrnn
c     
c     name of file: chrnn2.f 
c
c     third revision started November, 2019.
c     final version of Feb. 25, 2020.
c
c         chiral NN potential in r-space
c
c
c
      implicit real*8(a-h,o-z)
c
c        `classical' r-space common blocks
      common /readw/kwrite,kpunch,kread1,kread2
      common /nquant/ omega(5,23),iq(4),mlauf,index
      common /facen/ccf,e,x,xl,n
      common /cpotr1/vh(3),pquad(2)
c        this was the end of the `classical' r-space common blocks
c        note: the classical name for /cpotr1/ was /cpot/.
c
      common /cpotr2/vj(5),pqj(5),pqpj(5)
c
      common /cchr/c(20,300),wn,tlamb,ga,fpi,
     1            cb1,cb2,cb3,cb4,cd12,cd3,cd5,cd145,
     2            ic(20,300),mgg(300),ime,
     3            indt(300)
c
      logical indt
      dimension vv(5),pq(5),pqp(5)
      dimension amu(960),wmu(960),amu2(960)
      dimension aq(960),wq(960)
      dimension aint33(960),aint341(960),aint342(960)
      integer ioper(24)/'c   ','ss  ','ls  ','ls2 ','s12 ',
     1'c00 ','c01 ','c10 ','c11 ',
     2'ls0 ','ls1 ','ls20','ls21','s120','s121',
     3'c0  ','c1  ',
     4'l2  ','l2ss','l200','l201','l210','l211','    '/
c
      logical indpar/.false./
      logical indmu/.false./
      logical ind33/.false./
      logical ind341/.false./
      logical ind342/.false./
c
c
      data hbarc/197.32698d0/
      data pi/3.141592653589793d0/
      data gam3d4/1.2254167024651776d0/
      data gammae/0.5772156649015329d0/
c
      data xx7/-1.d0/
      data enn8/-1.d0/,xx8/-1.d0/
      data rrcut/-1.d0/,xxl/-1.d0/
      data rrrcut/-1.d0/,xxxl/-1.d0/
      data r4cut/-1.d0/,x4l/-1.d0/
      data cc4mu/-1.d0/
c
c
c
c
c         call subroutine chrpar once and only once
c
c
      if (indpar) go to 50
      indpar=.true.
c
c
      call chrpar
c
c
      pih=pi*0.5d0
      pi2=pi*pi
      sqrpi=dsqrt(pi)
      ga2 = ga * ga
      ga4 = ga2 * ga2
c
c
   50 xr = xl/hbarc 
      xr3=xr*xr*xr
      xr4=xr3*xr
      xr5=xr4*xr
      xr6=xr3*xr3
      xr7=xr6*xr
c
c
c
c
c        the following is needed only for the potentials by
c        Gezerlis PRC90, 054323 (2014)
c
      yrc=xr*tlamb
      yrc2=yrc*yrc
      yrc3=yrc2*yrc
      yrc4=yrc3*yrc
c
      if(yrc.gt.200.d0) then
         yuky = 0.d0
         else
         yuky = dexp(-yrc)
         end if
c
c
      if (tlamb.eq.0.d0) then
      yuky=0.d0
      end if
c
c        end: Gezerlis PRC90, 054323 (2014)
c
c
c
c
      do 55 k=1,3
   55 vh(k) = 0.d0
      do 56 k=1,2
   56 pquad(k) = 0.d0
      do 57 k=1,5
      vj(k) = 0.d0
      pqj(k) = 0.d0
   57 pqpj(k) = 0.d0
c
      ndo = 2 * index - 1
c
c
c
c
c         contributions
c         -------------
c         -------------
c
c
c
c
      do 8500 mes=1,ime
c
      mg=mgg(mes)
      if (mg.eq.24) go to 8500
c
c
      if (mg.lt.1.or.mg.gt.24) then
      write (kwrite,19000) mg
19000 format(/////' error in chrnn:  contribution   ',i4,'   does not
     1 exist in this program.'/' execution terminated.'////)
      stop
      end if
c
c
      iop=mg
c
c
c
c
c        get the operator matrix elements
c        --------------------------------
c
c
      do 65 k=1,5
      vv(k)=omega(k,iop)
      pq(k)=omega(k,iop)
   65 pqp(k)=omega(k,iop)
c
c
c
c
c        create functions and factors
c        ----------------------------
c
c
      c4 = c(4,mes)
      xrc = xr * c4
      xrcd=xrc*2.d0
      xrcq=xrc*4.d0
      xrci=1.d0/xrc
      xrc2=xrc*xrc
      xrc3=xrc2*xrc
      xrc4=xrc2*xrc2
      xrc5=xrc3*xrc2
      xrc6=xrc3*xrc3
      xrc7=xrc4*xrc3
      xrcp1=xrc+1.d0
      xrcp1s=xrcp1*xrcp1
c
c
      if(xrc.gt.200.d0) then
         yukx = 0.d0
         else
         yukx = dexp(-xrc)
         end if
      if(xrcd.gt.200.d0) then
         yukx2 = 0.d0
         else
         yukx2 = dexp(-xrcd)
         end if
c
c
         yukx4 = dexp(xrcq)
c
c
      go to 80
c
c
c
c
c        the following is needed only for the potentials by
c        Gezerlis PRC90, 054323 (2014)
c        prepare mu integration that starts from 2m_pi
c
   70 indmu=.true.
      ind33=.false.
      ind341=.false.
      ind342=.false.
c
      cc4mu=c4
c
      wpi2=2.d0*c4
c
      nmu=500
      cmu=c4
c
      if (tlamb.eq.0.d0) then
      astart=0.d0
      acut=1.d0
      else
      astart=wpi2
      acut=tlamb
      end if
c
      call gauss(astart,acut,nmu,amu,wmu)
c
c        transform gauss points and weights
      do 75 ii=1,nmu
c
      if (tlamb.eq.0.d0) then
      xmu=pih*amu(ii)
c        transformed gauss point
      amu(ii)=dtan(xmu)*cmu+wpi2
c        transformed gauss weight
      dcmu=1.d0/dcos(xmu)
      wmu(ii)=pih*cmu*dcmu*dcmu*wmu(ii)
      end if
c
      amu2(ii)=amu(ii)*amu(ii)
   75 continue
      go to 7999
c        end: Gezerlis PRC90, 054323 (2014)
c
c
c
c
   80 fac = c(1,mes)
      facpq = c(1,mes)
      mi = 1
      mm = 5
      go to 99
c
c
   95 mi = mi + 3
      mm = mm + 3
c
c
   99 itype = ic(mi,mes)
      if(itype.eq.0) go to 8000
      icase = ic(mi+1,mes) 
c
c
 7999 go to(100,200,300,9002,9002,9002,700,800,9002,9002,
     1 9002,9002,1300,1400,1500,1600,1700,1800,1900,2000,
     2 9002,9002,9002,9002,2500,2600,9002,2800,2900,3000,
     3 3100,3200,3300,3400,3500,3600,3700,3800,3900,4000,
     4 4100,4200,4300,9002,9002,9002,9002,9002,9002,9002,
     5 5100,5200,5300,5400),itype
c
c
c        for 1PE
c        -------
  100 fac = fac*c(mm,mes)*yukx/xr
      facpq=0.d0
      go to 95
c
c        for 1PE
c        -------
  200 fac = fac*c(mm,mes)*yukx/xr3
     1 *(3.d0+3.d0*xrc+xrc2)
      facpq=0.d0
      go to 95
c
c
c
  300 continue
      nexp = ic(mi+2,mes) 
      go to (320,340),nexp
c
  320 if (c(mm+1,mes).ne.rrcut.or.xl.ne.xxl) then
      rrcut=c(mm+1,mes)
      xxl=xl
      rrcut2=rrcut*rrcut
      rrcut3=rrcut2*rrcut
      rrcut5=rrcut3*rrcut2
      rrcut7=rrcut5*rrcut2
      rrcut9=rrcut7*rrcut2
      rrcut11=rrcut9*rrcut2
      xxl2=xl*xl
      xxl3=xl*xl*xl
      xxl4=xl*xl*xl*xl
      xxlcut2=xxl2/rrcut2
      f01=hbarc/(pi*sqrpi*rrcut2*rrcut)*dexp(-xxlcut2)
      fqq1=f01*(3.d0-2.d0*xxlcut2)*2.d0/rrcut2
c    
      if(xxlcut2.gt.200.d0) then
         yukxrs = 0.d0
         else
         yukxrs = dexp(-xxlcut2)
         end if
c     
      crs0=yukxrs/rrcut3
      crs1=-2.d0*xxl*yukxrs/rrcut5
      crs2=-2.d0*yukxrs/rrcut5+4.d0*xxl2*yukxrs/rrcut7
      crs3=12.d0*xxl*yukxrs/rrcut7-8.d0*xxl3*yukxrs/rrcut9
      crs4=12.d0*yukxrs/rrcut7-48.d0*xxl2*yukxrs/rrcut9+16.d0
     1      *xxl4*yukxrs/rrcut11
      end if
c
c
      go to (321,322,9002,9002,325,326,327,9002,9002,9002,
     1        331,332,333,334,335,336,337,338),icase
c
  321 fac = fac*f01 
      facpq=0.d0
      go to 95
c
  322 fac = fac*fqq1
      facpq=0.d0
      go to 95
c
  325 fac = fac*f01*2.d0/rrcut2
      facpq=0.d0
      go to 95
c
  326 fac = fac*fqq1/3.d0
      facpq=0.d0
      go to 95
c
  327 fac = -fac*f01*4.d0*xxlcut2/(3.d0*rrcut2)
      facpq=0.d0
      go to 95
  
  331 fac = fac*c(mm,mes)*crs0
      facpq=0.d0
      go to 95
c  
  332 fac = fac*c(mm,mes)*(-crs2-(2.d0/xxl)*crs1)
      facpq=0.d0
      go to 95
c  
  333 fac = fac*c(mm,mes)*(crs4+(4.d0/xxl)*crs3)
      facpq=0.d0
      go to 95
c
  334 fac = fac*c(mm,mes)*(-crs2+(1.d0/xxl)*crs1)
      facpq=0.d0
      go to 95
c
  335 fac = fac*c(mm,mes)*(crs4+(1.d0/xxl)*crs3
     1      -(6.d0/xxl2)*crs2+(6.d0/xxl3)*crs1)
      facpq=0.d0
      go to 95
c
  336 fac =-fac*c(mm,mes)*(1.d0/xxl)*crs1
      facpq=0.d0
      go to 95
c 
  337 fac = fac*c(mm,mes)*((1.d0/xxl)*crs3
     1      +(2.d0/xxl2)*crs2-(2.d0/xxl3)*crs1)
      facpq=0.d0
      go to 95
c
  338 fac = fac*c(mm,mes)*(1.d0/xxl2)*(-crs2+(1.d0/xxl)
     1      *crs1)
      facpq=0.d0
      go to 95
c
c
  340 if (icase.gt.10) go to 350
      if (c(mm+1,mes).ne.rrrcut.or.xl.ne.xxxl) then
      rrrcut= c(mm+1,mes)
      xxxl=xl
      rrrcut4= rrrcut**4
      xxxl2=xl*xl
      xxxl4= xxxl2*xxxl2
      xxxlcut4= xxxl4/rrrcut4
      f02= hbarc/(pi*gam3d4*rrrcut**3)*dexp(-xxxlcut4)
      fqq2= 4.d0*xxxl2/rrrcut4*(5.d0-4.d0*xxxlcut4)*f02
      end if
c	  
      go to (341,342,9002,9002,345,346,347,9002,9002,9002),icase
c	  
  341 fac= fac*f02
      facpq= 0.d0
      go to 95
c
  342 fac= fac*fqq2
      facpq= 0.d0
      go to 95
c
  345 fac= fac*4.d0*xxxl2/rrrcut4*f02
      facpq=0.d0
      go to 95
c
  346 fac= fac*fqq2/3.d0
      facpq= 0.d0
      go to 95	  
c	  
  347 fac= fac*8.d0*xxxl2/(3.d0*rrrcut4)
     1 *(1.d0-2.d0*xxxlcut4)*f02
      facpq=0.d0
      go to 95
c
c
  350 if(icase.gt.11) go to 9002
      if (xl.gt.10.d0) then
      f02alt=0.d0
      go to 368
      end if
c
      if (c(mm+1,mes).ne.r4cut.or.xl.ne.x4l) then
      r4cut= c(mm+1,mes)
      x4l=xl
          alam = 2.d0/r4cut
	  alam2= alam*alam
	  alam4=alam2*alam2
c 
	  fac4q = hbarc/(2.d0*pi2)
c 
	  nq=96
	  cq=2.5d0*alam
c 
	  call gauss(0.d0,cq,nq,aq,wq)
c
         aintq=0.d0
         do 367, i=1,nq
         aq2=aq(i)*aq(i)
         aq4=aq2*aq2
         aaintq=aq(i)*dsin(aq(i)*x4l)*dexp(-aq4/alam4)
  367    aintq=aintq+wq(i)*aaintq
c
         f02alt=fac4q*aintq/x4l
      end if
  368 continue
c	  
      iicase=icase-10
      go to (351,9002),iicase
c	  
  351 fac= fac*f02alt
      facpq= 0.d0
      go to 95
c
c
  700 enn=c(mm,mes)
      rcut=c(mm+1,mes)
      xx=(xl/rcut)**(2.d0*enn)
      if (xx.ne.xx7) then
      xx7=xx
         if(xx.ge.0.1d0) then
            cut7=1.d0-dexp(-xx)
            else
            cut7=oneme(xx)
         endif
      endif
      fac=fac*cut7
      facpq=0.d0
      go to 95
c
  800 enn=c(mm,mes)
      rcut=c(mm+1,mes)
      xx=(xl/rcut)**2.d0
      if (enn.ne.enn8.or.xx.ne.xx8) then
      enn8=enn
      xx8=xx
         if(xx.ge.0.1d0) then
            cut8=(1.d0-dexp(-xx))**enn
            else
            cut8=(oneme(xx))**enn
         endif
      endif
      fac=fac*cut8
      facpq=0.d0
      go to 95
c
 1300 fac=fac*c(mm,mes)/xr4
     1   *((1.d0+2.d0*ga2*(5.d0+2.d0*xrc2)
     2   -ga4*(23.d0+12.d0*xrc2))*dbesk1(xrcd)
     3   +xrc*(1.d0+10.d0*ga2-ga4*(23.d0+4.d0*xrc2))
     4   *dbesk0(xrcd))
      facpq=0.d0
      go to 95
c
 1400 go to (1410,1420),icase
 1410 fac=fac*c(mm,mes)/xr4
     1   *(3.d0*xrc*dbesk0(xrcd)
     2   +(3.d0+2.d0*xrc2)*dbesk1(xrcd))
      facpq=0.d0
      go to 95
c
 1420 fac=fac*c(mm,mes)/xr4
     1   *(-12.d0*xrc*dbesk0(xrcd)
     2   -(15.d0+4.d0*xrc2)*dbesk1(xrcd))
      facpq=0.d0
      go to 95
c
 1500 fac=fac*c(mm,mes)*yukx2/xr6
     1   *((2.d0*cb1+3.d0*ga2/(16.d0*wn))*xrc2*xrcp1s
     2   +ga2*xrc5/(32.d0*wn)
     3   +(cb3+3.d0*ga2/(16.d0*wn))
     4   *(6.d0+12.d0*xrc+10.d0*xrc2+4.d0*xrc3+xrc4))
      facpq=0.d0
      go to 95
c
 1600 fac=fac*c(mm,mes)*yukx2/xr5
     1   *(2.d0*(3.d0*ga2-2.d0)
     2   *(6.d0*xrci+12.d0+10.d0*xrc+4.d0*xrc2+xrc3)
     3   +ga2*xrc*(2.d0+4.d0*xrc+2.d0*xrc2+3.d0*xrc3))
      facpq=0.d0
      go to 95
c
 1700 go to (1710,1720),icase
 1710 fac=fac*c(mm,mes)*yukx2/xr5
     1   *(6.d0*xrci+12.d0+11.d0*xrc+6.d0*xrc2+2.d0*xrc3)
      facpq=0.d0
      go to 95
c
 1720 fac=fac*c(mm,mes)*yukx2/xr5
     2   *(12.d0*xrci+24.d0+20.d0*xrc+9.d0*xrc2+2.d0*xrc3)
      facpq=0.d0
      go to 95
c
 1800 go to (1810,1820),icase
 1810 fac=fac*c(mm,mes)*yukx2/xr6
     1   *((cb4+1.d0/(4.d0*wn))
     2   *xrcp1*(3.d0+3.d0*xrc+2.d0*xrc2)
     3   -ga2/(16.d0*wn)
     4   *(18.d0+36.d0*xrc+31.d0*xrc2+14.d0*xrc3+2.d0*xrc4))
      facpq=0.d0
      go to 95
c
 1820 fac=fac*c(mm,mes)*yukx2/xr6
     1   *(-(cb4+1.d0/(4.d0*wn))*xrcp1*(3.d0+3.d0*xrc+xrc2)
     2   +ga2/(32.d0*wn)
     3   *(36.d0+72.d0*xrc+52.d0*xrc2+17.d0*xrc3+2.d0*xrc4))
      facpq=0.d0
      go to 95
c
 1900 fac=fac*c(mm,mes)*yukx2/xr6
     1   *xrcp1
     2   *(2.d0+2.d0*xrc+xrc2)
      facpq=0.d0
      go to 95
c
 2000 fac=fac*c(mm,mes)*yukx2/xr6
     1   *xrcp1s
      facpq=0.d0
      go to 95
c
 2500 fac=fac*c(mm,mes)*yukx2/xr6
     1   *((2.d0*cb1)*xrc2*xrcp1s
     2   +(cb3)
     3   *(6.d0+12.d0*xrc+10.d0*xrc2+4.d0*xrc3+xrc4))
      facpq=0.d0
      go to 95
c
 2600 fac=fac*c(mm,mes)*yukx2/xr6
     1   *((3.d0*ga2/(16.d0*wn))*xrc2*xrcp1s
     2   +ga2*xrc5/(32.d0*wn)
     3   +(3.d0*ga2/(16.d0*wn))
     4   *(6.d0+12.d0*xrc+10.d0*xrc2+4.d0*xrc3+xrc4))
      facpq=0.d0
      go to 95
c
 2800 go to (2810,2820),icase
 2810 fac=fac*c(mm,mes)*yukx2/xr6
     1   *((cb4)
     2   *xrcp1*(3.d0+3.d0*xrc+2.d0*xrc2))
      facpq=0.d0
      go to 95
c
 2820 fac=fac*c(mm,mes)*yukx2/xr6
     1   *(-(cb4)*xrcp1*(3.d0+3.d0*xrc+xrc2))
      facpq=0.d0
      go to 95
c
 2900 go to (2910,2920),icase
 2910 fac=fac*c(mm,mes)*yukx2/xr6
     1   *((1.d0/(4.d0*wn))
     2   *xrcp1*(3.d0+3.d0*xrc+2.d0*xrc2)
     3   -ga2/(16.d0*wn)
     4   *(18.d0+36.d0*xrc+31.d0*xrc2+14.d0*xrc3+2.d0*xrc4))
      facpq=0.d0
      go to 95
c
 2920 fac=fac*c(mm,mes)*yukx2/xr6
     1   *(-(1.d0/(4.d0*wn))*xrcp1*(3.d0+3.d0*xrc+xrc2)
     2   +ga2/(32.d0*wn)
     3   *(36.d0+72.d0*xrc+52.d0*xrc2+17.d0*xrc3+2.d0*xrc4))
      facpq=0.d0
      go to 95
c
 3000 fac=fac*c(mm,mes)*(1.d0/xrc5)*((3.d0*cb2*cb2+20.d0*cb2*cb3
     1    +60.d0*cb3*cb3+4.d0*(2.d0*cb1+cb3)**2*xrc2)*xrc*dbesk1(xrcd)
     2	  +2.d0*(3.d0*cb2*cb2+20.d0*cb2*cb3+60.d0*cb3*cb3
     3	  +2.d0*(2.d0*cb1+cb3)*(cb2+6.d0*cb3)*xrc2)*dbesk2(xrcd))
      facpq=0.d0
      go to 95
c
 3100 go to (3110,3120),icase
 3110 fac=fac*c(mm,mes)*(1.d0/xrc4)*(2.d0*xrc*dbesk2(xrcd)
     1    +5.d0*dbesk3(xrcd))
      facpq=0.d0
      go to 95
c
 3120 fac=fac*c(mm,mes)*(1.d0/xrc5)*((3.d0+4.d0*xrc2)*dbesk2(xrcd)
     1    +16.d0*xrc*dbesk3(xrcd))
      facpq=0.d0
      go to 95
c 
 3200 fac=fac*c(mm,mes)*(1.d0/xrc5)*(dbesk2(xrcd)
     1    +2.d0*xrc*dbesk3(xrcd))
      facpq=0.d0
      go to 95
c
c
 3300 continue
      if (.not.indmu.or.cc4mu.ne.c4) go to 70
c
      aintmu=0.d0
      do 3305 ii=1,nmu
c
      if (ind33) go to 3304
c
      c42=c4*c4
      radi=amu2(ii)-4.d0*c42
      root=dsqrt(radi)
      term1=4.d0*c42*(5.d0*ga4-4.d0*ga2-1.d0)
      term2=-amu2(ii)*(23.d0*ga4-10.d0*ga2-1.d0)
      term3=-48.d0*ga4*c42*c42/radi
c
      aint33(ii)=root*(term1+term2+term3)*wmu(ii)
c
 3304 continue
      aintmu=aintmu
     1      +aint33(ii)*dexp(-amu(ii)*xr)
 3305 continue
c
      ind33=.true.
c
      fac=fac*c(mm,mes)*aintmu/xr
      facpq=0.d0
      go to 95
c
c
 3400 go to (3410,3420),icase
 3410 if (.not.indmu.or.cc4mu.ne.c4) go to 70
c
      aintmu=0.d0
      do 3415 ii=1,nmu
c
      if (ind341) go to 3414
c
      c42=c4*c4
      radi=amu2(ii)-4.d0*c42
      root=dsqrt(radi)
      aint341(ii)=amu2(ii)*root*wmu(ii)
c
 3414 continue
      amur=amu(ii)*xr
      aintmu=aintmu
     1      +aint341(ii)*dexp(-amur)
 3415 continue
c
      ind341=.true.
c
      fac=fac*c(mm,mes)*aintmu/xr
      facpq=0.d0
      go to 95
c
c
 3420 if (.not.indmu.or.cc4mu.ne.c4) go to 70
c
      aintmu=0.d0
      do 3425 ii=1,nmu
c
      if (ind342) go to 3424
c
      c42=c4*c4
      radi=amu2(ii)-4.d0*c42
      root=dsqrt(radi)
      aint342(ii)=root*wmu(ii)
c
 3424 continue
      amur=amu(ii)*xr
      aintmu=aintmu
     1      +aint342(ii)*dexp(-amur)
     2      *(3.d0+3.d0*amur+amur*amur)
 3425 continue
c
      ind342=.true.
c
      fac=fac*c(mm,mes)*aintmu/xr3
      facpq=0.d0
      go to 95
c
c
 3500 fac=fac*c(mm,mes)*(yukx2/xr6
     1   *((2.d0*cb1)*xrc2*xrcp1s
     2   +(cb3)
     3   *(6.d0+12.d0*xrc+10.d0*xrc2+4.d0*xrc3+xrc4))
     4   -0.25d0*yuky/xr6
     5   *((4.d0*cb1)*xrc2*(2.d0+yrc*(2.d0+yrc)-2.d0*xrc2)
     6   +(cb3)
     7   *(24.d0+yrc*(24.d0+12.d0*yrc+4.d0*yrc2+yrc3)
     8   -4.d0*xrc2*(2.d0+2.d0*yrc+yrc2)+4.d0*xrc4)))
      facpq=0.d0
      go to 95
c
 3600 go to (3610,3620),icase
 3610 fac=fac*c(mm,mes)*(1.d0/xrc5)*((5.d0+25.d0*ga2+4.d0*ga2*xrc2)
     1    *xrc*dbesk1(xrcd)+2.d0*(5.d0+25.d0*ga2+(1.d0+8.d0*ga2)
     2    *xrc2)*dbesk2(xrcd))
      facpq=0.d0
      go to 95
c
 3620 fac=fac*c(mm,mes)*(1.d0/xrc5)*((1.d0+6.d0*ga2)*2.d0*xrc
     1    *dbesk1(xrcd)+(5.d0+25.d0*ga2+4.d0*ga2*xrc2)*dbesk2(xrcd))
      facpq=0.d0
      go to 95
c
 3700 go to (3710,3720),icase
 3710 fac=fac*c(mm,mes)*(1.d0/xrc5)*((5.d0-35.d0*ga2-4.d0*ga2*xrc2)*xrc
     1     *dbesk1(xrcd)+2.d0*(5.d0*(1.d0-7.d0*ga2)+(1.d0-10.d0*ga2)
     2     *xrc2)*dbesk2(xrcd))
      facpq=0.d0
      go to 95
c
 3720 fac=fac*c(mm,mes)*(1.d0/xrc5)*(2.d0*(-8.d0+59.d0*ga2+4.d0
     1    *ga2*xrc2)*xrc*dbesk1(xrcd)-(35.d0*(1.d0-7.d0*ga2)+4.d0*
     2       (1.d0-13.d0*ga2)*xrc2)*dbesk2(xrcd))
      facpq=0.d0
      go to 95
c
 3800 go to (3810,3820),icase
 3810 fac=fac*c(mm,mes)*(yukx2/xr6
     1   *((cb4)
     2   *xrcp1*(3.d0+3.d0*xrc+2.d0*xrc2))
     3   -0.125*yuky/xr6
     4   *(cb4)
     5   *(24.d0+24.d0*yrc+12.d0*yrc2+4.d0*yrc3
     6   +yrc4-4.d0*xrc2*(2.d0+2.d0*yrc+yrc2)))
      facpq=0.d0
      go to 95
c
 3820 fac=fac*c(mm,mes)*(yukx2/xr6
     1   *(-(cb4)*xrcp1*(3.d0+3.d0*xrc+xrc2))
     2   +0.0625d0*yuky/xr6
     3   *(cb4)*(48.d0+48.d0*yrc+24.d0*yrc2+7.d0*yrc3
     4   +yrc4-4.d0*xrc2*(8.d0+5.d0*yrc+yrc2)))
      facpq=0.d0
      go to 95
c 
 3900 fac=fac*c(mm,mes)*(1.d0/xrc6)*((20.d0*(cb2-6.d0*cb3)-4.d0
     1    *(6.d0*cb1-cb2+9.d0*cb3)*xrc2-2.d0*(2.d0*cb1+cb3)*xrc4)
     2    *xrc*dbesk0(xrcd)+(20.d0*(cb2-6.d0*cb3)-2.d0*(12.d0*cb1
     3    -7.d0*cb2+48.d0*cb3)*xrc2-(16.d0*cb1-cb2+10.d0*cb3)*xrc4)
     4    *dbesk1(xrcd))
      facpq=0.d0
      go to 95
c
 4000 go to (4010,4020),icase
 4010 fac=fac*c(mm,mes)*yukx2/xrc6*(24.d0+48.d0*xrc
     1   +43.d0*xrc2+22.d0*xrc3+7.d0*xrc4+4.d0*ga2*
     2   (6.d0+12.d0*xrc+10.d0*xrc2+4.d0*xrc3+xrc4))
      facpq=0.d0
      go to 95
c
 4020 fac= fac*c(mm,mes)*yukx2/xrc7*((120.d0+ 240.d0*xrc+213.d0*xrc2
     1	   +106.d0*xrc3+ 32.d0*xrc4+8.d0*xrc5)*
     2     (dlog(4.d0*xrc)+gammae)-(120.d0- 240.d0*xrc   
     3	   + 213.d0*xrc2- 106.d0*xrc3+ 32.d0*xrc4-8.d0*xrc5)*yukx4
     4	    *eix(-4.d0*xrc)-4.d0*xrc*(96.d0+72.d0*xrc+38.d0*xrc2
     5       +7.d0*xrc3))-2.d0*fac*c(mm,mes)*(aibarm1(xrcd))/xrc
      facpq=0.d0
      go to 95
c
 4100 go to (4110,4120,4130),icase
 4110 fac=fac*c(mm,mes)*(yukx2/xrc7)*((15.d0+30.d0*xrc+24.d0*xrc2
     1    +8.d0*xrc3)*(dlog(xrcq)+gammae)+(-15.d0+30.d0*xrc-24.d0*xrc2
     2    +8.d0*xrc3)*yukx4*eix(-xrcq)-4.d0*xrc*(15.d0+15.d0*xrc
     3    +8.d0*xrc2+2.d0*xrc3)-8.d0*ga2*xrc*(3.d0+6.d0*xrc+5.d0*xrc2
     4    +2.d0*xrc3))
      facpq=0.d0
      go to 95
c
 4120 fac=fac*c(mm,mes)*(yukx2/xrc6)*(3.d0+6.d0*xrc+4.d0*xrc2+xrc3)
      facpq=0.d0
      go to 95
c 
 4130 fac=fac*c(mm,mes)*(yukx2/xrc7)*(-324.d0*xrc-228.d0*xrc2-48.d0
     1    *xrc3+5.d0*(21.d0+42.d0*xrc+30.d0*xrc2+4.d0*xrc3)*(dlog(xrcq)
     2     +gammae)+5.d0*yukx4*eix(-xrcq)*(-21.d0+42.d0*xrc-30.d0*xrc2
     3    +4.d0*xrc3))+24.d0*fac*c(mm,mes)*(1.d0/xrc3)
     4    *aibarm1(xrcd)
      facpq=0.d0
      go to 95
c
 4200 go to (4210,4220),icase
 4210 fac=fac*c(mm,mes)*(1.d0/xrc4)*(2.d0*xrc*dbesk2(xrcd)+5.d0
     1       *dbesk3(xrcd))
      facpq=0.d0
      go to 95
c
 4220 fac=fac*c(mm,mes)*(1.d0/xrc5)*((3.d0+4.d0*xrc2)*dbesk2(xrcd)
     1     +16.d0*xrc*dbesk3(xrcd))
      facpq=0.d0
      go to 95
c
 4300 go to (4310,4320,4330,4340),icase
 4310 fac=fac*c(mm,mes)*(1.d0/xrc7)*((30.d0+89.d0*xrc2-8.d0*xrc4
     1    +ga2*(300.d0+926.d0*xrc2-32.d0*xrc4)+ga4*(750.d0+2405.d0
     2	  *xrc2+76.d0*xrc4))*dbesk0(xrcd)+(137.d0+8.d0*xrc2+8.d0*xrc4+
     3       2.d0*ga2*(685.d0+106.d0*xrc2+16.d0*xrc4)+ga4*(3425.d0
     4      +860.d0*xrc2+32.d0*xrc4))*xrc*dbesk1(xrcd))-16.d0*
     5      fac*c(mm,mes)*(1.d0+2.d0*ga2)**2*
     6      (aitilm1(xrcd)/xrc)
      facpq=0.d0
      go to 95
c 
 4320 fac=fac*c(mm,mes)*(-((2.d0*ga2*xrc*dbesk1(xrcd)+(1.d0+5.d0*ga2)
     1    *dbesk2(xrcd))/xrc3)*2.d0*cd5+(((5.d0+ga2*(25.d0+2.d0*xrc2))
     2    *xrc*dbesk1(xrcd)+(10.d0+xrc2+ga2*(50.d0+11.d0*xrc2))
     3    *dbesk2(xrcd))/xrc5)*cd12)
      facpq=0.d0
      go to 95
c 
 4330 fac=fac*c(mm,mes)*(1.d0/xrc5)*((25.d0+ga2*(190.d0-4.d0*xrc2)
     1    +ga4*(325.d0+4.d0
     2    *xrc2))*xrc*dbesk1(xrcd)+2.d0*(25.d0-xrc2+ga2*(190.d0+11.d0
     3    *xrc2)+ga4*(325.d0+44.d0*xrc2))*dbesk2(xrcd))
      facpq=0.d0
      go to 95
c
 4340 fac=fac*c(mm,mes)*((2.d0*ga2*xrc*dbesk2(xrcd)+(3.d0+7.d0*ga2)
     1    *dbesk3(xrcd))*cd3/xrc4)
      facpq=0.d0
      go to 95
c
 5100 fac=fac*c(mm,mes)*(yukx2/xr6)*(24.d0+48.d0*xrc+46.d0*xrc2
     1    +28.d0*xrc3+10.d0*xrc4+xrc5)
      facpq=0.d0
      go to 95
c
 5200 fac=fac*c(mm,mes)*(yukx2/xr6)*(ga2*(48.d0+96.d0*xrc+82.d0*xrc2
     1    +36.d0*xrc3+10.d0*xrc4+3.d0*xrc5)-4.d0*(6.d0+12.d0*xrc
     2    +10.d0*xrc2+4.d0*xrc3+xrc4))
      facpq=0.d0
      go to 95
c
 5300 go to (5310,5320),icase
 5310 fac=fac*c(mm,mes)*(yukx2/xr6)*(24.d0+48.d0*xrc+43.d0*xrc2
     1    +22.d0*xrc3+6.d0*xrc4)
      facpq=0.d0
      go to 95
c
 5320 fac=fac*c(mm,mes)*(yukx2/xr6)*(96.d0+192.d0*xrc+152.d0*xrc2
     1    +62.d0*xrc3+12.d0*xrc4)
      facpq=0.d0
      go to 95
c 
 5400 go to (5410,5420),icase
 5410 fac=fac*c(mm,mes)*(yukx2/xr6)*(2.d0*ga2*(2.d0+xrc)*(6.d0
     1    +9.d0*xrc+6.d0*xrc2+2.d0*xrc3)-8.d0*(1.d0+xrc)*(3.d0
     2    +3.d0*xrc+2.d0*xrc2))
      facpq=0.d0
      go to 95
c
 5420 fac=fac*c(mm,mes)*(yukx2/xr6)*(2.d0*ga2*(2.d0+xrc)*(12.d0
     1    +18.d0*xrc+9.d0*xrc2+2.d0*xrc3)-16.d0*(1.d0+xrc)*(3.d0
     2    +3.d0*xrc+xrc2))
      facpq=0.d0
      go to 95
c
c
 8000 continue
c
c
c
c
c        multiply with functions and factors
c        -----------------------------------
c
      if (facpq.eq.0.d0) facpqp=0.d0
c
      do 8005 k=1,5
c
      vv(k) = vv(k) * fac
      pq(k) = pq(k) * facpq
      pqp(k) = pqp(k) * facpqp
c
c
c        multiply by iso-spin factors
c        ----------------------------
c        ----------------------------
c
      if (mes.le.4) then
c
c        the first two contributions must always be pi_0 exchange
c        --------------------------------------------------------
c
      if (mes.le.2) then
      vv(k)=-vv(k)
c
c        contributions 3 and 4 must always be pi_+/- exchange
c        ----------------------------------------------------
c
      else
         if (mod(iq(4),2).eq.0) then
c
c           j is even
            if (k.eq.2) then
            vv(k)=-2.d0*vv(k)
            else
            vv(k)=2.d0*vv(k)
            end if
         else
c
c           j is odd
            if (k.ne.2) then
            vv(k)=-2.d0*vv(k)
            else
            vv(k)=2.d0*vv(k)
            end if
         end if
      end if
c
c
      else
c
c
c        other contributions
c        -------------------
c
      if (indt(mes)) then
         if (mod(iq(4),2).eq.0) then
c
c           j is even
            if (k.eq.2) then
            vv(k)=-3.d0*vv(k)
            pq(k)=-3.d0*pq(k)
            pqp(k)=-3.d0*pqp(k)
            end if
         else
c
c           j is odd
            if (k.ne.2) then
            vv(k)=-3.d0*vv(k)
            pq(k)=-3.d0*pq(k)
            pqp(k)=-3.d0*pqp(k)
            end if
         end if
      end if
      end if
 8005 continue
c
c
      do 8015 k=1,5
      vj(k) = vj(k) + vv(k)
      pqj(k) = pqj(k) + pq(k)
 8015 pqpj(k) = pqpj(k) + pqp(k)
c
c
 8500 continue
c
c
c        restore for classical common block /cpotr1/
c
      do 8505 k=1,ndo
      vh(k)=vj(mlauf+k-1)
      if ((mlauf+k-1).gt.4) go to 8505
      pquad(1)=pqj(mlauf+k-1)
      pquad(2)=pqpj(mlauf+k-1)
 8505 continue
c
c
      return
c
c
c
c
c         more errors and warnings
c         ------------------------
c
c
 9002 write (kwrite,19002) itype,icase
19002 format (/////' error in chrnn:  cut/fun type',i5   ,'  and icase',
     1i5,' does not exist in this program.'/' execution terminated.'
     2////)
c
      stop
      end
c
c
      subroutine chrpar
c
c
c        chrpar reads, writes and stores the parameters for chrnn
c
c
      implicit real*8(a-h,o-z)
c
      common /readw/kwrite,kpunch,kread1,kread2
      common /cchr/c(20,300),wn,tlamb,ga,fpi,
     1            cb1,cb2,cb3,cb4,cd12,cd3,cd5,cd145,
     2            ic(20,300),mgg(300),ime,
     3            indt(300)
c
      logical indt
      dimension cc(4),cca(4)
      integer name(3),nname(15)
      integer ioper(24)/'c   ','ss  ','ls  ','ls2 ','s12 ',
     1'c00 ','c01 ','c10 ','c11 ',
     2'ls0 ','ls1 ','ls20','ls21','s120','s121',
     3'c0  ','c1  ',
     4'l2  ','l2ss','l200','l201','l210','l211','    '/
      integer end/'end '/
      integer cut/'cut '/,cuta/'cuta'/,fun/'fun '/
      logical indca
      logical index/.false./
c
      data hbarc/197.32698d0/
      data pi/3.141592653589793d0/
c
c
c
c
10000 format (2a4,a2,15a4)
10001 format (//' chrnn: chiral nucleon-nucleon potential in r-space')
10002 format (' ',50(1h-))
10003 format (' input-parameter-set:'/' ',20(1h-))
10004 format (' contribution  par_1   par_2       mass    iso-spin')
10006 format (' ',2a4,a2,f12.8,f10.6,1x,f10.5,f7.1)
10007 format (' ',2a4,a2,f4.1,1x,2f10.5,f13.5)
10010 format (2a4,a2,4f10.8)
10020 format (' ',2a4,a2,15a4)
10021 format (' ',2a4,a2,4f10.6)
10022 format (' ',2a4,a2,f10.4,f10.2)
c
c
c
c
      if (index) go to 50
      index=.true.
c
c
      ime=0
      imee=300
      ile=20
      mge=24
c
c         set all parameters and indices to zero or .false.
c
      do 1 imm=1,imee
      mgg(imm)=0
      indt(imm)=.false.
c
      do 1 il=1,ile
      c(il,imm)=0.d0
    1 ic(il,imm)=0
c
      indca=.false.
c
      sqrpi=dsqrt(pi)
      pi2=pi*pi
      pi3=pi2*pi
      pi4=pi3*pi
      pi5=pi4*pi
      pi32=dsqrt(pi3)
c
c
c
c         headline
c
   50 write (kwrite,10001)
      write (kwrite,10002)
      write (kwrite,10003)
c
      read  (kread1,10000) name,nname
      write (kwrite,10020) name,nname
      read  (kread1,10010) name,wn,tlamb
      write (kwrite,10022) name,wn,tlamb
c
c         read and write ga and fpi
c
      read (kread1,10010) name,ga,fpi
      write (kwrite,10021) name,ga,fpi
c
      ga2 = ga * ga
      ga4 = ga2 * ga2
      fpi2 = fpi * fpi
      fpi4 = fpi2 * fpi2
      fpi6 = fpi4 * fpi2

c      dbesk2=dbesk0(xrcd)+2.d0*dbesk1(xrcd)/xrcd
c      dbesk3= dbesk1(xrcd)+(4.d0/xrcd)*dbesk2
c
c      dbesk3=(4.d0/xrcd)*dbesk0(xrcd)+(8.d0/(xrcd*xrcd)+1.d0)
c     1        *dbesk1(xrcd)
c
c         read and write LECs of the pi-N Lagrangian
c
c         the c_i LECs
      read (kread1,10010) name,cc
      write (kwrite,10021) name,cc
      cb1=cc(1)*1.d-3
      cb2=cc(2)*1.d-3
      cb3=cc(3)*1.d-3
      cb4=cc(4)*1.d-3
c
c         the d_i LECs
      read (kread1,10010) name,cc
      write (kwrite,10021) name,cc
      cd12=cc(1)*1.d-6
      cd3=cc(2)*1.d-6
      cd5=cc(3)*1.d-6
      cd145=cc(4)*1.d-6
c
      write (kwrite,10004)
      write (kwrite,10002)
c
c
c
c
c         read, write and store parameters
c         --------------------------------
c         --------------------------------
c
c
c
   61 read  (kread1,10010) name,cc
c
c         check if data card just read contains cutoff or function parameters
c
      if (name(1).eq.cut.or.name(1).eq.fun) go to 70
c
c         check if end of mesons
c
      if (name(1).eq.end) go to 8500
c
c         check if there is a 'cutall'
c
      if (name(1).eq.cuta) then
      write (kwrite,10007) name,cc
      indca=.true.
      do i=1,4
      cca(i)=cc(i)
      end do
      go to 61
      end if
c
c
c
c        write parameters which are no cutoff or function parameters
c        -----------------------------------------------------------
c
c
      write (kwrite,10006) name,cc
c
c
c        find out type of contribution
c
      do 63 mg=1,mge
      if (name(1).eq.ioper(mg)) go to 64
   63 continue
      go to 9000
c
c
c
c         store contribution parameters which are no cutoff or
c         ----------------------------------------------------
c         function parameters
c         -------------------
c
   64 ime=ime+1
      if (ime.gt.imee) go to 9011
      mgg(ime)=mg
c         store coupling constant
      c(1,ime)=cc(1)
      if (cc(2).ne.0.d0) then
      c(1,ime)=(cc(1)/cc(2))**2
      end if
c         store meson mass
      c(4,ime)=cc(3)
c         test iso-spin
      icc=cc(4)
c         test isospin
      if (icc.lt.0.or.icc.gt.1) go to 9004
      if (icc.eq.1) indt(ime)=.true.
      mi=1
      mm=5
c
c        check if there is a `cutall' cutoff
c
      if (indca) then
      do i=1,4
      cc(i)=cca(i)
      end do
      go to 72
      else
      go to 61
      end if
c
c
c
c         write cutoff or function parameters
c         -----------------------------------
c
c
   70 write (kwrite,10007) name,cc
   72 continue
c
c
c
c
c          store cutoff or function parameters
c          -----------------------------------
c
      itype=cc(1)
      if (itype.eq.0) go to 8000
      if (itype.lt.0.or.itype.gt.54) go to 9002
      ic(mi,ime)=itype
      icase=cc(2)
      ic(mi+1,ime)=icase
      c4=c(4,ime)
      c47=c4*c4*c4*c4*c4*c4*c4
c
c
      go to (100,200,300,9002,9002,9002,700,800,9002,9002,
     1 9002,9002,1300,1400,1500,1600,1700,1800,1900,2000,
     2 9002,9002,9002,9002,2500,2600,9002,2800,2900,3000,
     3 3100,3200,3300,3400,3500,3600,3700,3800,3900,4000,
     4 4100,4200,4300,9002,9002,9002,9002,9002,9002,9002,
     5 5100,5200,5300,5400),itype
c
c
c        for 1PE
c        -------
  100 c(mm,ime)=c4*c4/(48.d0*pi)
      go to 95
c
c        for 1PE
c        -------
  200 c(mm,ime)=1.d0/(48.d0*pi)
      go to 95
c
c
c
  300 c(mm+1,ime)=cc(4)
      nexp=cc(3)
      ic(mi+2,ime)=nexp
      if (nexp.lt.1.or.nexp.gt.2) go to 9003
      go to (320,340),nexp
  320 if (icase.lt.1.or.icase.gt.18) go to 9002
      go to (321,322,9002,9002,325,326,327,9002,9002,9002,
     1        331,332,333,334,335,336,337,338),icase
c
  321 c(mm,ime)=1.d0
      go to 95
c
  322 c(mm,ime)=1.d0
      go to 95
c
  325 c(mm,ime)=1.d0
      go to 95
c
  326 c(mm,ime)=1.d0
      go to 95
c
  327 c(mm,ime)=1.d0
      go to 95
c
  331 c(mm,ime)=hbarc/pi32
      go to 95
  332 c(mm,ime)=hbarc/pi32
      go to 95
  333 c(mm,ime)=hbarc/pi32
      go to 95
  334 c(mm,ime)=hbarc/pi32
      go to 95
  335 c(mm,ime)=hbarc/pi32
      go to 95
  336 c(mm,ime)=hbarc/pi32
      go to 95
  337 c(mm,ime)=hbarc/pi32
      go to 95
  338 c(mm,ime)=hbarc/pi32
      go to 95
c
c
  340 if (icase.lt.1.or.icase.gt.11) go to 9002
      go to (341,342,9002,9002,345,346,347,9002,9002,9002,
     1       351),icase
c
  341 c(mm,ime)=1.d0
      go to 95
c
  342 c(mm,ime)=1.d0
      go to 95
c
  345 c(mm,ime)=1.d0
      go to 95
c
  346 c(mm,ime)=1.d0
      go to 95
c
  347 c(mm,ime)=1.d0
      go to 95
c
  351 c(mm,ime)=1.d0
      go to 95
c
c
  700 c(mm,ime)=cc(3)
      c(mm+1,ime)=cc(4)
      go to 95
c
  800 c(mm,ime)=cc(3)
      c(mm+1,ime)=cc(4)
      go to 95
c
 1300 c(mm,ime)=c4/(128.d0*pi3*fpi4)
      go to 95
c
 1400 if (icase.lt.1.or.icase.gt.2) go to 9002
      go to (1410,1420),icase
 1410 c(mm,ime)=ga4*c4/(32.d0*pi3*fpi4)
      go to 95
c
 1420 c(mm,ime)=ga4*c4/(128.d0*pi3*fpi4)
      go to 95
c
 1500 c(mm,ime)=3.d0*ga2/(32.d0*pi2*fpi4)
      go to 95
c
 1600 c(mm,ime)=c4*ga2/(512.d0*pi2*fpi4*wn)
      go to 95
c
 1700 if (icase.lt.1.or.icase.gt.2) go to 9002
      go to (1710,1720),icase
 1710 c(mm,ime)=-3.d0*ga4*c4/(512.d0*pi2*fpi4*wn)
      go to 95
c
 1720 c(mm,ime)=3.d0*ga4*c4/(1024.d0*pi2*fpi4*wn)
      go to 95
c
 1800 if (icase.lt.1.or.icase.gt.2) go to 9002
      go to (1810,1820),icase
 1810 c(mm,ime)=ga2/(48.d0*pi2*fpi4)
      go to 95
c
 1820 c(mm,ime)=ga2/(48.d0*pi2*fpi4)
      go to 95
c
 1900 c(mm,ime)=-3.d0*ga4/(64.d0*pi2*wn*fpi4)
      go to 95
c
 2000 c(mm,ime)=ga2*(ga2-1.d0)/(32.d0*pi2*wn*fpi4)
      go to 95
c
 2500 c(mm,ime)=3.d0*ga2/(32.d0*pi2*fpi4)
      go to 95
c
 2600 c(mm,ime)=3.d0*ga2/(32.d0*pi2*fpi4)
      go to 95
c
 2800 if (icase.lt.1.or.icase.gt.2) go to 9002
      go to (2810,2820),icase
 2810 c(mm,ime)=ga2/(48.d0*pi2*fpi4)
      go to 95
c
 2820 c(mm,ime)=ga2/(48.d0*pi2*fpi4)
      go to 95
c
 2900 if (icase.lt.1.or.icase.gt.2) go to 9002
      go to (2910,2920),icase
 2910 c(mm,ime)=ga2/(48.d0*pi2*fpi4)
      go to 95
c
 2920 c(mm,ime)=ga2/(48.d0*pi2*fpi4)
      go to 95
c
 3000 c(mm,ime)=-3.d0*c47/(32.d0*pi3*fpi4)
      go to 95
c
 3100 if (icase.lt.1.or.icase.gt.2) go to 9002
      go to (3110,3120),icase
 3110 c(mm,ime)=cb4*cb4*c47/(24.d0*pi3*fpi4)
      go to 95
 
 3120 c(mm,ime)=-cb4*cb4*c47/(96.d0*pi3*fpi4)
      go to 95
c
 3200 c(mm,ime)=3.d0*cb2*ga2*c47/(8.d0*pi3*wn*fpi4)
      go to 95 
c
 3300 c(mm,ime)=1.d0/(768.d0*pi*fpi4*2.d0*pi2)
      go to 95
c
 3400 if (icase.lt.1.or.icase.gt.2) go to 9002
      go to (3410,3420),icase
 3410 c(mm,ime)=2.d0*3.d0*ga4/(128.d0*pi*fpi4*6.d0*pi2)
      go to 95
c
 3420 c(mm,ime)=-3.d0*ga4/(128.d0*pi*fpi4*6.d0*pi2)
      go to 95
c
 3500 c(mm,ime)=3.d0*ga2/(32.d0*pi2*fpi4)
      go to 95
c
 3600 if (icase.lt.1.or.icase.gt.2) go to 9002
      go to (3610,3620),icase
 3610 c(mm,ime)=cb4*c47/(32.d0*pi3*wn*fpi4)
      go to 95
c
 3620 c(mm,ime)=-cb4*c47/(16.d0*pi3*wn*fpi4)
      go to 95
c
 3700 if (icase.lt.1.or.icase.gt.2) go to 9002
      go to (3710,3720),icase
 3710 c(mm,ime)=cb4*c47/(48.d0*pi3*wn*fpi4)
      go to 95

 3720 c(mm,ime)=cb4*c47/(192.d0*pi3*wn*fpi4)
      go to 95
c
 3800 if (icase.lt.1.or.icase.gt.2) go to 9002
      go to (3810,3820),icase
 3810 c(mm,ime)=ga2/(48.d0*pi2*fpi4)
      go to 95
c
 3820 c(mm,ime)=ga2/(48.d0*pi2*fpi4)
      go to 95
c
 3900 c(mm,ime)=3.d0*ga2*c47/(32.d0*pi3*wn*fpi4)
      go to 95
c
 4000 if (icase.lt.1.or.icase.gt.2) go to 9002
      go to (4010,4020),icase
c 
 4010 c(mm,ime)=3.d0*c47*ga4/(2048.d0*pi3*fpi6)
      go to 95
c      
 4020 c(mm,ime)=-3.d0*ga4*c47/(8192.d0*pi3*fpi6)
      go to 95
c
 4100 if (icase.lt.1.or.icase.gt.3) go to 9002
      go to (4110,4120,4130),icase
 4110 c(mm,ime)=(c47*ga4)/(6144.d0*pi3*fpi6)
      go to 95
c 
 4120 c(mm,ime)=(c47*ga4*(1.d0+2.d0*ga2))/(1536.d0*pi3*fpi6)
      go to 95 
c
 4130 c(mm,ime)=-(c47*ga4)/(49152.d0*pi3*fpi6)
      go to 95
c
 4200 if (icase.lt.1.or.icase.gt.2) go to 9002
      go to (4210,4220),icase
 4210 c(mm,ime)=-(c47*ga2*cd145)/(8.d0*pi3*fpi4)
      go to 95
c 
 4220 c(mm,ime)=(c47*ga2*cd145)/(32.d0*pi3*fpi4)
      go to 95
c 
 4300 if (icase.lt.1.or.icase.gt.4) go to 9002
      go to (4310,4320,4330,4340),icase
 4310 c(mm,ime)=-c47/(9216.d0*pi5*fpi6)
      go to 95
c
 4320 c(mm,ime)=-c47/(8.d0*pi3*fpi4)
      go to 95
c
 4330 c(mm,ime)=c47/(9216.d0*pi5*fpi6)
      go to 95
c
 4340 c(mm,ime)=-c47/(16.d0*pi3*fpi4)
      go to 95
c
 5100 c(mm,ime)=3*ga4/(1024.d0*pi2*fpi4*wn)
      go to 95
c
 5200 c(mm,ime)=ga2/(512.d0*pi2*fpi4*wn)
      go to 95
c 
 5300 if (icase.lt.1.or.icase.gt.2) go to 9002
      go to (5310,5320),icase
 5310 c(mm,ime)=-ga4/(512.d0*pi2*fpi4*wn)
      go to 95
c
 5320 c(mm,ime)=ga4/(2048.d0*pi2*fpi4*wn)
      go to 95
c 
 5400 if (icase.lt.1.or.icase.gt.2) go to 9002
      go to (5410,5420),icase
 5410 c(mm,ime)=-ga2/(1536.d0*pi2*fpi4*wn)
      go to 95
c
 5420 c(mm,ime)=ga2/(3072.d0*pi2*fpi4*wn)
      go to 95
c
c
   95 mi=mi+3
      mm=mm+3
      if(mi.gt.ile.or.mm.gt.ile) go to 9011
 8000 continue
      go to 61
c
c
c         write end of mesons
c         -------------------
c
c
 8500 write (kwrite,10020) name
      write (kwrite,10002)
      write (kwrite,10002)
c
      return
c
c
c         errors
c         ------
c         ------
c
c
 9000 write (kwrite,19000) name(1)
19000 format(/////' error in chrpar: contribution   ',a4,'   does not
     1 exist in this program.'/' execution terminated.'////)
      go to 9999
c
c
 9002 write (kwrite,19002) cc(1),cc(2)
19002 format (/////' error in chrnn:  cut/fun type',f10.4,'  and icase',
     1f10.4,' does not exist in this program.'/' execution terminated.'
     2////)
      go to 9999
c
c
 9003 write (kwrite,19003) cc(3)
19003 format (/////' error in chrpar:   nexp  has the non-permissible
     1value',f10.4,'  .'/' execution terminated.'////)
      go to 9999
c
c
 9004 write (kwrite,19004) cc(4)
19004 format (/////' error in chrpar: isospin has the non-permissible
     1value',f10.4,'  .'/' execution terminated.'////)
      go to 9999
c
c
 9011 write (kwrite,19011)
19011 format (/////' error in chrpar: too many contributions with respec
     1t to the dimensions given'/' in this program. execution terminated
     2.'////)
      go to 9999
c
c
 9999 stop
      end
c
      subroutine omegam
c
c        AUFSTELLEN DER OPERATORMATRIX OMEGA 
c
c        The first index (k) of 
c                            omega(k,i)
c        runs from 1 to 5 and refers to the matrix elements
c        VJ/0 , VJ/1 , VJ-1/1 , VJ+1/1 , VJ-1/J+1/1          *
c        ( VJ/S=O,1 : J-ABHAENGIGER POTENTIALTERM )          *
c
c        The second index (i) runs from 1 to 23 and denotes 
c        the various operators, with
c        1   c    (central)
c        2   ss   (sigma1 dot sigma2)
c        3   ls   (spin-orbit)
c        4   ls2  (quadratic spin-orbit)
c        5   s12  (tensor)
c        6   c00   (central force times spin-0/isospin-0 projection operator)
c        7   c01
c        8   c10
c        9   c11
c        10  ls0  (spin-orbit operator times isospin-0 projection operator)
c        11  ls1
c        12  ls20 (quadratic spin-orbit times isospin-0 projection operator)
c        13  ls21
c        14  s120 (S12 tensor operator times isospin-0 projection operator)
c        15  s121
c        16  c0    (central force times spin-0 projection operator)
c        17  c1    (central force times spin-1 projection operator)
c        18  l2    (l square)
c        19  l2ss  (l square times sigma1 dot sigma2)
c        20  l200  (l square times spin-0/isospin-0 projection operator)
c        21  l201  (l square times spin-0/isospin-1 projection operator) 
c        22  l210  (l square times spin-1/isospin-0 projection operator)
c        23  l211  (l square times spin-1/isospin-1 projection operator)
c
      implicit real*8 (a-h,o-z)
      common /nquant/ omega(5,23),iq(4),mlauf,index
c
      dimension tt(5),pros0(5),pros1(5),prot0(5),prot1(5)
c
c
      x = dfloat(iq(4))
      x1 = x + 1.d0
      x2 = 2.d0 * x + 1.d0
c
c
      do 8 i=1,23
      do 8 k=1,5
    8 omega(k,i) = 0.d0
c
c        central and spin-spin operators
      do 10 i=1,2
      do 10 k=1,4
   10 omega(k,i) = 1.d0
      omega(1,2) = -3.d0
c
c        spin-orbit operator
      omega(2,3) = -1.d0
      omega(3,3) = x - 1.d0
      omega(4,3) = - ( x + 2.d0 )
c
c        ls**2 operator
      omega(2,4) = omega(2,3) * omega(2,3)
      omega(3,4) = omega(3,3) * omega(3,3)
      omega(4,4) = omega(4,3) * omega(4,3)
c
c        tensor operator
      omega(2,5) = 2.d0
      omega(3,5) = -2.d0 * omega(3,3) / x2
      omega(4,5) =  2.d0 * omega(4,3) / x2
      omega(5,5) = dsqrt(x*x1) * 6.d0 / x2
c
c
c        l**2 operator
      omega(1,18)=x*x1
      omega(2,18)=x*x1
      omega(3,18)=x*omega(3,3)
      omega(4,18)=x1*(x+2.d0)


       


  
c        spin projection operator
c        ------------------------
c
      do 25 k=1,4
      pros0(k)=(1.d0-omega(k,2))*0.25d0
   25 pros1(k)=(3.d0+omega(k,2))*0.25d0
      pros0(5)=0.d0
      pros1(5)=1.d0
c
c
c        the tau1 dot tau2 operator
c
c
      if (mod(iq(4),2).eq.0) then
c        j is even
      do 40 k=1,5
   40 tt(k)=1.d0
      tt(2)=-3.d0
      else
c        j is odd
      do 41 k=1,5
   41 tt(k)=-3.d0
      tt(2)=1.d0
      end if
c
c
c        isospin projection operator
c        ---------------------------
c
      do 55 k=1,5
      prot0(k)=(1.d0-tt(k))*0.25d0
   55 prot1(k)=(3.d0+tt(k))*0.25d0
c
c
c        combined operators
c        ------------------
c
      do 75 k=1,5
      if (k.eq.5) go to 74
      omega(k,16)=pros0(k)
      omega(k,17)=pros1(k)
      omega(k,6)=pros0(k)*prot0(k)
      omega(k,7)=pros0(k)*prot1(k)
      omega(k,8)=pros1(k)*prot0(k)
      omega(k,9)=pros1(k)*prot1(k)
      omega(k,19)=omega(k,18)*omega(k,2)
      omega(k,20)=omega(k,6)*omega(k,18)
      omega(k,21)=omega(k,7)*omega(k,18)
      omega(k,22)=omega(k,8)*omega(k,18)
      omega(k,23)=omega(k,9)*omega(k,18)
      omega(k,10)=omega(k,3)*prot0(k)
      omega(k,11)=omega(k,3)*prot1(k)
      omega(k,12)=omega(k,4)*prot0(k)
      omega(k,13)=omega(k,4)*prot1(k)
   74 omega(k,14)=omega(k,5)*prot0(k)
   75 omega(k,15)=omega(k,5)*prot1(k)
c
c
c        the case j=0
      if (iq(4).eq.0) then
      do 102 i=1,23
      omega(2,i) = 0.d0
      omega(3,i) = 0.d0
  102 omega(5,i) = 0.d0
      end if
c
c
      return
      end
c
c
c $Id: besk0.F,v 1.1.1.1 1996/02/15 17:49:09 mclareni Exp $
c
c $Log: besk0.F,v $
c Revision 1.1.1.1  1996/02/15 17:49:09  mclareni
c Kernlib
c
c
      function dbesk0(dx)
      double precision x,y,r,a,a0,a1,a2,b,b0,b1,b2,t(10)
      double precision u0,u1,u2,u3,u4,u5,u6,u7,u8,u9
      double precision f,f1,f2,f3,c,c0,pi1,ce,eps,h,alfa,d
      double precision zero,one,two,four,five,six,seven,eight,nine,half
      double precision c1(0:14),c2(0:15),c3(0:12)
      double precision dbesk0,dx
 
      data zero /0.0d0/, one /1.0d0/, two /2.0d0/
      data four /4.0d0/, five /5.0d0/, six /6.0d0/, seven /7.0d0/
      data eight /8.0d0/, nine /9.0d0/, half /0.5d0/
 
      data t /16.0d0,368.0d0,43.0d0,75.0d0,400.0d0,40.0d0,
     1        48.0d0,12.0d0,20.0d0,28.0d0/
 
      data pi1 /1.25331 41373 155d0/, ce /0.57721 56649 0153d0/
      data eps /1.0d-14/
 
      data c1( 0) /0.12773 34398 1218d3/
      data c1( 1) /0.19049 43201 7274d3/
      data c1( 2) /0.82489 03274 4024d2/
      data c1( 3) /0.22274 81924 2462d2/
      data c1( 4) /0.40116 73760 1793d1/
      data c1( 5) /0.50949 33654 3998d0/
      data c1( 6) /0.04771 87487 9817d0/
      data c1( 7) /0.00341 63317 6601d0/
      data c1( 8) /0.00019 24693 5969d0/
      data c1( 9) /0.00000 87383 1550d0/
      data c1(10) /0.00000 03260 9105d0/
      data c1(11) /0.00000 00101 6973d0/
      data c1(12) /0.00000 00002 6883d0/
      data c1(13) /0.00000 00000 0610d0/
      data c1(14) /0.00000 00000 0012d0/
 
      data c2( 0) /0.24027 70596 4072d3/
      data c2( 1) /0.36947 40739 7287d3/
      data c2( 2) /0.16997 34116 9840d3/
      data c2( 3) /0.49020 46377 7263d2/
      data c2( 4) /0.93884 97325 2684d1/
      data c2( 5) /0.12594 79763 6677d1/
      data c2( 6) /0.12377 69641 1492d0/
      data c2( 7) /0.00924 43098 6287d0/
      data c2( 8) /0.00054 06238 9649d0/
      data c2( 9) /0.00002 53737 9603d0/
      data c2(10) /0.00000 09754 7830d0/
      data c2(11) /0.00000 00312 4957d0/
      data c2(12) /0.00000 00008 4643d0/
      data c2(13) /0.00000 00000 1963d0/
      data c2(14) /0.00000 00000 0039d0/
      data c2(15) /0.00000 00000 0001d0/
 
      data c3( 0) /+0.98840 81742 3083d0/
      data c3( 1) /-0.01131 05046 4693d0/
      data c3( 2) /+0.00026 95326 1276d0/
      data c3( 3) /-0.00001 11066 8520d0/
      data c3( 4) /+0.00000 06325 7511d0/
      data c3( 5) /-0.00000 00450 4734d0/
      data c3( 6) /+0.00000 00037 9300d0/
      data c3( 7) /-0.00000 00003 6455d0/
      data c3( 8) /+0.00000 00000 3904d0/
      data c3( 9) /-0.00000 00000 0458d0/
      data c3(10) /+0.00000 00000 0058d0/
      data c3(11) /-0.00000 00000 0008d0/
      data c3(12) /+0.00000 00000 0001d0/

      round(d)  =  sngl(d+(d-dble(sngl(d))))
 
      x=dx
 
    9 if(x .le. zero) then
       print *,'dbsk0 out of range'
       stop
      endif
      if(x .lt. half) then
       y=x/eight
       h=two*y**2-one
       alfa=-two*h
       b1=zero
       b2=zero
       do 1 i = 14,0,-1
       b0=c1(i)-alfa*b1-b2
       b2=b1
    1  b1=b0
       r=b0-h*b2
       b1=zero
       b2=zero
       do 2 i = 15,0,-1
       b0=c2(i)-alfa*b1-b2
       b2=b1
    2  b1=b0
       b1=-(ce+log(half*x))*r+b0-h*b2
      else if(x .gt. five) then
       r=one/x
       y=five*r
       h=two*y-one
       alfa=-two*h
       b1=zero
       b2=zero
       do 3 i = 12,0,-1
       b0=c3(i)-alfa*b1-b2
       b2=b1
    3  b1=b0
       b1=pi1*sqrt(r)*(b0-h*b2)
       b1=exp(-x)*b1
      else
       y=(t(1)*x)**2
       a0=one
       a1=(t(1)*x+seven)/nine
       a2=(y+t(2)*x+t(3))/t(4)
       b0=one
       b1=(t(1)*x+nine)/nine
       b2=(y+t(5)*x+t(4))/t(4)
       u1=one
       u4=t(6)
       u5=t(7)
       c=zero
       f=two
    4  c0=c
       f=f+one
       u0=t(8)*f**2-one
       u1=u1+two
       u2=u1+two
       u3=u1+four
       u4=u4+t(9)
       u5=u5+t(10)
       u6=one/u3**2
       u7=u2*u6
       u8=-u7/u1
       u9=t(1)*u7*x
       f1=u9-(u0-u4)*u8
       f2=u9-(u0-u5)*u6
       f3=-u8*(u3-six)**2
       a=f1*a2+f2*a1+f3*a0
       b=f1*b2+f2*b1+f3*b0
       c=a/b
       if(abs((c0-c)/c) .ge. eps) then
        a0=a1
        a1=a2
        a2=a
        b0=b1
        b1=b2
        b2=b
        go to 4
       endif
       b1=pi1*c/sqrt(x)
       b1=exp(-x)*b1
      endif

      dbesk0=b1

      return
 
  100 format(7x,a6,' ... non-positive argument x = ',e16.6)
      end
c
c
c $Id: besk1.F,v 1.1.1.1 1996/02/15 17:49:09 mclareni Exp $
c
c $Log: besk1.F,v $
c Revision 1.1.1.1  1996/02/15 17:49:09  mclareni
c Kernlib
c
c
      function dbesk1(dx)
      double precision x,y,r,a,a0,a1,a2,b,b0,b1,b2,t(12)
      double precision u0,u1,u2,u3,u4,u5,u6,u7,u8,u9
      double precision f,f1,f2,f3,c,c0,pi1,ce,eps,h,alfa,d
      double precision zero,one,two,three,four,five,six,eight,half
      double precision c1(0:14),c2(0:14),c3(0:11)
      double precision dbesk1,dx
 
      data zero /0.0d0/, one /1.0d0/, two /2.0d0/, three /3.0d0/
      data four /4.0d0/, five /5.0d0/, six /6.0d0/, eight /8.0d0/
      data half /0.5d0/
 
      data t /16.0d0,3.2d0,2.2d0,432.0d0,131.0d0,35.0d0,336.0d0,
     1        40.0d0,48.0d0,12.0d0,20.0d0,28.0d0/
 
      data pi1 /1.25331 41373 155d0/, ce /0.57721 56649 0153d0/
      data eps /1.0d-14/
 
      data c1( 0) /0.22060 14269 2352d3/
      data c1( 1) /0.12535 42668 3715d3/
      data c1( 2) /0.42865 23409 3128d2/
      data c1( 3) /0.94530 05229 4349d1/
      data c1( 4) /0.14296 57709 0762d1/
      data c1( 5) /0.15592 42954 7626d0/
      data c1( 6) /0.01276 80490 8173d0/
      data c1( 7) /0.00081 08879 0069d0/
      data c1( 8) /0.00004 10104 6194d0/
      data c1( 9) /0.00000 16880 4220d0/
      data c1(10) /0.00000 00575 8695d0/
      data c1(11) /0.00000 00016 5345d0/
      data c1(12) /0.00000 00000 4048d0/
      data c1(13) /0.00000 00000 0085d0/
      data c1(14) /0.00000 00000 0002d0/
 
      data c2( 0) /0.41888 94461 6640d3/
      data c2( 1) /0.24989 55490 4287d3/
      data c2( 2) /0.91180 31933 8742d2/
      data c2( 3) /0.21444 99505 3962d2/
      data c2( 4) /0.34384 15392 8805d1/
      data c2( 5) /0.39484 60929 4094d0/
      data c2( 6) /0.03382 87455 2688d0/
      data c2( 7) /0.00223 57203 3417d0/
      data c2( 8) /0.00011 71310 2246d0/
      data c2( 9) /0.00000 49754 2712d0/
      data c2(10) /0.00000 01746 0493d0/
      data c2(11) /0.00000 00051 4329d0/
      data c2(12) /0.00000 00001 2890d0/
      data c2(13) /0.00000 00000 0278d0/
      data c2(14) /0.00000 00000 0005d0/
 
      data c3( 0) /+1.03595 08587 724d0/
      data c3( 1) /+0.03546 52912 433d0/
      data c3( 2) /-0.00046 84750 282d0/
      data c3( 3) /+0.00001 61850 638d0/
      data c3( 4) /-0.00000 08451 720d0/
      data c3( 5) /+0.00000 00571 322d0/
      data c3( 6) /-0.00000 00046 456d0/
      data c3( 7) /+0.00000 00004 354d0/
      data c3( 8) /-0.00000 00000 458d0/
      data c3( 9) /+0.00000 00000 053d0/
      data c3(10) /-0.00000 00000 007d0/
      data c3(11) /+0.00000 00000 001d0/

      round(d)  =  sngl(d+(d-dble(sngl(d))))
 
      x=dx
 
    9 if(x .le. zero) then
       print *,'dbesk1 out of range'
       stop
      endif
      if(x .lt. half) then
       y=x/eight
       h=two*y**2-one
       alfa=-two*h
       b1=zero
       b2=zero
       do 1 i = 14,0,-1
       b0=c1(i)-alfa*b1-b2
       b2=b1
    1  b1=b0
       r=y*(b0-b2)
       b1=zero
       b2=zero
       do 2 i = 14,0,-1
       b0=c2(i)-alfa*b1-b2
       b2=b1
    2  b1=b0
       b1=(ce+log(half*x))*r+one/x-y*(b0-b2)
      else if(x .gt. five) then
       r=one/x
       y=five*r
       h=two*y-one
       alfa=-two*h
       b1=zero
       b2=zero
       do 3 i = 11,0,-1
       b0=c3(i)-alfa*b1-b2
       b2=b1
    3  b1=b0
       b1=pi1*sqrt(r)*(b0-h*b2)
       b1=exp(-x)*b1
      else
       y=(t(1)*x)**2
       a0=one
       a1=t(2)*x+t(3)
       a2=(y+t(4)*x+t(5))/t(6)
       b0=one
       b1=t(2)*x+one
       b2=(y+t(7)*x+t(6))/t(6)
       u1=one
       u4=t(8)
       u5=t(9)
       c=zero
       f=two
    4  c0=c
       f=f+one
       u0=t(10)*f**2+three
       u1=u1+two
       u2=u1+two
       u3=u1+four
       u4=u4+t(11)
       u5=u5+t(12)
       u6=one/(u3**2-four)
       u7=u2*u6
       u8=-u7/u1
       u9=t(1)*u7*x
       f1=u9-(u0-u4)*u8
       f2=u9-(u0-u5)*u6
       f3=u8*(four-(u3-six)**2)
       a=f1*a2+f2*a1+f3*a0
       b=f1*b2+f2*b1+f3*b0
       c=a/b
       if(abs((c0-c)/c) .ge. eps) then
        a0=a1
        a1=a2
        a2=a
        b0=b1
        b1=b2
        b2=b
        go to 4
       endif
       b1=pi1*c/sqrt(x)
       b1=exp(-x)*b1
      endif

      dbesk1=b1

      return
 
      end

	function dbesk2(dx)
	   implicit real*8 (a-h, o-z)
             
	dbesk2= dbesk0(dx)+(2.d0/dx)*dbesk1(dx)
                        return
                        end

	function dbesk3(dx)
	   implicit real*8 (a-h, o-z)
             
	dbesk3= dbesk1(dx)+(4.d0/dx)*dbesk2(dx)
                        return
                        end

c
c
      function oneme(x)
c
c        oneme(x) = 1 - exp(-x)
c
c        NOTE: this code is useful only for
c              0 < x < 1.
c
c
      implicit real*8 (a-h,o-z)
c
c
      i=0
      term=1.d0
      sum0=0.d0
      sum1=1.d0
c
c
   10 i=i+1
      term=term*x/dfloat(i)
      sum0=sum0+term
      sum1=sum1+term
      if(dabs(term/sum0).gt.1.d-16) go to 10
c
c
      oneme=sum0/sum1
c
c
      return
      end
        subroutine gauss(ax,bx,n,x,w)
        implicit double precision (a-h,o-z)
        parameter(pi=3.1415926535897932d0)
        dimension x(n),w(n)

        eps = 1.d-15
        do 2 i=1,n
        z=dcos(pi*(i-.25d0)/(n+.5d0))
    1   z1=z-alegf(n,0,z,0)/alegf(n,1,z,0)*dsqrt((1.d0+z)*(1.d0-z))
        if (dabs(z1-z).gt.eps) then
        z=z1
        goto 1
        end if
        x(i) = z1 
    2   w(i) = 2.d0/(alegf(n,1,z1,0)**2)
c
c        at this point, x and w are the gauss points and weights 
c        for the interval (-1,+1); x is descending.
c
c        now, re-scale gauss points and weights for interval (ax,bx)
c        such that x is ascending.
c
      alpha=0.5d0*(ax+bx)
      beta=0.5d0*(bx-ax)
      do 3 j=1,n
      x(j)=alpha-beta*x(j)
    3 w(j)=beta*w(j)
c
        return
        end
cern	  c315	    version    05/03/68 alegf	     94 	       c
      double precision function alegf(l,m,y,norm)
c     norm = 0 , unnormalised legendre functions
c     norm = 1 , normalised legendre functions
      implicit double precision (a-h,o-z)
      ma = iabs(m)
      if (l - ma) 1,2,2
    1 alegf = 0.d0
      return
    2 if (m) 3,4,4
    3 ib = l - ma + 1
      ie = l + ma
      prod = 1.d0
      do 5 i = ib,ie
      a = i
    5 prod = prod*a
      fact = 1.0d0/prod
      go to 6
    4 fact = 1.d0
    6 mm = ma
      if (ma - 1) 7,7,8
    7 p0 = 1.0d0
      if (ma) 9,9,10
    9 p1 = y
      go to 11
   10 p0 = 0.0d0
      p1 = dsqrt(1.00 - y**2)
   11 if (l - 1) 12,13,14
   12 alegf = p0
      go to 23
   13 alegf = p1 * fact
      go to 23
   14 pnmn1 = p0
      pn = p1
      am = ma
      k = l - 1
      do 15 n = 1,k
      an = n
      pnpl1 = (1.d0/(an-am+1.d0))*((2.d0*an+1.d0)*y*pn-(an+am)*pnmn1)
      pnmn1 = pn
   15 pn = pnpl1
   16 alegf = pnpl1*fact
      go to 23
    8 z2 = (1.d0-y**2)
      am = ma
      ham = am/2.d0
      zham = z2**ham
      if (ma.eq.(l-1)) go to 17
      nb = l+1
      ne = 2*l
      prod = 1.d0
      do 18 ni = nb,ne
      ai = ni
   18 prod = prod*ai
      denom = 2.d0**l
      dnn = prod/denom
      if (ma.eq.l) go to 19
   17 ne = 2*l-1
      prod = 1.d0
      do 20 ni = l,ne
      ai = ni
   20 prod = prod*ai
      denom = 2.d0**(l-1)
      dnm1n = y*prod/denom
      if (ma.eq.(l-1)) go to 21
      me = l-1-ma
      do 22 mn = 1,me
      an = l
      am = l-1-mn
      dnm2n=(1.d0/((an-am)*(an+am+1.d0)))*
     *      (2.d0*(am+1.d0)*y*dnm1n-z2*dnn)
      dnn = dnm1n
   22 dnm1n = dnm2n
      alegf = dnm2n*zham*fact
      go to 23
   19 alegf = dnn*zham*fact
      go to 23
   21 alegf = dnm1n*zham*fact
   23 if (norm.eq.1) go to 24
      return
   24 b = l
      if (m) 25,26,25
   25 ms = -m/mm
      jb = l - mm + 1
      je = l + mm
      prod = 1.d0
      do 27 i = jb,je
      a = i
   27 prod = prod*a
      factor = 0.5d0*(2.d0*b+1.d0)*(prod**ms)
      go to 28
   26 factor = 0.5d0*(2.d0*b+1.d0)
   28 factor = dsqrt(factor)
      alegf = alegf*factor
      return
      end
	 function eix(z)
c
c        eix function
c        note: this version of eix is only valid for negative arguments.
c
	 implicit real*8 (a-h,o-z)
         dimension x(1000),w(1000)
         data pih/1.570796326794897d0/       
         logical index/.false./
c
c
         if (z.ge.0.d0) then
         write (6,20000)
20000    format (' error: function eix has a non-negative argument.'/
     1   ' execution terminated.')   
         stop
         end if
c
c
         if (index) go to 10
         index=.true.
c
         n=50 
         c=1.d0
c****    write (6,10000) n,c
10000    format (i6,f10.5)
c
         call gauss(0.d0,1.d0,n,x,w)
c
         do i=1,n
         xx=pih*x(i)
         x(i)=c*dtan(xx)
         dc=1.d0/dcos(xx)
         w(i)=c*pih*dc*dc*w(i)
         end do
c
c
   10    zz=-z
c
         aint=0.d0
         do i=1,n
         xx=x(i)+zz
         term=dexp(-xx)/xx*w(i)
         aint=aint+term
         end do
c
         eix=-aint
c
         return
         end
c
c
	 function aibarm1(z)
	 implicit real*8 (a-h,o-z)
         dimension x(1000),w(1000)
         data pih/1.570796326794897d0/                                     
         logical index/.false./
c
c
         if (index) go to 10
         index=.true.
c
         n=200
         c=0.01d0
c****    write (6,10000) n,c
10000    format (i6,f10.5)
c
         call gauss(0.d0,1.d0,n,x,w)
c
         do i=1,n
         xx=pih*x(i)
         x(i)=c*dtan(xx)+1.d0
         dc=1.d0/dcos(xx)
         w(i)=c*pih*dc*dc*w(i)
         end do
c
c
   10    aint=0.d0
         do i=1,n
         xx=x(i)
         term=dexp(-z*xx)/xx*dlog((xx+1.d0)/(xx-1.d0))*w(i)
         aint=aint+term
         end do
c
         aibarm1=aint
c
         return
         end
c
c
	 function aitilm1(z)
	 implicit real*8 (a-h,o-z)
         dimension x(1000),w(1000)
         data pih/1.570796326794897d0/                                     
         logical index/.false./
c
c
         if (index) go to 10
         index=.true.
c
         n=200
         c=1.d0
c****    write (6,10000) n,c
10000    format (i6,f10.5)
c
         call gauss(0.d0,1.d0,n,x,w)
c
         do i=1,n
         xx=pih*x(i)
         x(i)=c*dtan(xx)+1.d0
         dc=1.d0/dcos(xx)
         w(i)=c*pih*dc*dc*w(i)
         end do
c
c
   10    aint=0.d0
         do i=1,n
         xx=x(i)
         term=dexp(-z*xx)/xx*dlog(xx+dsqrt(xx*xx-1.d0))*w(i)
         aint=aint+term
         end do
c
         aitilm1=aint
c
         return
         end
