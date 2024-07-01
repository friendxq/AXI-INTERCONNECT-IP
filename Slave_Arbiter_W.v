//=============================================================================
//
//Module Name:					Slave_Arbiter_W.v

//Function Description:	        AXI总线仲裁器写通道仲裁
//
//------------------------------------------------------------------------------
//
//=============================================================================

`timescale 1ns/1ns

module Slave_Arbiter_W (
	/**********时钟&复位**********/
	  input                       sys_clk,
	  input      	                sys_rstn,
	/********** 0号请求 **********/
    input                       s0_bvalid,   
	/********** 1号请求 **********/
    input                       s1_bvalid,
	/********** 2号请求 **********/
    input                       s2_bvalid,
    
    input                       m_bvalid,
    
    input                       s_bready,
    
    output    [2:0]             bvalid_sel
);

		reg	 		  	s0_wgrnt;
	  reg	 		  	s1_wgrnt;
    reg  		  	s2_wgrnt;
    
    //=========================================================
    //常量定义 
    parameter   AXI_MASTER_0 = 2'd0,    //0号从机占用总线状态
                AXI_MASTER_1 = 2'd1,    //1号从机占用总线状态
                AXI_MASTER_2 = 2'd2;   //2号从机占用总线状态

    //=========================================================
    //写地址通道仲裁状态机

    //---------------------------------------------------------
    reg     [1:0]   cur_prio   ;   //当前状态: 代表当前的优先级
    reg     [1:0]   next_prio  ;   //下一状态：代表下一个优先级
    reg     [1:0]   gnt_id     ;
    
    //---------------------------------------------------------
    
    //状态译码
    always @(*) 
    begin
        case (cur_prio)
            AXI_MASTER_0: begin                 //0号从机占用总线状态，响应请求优先级为：0>1>2
                if(s0_bvalid) 
                begin     
                	gnt_id    =  2'd0;          
                  next_prio = AXI_MASTER_1;
                end   
                else if(s1_bvalid)  
                begin     
                	gnt_id    =  2'd1;           
                  next_prio = AXI_MASTER_2;
                end   
                else  
                begin     
                	gnt_id    =  2'd2;           
                  next_prio = AXI_MASTER_0;
                end 
              
            end
            AXI_MASTER_1: begin                 //1号从机占用总线状态，响应请求优先级为：1>2>0                           
                if(s1_bvalid) 
                begin
              		gnt_id    =  2'd1;           
                  next_prio = AXI_MASTER_2;
                end
                else if(s2_bvalid)        
                begin                       
                	gnt_id    =  2'd2;        
                  next_prio = AXI_MASTER_0; 
                end                               
                else              
                begin                      
                	gnt_id    =  2'd0;       
                  next_prio = AXI_MASTER_1;
                end                        
            end                                                                                           
            AXI_MASTER_2: begin                 //2号从机占用总线状态，响应请求优先级为：2>0>1          
                if(s2_bvalid)                                                            
                begin                       
                	gnt_id    =  2'd2;        
                  next_prio = AXI_MASTER_0; 
                end                                                          
                else if(s0_bvalid)
                begin                      
                	gnt_id    =  2'd0;       
                  next_prio = AXI_MASTER_1;
                end       
                else 
                begin
                	gnt_id    =  2'd1;           
                  next_prio = AXI_MASTER_2;
                end
            end
            default:
            begin
            	gnt_id    =  2'd0; 
              next_prio = AXI_MASTER_0;      //默认状态为0号从机占用总线
            end
        endcase
    end

    //---------------------------------------------------------
    //更新状态寄存
    wire				S_wr_state_refre;

    assign S_wr_state_refre = m_bvalid && s_bready;

    always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn)
            cur_prio <= AXI_MASTER_0;         //默认状态为0号从机占用总线
        else if(S_wr_state_refre)
            cur_prio <= next_prio;
    end

    //---------------------------------------------------------
    wire   S_wr_grnt_enb;

    assign S_wr_grnt_enb = s0_bvalid | s1_bvalid | s2_bvalid ;
    
    always @(posedge sys_clk or negedge sys_rstn)
    begin
  	  if(!sys_rstn | S_wr_state_refre) begin
  	     s0_wgrnt    <= 1'b0;
  	     s1_wgrnt    <= 1'b0;
  	     s2_wgrnt    <= 1'b0;
  	  end 
  	  else if(S_wr_grnt_enb) begin
  	  	case(gnt_id)
  	     2'd0:    {s2_wgrnt,s1_wgrnt,s0_wgrnt} <= 3'b001;   
  	     2'd1:    {s2_wgrnt,s1_wgrnt,s0_wgrnt} <= 3'b010;   
  	     2'd2:    {s2_wgrnt,s1_wgrnt,s0_wgrnt} <= 3'b100;     
  	   endcase    
  	  end
  	  else begin
  	    {s2_wgrnt,s1_wgrnt,s0_wgrnt} <= 3'b000; 
  	  end
		end
		assign bvalid_sel = {s2_wgrnt,s1_wgrnt,s0_wgrnt};
endmodule
