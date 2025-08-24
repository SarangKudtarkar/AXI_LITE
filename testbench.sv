`timescale 1ns / 1ps

module axi4_lite_top_tb();

    logic           ACLK_tb;
    logic           ARESETN_tb;
    logic           read_s_tb;
    logic           write_s_tb;
    logic [31:0]    address_tb;
    logic [31:0]    W_data_tb;

    wire  [31:0]    read_data_out_tb;
    wire            read_valid_out_tb;

    axi4_lite_top u_axi4_lite_top0 (
        .ACLK(ACLK_tb),
        .ARESETN(ARESETN_tb),
        .read_s(read_s_tb),
        .write_s(write_s_tb),
        .address(address_tb),
        .W_data(W_data_tb),
        .read_data_out(read_data_out_tb),
        .read_valid_out(read_valid_out_tb)
    );

    initial begin
        $display("=== AXI4-Lite Test Started ===");

        // Init
        ACLK_tb = 0;
        ARESETN_tb = 0;
        read_s_tb = 0;
        write_s_tb = 0;
        address_tb = 0;
        W_data_tb = 0;

        #20;
        ARESETN_tb = 1;

        // WRITE TRANSACTION
        #10;
        write_s_tb = 1;
        address_tb = 7;
        W_data_tb = 32'hDEADBEE;
        #10;
        write_s_tb = 0;

        $display("[%0t ns] WRITE: Address = 0x%0h, Data = 0x%0h", $time, address_tb, W_data_tb);

        // Wait for write to settle
        #30;

        // READ TRANSACTION
        read_s_tb = 1;
        address_tb = 7;
        #10;
        read_s_tb = 0;

        $display("[%0t ns] READ REQUEST: Address = 0x%0h", $time, address_tb);

        // Wait for read_valid and display value
        wait (read_valid_out_tb);
        $display("[%0t ns] READ RESPONSE: Data = 0x%0h", $time, read_data_out_tb);

        #20;
      
      	ARESETN_tb = 1;

        // WRITE TRANSACTION
        #10;
        write_s_tb = 1;
        address_tb = 7;
        W_data_tb = 32'hDEADBE0;
        #10;
        write_s_tb = 0;

        $display("[%0t ns] WRITE: Address = 0x%0h, Data = 0x%0h", $time, address_tb, W_data_tb);

        // Wait for write to settle
        #30;

        // READ TRANSACTION
        read_s_tb = 1;
        address_tb = 7;
        #10;
        read_s_tb = 0;

        $display("[%0t ns] READ REQUEST: Address = 0x%0h", $time, address_tb);

        // Wait for read_valid and display value
        wait (read_valid_out_tb);
        $display("[%0t ns] READ RESPONSE: Data = 0x%0h", $time,	read_data_out_tb);

        #20;
      
      
        $display("=== AXI4-Lite Test Completed ===");
        $finish;
    end

    // Clock generation
    always #5 ACLK_tb = ~ACLK_tb;

endmodule
