
//Test bench connects the flip-flop to the tester module
module testbench;
	reg pclk;
    reg [39:0] din;
    reg inputReady;
	wire ready;
	wire [7:0] dout;
	
	integer pix;
	

	data8out #(1,5) c1(pclk,din,inputReady,ready,dout);
	
	initial
	begin
		//Dump results of the simulation to ff.cvd
		$dumpfile("d.vcd");
		$dumpvars;
		
		
		pclk=0;
		din='h55667890;	
		inputReady=1;	
		#1 pclk=1;#1 pclk=0; 
		inputReady=0;	
		for (pix=0;pix<21;pix=pix+1) 
		begin
			#1 pclk=1;#1 pclk=0; 
		end
		 
		$finish;
	end
	
endmodule
