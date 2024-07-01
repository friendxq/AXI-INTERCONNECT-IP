//=============================================================================
//
//Module Name:					Master_Req_W.v

//Function Description:	        AXI主机写需求逻辑
//
//------------------------------------------------------------------------------
//
//=============================================================================

`timescale 1ns/1ns

module Master_Req_W (
	/**********时钟&复位**********/
	  input                       sys_clk,
	  input      	                sys_rstn,
	/********** 0号主机写地址有效 **********/
    input                       m0_awvalid,   
	/********** 1号主机写地址有效 **********/
    input                       m1_awvalid,
	/********** 2号主机写地址有效 **********/
    input                       m2_awvalid,
	/********** 主机占用情况 **********/
		input [2:0]	                wr_grant,
	/********** 总线写地址有效 **********/
		input                       s_awvalid,
	/********** 总线写地址准备 **********/
		input                       m_awready,
	/********** 总线写响应有效 **********/
		input                       m_bvalid,
	/********** 总线写响应准备 **********/
		input                       s_bready,
	/********** 一组命令完毕信号 **********/
		input                       wr_reg_flag,
    
    output reg		              wr_req_0,
    output reg		              wr_req_1,
    output reg		              wr_req_2,
    output wire		              wr_state_refre
);

		wire  				wr_req_0_tmp;
		wire  				wr_req_1_tmp;
		wire  				wr_req_2_tmp;
    //=========================================================

    
    assign wr_req_0_tmp = (wr_grant==3'b001 && m_bvalid && s_bready && !wr_reg_flag && (~(s_awvalid && m_awready)))
    																						? 1'b0:((m0_awvalid==1'b1)? 1'b1:wr_req_0);
	assign wr_req_1_tmp = (wr_grant==3'b010 && m_bvalid && s_bready && !wr_reg_flag && (~(s_awvalid && m_awready)))
																							? 1'b0:((m1_awvalid==1'b1)? 1'b1:wr_req_1);
	assign wr_req_2_tmp = (wr_grant==3'b100 && m_bvalid && s_bready && !wr_reg_flag && (~(s_awvalid && m_awready)))
																							? 1'b0:((m2_awvalid==1'b1)? 1'b1:wr_req_2);
	always @(posedge sys_clk or negedge sys_rstn)
	begin
		if(!sys_rstn) 
		begin
			wr_req_0    <= 1'b0;
			wr_req_1    <= 1'b0;
			wr_req_2    <= 1'b0;
		end 
		else
		begin
				wr_req_0 <= wr_req_0_tmp;
				wr_req_1 <= wr_req_1_tmp;
				wr_req_2 <= wr_req_2_tmp;
		end
	end
    assign wr_state_refre = m_bvalid && s_bready && !wr_reg_flag && (~(s_awvalid && m_awready));
endmodule