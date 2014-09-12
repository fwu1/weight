module wcoder(
	input pclk, 
	input vsync,
    input hsync,
    input [7:0] din,
	output ready,
	input dclk, 
	output [7:0] dout
);

assign dout=din;
assign ready=pclk | vsync | hsync |dclk;

endmodule	


//Test bench connects the flip-flop to the tester module
module testbench;
	reg pclk; 
	wire vsync;
    wire hsync;
    reg [7:0] din;
	wire ready;
	wire dclk; 
	wire [7:0] dout;
	
	wcoder c1(pclk,vsync,hsync,din,ready,dclk,dout);
	initial
	begin
		pclk=0;
		//Dump results of the simulation to ff.cvd
		$dumpfile("w.vcd");
		$dumpvars;
		#1 din=1;	#1 pclk=1; #2 pclk=0; 
		#1 din=2;	#1 pclk=1; #2 pclk=0; 
		#1 din=3;	#1 pclk=1; #2 pclk=0; 
		$finish;
	end
	
endmodule
