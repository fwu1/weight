
//Test bench connects the flip-flop to the tester module
module testbench;
	reg pclk; 
	reg vsync;
    reg href;
    reg [7:0] din;
	wire ready;
	reg dclk; 
	wire [7:0] dout;
	integer pix;
	integer lineIdx;
	
	wcoder c1(pclk,hsync,href,din,ready,dclk,dout);
	initial
	begin
		//Dump results of the simulation to ff.cvd
		$dumpfile("w.vcd");
		$dumpvars;
		
		
		pclk=0;
		vsync=0;
		href=0;
		din=0;
		dclk=0;
		
		vsync=1;
		#1 pclk=1; 
		#1 pclk=0; 
		vsync=0;
		
		for (lineIdx=0;lineIdx<3;lineIdx=lineIdx+1) 
		begin
			href=0;
			#1 pclk=1; #1 pclk=0; 
			#1 href=1; #1
			for (pix=0;pix<21;pix=pix+1) 
			begin
				#1 din=pix+lineIdx+1;	
				#1 pclk=1; 
					if (ready)
						dclk=0;
				#2 pclk=0;
					if (ready)
						dclk=1;
			end
			href=0;
		end
		 
		$finish;
	end
	
endmodule
