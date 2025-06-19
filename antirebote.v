module antirebote(input wire clk, input wire rst, input wire btn_in, output reg btn:out);

    //btn_in -> entrada inestable
    //btn_out -> salida estable

    reg[15:0] contador;
    reg btn_sync;

    parameter limite=50000; //ajuste según frecuencia del reloj 

    always@(posedge clk or posedge rst) begin
        if(rst) begin
            contador <= 0;
            btn_sync <= 0;
            btn_out <= 0;
        end
        else begin
            if(btn_in == btn_sync) begin
                //mismo valor -> incrementa el contador
                contador <= contador+1;
            else
                btn_out <= btn_sync;
            end
            else begin
                //cambió el valor -> reiniciar el contador
                contador <= 0;
                btn_sync <= btn_in;
            end
        end
    end
endmodule 