module wcoder(
	input pclk, 
    input href,
    input [7:0] din,
	output ready,
	output [7:0] dout
);

parameter colSize=8;
parameter colBlockWide=200;
parameter rowSize=4;
parameter rowBlockSize=4;
parameter rowBlockHeight=3;
parameter sumSize=16;
parameter weightSize=24;
parameter true=1;
parameter false=0;
parameter outClock=1;

reg [colSize-1:0] colIdx;	// the index of column in a block

reg sumReady;	// data in buffer is ready
reg outReady;	// mark this output is ready

reg [(sumSize-1):0] sum;
reg [(weightSize-1):0] weight;

reg [31:0] outBuffer;
reg [2:0] outSize;
reg [3:0] outTimer;
reg [7:0] header;

data8out #(18,5) c1(pclk,{weight,sum},sumReady,ready,dout);

initial
begin
	outSize=0;
	sumReady=false;
	colIdx=-1;
	sum=0;
	weight=0;
	header=8'h55;
end


always @(posedge pclk) begin

	if(sumReady) 
		sumReady<=false;
		
	if(href==1) begin
		// when href is high, 
		// add the sum
		sum<=sum+din;
		weight<=weight+din*colIdx;
		if(colIdx==(colBlockWide-1)) begin
			// reach the width, mark the sum ready for output
			sumReady<=true;
			// reset the output clock timer
			outTimer<=0;
			// reset column index
			colIdx<=0;
		end
		else
			// increase the column index
			colIdx<=colIdx+1;
	end
	else begin
		// when href is low, reset column index
		colIdx<=0;
		
	end
	
	
/*
	if(sumReady) begin
		// save the sum to output buffer
		outBuffer[31:sumSize]<='h5566; 
		outBuffer[(sumSize-1):0]<=sum;
		outSize<=4;
		outTimer<=0;
		sumReady<=false;
	end

	if(outSize!=0) begin
	// there are data to output
		outTimer<=outTimer+1;
		if(outTimer==0) begin
			// output the data
			outSize<=outSize-1;
			dout<=outBuffer[31:24];
			outBuffer[31:8]<=outBuffer[23:0];
			ready<=true;
		end
		
		if(outTimer==outClock)
			ready<=false;
			
		if(outTimer==(outClock+outClock-1))
			outTimer<=0;
	end
*/		
end


endmodule	

