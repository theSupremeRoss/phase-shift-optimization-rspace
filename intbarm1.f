            implicit real*8 (a-h, o-z)
             dimension x(1000), w(1000)
             write *, 'put a,b,n' 
               read *, ax,bx,n
			   call gauss(ax,bx,n,x,w)
			   s=0.d0
			   do i=1,n
			   s=s+ f(x(i))* w(i)
			   end do
			   write *, 'no of interval', n  , 'result is',s
             end
              
		
			 function f(x)
             implicit real*8 (a-h, o-z)
             f=(dexp(-10*x)/x)*(alog((x+1)/(x-1)))
             end 
			   
