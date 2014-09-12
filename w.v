
//Test bench connects the flip-flop to the tester module
module testbench;
	reg pclk; 
	reg vsync;
    reg hsync;
    reg [7:0] din;
	wire ready;
	reg dclk; 
	wire [7:0] dout;
	integer pix;
	integer lineIdx;
	
	wcoder c1(pclk,vsync,hsync,din,ready,dclk,dout);
	initial
	begin
		//Dump results of the simulation to ff.cvd
		$dumpfile("w.vcd");
		$dumpvars;
		
		
		pclk=0;
		vsync=0;
		hsync=0;
		din=0;
		dclk=0;
		
		#1 vsync=1; #1 vsync=0;
		for (lineIdx=0;lineIdx<7;lineIdx=lineIdx+1) 
		begin
			#1 hsync=1; #1 hsync=0;
			
			for (pix=0;pix<6;pix=pix+1) 
			begin
				#1 din=pix+lineIdx+1;	
				#1 pclk=1; 
					if (ready)
						dclk=0;
				#2 pclk=0;
					if (ready)
						dclk=1;
			end
		end
		/*
		if(dout==din) begin
			$display("pass1");
		end
		*/
		 
		$finish;
	end
	
endmodule
