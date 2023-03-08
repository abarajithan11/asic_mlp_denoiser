`timescale 1ns/1ps

module mlp_98 #(
  parameter   N1 = 98,
              N2 = 20,
              W_X = 4,
              W_K = 4,
              D1  = $clog2(N1/2),
              D2  = $clog2(N2),
  localparam  W_A_MAG_MUL = W_X + W_K,
              W_A_MAG_SUM = W_A_MAG_MUL + $clog2(N1/2),
              W_A_POL_MUL = 1 + W_K,
              W_A_POL_SUM = W_A_POL_MUL + $clog2(N1/2),
              W_A_SUM     = W_A_MAG_SUM,
              W_Y_MUL     = W_A_SUM + W_K,
              W_Y_SUM     = W_Y_MUL + $clog2(N2) 
)(
  input  logic clk,
  input  logic [N1/2-1:0][W_X-1:0] in_mag,
  input  logic [N1/2-1:0]          in_pol,
  output logic [W_Y_SUM-1:0]       out
);

  logic [W_K-1:0] weights_n1_load [N2 * N1];
  logic [N1/2-1:0][N2-1:0][W_K-1:0] weights_n1_mag, weights_n1_pol;
  logic [W_K-1:0]                   weights_n2 [N2-1:0];

  initial begin
    $readmemh("weights_n1.mem", weights_n1_load);
    $readmemh("weights_n2.mem", weights_n2);
  end

  always_comb
    for (int n2=0; n2 < N2; n2=n2+1)
      for (int n1=0; n1 < N1/2; n1=n1+1) begin
        weights_n1_mag[n1][n2] = weights_n1_load[n2*N1 + n1];
        weights_n1_pol[n1][n2] = weights_n1_load[n2*N1 + n1 + N1/2];
      end

  logic [D1  :0][N1/2-1:0][N2-1:0][W_A_POL_SUM-1:0] a_pol_tree_i, a_pol_tree_o;
  logic [D1  :0][N1/2-1:0][N2-1:0][W_A_MAG_SUM-1:0] a_mag_tree_i, a_mag_tree_o;
  logic [N2-1:0][W_A_SUM-1:0] sum_a;

  logic [D2  :0][N2-1:0][W_Y_SUM-1:0] b_tree;

  genvar d, n1, n2, a;

`define MULTIPLY(RESULT, K, X) \
  RESULT <= (W_K==1) ? $signed(K ? -X : X) : $signed(K)*$signed(X)

  for (n2=0; n2<N2; n2=n2+1) begin: gN2
    for (n1=0; n1<N1/2; n1=n1+1) begin: gN1
      always_ff @(posedge clk) begin           // Register multipliers
        `MULTIPLY(a_mag_tree_o[0][n1][n2], weights_n1_mag[n1][n2], in_mag[n1]);
        `MULTIPLY(a_pol_tree_o[0][n1][n2], weights_n1_pol[n1][n2], in_pol[n1]);
      end
    end
      
    for (d=0; d<D1; d=d+1) begin: gD
      for (a=0; a<N1/2; a=a+1) begin: gA
        if (a<(N1/2)/2**(d+1)) begin: gR

          assign a_pol_tree_i[d+1][a][n2] = $signed(a_pol_tree_o[d][2*a][n2]) + $signed(a_pol_tree_o[d][2*a+1][n2]); 
          assign a_mag_tree_i[d+1][a][n2] = $signed(a_mag_tree_o[d][2*a][n2]) + $signed(a_mag_tree_o[d][2*a+1][n2]);

          always_ff @(posedge clk) begin
            a_pol_tree_o[d+1][a][n2] <= a_pol_tree_i[d+1][a][n2];
            a_mag_tree_o[d+1][a][n2] <= a_mag_tree_i[d+1][a][n2];
          end
        end else
          assign {a_pol_tree_o[d+1][a][n2], a_mag_tree_o[d+1][a][n2]} = '0;
      end
    end
    
    always_ff @(posedge clk)
      sum_a[n2] <= $signed(a_pol_tree_o[D1-1][0][n2]) + $signed(a_mag_tree_o[D1-1][0][n2]);


    always_ff @(posedge clk)           // Register multipliers
      `MULTIPLY(b_tree[0][n2], weights_n2[n2], sum_a[n2]);
  end
    
  for (d=0; d<D2; d=d+1) begin: D
    for (a=0; a<N2; a=a+1) begin: A
      if (a<N2/2**(d+1)) begin: R
        always_ff @(posedge clk)
          b_tree[d+1][a] <= b_tree[d][2*a] + b_tree[d][2*a+1];
      end else 
        assign b_tree[d+1][a] = '0;
    end
  end
  
  assign out = b_tree[D2-1][0];

endmodule