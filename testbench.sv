`timescale 1ns/1ps

module axi4_lite_top_tb;
  
  //Clock and reset
  logic ACLK_tb;
  logic ARESETN_tb;
  //Stimulus
  logic read_s_tb;
  logic write_s_tb;
  logic [31:0] address_tb;
  logic [31:0] W_data_tb;
  
  //DUT Outputs
  wire [31:0] read_data_out_tb;
  wire read_valid_out_tb;
  
  
  // DUT Initialization
  axi4_lite_top u_axi_lite_top0(
    
    .ACLK (ACLK_tb),
    .ARESETN (ARESETN_tb),
    .read_s (read_s_tb),
    .write_s (write_s_tb),
    .address (address_tb),
    .W_data (W_data_tb),
    .read_data_out (read_data_out_tb),
    .read_valid_out (read_valid_out_tb)
    
  );
  
  //Clock generation
  initial ACLK_tb=0;
  always #5 ACLK_tb= ~ACLK_tb;
  
  
  //Reset task
  //automatic to ensure local var are not shared like static
  task automatic apply_reset();
    begin
      
      $display("AXI4-Lite reset started");

      ARESETN_tb=0;
      read_s_tb=0;
      write_s_tb=0;
      address_tb=0;
      W_data_tb=0;
      repeat (2) @(posedge ACLK_tb);
      ARESETN_tb=1;
      @(posedge ACLK_tb);
    end
  endtask
  
  
  task automatic axi_read(input [31:0] addr);
    begin
      @(posedge ACLK_tb);
      read_s_tb= 1;
      address_tb= addr;
      @(posedge ACLK_tb);
      read_s_tb= 0;
      $display("[%0t ns] READ REQUEST: Address = 0x%0h",$time,addr);
      wait(read_valid_out_tb);
      $display("[%0t ns] READ RESPONSE: Data = 0x%0h",$time,read_data_out_tb);
      @(posedge ACLK_tb);
           
    end
  
  endtask
  
  
  task automatic axi_write(input [31:0] addr,input [31:0] data);
    begin
      @(posedge ACLK_tb);
      write_s_tb= 1;
      address_tb= addr;
      W_data_tb= data;
      @(posedge ACLK_tb);
      write_s_tb= 0;
      $display("[%0t ns] Write: Address = 0x%0h, Data = 0x%0h",$time,addr,data);
      
      repeat (2) @(posedge ACLK_tb);
           
    end
  
  endtask
  
  initial begin 
    $dumpfile("axi4_lite.vcd");
    $dumpvars(0,u_axi_lite_top0);
    
    $display("AXI4-Lite test started");
    
    apply_reset();
    
    axi_write(32'h5,32'h5600034);
    axi_read(32'h5);
    
    axi_write(32'h5,32'h5600157);
    axi_read(32'h5);
    $finish;
  end
  
  
endmodule