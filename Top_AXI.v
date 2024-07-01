//=============================================================================
//
//Module Name:					Top_AXI.v

//Function Description:	          将master，slave，AXI Interconnect集成
//
//=============================================================================

`timescale 1ns/1ns

module Top_AXI(
	  /********* 时钟&复位 *********/
	input               sys_clk ,
	input      	        sys_rstn,
    input [1:0]	        num_order_w_0,
    input [1:0]	        num_order_r_0,
    input      	        en_w_0,
    input      	        en_r_0,
    input [7:0]	        awlen_0,
    input [7:0]	        arlen_0,
    input [31:0]	    addr_start_w0,
    input [31:0]        addr_start_r0,
    input [1:0]	        num_order_w_1,
    input [1:0]	        num_order_r_1,
    input      	        en_w_1,
    input      	        en_r_1,
    input [7:0]	        awlen_1,
    input [7:0]	        arlen_1,
    input [3:0]	        ARID_0,
    input [3:0]	        ARID_1,
    input [31:0]        addr_start_w1,
    input [31:0]        addr_start_r1
);

     //=========================================================
    //0号主机信号
    wire  [3:0]    m0_awid;
    wire  [31:0]   m0_awaddr;
    wire  [7:0]    m0_awlen;
    wire           m0_awvalid;
    wire           m0_awready;

    wire  [3:0]    m0_wid;
    wire  [31:0]   m0_wdata;
    wire           m0_wlast;
    wire           m0_wvalid;
    wire           m0_wready;

    wire  [3:0]    m0_bid;
    wire           m0_bvalid;
    wire           m0_bready;
    
    wire  [3:0]    m0_arid;
    wire  [31:0]   m0_araddr;
    wire  [7:0]    m0_arlen;
    wire           m0_arvalid;
    wire           m0_arready;

    wire  [3:0]	   m0_rid;
    wire  [31:0]   m0_rdata;
    wire           m0_rlast;
    wire           m0_rvalid;
    wire           m0_rready;
    wire  [31:0]   data_out_0;
    wire           data_out_vld_0;

     //=========================================================
    //0号主机信号
    wire  [3:0]    m1_awid;
    wire  [31:0]   m1_awaddr;
    wire  [7:0]    m1_awlen;
    wire           m1_awvalid;
    wire           m1_awready;

    wire  [3:0]    m1_wid;
    wire  [31:0]   m1_wdata;
    wire           m1_wlast;
    wire           m1_wvalid;
    wire           m1_wready;

    wire  [3:0]    m1_bid;
    wire           m1_bvalid;
    wire           m1_bready;
    
    wire  [3:0]    m1_arid;
    wire  [31:0]   m1_araddr;
    wire  [7:0]    m1_arlen;
    wire           m1_arvalid;
    wire           m1_arready;

    wire  [3:0]	   m1_rid;
    wire  [31:0]   m1_rdata;
    wire           m1_rlast;
    wire           m1_rvalid;
    wire           m1_rready;
    wire  [31:0]   data_out_1;
    wire           data_out_vld_1;

     //=========================================================
    //0号从机信号
    wire  [3:0]    s0_awid;
    wire  [31:0]   s0_awaddr;
    wire  [7:0]    s0_awlen;
    wire 		   s0_awvalid;
    wire 		   s0_awready;

	wire  [3:0]    s0_wid;
    wire  [31:0]   s0_wdata;
    wire           s0_wlast;
	wire 		   s0_wvalid;
    wire    	   s0_wready;

	wire  [3:0]    s0_bid;
    wire           s0_bvalid;
	wire 		   s0_bready;

	wire  [3:0]	   s0_arid;  
    wire  [31:0]   s0_araddr;
    wire  [7:0]    s0_arlen;
    wire  	       s0_arvalid;
    wire           s0_arready;

	wire  [3:0]	   s0_rid;
	wire  [31:0]   s0_rdata;
	wire 		   s0_rlast;
	wire		   s0_rvalid; 
    wire           s0_rready; 

     //=========================================================
    //1号从机信号
    wire  [3:0]    s1_awid;
    wire  [31:0]   s1_awaddr;
    wire  [7:0]    s1_awlen;
    wire 		   s1_awvalid;
    wire 		   s1_awready;

	wire  [3:0]    s1_wid;
    wire  [31:0]   s1_wdata;
    wire           s1_wlast;
	wire 		   s1_wvalid;
    wire    	   s1_wready;

	wire  [3:0]    s1_bid;
    wire           s1_bvalid;
	wire 		   s1_bready;

	wire  [3:0]	   s1_arid;  
    wire  [31:0]   s1_araddr;
    wire  [7:0]    s1_arlen;
    wire  	       s1_arvalid;
    wire           s1_arready;

	wire  [3:0]	   s1_rid;
	wire  [31:0]   s1_rdata;
	wire 		   s1_rlast;
	wire		   s1_rvalid; 
    wire           s1_rready; 
    
     //=========================================================
    //2号从机信号
    wire  [3:0]    s2_awid;
    wire  [31:0]   s2_awaddr;
    wire  [7:0]    s2_awlen;
    wire 		   s2_awvalid;
    wire 		   s2_awready;

	wire  [3:0]    s2_wid;
    wire  [31:0]   s2_wdata;
    wire           s2_wlast;
	wire 		   s2_wvalid;
    wire    	   s2_wready;

	wire  [3:0]    s2_bid;
    wire           s2_bvalid;
	wire 		   s2_bready;

	wire  [3:0]	   s2_arid;  
    wire  [31:0]   s2_araddr;
    wire  [7:0]    s2_arlen;
    wire  	       s2_arvalid;
    wire           s2_arready;

	wire  [3:0]	   s2_rid;
	wire  [31:0]   s2_rdata;
	wire 		   s2_rlast;
	wire		   s2_rvalid; 
    wire           s2_rready; 
    

     //=========================================================
    //0号主机例化
    AXI_Master u0_AXI_Master(
        .sys_clk      (sys_clk),
        .sys_rstn     (sys_rstn),
  
        .awid         (m0_awid),
        .awaddr       (m0_awaddr),
        .awlen        (m0_awlen),
        .awvalid      (m0_awvalid),
        .awready      (m0_awready),
  
        .wid          (m0_wid),
        .wdata        (m0_wdata),
        .wlast        (m0_wlast),
        .wvalid       (m0_wvalid),
        .wready       (m0_wready),
  
        .bid          (m0_bid),
        .bvalid       (m0_bvalid),
        .bready       (m0_bready),
  
        .arid         (m0_arid),
        .araddr       (m0_araddr),
        .arlen        (m0_arlen),
        .arvalid      (m0_arvalid),
        .arready      (m0_arready),
  
        .rid          (m0_rid),
        .rdata        (m0_rdata),
        .rlast        (m0_rlast),
        .rvalid       (m0_rvalid),
        .rready       (m0_rready),

        .num_order_w    (num_order_w_0),
        .num_order_r    (num_order_r_0),
        .en_w         (en_w_0),
        .en_r         (en_r_0),
        .AWLEN        (awlen_0),
        .ARLEN        (arlen_0),
        .addr_start_w (addr_start_w0),
        .addr_start_r (addr_start_r0),
        .ARID         (ARID_0),
        .data_out     (data_out_0),
        .data_out_vld (data_out_vld_0)
    );

     //=========================================================
    //1号主机例化
    AXI_Master u1_AXI_Master(
        .sys_clk      (sys_clk),
        .sys_rstn     (sys_rstn),
  
        .awid         (m1_awid),
        .awaddr       (m1_awaddr),
        .awlen        (m1_awlen),
        .awvalid      (m1_awvalid),
        .awready      (m1_awready),
  
        .wid          (m1_wid),
        .wdata        (m1_wdata),
        .wlast        (m1_wlast),
        .wvalid       (m1_wvalid),
        .wready       (m1_wready),
  
        .bid          (m1_bid),
        .bvalid       (m1_bvalid),
        .bready       (m1_bready),
  
        .arid         (m1_arid),
        .araddr       (m1_araddr),
        .arlen        (m1_arlen),
        .arvalid      (m1_arvalid),
        .arready      (m1_arready),
  
        .rid          (m1_rid),
        .rdata        (m1_rdata),
        .rlast        (m1_rlast),
        .rvalid       (m1_rvalid),
        .rready       (m1_rready),

        .num_order_w  (num_order_w_1),
        .num_order_r  (num_order_r_1),
        .en_w         (en_w_1),
        .en_r         (en_r_1),
        .AWLEN        (awlen_1),
        .ARLEN        (arlen_1),
        .addr_start_w (addr_start_w1),
        .addr_start_r (addr_start_r1),
        .ARID         (ARID_1),
        .data_out     (data_out_1),
        .data_out_vld (data_out_vld_1)
    );

    //=========================================================
    //AXI4连接器例化
    AXI_Interconnect u_AXI_Interconnect (
    .sys_clk                 ( sys_clk   ),
    .sys_rstn                ( sys_rstn  ),
    .m0_awid                 ( m0_awid   ),
    .m0_awaddr               ( m0_awaddr ),
    .m0_awlen                ( m0_awlen  ),
    .m0_awsize               (  ),
    .m0_awburst              ( ),
    .m0_awvalid              ( m0_awvalid),
    .m0_wid                  ( m0_wid    ),
    .m0_wdata                ( m0_wdata  ),
    .m0_wstrb                (   ),
    .m0_wlast                ( m0_wlast  ),
    .m0_wvalid               ( m0_wvalid ),
    .m0_bready               ( m0_bready ),
    .m0_arid                 ( m0_arid   ),
    .m0_araddr               ( m0_araddr ),
    .m0_arlen                ( m0_arlen  ),
    .m0_arsize               (  ),
    .m0_arburst              ( ),
    .m0_arvalid              ( m0_arvalid),
    .m0_rready               ( m0_rready ),
    .m1_awid                 ( ),
    .m1_awaddr               ( ),
    .m1_awlen                ( ),
    .m1_awsize               ( ),
    .m1_awburst              ( ),
    .m1_awvalid              ( ),
    .m1_wid                  ( ),
    .m1_wdata                ( ),
    .m1_wstrb                ( ),
    .m1_wlast                ( ),
    .m1_wvalid               ( ),
    .m1_bready               ( ),
    .m1_arid                 ( ),
    .m1_araddr               ( ),
    .m1_arlen                ( ),
    .m1_arsize               ( ),
    .m1_arburst              ( ),
    .m1_arvalid              ( ),
    .m1_rready               ( ),
    .m2_awid                 ( ),
    .m2_awaddr               ( ),
    .m2_awlen                ( ),
    .m2_awsize               ( ),
    .m2_awburst              ( ),
    .m2_awvalid              ( ),
    .m2_wid                  ( ),
    .m2_wdata                ( ),
    .m2_wstrb                ( ),
    .m2_wlast                ( ),
    .m2_wvalid               ( ),
    .m2_bready               ( ),
    .m2_arid                 ( ),
    .m2_araddr               ( ),
    .m2_arlen                ( ),
    .m2_arsize               ( ),
    .m2_arburst              ( ),
    .m2_arvalid              ( ),
    .m2_rready               ( ),
    .s0_awready              ( s0_awready),
    .s0_wready               ( s0_wready ),
    .s0_bid                  ( s0_bid    ),
    .s0_bresp                (   ),
    .s0_bvalid               ( s0_bvalid ),
    .s0_arready              ( s0_arready),
    .s0_rid                  ( s0_rid    ),
    .s0_rdata                ( s0_rdata  ),
    .s0_rresp                (   ),
    .s0_rlast                ( s0_rlast  ),
    .s0_rvalid               ( s0_rvalid ),
    .s1_awready              ( s1_awready),
    .s1_wready               ( s1_wready ),
    .s1_bid                  ( s1_bid    ),
    .s1_bresp                (   ),
    .s1_bvalid               ( s1_bvalid ),
    .s1_arready              ( s1_arready),
    .s1_rid                  ( s1_rid    ),
    .s1_rdata                ( s1_rdata  ),
    .s1_rresp                (   ),
    .s1_rlast                ( s1_rlast  ),
    .s1_rvalid               ( s1_rvalid ),
    .s2_awready              ( s2_awready),
    .s2_wready               ( s2_wready ),
    .s2_bid                  ( s2_bid    ),
    .s2_bresp                (   ),
    .s2_bvalid               ( s2_bvalid ),
    .s2_arready              ( s2_arready),
    .s2_rid                  ( s2_rid    ),
    .s2_rdata                ( s2_rdata  ),
    .s2_rresp                (   ),
    .s2_rlast                ( s2_rlast  ),
    .s2_rvalid               ( s2_rvalid ),

    .m0_awready              ( m0_awready),
    .m0_wready               ( m0_wready ),
    .m0_bid                  ( m0_bid    ),
    .m0_bresp                (   ),
    .m0_bvalid               ( m0_bvalid ),
    .m0_arready              ( m0_arready),
    .m0_rid                  ( m0_rid    ),
    .m0_rdata                ( m0_rdata  ),
    .m0_rresp                (   ),
    .m0_rlast                ( m0_rlast  ),
    .m0_rvalid               ( m0_rvalid ),
    .m1_awready              ( ),
    .m1_wready               ( ),
    .m1_bid                  ( ),
    .m1_bresp                ( ),
    .m1_bvalid               ( ),
    .m1_arready              ( ),
    .m1_rid                  ( ),
    .m1_rdata                ( ),
    .m1_rresp                ( ),
    .m1_rlast                ( ),
    .m1_rvalid               ( ),
    .m2_awready              ( ),
    .m2_wready               ( ),
    .m2_bid                  ( ),
    .m2_bresp                ( ),
    .m2_bvalid               ( ),
    .m2_arready              ( ),
    .m2_rid                  ( ),
    .m2_rdata                ( ),
    .m2_rresp                ( ),
    .m2_rlast                ( ),
    .m2_rvalid               ( ),
    .m_bid                   (      ),
    .m_bresp                 (    ),
    .m_rid                   (      ),
    .m_rdata                 (    ),
    .m_rresp                 (    ),
    .m_rlast                 (    ),
    .s0_awid                 ( s0_awid   ),
    .s0_awaddr               ( s0_awaddr ),
    .s0_awlen                ( s0_awlen  ),
    .s0_awsize               (  ),
    .s0_awburst              ( ),
    .s0_awvalid              ( s0_awvalid),
    .s0_wid                  ( s0_wid    ),
    .s0_wdata                ( s0_wdata  ),
    .s0_wstrb                (   ),
    .s0_wlast                ( s0_wlast  ),
    .s0_wvalid               ( s0_wvalid ),
    .s0_bready               ( s0_bready ),
    .s0_arid                 ( s0_arid   ),
    .s0_araddr               ( s0_araddr ),
    .s0_arlen                ( s0_arlen  ),
    .s0_arsize               (  ),
    .s0_arburst              ( ),
    .s0_arvalid              ( s0_arvalid),
    .s0_rready               ( s0_rready ),
    .s1_awid                 ( s1_awid   ),
    .s1_awaddr               ( s1_awaddr ),
    .s1_awlen                ( s1_awlen  ),
    .s1_awsize               (  ),
    .s1_awburst              ( ),
    .s1_awvalid              ( s1_awvalid),
    .s1_wid                  ( s1_wid    ),
    .s1_wdata                ( s1_wdata  ),
    .s1_wstrb                (   ),
    .s1_wlast                ( s1_wlast  ),
    .s1_wvalid               ( s1_wvalid ),
    .s1_bready               ( s1_bready ),
    .s1_arid                 ( s1_arid   ),
    .s1_araddr               ( s1_araddr ),
    .s1_arlen                ( s1_arlen  ),
    .s1_arsize               (  ),
    .s1_arburst              ( ),
    .s1_arvalid              ( s1_arvalid),
    .s1_rready               ( s1_rready ),
    .s2_awid                 ( s2_awid   ),
    .s2_awaddr               ( s2_awaddr ),
    .s2_awlen                ( s2_awlen  ),
    .s2_awsize               (  ),
    .s2_awburst              ( ),
    .s2_awvalid              ( s2_awvalid),
    .s2_wid                  ( s2_wid    ),
    .s2_wdata                ( s2_wdata  ),
    .s2_wstrb                (   ),
    .s2_wlast                ( s2_wlast  ),
    .s2_wvalid               ( s2_wvalid ),
    .s2_bready               ( s2_bready ),
    .s2_arid                 ( s2_arid   ),
    .s2_araddr               ( s2_araddr ),
    .s2_arlen                ( s2_arlen  ),
    .s2_arsize               (  ),
    .s2_arburst              ( ),
    .s2_arvalid              ( s2_arvalid),
    .s2_rready               ( s2_rready ),
    .s_awid                  (     ),
    .s_awaddr                (   ),
    .s_awlen                 (    ),
    .s_awsize                (   ),
    .s_awburst               (  ),
    .s_wid                   (      ),
    .s_wdata                 (    ),
    .s_wstrb                 (    ),
    .s_wlast                 (    ),
    .s_arid                  (    ),
    .s_araddr                (   ),
    .s_arlen                 (    ),
    .s_arsize                (   ),
    .s_arburst               (  )
);

     //=========================================================
    //0号从机例化
AXI_Slave u0_AXI_Slave (
    .sys_clk                 ( sys_clk ),
    .sys_rstn                ( sys_rstn ),
    .awid                    ( s0_awid    ),
    .awaddr                  ( s0_awaddr  ),
    .awlen                   ( s0_awlen   ),
    .awvalid                 ( s0_awvalid ),
    .wid                     ( s0_wid     ),
    .wdata                   ( s0_wdata   ),
    .wlast                   ( s0_wlast   ),
    .wvalid                  ( s0_wvalid  ),
    .bid                     ( s0_bid     ),
    .bready                  ( s0_bready  ),
    .arid                    ( s0_arid    ),
    .araddr                  ( s0_araddr  ),
    .arlen                   ( s0_arlen   ),
    .arvalid                 ( s0_arvalid ),
    .rready                  ( s0_rready  ),
    .awready                 ( s0_awready ),
    .wready                  ( s0_wready  ),
    .bvalid                  ( s0_bvalid  ),
    .arready                 ( s0_arready ),
    .rid                     ( s0_rid     ),
    .rdata                   ( s0_rdata   ),
    .rlast                   ( s0_rlast   ),
    .rvalid                  ( s0_rvalid  )
);

     //=========================================================
    //1号从机例化
AXI_Slave u1_AXI_Slave (
    .sys_clk                 ( sys_clk ),
    .sys_rstn                ( sys_rstn ),
    .awid                    ( s1_awid    ),
    .awaddr                  ( s1_awaddr  ),
    .awlen                   ( s1_awlen   ),
    .awvalid                 ( s1_awvalid ),
    .wid                     ( s1_wid     ),
    .wdata                   ( s1_wdata   ),
    .wlast                   ( s1_wlast   ),
    .wvalid                  ( s1_wvalid  ),
    .bid                     ( s1_bid     ),
    .bready                  ( s1_bready  ),
    .arid                    ( s1_arid    ),
    .araddr                  ( s1_araddr  ),
    .arlen                   ( s1_arlen   ),
    .arvalid                 ( s1_arvalid ),
    .rready                  ( s1_rready  ),
    .awready                 ( s1_awready ),
    .wready                  ( s1_wready  ),
    .bvalid                  ( s1_bvalid  ),
    .arready                 ( s1_arready ),
    .rid                     ( s1_rid     ),
    .rdata                   ( s1_rdata   ),
    .rlast                   ( s1_rlast   ),
    .rvalid                  ( s1_rvalid  )
);	

     //=========================================================
    //2号从机例化
AXI_Slave u2_AXI_Slave (
    .sys_clk                 ( sys_clk ),
    .sys_rstn                ( sys_rstn ),
    .awid                    ( s2_awid    ),
    .awaddr                  ( s2_awaddr  ),
    .awlen                   ( s2_awlen   ),
    .awvalid                 ( s2_awvalid ),
    .wid                     ( s2_wid     ),
    .wdata                   ( s2_wdata   ),
    .wlast                   ( s2_wlast   ),
    .wvalid                  ( s2_wvalid  ),
    .bid                     ( s2_bid     ),
    .bready                  ( s2_bready  ),
    .arid                    ( s2_arid    ),
    .araddr                  ( s2_araddr  ),
    .arlen                   ( s2_arlen   ),
    .arvalid                 ( s2_arvalid ),
    .rready                  ( s2_rready  ),
    .awready                 ( s2_awready ),
    .wready                  ( s2_wready  ),
    .bvalid                  ( s2_bvalid  ),
    .arready                 ( s2_arready ),
    .rid                     ( s2_rid     ),
    .rdata                   ( s2_rdata   ),
    .rlast                   ( s2_rlast   ),
    .rvalid                  ( s2_rvalid  )
);							
   
endmodule
