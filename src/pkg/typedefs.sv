`timescale 1 ns / 1 ps
package typedefs;


	typedef struct packed {
		logic       valid;  
		logic [4:0] idx;       	//id of the register
	} a_reg_t;				   	//architectural register

	typedef struct packed {
		logic       valid;
		a_reg_t  	rd;		   	//only valid if rd used
		a_reg_t 	rs1;	   	//only valid if rs1 used
		a_reg_t 	rs2;	   	//only valid if rs2 used
		logic       is_branch;	//bonus
	} dinstr_t;	                //decoded instruction


	typedef struct packed {
		logic       valid;  
		logic [5:0] idx;    	//id of the new register
		logic       ready;  	// 
	} p_reg_t;					//physical register

	typedef struct packed {
		logic       valid;
		p_reg_t   	rd;
		p_reg_t   	rs1;
		p_reg_t   	rs2;
	} rinstr_t;					//renamed instruction

	typedef struct packed {
		logic valid;
		logic hit;
	} br_result_t;
	
endpackage	
