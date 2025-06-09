`define TEST_CYCLE_COUNT 150
`define PRINT_OUTPUTS

module tb_rename
	import typedefs::*;
    (

	);
	logic clk;
	logic reset;

	dinstr_t dinstr;					//decoded instruction
	p_reg_t p_commit;					//physical register
	rinstr_t rinstr;					//renamed instruction
	br_result_t br_result;
	logic rn_full;


	rename RENAME(
		.clk(clk),
		.rst_ni(reset),
		.br_result_i(br_result),
		.p_commit_i(p_commit),
		.dinstr_i(dinstr),
		.rinstr_o(rinstr),
		.rn_full_o(rn_full)
	);
	
	initial begin
		clk=1;
		while(1) begin
			#5 clk = ~clk;
		end
	end
	
	initial begin // waveform oluşmuyor ben koydum
	$dumpfile("dump.vcd");
	$dumpvars();
	end

	logic[5:0] rename_map [31:0];
	logic ready_map [63:0];
	int ref_counter [63:0];
	
	rinstr_t instrs [$];
	rinstr_t new_instr;
	rinstr_t committed_instr;
	int next_commit_timer;
	
	initial begin
		reset = 0;
		br_result = '0;
		p_commit = '0;
		dinstr = '0;
		for(int i=0;i<32;i++) rename_map[i] = 6'(i);
		for(int i=0;i<64;i++) ready_map[i] = 1;
		for(int i=0;i<64;i++) ref_counter[i] = 0;
		next_commit_timer=5;
		
		#50;
		reset = 1;
		
		//for testing manually	 // commit olunca busy table 1 olmas ıotomatik kısımda yer alıyor o yüzden burada check_Output yapma		
		 //#10 dinstr = {valid:1, rd:{valid:1, idx:1}, rs1:{valid:1, idx:2}, rs2:{valid:1, idx:3}, is_branch:0};  p_commit = {valid:0, idx:0, ready:0}; br_result = {valid:0, hit:0}; 
		 //#2 //check_output();
		 //#8 dinstr = {valid:1, rd:{valid:1, idx:1}, rs1:{valid:1, idx:1}, rs2:{valid:0, idx:3}, is_branch:0};  p_commit = {valid:0, idx:0, ready:0}; br_result = {valid:0, hit:0}; 
		 //#2 //check_output();
		 //#8 dinstr = {valid:1, rd:{valid:1, idx:5}, rs1:{valid:1, idx:2}, rs2:{valid:1, idx:6}, is_branch:0};  p_commit = {valid:1, idx:32, ready:0}; br_result = {valid:0, hit:0}; 
		 //#2 //check_output();
		 //#8 dinstr = {valid:1, rd:{valid:1, idx:3}, rs1:{valid:1, idx:5}, rs2:{valid:1, idx:2}, is_branch:0};  p_commit = {valid:1, idx:33, ready:0}; br_result = {valid:0, hit:0}; 
		 //#2 //check_output();
		 //#8 dinstr = {valid:1, rd:{valid:0, idx:1}, rs1:{valid:1, idx:1}, rs2:{valid:1, idx:5}, is_branch:1};  p_commit = {valid:1, idx:34, ready:0}; br_result = {valid:0, hit:0}; 
		 //#2 //check_output();	
		 //#8 dinstr = {valid:1, rd:{valid:1, idx:1}, rs1:{valid:0, idx:2}, rs2:{valid:0, idx:3}, is_branch:0};  p_commit = {valid:1, idx:35, ready:0}; br_result = {valid:0, hit:0}; 
		 //#2 //check_output();
		 //#8 dinstr = {valid:1, rd:{valid:1, idx:4}, rs1:{valid:1, idx:0}, rs2:{valid:1, idx:5}, is_branch:0};  p_commit = {valid:0, idx:0, ready:0}; br_result = {valid:0, hit:0}; 
		 //#2 //check_output();
		 //#8 dinstr = {valid:1, rd:{valid:1, idx:5}, rs1:{valid:1, idx:8}, rs2:{valid:1, idx:1}, is_branch:0};  p_commit = {valid:0, idx:0, ready:0}; br_result = {valid:0, hit:0}; 
		 //#2 //check_output();
		 //#8 dinstr = {valid:1, rd:{valid:1, idx:7}, rs1:{valid:1, idx:5}, rs2:{valid:1, idx:1}, is_branch:0};  p_commit = {valid:0, idx:0, ready:0}; br_result = {valid:1, hit:0}; 
		 //#2 //check_output();
		 //#8 dinstr = {valid:1, rd:{valid:1, idx:8}, rs1:{valid:1, idx:5}, rs2:{valid:1, idx:7}, is_branch:0};  p_commit = {valid:0, idx:0, ready:0}; br_result = {valid:0, hit:0}; 
		 //#2 //check_output();
		 //#8 dinstr = {valid:1, rd:{valid:0, idx:1}, rs1:{valid:1, idx:5}, rs2:{valid:0, idx:3}, is_branch:1};  p_commit = {valid:0, idx:0, ready:0}; br_result = {valid:0, hit:0}; 
		 //#2 //check_output();
		 //#8 dinstr = {valid:1, rd:{valid:1, idx:6}, rs1:{valid:1, idx:0}, rs2:{valid:0, idx:3}, is_branch:0};  p_commit = {valid:1, idx:36, ready:0}; br_result = {valid:0, hit:0}; 
		 //#2 //check_output();
		 //#8 dinstr = {valid:1, rd:{valid:1, idx:2}, rs1:{valid:1, idx:1}, rs2:{valid:1, idx:7}, is_branch:0};  p_commit = {valid:0, idx:0, ready:0}; br_result = {valid:0, hit:0}; 
		 //#2 //check_output();
		 //#8 dinstr = {valid:1, rd:{valid:1, idx:1}, rs1:{valid:1, idx:6}, rs2:{valid:1, idx:1}, is_branch:0};  p_commit = {valid:1, idx:37, ready:0}; br_result = {valid:1, hit:1}; 
		 //#2 //check_output();
		 //#8 dinstr = {valid:1, rd:{valid:1, idx:9}, rs1:{valid:1, idx:8}, rs2:{valid:1, idx:8}, is_branch:0};  p_commit = {valid:1, idx:38, ready:0}; br_result = {valid:0, hit:0}; 
		 //#2 //check_output();
		 //#8 dinstr = {valid:1, rd:{valid:1, idx:10}, rs1:{valid:1, idx:3}, rs2:{valid:1, idx:4}, is_branch:0}; p_commit = {valid:1, idx:39, ready:0}; br_result = {valid:0, hit:0};
		 //#2 //check_output();
		 //#8 dinstr = {valid:0, rd:{valid:1, idx:10}, rs1:{valid:0, idx:3}, rs2:{valid:0, idx:4}, is_branch:0}; p_commit = {valid:0, idx:39, ready:0}; br_result = {valid:0, hit:0};
		 //#2 //check_output();
		for(int i=0;i<`TEST_CYCLE_COUNT;i++) begin
			next_commit_timer--;
			if(next_commit_timer==0) begin
				if(instrs.size()>0) begin
					committed_instr = instrs.pop_front();
					if(committed_instr.rd.valid) begin
						p_commit.valid = 1;
						p_commit.idx = 6'(committed_instr.rd.idx);
						ready_map[p_commit.idx] = 1;
						`ifdef PRINT_OUTPUTS
							$display("%0d committed", p_commit.idx);
						`endif
					end else begin
						p_commit.valid = 0;
					end
					
					if(committed_instr.rs1.valid) ref_counter[committed_instr.rs1.idx]--;
					if(committed_instr.rs2.valid) ref_counter[committed_instr.rs2.idx]--;
				end 
				
				next_commit_timer = $urandom_range(1,3);
			end else begin
				p_commit.valid = 0;
			end
		
			#1; //for preparing rn_full
			if(!rn_full) begin
				dinstr = '{valid:$urandom_range(1,10)>2, rd:'{valid:$urandom_range(1,10)>2, idx:5'($urandom_range(1,31))}, rs1:'{valid:$urandom_range(0,1)==1, idx:5'($urandom_range(0,31))}, rs2:'{valid:$urandom_range(0,1)==1, idx:5'($urandom_range(0,31))}, is_branch:0};
				#1;  //for preparing rinstr
				check_output();
			end else begin
				dinstr = '{valid:0, default:'0};
				i--;	
				#1;  //for preparing rinstr
				assert(dinstr.valid == rinstr.valid)
				else $error("rinstr should be valid when dinstr valid");
			end
			
			@(posedge clk);
		end
		#500;
		$finish(); // stop olunca hata veriyor 
	end
	
	task check_output();
		assert(dinstr.valid == rinstr.valid)
		else $error("rinstr should be valid when dinstr valid");
			
		if(rinstr.valid) begin
			`ifdef PRINT_OUTPUTS
			  print_results();
			`endif
			
			assert(dinstr.rd.valid == rinstr.rd.valid)
			else $error("rinstr.rd should be valid when dinstr.rd valid");
			
			assert(dinstr.rs1.valid == rinstr.rs1.valid)
			else $error("rinstr.rs1 should be valid when dinstr.rs1 valid");
			
			assert(dinstr.rs2.valid == rinstr.rs2.valid)
			else $error("rinstr.rs2 should be valid when dinstr.rs2 valid");
			
			if(rinstr.rs1.valid) begin
				assert(rinstr.rs1.idx == rename_map[dinstr.rs1.idx])
				else $error("rinstr.rs1.idx incorrect");
				
				assert(rinstr.rs1.ready == ready_map[rinstr.rs1.idx])
				else $error("rinstr.rs1.ready incorrect");
				
				ref_counter[rinstr.rs1.idx]++;
			end
			
			if(rinstr.rs2.valid) begin
				assert(rinstr.rs2.idx == rename_map[dinstr.rs2.idx])
				else $error("rinstr.rs2.idx(%0d) incorrect, should be %0d", rinstr.rs2.idx, rename_map[dinstr.rs2.idx]);
				
				assert(rinstr.rs2.ready == ready_map[rinstr.rs2.idx])
				else $error("rinstr.rs2.ready incorrect");
				
				ref_counter[rinstr.rs2.idx]++;
			end
		
			if(rinstr.rd.valid) begin
				assert(ready_map[rinstr.rd.idx]==1)
				else $error("rinstr.rd assigned to uncommitted rd");
				
				rename_map[dinstr.rd.idx] = rinstr.rd.idx;
				ready_map[rinstr.rd.idx] = 0;
				
				assert(ref_counter[rinstr.rd.idx]==0)
				else $error("rinstr.rd assigned to a rd with unresolved dependencies");
				
				ref_counter[rinstr.rd.idx]=0;;
			end
			
			instrs.push_back(rinstr);
		end
	endtask
	
	task print_results();
		string display_string;
		string tmp;
		display_string = $sformatf("dinstr:{rd:%s, rs1:%s, rs2:%s} -> rinstr:{rd:%s, rs1:{%s,%s}, rs2:{%s,%s}}", dinstr.rd.valid  ? itoa(32'(dinstr.rd.idx) ) : "-",
																								  dinstr.rs1.valid ? itoa(32'(dinstr.rs1.idx)) : "-",
																								  dinstr.rs2.valid ? itoa(32'(dinstr.rs2.idx)) : "-",
																								  rinstr.rd.valid  ? itoa(32'(rinstr.rd.idx) ) : "-",
																								  rinstr.rs1.valid ? itoa(32'(rinstr.rs1.idx)) : "-",
																								  rinstr.rs1.valid ? (rinstr.rs1.ready ? "YES" : "NO") : "-",
																								  rinstr.rs2.valid ? itoa(32'(rinstr.rs2.idx)) : "-",
																								  rinstr.rs2.valid ? (rinstr.rs2.ready ? "YES" : "NO") : "-"
							  );
		$display("%s", display_string);
	endtask
	
	function automatic string itoa(input int val);
		string result;
		result.itoa(val);
		return result;
	endfunction

endmodule
