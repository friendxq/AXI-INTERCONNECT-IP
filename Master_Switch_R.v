//=============================================================================
//
//Module Name:					Master_Switch_R.v

//Function Description:	        AXI总线读通道主控用多路复用器
//=============================================================================

`timescale 1ns/1ns

module Master_Switch_R#(
    parameter   DATA_WIDTH  = 32,
                ADDR_WIDTH  = 32,
                ID_WIDTH    = 4,
                RESP_WIDTH  = 2
)(
	  /********* 时钟&复位 *********/
	  input                       sys_clk,
	  input      	                sys_rstn,
    /********** 0号主控 **********/
    //读地址通道
	  input      [ID_WIDTH-1:0]   m0_arid,
    input	  	 [ADDR_WIDTH-1:0] m0_araddr,
    input      [7:0]            m0_arlen,
    input      [2:0]            m0_arsize,
    input      [1:0]            m0_arburst,
    input                       m0_arvalid,
    output reg                  m0_arready,
    //读数据通道
    input 			                m0_rready,
    output reg [ID_WIDTH-1:0]   m0_rid,
    output reg [DATA_WIDTH-1:0] m0_rdata,
    output reg [RESP_WIDTH-1:0] m0_rresp,
    output reg                  m0_rlast,
    output reg                  m0_rvalid,
    /********** 1号主控 **********/
    //读地址通道
	  input      [ID_WIDTH-1:0]   m1_arid,
    input	     [ADDR_WIDTH-1:0] m1_araddr,
    input      [7:0]            m1_arlen,
    input      [2:0]            m1_arsize,
    input      [1:0]            m1_arburst,
    input                       m1_arvalid,
    output reg                  m1_arready,
    //读数据通道
    input 			                m1_rready,
    output reg [ID_WIDTH-1:0]   m1_rid,
    output reg [DATA_WIDTH-1:0] m1_rdata,
    output reg [RESP_WIDTH-1:0] m1_rresp,
    output reg                  m1_rlast,
    output reg                  m1_rvalid,
    /********** 2号主控 **********/
    //读地址通道
	  input      [ID_WIDTH-1:0]   m2_arid,
    input	  	 [ADDR_WIDTH-1:0] m2_araddr,
    input      [7:0]            m2_arlen,
    input      [2:0]            m2_arsize,
    input      [1:0]            m2_arburst,
    input                       m2_arvalid,
    output reg                  m2_arready,
    //读数据通道
    input 			                m2_rready,
    output reg [ID_WIDTH-1:0]   m2_rid,
    output reg [DATA_WIDTH-1:0] m2_rdata,
    output reg [RESP_WIDTH-1:0] m2_rresp,
    output reg                  m2_rlast,
    output reg                  m2_rvalid,
    /******** 从机侧信号 ********/
    //读地址通道
    output reg [ID_WIDTH-1:0]   s_arid,
    output reg [ADDR_WIDTH-1:0]	s_araddr,
    output reg [7:0]            s_arlen,
    output reg [2:0]            s_arsize,
    output reg [1:0]            s_arburst,
    output reg                  s_arvalid,
    input                       m_arready,
    //读数据通道
    output reg                  s_rready,
    input			 [ID_WIDTH-1:0]   m_rid,
    input			 [DATA_WIDTH-1:0] m_rdata,
    input			 [RESP_WIDTH-1:0] m_rresp,
    input			                  m_rlast,
    input			                  m_rvalid,
    /******** 通用信号 ********/
    input     [2:0]             rd_grant
);
    //=========================================================
    //读入通路的多路复用主控信号

    //---------------------------------------------------------
    //其他信号复用
    always @(*) 
    begin
        case(rd_grant)     //判断读入通路的仲裁结果
            3'b001: begin
                s_arid      =  m0_arid;
                s_araddr    =  m0_araddr;
                s_arlen     =  m0_arlen;
                s_arsize    =  m0_arsize;
                s_arburst   =  m0_arburst;
                s_arvalid   =  m0_arvalid;
                s_rready 		=  m0_rready;
            end
            3'b010: begin
                s_arid      =  m1_arid;
                s_araddr    =  m1_araddr;
                s_arlen     =  m1_arlen;
                s_arsize    =  m1_arsize;
                s_arburst   =  m1_arburst;
                s_arvalid   =  m1_arvalid;
                s_rready 		=  m1_rready;
            end
            3'b100: begin
                s_arid      =  m2_arid;
                s_araddr    =  m2_araddr;
                s_arlen     =  m2_arlen;
                s_arsize    =  m2_arsize;
                s_arburst   =  m2_arburst;
                s_arvalid   =  m2_arvalid;
                s_rready 		=  m2_rready;
            end
            default: begin
                s_arid      =  4'd0;
                s_araddr    =  32'd0;
                s_arlen     =  8'd0;
                s_arsize    =  3'd0;
                s_arburst   =  2'd0;
                s_arvalid   =  1'b0;
                s_rready    =  1'b0;
            end
        endcase
    end


    //---------------------------------------------------------
    //arready信号复用
    always @(*) begin
        case(rd_grant)
            3'b001: begin 
                m0_arready = m_arready;
                m1_arready = 1'b0;
                m2_arready = 1'b0;
            end
            3'b010: begin
                m0_arready = 1'b0;
                m1_arready = m_arready;
                m2_arready = 1'b0;
            end
            3'b100: begin
                m0_arready = 1'b0;
                m1_arready = 1'b0;
                m2_arready = m_arready;
            end
            default: begin
                m0_arready = 1'b0;
                m1_arready = 1'b0;
                m2_arready = 1'b0;
            end
        endcase
    end

//---------------------------------------------------------
    //rvalid信号复用
    always @(*) begin
        case(rd_grant)
            3'b001: begin 
                m0_rvalid = m_rvalid;
                m1_rvalid = 1'b0;
                m2_rvalid = 1'b0;
            end
            3'b010: begin
                m0_rvalid = 1'b0;
                m1_rvalid = m_rvalid;
                m2_rvalid = 1'b0;
            end
            3'b100: begin
                m0_rvalid = 1'b0;
                m1_rvalid = 1'b0;
                m2_rvalid = m_rvalid;
            end
            default: begin
                m0_rvalid = 1'b0;
                m1_rvalid = 1'b0;
                m2_rvalid = 1'b0;
            end
        endcase
    end
    
//---------------------------------------------------------
    //rid信号复用
    always @(*) begin
        case(rd_grant)
            3'b001: begin 
                m0_rid = m_rid;
                m1_rid = 4'd0;
                m2_rid = 4'd0;
            end
            3'b010: begin
                m0_rid = 4'd0;
                m1_rid = m_rid;
                m2_rid = 4'd0;
            end
            3'b100: begin
                m0_rid = 4'd0;
                m1_rid = 4'd0;
                m2_rid = m_rid;
            end
            default: begin
                m0_rid = 4'd0;
                m1_rid = 4'd0;
                m2_rid = 4'd0;
            end
        endcase
    end
    
//---------------------------------------------------------
    //rdata信号复用
    always @(*) begin
        case(rd_grant)
            3'b001: begin 
                m0_rdata = m_rdata;
                m1_rdata = 32'd0;
                m2_rdata = 32'd0;
            end
            3'b010: begin
                m0_rdata = 32'd0;
                m1_rdata = m_rdata;
                m2_rdata = 32'd0;
            end
            3'b100: begin
                m0_rdata = 32'd0;
                m1_rdata = 32'd0;
                m2_rdata = m_rdata;
            end
            default: begin
                m0_rdata = 32'd0;
                m1_rdata = 32'd0;
                m2_rdata = 32'd0;
            end
        endcase
    end
    
//---------------------------------------------------------
    //rresp信号复用
    always @(*) begin
        case(rd_grant)
            3'b001: begin 
                m0_rresp = m_rresp;
                m1_rresp = 2'd0;
                m2_rresp = 2'd0;
            end
            3'b010: begin
                m0_rresp = 2'd0;
                m1_rresp = m_rresp;
                m2_rresp = 2'd0;
            end
            3'b100: begin
                m0_rresp = 2'd0;
                m1_rresp = 2'd0;
                m2_rresp = m_rresp;
            end
            default: begin
                m0_rresp = 2'd0;
                m1_rresp = 2'd0;
                m2_rresp = 2'd0;
            end
        endcase
    end
    
//---------------------------------------------------------
    //rlast信号复用
    always @(*) begin
        case(rd_grant)
            3'b001: begin 
                m0_rlast = m_rlast;
                m1_rlast = 1'b0;
                m2_rlast = 1'b0;
            end
            3'b010: begin
                m0_rlast = 1'b0;
                m1_rlast = m_rlast;
                m2_rlast = 1'b0;
            end
            3'b100: begin
                m0_rlast = 1'b0;
                m1_rlast = 1'b0;
                m2_rlast = m_rlast;
            end
            default: begin
                m0_rlast = 1'b0;
                m1_rlast = 1'b0;
                m2_rlast = 1'b0;
            end
        endcase
    end
    
    
endmodule