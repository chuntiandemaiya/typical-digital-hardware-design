module moduleName (
    input   clk,
    input   rst_n,
    output  clk_87 
);
    logic   cnt8_en;
    logic   cnt9_en;
    logic   cnt10_en;
    logic   clk_8;
    logic   clk_9;

    logic [2:0] cnt8;
    logic [3:0] cnt9;
    logic [3:0] cnt10;    
    
    assign  cnt10_en = (cnt8_en && cnt8==7) | (cnt9_en && cnt9==8);
    assign  cnt8_en = (cnt10 < 3);
    assign  cnt9_en = (cnt10 > 2);

    always_ff @( posedge clk or negedge rst_n ) begin
        if (!rst_n) begin
            cnt10 <= 'b0;
        end else if (cnt10_en && cnt10 != 9) begin
            cnt10 <= cnt10 + 1;
        end else if (cnt10_en && cnt10 == 9) begin
            cnt10 <= 0;
        end
    end

    always_ff @( posedge clk or negedge rst_n ) begin
        if (!rst_n) begin
            cnt8 <= 'b0;
        end else if (cnt8_en && cnt8 != 7) begin
            cnt8 <= cnt10 + 1;
        end else if (cnt8_en && cnt8 == 7) begin
            cnt8 <= 0;
        end
    end    

    always_ff @( posedge clk or negedge rst_n ) begin
        if (!rst_n) begin
            cnt9 <= 'b0;
        end else if (cnt9_en && cnt9 != 8) begin
            cnt9 <= cnt10 + 1;
        end else if (cnt9_en && cnt9 == 8) begin
            cnt9 <= 0;
        end
    end  

    always_ff @( posedge clk or negedge rst_n ) begin
        if (!rst_n) begin
            clk_8 <= 'b0;
        end else begin
            case (cnt8)
                3'b000: clk_8 <= 1;
                3'b100: clk_8 <= 0;
                default: clk_8 <= clk_8;
            endcase
        end
    end  

    always_ff @( posedge clk or negedge rst_n ) begin
        if (!rst_n) begin
            clk_9 <= 'b0;
        end else begin
            case (cnt9)
                3'b000: clk_9 <= 1;
                3'b100: clk_9 <= 0;
                default: clk_9 <= clk_9;
            endcase
        end
    end  

    assign clk_87 = clk_8 & clk_9;

endmodule