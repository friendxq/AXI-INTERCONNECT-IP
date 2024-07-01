//***************************************
//COPYRIGHT(C)2024,QI XIE
//All rights reserved.
//
//IP LIB INDEX : IP lib index just as QI XIE 
//IP Name      : AXI INTERCONNET IP
//FILE Name    : R_ADDR_REG.V
//Module Name  : R_ADDR_REG.V
//
//Author       : QI XIE
//Email        : 2436834315@qq.com
//Data         : 2024/4/15
//Version      : V 1.0
//
//Abstract     : 
//Called by    : Son file
//
//****************************************
`timescale 1ns/1ns

module R_ADDR_REG (
    input           sys_clk,
    input           sys_rstn,

    /********** s_araddr_cnt[2:0] **********/
    input           s_arvalid,
    input           m_arready,
    input           rd_state_refre,
    /********** m_rlast_cnt[2:0]_input **********/
    input           s_rready,
    input           m_rvalid,
    input           m_rlast,
    /********** 读地址通道路由有效信号 **********/
    output      reg  s_araddr_en,
    /********** 结束标志信号rd_reg_flag **********/
    output      reg  rd_reg_flag
);
    
    //==========================================================    
    reg [2:0] 	s_araddr_cnt;       //s_araddr_cnt
    always @(posedge sys_clk or negedge sys_rstn )  //s_araddr_cnt[2:0]
        begin
        if(!sys_rstn)
            s_araddr_cnt <= 3'd0;
        else
            begin
                if (rd_state_refre && ~(s_arvalid&&m_arready))
                        s_araddr_cnt <= 3'd0;
                else if(s_araddr_cnt < 4)
                    begin
                        if (s_arvalid && m_arready)
                            s_araddr_cnt <= s_araddr_cnt + 1'b1;
                    end
            end
        end
        
    //==========================================================
    reg [2:0] 	m_rlast_cnt;        //s_rlast_cnt
    always @(posedge sys_clk or negedge sys_rstn )   //m_rlast_cnt[2:0]
        begin
        if(!sys_rstn)
            m_rlast_cnt <= 3'd0;
        else
            begin
                if (rd_state_refre && ~(s_arvalid&&m_arready))
                        m_rlast_cnt <= 3'd0;
                else if(m_rvalid && s_rready && m_rlast )
                    m_rlast_cnt <= m_rlast_cnt + 1'b1;           
            end
        end

    //==========================================================
    wire [2:0] 	delta_cnt_r;        //delta_cnt_r

    assign delta_cnt_r = s_araddr_cnt - m_rlast_cnt;    //delta_cnt_r[2:0]

    always @(posedge sys_clk or negedge sys_rstn )  //传输给请求模块的结束标志信号rd_reg_flag
        begin
        if(!sys_rstn)
            rd_reg_flag <= 1'b0;
        else
            begin
                if (delta_cnt_r==3'd1 && m_arready && s_arvalid)
                    rd_reg_flag <= 1'b0;
                else if(delta_cnt_r <= 3'd1)
                    rd_reg_flag <= 1'b0;
                else if(delta_cnt_r > 3'd1)
                    rd_reg_flag <= 1'b1;
            end
        end

    //==========================================================   
    always @(posedge sys_clk or negedge sys_rstn )  //读地址路由有效信号s_araddr_en
        begin
        if(!sys_rstn)
            s_araddr_en <= 1'b0;
        else
            begin
                if (s_arvalid)
                        s_araddr_en <= 1'b1;
                else
                    s_araddr_en <= 1'b0;
            end
        end

endmodule