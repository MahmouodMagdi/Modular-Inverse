////////////////////////////////////////
/////		 Test Macros 		   /////
////////////////////////////////////////
`timescale 1ns/1ps
`define delay   10
`define CLK_PER 100


////////////////////////////////////////
////		Test parameters			////
////////////////////////////////////////
parameter Data_Width = 256;



///////////////////////////////////////////////////////
////////		Sequencer Class Creation	   ////////
///////////////////////////////////////////////////////
class Sequencer #();

  rand bit [Data_Width - 1:0] rand_A, rand_b;										      // Two random variables 
  constraint value_A {rand_A inside {[256'd1:256'd28]};}							// take a value from 1 to 28
  constraint value_b {rand_b inside {[256'd1:256'd96]};}							// take a value from 1 to 96

endclass


module ModInv_tb;

	logic [Data_Width       - 1 : 0] Expect;										// Represents the expected value when there is an error 
	logic [(Data_Width * 2) - 1 : 0] Mul   ;										// Multiplication = integer * inverse modular
	logic [Data_Width       - 1 : 0] Mod   ;										// Integer * inverse modular * mod(prime)  1 --> if The result o_R is correct, else error 
	



	// Input Signals 
	logic						 i_clk_tb	;										            // Test Bench Input Clock Signal 
	logic						 i_rst_tb	;										            // Test Bench Input Reset Signal
	logic	[Data_Width - 1 : 0] i_a_tb		;										  // Test Bench Input integer a
	logic	[Data_Width - 1 : 0] i_p_tb		;										  // Test Bench Input Prime p

		
	logic	[Data_Width - 1 : 0] o_R_tb		;										  // Test Bench Output Modular Inverse Signal
	logic   					 o_busy_tb	;										        // Test Bench Output Busy Signal 





	Sequencer #() item;																        // Making a Class object 


//////////////////////////////////////////////////////
//////		Design Under Test Instantiation		//////
//////////////////////////////////////////////////////
	Modular_Inverse #(

					.Data_Width(Data_Width)

				) DUT (

					.i_clk	(i_clk_tb ),
					.i_rst	(i_rst_tb ),
					.i_a	(i_a_tb	  ),
					.i_p	(i_p_tb	  ),
					.o_R	(o_R_tb	  ),
					.o_busy (o_busy_tb)

				);



///////////////////////////////////////////////////////
////////	Dump Changes into the .VCD File	   ////////
///////////////////////////////////////////////////////
	initial 
	begin

	  $dumpfile("dump.vcd");
	  $dumpvars;

	  #500000

	  $finish;

	end





///////////////////////////////////////////////
////////	Clock Generation Block	   ////////
///////////////////////////////////////////////
always #(`CLK_PER/2) i_clk_tb = ~i_clk_tb;




///////////////////////////////////////////////////////
////////		Applying Test Stimulus 	   		///////
///////////////////////////////////////////////////////
initial 
begin

  i_p_tb   = 256'd29;																// Set the Prime Number to decimal = 29
  i_clk_tb = 1'b1;  																// initialize i_clk_tb

  item = new();

    repeat(30) 
	begin

		// Reset the System
		i_rst_tb = 0;
		
		// Randomize the integer values using randomization
        item.randomize();
        i_a_tb = item.rand_A;
   
   
	
		// De-assert the reset signal 
		@(posedge i_clk_tb)  #`delay;
        i_rst_tb = 1;

		

        @(posedge i_clk_tb)  #`delay;
		
        while (o_busy_tb == 1) @(posedge i_clk_tb);

			Mul = (i_a_tb*o_R_tb); 

			Mod = Mul%i_p_tb;

			if( Mod == 1 ) 
			begin

				$display("i_a = %d\ni_P = %d\no_R = %d\n(i_a o_R)mod(i_p) = %d",i_a_tb,i_p_tb,o_R_tb,Mod);
				$display("\n *********************************************************** \n");

			end 
			else 
			begin

				$display("%d:Error Expect = %d R =%d",i_a_tb,Mod,o_R_tb);

			end

    end

    #10000 	i_p_tb = 256'd97;														// Set the Prime Number to decimal = 97
    
	repeat(50) 
	begin

		i_rst_tb = 0;
        item.randomize();
        i_a_tb = item.rand_b;
		

		@(posedge i_clk_tb)  #`delay;
        i_rst_tb = 1;
		

        @(posedge i_clk_tb)  #`delay;

        while (o_busy_tb == 1) @(posedge i_clk_tb);

			Mul = (i_a_tb*o_R_tb); 

			Mod = Mul%i_p_tb;

			if( Mod == 1 ) 
			begin

				$display("i_a = %d\ni_P = %d\no_R = %d\n(i_a o_R)mod(i_p) = %d",i_a_tb,i_p_tb,o_R_tb,Mod);
				$display("\n *********************************************************** \n");

			end 
			else 
			begin

				$display("%d:Error Expect = %d R =%d",i_a_tb,Mod,o_R_tb);

			end
			
    end


$finish;

end



endmodule
