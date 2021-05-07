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
		Dayadv,
		Dateadv,
		Monthadv,
		Pulse,		  // assume 1/sec.
// 6 decimal digit display (7 segment)
  output [6:0] S1disp, S0disp, 	   		// 2-digit seconds display
               M1disp, M0disp, 
               H1disp, H0disp,
			   D0disp,
			   Date1disp, Date0disp,
			   Month1disp, Month0disp,
			   
  output logic Buzz
);	           // alarm sounds
  logic resetDate;
  logic[6:0] TSec, TMin, THrs, TDys, TDate, TMonth,  // clock/time 
             AMin, AHrs;	    					// alarm setting
  logic[6:0] Min, Hrs, Dys, Date, Month;		    	// displayed time
  logic Szero, Mzero, Hzero, Dayzero, DateZero, YearZero,
        TMen, THen, TDen, TDateEn, TMonthEn, AMen, AHen, 
		ShouldBuzz; 
  logic[6:0] daysInMonth = 31;

// free-running seconds counter	-- be sure to set parameters on ct_mod_N modules
	ct_mod_N Sct(
		.N(60), .clk(Pulse), .rst(Reset), .en(1'b1), .ct_out(TSec), .z(Szero)
    );
// minutes counter -- runs at either 1/sec or 1/60sec
	ct_mod_N Mct(
		.N(60), .clk(Pulse), .rst(Reset), .en(TMen), .ct_out(TMin), .z(Mzero)
    );
// hours counter -- runs at either 1/sec or 1/60min
	ct_mod_N Hct(
		.N(24), .clk(Pulse), .rst(Reset), .en(THen), .ct_out(THrs), .z(Hzero)
    );
	ct_mod_N Dct(
		.N(7), .clk(Pulse), .rst(Reset), .en(TDen), .ct_out(TDys), .z()
    );
	
	ct_mod_N Datect(
		.N(daysInMonth), .clk(Pulse), .rst(Reset), .en(TDateEn), .ct_out(TDate), .z(DateZero)
    );
	
	ct_mod_N Monthct(
		.N(12), .clk(Pulse), .rst(Reset), .en(TMonthEn), .ct_out(TMonth), .z()
    );
	
// alarm set registers -- either hold or advance 1/sec
	ct_mod_N Mreg(
		.N(60), .clk(Pulse), .rst(Reset), .en(AMen), .ct_out(AMin), .z()
    ); 

	ct_mod_N Hreg(
		.N(24), .clk(Pulse), .rst(Reset), .en(AHen), .ct_out(AHrs), .z()
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
	
  lcd_int Ddisp(
    .bin_in (Dys),
	.Segment1  (),
	.Segment0  (D0disp)
	);
	
  lcd_int Datedisp(
    .bin_in (Date + 1),
	.Segment1  (Date1disp),
	.Segment0  (Date0disp)
	);
	
  lcd_int Monthdisp(
    .bin_in (Month + 1),
	.Segment1  (Month1disp),
	.Segment0  (Month0disp)
	);
	
// buzz off :)	  make the connections
  alarm a1(
    .tmin(TMin), .amin(AMin), .thrs(THrs), .ahrs(AHrs), .tdys(TDys), .buzz(ShouldBuzz)
	);
	
	always_comb begin
		AMen = 0;
		AHen = 0;
		Hrs = 0;
		Min = 0;
		Dys = 0;
		Month = 0;
		Date = 0;
		TMen = 0;
		THen = 0;
		TDen = 0;
		TDateEn = 0;
		TMonthEn = 0;
		
				if (TMonth + 1 == 2) begin
					daysInMonth = 28;
				end else if (TMonth + 1 == 4 || TMonth + 1 == 6 || TMonth + 1 == 9 || TMonth + 1 == 11) begin
					daysInMonth = 30;
				end else begin 
					daysInMonth = 31;
				end
		
		
		Buzz = 0;
		if (!Reset) begin
		Buzz = ShouldBuzz && Alarmon;
		
		resetDate = 0;
		TMen = Szero;
		THen = Mzero && Szero;
		TDen = Mzero && Szero && Hzero;
		TDateEn = Mzero && Szero && Hzero;
		TMonthEn = Mzero && Szero && Hzero && DateZero;
		Date = TDate;

		if (Timeset) begin
			if(Alarmset == 0) begin
				TMen = Minadv;
				THen = Hrsadv;
				TDen = Dayadv;
				TDateEn = Dateadv;
				TMonthEn = Monthadv;
			end
		end 
		
		if (TMonthEn) begin 
			if (TMonth + 1 == 2) begin
				daysInMonth = 28;
			end else if (TMonth + 1 == 4 || TMonth + 1 == 6 || TMonth + 1 == 9 || TMonth + 1 == 11) begin
				daysInMonth = 30;
			end else begin 
				daysInMonth = 31;
			end
			Date = 0;
		end 
				
		if (Timeset == 0)begin
			if(Alarmset) begin
				AMen = Minadv;
				AHen = Hrsadv;
			end
		end
		
		if (Alarmset) begin
			Min = AMin;
			Hrs = AHrs;
		end else begin 
			Min = TMin;
			Hrs = THrs;
		end
		Dys = TDys;
		Month = TMonth;
		end else begin 
			resetDate = 1;
			daysInMonth = 31;
		end
	end 

endmodule
