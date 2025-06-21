module antirebote (
    input wire clk,
    input wire rst,
    input wire btn_in, //entrada inestable
    output reg btn_out //salida filtrada
);

    reg [15:0] contador;
    reg btn_sync;
    parameter limite = 50000; // Para 100 MHz = 0.5 ms de filtrado

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            contador <= 0;
            btn_sync <= 0;
            btn_out <= 0;
        end
        else begin
            //sincronización
            btn_sync <= btn_in;
            
            //debounce
            if (btn_sync != btn_out) begin
                if (contador >= limite) begin
                    btn_out <= btn_sync; //actualizar salida
                    contador <= 0;       //reiniciar contador
                end
                else begin
                    contador <= contador + 1; //incrementar contador
                end
            end
            else begin
                contador <= 0; //resetear 
            end
        end
    end
endmodule
