module flag_check(input[2:0] C, input[2:0] flag, output cond_passD);
    wire N, V, Z;
    assign {N, V, Z} = flag;
    reg willBranch;
    always @(C, F) begin
        case (C)
            3'b000: willBranch = ~Z;
            3'b001: willBranch = Z;
            3'b010: willBranch = ~Z & ~N;
            3'b011: willBranch = N;
            3'b100: willBranch = Z | (~Z & ~N);
            3'b101: willBranch = N | Z;
            3'b110: willBranch = V;
            3'b111: willBranch = 1'b1;
            default: willBranch = 1'b0;
        endcase
    end
    assign cond_passD = willBranch;
endmodule
