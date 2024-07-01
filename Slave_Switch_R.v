//=============================================================================
//
//Module Name:					Slave_Switch_R.v

//Function Description:	        AXI总线读通道从机用多路复用器
//=============================================================================

`timescale 1ns/1ns

module Slave_Switch_R#(
    parameter   DATA_WIDTH  = 32,
                ADDR_WIDTH  = 32,
                ID_WIDTH    = 4,
                RESP_WIDTH  = 2
)(
	  /********* 时钟&复位 *********/
	  input                       sys_clk,
	  input      	                sys_rstn,
    /********** 0号从机 **********/
    //读地址通道
	output reg [ID_WIDTH-1:0]   s0_arid,
    output reg [ADDR_WIDTH-1:0] s0_araddr,
    output reg [7:0]            s0_arlen,
    output reg [2:0]            s0_arsize,
    output reg [1:0]            s0_arburst,
    output reg                  s0_arvalid,
    input			                  s0_arready,
    //读数据通道
    output reg	                s0_rready,
    input			 [ID_WIDTH-1:0]   s0_rid,
    input			 [DATA_WIDTH-1:0] s0_rdata,
    input			 [RESP_WIDTH-1:0] s0_rresp,
    input			                  s0_rlast,
    input			                  s0_rvalid,
    /********** 1号从机 **********/
    //读地址通道
	output reg [ID_WIDTH-1:0]   s1_arid,
    output reg [ADDR_WIDTH-1:0] s1_araddr,
    output reg [7:0]            s1_arlen,
    output reg [2:0]            s1_arsize,
    output reg [1:0]            s1_arburst,
    output reg                  s1_arvalid,
    input			                  s1_arready,
    //读数据通道
    output reg	                s1_rready,
    input			 [ID_WIDTH-1:0]   s1_rid,
    input			 [DATA_WIDTH-1:0] s1_rdata,
    input			 [RESP_WIDTH-1:0] s1_rresp,
    input			                  s1_rlast,
    input			                  s1_rvalid,
    /********** 2号从机 **********/
    //读地址通道
	output reg [ID_WIDTH-1:0]   s2_arid,
    output reg [ADDR_WIDTH-1:0] s2_araddr,
    output reg [7:0]            s2_arlen,
    output reg [2:0]            s2_arsize,
    output reg [1:0]            s2_arburst,
    output reg                  s2_arvalid,
    input			                  s2_arready,
    //读数据通道
    output reg	                s2_rready,
    input 		 [ID_WIDTH-1:0]   s2_rid,
    input 		 [DATA_WIDTH-1:0] s2_rdata,
    input 		 [RESP_WIDTH-1:0] s2_rresp,
    input 		                  s2_rlast,
    input 		                  s2_rvalid,
    /******** 主机侧信号 ********/
    //读地址通道
    input			 [ID_WIDTH-1:0]   s_arid,
    input			 [ADDR_WIDTH-1:0]	s_araddr,
    input			 [7:0]            s_arlen,
    input			 [2:0]            s_arsize,
    input			 [1:0]            s_arburst,
    input			                  s_arvalid,
    output reg                  m_arready,
    //读数据通道
    input			                  s_rready,
    output reg [ID_WIDTH-1:0]   m_rid,
    output reg [DATA_WIDTH-1:0] m_rdata,
    output reg [RESP_WIDTH-1:0] m_rresp,
    output reg                  m_rlast,
    output reg                  m_rvalid,
    /******** 选择及其使能信号 ********/
    input      [2:0]            rvalid_sel,
    input                       s_araddr_en,
    input                       m_rvalid_sel_en
);
    //=========================================================
    //读入通路的多路复用从机信号

    //---------------------------------------------------------
    //其他信号复用
    always @(*) 
    begin
    	if(s_araddr_en) begin
        case(s_araddr[ADDR_WIDTH-1:ADDR_WIDTH-2])     //判断读入地址通路的仲裁结果
            2'b01: begin
                m_arready 		=  s0_arready;
            end
            2'b10: begin
                m_arready 		=  s1_arready;
            end
            2'b11: begin
                m_arready 		=  s2_arready;
            end
            default: begin
                m_arready    =  1'b0;
            end
        endcase
      end
      else begin
      	m_arready    =  1'b0;
      end
    end

		always @(*) 
    begin
    	if(m_rvalid_sel_en) begin
        case(rvalid_sel)     //判断读入数据通路的仲裁结果
            3'b001: begin
                m_rid 		=  s0_rid;
                m_rdata 	=  s0_rdata;
                m_rresp 	=  s0_rresp;
                m_rlast 	=  s0_rlast;
                m_rvalid 	=  s0_rvalid;
            end
            3'b010: begin
                m_rid 		=  s1_rid;
                m_rdata 	=  s1_rdata;
                m_rresp 	=  s1_rresp;
                m_rlast 	=  s1_rlast;
                m_rvalid 	=  s1_rvalid;
            end
            3'b100: begin
                m_rid 		=  s2_rid;
                m_rdata 	=  s2_rdata;
                m_rresp 	=  s2_rresp;
                m_rlast 	=  s2_rlast;
                m_rvalid 	=  s2_rvalid;
            end
            default: begin
                m_rid 		=  4'd0;
                m_rdata 	=  32'd0;
                m_rresp 	=  2'd0;
                m_rlast 	=  1'd0;
                m_rvalid 	=  1'd0;
            end
        endcase
      end
      else begin
      	m_rid 		=  4'd0;
        m_rdata 	=  32'd0;
        m_rresp 	=  2'd0;
        m_rlast 	=  1'd0;
        m_rvalid 	=  1'd0;
      end
    end


    //------------------读地址通道-----------------------
    //arid信号复用
    always @(*) begin
    	if(s_araddr_en) begin
        case(s_araddr[ADDR_WIDTH-1:ADDR_WIDTH-2])
            2'b01: begin 
                s0_arid = s_arid;
                s1_arid = 4'd0;
                s2_arid = 4'd0;
            end
            2'b10: begin
                s0_arid = 4'd0;
                s1_arid = s_arid;
                s2_arid = 4'd0;
            end
            2'b11: begin
                s0_arid = 4'd0;
                s1_arid = 4'd0;
                s2_arid = s_arid;
            end
            default: begin
                s0_arid = 4'd0;
                s1_arid = 4'd0;
                s2_arid = 4'd0;
            end
        endcase
      end
      else begin
      	s0_arid = 4'd0;
        s1_arid = 4'd0;
        s2_arid = 4'd0;
      end
    end

    //---------------------------------------------------
    //araddr信号复用
    always @(*) begin
    	if(s_araddr_en) begin
        case(s_araddr[ADDR_WIDTH-1:ADDR_WIDTH-2])
            2'b01: begin 
                s0_araddr = s_araddr;
                s1_araddr = 32'd0;
                s2_araddr = 32'd0;
            end
            2'b10: begin
                s0_araddr = 32'd0;
                s1_araddr = s_araddr;
                s2_araddr = 32'd0;
            end
            2'b11: begin
                s0_araddr = 32'd0;
                s1_araddr = 32'd0;
                s2_araddr = s_araddr;
            end
            default: begin
                s0_araddr = 32'd0;
                s1_araddr = 32'd0;
                s2_araddr = 32'd0;
            end
        endcase
      end
      else begin
      	s0_araddr = 32'd0;
        s1_araddr = 32'd0;
        s2_araddr = 32'd0;
      end
    end

    //---------------------------------------------------
    //arlen信号复用
    always @(*) begin
    	if(s_araddr_en) begin
        case(s_araddr[ADDR_WIDTH-1:ADDR_WIDTH-2])
            2'b01: begin 
                s0_arlen = s_arlen;
                s1_arlen = 8'd0;
                s2_arlen = 8'd0;
            end
            2'b10: begin
                s0_arlen = 8'd0;
                s1_arlen = s_arlen;
                s2_arlen = 8'd0;
            end
            2'b11: begin
                s0_arlen = 8'd0;
                s1_arlen = 8'd0;
                s2_arlen = s_arlen;
            end
            default: begin
                s0_arlen = 8'd0;
                s1_arlen = 8'd0;
                s2_arlen = 8'd0;
            end
        endcase
      end
      else begin
      	s0_arlen = 8'd0;
        s1_arlen = 8'd0;
        s2_arlen = 8'd0;
      end
    end

    //---------------------------------------------------
    //arsize信号复用
    always @(*) begin
    	if(s_araddr_en) begin
        case(s_araddr[ADDR_WIDTH-1:ADDR_WIDTH-2])
            2'b01: begin 
                s0_arsize = s_arsize;
                s1_arsize = 3'd0;
                s2_arsize = 3'd0;
            end
            2'b10: begin
                s0_arsize = 3'd0;
                s1_arsize = s_arsize;
                s2_arsize = 3'd0;
            end
            2'b11: begin
                s0_arsize = 3'd0;
                s1_arsize = 3'd0;
                s2_arsize = s_arsize;
            end
            default: begin
                s0_arsize = 3'd0;
                s1_arsize = 3'd0;
                s2_arsize = 3'd0;
            end
        endcase
      end
      else begin
      	s0_arsize = 3'd0;
        s1_arsize = 3'd0;
        s2_arsize = 3'd0;
      end
    end

    //---------------------------------------------------
    //arburst信号复用
    always @(*) begin
    	if(s_araddr_en) begin
        case(s_araddr[ADDR_WIDTH-1:ADDR_WIDTH-2])
            2'b01: begin 
                s0_arburst = s_arburst;
                s1_arburst = 2'd0;
                s2_arburst = 2'd0;
            end
            2'b10: begin
                s0_arburst = 2'd0;
                s1_arburst = s_arburst;
                s2_arburst = 2'd0;
            end
            2'b11: begin
                s0_arburst = 2'd0;
                s1_arburst = 2'd0;
                s2_arburst = s_arburst;
            end
            default: begin
                s0_arburst = 2'd0;
                s1_arburst = 2'd0;
                s2_arburst = 2'd0;
            end
        endcase
      end
      else begin
      	s0_arburst = 2'd0;
        s1_arburst = 2'd0;
        s2_arburst = 2'd0;
      end
    end

    //---------------------------------------------------
    //arvalid信号复用
    always @(*) begin
    	if(s_araddr_en) begin
        case(s_araddr[ADDR_WIDTH-1:ADDR_WIDTH-2])
            2'b01: begin 
                s0_arvalid = s_arvalid;
                s1_arvalid = 1'd0;
                s2_arvalid = 1'd0;
            end
            2'b10: begin
                s0_arvalid = 1'd0;
                s1_arvalid = s_arvalid;
                s2_arvalid = 1'd0;
            end
            2'b11: begin
                s0_arvalid = 1'd0;
                s1_arvalid = 1'd0;
                s2_arvalid = s_arvalid;
            end
            default: begin
                s0_arvalid = 1'd0;
                s1_arvalid = 1'd0;
                s2_arvalid = 1'd0;
            end
        endcase
      end
      else begin
      	s0_arvalid = 1'd0;
        s1_arvalid = 1'd0;
        s2_arvalid = 1'd0;
      end
    end

    //------------------读数据通道-----------------------
    //rready信号复用
    always @(*) begin
    	if(m_rvalid_sel_en) begin
        case(rvalid_sel)
            2'b01: begin 
                s0_rready = s_rready;
                s1_rready = 1'd0;
                s2_rready = 1'd0;
            end
            2'b10: begin
                s0_rready = 1'd0;
                s1_rready = s_rready;
                s2_rready = 1'd0;
            end
            2'b11: begin
                s0_rready = 1'd0;
                s1_rready = 1'd0;
                s2_rready = s_rready;
            end
            default: begin
                s0_rready = 1'd0;
                s1_rready = 1'd0;
                s2_rready = 1'd0;
            end
        endcase
      end
      else begin
      	s0_rready = 1'd0;
        s1_rready = 1'd0;
        s2_rready = 1'd0;
      end
    end

endmodule