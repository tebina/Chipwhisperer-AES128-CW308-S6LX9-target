//////////////////////////////////////////////////////////////////////////////////
// General Top-Level Module for Spartan 6 LX9 Target
// For use with CW308 breakout board
//
//////////////////////////////////////////////////////////////////////////////////

module CW308T_S6LX9_Example(
    input clk,
    output clk2,
    output TxD,
    input RxD,
    inout IO3,
    inout IO4,
    output LED1,
    output LED2,
    output LED3,
    inout H1,
    inout H2,
    inout H3,
    inout H4,
    inout H5,
    inout H6,
    inout H7,
    inout H8,
    inout H9,
    inout H10,
    input PDIC,
    input PDID,
    input nRST,
    input SCK,
    output MISO,
    input MOSI
  );

  assign clk2 = 1'b0;
  assign MISO = 1'b0;

  assign H1 = 1'bZ;
  assign H2 = 1'bZ;
  assign H3 = 1'bZ;
  assign H4 = 1'bZ;
  assign H5 = 1'bZ;
  assign H6 = 1'bZ;
  assign H7 = 1'bZ;
  assign H8 = 1'bZ;
  assign H9 = 1'bZ;
  assign H10 = 1'bZ;

  assign LED3 = 1'b1;

  wire [127:0] enc_input; 	//Input to encryption algorithm (normally PT)
  wire [127:0] enc_output; 	//Output from encryption algorithm (normally CT)
  wire [127:0] enc_key; 		//Encryption key to use
  wire load_input; 			//One-clock cycle flag to indicate data in enc_input is valid
  wire load_key; 				//One-cycle flag to indicate data in enc_input is valid
  wire enc_go; 					//One-cycle flag to indicate we should run an encryption
  wire enc_output_ready; 	//One-cycle flag generated by encryption core indicating data out is valid

  SimpleSerial SSCore(.clk(clk), .TxD(TxD), .RxD(RxD), .LED_rx(LED1), .LED_go(LED2),
                      .pt(enc_input), .key(enc_key), .load_key(load_key), .load_pt(load_input),
                      .do_enc(enc_go), .ct(enc_output), .ct_ready(enc_output_ready));

  /* Loopback test */
  //assign enc_output = enc_input;
  //assign load_input = enc_output_ready;

  wire enc_busy;
  assign IO4 = enc_busy;
  /* To use this example AES core:
  	 - We need to generate our own flag indicating when output data is valid
  */
  //	aes_core AESGoogleVault(
  //		.clk(clk),
  //		.load_i(enc_go),
  //		.key_i({enc_key, 128'h0}),
  //		.data_i(enc_input),
  //		.size_i(2'd0),
  //		.dec_i(1'b0),
  //		.data_o(enc_output),
  //		.busy_o(enc_busy)
  //	);

  SBox128_top SBox128_top(
                .SYS_CLK(clk),
                .RST(1'b0),
                .PLAINTEXT_IN(enc_input),
                .KEY_IN(enc_key),
                .START(enc_go),
                .KEY_LOAD(load_key),
                .DONE(enc_output_ready),
                .BUSY(enc_busy),
                .CIPHERTEXT_OUT(enc_output)
              );



endmodule
