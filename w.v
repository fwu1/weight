module wcoder(
	input pclk, 
	input vsync,
    input hsync,
    input [7:0] din,
	output ready,
	input dclk, 
	output reg [7:0] dout
);

parameter colSize=8;
parameter colBlockWide=3;
parameter rowSize=4;
parameter rowBlockSize=4;
parameter rowBlockHeight=3;


reg [colSize-1:0] colIdx;	// the index of column in a block
reg colBlock;				// 0- for the left block, 1-for the right block
reg [rowSize-1:0] rowIdx;	// the index of row in a block
reg [rowBlockSize-1:0] rowBlock;	// the index of block in rows

reg vReady;		// mark vertical data processing is ready
reg hReady; 	// mark horizontal data processing is ready
reg outReady;	// mark this output is ready

reg [15:0] sum1;	// left sum
reg [15:0] sum2;	// right sum

reg [31:0] outBuffer;
reg [1:0] outIdx;
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
	sum1<=0;
	sum2<=0;
end


always @(posedge hsync) begin
	if(vReady) begin
		colIdx<=0;
		colBlock<=0;
		hReady<=1;
	end
end

always @(posedge pclk) begin
	
	// read the data and sum it for its block
	if(colBlock==0)
		sum1<=sum1+din;
	else
		sum2<=sum2+din;
	
	if(colIdx==(colBlockWide-1)) begin
		// reach the last pixel of a block
		colIdx<=0;
		if(colBlock==0)
			// on the left block, move to the right block
			colBlock<=1;
		else 
		begin
			// on the right block
			// increase the raw index
			rowIdx<=rowIdx+1;
			if(rowIdx==(rowBlockHeight-1)) begin
				// reach the last raw of the block
				// set data ready to output;
				outBuffer[31:16]<=sum1; 
				outBuffer[15:0]<=sum2;
				outIdx<=0; 
				outReady<=1;
				sum1<=0;
				sum2<=0;
				rowIdx<=0;
				rowBlock<=rowBlock+1;
			end
		end
	end
	else
		// increase column index
		colIdx<=colIdx+1;
	
end

always @(posedge dclk) begin
	if(outReady) begin
		dout<=outBuffer[31:24];
		outBuffer[31:8]=outBuffer[23:0];		
		outIdx<=outIdx+1;
		if(outIdx==3)
			outReady<=0;
	end
end

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
