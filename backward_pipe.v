module backward_pipe #(
    parameter DATA_WIDTH = 8,
    parameter PIPE_EN    = 0
)(
    input                       clk,
    input                       rstn,

    input      [DATA_WIDTH-1:0] tdata_i,
    input                       tvalid_i,
    output reg                  tready_i,

    output     [DATA_WIDTH-1:0] tdata_o,
    output reg                  tvalid_o,
    input                       tready_o
);

generate
    if (PIPE_EN == 0) begin : pipe_byp  // Bypass mode
        assign tdata_o  = tdata_i;
        assign tvalid_o = tvalid_i;
        assign tready_i = tready_o;
    end
    else begin : pipe_imp  // Pipeline implementation
        reg                  tready_r;
        reg [DATA_WIDTH-1:0] tdata_r;

        always @(posedge clk or negedge rstn) begin
            if (!rstn) begin
                tready_r <= 1'b1;
                tdata_r  <= {DATA_WIDTH{1'b0}};
            end
            else begin
                if (tready_o) begin                 //Read while writing or only Read ,set buf empty
                    tready_r <= 1'b1;
                end
                else if (tvalid_i && tready_r) begin//Only Write ,set buf unempty，and register data
                    tready_r <= 1'b0;
                    tdata_r  <= tdata_i;
                end
            end
        end

        assign tdata_o  = tready_r ? tdata_i : tdata_r;
        assign tvalid_o = tready_r ? tvalid_i : 1'b1;
        assign tready_i = tready_r;
    end
endgenerate

endmodule