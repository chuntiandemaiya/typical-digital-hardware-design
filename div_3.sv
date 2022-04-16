module div_3 (
    input   clk,
    input   rst_n,
    output  clk_out
);
    logic   [1:0]   cnt;
    logic           posedge_en;
    logic           negedge_en;
    logic           n_clk;
    logic           clk_1;
    logic           clk_2;

    assign n_clk = ~clk;

    always_ff @( posedge clk or negedge rst_n ) begin
        if (!rst_n) begin
            cnt <= 0;
        end else if (cnt != 2) begin
            cnt <= cnt + 1;
        end else if (cnt == 2) begin
            cnt <= 0;
        end
    end

    assign posedge_en = (cnt == 0);
    assign negedge_en = (cnt == 2);


    always_ff @( posedge clk or negedge rst_n ) begin : blockName
        if (!rst_n) begin
            clk_1 <= 0;
        end else if (posedge_en) begin
            clk_1 <= ~clk_1;
        end
    end

    always_ff @( posedge n_clk or negedge rst_n ) begin : blockName
        if (!rst_n) begin
            clk_2 <= 0;
        end else if (negedge_en) begin
            clk_2 <= ~clk_2;
        end
    end

    assign clk_out = clk_1 ^ clk_2;

endmodule