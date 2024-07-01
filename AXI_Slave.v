//=============================================================================
//
//Module Name:				AXI_Slave.v

//Function Description:	        AXI总线模拟从机
//
//
//=============================================================================
`timescale 1ns/1ns

module AXI_Slave(
    /**********时钟&复位**********/
    input               sys_clk,
    input      	        sys_rstn,
    /*********写地址通道**********/
    input      [3:0]    awid,
    input      [31:0]   awaddr,
    input      [7:0]	awlen,
    input               awvalid,
    output reg          awready,
    /*********写数据通道**********/
    input      [3:0]    wid,
    input      [31:0]   wdata,
    input               wlast,
    input               wvalid,
    output reg          wready,
    /*********写响应通道**********/
    output reg [3:0]    bid,
    output reg          bvalid,
    input               bready,
    /*********读地址通道**********/
    input      [3:0]    arid,
    input      [31:0]   araddr,
    input      [7:0]	arlen,
    input               arvalid,
    output reg          arready,
    /*********读数据通道**********/
    output reg [3:0]    rid,
    output     [31:0]   rdata,
    output reg          rlast,
    output reg          rvalid,
    input     	 		rready
);

    parameter                     W_ID0 = 4'b0001,          //主机占用总线器件 写 命令ID
                                  W_ID1 = 4'b0010,
                                  W_ID2 = 4'b0100,
                                  W_ID3 = 4'b1000;

    reg  [7:0]   r_len_cnt0 ;                      //读数据个数计数
    reg  [7:0]   r_len_cnt1 ;
    reg  [7:0]   r_len_cnt2 ;
    reg  [7:0]   r_len_cnt3 ;

    reg     [3:0]                 R_ID0;          //主机占用总线器件 读 命令ID
    reg     [3:0]                 R_ID1;
    reg     [3:0]                 R_ID2;
    reg     [3:0]                 R_ID3;      

    reg     [7:0]                 ARLEN0;
    reg     [7:0]                 ARLEN1;
    reg     [7:0]                 ARLEN2;
    reg     [7:0]                 ARLEN3;

    reg     [11:0]                 ARADDR0;
    reg     [11:0]                 ARADDR1;
    reg     [11:0]                 ARADDR2;
    reg     [11:0]                 ARADDR3;

    reg          en_data_r ;
    reg  [31:0]  addr_w    ; //写入到从的地址

    reg  [7:0]   cnt_addr_r;
    reg          RVALID_p0 , RLAST_p0  ;
    wire         wren      ;
    wire [11:0]   wraddress;
    reg  [11:0]   rdaddress ;
    reg [2:0]           state_rlast_cnt;
    
    //=========================================================
    //写地址通道

   always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn)
            awready <= 1'b0;
        else if(awvalid&&!awready)
            awready <= 1'b1;
        else if(!awvalid)
            awready <= 1'b0;
    end

    reg [7:0] len_w;

    always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn)
            len_w <= 8'd0;
        else if(awvalid)
            len_w <= awlen;
    end

    //=========================================================
    //写数据通道

    reg [31:0] ram [0:31];

    always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn)
            wready <= 1'b0;
        else if(wvalid&&!wready)
            wready <= 1'b1;
        else if(wvalid)
            wready <= 1'b0;
    end

    reg  [7:0] cnt_addr_w;
    
    always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn)
            addr_w <= 32'd0;
        else if(awvalid)
            addr_w <= awaddr[11:0] ;
    end

    always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn)
            cnt_addr_w <= 8'd0;
        else if(wvalid && wready) 
        begin
            if(cnt_addr_w==len_w)
                cnt_addr_w <= 8'd0;
            else
                cnt_addr_w <= cnt_addr_w + 1'b1;
        end
        else if(awvalid)
            cnt_addr_w <= 8'd0;
    end

    assign  wren =  wvalid  & wready ;

    assign  rden =  rready ;
    
    assign  wraddress = addr_w[11:0] + cnt_addr_w ;
    
     always@(*)
     begin
         case(state_rlast_cnt)
            3'd0: begin
              rdaddress <= ARADDR0 + r_len_cnt0;
            end
            3'd1: begin
              rdaddress <= ARADDR1 + r_len_cnt1;
            end
            3'd2: begin
              rdaddress <= ARADDR2 + r_len_cnt2;
            end
            3'd3: begin
              rdaddress <= ARADDR3 + r_len_cnt3;
            end
            default: begin
              rdaddress <= 12'd0;
            end
         endcase
     end
    
    ram_axi  u0_ram_axi (
	    .clock     (sys_clk),
	    .data      (wdata),
	    .rdaddress (rdaddress),
	    .rden      (rden),
	    .wraddress (wraddress),
	    .wren      (wren),
	    .q         (rdata)
	    );


    //=========================================================
    //写响应通道

    always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn)
            bvalid <= 1'b0;
        else if(wlast&&wvalid)
            bvalid <= 1'b1;
        else if(bready)
            bvalid <= 1'b0;
        else
            bvalid <= 1'b0;
    end

    always@(posedge sys_clk, negedge sys_rstn)
    begin
        if (!sys_rstn) begin
          bid <= 4'd0;
        end
        else if(wlast&&wvalid&&wready) begin
          case(wid)
            W_ID0: begin
              bid <= wid;
            end
            W_ID1: begin
              bid <= wid;
            end
            W_ID2: begin
              bid <= wid;
            end
            W_ID3: begin
              bid <= wid;
            end
            default: begin
              bid <= wid;
            end
          endcase
        end
        else begin
          bid <= 4'd0;
        end
    end

    //=========================================================
    //读地址通道
    
   

    always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn)
            arready <= 1'b0;
        else if(arvalid && !arready)
            arready <= 1'b1;
        else if(!arvalid)
            arready <= 1'b0;
    end
    
    reg [2:0]           num_order_cnt_r;
    always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn || (state_rlast_cnt == num_order_cnt_r))
            num_order_cnt_r <= 1'b0;
        else if(arvalid && arready)
            num_order_cnt_r <= num_order_cnt_r + 1'b1;
    end

    

    
    always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn || (state_rlast_cnt == num_order_cnt_r)) begin
            ARLEN0 <= 8'd0;
            ARLEN1 <= 8'd0;
            ARLEN2 <= 8'd0;
            ARLEN3 <= 8'd0;
            ARADDR0 <= 12'd0;
            ARADDR1 <= 12'd0;
            ARADDR2 <= 12'd0;
            ARADDR3 <= 12'd0;
            R_ID0   <= 4'd0;
            R_ID1   <= 4'd0;
            R_ID2   <= 4'd0;
            R_ID3   <= 4'd0;
        end
        else if(arvalid && arready) begin
            case (num_order_cnt_r)
                2'b00: begin
                  ARLEN0 <= arlen;
                  ARADDR0 <= araddr[11:0];
                  R_ID0   <= arid;
                end
                2'b01: begin
                  ARLEN1 <= arlen;
                  ARADDR1 <= araddr[11:0];
                  R_ID1   <= arid;
                end
                2'b10: begin
                  ARLEN2 <= arlen;
                  ARADDR2 <= araddr[11:0];
                  R_ID2   <= arid;
                end
                2'b11: begin
                  ARLEN3 <= arlen;
                  ARADDR3 <= araddr[11:0];
                  R_ID3   <= arid;
                end
                default: begin
                  ARLEN0 <= 8'd0;
                  ARLEN1 <= 8'd0;
                  ARLEN2 <= 8'd0;
                  ARLEN3 <= 8'd0;
                  ARADDR0 <= 12'd0;
                  ARADDR1 <= 12'd0;
                  ARADDR2 <= 12'd0;
                  ARADDR3 <= 12'd0;
                  R_ID0   <= 4'd0;
                  R_ID1   <= 4'd0;
                  R_ID2   <= 4'd0;
                  R_ID3   <= 4'd0;
                end    
            endcase
        end
    end

    
    //=========================================================
    //读数据通道
    always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn)
            rvalid <= 1'b0;
        else if(rready&&!rvalid)
            rvalid <= 1'b1;
        else if(rready)
            rvalid <= 1'b0;
    end

    always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn)
            rid <= 4'd0;
        else if(rden) begin
          case(state_rlast_cnt)
            3'd0: begin
              rid <= R_ID0;
            end
            3'd1: begin
              rid <= R_ID1;
            end
            3'd2: begin
              rid <= R_ID2;
            end
            3'd3: begin
              rid <= R_ID3;
            end
            default: begin
              rid <= 4'd0;
            end
          endcase
        end

    end
    

    
    always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn|| (state_rlast_cnt == num_order_cnt_r)) begin
            r_len_cnt0 <= 8'd0;
            r_len_cnt1 <= 8'd0;
            r_len_cnt2 <= 8'd0;
            r_len_cnt3 <= 8'd0;
        end
        else if(rvalid && rready) 
        begin
            case(rid)
              R_ID0: begin
                if(r_len_cnt0 == ARLEN0)
                    r_len_cnt0 <= 8'd0;
                else 
                    r_len_cnt0 <= r_len_cnt0 + 1'b1;
              end
              R_ID1: begin
                if(r_len_cnt1 == ARLEN1)
                    r_len_cnt1 <= 8'd0;
                else
                   r_len_cnt1 <= r_len_cnt1 + 1'b1;
              end
              R_ID2: begin
                if(r_len_cnt2 == ARLEN2)
                    r_len_cnt2 <= 8'd0;
                else 
                    r_len_cnt2 <= r_len_cnt2 + 1'b1;
              end
              R_ID3: begin
                if(r_len_cnt3 == ARLEN3)
                    r_len_cnt3 <= 8'd0;
                else 
                    r_len_cnt3 <= r_len_cnt3 + 1'b1;
              end
              default: begin
                r_len_cnt0 <= 8'd0;
                r_len_cnt1 <= 8'd0;
                r_len_cnt2 <= 8'd0;
                r_len_cnt3 <= 8'd0;
              end
            endcase
        end
    end

    
    always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn || (state_rlast_cnt == num_order_cnt_r))
            state_rlast_cnt <= 3'd0;
        else if(rlast && rready)
            state_rlast_cnt <= state_rlast_cnt + 1'b1;
    end

    //RLAST逻辑
    always@(*)
    begin
        if( rvalid && (r_len_cnt0==(ARLEN0-1'b1) && rid==R_ID0) ||
            rvalid && (r_len_cnt1==(ARLEN1-1'b1) && rid==R_ID1) ||
            rvalid && (r_len_cnt2==(ARLEN2-1'b1) && rid==R_ID2) ||
            rvalid && (r_len_cnt3==(ARLEN3-1'b1) && rid==R_ID3))
        rlast <=  1'b1;
        else
        rlast <=  1'b0;
    end

    


endmodule