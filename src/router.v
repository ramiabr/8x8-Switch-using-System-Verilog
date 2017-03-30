// AUTHOR:    Ramkumar Subramanian
//
// DATE: Wed Mar  8 11:32:32 PST 2017
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//
// ABSTRACT : 
//         This project is a 8x8 switch. There are 8 Input ports that can receive 
// serial data parallely. The switch decodes the serial data into address and data
// and based on the address assigns the data to appropriate output port 
//
//      Input Ports     Size            Description
//      ==========      =========       ===========
//      clock		1		Input clock
//	reset_n		1		Active low synchronous reset 
// 	frame_n		8		Input frame signal, one for each input port
//	valid_n		8		Input valid signal, one for each input port
//	di		8		Serial input for 8 input ports
//
//	Output Ports	Size		Description 			
//      ==========      =========       ===========
//	dout		8		serial output port for 8 output ports
//	valido_n	1		Output frame signal, one for each output port 
//	frameo_n	1		Output Valid signal, one for each output port
//
//
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

`define clogb2(x) x==8 ? 2 : x==16 ? 3 : x==32 ? 4 : x==64 ? 5 : x==128 ? 6 : x==256 ? 7 : x==12 ? 8 : x==1024 ? 9 : 10


module router (clock, reset_n, frame_n, valid_n, di, dout, valido_n, frameo_n);
	input clock, reset_n;
	input [7:0] frame_n, valid_n; 
	input [7:0] di; 
		
	output [7:0] dout; 
	output [7:0] valido_n;
	output [7:0] frameo_n;
	
	// Interconnections 
	wire [3:0] addr [7:0];
	wire [31:0] payload [7:0];
	wire [7:0] vld;
	
	wire [31:0] data_out [7:0];
	wire [7:0] req [7:0];
	wire [31:0] data_fifo [7:0];
	wire [31:0] dout_portout [7:0];
	
	
	wire [7:0] granted; 
	wire [7:0] grant [7:0]; 
	wire [2:0] grant_index [7:0];
	
	wire [7:0] empty;
	wire [7:0] full;
	wire [7:0] pop;
	
	wire [7:0] push_fifo;
	wire [7:0] pop_flag;
	
	// Input port 
	portin port0 (clock, reset_n, frame_n[0], valid_n[0], di[0], addr[0],  payload[0], vld[0]);
	portin port1 (clock, reset_n, frame_n[1], valid_n[1], di[1], addr[1],  payload[1], vld[1]);
	portin port2 (clock, reset_n, frame_n[2], valid_n[2], di[2], addr[2],  payload[2], vld[2]);
	portin port3 (clock, reset_n, frame_n[3], valid_n[3], di[3], addr[3],  payload[3], vld[3]);
	portin port4 (clock, reset_n, frame_n[4], valid_n[4], di[4], addr[4],  payload[4], vld[4]);
	portin port5 (clock, reset_n, frame_n[5], valid_n[5], di[5], addr[5],  payload[5], vld[5]);
	portin port6 (clock, reset_n, frame_n[6], valid_n[6], di[6], addr[6],  payload[6], vld[6]);
	portin port7 (clock, reset_n, frame_n[7], valid_n[7], di[7], addr[7],  payload[7], vld[7]);

	
	// Flip flop  
	flipflop flop0 (clock, reset_n, payload[0], vld[0], data_out[0]);
	flipflop flop1 (clock, reset_n, payload[1], vld[1], data_out[1]);
	flipflop flop2 (clock, reset_n, payload[2], vld[2], data_out[2]);
	flipflop flop3 (clock, reset_n, payload[3], vld[3], data_out[3]);
	flipflop flop4 (clock, reset_n, payload[4], vld[4], data_out[4]);
	flipflop flop5 (clock, reset_n, payload[5], vld[5], data_out[5]);
	flipflop flop6 (clock, reset_n, payload[6], vld[6], data_out[6]);
	flipflop flop7 (clock, reset_n, payload[7], vld[7], data_out[7]);

	// Request selector  
	request_selector rq0 (clock, reset_n, vld, addr,  grant[0], 4'b0000, req[0]);
	request_selector rq1 (clock, reset_n, vld, addr,  grant[1], 4'b0001, req[1]);
	request_selector rq2 (clock, reset_n, vld, addr,  grant[2], 4'b0010, req[2]);
	request_selector rq3 (clock, reset_n, vld, addr,  grant[3], 4'b0011, req[3]);
	request_selector rq4 (clock, reset_n, vld, addr,  grant[4], 4'b0100, req[4]);
	request_selector rq5 (clock, reset_n, vld, addr,  grant[5], 4'b0101, req[5]);
	request_selector rq6 (clock, reset_n, vld, addr,  grant[6], 4'b0110, req[6]);
	request_selector rq7 (clock, reset_n, vld, addr,  grant[7], 4'b0111, req[7]);
	
	// Multiplexer 
	multiplexer mux0 (grant[0], clock, data_out, data_fifo[0], push_fifo[0]);
	multiplexer mux1 (grant[1], clock, data_out, data_fifo[1], push_fifo[1]);
	multiplexer mux2 (grant[2], clock, data_out, data_fifo[2], push_fifo[2]);
	multiplexer mux3 (grant[3], clock, data_out, data_fifo[3], push_fifo[3]);
	multiplexer mux4 (grant[4], clock, data_out, data_fifo[4], push_fifo[4]);
	multiplexer mux5 (grant[5], clock, data_out, data_fifo[5], push_fifo[5]);
	multiplexer mux6 (grant[6], clock, data_out, data_fifo[6], push_fifo[6]);
	multiplexer mux7 (grant[7], clock, data_out, data_fifo[7], push_fifo[7]);
	
	// Arbitter  
	DW_arb_rr #(8, 1, 0) arb0 (clock, reset_n, 1'b1, 1'b1, req[0], 8'd0, granted[0], grant[0], grant_index[0]); 
	DW_arb_rr #(8, 1, 0) arb1 (clock, reset_n, 1'b1, 1'b1, req[1], 8'd0, granted[1], grant[1], grant_index[1]); 
	DW_arb_rr #(8, 1, 0) arb2 (clock, reset_n, 1'b1, 1'b1, req[2], 8'd0, granted[2], grant[2], grant_index[2]); 
	DW_arb_rr #(8, 1, 0) arb3 (clock, reset_n, 1'b1, 1'b1, req[3], 8'd0, granted[3], grant[3], grant_index[3]); 
	DW_arb_rr #(8, 1, 0) arb4 (clock, reset_n, 1'b1, 1'b1, req[4], 8'd0, granted[4], grant[4], grant_index[4]); 
	DW_arb_rr #(8, 1, 0) arb5 (clock, reset_n, 1'b1, 1'b1, req[5], 8'd0, granted[5], grant[5], grant_index[5]); 
	DW_arb_rr #(8, 1, 0) arb6 (clock, reset_n, 1'b1, 1'b1, req[6], 8'd0, granted[6], grant[6], grant_index[6]); 
	DW_arb_rr #(8, 1, 0) arb7 (clock, reset_n, 1'b1, 1'b1, req[7], 8'd0, granted[7], grant[7], grant_index[7]); 

	// fifo	 
	fifo #(32, 32) fifo0 (full[0], empty[0], dout_portout[0], data_fifo[0], clock, reset_n, push_fifo[0], pop[0], pop_flag[0]);
	fifo #(32, 32) fifo1 (full[1], empty[1], dout_portout[1], data_fifo[1], clock, reset_n, push_fifo[1], pop[1], pop_flag[1]);
	fifo #(32, 32) fifo2 (full[2], empty[2], dout_portout[2], data_fifo[2], clock, reset_n, push_fifo[2], pop[2], pop_flag[2]);
	fifo #(32, 32) fifo3 (full[3], empty[3], dout_portout[3], data_fifo[3], clock, reset_n, push_fifo[3], pop[3], pop_flag[3]);
	fifo #(32, 32) fifo4 (full[4], empty[4], dout_portout[4], data_fifo[4], clock, reset_n, push_fifo[4], pop[4], pop_flag[4]);
	fifo #(32, 32) fifo5 (full[5], empty[5], dout_portout[5], data_fifo[5], clock, reset_n, push_fifo[5], pop[5], pop_flag[5]);
	fifo #(32, 32) fifo6 (full[6], empty[6], dout_portout[6], data_fifo[6], clock, reset_n, push_fifo[6], pop[6], pop_flag[6]);
	fifo #(32, 32) fifo7 (full[7], empty[7], dout_portout[7], data_fifo[7], clock, reset_n, push_fifo[7], pop[7], pop_flag[7]);
	
	
	// Synchronizing empty signal 
	//sync_empty sync0 (clock, reset_n, empty[0], valido_n[0], empty_to_portout[0]);
	
	
	// Output port 
	portout portout0 (clock, empty[0], reset_n, dout_portout[0], dout[0], valido_n[0], frameo_n[0], pop[0], push_fifo[0], pop_flag[0]);
	portout portout1 (clock, empty[1], reset_n, dout_portout[1], dout[1], valido_n[1], frameo_n[1], pop[1], push_fifo[1], pop_flag[1]);
	portout portout2 (clock, empty[2], reset_n, dout_portout[2], dout[2], valido_n[2], frameo_n[2], pop[2], push_fifo[2], pop_flag[2]);
	portout portout3 (clock, empty[3], reset_n, dout_portout[3], dout[3], valido_n[3], frameo_n[3], pop[3], push_fifo[3], pop_flag[3]);
	portout portout4 (clock, empty[4], reset_n, dout_portout[4], dout[4], valido_n[4], frameo_n[4], pop[4], push_fifo[4], pop_flag[4]);
	portout portout5 (clock, empty[5], reset_n, dout_portout[5], dout[5], valido_n[5], frameo_n[5], pop[5], push_fifo[5], pop_flag[5]);
	portout portout6 (clock, empty[6], reset_n, dout_portout[6], dout[6], valido_n[6], frameo_n[6], pop[6], push_fifo[6], pop_flag[6]);
	portout portout7 (clock, empty[7], reset_n, dout_portout[7], dout[7], valido_n[7], frameo_n[7], pop[7], push_fifo[7], pop_flag[7]);
	

endmodule


module portin (input clock, reset_n,frame_n,valid_n,di,
               output reg [3:0] addr, output reg [31:0] payload, output reg vld); 

	reg [5:0] cnta,cntp; 
	
	always @(posedge clock, negedge reset_n) 
		if (!reset_n) begin 
			cnta <= 0; 
	       	cntp <= 0; 
	       	vld <= 0; 
		end
    	else begin 
       		if (!frame_n && valid_n) begin 
		        if (cnta < 4) 
					addr[cnta] <= di; 
        		cnta <= cnta + 1; 
		    end 
       else if (!frame_n && !valid_n) begin 
         	payload[cntp] <= di;   
			cntp <= cntp + 1; 
       end       
		else if (frame_n && !valid_n) begin 
        	payload[cntp] <= di;   
         	vld <= 1; 
         	cnta <= 0; 
         	cntp <= 0; 
    	end
       	else begin 
        	vld <= 0; 
         	cnta <= 0; 
         	cntp <= 0; 
       end
    end              
endmodule       


module flipflop (clk, reset_n, data, vld, data_out);

	input clk, reset_n, vld; //, clear;
	input [31:0] data;
	
	output reg [31:0] data_out;
	
	//reg state;

	always @ (posedge clk) begin 
		if(! reset_n) begin 
			data_out <= 0;
		end
		else if (vld == 1) begin 
			data_out <= data;		
		end
		else 
			data_out <= data_out;
	end
endmodule 




module request_selector_x1 (clk, reset_n, vld, addr, clear, pgm, req);	
	parameter reset = 0; 
	parameter set = 1;
	
	input clk, reset_n;
	input vld; 
	input [3:0] addr;
	input [3:0] pgm; 
	input clear;
		
	output reg req; 
	reg state;

	always @ (posedge clk) begin 
		if(! reset_n) begin 		
			req <= 0;
			state <= reset; 		
		end
		else if(state == reset) begin 
			req <= 0 ;
			
			//		
			if(addr == pgm && vld == 1) begin 
				req <= 1;
				state <= set;							
			end 
		end
		else if(state == set) begin 			
			if(clear == 1)  begin 
				state <= reset;	
				req <= 0;	
			end		
		end	
		else begin 
			req <= 0; 
			state <= reset;		
		end
	end
endmodule 


module request_selector (clk, reset_n, vld, addr, clear, pgm, req);		
	input clk, reset_n;
	input [7:0] vld; 
	input [3:0] addr [7:0];
	input [3:0] pgm; 
	input [7:0] clear;
		
	output [7:0] req; 

	// Instantiate 8 blocks  
	// clk, reset_n, vld, addr, clear, pgm, req
	request_selector_x1 x0 (clk, reset_n, vld[0], addr[0], clear[0], pgm, req[0]);
	request_selector_x1 x1 (clk, reset_n, vld[1], addr[1], clear[1], pgm, req[1]);
	request_selector_x1 x2 (clk, reset_n, vld[2], addr[2], clear[2], pgm, req[2]);
	request_selector_x1 x3 (clk, reset_n, vld[3], addr[3], clear[3], pgm, req[3]);
	request_selector_x1 x4 (clk, reset_n, vld[4], addr[4], clear[4], pgm, req[4]);
	request_selector_x1 x5 (clk, reset_n, vld[5], addr[5], clear[5], pgm, req[5]);
	request_selector_x1 x6 (clk, reset_n, vld[6], addr[6], clear[6], pgm, req[6]);
	request_selector_x1 x7 (clk, reset_n, vld[7], addr[7], clear[7], pgm, req[7]);
endmodule 



module multiplexer (sel, clk, data_in, data_out, push);

	parameter scan = 1'b0;
	parameter outp = 1'b1;
 
	input [7:0] sel;
	input clk;
	input [31:0] data_in [7:0];
	//input granted, reset_push;
	
	output reg [31:0] data_out;
	output reg push;
	
	reg state;

	always @ (posedge clk) begin 
		if(state == scan) begin 

			if(sel > 8'd0) begin 
				state <= outp;				
			end
			push <= 0;
		end 
		else if(state == outp) begin 
		
		// When receive sel go to output mode 


		if(sel == 8'b0000_0000) begin 
			data_out <= 0;
			push <= 0;
			state <= scan;
		end
		else if(sel == 8'b0000_0001) begin  
			data_out <= data_in[0];
			push <= 1;
			state <= scan;
		end
		else if(sel == 8'b0000_0010)  begin 
			data_out <= data_in[1];		
			push <= 1;		
			state <= scan;
		end	
		else if(sel == 8'b0000_0100)  begin 
			data_out <= data_in[2];
			push <= 1;
			state <= scan;
		end
		else if(sel == 8'b0000_1000)  begin 
			data_out <= data_in[3];	
			push <= 1;
			state <= scan;
		end
		else if(sel == 8'b0001_0000)  begin 
			data_out <= data_in[4];
			push <= 1;
			state <= scan;
		end
		else if(sel == 8'b0010_0000) begin 
			data_out <= data_in[5];
			push <= 1;
			state <= scan;
		end
		else if(sel == 8'b0100_0000) begin 
			data_out <= data_in[6];		
			push <= 1;
			state <= scan;
		end				
		else if(sel == 8'b1000_0000) begin 
			data_out <= data_in[7];
			push <= 1;
			state <= scan;
		end			
		else begin 
			data_out <= 0;	
			state <= scan;
			push <= 0;
		end



		end
		else begin 
			state <= scan;
		end

	end
endmodule



module fifo  #(parameter WIDTH=8, DEPTH=128)  (full, empty, dout, din, clk,  reset, push,  pop, pop_flag);

	output full;
        output empty;
        output [WIDTH-1:0] dout;
        
        input [WIDTH-1:0] din;
        input clk;
	input reset;
	input push;
	input pop;
	output pop_flag;
	

        reg     [(WIDTH - 1):0] mem[(DEPTH - 1):0];

        reg     [`clogb2(DEPTH):0]              head;
        reg     [`clogb2(DEPTH):0]              tail;
        reg     [`clogb2(DEPTH)+1:0]            cnt;
	
	wire empty;
	
	reg pop_flag;
	//reg  [WIDTH-1:0] dout;

        assign dout = mem[tail];
	assign empty = (head == tail);
        assign full = (cnt == DEPTH);

	always @(posedge clk or negedge reset) if (!reset) begin
        	head <= 0;
          	tail <= 0;
          	cnt <= 0;
		pop_flag <= 0;
        end
	else if (push && (!full) && pop && (!empty)) begin 
          	mem[head] <= din;
          	head <= (head + 1);
          	tail <= (tail + 1);
		pop_flag <= 1;
	end
        else if (push && (!full)) begin
          	mem[head] <= din;
          	head <= (head + 1);
          	cnt <= (cnt + 1);
		pop_flag <= 0;
        end
        else if (pop && (!empty)) begin
		//dout <= mem[tail];
          	tail <= (tail + 1);
          	cnt <= (cnt - 1);
		pop_flag <= 1;
        end
	
	
