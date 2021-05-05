// CSE140 lab 2  
// How does this work? How long does the alarm stay on? 
// (buzz is the alarm itself)
module alarm(
  input[6:0]   tmin,
               amin,
			   thrs,
			   tdys,
			   ahrs,						 
  output logic buzz
);

  always_comb
    buzz = tmin==amin && thrs==ahrs && tdys < 5;

endmodule