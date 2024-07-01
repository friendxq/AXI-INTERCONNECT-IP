//=============================================================================
//
//Module Name:					Slave_Switch_W.v

//Function Description:	        AXI总线写通道从机用多路复用器
//=============================================================================

`timescale 1ns/1ns

module Slave_Switch_W#(
    parameter   DATA_WIDTH  = 32,
                ADDR_WIDTH  = 32,
                ID_WIDTH    = 4,
                STRB_WIDTH  = (DATA_WIDTH/8),
                RESP_WIDTH  = 2
)(
	  /********* 时钟&复位 *********/
	  input                       sys_clk,
	  input      	                sys_rstn,
    /********** 0号从机 **********/
    //写地址通道
	  output reg [ID_WIDTH-1:0]   s0_awid,
    output reg [ADDR_WIDTH-1:0] s0_awaddr,
    output reg [7:0]            s0_awlen,
    output reg [2:0]            s0_awsize,
    output reg [1:0]            s0_awburst,
    output reg                  s0_awvalid,
    input                       s0_awready,
    //写数据通道
    output reg [ID_WIDTH-1:0]   s0_wid,
    output reg [DATA_WIDTH-1:0] s0_wdata,
    output reg [STRB_WIDTH-1:0] s0_wstrb,
    output reg                  s0_wlast,
    output reg                  s0_wvalid,
    input 		                  s0_wready,
    //写响应通道
    input      [ID_WIDTH-1:0]   s0_bid,
    input      [RESP_WIDTH-1:0] s0_bresp,
    input                       s0_bvalid,
    output reg                  s0_bready,
    /********** 1号从机 **********/
    //写地址通道
	  output reg [ID_WIDTH-1:0]   s1_awid,
    output reg [ADDR_WIDTH-1:0] s1_awaddr,
    output reg [7:0]            s1_awlen,
    output reg [2:0]            s1_awsize,
    output reg [1:0]            s1_awburst,
    output reg                  s1_awvalid,
    input                       s1_awready,
    //写数据通道
    output reg [ID_WIDTH-1:0]   s1_wid,
    output reg [DATA_WIDTH-1:0] s1_wdata,
    output reg [STRB_WIDTH-1:0] s1_wstrb,
    output reg                  s1_wlast,
    output reg                  s1_wvalid,
    input 		                  s1_wready,
    //写响应通道
    input      [ID_WIDTH-1:0]   s1_bid,
    input      [RESP_WIDTH-1:0] s1_bresp,
    input                       s1_bvalid,
    output reg                  s1_bready,
    /********** 2号从机 **********/
    //写地址通道
	  output reg [ID_WIDTH-1:0]   s2_awid,
    output reg [ADDR_WIDTH-1:0] s2_awaddr,
    output reg [7:0]            s2_awlen,
    output reg [2:0]            s2_awsize,
    output reg [1:0]            s2_awburst,
    output reg                  s2_awvalid,
    input                       s2_awready,
    //写数据通道
    output reg [ID_WIDTH-1:0]   s2_wid,
    output reg [DATA_WIDTH-1:0] s2_wdata,
    output reg [STRB_WIDTH-1:0] s2_wstrb,
    output reg                  s2_wlast,
    output reg                  s2_wvalid,
    input 		                  s2_wready,
    //写响应通道
    input      [ID_WIDTH-1:0]   s2_bid,
    input      [RESP_WIDTH-1:0] s2_bresp,
    input                       s2_bvalid,
    output reg                  s2_bready,
    /******** 主机侧信号 ********/
    //写地址通道
    input 		 [ID_WIDTH-1:0]   s_awid,
    input 		 [ADDR_WIDTH-1:0]	s_awaddr,
    input 		 [7:0]            s_awlen,
    input 		 [2:0]            s_awsize,
    input 		 [1:0]            s_awburst,
    input 		                  s_awvalid,
    output reg                  m_awready,
    //写数据通道
    input 		 [ID_WIDTH-1:0]   s_wid,
    input 		 [DATA_WIDTH-1:0] s_wdata,
    input 		 [STRB_WIDTH-1:0] s_wstrb,
    input 		                  s_wlast,
    input 		                  s_wvalid,
    output reg                  m_wready,
    //写响应通道
    output reg [ID_WIDTH-1:0]   m_bid,
    output reg [RESP_WIDTH-1:0] m_bresp,
    output reg                  m_bvalid,
    input			                  s_bready,
    /******** 选择及其使能信号 ********/
    input      [1:0]            s_wvalid_sel,
    input      [2:0]            bvalid_sel,
    input                       s_awaddr_en,
    input                       s_wvalid_sel_en

);
    //=========================================================
    //写入通路的多路复用从机信号

    //---------------------------------------------------------
    //其他信号复用
    always @(*) 
    begin
    	if(s_awaddr_en) begin
        case(s_awaddr[ADDR_WIDTH-1:ADDR_WIDTH-2])     //判断写入地址通路的仲裁结果
            2'b01: begin
                m_awready   =  s0_awready;
            end
            2'b10: begin
                m_awready   =  s1_awready;
            end
            2'b11: begin
                m_awready   =  s2_awready;
            end
            default: begin
                m_awready   =  1'b0;
            end
        endcase
      end
      else begin
      	m_awready   =  1'b0;
      end
    end

		always @(*) 
    begin
    	if(s_wvalid_sel_en) begin
        case(s_wvalid_sel)     //判断写入数据通路的仲裁结果
            2'b01: begin
                m_wready    =  s0_wready;
            end
            2'b10: begin
                m_wready    =  s1_wready;
            end
            2'b11: begin
                m_wready    =  s2_wready;
            end
            default: begin
                m_wready    =  1'b0;
            end
        endcase
      end
      else begin
      	m_wready    =  1'b0;
      end
    end
    
    always @(*) 
    begin

        case(bvalid_sel)     //判断写入相应通路的仲裁结果
            3'b001: begin
            		m_bid   	  =  s0_bid;
            		m_bresp	    =  s0_bresp;
            		m_bvalid    =  s0_bvalid;
            end
            3'b010: begin
                m_bid   	  =  s1_bid;
            		m_bresp	    =  s1_bresp;
            		m_bvalid    =  s1_bvalid;
            end
            3'b100: begin
                m_bid   	  =  s2_bid;
            		m_bresp	    =  s2_bresp;
            		m_bvalid    =  s2_bvalid;
            end
            default: begin
                m_bid   	  =  4'd0;
            		m_bresp	    =  2'd0;
            		m_bvalid    =  1'b0;
            end
        endcase

    end

    //------------------写地址通道-----------------------
    //awid信号复用
    always @(*) begin
    	if(s_awaddr_en) begin
        case(s_awaddr[ADDR_WIDTH-1:ADDR_WIDTH-2])
            2'b01: begin 
                s0_awid = s_awid;
                s1_awid = 4'd0;
                s2_awid = 4'd0;
            end
            2'b10: begin
                s0_awid = 4'd0;
                s1_awid = s_awid;
                s2_awid = 4'd0;
            end
            2'b11: begin
                s0_awid = 4'd0;
                s1_awid = 4'd0;
                s2_awid = s_awid;
            end
            default: begin
                s0_awid = 4'd0;
                s1_awid = 4'd0;
                s2_awid = 4'd0;
            end
        endcase
      end
      else begin
      	s0_awid = 4'd0;
        s1_awid = 4'd0;
        s2_awid = 4'd0;
      end
    end

    //---------------------------------------------------------
    //awaddr信号复用
    always @(*) begin
    	if(s_awaddr_en) begin
        case(s_awaddr[ADDR_WIDTH-1:ADDR_WIDTH-2])
            2'b01: begin 
                s0_awaddr = s_awaddr;
                s1_awaddr = 32'd0;
                s2_awaddr = 32'd0;
            end
            2'b10: begin
                s0_awaddr = 32'd0;
                s1_awaddr = s_awaddr;
                s2_awaddr = 32'd0;
            end
            2'b11: begin
                s0_awaddr = 32'd0;
                s1_awaddr = 32'd0;
                s2_awaddr = s_awaddr;
            end
            default: begin
                s0_awaddr = 32'd0;
                s1_awaddr = 32'd0;
                s2_awaddr = 32'd0;
            end
        endcase
      end
      else begin
      	s0_awaddr = 32'd0;
        s1_awaddr = 32'd0;
        s2_awaddr = 32'd0;
      end
    end

    //---------------------------------------------------------
    //awlen信号复用
    always @(*) begin
    	if(s_awaddr_en) begin
        case(s_awaddr[ADDR_WIDTH-1:ADDR_WIDTH-2])
            2'b01: begin 
                s0_awlen  = s_awlen;
                s1_awlen  = 8'd0;
                s2_awlen  = 8'd0;
            end
            2'b10: begin
                s0_awlen  = 8'd0;
                s1_awlen  = s_awlen;
                s2_awlen  = 8'd0;
            end
            2'b11: begin
                s0_awlen  = 8'd0;
                s1_awlen  = 8'd0;
                s2_awlen  = s_awlen;
            end
            default: begin
                s0_awlen  = 8'd0;
                s1_awlen  = 8'd0;
                s2_awlen  = 8'd0;
            end
        endcase
      end
      else begin
      	s0_awlen  = 8'd0;
        s1_awlen  = 8'd0;
        s2_awlen  = 8'd0;
      end
    end
 
    //---------------------------------------------------------
    //awsize信号复用
    always @(*) begin
    	if(s_awaddr_en) begin
        case(s_awaddr[ADDR_WIDTH-1:ADDR_WIDTH-2])
            2'b01: begin 
                s0_awsize = s_awsize;
                s1_awsize = 3'd0;
                s2_awsize = 3'd0;
            end
            2'b10: begin
                s0_awsize = 3'd0;
                s1_awsize = s_awsize;
                s2_awsize = 3'd0;
            end
            2'b11: begin
                s0_awsize = 3'd0;
                s1_awsize = 3'd0;
                s2_awsize = s_awsize;
            end
            default: begin
                s0_awsize = 3'd0;
                s1_awsize = 3'd0;
                s2_awsize = 3'd0;
            end
        endcase
      end
      else begin
      	s0_awsize = 3'd0;
        s1_awsize = 3'd0;
        s2_awsize = 3'd0;
      end
    end
    
    //---------------------------------------------------------
    //awburst信号复用
    always @(*) begin
    	if(s_awaddr_en) begin
        case(s_awaddr[ADDR_WIDTH-1:ADDR_WIDTH-2])
            2'b01: begin 
                s0_awburst = s_awburst;
                s1_awburst = 2'd0;
                s2_awburst = 2'd0;
            end
            2'b10: begin
                s0_awburst = 2'd0;
                s1_awburst = s_awburst;
                s2_awburst = 2'd0;
            end
            2'b11: begin
                s0_awburst = 2'd0;
                s1_awburst = 2'd0;
                s2_awburst = s_awburst;
            end
            default: begin
                s0_awburst = 2'd0;
                s1_awburst = 2'd0;
                s2_awburst = 2'd0;
            end
        endcase
      end
      else begin
      	s0_awburst = 2'd0;
        s1_awburst = 2'd0;
        s2_awburst = 2'd0;
      end
    end
    
    //---------------------------------------------------------
    //awvalid信号复用
    always @(*) begin
    	if(s_awaddr_en) begin
        case(s_awaddr[ADDR_WIDTH-1:ADDR_WIDTH-2])
            2'b01: begin 
                s0_awvalid = s_awvalid;
                s1_awvalid = 1'd0;
                s2_awvalid = 1'd0;
            end
            2'b10: begin
                s0_awvalid = 1'd0;
                s1_awvalid = s_awvalid;
                s2_awvalid = 1'd0;
            end
            2'b11: begin
                s0_awvalid = 1'd0;
                s1_awvalid = 1'd0;
                s2_awvalid = s_awvalid;
            end
            default: begin
                s0_awvalid = 1'd0;
                s1_awvalid = 1'd0;
                s2_awvalid = 1'd0;
            end
        endcase
      end
      else begin
      	s0_awvalid = 1'd0;
        s1_awvalid = 1'd0;
        s2_awvalid = 1'd0;
      end
    end
    
    //--------------------写数据通道-------------------------
    //wid信号复用
    always @(*) begin
    	if(s_wvalid_sel_en) begin
        case(s_wvalid_sel)
            2'b01: begin 
                s0_wid = s_wid;
                s1_wid = 4'd0;
                s2_wid = 4'd0;
            end
            2'b10: begin
                s0_wid = 4'd0;
                s1_wid = s_wid;
                s2_wid = 4'd0;
            end
            2'b11: begin
                s0_wid = 4'd0;
                s1_wid = 4'd0;
                s2_wid = s_wid;
            end
            default: begin
                s0_wid = 4'd0;
                s1_wid = 4'd0;
                s2_wid = 4'd0;
            end
        endcase
      end
      else begin
      	s0_wid = 4'd0;
        s1_wid = 4'd0;
        s2_wid = 4'd0;
      end
    end
    
    //---------------------------------------------------------
    //wdata信号复用
    always @(*) begin
    	if(s_wvalid_sel_en) begin
        case(s_wvalid_sel)
            2'b01: begin 
                s0_wdata = s_wdata;
                s1_wdata = 32'd0;
                s2_wdata = 32'd0;
            end
            2'b10: begin
                s0_wdata = 32'd0;
                s1_wdata = s_wdata;
                s2_wdata = 32'd0;
            end
            2'b11: begin
                s0_wdata = 32'd0;
                s1_wdata = 32'd0;
                s2_wdata = s_wdata;
            end
            default: begin
                s0_wdata = 32'd0;
                s1_wdata = 32'd0;
                s2_wdata = 32'd0;
            end
        endcase
      end
      else begin
      	s0_wdata = 32'd0;
        s1_wdata = 32'd0;
        s2_wdata = 32'd0;
      end
    end
    
    //---------------------------------------------------------
    //wstrb信号复用
    always @(*) begin
    	if(s_wvalid_sel_en) begin
        case(s_wvalid_sel)
            2'b01: begin 
                s0_wstrb = s_wstrb;
                s1_wstrb = 4'd0;
                s2_wstrb = 4'd0;
            end
            2'b10: begin
                s0_wstrb = 4'd0;
                s1_wstrb = s_wstrb;
                s2_wstrb = 4'd0;
            end
            2'b11: begin
                s0_wstrb = 4'd0;
                s1_wstrb = 4'd0;
                s2_wstrb = s_wstrb;
            end
            default: begin
                s0_wstrb = 4'd0;
                s1_wstrb = 4'd0;
                s2_wstrb = 4'd0;
            end
        endcase
      end
      else begin
      	s0_wstrb = 4'd0;
        s1_wstrb = 4'd0;
        s2_wstrb = 4'd0;
      end
    end
    
    //---------------------------------------------------------
    //wlast信号复用
    always @(*) begin
    	if(s_wvalid_sel_en) begin
        case(s_wvalid_sel)
            2'b01: begin 
                s0_wlast = s_wlast;
                s1_wlast = 1'd0;
                s2_wlast = 1'd0;
            end
            2'b10: begin
                s0_wlast = 1'd0;
                s1_wlast = s_wlast;
                s2_wlast = 1'd0;
            end
            2'b11: begin
                s0_wlast = 1'd0;
                s1_wlast = 1'd0;
                s2_wlast = s_wlast;
            end
            default: begin
                s0_wlast = 1'd0;
                s1_wlast = 1'd0;
                s2_wlast = 1'd0;
            end
        endcase
      end
      else begin
      	s0_wlast = 1'd0;
        s1_wlast = 1'd0;
        s2_wlast = 1'd0;
      end
    end

    //---------------------------------------------------------
    //wvalid信号复用
    always @(*) begin
    	if(s_wvalid_sel_en) begin
        case(s_wvalid_sel)
            2'b01: begin 
                s0_wvalid = s_wvalid;
                s1_wvalid = 1'd0;
                s2_wvalid = 1'd0;
            end
            2'b10: begin
                s0_wvalid = 1'd0;
                s1_wvalid = s_wvalid;
                s2_wvalid = 1'd0;
            end
            2'b11: begin
                s0_wvalid = 1'd0;
                s1_wvalid = 1'd0;
                s2_wvalid = s_wvalid;
            end
            default: begin
                s0_wvalid = 1'd0;
                s1_wvalid = 1'd0;
                s2_wvalid = 1'd0;
            end
        endcase
      end
      else begin
      	s0_wvalid = 1'd0;
        s1_wvalid = 1'd0;
        s2_wvalid = 1'd0;
      end
    end

    //----------------响应通道--------------------------
    //bready信号复用
    always @(*) begin

        case(bvalid_sel)
            3'b001: begin 
                s0_bready = s_bready;
                s1_bready = 1'd0;
                s2_bready = 1'd0;
            end
            3'b010: begin
                s0_bready = 1'd0;
                s1_bready = s_bready;
                s2_bready = 1'd0;
            end
            3'b100: begin
                s0_bready = 1'd0;
                s1_bready = 1'd0;
                s2_bready = s_bready;
            end
            default: begin
                s0_bready = 1'd0;
                s1_bready = 1'd0;
                s2_bready = 1'd0;
            end
        endcase
      end


endmodule

    