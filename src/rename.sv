`timescale 1 ns / 1 ps

module rename 
  import typedefs::*;
(
    input  logic       clk,
    input  logic       rst_ni,
    input  br_result_t br_result_i,
    input  p_reg_t     p_commit_i,   // in-order commit
    input  dinstr_t    dinstr_i,
    output rinstr_t    rinstr_o,
    output logic       rn_full_o
);

  logic [5:0] arch2phy [31:0]; // rename table // architectural olanlara physical karşılığını yazacağım. 
  logic [5:0] prev2phy [63:0]; // bir nevi re order buffer // free list boşaltmak için güncel prf değerinin karşısına previous prf değerini ekliyorum
  logic busy_table [63:0] ; // busy table // bir instruction commit edildiğinde ready olacak. derste issue queue de işi bitince ready olmuştu.
  logic free_list [63:0]; // free list // bir rd adresi commit edilmiş ve aynı rd adresine yeni bir physical adres tanımlanırsa (yani) rd adresi tekrar gelirse öncekini free yap
  logic [5:0] next_arch2phy [31:0];
  logic [5:0] next_prev2phy [63:0];
  logic       next_busy_table [63:0];
  logic       next_free_list [63:0];
  logic [5:0] prev_adres;
  dinstr_t    din;
  rinstr_t    rin;
  logic [5:0] count, next_count;
  logic rn_full;


  assign din = dinstr_i;

  assign rn_full = (count == 6'd62); // resette zaten 31 oluyor. 0 dahil olmadan x1 den x31 e 31 tane var. 31 + 31 = 62 

  // next ve current diye 2 ayrı şekilde yaptım çünkü uyarı veriyor verilator. curerentler posedge clk da tetiklendiği için always_comb'a 2 defa girip 2 defa renaming yapıyor 1 dinstr için ama posedge clk da current <= next yaptığımız için 2. olanı almıyor sorunsuz gidiyor 

  always_comb begin  // rd ye adres atama için
    rin.valid = din.valid;
    rin.rd.valid = din.valid ? din.rd.valid : 1'b0; // din.valid 0 ise rin.rd.valid de 0 olsun 
    rin.rs1.valid = din.valid ? din.rs1.valid : 1'b0;
    rin.rs2.valid = din.valid ? din.rs2.valid : 1'b0;
    rin.rs1.idx = 6'd0;
    rin.rs2.idx = 6'd0;
    rin.rd.idx = 6'd0;
    rin.rs1.ready = 0;
    rin.rs2.ready = 0;
    rin.rd.ready = 0;
    next_count = count; // Başlangıçta mevcut count'u al
    next_arch2phy = arch2phy;
    next_prev2phy = prev2phy;
    next_busy_table = busy_table;
    next_free_list = free_list;
    prev_adres = 6'd0;
    if (p_commit_i.valid) begin
        prev_adres = next_prev2phy[p_commit_i.idx];
        next_free_list[prev_adres] = 1; // previous prf değeri free yapıldı
        next_busy_table[p_commit_i.idx] = 0; // busy değil
        next_count = next_count - 1; // free listte biri silindi full değil artık
    end 
    if(rin.rs1.valid == 1) begin
      rin.rs1.idx = next_arch2phy[din.rs1.idx]; 
      rin.rs1.ready = ~next_busy_table[rin.rs1.idx];   
    end
    else begin
      rin.rs1.idx = 6'd0;
      rin.rs1.ready = 1; // valid değilse ready olup olmaması önemli 
    end
    if(rin.rs2.valid == 1) begin
      rin.rs2.idx = next_arch2phy[din.rs2.idx];    
      rin.rs2.ready = ~next_busy_table[rin.rs2.idx];
    end
    else begin
      rin.rs2.idx = 6'd0;
      rin.rs2.ready = 1; // valid değilse ready olup olmaması önemli 
    end  
    if(din.rd.valid == 0) begin // valid değilse 
      rin.rd.idx = 6'd0; // valid değilse direkt sıfır ata
      rin.rd.ready = 1; // valid değilse ready olup olmaması önemli 
    end
    else begin // valid ise
      if(din.valid == 1) begin // din valid ise 
        if(din.rd.idx == 5'd0) begin // rd x0 ise 
          rin.rd.idx = 6'd0;
          rin.rd.ready = 1;
        end
        else begin // x0 değilse
          for (int i=1; i<64; ++i) begin // 0'ı dahil etmeye gerek yok
            if(free_list[i] == 1) begin // free bir prf bulundu atama olacak // çalışırsa fifo yap
              rin.rd.idx = 6'(i);
              next_count = next_count + 1; // sadece buradan arttır
              next_free_list[i] = 0; // artık free değil
              next_prev2phy[i] = next_arch2phy[din.rd.idx]; // güncel prf adresine previous prf adresini attım
              next_arch2phy[din.rd.idx] = 6'(i); //rename table da yeni atama oldu // i integer olduğu için 32 bit, böyle yapmakta fayda var
              next_busy_table[i] = 1; // artık busy
              rin.rd.ready = 0;
              break;
            end
          end
        end
      end   
    end
    end  


  assign rinstr_o = rin;// combinational output 
  assign rn_full_o = rn_full;


  always_ff @(posedge clk) begin  // sequential output
    if (!rst_ni) begin
      free_list[0] <= 0; // sıfır hiçbir zaman free değil 
      count <= 6'd31;
      for (int i=32; i<64; ++i) begin
        free_list[i] <= 1; // resette her architectural adresini aynı physical adrese attığım için ilk 32 tanesi free değil. sonraki 32 tane free. 
        busy_table[i] <= 0;
      end
      for (int i=0; i<32; ++i) begin
        arch2phy[i] <= 6'(i); // resette her architectural adresini aynı physical adrese attım
        prev2phy[i] <= 0;
        free_list[i] <= 0; // resette her architectural adresini aynı physical adrese attığım için ilk 31 tanesi free değil
        busy_table[i] <= 0;
      end
    end else  begin
      count <= next_count;
      free_list <= next_free_list;
      busy_table <= next_busy_table;
      prev2phy <= next_prev2phy;
      arch2phy <= next_arch2phy;
    end 
  end
endmodule

