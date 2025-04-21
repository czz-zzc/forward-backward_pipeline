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
        reg                  buf_full;
        reg [DATA_WIDTH-1:0] buf_data;

        always @(posedge clk or negedge rstn) begin
            if (!rstn) begin
                buf_full <= 1'b0;
                buf_data <= {DATA_WIDTH{1'b0}};
            end
            else begin
                if (tvalid_i && tready_i) begin//Read while writing or only write ,set buf full
                    buf_full <= 1'b1;
					buf_data <= tdata_i;
                end
                else if (tready_o) begin//Only Read,set buf empty
                    buf_full <= 1'b0;
                end
            end
        end

        assign tdata_o  = buf_data;
        assign tvalid_o = buf_full;
        assign tready_i = tready_o | (~buf_full);
    end
endgenerate

endmodule