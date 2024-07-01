//=============================================================================
//
//Module Name:				AXI_Master.v

//Function Description:	        AXI总线模拟主机
//
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//
//Version	Modified History
//V1.0		
//
//=============================================================================

`timescale 1ns/1ns

module AXI_Master#(
    parameter   DATA_WIDTH  = 32,               //数据位宽
                ADDR_WIDTH  = 32,               //地址位宽              
                ID_WIDTH    = 4,                //ID位宽
                STRB_WIDTH  = (DATA_WIDTH/8),   //STRB位宽
                RESP_WIDTH  = 2
)(
    /**********时钟&复位**********/
    input                         sys_clk,
    input      	                  sys_rstn,
    /*********写地址通道**********/
    output reg [ID_WIDTH-1:0]     awid,
    output reg [ADDR_WIDTH-1:0]   awaddr,
    output reg [7:0]	            awlen,
    output reg                    awvalid,
    input                         awready,
    /*********写数据通道**********/
    output reg [ID_WIDTH-1:0]     wid,
    output reg [DATA_WIDTH-1:0]   wdata,
    output reg                    wlast,
    output reg                    wvalid,
    input                         wready,
    /*********写响应通道**********/
    input      [ID_WIDTH-1:0]     bid,
    input                         bvalid,
    output reg                    bready,
    /*********读地址通道**********/
    output reg [ID_WIDTH-1:0]     arid,
    output reg [ADDR_WIDTH-1:0]   araddr,
    output reg [7:0]	            arlen,
    output reg                    arvalid,
    input                         arready,
    /*********读数据通道**********/
    input  [ID_WIDTH-1:0]         rid,
    input  [DATA_WIDTH-1:0]       rdata,
    input                         rlast,
    input                         rvalid,
    output reg	 	              	rready,
    /**********控制信号***********/

    input  [1:0]                  num_order_w,              //主机占用总线时输入写命令个数
    input  [1:0]                  num_order_r,              //主机占用总线时输入读命令个数
    input                         en_w,
    input                         en_r,
    input  [7:0]                  AWLEN,
    input  [7:0]                  ARLEN,
    input  [3:0]                  ARID,
    input  [ADDR_WIDTH-1:0]       addr_start_w,
    input  [ADDR_WIDTH-1:0]       addr_start_r,
    /**********读到数据***********/
    output reg [DATA_WIDTH-1:0]   data_out,
    output reg                    data_out_vld
);
    parameter                     W_ID0 = 4'b0001,          //主机占用总线器件 写 命令ID
                                  W_ID1 = 4'b0010,
                                  W_ID2 = 4'b0100,
                                  W_ID3 = 4'b1000;


    

    reg     [2:0]                 num_order_cnt_w;          //写命令输入计数器

    reg     [1:0]                 out_wdata_cnt;            //写数据输出计数器
    reg     [2:0]                 state_wlast_cnt;          //Wlast计数器
    reg     [7:0]                 AWLEN0;
    reg     [7:0]                 AWLEN1;
    reg     [7:0]                 AWLEN2;
    reg     [7:0]                 AWLEN3;
    reg     [2:0]                 all_rlast_cnt;

    //=========================================================
    //写地址通道

    always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn|| (state_wlast_cnt == num_order_w+1'b1))
            awvalid <= 1'b0 ;
        else if(en_w)
            awvalid <= 1'b1;
        else if(awready)
            awvalid <= 1'b0 ;
    end

    always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn|| (state_wlast_cnt == num_order_w+1'b1))
            num_order_cnt_w <= 2'd0;
        else if(awvalid && awready)
            num_order_cnt_w <= num_order_cnt_w + 1'b1;
        // else if(state_wlast_cnt == (num_order_w ) && wlast && wready )
        //     num_order_cnt_w <= 1'b0;
    end
    
    always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn|| (state_wlast_cnt == num_order_w+1'b1)) begin
            AWLEN0 <= 8'd0 ;
            AWLEN1 <= 8'd0 ;
            AWLEN2 <= 8'd0 ;
            AWLEN3 <= 8'd0 ;
            awid   <= 4'd0;
        end
        else if(en_w) begin
            case (num_order_cnt_w)
                2'b00: begin
                  AWLEN0 <= AWLEN;
                  awid   <= W_ID0;
                end
                2'b01: begin
                  AWLEN1 <= AWLEN;
                  awid   <= W_ID1;
                end
                2'b10: begin
                  AWLEN2 <= AWLEN;
                  awid   <= W_ID2;
                end
                2'b11: begin
                  AWLEN3 <= AWLEN;
                  awid   <= W_ID3;
                end
                default: begin
                  AWLEN0 <= 4'd0;
                  awid   <= 4'd0;
                end    
            endcase
        end
    end

    always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn|| (state_wlast_cnt == num_order_w+1'b1)) begin
            awaddr <= 32'd0;
            awlen  <= 4'd0;
        end
        else if(en_w) begin
            awaddr <= addr_start_w;
            awlen  <= AWLEN;
        end
        else if(awready) begin
            awaddr <= 32'd0;
            awlen  <= 4'd0;
        end
    end


    //=========================================================
    //写数据通道

    parameter           state_wlast0 = 4'b0000,
                        state_wlast1 = 4'b0001,                //各个命令最先完成状态
                        state_wlast2 = 4'b0010,
                        state_wlast3 = 4'b0100,
                        state_wlast4 = 4'b1000;
    
    reg     [3:0]       state_wlast;

        always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn|| (state_wlast_cnt == num_order_w+1'b1))
            state_wlast <= state_wlast0;
        else if (wlast & wready && state_wlast_cnt==3'd0) begin
            case (wid)
              W_ID0: begin
                state_wlast <= state_wlast1;
                if(num_order_w == 2'd0) begin
                  out_wdata_cnt <= 2'b00;
                end
                else begin
                  out_wdata_cnt <= 2'b01;
                end
              end
              W_ID1: begin
                state_wlast <= state_wlast2;
                 if(num_order_w == 2'd1) begin
                  out_wdata_cnt <= 2'b00;
                end               
                else begin
                  out_wdata_cnt <= 2'b10;
                end
              end
              W_ID2: begin
                state_wlast <= state_wlast3;
                if(num_order_w == 2'd2) begin
                  out_wdata_cnt <= 2'b00;
                end
                else begin
                  out_wdata_cnt <= 2'b11;
                end
              end
              W_ID3: begin
                state_wlast <= state_wlast4;
                out_wdata_cnt <= 2'b00;
              end
              default: begin
                state_wlast <= state_wlast0; 
                out_wdata_cnt <= 2'b00;
              end
            endcase
        end
    end

    always@(posedge sys_clk, negedge sys_rstn)
    begin
        case(state_wlast)
          state_wlast0: begin
            if(!sys_rstn) begin
              out_wdata_cnt <= 2'd0;
            end
            else if(wvalid && wready &&  !wlast && out_wdata_cnt == num_order_w) begin
              out_wdata_cnt <= 2'd0;
            end
            else if(wvalid && wready && !wlast) begin
              out_wdata_cnt <= out_wdata_cnt + 1'b1;
            end
            
          end
          state_wlast1: begin
             if(wlast && wready && out_wdata_cnt == num_order_w) begin
              out_wdata_cnt <= 2'd0;
             end
             else if(wlast  && wready) begin
              out_wdata_cnt <= out_wdata_cnt + 1'b1;
            end
            end
    
          
          state_wlast2: begin
             if(wlast && wready && out_wdata_cnt == num_order_w) begin
              out_wdata_cnt <= 2'd0;
             end
             else if(wlast  && wready) begin
              out_wdata_cnt <= out_wdata_cnt + 1'b1;
            end
          end
          state_wlast3: begin
             if(wlast && wready && out_wdata_cnt == num_order_w) begin
              out_wdata_cnt <= 2'd0;
             end
             else if(wlast  && wready) begin
              out_wdata_cnt <= out_wdata_cnt + 1'b1;
            end
          end
          state_wlast4: begin
             if(wlast && wready && out_wdata_cnt == num_order_w) begin
              out_wdata_cnt <= 2'd0;
             end
             else if(wlast  && wready) begin
              out_wdata_cnt <= out_wdata_cnt + 1'b1;
            end
          end
          default: begin
            if(!sys_rstn) begin
              out_wdata_cnt <= 2'd0;
            end
            else if(wvalid && wready &&  !wlast && out_wdata_cnt == num_order_w) begin
              out_wdata_cnt <= 2'd0;
            end
            else if(wvalid && wready && !wlast && wready) begin
              out_wdata_cnt <= out_wdata_cnt + 1'b1;
            end
          end
        endcase
    end

    always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn || (state_wlast_cnt == num_order_w+1'b1))
            state_wlast_cnt <= 3'd0;
        else if(wlast && wready)
            state_wlast_cnt <= state_wlast_cnt + 1'b1;
    end


    always@(posedge sys_clk, negedge sys_rstn)          //写数据通道握手
    begin
        if(!sys_rstn || (wready&&wlast)|| (state_wlast_cnt == num_order_w+1'b1))
            wvalid <= 1'b0;
        else if(num_order_cnt_w == num_order_w +1'b1 )
            wvalid <= 1'b1;
    end

   // 产生写入的数据，便于仿真和上板测试使用
    reg [31:0]      wdata0;
    reg [31:0]      wdata1;
    reg [31:0]      wdata2;
    reg [31:0]      wdata3;
    always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn|| (state_wlast_cnt == num_order_w+1'b1)) begin
            wid    <= 4'd0;
            wdata  <= 32'd0;
            wdata0 <= 32'd0;
            wdata1 <= 32'd1;
            wdata2 <= 32'd2;
            wdata3 <= 32'd3;
        end
        else if(wready && wvalid) begin
            case (out_wdata_cnt)
            2'b00: begin
                // wid    <= W_ID0;
                // wdata  <= wdata0;
                wdata0 <= wdata0 + 1'b1;
            end
            2'b01: begin
                // wid    <= W_ID1;
                // wdata  <= wdata1;
                wdata1 <= wdata1 + 1'b1;
            end
            2'b10: begin
                // wid    <= W_ID2;
                // wdata  <= wdata2;
                wdata2 <= wdata2 + 1'b1;
            end
            2'b11: begin
                // wid    <= W_ID3;
                // wdata  <= wdata3;
                wdata3 <= wdata3 + 1'b1;
            end
            default: begin
                // wid    <= 4'd0;
                // wdata  <= 32'd0;
                wdata0 <= 32'd0;
                wdata1 <= 32'd0;
                wdata2 <= 32'd0;
                wdata3 <= 32'd0;
            end
            endcase
        end
        
        // else if(wlast) begin
        // case(wid)
        //     W_ID0: begin
        //         wid    <= 4'd0;
        //         wdata  <= 32'd0;
        //         wdata0 <= 32'd0;
        //     end
        //     W_ID1: begin
        //         wid    <= 4'd0;
        //         wdata  <= 32'd0;
        //         wdata1 <= 32'd0;
        //     end
        //     W_ID2: begin
        //         wid    <= 4'd0;
        //         wdata  <= 32'd0;
        //         wdata2 <= 32'd0;
        //     end
        //     W_ID3: begin
        //         wid    <= 4'd0;
        //         wdata  <= 32'd0;
        //         wdata3 <= 32'd0;
        //     end
        //     default: begin
        //         wid    <= 4'd0;
        //         wdata  <= 32'd0;
        //         wdata0 <= 32'd0;
        //         wdata1 <= 32'd0;
        //         wdata2 <= 32'd0;
        //         wdata3 <= 32'd0;
        //     end
        // endcase
        // end
    end
    always @(*) begin
        if (wvalid)
        begin
            case (out_wdata_cnt)
                2'b00: begin
                wid    <= W_ID0;
                wdata  <= wdata0;
                end
                2'b01: begin
                wid    <= W_ID1;
                wdata  <= wdata1;
                end
                2'b10: begin
                wid    <= W_ID2;
                wdata  <= wdata2;
                end
                2'b11: begin
                wid    <= W_ID3;
                wdata  <= wdata3;
                end
                default: 
                begin
                wid    <= 4'd0;
                wdata  <= 32'd0;
                end
            endcase
        end
        else
            begin
                wid    <= 4'd0;
                wdata  <= 32'd0;               
            end
        end
    reg  [7:0]   len_cnt0 ;
    reg  [7:0]   len_cnt1 ;
    reg  [7:0]   len_cnt2 ;
    reg  [7:0]   len_cnt3 ;

    always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn|| (state_wlast_cnt == num_order_w+1'b1)) begin
            len_cnt0 <= 8'd0;
            len_cnt1 <= 8'd0;
            len_cnt2 <= 8'd0;
            len_cnt3 <= 8'd0;
        end
        else if(wvalid && wready) 
        begin
            case(wid)
              W_ID0: begin
                if(len_cnt0 == AWLEN0)
                    len_cnt0 <= 8'd0;
                else 
                    len_cnt0 <= len_cnt0 + 1'b1;
              end
              W_ID1: begin
                if(len_cnt1 == AWLEN1)
                    len_cnt1 <= 8'd0;
                else
                   len_cnt1 <= len_cnt1 + 1'b1;
              end
              W_ID2: begin
                if(len_cnt2 == AWLEN2)
                    len_cnt2 <= 8'd0;
                else 
                    len_cnt2 <= len_cnt2 + 1'b1;
              end
              W_ID3: begin
                if(len_cnt3 == AWLEN3)
                    len_cnt3 <= 8'd0;
                else 
                    len_cnt3 <= len_cnt3 + 1'b1;
              end
              default: begin
                len_cnt0 <= 8'd0;
                len_cnt1 <= 8'd0;
                len_cnt2 <= 8'd0;
                len_cnt3 <= 8'd0;
              end
            endcase
        end
    end
        

    always@(*)
    begin
        if( wvalid && (len_cnt0==(AWLEN0-1'b1) && wid==W_ID0) ||
            wvalid && (len_cnt1==(AWLEN1-1'b1) && wid==W_ID1) ||
            wvalid && (len_cnt2==(AWLEN2-1'b1) && wid==W_ID2) ||
            wvalid && (len_cnt3==(AWLEN3-1'b1) && wid==W_ID3))
        wlast <=  1'b1;
        else
        wlast <=  1'b0;
    end
    
    //=========================================================
    //写响应通道

    always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn)
            bready <= 1'b0;
        else if(awready || !bvalid)
            bready <= 1'b1;
        else if(bvalid)
            bready <= 1'b0;
    end


    //=========================================================
    //读地址通道

    always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn)
            arvalid <= 1'b0;
        else if(en_r)
            arvalid <= 1'b1;
        else if(arready)
            arvalid <= 1'b0;
    end

    always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn)
            araddr <= 32'd0;
        else if(en_r)
            araddr <= addr_start_r;
    end
    
    always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn)
            arlen <= 4'd0 ;
        else if(en_r)
            arlen <= ARLEN;
    end

    always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn)
            arid <= 4'd0;
        else if(en_r)
            arid <= ARID;
    end



    
    //=========================================================
    //读数据通道

    always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn || (rlast && rvalid) ||(all_rlast_cnt == num_order_r+1'b1))
            rready <= 1'b0;
        else if (all_rlast_cnt < num_order_r+1'b1) begin
            rready <= 1'b1;
        end
    end


    always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn || (all_rlast_cnt == num_order_r+1'b1))
            all_rlast_cnt <= 3'd0;
        else if(rlast && rready)
            all_rlast_cnt <= all_rlast_cnt + 1'b1;
    end

    always@(posedge sys_clk, negedge sys_rstn)
    begin
        if(!sys_rstn)
        begin
            data_out <= 32'd0;
            data_out_vld <= 1'b0;
        end
        else 
        begin
          if(rready && rvalid)
          begin
            data_out <= rdata;
            data_out_vld <= 1'b1;
          end
          else
          begin
            data_out <= 32'd0;
            data_out_vld <= 1'b0;
          end
        end
    end
endmodule