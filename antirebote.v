module antirebote (
    input wire clk,
    input wire rst,
    input wire btn_in, //entrada inestable
    output reg btn_out //salida filtrada
);

    reg [15:0] contador;
    reg btn_sync;
    parameter limite = 50000; //ajustar según frecuencia del reloj

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            contador <= 0;
            btn_sync <= 0;
            btn_out <= 0;
        end
        else begin
            //sincronizar la entrada
            btn_sync <= btn_in;

            //debounce
            if (btn_sync == btn_out) begin
                contador <= 0; //resetear si no hay cambio
            end
            else begin
                contador <= contador + 1;
                if (contador >= limite) begin
                    btn_out <= btn_sync; //actualizar si supera el límite
                    contador <= 0;
                end
            end
        end
    end

endmodule
