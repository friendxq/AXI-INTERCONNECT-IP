//=============================================================================
//
//Module Name:					Master_Arbiter_R.v

//Function Description:	        AXI总线仲裁器读通道仲裁
//
//------------------------------------------------------------------------------
//
//=============================================================================

`timescale 1ns/1ns

module Master_Arbiter_R (
	/**********时钟&复位**********/
	  input                       sys_clk,
	  input      	                sys_rstn,
	/********** 0号请求 **********/
    input                       rd_req_0,   
	/********** 1号请求 **********/
    input                       rd_req_1,
	/********** 2号请求 **********/
    input                       rd_req_2,
	/********** 状态转换使能 **********/
		input                       rd_state_refre,
    
    output 		[2:0]             rd_grant
);

		reg	 				m0_rgrnt;
	  reg	 				m1_rgrnt;
    reg  				m2_rgrnt;
    //=========================================================
    //常量定义

    
    parameter   AXI_MASTER_0 = 2'd0,    //0号主机占用总线状态
                AXI_MASTER_1 = 2'd1,    //1号主机占用总线状态
                AXI_MASTER_2 = 2'd2;    //2号主机占用总线状态

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
            AXI_MASTER_0: begin                 //0号主机占用总线状态，响应请求优先级为：0>1>2
                if(rd_req_0) 
                begin     
                	gnt_id    =  2'd0;           
                  next_prio = AXI_MASTER_1;
                end   
                else if(rd_req_1)  
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
            AXI_MASTER_1: begin                 //1号主机占用总线状态，响应请求优先级为：1>2>0          'd1: begin                 
                if(rd_req_1) 
                begin
                	gnt_id    =  2'd1;           
                  next_prio = AXI_MASTER_2;
                end
                else if(rd_req_2)        
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
            AXI_MASTER_2: begin                 //2号主机占用总线状态，响应请求优先级为：2>0>1          
                if(rd_req_2)                                                                 
                begin                       
                	gnt_id    =  2'd2;        
                  next_prio = AXI_MASTER_0; 
                end                                                          
                else if(rd_req_0)
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
              next_prio = AXI_MASTER_0;      //默认状态为0号主机占用总线
            end
        endcase
    end

    

    //---------------------------------------------------------
    //更新状态寄存
    always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn)
            cur_prio <= AXI_MASTER_0;         //默认状态为0号主机占用总线
        else if(rd_state_refre)
            cur_prio <= next_prio;
    end

    //---------------------------------------------------------
    wire   rd_grnt_enb   ;

    assign rd_grnt_enb = rd_req_0 | rd_req_1 | rd_req_2 ;
    
    always @(posedge sys_clk or negedge sys_rstn)
    begin
  	  if(!sys_rstn | rd_state_refre) begin//遇到全局复位或者读状态更新时，仲裁信号清零
  	     m0_rgrnt    <= 1'b0;
  	     m1_rgrnt    <= 1'b0;
  	     m2_rgrnt    <= 1'b0;
  	  end 
  	  else if(rd_grnt_enb) begin
  	  	case(gnt_id)
  	     2'd0:    {m0_rgrnt,m1_rgrnt,m2_rgrnt} <= 3'b100;   
  	     2'd1:    {m0_rgrnt,m1_rgrnt,m2_rgrnt} <= 3'b010;   
  	     2'd2:    {m0_rgrnt,m1_rgrnt,m2_rgrnt} <= 3'b001;     
  	   endcase    
  	  end
  	  else begin
  	    {m0_rgrnt,m1_rgrnt,m2_rgrnt} <= 3'b000; 
  	  end
		end
		assign rd_grant = {m2_rgrnt,m1_rgrnt,m0_rgrnt};
endmodule
