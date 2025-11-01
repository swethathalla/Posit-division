module PLAD #(parameter SIZE = 16) (
    input [SIZE-1:0] X1, 
    input [SIZE-1:0] X2, 
    output [SIZE-1:0] res,
    output exp1
);
    wire [SIZE-1:0] masked0_1, masked0_2, approximate1;
    m_divider #(16,16) d1( X1 , X2 , approximate1 , masked0_1 , masked0_2 );

    wire [SIZE-1:0] masked1_1, masked1_2, approximate2;
    m_divider #(16,16) d2( masked0_1 , masked0_2 , approximate2 , masked1_1 , masked1_2 );

    wire [SIZE-1:0] res_added, res_shifted;
    wire [1:0] extra;

    // Subtraction instead of addition
    assign {extra , res_added} = {1'b1,X1} - X2 + approximate1 + approximate2;

    // Normalization shift
    assign res_shifted = {extra[0], res_added[SIZE-1:1]} ;

    wire must_shift; 
    or shifter_or(must_shift, extra[0], extra[1]);
    mux_nbit #(SIZE) mux_final (res_added, res_shifted, extra[1], res);
    assign exp1 = must_shift;

    initial begin
        $dumpfile("test_div.vcd");
        $dumpvars(0, X1, X2, res, exp1, res_shifted, res_added, approximate1, approximate2);
    end
endmodule
