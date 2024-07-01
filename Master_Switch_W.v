//=============================================================================
//
//Module Name:					Master_Switch_W.v

//Function Description:	        AXI总线写通道主控用多路复用器
//=============================================================================

`timescale 1ns/1ns

module Master_Switch_W#(
    parameter   DATA_WIDTH  = 32,
                ADDR_WIDTH  = 32,
                ID_WIDTH    = 4,
                STRB_WIDTH  = (DATA_WIDTH/8),
                RESP_WIDTH  = 2
)(
	  /********* 时钟&复位 *********/
	  input                       sys_clk,
	  input      	              sys_rstn,
    /********** 0号主控 **********/
    //写地址通道
	input      [ID_WIDTH-1:0]   m0_awid,
    input	   [ADDR_WIDTH-1:0] m0_awaddr,
    input      [7:0]            m0_awlen,
    input      [2:0]            m0_awsize,
    input      [1:0]            m0_awburst,
    input                       m0_awvalid,
    output reg                  m0_awready,
    //写数据通道
    input      [ID_WIDTH-1:0]   m0_wid,
    input      [DATA_WIDTH-1:0] m0_wdata,
    input      [STRB_WIDTH-1:0] m0_wstrb,
    input                       m0_wlast,
    input                       m0_wvalid,
    output reg                  m0_wready,
    //写响应通道
    output reg [ID_WIDTH-1:0]   m0_bid,
    output reg [RESP_WIDTH-1:0] m0_bresp,
    output reg                  m0_bvalid,
    input                       m0_bready,
    /********** 1号主控 **********/
    //写地址通道
	input      [ID_WIDTH-1:0]   m1_awid,
    input	   [ADDR_WIDTH-1:0] m1_awaddr,
    input      [7:0]            m1_awlen,
    input      [2:0]            m1_awsize,
    input      [1:0]            m1_awburst,
    input                       m1_awvalid,
    output reg                  m1_awready,
    //写数据通道
    input      [ID_WIDTH-1:0]   m1_wid,
    input      [DATA_WIDTH-1:0] m1_wdata,
    input      [STRB_WIDTH-1:0] m1_wstrb,
    input                       m1_wlast,
    input                       m1_wvalid,
    output reg                  m1_wready,
    //写响应通道
    output reg [ID_WIDTH-1:0]   m1_bid,
    output reg [RESP_WIDTH-1:0] m1_bresp,
    output reg                  m1_bvalid,
    input                       m1_bready,
    /********** 2号主控 **********/
    //写地址通道
	input      [ID_WIDTH-1:0]   m2_awid,
    input	   [ADDR_WIDTH-1:0]  m2_awaddr,
    input      [7:0]            m2_awlen,
    input      [2:0]            m2_awsize,
    input      [1:0]            m2_awburst,
    input                       m2_awvalid,
    output reg                  m2_awready,
    //写数据通道
    input      [ID_WIDTH-1:0]   m2_wid,
    input      [DATA_WIDTH-1:0] m2_wdata,
    input      [STRB_WIDTH-1:0] m2_wstrb,
    input                       m2_wlast,
    input                       m2_wvalid,
    output reg                  m2_wready,
    //写响应通道
    output reg [ID_WIDTH-1:0]   m2_bid,
    output reg [RESP_WIDTH-1:0] m2_bresp,
    output reg                  m2_bvalid,
    input                       m2_bready,
    /******** 从机侧信号 ********/
    //写地址通道
    output reg [ID_WIDTH-1:0]   s_awid,
    output reg [ADDR_WIDTH-1:0]	s_awaddr,
    output reg [7:0]            s_awlen,
    output reg [2:0]            s_awsize,
    output reg [1:0]            s_awburst,
    output reg                  s_awvalid,
    input                       m_awready,
    //写数据通道
    output reg [ID_WIDTH-1:0]   s_wid,
    output reg [DATA_WIDTH-1:0] s_wdata,
    output reg [STRB_WIDTH-1:0] s_wstrb,
    output reg                  s_wlast,
    output reg                  s_wvalid,
    input                       m_wready,
    //写响应通道
    input      [ID_WIDTH-1:0]   m_bid,
    input      [RESP_WIDTH-1:0] m_bresp,
    input                       m_bvalid,
    output reg                  s_bready,
    /******** 通用信号 ********/
    input  [2:0]                wr_grant

);
    //=========================================================
    //写入通路的多路复用主控信号

    //---------------------------------------------------------
    //其他信号复用
    always @(*) 
    begin
        case(wr_grant)     //判断写入通路的仲裁结果
            3'b001: begin
                s_awid      =  m0_awid;
                s_awaddr    =  m0_awaddr;
                s_awlen     =  m0_awlen;
                s_awsize    =  m0_awsize;
                s_awburst   =  m0_awburst;
                s_awvalid   =  m0_awvalid;
                s_wid       =  m0_wid;
                s_wdata     =  m0_wdata;
                s_wstrb     =  m0_wstrb;
                s_wlast     =  m0_wlast;
                s_wvalid    =  m0_wvalid;
                s_bready    =  m0_bready;
            end
            3'b010: begin
                s_awid      =  m1_awid;
                s_awaddr    =  m1_awaddr;
                s_awlen     =  m1_awlen;
                s_awsize    =  m1_awsize;
                s_awburst   =  m1_awburst;
                s_awvalid   =  m1_awvalid;
                s_wid       =  m1_wid;
                s_wdata     =  m1_wdata;
                s_wstrb     =  m1_wstrb;
                s_wlast     =  m1_wlast;
                s_wvalid    =  m1_wvalid;
                s_bready    =  m1_bready;
            end
            3'b100: begin
                s_awid      =  m2_awid;
                s_awaddr    =  m2_awaddr;
                s_awlen     =  m2_awlen;
                s_awsize    =  m2_awsize;
                s_awburst   =  m2_awburst;
                s_awvalid   =  m2_awvalid;
                s_wid       =  m2_wid;
                s_wdata     =  m2_wdata;
                s_wstrb     =  m2_wstrb;
                s_wlast     =  m2_wlast;
                s_wvalid    =  m2_wvalid;
                s_bready    =  m2_bready;
            end
            default: begin
                s_awid      =  4'd0;
                s_awaddr    =  32'd0;
                s_awlen     =  8'd0;
                s_awsize    =  3'd0;
                s_awburst   =  2'd0;
                s_awvalid   =  1'b0;
                s_wid       =  4'd0;
                s_wdata     =  32'd0;
                s_wstrb     =  4'd0;
                s_wlast     =  1'b0;
                s_wvalid    =  1'b0;
                s_bready    =  1'b0;
            end
        endcase
    end


    //---------------------------------------------------------
    //awready信号复用
    always @(*) begin
        case(wr_grant)
            3'b001: begin 
                m0_awready = m_awready;
                m1_awready = 1'b0;
                m2_awready = 1'b0;
            end
            3'b010: begin
                m0_awready = 1'b0;
                m1_awready = m_awready;
                m2_awready = 1'b0;
            end
            3'b100: begin
                m0_awready = 1'b0;
                m1_awready = 1'b0;
                m2_awready = m_awready;
            end
            default: begin
                m0_awready = 1'b0;
                m1_awready = 1'b0;
                m2_awready = 1'b0;
            end
        endcase
    end

    //---------------------------------------------------------
    //wready信号复用
    always @(*) begin
        case(wr_grant)
            3'b001: begin 
                m0_wready = m_wready;
                m1_wready = 1'b0;
                m2_wready = 1'b0;
            end
            3'b010: begin
                m0_wready = 1'b0;
                m1_wready = m_wready;
                m2_wready = 1'b0;
            end
            3'b100: begin
                m0_wready = 1'b0;
                m1_wready = 1'b0;
                m2_wready = m_wready;
            end
            default: begin
                m0_wready = 1'b0;
                m1_wready = 1'b0;
                m2_wready = 1'b0;
            end
        endcase
    end

    //---------------------------------------------------------
    //bvalid信号复用
    always @(*) begin
        case(wr_grant)
            3'b001: begin 
                m0_bvalid = m_bvalid;
                m1_bvalid = 1'b0;
                m2_bvalid = 1'b0;
            end
            3'b010: begin
                m0_bvalid = 1'b0;
                m1_bvalid = m_bvalid;
                m2_bvalid = 1'b0;
            end
            3'b100: begin
                m0_bvalid = 1'b0;
                m1_bvalid = 1'b0;
                m2_bvalid = m_bvalid;
            end
            default: begin
                m0_bvalid = 1'b0;
                m1_bvalid = 1'b0;
                m2_bvalid = 1'b0;
            end
        endcase
    end    
    
    //---------------------------------------------------------
    //bid信号复用
    always @(*) begin
        case(wr_grant)
            3'b001: begin 
                m0_bid = m_bid;
                m1_bid = 4'd0;
                m2_bid = 4'd0;
            end
            3'b010: begin
                m0_bid = 4'd0;
                m1_bid = m_bid;
                m2_bid = 4'd0;
            end
            3'b100: begin
                m0_bid = 4'd0;
                m1_bid = 4'd0;
                m2_bid = m_bid;
            end
            default: begin
                m0_bid = 4'd0;
                m1_bid = 4'd0;
                m2_bid = 4'd0;
            end
        endcase
    end 
    
    //---------------------------------------------------------
    //bresp信号复用
    always @(*) begin
        case(wr_grant)
            3'b001: begin 
                m0_bresp = m_bresp;
                m1_bresp = 2'd0;
                m2_bresp = 2'd0;
            end
            3'b010: begin
                m0_bresp = 2'd0;
                m1_bresp = m_bresp;
                m2_bresp = 2'd0;
            end
            3'b100: begin
                m0_bresp = 2'd0;
                m1_bresp = 2'd0;
                m2_bresp = m_bresp;
            end
            default: begin
                m0_bresp = 2'd0;
                m1_bresp = 2'd0;
                m2_bresp = 2'd0;
            end
        endcase
    end 

 
endmodule

    