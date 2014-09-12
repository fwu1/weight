

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
reg [5:0] waitCounter;
reg inPorcess;
reg dataOn;
initial
begin
	outSize=0;
	waitCounter=0;
	inPorcess=0;
	ready=0;
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
			ready<=1;
			waitCounter<=outClock-1;
		end
	end
	else begin
		// in process
		waitCounter<=waitCounter-1;
		if(ready) begin
			// ready signal is high
			if(waitCounter==0) begin
				ready<=0;
				waitCounter<=outClock-1;
			end
		end
		else begin
			// this ready signal is low
			if(waitCounter==0) begin
				waitCounter<=outClock;
				if(outSize!=0) begin
					// output the first buffered bytes
					dout<=outBuffer[(8*nofBytes-9):(8*nofBytes-16)];
					// shift the remaining bytes
					outBuffer[(8*nofBytes-9):8]<=outBuffer[(8*nofBytes-17):0];
					outSize<=outSize-1;
					ready<=1;
					waitCounter<=outClock-1;
				end
				else 
					inPorcess=0;
			end
		end
	end
		
end


endmodule	

