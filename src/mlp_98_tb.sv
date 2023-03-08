module mlp_98_tb;
  timeunit 1ns/1ps;

  localparam  CLK_PERIOD = 10,
              N1 = 98,
              N2 = 20,
              W_X = 4,
              W_K = 4,
              D1  = $clog2(N1/2),
              D2  = $clog2(N2),
              W_A_MAG_MUL = W_X + W_K,
              W_A_MAG_SUM = W_A_MAG_MUL + $clog2(N1/2),
              W_A_POL_MUL = 1 + W_K,
              W_A_POL_SUM = W_A_POL_MUL + $clog2(N1/2),
              W_A_SUM     = W_A_MAG_SUM,
              W_Y_MUL     = W_A_SUM + W_K,
              W_Y_SUM     = W_Y_MUL + $clog2(N2);

  logic clk=0;
  logic [N1/2-1:0][W_X-1:0] in_mag;
  logic [N1/2-1:0]          in_pol;
  logic [W_Y_SUM -1:0]      out;
  int status;

  initial forever #(CLK_PERIOD/2) clk <= ~clk;
  mlp_98 #(.N1(N1),.N2(N2),.W_X(W_X),.W_K(W_K),.D1(D1),.D2(D2)) dut (.*);

  initial begin
    status = std::randomize(in_mag);
    status = std::randomize(in_pol);

    repeat (100) @(posedge clk);
  end

endmodule