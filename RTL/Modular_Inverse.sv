`timescale 1ns/1ps


////////////////////////////
/// 	Design Macros 	 ///
////////////////////////////
`define Init    0   																// Initialization state
`define ModInv  1   																// Modular Inverse Calculation state
`define Final   2   																// Final Result state


module Modular_Inverse #(

	parameter Data_Width = 256

)(

///////////////////////
///		Inputs 		///
///////////////////////
	input	logic						 i_clk	,
	input	logic						 i_rst	,
	input	logic	[Data_Width - 1 : 0] i_a	,
	input	logic	[Data_Width - 1 : 0] i_p	,

///////////////////////
///		Outputs 	///
///////////////////////
	output	logic	[Data_Width - 1 : 0] o_R	,
	output  logic   					 o_busy

);


///////////////////////////////////////////////
///		Internal Signals and registers		///
///////////////////////////////////////////////
	logic [Data_Width - 1 : 0] u, v, x, y;
	logic [Data_Width     : 0] u_v_reg, x_y_reg, x_pls_p_reg, y_pls_p_reg;
	logic 		       [1 : 0] state;



////////////////////////////////////////////////////
// Preparing the Addition and Subtraztion results //
////////////////////////////////////////////////////
	assign    u_v_reg     = u - v	;
	assign    x_y_reg     = x - y	;
	assign    x_pls_p_reg = x + i_p	;
	assign    y_pls_p_reg = y + i_p	;


///////////////////////////////////////////////////////
///		Behavioral Model of the Modular Inverse 	///
///////////////////////////////////////////////////////
	always @(posedge i_clk or negedge i_rst) 
	begin

			if(!i_rst) 																// Ready
			begin    													

				o_busy <= 1'b0 ;
				state  <= `Init;

			end 
			
			else 
			begin
			
				if(state == `Init) begin    										// Initialization

					o_busy <= 1'b1   ;
					u 	   <= i_a    ;
					v 	   <= i_p    ;
					x 	   <= 256'd1 ;
					y 	   <= 256'd0 ;
					state  <= `ModInv;

				end 
				else if(state == `ModInv) begin									// Modular Inverse Calculation

					if((u != 'd1) && (v != 'd1)) 
					begin

						if(u[0] == 1'b0) 
						begin

							u <= {1'b0,u[Data_Width - 1:1]};									// Divide by 2
							x <= (x[0])? x_pls_p_reg[Data_Width:1] : {1'b0,x[Data_Width - 1:1]} ;

						end 

						if(v[0] == 1'd0) 
						begin

							v <= {1'b0,v[Data_Width - 1:1]};
							y <= (y[0])? y_pls_p_reg[Data_Width:1] : {1'b0,y[Data_Width - 1:1]} ;			

						end 

						if((u[0])&&(v[0])) 
						begin

							if (u_v_reg[Data_Width]) 
							begin					

								v <= (v - u);
								y <= (x_y_reg[Data_Width])? (y - x):(y - x + i_p);					

							end 
							else 
							begin				

								u <= (u - v);
								x <= (x_y_reg[Data_Width])? (x - y + i_p):(x - y);				

							end

						end

					end 
					else 
					begin			

						o_R   <= (u == 'd1)? x:y ;
						state <= `Final;			

					end

				end 
				else 
				begin
				
					o_busy <= 0;  													// Finalization

				end

			end

	end

endmodule 
