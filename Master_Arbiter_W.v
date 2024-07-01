//=============================================================================
//
//Module Name:					Master_Arbiter_W.v

//Function Description:	        AXI总线仲裁器写通道仲裁
//
//------------------------------------------------------------------------------
//
//=============================================================================

`timescale 1ns/1ns

module Master_Arbiter_W (
	/**********时钟&复位**********/
	  input                       sys_clk,
	  input      	                sys_rstn,
	/********** 0号请求 **********/
    input                       wr_req_0,   
	/********** 1号请求 **********/
    input                       wr_req_1,
	/********** 2号请求 **********/
    input                       wr_req_2,
	/********** 状态转换使能 **********/
		input                       wr_state_refre,
    
    output 		[2:0]             wr_grant
);

		reg	 				m0_wgrnt;
	  reg	 				m1_wgrnt;
    reg  				m2_wgrnt;
    //=========================================================
    //常量定义
    
    
    parameter   AXI_MASTER_0 = 2'd0,    //0号主机占用总线状态
                AXI_MASTER_1 = 2'd1,    //1号主机占用总线状态
                AXI_MASTER_2 = 2'd2;    //2号主机占用总线状态

    //=========================================================
    //写地址通道仲裁状态机

    //---------------------------------------------------------
    reg     [1:0]   cur_prio   ;	 //当前状态: 代表当前的优先级
    reg     [1:0]   next_prio  ;   //下一状态：代表下一个优先级
    reg     [1:0]   gnt_id     ;   //仲裁结果id号，0表示仲裁结果为主机0
    
    //---------------------------------------------------------

    
    //状态译码，如果主机和从机数比较多的话，使用这种状态的方法可能比较难写了，建议后续采用状态转换表写
    always @(*) 
    begin
        case (cur_prio)
            AXI_MASTER_0: begin                 //0号主机占用总线状态，响应请求优先级为：0>1>2
                if(wr_req_0) 
                begin     
                	gnt_id    =  2'd0;           
                  next_prio = AXI_MASTER_1;
                end   
                else if(wr_req_1)  
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
                if(wr_req_1) 
                begin
                	gnt_id    =  2'd1;           
                  next_prio = AXI_MASTER_2;
                end
                else if(wr_req_2)        
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
                if(wr_req_2)                                                                 
                begin                       
                	gnt_id    =  2'd2;        
                  next_prio = AXI_MASTER_0; 
                end                                                          
                else if(wr_req_0)
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
        else if(wr_state_refre)
            cur_prio <= next_prio;
    end

    //---------------------------------------------------------
    wire   wr_grnt_enb   ;

    assign wr_grnt_enb = wr_req_0 | wr_req_1 | wr_req_2;
    
    always @(posedge sys_clk or negedge sys_rstn)
    begin
  	  if(!sys_rstn | wr_state_refre) begin//当复位以及遇到状态更新信号时，将仲裁信号清零
  	     m0_wgrnt    <= 1'b0;
  	     m1_wgrnt    <= 1'b0;
  	     m2_wgrnt    <= 1'b0;
  	  end
  	  else if(wr_grnt_enb) begin
  	  	case(gnt_id)
  	     2'd0:    {m2_wgrnt,m1_wgrnt,m0_wgrnt} <= 3'b001;   
  	     2'd1:    {m2_wgrnt,m1_wgrnt,m0_wgrnt} <= 3'b010;   
  	     2'd2:    {m2_wgrnt,m1_wgrnt,m0_wgrnt} <= 3'b100;     
  	   endcase    
  	  end
  	  else begin
  	    {m0_wgrnt,m1_wgrnt,m2_wgrnt} <= 3'b000; 
  	  end
		end
		assign wr_grant = {m2_wgrnt,m1_wgrnt,m0_wgrnt};
endmodule
