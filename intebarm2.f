       	    implicit real*8 (a-h, o-z)
             dimension x(1000), w(1000), y(1000),p(1000),t(1000)
             parameter(pi=3.1415926535897932d0)
	     ax=-1
	     bx=1
	     n=400
               
			   call gauss(ax,bx,n,x,w)
			   s=0.d0
			   do i=1,n
                           y(i)=0.001*tan(pi*(x(i)+1)/4)+1.d0
			   p(i)=cos(pi*(x(i)+1)/4)
      			   t(i)=(0.001*(pi/4))*(w(i)/(p(i)*p(i)))
			   s=s+ f(y(i))* t(i)
			   end do
			   write *, 'no of interval', n  , 'result is',s
             end
              
		
			 function f(y,z)
             implicit real*8 (a-h, o-z)
	      
             f=(dexp(-z*y)/y)*(dlog((y+1)/(y-1)))
	     
             end 
			   
