module 3to8_Decoder(input[2:0] Offset, output[7:0]Decoded_Offset);
  assign Decoded_Offset = (Offset == 3'd0) ? 8'h01:
                          (Offset == 3'd1) ? 8'h02:
                          (Offset == 3'd2) ? 8'h04:
                          (Offset == 3'd3) ? 8'h08:
                          (Offset == 3'd4) ? 8'h10:
                          (Offset == 3'd5) ? 8'h20:
                          (Offset == 3'd6) ? 8'h40:
                          (Offset == 3'd7) ? 8'h80:
                          8'h0;
endmodule
