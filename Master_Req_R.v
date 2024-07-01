//=============================================================================
//
//Module Name:					Master_Req_R.v

//Function Description:	        AXI主机读需求逻辑
//
//------------------------------------------------------------------------------
//
//=============================================================================

`timescale 1ns/1ns

module Master_Req_R (
	/**********时钟&复位**********/
	  input                       sys_clk,
	  input      	              	sys_rstn,
	/********** 0号主机读地址有效 **********/
    input                       m0_arvalid,   
	/********** 1号主机读地址有效 **********/
    input                       m1_arvalid,
	/********** 2号主机读地址有效 **********/
    input                       m2_arvalid,
	/********** 主机占用情况 **********/
		input  [2:0]                rd_grant,
	/********** 总线读地址有效 **********/
		input                       s_arvalid,
	/********** 总线读地址准备 **********/
		input                       m_arready,
	/********** 总线读有效 **********/
		input                       m_rvalid,
	/********** 总线读last **********/
		input                       m_rlast,
	/********** 总线读准备 **********/
		input                       s_rready,
	/********** 一组命令完毕信号 **********/
		input                       rd_reg_flag,
    
    output reg		              rd_req_0,
    output reg		              rd_req_1,
    output reg		              rd_req_2,
    output 				          rd_state_refre
);

		wire  				rd_req_0_tmp;
		wire  				rd_req_1_tmp;
		wire  				rd_req_2_tmp;
    //=========================================================

    
  assign rd_req_0_tmp = (rd_grant==3'b001 && m_rlast && m_rvalid && s_rready && !rd_reg_flag && (~(s_arvalid && m_arready)))
    												  								? 1'b0:((m0_arvalid==1'b1)? 1'b1:rd_req_0);
	assign rd_req_1_tmp = (rd_grant==3'b010 && m_rlast && m_rvalid && s_rready && !rd_reg_flag && (~(s_arvalid && m_arready)))
																							? 1'b0:((m1_arvalid==1'b1)? 1'b1:rd_req_1);
	assign rd_req_2_tmp = (rd_grant==3'b100 && m_rlast && m_rvalid && s_rready && !rd_reg_flag && (~(s_arvalid && m_arready)))
																							? 1'b0:((m2_arvalid==1'b1)? 1'b1:rd_req_2);
	always @(posedge sys_clk or negedge sys_rstn)
		if(!sys_rstn) 
		begin
			rd_req_0    <= 1'b0;
			rd_req_1    <= 1'b0;
			rd_req_2    <= 1'b0;
		end 
		else
		begin
				rd_req_0 <= rd_req_0_tmp;
				rd_req_1 <= rd_req_1_tmp;
				rd_req_2 <= rd_req_2_tmp;
		end
    assign rd_state_refre = m_rlast && m_rvalid && s_rready && !rd_reg_flag && (~(s_arvalid && m_arready));
endmodule