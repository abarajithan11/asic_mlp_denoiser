module memory_init();

parameter integer DVS_WIDTH = 346; 
parameter integer DVS_HEIGHT = 260; 
parameter integer WORD_SIZE = 18;
parameter integer CAVIAR_X_Y_BITS = 9; 
parameter integer TIMESTAMP_BITS = 16; 
parameter integer POLARITY_BITS = 2; 

//logic [WORD_SIZE-1:0]input_file_buffer[0:DVS_WIDTH-1][0:DVS_HEIGHT-1];
reg [WORD_SIZE-1:0]Memory[0:1][0:1];
reg clk;
integer i;
integer j;
// clock generator
always begin
    #1 clk = 1'b1;
    #1 clk = 1'b0;
end

initial $readmemh("/home/keerthivasan/Downloads/hls4ml/create_mlp_activations/input_data.txt", Memory);

initial begin 

//Populating Memory 
for(  i = 0; i < 2; i = i+1 )begin
    for(  j = 0; j < 2; j = j+ 1)begin
        $display("%d\n",Memory[i][j]);
    end
end   
end

endmodule






