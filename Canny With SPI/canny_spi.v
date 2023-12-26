module canny (
    input clk,
    input reset,
    input start,
    input [15:0] im11,
    input [15:0] im12,
    input [15:0] im13,
    input [15:0] im21,
    input [15:0] im22,
    input [15:0] im23,
    input [15:0] im31,
    input [15:0] im32,
    input [15:0] im33,
    output [15:0] dx_out,
    output dx_out_sign,
    output [15:0] dy_out,
    output dy_out_sign,
    output [15:0] dxy,
    output data_occur,
    input wire sclk,
    input wire mosi,
    output wire miso,
    input wire cs
);

reg [15:0] im11t, im12t,im13t, im21t, im22t, im23t, im31t, im32t, im33t; // ... (other temporary registers)
reg data_occur;

wire temp3x_sign;
wire [15:0] temp3y;
wire temp3y_sign;
wire [15:0] reg_add;

// SPI registers
reg [15:0] spi_tx_data;
reg [15:0] spi_rx_data;
reg spi_ready;
reg spi_active;

// SPI communication logic
always @(posedge clk) begin
    if (~reset) begin
        spi_ready <= 0;
        spi_active <= 0;
        spi_rx_data <= 16'b0;
    end else begin
        if (spi_ready) begin
            spi_rx_data <= miso;
        end
        // SPI ready and active logic
        spi_ready <= 1; // Set to 1 when ready to send/receive data
        spi_active <= 1; // Set to 1 during SPI communication
    end
end

always @(posedge clk) begin
   if(~reset)
 
begin 
    im11t<=16'd0;
    im21t<=16'd0;
    im31t<=16'd0;
    im12t<=16'd0;
    im22t<=16'd0;
    im32t<=16'd0;
    im13t<=16'd0;
    im23t<=16'd0;
    im33t<=16'd0;
    data_occur<=1'b0;
end

else if(start )
begin 

    im11t<=im11;
    im21t<=im21;
    im31t<=im31;
    im12t<=im12;
    im22t<=im22;
    im32t<=im32;
    im13t<=im13;
    im23t<=im23;
    im33t<=im33;
    data_occur<=1'b1;    
end

else
begin
    im11t<=16'd0;
    im21t<=16'd0;
    im31t<=16'd0;
    im12t<=16'd0;
    im22t<=16'd0;
    im32t<=16'd0;
    im13t<=16'd0;
    im23t<=16'd0;
    im33t<=16'd0;
    data_occur<=1'b0;
    
end
end

assign dy_out=temp3y;
assign dy_out_sign=temp3y_sign;
assign temp1y=(im31t+(im32t << 1)+ im33t);
assign temp2y=(im11t+(im12t << 1)+ im13t);
assign temp3y=(temp1y > temp2y)?{temp1y-temp2y}:
              (temp1y < temp2y)?{temp2y-temp1y}:{16'd0};
     
assign temp3y_sign=(temp1y > temp2y)?1'b1:1'b0;
              
assign reg_add=(data_occur)?(dx_out+dy_out):16'd0;
assign dxy=(data_occur && reg_add >= 16'd255)?16'd255:16'd0;

assign dx_out=temp3x;
assign dx_out_sign=temp3x_sign;

assign temp1x=(im11t+(im21t << 1)+ im31t);
assign temp2x=(im13t+(im23t << 1)+ im33t);

assign temp3x=(temp1x > temp2x)?{temp1x-temp2x}:
              (temp1x < temp2x)?{temp2x-temp1x}:{16'd0};
           
assign temp3x_sign=(temp1x > temp2x)?1'b1:1'b0;

endmodule
