//--=================================--//
// A new version of fifo 
// 1. the empty & full is ouput of flip-flop
// 2. the gray-code is the output of filp-flop
//--=================================--// 
module asyn_fifo_v2 #(
	parameter DATA_WIDTH = 16 ,					// DPRAM数据总线宽度
	parameter FIFO_DEPTH = 16 ,					// DPRAM存储深度
	parameter ADDR  = 4 					// DPRAM地址总线宽度    
)(
    input               wr_clk          ,
    input               rst_n           ,
    input               wr_en           ,
    input [DATA_WIDTH-1:0]  wr_data     ,

    input               rd_clk          ,
    input               rd_rst_n        ,
    input               rd_en           ,
    output[DATA_WIDTH-1:0]  rd_data     ,
    
    output              full            ,
    output              empty           
);
    localparam  ADDR_WIDTH = $clog2(FIFO_DEPTH);
    logic [DATA_WIDTH-1:0]  mem [{(ADDR_WIDTH-1){1'b1}}:0];
    
    logic [ADDR_WIDTH:0]    wr_bin_addr_nxt ;
    logic [ADDR_WIDTH:0]    wr_bin_addr     ;
    logic [ADDR_WIDTH:0]    wr_gray_addr_nxt;  
    logic [ADDR_WIDTH:0]    wr_gray_addr    ;
    logic [ADDR_WIDTH:0]    wr_gray_addr_rd_asyn1;
    logic [ADDR_WIDTH:0]    wr_gray_addr_rd_asyn2;

    logic [ADDR_WIDTH:0]    rd_bin_addr_nxt ;
    logic [ADDR_WIDTH:0]    rd_bin_addr     ;
    logic [ADDR_WIDTH:0]    rd_gray_addr_nxt;  
    logic [ADDR_WIDTH:0]    rd_gray_addr    ;
    logic [ADDR_WIDTH:0]    rd_gray_addr_wr_asyn1;
    logic [ADDR_WIDTH:0]    rd_gray_addr_wr_asyn2;

    logic                   full_nxt        ;
    logic                   empty_nxt       ;

    always_ff @( posedge clk or negedge rst_n ) begin
        if (!rst_n) begin
            for (integer i = 0 ; i < FIFO_DEPTH ; i++) begin
                mem[i] <= 'b0
            end
        end else if ( wr_en && ~empty) begin
            mem[wr_bin_addr[ADDR_WIDTH-1:0]] <= 'b0
        end
    end

//--============================--//
// write clk domain
//--============================--//
    assign wr_bin_addr_nxt =  (wr_en && ~full) ? wr_bin_addr + 1 : wr_bin_addr ;
    always_ff @( posedge clk or negedge rst_n ) begin : blockName
        if (!rst_n) begin
            wr_bin_addr <= 'b0;
        end else begin
            wr_bin_addr <= wr_bin_addr_nxt;
        end
    end

    assign wr_gray_addr_nxt = (wr_bin_addr_nxt>>1) ^ wr_bin_addr_nxt;
    always_ff @( posedge clk or negedge rst_n ) begin : blockName
        if (!rst_n) begin
            wr_gray_addr <= 'b0;
        end else begin
            wr_gray_addr <= wr_gray_addr_nxt;
        end
    end
//--============================--//
// read clk domain
//--============================--//
    assign rd_bin_addr_nxt =  (rd_en && ~empty) ? rd_bin_addr + 1 : rd_bin_addr ;
    always_ff @( posedge clk or negedge rst_n ) begin : blockName
        if (!rst_n) begin
            rd_bin_addr <= 'b0;
        end else begin
            rd_bin_addr <= rd_bin_addr_nxt;
        end
    end

    assign rd_gray_addr_nxt = (rd_bin_addr_nxt>>1) ^ rd_bin_addr_nxt;
    always_ff @( posedge clk or negedge rst_n ) begin : blockName
        if (!rst_n) begin
            rd_gray_addr <= 'b0;
        end else begin
            rd_gray_addr <= rd_gray_addr_nxt;
        end
    end
//--============================--//
// asyn to another clk domain
//--============================--//
    always_ff @( posedge clk or negedge rst_n ) begin : blockName
        if (!rst_n) begin
            wr_gray_addr_rd_asyn1 <= 'b0;
            wr_gray_addr_rd_asyn2 <= 'b0;
        end else begin
            wr_gray_addr_rd_asyn1 <= wr_gray_addr;
            wr_gray_addr_rd_asyn2 <= wr_gray_addr_rd_asyn1; 
        end      
    end

    always_ff @( posedge clk or negedge rst_n ) begin : blockName
        if (!rst_n) begin
            rd_gray_addr_wr_asyn1 <= 'b0;
            rd_gray_addr_wr_asyn2 <= 'b0;
        end else begin
            rd_gray_addr_wr_asyn1 <= rd_gray_addr;
            rd_gray_addr_wr_asyn2 <= rd_gray_addr_wr_asyn1;
        end       
    end
//--============================--//
//  generate the full & empty
//--============================--//
    assign full_nxt = (wr_gray_addr_nxt == {~rd_gray_addr_wr_asyn2[ADDR_WIDTH:ADDR_WIDTH-1],rd_gray_addr_wr_asyn2[ADDR_WIDTH-2:0]});
    always_ff @( posedge clk or negedge rst_n ) begin : blockName
        if (!rst_n) begin
            full <= 0;
        end else begin
            full <= full_nxt;
        end 
    end

    assign empty_nxt = (rd_gray_addr_nxt == {wr_gray_addr_rd_asyn2[ADDR_WIDTH:ADDR_WIDTH-1],wr_gray_addr_rd_asyn2[ADDR_WIDTH-2:0]}});
    always_ff @( posedge clk or negedge rst_n ) begin : blockName
        if (!rst_n) begin
            empty <= 0;
        end else begin
            empty <= empty_nxt;
        end
    end



endmodule