module m_divider #(parameter SIZE = 16, parameter truncation = 16)
    ( input [SIZE-1:0] X1, 
      input [SIZE-1:0] X2, 
      output [SIZE-1:0] res, 
      output [SIZE-1:0] masked1, 
      output [SIZE-1:0] masked2 );

    localparam length = $clog2(SIZE);

    wire [length-1:0] l1, l2;
    wire [SIZE-1:0] l1_exp, l2_exp;

    // Leading-One Detection
    lod #(SIZE) lod1( X1, l1_exp );
    lod #(SIZE) lod2( X2, l2_exp );

    // Masking
    mask #(SIZE) mask1 ( X1 , l1_exp , masked1 );
    mask #(SIZE) mask2 ( X2 , l2_exp , masked2 );

    // Encoding
    encoder encoder1 ( l1_exp , l1 );
    encoder encoder2 ( l2_exp , l2 );

    // Logarithmic shift approximations
    wire [SIZE-1:0] ans1, ans2;
    log_shifter_R #(4, truncation) shifter1 ( masked1 , l2 , ans1 );
    log_shifter_R #(4, truncation) shifter2 ( X2 , l1 , ans2 );

    // Difference instead of addition (division)
    subtractor #(SIZE) sub1(ans1, ans2, res);
    // OR use: assign res = ans1 - ans2;

    initial begin
        $dumpfile("test_div.vcd");
        $dumpvars(0, X1, X2, l1, l2, ans1, ans2, l1_exp, l2_exp);
    end
endmodule
