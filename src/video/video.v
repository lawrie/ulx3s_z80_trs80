`default_nettype none
module video (
  input         clk,
  input         reset,
  output [7:0]  vga_r,
  output [7:0]  vga_b,
  output [7:0]  vga_g,
  output        vga_hs,
  output        vga_vs,
  output        vga_de,
  input  [7:0]  vga_data,
  output [9:0]  vga_addr
);

  parameter HA = 640;
  parameter HS  = 96;
  parameter HFP = 16;
  parameter HBP = 48;
  parameter HT  = HA + HS + HFP + HBP;
  parameter HB = 64;
  parameter HB2 = HB/2; // NOTE pixel coarse H-adjust
  parameter HBadj = 0; // NOTE border H-adjust

  parameter VA = 480;
  parameter VS  = 2;
  parameter VFP = 11;
  parameter VBP = 31;
  parameter VT  = VA + VS + VFP + VBP;
  parameter VB = 48;
  parameter VB2 = VB/2;

  wire [11:0] font_addr;
  wire [7:0] font_line;

  rom #(
    .MEM_INIT_FILE("../roms/charrom.mem"),
    .DEPTH(4 * 1024)
   ) char_rom (
    .clk(clk),
    .addr(font_addr),
    .dout(font_line)
  );

  reg [9:0] hc = 0;
  reg [9:0] vc = 0;

  reg [3:0] row = 0;
  reg [3:0] line = 0;

  reg R_vga_hs, R_vga_vs, R_vga_hde, R_vga_vde;

  always @(posedge clk) begin
    if (hc == HT - 1) begin
      hc <= 0;
      if (vc == VT - 1) vc <= 0;
      else vc <= vc + 1;
    end else hc <= hc + 1;

    if (hc == 0) begin
      if (vc[0]) begin
        if (line == 11) begin
          line <= 0;
          row <= row + 1;
        end else begin
          line <= line + 1;
        end
      end

      if (vc == VB - 1) begin
        row <= 0;
        line <= 0;
      end
    end

    case (hc)
      0           : R_vga_hde <= 1;
      HA          : R_vga_hde <= 0;
      HA+HFP      : R_vga_hs  <= 1;
      HA+HFP+HS-1 : R_vga_hs  <= 0;
    endcase

    case(vc)
      0           : R_vga_vde <= 1;
      VA          : R_vga_vde <= 0;
      VA+VFP      : R_vga_vs  <= 1;
      VA+VFP+VS-1 : R_vga_vs  <= 0;
    endcase
  end

  assign vga_hs = !R_vga_hs;
  assign vga_vs = !R_vga_vs;
  assign vga_de = R_vga_hde && R_vga_vde;

  wire [8:0] x = hc - HB;
  wire [6:0] y = vc[9:1] - VB2;

  wire hBorder = (hc < (HB + HBadj) || hc >= (HA - HB + HBadj));
  wire vBorder = (vc < VB || vc >= VA - VB);
  wire border = hBorder || vBorder;

  assign vga_addr = {row, x[8:3]};

  wire [7:0] char_adjust = 
	  vga_data[5] == 0 && vga_data[7] == 0 ? vga_data | 8'h40 :
                                                 vga_data;
  assign font_addr = {char_adjust, line};

  reg [7:0] R_pixel;
  always @(posedge clk) R_pixel <= {8{font_line[~x[2:0]]}};
  
  assign vga_r = !vga_de | border ? 8'b0 : R_pixel;
  assign vga_g = !vga_de | border ? 8'b0 : R_pixel;
  assign vga_b = !vga_de | border ? 8'b0 : R_pixel;

endmodule
