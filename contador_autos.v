module contador_autos(input wire entrada, input wire salida, input wire clk, input wire rst, output reg [2:0] autos);

    always@(posedge clk or posedge rst) begin
        if(reset) autos <= 3'b000;
        else begin
            case({entrada, salida})
                2'b10: if(autos < 3'b111) autos <= autos+1; //entrada
                2'b01: if(autos > 3'b000) autos <= autos-1; //salida
                default: autos <= autos; 
            endcase

        end
    end

endmodule