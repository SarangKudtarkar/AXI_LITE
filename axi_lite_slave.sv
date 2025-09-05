module axi4_lite_slave #(
  parameter ADDRESS=32,
  parameter DATA_WIDTH=32
)
  (
   	//Global signal
    input ACLK,
    input ARESETN,
    
    
    //Read Address Channel outputs
    output logic S_ARREADY,
    //Read Data Channel outputs
    output logic [DATA_WIDTH-1:0] S_RDATA,
    output logic [1:0] S_RRESP,
    output logic S_RVALID,
    //Write Address Channel outputs
    output logic S_AWREADY,
    output logic S_WREADY,
    //Write Response Channel outputs
    output logic S_BRESP,
    output logic S_BVALID,

    //Read Address Channel inputs
    input [ADDRESS-1:0] S_ARADDR,
    input S_ARVALID,
	
    //Read Data Channel inputs
    input S_RREADY,

    //Write Address Channel inputs
    input [ADDRESS-1:0] S_AWADDR,
    input  S_AWVALID,
    
    //Write Data Channel inputs
    input [DATA_WIDTH-1:0] S_WDATA,
    input [3:0] S_WSTRB,
    input S_WVALID,

    //Write Response Channel inputs
    input S_BREADY
    
  );
  
  localparam no_of_registers = 32;
  
  logic write_addr,write_data;
  logic [ADDRESS-1:0] addr;
  logic [DATA_WIDTH-1:0] register [no_of_registers-1:0];
  
  
  typedef enum logic [2:0] {IDLE,WRITE_CHANNEL,WRESP_CHANNEL,RADDR_CHANNEL, RDATA_CHANNEL} state_type;
  
  state_type state,next_state;
  
  //ar
  assign S_ARREADY= (state== RADDR_CHANNEL)?1:0;
  //r
  assign S_RDATA= (state==RDATA_CHANNEL)? register[addr]:32'h0;
  assign S_RVALID= (state==RDATA_CHANNEL)? 1:0;
  //Todo response code
  assign S_RRESP= (state==RDATA_CHANNEL)? 2'b00:0;
  //AW
 
  assign S_AWREADY= (state==WRITE_CHANNEL)? 1:0;
  //W
  assign S_WREADY= (state==WRITE_CHANNEL)? 1:0;
  assign write_addr= S_AWVALID && S_AWREADY;
  assign write_data= S_WVALID && S_WREADY; 
  //B
  assign S_BVALID= (state==WRESP_CHANNEL)? 1:0;
  //Todo response code
  assign S_RESP= (state==WRESP_CHANNEL)? 0:0;
  
  integer i;
  
  always_ff @(posedge ACLK) begin
    if(~ARESETN) begin
      for(i=0;i<32;i++) begin
        register[i]<=32'b0;
      end
    end else begin
      if(state== WRITE_CHANNEL) begin
        register[S_AWADDR]<= S_WDATA;
      end
      else if(state== RADDR_CHANNEL) begin
        addr<=S_ARADDR;
        
      end
    end
  end  
  
  
  always_ff @(posedge ACLK) begin
    if(~ARESETN) begin
      state<= IDLE;
    end else begin
      state<= next_state;
    end
  end
  

  
  always_comb begin
    
    case(state)
      
      IDLE: begin
        if (S_AWVALID) begin
          next_state=WRITE_CHANNEL;
        end else if (S_ARVALID) begin
          next_state=RADDR_CHANNEL;
        end else begin
          next_state=IDLE;
          
        end
      end
      RADDR_CHANNEL: begin
        if (S_ARVALID && S_ARREADY) begin
          next_state= RDATA_CHANNEL;
        end
      end
      RDATA_CHANNEL: begin
        if (S_RVALID && S_RREADY) begin
          next_state= IDLE;
        end
      end
      WRITE_CHANNEL: begin
        if (write_addr && write_data) begin
          next_state= WRESP_CHANNEL;
        end        
      end
      WRESP_CHANNEL: begin
        if (S_BVALID && S_BREADY) begin
          next_state= IDLE;
        end       
      end
      default: next_state= IDLE;
      
      
    endcase
    
    
  end
  
  
endmodule