module addr_calc #(parameter CAVIAR_X_Y_BITS = 9 )(
input [4:0]count,
input [CAVIAR_X_Y_BITS-1:0]input_addr_x,
input [CAVIAR_X_Y_BITS-1:0]input_addr_y,
output [CAVIAR_X_Y_BITS-1:0]addr1_x_out,
output [CAVIAR_X_Y_BITS-1:0]addr1_y_out,
output [CAVIAR_X_Y_BITS-1:0]addr2_x_out,
output [CAVIAR_X_Y_BITS-1:0]addr2_y_out
);


logic [CAVIAR_X_Y_BITS-1:0]addr1_x;
logic [CAVIAR_X_Y_BITS-1:0]addr1_y;
logic [CAVIAR_X_Y_BITS-1:0]addr2_x;
logic [CAVIAR_X_Y_BITS-1:0]addr2_y;

assign addr1_x_out = addr1_x;
assign addr1_y_out = addr1_y;
assign addr2_x_out = addr2_x;
assign addr2_y_out = addr2_y;

always_comb begin
    if ( count == 0)begin
        addr1_x = input_addr_x - 3;
        addr2_x = input_addr_x - 2;
        addr1_y = input_addr_y - 3;
        addr2_y = input_addr_y - 3;
    end
    else if ( count %7 == 3)begin
        addr1_x = input_addr_x + 2;
        addr2_x = input_addr_x - 4;
        addr1_y = input_addr_y;
        addr2_y = input_addr_y + 1;
    end    
    else if ( count %7 == 4 || count %7 == 0)begin
        addr1_x = input_addr_x - 5;
        addr2_x = input_addr_x - 4;
        addr1_y = input_addr_y + 1;
        addr2_y = input_addr_y + 1;
    end
    else begin
        addr1_x = input_addr_x + 2;
        addr2_x = input_addr_x + 3;
        addr1_y = input_addr_y;
        addr2_y = input_addr_y;
    end    
    
end

endmodule