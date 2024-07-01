//***************************************
//COPYRIGHT(C)2024,QI XIE
//All rights reserved.
//
//IP LIB INDEX : IP lib index just as QI XIE 
//IP Name      : AXI INTERCONNECT IP
//FILE Name    : W_ADDR_REG
//Module Name  : W_Addr_reg.v
//
//Author       : QI XIE
//Email        : 2436834315@qq.com
//Data         : 2024/4/15
//Version      : V 1.0
//
//Abstract     : 
//Called by    : Son Module
//
//****************************************     
`timescale 1ns/1ns

module W_ADDR_REG #(
    /********** 各位宽参数定义 **********/
    parameter CNT_WIDTH = 3,    //计数器位宽
    parameter REG_WIDTH = 6,    //寄存器位宽
    parameter REG_DEPTH = 4,    //寄存器深度
    parameter SEL_WIDTH = 2,    //写数据通道路由信号位宽
    parameter ID_WIDTH = 4,     //写数据和写地址通道id位宽
    parameter ADDR_WIDTH = 32   //写地址位宽
)
(
    input   sys_clk,
    input   sys_rstn,
    /*********** s_awaddr_cnt相关信号 **********/
    input   s_awvalid,
    input   m_awready,
    input   wr_state_refre,
    /************* 写响应计数器 ***************/
    input   s_bready,
    input   m_bvalid,
    /************ 写数据通道路由信号 **********/
    input   s_wvalid,
    input   m_wready,
    input   [ID_WIDTH-1:0]    s_wid,
    /*************** 寄存器输入 **************/
    input   [ADDR_WIDTH-1:0]s_awaddr,
    input   [ID_WIDTH-1:0]s_awid,

    /********** 写结束标志wr_reg_flag *********/
    output reg 	wr_reg_flag, 

    /**** 写地址通道路由使能信号 s_awaddr_en****/
    output reg  s_awaddr_en,

    /********** 写数据通道路由信号 **********/
    output  reg [SEL_WIDTH-1:0] s_wvalid_sel,
    output  reg s_wvalid_sel_en
);
    //==========================================================
    reg [REG_WIDTH-1:0] 	s_awaddr_reg [REG_DEPTH-1:0];//s_awaddr_reg

    //==========================================================
    reg [CNT_WIDTH-1:0] 	s_awaddr_cnt;               //写入地址计数器相关信号

    always @(posedge sys_clk or negedge sys_rstn )  //s_awaddr_cnt
        begin
        if(!sys_rstn)
            s_awaddr_cnt <= 3'd0;
        else
            begin
                if (wr_state_refre && ~(s_awvalid&&m_awready))
                    s_awaddr_cnt <= 3'd0;
                else if(s_awaddr_cnt < 4)
                    begin
                        if (s_awvalid && m_awready)
                            s_awaddr_cnt <= s_awaddr_cnt +1'b1;
                    end
            end
        end

    //==========================================================  
    reg [CNT_WIDTH-1:0] 	m_bvalid_cnt;               //写响应计数器 

    always @(posedge sys_clk or negedge sys_rstn )  //m_bvalid_cnt
        begin
        if(!sys_rstn)
            m_bvalid_cnt <= 1'b0;
        else
            begin
                if (wr_state_refre && ~(s_awvalid&&m_awready))
                    m_bvalid_cnt <= 3'd0;
                else if(s_bready && m_bvalid)
                    m_bvalid_cnt <= m_bvalid_cnt + 1'b1;                                     
            end
        end

    //==========================================================
    wire [CNT_WIDTH-1:0] 	delta_cnt_w;
    assign delta_cnt_w = s_awaddr_cnt - m_bvalid_cnt;   //delta_cnt_w设计

    always @(posedge sys_clk or negedge sys_rstn )      //wr_reg_flag设计
        begin
        if(!sys_rstn)
            wr_reg_flag <= 1'b0;
        else
            begin
                if (delta_cnt_w==1 && ~(s_awvalid&&m_awready))
                    wr_reg_flag <= 1'b0;
                else if(delta_cnt_w < 2)
                    wr_reg_flag <= 1'b0;
                else if(delta_cnt_w > 1)
                    wr_reg_flag <= 1'b1;                                      
            end
        end

    //==========================================================
    always @(posedge sys_clk or negedge sys_rstn )      //s_awaddr_en
        begin
        if(!sys_rstn)
            s_awaddr_en <= 1'b0;
        else
            begin
                if (s_awvalid)
                    s_awaddr_en <= 1'b1;
                else
                    s_awaddr_en <= 1'b0;
            end
        end

    //==========================================================
    always @(* )      //s_wvalid_sel[1:0]
        begin
    
          if (s_wvalid)
              begin
                  if (s_wid == s_awaddr_reg[0][ID_WIDTH-1:0])
                      s_wvalid_sel <= s_awaddr_reg[0][REG_WIDTH-1:ID_WIDTH];
                  else if(s_wid == s_awaddr_reg[1][ID_WIDTH-1:0])
                      s_wvalid_sel <= s_awaddr_reg[1][REG_WIDTH-1:ID_WIDTH];
                  else if(s_wid == s_awaddr_reg[2][ID_WIDTH-1:0])
                      s_wvalid_sel <= s_awaddr_reg[2][REG_WIDTH-1:ID_WIDTH];     
                  else if(s_wid == s_awaddr_reg[3][ID_WIDTH-1:0])
                      s_wvalid_sel <= s_awaddr_reg[3][REG_WIDTH-1:ID_WIDTH];
                  else
                      s_wvalid_sel <= 2'd0;
              end
          else begin
            s_wvalid_sel <= 2'd0;
          end
        
        end

    //==========================================================
    always @(posedge sys_clk or negedge sys_rstn )      //s_wvalid_sel_en
        begin
        if(!sys_rstn)
            s_wvalid_sel_en <= 1'b0;
        else
            begin
                if (s_wvalid)
                    s_wvalid_sel_en <= 1'b1;
                else
                    s_wvalid_sel_en <= 1'b0;
            end
        end

    //==========================================================

    always @(posedge sys_clk or negedge sys_rstn )          //s_awaddr_reg
        begin
        if(!sys_rstn)
        begin
            s_awaddr_reg[0] <= 6'd0;
            s_awaddr_reg[1] <= 6'd0;
            s_awaddr_reg[2] <= 6'd0;
            s_awaddr_reg[3] <= 6'd0;
        end
        else
            begin
                if (wr_state_refre && ~(s_awvalid && m_awready))
                    begin
                        s_awaddr_reg[0] <= 6'd0;
                        s_awaddr_reg[1] <= 6'd0;
                        s_awaddr_reg[2] <= 6'd0;
                        s_awaddr_reg[3] <= 6'd0;            
                    end
                else if(s_awvalid && m_awready)
                    begin
                        case (s_awaddr_cnt)
                            4'd0: s_awaddr_reg[0] <= {s_awaddr[ADDR_WIDTH-1:ADDR_WIDTH-2],s_awid};
                            4'd1: s_awaddr_reg[1] <= {s_awaddr[ADDR_WIDTH-1:ADDR_WIDTH-2],s_awid};
                            4'd2: s_awaddr_reg[2] <= {s_awaddr[ADDR_WIDTH-1:ADDR_WIDTH-2],s_awid};
                            4'd3: s_awaddr_reg[3] <= {s_awaddr[ADDR_WIDTH-1:ADDR_WIDTH-2],s_awid};
                            default: 
                            begin
                                s_awaddr_reg[0] <= 6'd0;
                                s_awaddr_reg[1] <= 6'd0;
                                s_awaddr_reg[2] <= 6'd0;
                                s_awaddr_reg[3] <= 6'd0;
                            end
                        endcase
                    end    
            end
        end
    endmodule