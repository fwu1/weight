

module data8out(
	pclk, din, inputReady, ready,dout
);

parameter outClock=1;
parameter nofBytes=3;

input pclk;

input [(8*nofBytes-1):0] din;
input inputReady;
output reg ready;
output reg [7:0] dout;



reg [(8*nofBytes-9):0] outBuffer;
reg [2:0] outSize;
reg [3:0] outTimer;
reg inPorcess;

initial
begin
	outSize=0;
	outTimer=0;
	inPorcess=0;
end


always @(posedge pclk) begin
	if(inPorcess==0 ) begin
		if(inputReady==1) begin
			inPorcess<=1;
			// set the first byte to output
			dout<=din[(8*nofBytes-1):(8*nofBytes-8)];
			//save the remaining bytes to buffer
			outBuffer[(8*nofBytes-9):0]<=din[(8*nofBytes-9):0];
			outSize<=nofBytes-1;
		end
	end
	else begin
		// in process
		if(outSize!=0) begin
			// output the first buffered bytes
			dout<=outBuffer[(8*nofBytes-9):(8*nofBytes-16)];
			// shift the remaining bytes
			outBuffer[(8*nofBytes-9):8]<=outBuffer[(8*nofBytes-17):0];
			outSize<=outSize-1;
		end
		else
			inPorcess=0;
	end
		
end


endmodule	

