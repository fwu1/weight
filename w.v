module wcoder(
	input pclk, 
	input vsync,
    input hsync,
    input [7:0] din,
	output ready,
	input dclk, 
	output [7:0] dout
);

parameter colSize=8;
parameter rowSize=4;
parameter colBlockWide=2;

reg [colSize-1:0] colIdx;
reg colBlock;
reg [rowSize-1:0] rowIdx;
reg [3:0] rowBlock;

reg vReady;
reg hReady; 
reg outReady;

reg [7:0] sum;

initial
begin
	vReady=0;
	hReady=0;
end

always @(posedge vsync) begin
	vReady<=1;
	outReady<=0;
	rowIdx<=0;
	rowBlock<=0;
end

always @(posedge hsync) begin
	if(vReady) begin
		colIdx<=0;
		colBlock<=0;
		hReady<=1;
		sum<=0;
	end
end

always @(posedge pclk) begin
	colIdx<=colIdx+1;
	sum<=sum+din;
	if(colIdx==colBlockWide) begin
		outReady<=1;
	end
end


assign dout=sum;
assign ready=outReady;


endmodule	


//Test bench connects the flip-flop to the tester module
module testbench;
	reg pclk; 
	reg vsync;
    reg hsync;
    reg [7:0] din;
	wire ready;
	reg dclk; 
	wire [7:0] dout;
	
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
		#1 hsync=1; #1 hsync=0;
		
		#1 din=1;	#1 pclk=1; #2 pclk=0;
		#1 din=2;	#1 pclk=1; #2 pclk=0; 
		#1 din=3;	#1 pclk=1; #2 pclk=0; 
		#1 din=4;	#1 pclk=1; #2 pclk=0; 
		#1 din=5;	#1 pclk=1; #2 pclk=0; 
		
		/*
		if(dout==din) begin
			$display("pass1");
		end
		*/
		 
		$finish;
	end
	
endmodule