endmodule


module portout (clock, empty, reset_n, data_in, dout, valido_n, frameo_n, pop, push, pop_flag);
	
	parameter idle = 2'b00;
	parameter wait_pop = 2'b01;
	parameter send = 2'b10;


	input clock, reset_n, empty; 
	input [31:0] data_in; 
	input push; 
	input pop_flag; 
	
	output reg dout, valido_n, frameo_n; 
	output reg pop;
	
	reg [5:0] count; 
	reg [1:0] state;
	
	reg [31:0] data_sample;
	
	
	always @ (posedge clock) begin 
		if(! reset_n) begin 
			count <= 0;
			dout <= 0; 
			valido_n <= 1;
			frameo_n <= 1;
			state <= idle;	
			pop <= 0;	
			data_sample <= 0;	
		end
		else if(state == idle ) begin 
			count <= 0;
			dout <= 0; 
			valido_n <= 1;
			frameo_n <= 1;
			pop <= 0;
			//data_sample <= 0;			
			
			if(empty == 0) begin 
				state <= send;
				pop <= 1;
				data_sample <= data_in;	
			end							
		end
		else if(state == send) begin 			
			 pop <= 0;
			 dout <= data_sample[count];
			 count <= count + 1;
			 valido_n <= 0;
			 frameo_n <= 0;
			
			 if(count > 'd30) begin 
			 	 state <= idle;
				 frameo_n <= 1;
			 end	 
		end
		else begin 
			state <= idle;		
		end

	end
endmodule


