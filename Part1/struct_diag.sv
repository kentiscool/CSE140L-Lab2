// CSE140L  
// see Structural Diagram in Lab2 assignment writeup
// fill in missing connections and parameters
module struct_diag(
  input Reset,
        Timeset, 	  // manual buttons
        Alarmset,	  //	(five total)
	Minadv,
	Hrsadv,
	Alarmon,
	Pulse,		  // assume 1/sec.
// 6 decimal digit display (7 segment)
  output [6:0] S1disp, S0disp, 	   // 2-digit seconds display
               M1disp, M0disp, 
               H1disp, H0disp,
  output logic Buzz
  );	           // alarm sounds
  logic[6:0] TSec, TMin, THrs,     // clock/time 
             AMin, AHrs;	    // alarm setting
  logic[6:0] Min, Hrs;		    // displayed time
  logic Szero, Mzero, Hzero, 	   // "carry out" from sec -> min, min -> hrs, hrs -> days
        TMen, THen, AMen, AHen, ShouldBuzz; 

// free-running seconds counter	-- be sure to set parameters on ct_mod_N modules
  ct_mod_N #(.N(60)) Sct(
    .clk(Pulse), .rst(Reset), .en(1'b1), .ct_out(TSec), .z(Szero)
    );
// minutes counter -- runs at either 1/sec or 1/60sec
  ct_mod_N #(.N(60)) Mct(
    .clk(Pulse), .rst(Reset), .en(TMen), .ct_out(TMin), .z(Mzero)
    );
// hours counter -- runs at either 1/sec or 1/60min
  ct_mod_N #(.N(24)) Hct(
	.clk(Pulse), .rst(Reset), .en(THen), .ct_out(THrs), .z(Hzero)
    );
// alarm set registers -- either hold or advance 1/sec
  ct_mod_N #(.N(60)) Mreg(
    .clk(Pulse), .rst(Reset), .en(AMen), .ct_out(AMin), .z()
    ); 

  ct_mod_N #(.N(24)) Hreg(
    .clk(Pulse), .rst(Reset), .en(AHen), .ct_out(AHrs), .z()
    ); 

// display drivers (2 digits each, 6 digits total)
  lcd_int Sdisp(
    .bin_in (TSec)  ,
	.Segment1  (S1disp),
	.Segment0  (S0disp)
	);

  lcd_int Mdisp(
    .bin_in (Min) ,
	.Segment1  (M1disp),
	.Segment0  (M0disp)
	);

  lcd_int Hdisp(
    .bin_in (Hrs),
	.Segment1  (H1disp),
	.Segment0  (H0disp)
	);

// buzz off :)	  make the connections
  alarm a1(
    .tmin(TMin), .amin(AMin), .thrs(THrs), .ahrs(AHrs), .buzz(ShouldBuzz)
	);
	
	always_comb begin
		if (!Reset) begin
		Buzz = ShouldBuzz && Alarmon;
	
		TMen = Szero;
		THen = Mzero && Szero;
		
		if (Timeset) begin
			if(Alarmset == 0) begin
				TMen = Minadv;
				THen = Hrsadv;

			end
		end 
				
		if (Timeset == 0)begin
			if(Alarmset) begin
				AMen = Minadv  ;
				AHen = Hrsadv  ;
			end
		end
		
		if (Alarmset) begin
			Min = AMin;
			Hrs = AHrs;
		end else begin 
			Min = TMin;
			Hrs = THrs;
		end
		end
	end

endmodule
