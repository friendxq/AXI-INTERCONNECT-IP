//=============================================================================
//
//Module Name:					AXI_Interconnect.sv

//Function Description:	        AXI总线连接器
//
//=============================================================================

`timescale 1ns/1ns

module AXI_Interconnect#(
    parameter   DATA_WIDTH  = 32,               //数据位宽
                ADDR_WIDTH  = 32,               //地址位宽              
                ID_WIDTH    = 4,                //ID位宽
                STRB_WIDTH  = (DATA_WIDTH/8),   //STRB位宽
                RESP_WIDTH  = 2,
                CNT_WIDTH   = 3,                //计数器位宽
                REG_WIDTH = 6,                  //寄存器位宽
                REG_DEPTH = 4,                  //寄存器深度
                SEL_WIDTH = 2                   //写数据通道路由信号位宽
)(
	  /********* 时钟&复位 *********/
	input                       sys_clk,
	input      	                sys_rstn,
    /********** 0号主控 **********/
    //写地址通道
	input      [ID_WIDTH-1:0]   m0_awid,
    input	   [ADDR_WIDTH-1:0] m0_awaddr,
    input      [7:0]            m0_awlen,
    input      [2:0]            m0_awsize,
    input      [1:0]            m0_awburst,
    input                       m0_awvalid,
    output                      m0_awready,
    //写数据通道
    input      [ID_WIDTH-1:0]   m0_wid,
    input      [DATA_WIDTH-1:0] m0_wdata,
    input      [STRB_WIDTH-1:0] m0_wstrb,
    input                       m0_wlast,
    input                       m0_wvalid,
    output                      m0_wready,
    //写响应通道
    output     [3:0]            m0_bid,
    output     [RESP_WIDTH-1:0] m0_bresp,
    output                      m0_bvalid,
    input                       m0_bready,
    //读地址通道
    input      [ID_WIDTH-1:0]   m0_arid,
    input      [ADDR_WIDTH-1:0] m0_araddr,
    input      [7:0]            m0_arlen,
    input      [2:0]            m0_arsize,
    input      [1:0]            m0_arburst,
    input                       m0_arvalid,
    output                      m0_arready,
    //读数据通道
    output     [ID_WIDTH-1:0]   m0_rid,
    output     [DATA_WIDTH-1:0] m0_rdata,
    output     [RESP_WIDTH-1:0] m0_rresp,
    output                      m0_rlast,
    output                      m0_rvalid,
    input                       m0_rready,
    /********** 1号主控 **********/
    //写地址通道
	input      [ID_WIDTH-1:0]   m1_awid,
    input	   [ADDR_WIDTH-1:0] m1_awaddr,
    input      [7:0]            m1_awlen,
    input      [2:0]            m1_awsize,
    input      [1:0]            m1_awburst,
    input                       m1_awvalid,
    output                      m1_awready,
    //写数据通道
    input      [ID_WIDTH-1:0]   m1_wid,
    input      [DATA_WIDTH-1:0] m1_wdata,
    input      [STRB_WIDTH-1:0] m1_wstrb,
    input                       m1_wlast,
    input                       m1_wvalid,
    output                      m1_wready,
    //写响应通道
    output     [3:0]            m1_bid,
    output     [RESP_WIDTH-1:0] m1_bresp,
    output                      m1_bvalid,
    input                       m1_bready,
    //读地址通道
    input      [ID_WIDTH-1:0]   m1_arid,
    input      [ADDR_WIDTH-1:0] m1_araddr,
    input      [7:0]            m1_arlen,
    input      [2:0]            m1_arsize,
    input      [1:0]            m1_arburst,
    input                       m1_arvalid,
    output                      m1_arready,
    //读数据通道
    output     [ID_WIDTH-1:0]   m1_rid,
    output     [DATA_WIDTH-1:0] m1_rdata,
    output     [RESP_WIDTH-1:0] m1_rresp,
    output                      m1_rlast,
    output                      m1_rvalid,
    input                       m1_rready,
    /********** 2号主控 **********/
    //写地址通道
	input      [ID_WIDTH-1:0]   m2_awid,
    input	   [ADDR_WIDTH-1:0] m2_awaddr,
    input      [7:0]            m2_awlen,
    input      [2:0]            m2_awsize,
    input      [1:0]            m2_awburst,
    input                       m2_awvalid,
    output                      m2_awready,
    //写数据通道
    input      [ID_WIDTH-1:0]   m2_wid,
    input      [DATA_WIDTH-1:0] m2_wdata,
    input      [STRB_WIDTH-1:0] m2_wstrb,
    input                       m2_wlast,
    input                       m2_wvalid,
    output                      m2_wready,
    //写响应通道
    output     [3:0]            m2_bid,
    output     [RESP_WIDTH-1:0] m2_bresp,
    output                      m2_bvalid,
    input                       m2_bready,
    //读地址通道
    input      [ID_WIDTH-1:0]   m2_arid,
    input      [ADDR_WIDTH-1:0] m2_araddr,
    input      [7:0]            m2_arlen,
    input      [2:0]            m2_arsize,
    input      [1:0]            m2_arburst,
    input                       m2_arvalid,
    output                      m2_arready,
    //读数据通道
    output     [ID_WIDTH-1:0]   m2_rid,
    output     [DATA_WIDTH-1:0] m2_rdata,
    output     [RESP_WIDTH-1:0] m2_rresp,
    output                      m2_rlast,
    output                      m2_rvalid,
    input                       m2_rready,
    
    /******** 主控通用信号 ********/
    //写响应通道
	output     [ID_WIDTH-1:0] 	m_bid,
	output     [1:0]	        m_bresp,
    //读数据通道
	output     [ID_WIDTH-1:0]   m_rid,
	output     [DATA_WIDTH-1:0] m_rdata,
	output     [1:0]	        m_rresp,
    output                      m_rlast,
    /********** 0号从机 **********/
    //写地址通道
    output	   [ID_WIDTH-1:0]   s0_awid,
    output	   [ADDR_WIDTH-1:0] s0_awaddr,
    output	   [7:0]            s0_awlen,
    output	   [2:0]            s0_awsize,
    output	   [1:0]            s0_awburst,
    output                      s0_awvalid,
    input	   	                s0_awready,
    //写数据通道
    output     [ID_WIDTH-1:0]   s0_wid,
    output     [ADDR_WIDTH-1:0] s0_wdata,
    output     [STRB_WIDTH-1:0] s0_wstrb,
    output                      s0_wlast,
    output                      s0_wvalid,
    input	  		            s0_wready,
    //写响应通道
	input	   [ID_WIDTH-1:0]	s0_bid,
	input	   [1:0]	        s0_bresp,
	input	     		        s0_bvalid,
    output                      s0_bready,
    //读地址通道
    output	   [ID_WIDTH-1:0]   s0_arid,
    output	   [ADDR_WIDTH-1:0] s0_araddr,
    output	   [7:0]            s0_arlen,
    output	   [2:0]            s0_arsize,
    output	   [1:0]            s0_arburst,
    output                      s0_arvalid,
    input	  		            s0_arready,
    //读数据通道                
	input	   [ID_WIDTH-1:0]   s0_rid,
	input	   [DATA_WIDTH-1:0] s0_rdata,
	input	   [RESP_WIDTH-1:0]	s0_rresp,
	input	  		            s0_rlast,
	input	 		            s0_rvalid, 
    output                      s0_rready, 
    /********** 1号从机 **********/
    //写地址通道
    output	   [ID_WIDTH-1:0]   s1_awid,
    output	   [ADDR_WIDTH-1:0] s1_awaddr,
    output	   [7:0]            s1_awlen,
    output	   [2:0]            s1_awsize,
    output	   [1:0]            s1_awburst,
    output                      s1_awvalid,
    input	   	                s1_awready,
    //写数据通道
    output     [ID_WIDTH-1:0]   s1_wid,
    output     [ADDR_WIDTH-1:0] s1_wdata,
    output     [STRB_WIDTH-1:0] s1_wstrb,
    output                      s1_wlast,
    output                      s1_wvalid,
    input	  		            s1_wready,
    //写响应通道
	input	   [ID_WIDTH-1:0]	s1_bid,
	input	   [1:0]	        s1_bresp,
	input	     		        s1_bvalid,
    output                      s1_bready,
    //读地址通道
    output	   [ID_WIDTH-1:0]   s1_arid,
    output	   [ADDR_WIDTH-1:0] s1_araddr,
    output	   [7:0]            s1_arlen,
    output	   [2:0]            s1_arsize,
    output	   [1:0]            s1_arburst,
    output                      s1_arvalid,
    input	  		            s1_arready,
    //读数据通道                
	input	   [ID_WIDTH-1:0]   s1_rid,
	input	   [DATA_WIDTH-1:0] s1_rdata,
	input	   [RESP_WIDTH-1:0]	s1_rresp,
	input	  		            s1_rlast,
	input	 		            s1_rvalid, 
    output                      s1_rready, 
    /********** 2号从机 **********/
    //写地址通道
    output	   [ID_WIDTH-1:0]   s2_awid,
    output	   [ADDR_WIDTH-1:0] s2_awaddr,
    output	   [7:0]            s2_awlen,
    output	   [2:0]            s2_awsize,
    output	   [1:0]            s2_awburst,
    output                      s2_awvalid,
    input	   	                s2_awready,
    //写数据通道
    output     [ID_WIDTH-1:0]   s2_wid,
    output     [ADDR_WIDTH-1:0] s2_wdata,
    output     [STRB_WIDTH-1:0] s2_wstrb,
    output                      s2_wlast,
    output                      s2_wvalid,
    input	  		            s2_wready,
    //写响应通道
	input	   [ID_WIDTH-1:0]	s2_bid,
	input	   [1:0]	        s2_bresp,
	input	     		        s2_bvalid,
    output                      s2_bready,
    //读地址通道
    output	   [ID_WIDTH-1:0]   s2_arid,
    output	   [ADDR_WIDTH-1:0] s2_araddr,
    output	   [7:0]            s2_arlen,
    output	   [2:0]            s2_arsize,
    output	   [1:0]            s2_arburst,
    output                      s2_arvalid,
    input	  		            s2_arready,
    //读数据通道                
	input	   [ID_WIDTH-1:0]   s2_rid,
	input	   [DATA_WIDTH-1:0] s2_rdata,
	input	   [RESP_WIDTH-1:0]	s2_rresp,
	input	  		            s2_rlast,
	input	 		            s2_rvalid, 
    output                      s2_rready, 

    /******** 从机通用信号 ********/
    //写地址通道
    output     [ID_WIDTH-1:0]   s_awid,
    output     [ADDR_WIDTH-1:0]	s_awaddr,
    output     [7:0]            s_awlen,
    output     [2:0]            s_awsize,
    output     [1:0]            s_awburst,
    //写数据通道
    output     [ID_WIDTH-1:0]   s_wid,
    output     [DATA_WIDTH-1:0] s_wdata,
    output     [STRB_WIDTH-1:0] s_wstrb,
    output                      s_wlast,
    //读地址通道
    output     [ID_WIDTH-1:0]   s_arid,    
    output     [ADDR_WIDTH-1:0] s_araddr,
    output     [7:0]            s_arlen,
    output     [2:0]            s_arsize,
    output     [1:0]            s_arburst
);


    //=========================================================
    //内部信号

// Master_Req_W Inputs

wire   [2:0]  wr_grant                      ;
wire   s_awvalid                            ;
wire   m_awready                            ;
wire   m_bvalid                             ;
wire   s_bready                             ;
wire   wr_reg_flag                          ;

// Master_Req_W Outputs
wire  wr_req_0                             ;
wire  wr_req_1                             ;
wire  wr_req_2                             ;
wire  wr_state_refre                       ;

// Master_Req_R Inputs
wire   [2:0]  rd_grant                      ;
wire   s_arvalid                            ;
wire   m_arready                            ;
wire   m_rvalid                             ;
wire   s_rready                             ;
wire   rd_reg_flag                          ;

// Master_Req_R Outputs
wire  rd_req_0                             ;
wire  rd_req_1                             ;
wire  rd_req_2                             ;
wire  rd_state_refre                       ;

// Slave_Arbiter_W Outputs
wire  [2:0]  bvalid_sel                    ;

// Slave_Arbiter_R Outputs
wire  [2:0]  rvalid_sel                    ;    

// Master_Switch_W Outputs
wire  s_wvalid                             ;

// Slave_Switch_W Inputs
wire   [1:0]  s_wvalid_sel                  ;
wire   s_awaddr_en                          ;
wire   s_wvalid_sel_en                      ;
wire  m_wready                             ;

// Slave_Switch_R Inputs
wire   s_araddr_en                          ;
wire   m_rvalid_sel_en                      ;







    //=========================================================
    //写通道请求例化
    Master_Req_W  u_Master_Req_W (
    .sys_clk                 ( sys_clk       ),
    .sys_rstn                ( sys_rstn      ),
    .m0_awvalid              ( m0_awvalid    ),
    .m1_awvalid              ( m1_awvalid    ),
    .m2_awvalid              ( m2_awvalid    ),
    .wr_grant                ( wr_grant      ),
    .s_awvalid               ( s_awvalid     ),
    .m_awready               ( m_awready     ),
    .m_bvalid                ( m_bvalid      ),
    .s_bready                ( s_bready      ),
    .wr_reg_flag             ( wr_reg_flag   ),

    .wr_req_0                ( wr_req_0      ),
    .wr_req_1                ( wr_req_1      ),
    .wr_req_2                ( wr_req_2      ),
    .wr_state_refre          ( wr_state_refre)
);

    //=========================================================
    //读通道请求例化
    Master_Req_R  u_Master_Req_R (
    .sys_clk                 ( sys_clk       ),
    .sys_rstn                ( sys_rstn      ),
    .m0_arvalid              ( m0_arvalid    ),
    .m1_arvalid              ( m1_arvalid    ),
    .m2_arvalid              ( m2_arvalid    ),
    .rd_grant                ( rd_grant      ),
    .s_arvalid               ( s_arvalid     ),
    .m_arready               ( m_arready     ),
    .m_rvalid                ( m_rvalid      ),
    .m_rlast                 ( m_rlast       ),
    .s_rready                ( s_rready      ),
    .rd_reg_flag             ( rd_reg_flag   ),

    .rd_req_0                ( rd_req_0      ),
    .rd_req_1                ( rd_req_1      ),
    .rd_req_2                ( rd_req_2      ),
    .rd_state_refre          ( rd_state_refre)
);

    //=========================================================
    //写通道主机仲裁器例化
   Master_Arbiter_W u_Master_Arbiter_W (
    .sys_clk                 ( sys_clk       ),
    .sys_rstn                ( sys_rstn      ),
    .wr_req_0                ( wr_req_0      ),
    .wr_req_1                ( wr_req_1      ),
    .wr_req_2                ( wr_req_2      ),
    .wr_state_refre          ( wr_state_refre),

    .wr_grant                ( wr_grant      )
);

    //=========================================================
    //读通道从机仲裁器例化
    Master_Arbiter_R u_Master_Arbiter_R (
    .sys_clk                 ( sys_clk       ),
    .sys_rstn                ( sys_rstn      ),
    .rd_req_0                ( rd_req_0      ),
    .rd_req_1                ( rd_req_1      ),
    .rd_req_2                ( rd_req_2      ),
    .rd_state_refre          ( rd_state_refre),

    .rd_grant                ( rd_grant      )
);

    //=========================================================
    //写通道从机仲裁器例化
    Slave_Arbiter_W  u_Slave_Arbiter_W (
    .sys_clk                 ( sys_clk   ),
    .sys_rstn                ( sys_rstn  ),
    .s0_bvalid               ( s0_bvalid ),
    .s1_bvalid               ( s1_bvalid ),
    .s2_bvalid               ( s2_bvalid ),
    .m_bvalid                ( m_bvalid  ),
    .s_bready                ( s_bready  ),

    .bvalid_sel              ( bvalid_sel)
);

    //=========================================================
    //读通道从机仲裁器例化
    Slave_Arbiter_R u_Slave_Arbiter_R (
    .sys_clk                 ( sys_clk   ),
    .sys_rstn                ( sys_rstn  ),
    .s0_rvalid               ( s0_rvalid ),
    .s1_rvalid               ( s1_rvalid ),
    .s2_rvalid               ( s2_rvalid ),
    .m_rvalid                ( m_rvalid  ),
    .s_rready                ( s_rready  ),

    .rvalid_sel              ( rvalid_sel)
);

    //=========================================================
    //写通道主机用多路复用器
    Master_Switch_W u_Master_Switch_W (
    .sys_clk                 ( sys_clk     ),
    .sys_rstn                ( sys_rstn    ),
    .m0_awid                 ( m0_awid     ),
    .m0_awaddr               ( m0_awaddr   ),
    .m0_awlen                ( m0_awlen    ),
    .m0_awsize               ( m0_awsize   ),
    .m0_awburst              ( m0_awburst  ),
    .m0_awvalid              ( m0_awvalid  ),
    .m0_wid                  ( m0_wid      ),
    .m0_wdata                ( m0_wdata    ),
    .m0_wstrb                ( m0_wstrb    ),
    .m0_wlast                ( m0_wlast    ),
    .m0_wvalid               ( m0_wvalid   ),
    .m0_bready               ( m0_bready   ),
    .m1_awid                 ( m1_awid     ),
    .m1_awaddr               ( m1_awaddr   ),
    .m1_awlen                ( m1_awlen    ),
    .m1_awsize               ( m1_awsize   ),
    .m1_awburst              ( m1_awburst  ),
    .m1_awvalid              ( m1_awvalid  ),
    .m1_wid                  ( m1_wid      ),
    .m1_wdata                ( m1_wdata    ),
    .m1_wstrb                ( m1_wstrb    ),
    .m1_wlast                ( m1_wlast    ),
    .m1_wvalid               ( m1_wvalid   ),
    .m1_bready               ( m1_bready   ),
    .m2_awid                 ( m2_awid     ),
    .m2_awaddr               ( m2_awaddr   ),
    .m2_awlen                ( m2_awlen    ),
    .m2_awsize               ( m2_awsize   ),
    .m2_awburst              ( m2_awburst  ),
    .m2_awvalid              ( m2_awvalid  ),
    .m2_wid                  ( m2_wid      ),
    .m2_wdata                ( m2_wdata    ),
    .m2_wstrb                ( m2_wstrb    ),
    .m2_wlast                ( m2_wlast    ),
    .m2_wvalid               ( m2_wvalid   ),
    .m2_bready               ( m2_bready   ),
    .m_awready               ( m_awready   ),
    .m_wready                ( m_wready    ),
    .m_bid                   ( m_bid       ),
    .m_bresp                 ( m_bresp     ),
    .m_bvalid                ( m_bvalid    ),
    .wr_grant                ( wr_grant    ),

    .m0_awready              ( m0_awready  ),
    .m0_wready               ( m0_wready   ),
    .m0_bid                  ( m0_bid      ),
    .m0_bresp                ( m0_bresp    ),
    .m0_bvalid               ( m0_bvalid   ),
    .m1_awready              ( m1_awready  ),
    .m1_wready               ( m1_wready   ),
    .m1_bid                  ( m1_bid      ),
    .m1_bresp                ( m1_bresp    ),
    .m1_bvalid               ( m1_bvalid   ),
    .m2_awready              ( m2_awready  ),
    .m2_wready               ( m2_wready   ),
    .m2_bid                  ( m2_bid      ),
    .m2_bresp                ( m2_bresp    ),
    .m2_bvalid               ( m2_bvalid   ),
    .s_awid                  ( s_awid      ),
    .s_awaddr                ( s_awaddr    ),
    .s_awlen                 ( s_awlen     ),
    .s_awsize                ( s_awsize    ),
    .s_awburst               ( s_awburst   ),
    .s_awvalid               ( s_awvalid   ),
    .s_wid                   ( s_wid       ),
    .s_wdata                 ( s_wdata     ),
    .s_wstrb                 ( s_wstrb     ),
    .s_wlast                 ( s_wlast     ),
    .s_wvalid                ( s_wvalid    ),
    .s_bready                ( s_bready    )
);

    //=========================================================
    //读通道主机用多路复用器
    Master_Switch_R u_Master_Switch_R (
    .sys_clk                 ( sys_clk     ),
    .sys_rstn                ( sys_rstn    ),
    .m0_arid                 ( m0_arid     ),
    .m0_araddr               ( m0_araddr   ),
    .m0_arlen                ( m0_arlen    ),
    .m0_arsize               ( m0_arsize   ),
    .m0_arburst              ( m0_arburst  ),
    .m0_arvalid              ( m0_arvalid  ),
    .m0_rready               ( m0_rready   ),
    .m1_arid                 ( m1_arid     ),
    .m1_araddr               ( m1_araddr   ),
    .m1_arlen                ( m1_arlen    ),
    .m1_arsize               ( m1_arsize   ),
    .m1_arburst              ( m1_arburst  ),
    .m1_arvalid              ( m1_arvalid  ),
    .m1_rready               ( m1_rready   ),
    .m2_arid                 ( m2_arid     ),
    .m2_araddr               ( m2_araddr   ),
    .m2_arlen                ( m2_arlen    ),
    .m2_arsize               ( m2_arsize   ),
    .m2_arburst              ( m2_arburst  ),
    .m2_arvalid              ( m2_arvalid  ),
    .m2_rready               ( m2_rready   ),
    .m_arready               ( m_arready   ),
    .m_rid                   ( m_rid       ),
    .m_rdata                 ( m_rdata     ),
    .m_rresp                 ( m_rresp     ),
    .m_rlast                 ( m_rlast     ),
    .m_rvalid                ( m_rvalid    ),
    .rd_grant                ( rd_grant    ),

    .m0_arready              ( m0_arready  ),
    .m0_rid                  ( m0_rid      ),
    .m0_rdata                ( m0_rdata    ),
    .m0_rresp                ( m0_rresp    ),
    .m0_rlast                ( m0_rlast    ),
    .m0_rvalid               ( m0_rvalid   ),
    .m1_arready              ( m1_arready  ),
    .m1_rid                  ( m1_rid      ),
    .m1_rdata                ( m1_rdata    ),
    .m1_rresp                ( m1_rresp    ),
    .m1_rlast                ( m1_rlast    ),
    .m1_rvalid               ( m1_rvalid   ),
    .m2_arready              ( m2_arready  ),
    .m2_rid                  ( m2_rid      ),
    .m2_rdata                ( m2_rdata    ),
    .m2_rresp                ( m2_rresp    ),
    .m2_rlast                ( m2_rlast    ),
    .m2_rvalid               ( m2_rvalid   ),
    .s_arid                  ( s_arid      ),
    .s_araddr                ( s_araddr    ),
    .s_arlen                 ( s_arlen     ),
    .s_arsize                ( s_arsize    ),
    .s_arburst               ( s_arburst   ),
    .s_arvalid               ( s_arvalid   ),
    .s_rready                ( s_rready    )
);

    //=========================================================
    //写通道从机用多路复用器
    Slave_Switch_W u_Slave_Switch_W (
    .sys_clk                 ( sys_clk          ),
    .sys_rstn                ( sys_rstn         ),
    .s0_awready              ( s0_awready       ),
    .s0_wready               ( s0_wready        ),
    .s0_bid                  ( s0_bid           ),
    .s0_bresp                ( s0_bresp         ),
    .s0_bvalid               ( s0_bvalid        ),
    .s1_awready              ( s1_awready       ),
    .s1_wready               ( s1_wready        ),
    .s1_bid                  ( s1_bid           ),
    .s1_bresp                ( s1_bresp         ),
    .s1_bvalid               ( s1_bvalid        ),
    .s2_awready              ( s2_awready       ),
    .s2_wready               ( s2_wready        ),
    .s2_bid                  ( s2_bid           ),
    .s2_bresp                ( s2_bresp         ),
    .s2_bvalid               ( s2_bvalid        ),
    .s_awid                  ( s_awid           ),
    .s_awaddr                ( s_awaddr         ),
    .s_awlen                 ( s_awlen          ),
    .s_awsize                ( s_awsize         ),
    .s_awburst               ( s_awburst        ),
    .s_awvalid               ( s_awvalid        ),
    .s_wid                   ( s_wid            ),
    .s_wdata                 ( s_wdata          ),
    .s_wstrb                 ( s_wstrb          ),
    .s_wlast                 ( s_wlast          ),
    .s_wvalid                ( s_wvalid         ),
    .s_bready                ( s_bready         ),
    .s_wvalid_sel            ( s_wvalid_sel     ),
    .bvalid_sel              ( bvalid_sel       ),
    .s_awaddr_en             ( s_awaddr_en      ),
    .s_wvalid_sel_en         ( s_wvalid_sel_en  ),

    .s0_awid                 ( s0_awid          ),
    .s0_awaddr               ( s0_awaddr        ),
    .s0_awlen                ( s0_awlen         ),
    .s0_awsize               ( s0_awsize        ),
    .s0_awburst              ( s0_awburst       ),
    .s0_awvalid              ( s0_awvalid       ),
    .s0_wid                  ( s0_wid           ),
    .s0_wdata                ( s0_wdata         ),
    .s0_wstrb                ( s0_wstrb         ),
    .s0_wlast                ( s0_wlast         ),
    .s0_wvalid               ( s0_wvalid        ),
    .s0_bready               ( s0_bready        ),
    .s1_awid                 ( s1_awid          ),
    .s1_awaddr               ( s1_awaddr        ),
    .s1_awlen                ( s1_awlen         ),
    .s1_awsize               ( s1_awsize        ),
    .s1_awburst              ( s1_awburst       ),
    .s1_awvalid              ( s1_awvalid       ),
    .s1_wid                  ( s1_wid           ),
    .s1_wdata                ( s1_wdata         ),
    .s1_wstrb                ( s1_wstrb         ),
    .s1_wlast                ( s1_wlast         ),
    .s1_wvalid               ( s1_wvalid        ),
    .s1_bready               ( s1_bready        ),
    .s2_awid                 ( s2_awid          ),
    .s2_awaddr               ( s2_awaddr        ),
    .s2_awlen                ( s2_awlen         ),
    .s2_awsize               ( s2_awsize        ),
    .s2_awburst              ( s2_awburst       ),
    .s2_awvalid              ( s2_awvalid       ),
    .s2_wid                  ( s2_wid           ),
    .s2_wdata                ( s2_wdata         ),
    .s2_wstrb                ( s2_wstrb         ),
    .s2_wlast                ( s2_wlast         ),
    .s2_wvalid               ( s2_wvalid        ),
    .s2_bready               ( s2_bready        ),
    .m_awready               ( m_awready        ),
    .m_wready                ( m_wready         ),
    .m_bid                   ( m_bid            ),
    .m_bresp                 ( m_bresp          ),
    .m_bvalid                ( m_bvalid         )
);

    //=========================================================
    //读通道从机用多路复用器
    Slave_Switch_R u_Slave_Switch_R (
    .sys_clk                 ( sys_clk          ),
    .sys_rstn                ( sys_rstn         ),
    .s0_arready              ( s0_arready       ),
    .s0_rid                  ( s0_rid           ),
    .s0_rdata                ( s0_rdata         ),
    .s0_rresp                ( s0_rresp         ),
    .s0_rlast                ( s0_rlast         ),
    .s0_rvalid               ( s0_rvalid        ),
    .s1_arready              ( s1_arready       ),
    .s1_rid                  ( s1_rid           ),
    .s1_rdata                ( s1_rdata         ),
    .s1_rresp                ( s1_rresp         ),
    .s1_rlast                ( s1_rlast         ),
    .s1_rvalid               ( s1_rvalid        ),
    .s2_arready              ( s2_arready       ),
    .s2_rid                  ( s2_rid           ),
    .s2_rdata                ( s2_rdata         ),
    .s2_rresp                ( s2_rresp         ),
    .s2_rlast                ( s2_rlast         ),
    .s2_rvalid               ( s2_rvalid        ),
    .s_arid                  ( s_arid           ),
    .s_araddr                ( s_araddr         ),
    .s_arlen                 ( s_arlen          ),
    .s_arsize                ( s_arsize         ),
    .s_arburst               ( s_arburst        ),
    .s_arvalid               ( s_arvalid        ),
    .s_rready                ( s_rready         ),
    .rvalid_sel              ( rvalid_sel     ),
    .s_araddr_en             ( s_araddr_en      ),
    .m_rvalid_sel_en         ( m_rvalid_sel_en  ),

    .s0_arid                 ( s0_arid          ),
    .s0_araddr               ( s0_araddr        ),
    .s0_arlen                ( s0_arlen         ),
    .s0_arsize               ( s0_arsize        ),
    .s0_arburst              ( s0_arburst       ),
    .s0_arvalid              ( s0_arvalid       ),
    .s0_rready               ( s0_rready        ),
    .s1_arid                 ( s1_arid          ),
    .s1_araddr               ( s1_araddr        ),
    .s1_arlen                ( s1_arlen         ),
    .s1_arsize               ( s1_arsize        ),
    .s1_arburst              ( s1_arburst       ),
    .s1_arvalid              ( s1_arvalid       ),
    .s1_rready               ( s1_rready        ),
    .s2_arid                 ( s2_arid          ),
    .s2_araddr               ( s2_araddr        ),
    .s2_arlen                ( s2_arlen         ),
    .s2_arsize               ( s2_arsize        ),
    .s2_arburst              ( s2_arburst       ),
    .s2_arvalid              ( s2_arvalid       ),
    .s2_rready               ( s2_rready        ),
    .m_arready               ( m_arready        ),
    .m_rid                   ( m_rid            ),
    .m_rdata                 ( m_rdata          ),
    .m_rresp                 ( m_rresp          ),
    .m_rlast                 ( m_rlast          ),
    .m_rvalid                ( m_rvalid         )
);

    //=========================================================
    //写通道从机侧寄存模块
    W_ADDR_REG  u_W_ADDR_REG (
    .sys_clk                 ( sys_clk       ),
    .sys_rstn                ( sys_rstn      ),
    .s_awvalid               ( s_awvalid    ),
    .m_awready               ( m_awready    ),
    .wr_state_refre          ( wr_state_refre    ),
    .s_bready                ( s_bready      ),
    .m_bvalid                ( m_bvalid     ),
    .s_wvalid                ( s_wvalid     ),
    .m_wready                ( m_wready      ),
    .s_wid                   ( s_wid      ),
    .s_awaddr                ( s_awaddr   ),
    .s_awid                  ( s_awid      ),
    .wr_reg_flag             ( wr_reg_flag      ),
    .s_awaddr_en             ( s_awaddr_en      ),
    .s_wvalid_sel            ( s_wvalid_sel),
    .s_wvalid_sel_en         ( s_wvalid_sel_en)
);
    //=========================================================
    //读通道从机侧寄存模块
    R_ADDR_REG u_R_ADDR_REG(
    .sys_clk                 ( sys_clk       ),
    .sys_rstn                ( sys_rstn      ),
    .s_arvalid               ( s_arvalid    ),
    .m_arready               ( m_arready    ),
    .rd_state_refre          ( rd_state_refre    ),
    .s_rready                ( s_rready      ),
    .m_rvalid                ( m_rvalid     ),
    .m_rlast                 ( m_rlast     ),
    .s_araddr_en             ( s_araddr_en      ),
    .rd_reg_flag             ( rd_reg_flag      )
);
endmodule
