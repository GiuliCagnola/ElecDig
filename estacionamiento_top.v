module estacionamiento_top(input wire btn_A, input wire btn_B, input wire clk, input wire rst, output wire [3:0] leds)

    //salidas de los filtros antirebote
    wire btn_A_clean, btn_B_clean;

    //salidas de la fsm
    wire entrada, salida;

    //contador de autos
    wire [2:0] autos;

    //antirebote para el sensor A
    antirebote antirebote_A(.clk(clk),
                            .rst(rst),
                            .btn_in(btn_A),
                            .btn_out(btn_A_clean));

      //antirebote para el sensor B
    antirebote antirebote_B(.clk(clk),
                            .rst(rst),
                            .btn_in(btn_B),
                            .btn_out(btn_B_clean));

    //sensor {A,B}
    wire [1:0] sensor;
    assign sensor = {btn_A_clean, btn_B_clean};

    //fsm de detección de secuencias
    fsm_estacionamiento fsm(.clk(clk),
                            .rst(rst),
                            .sensor(sensor),
                            .entrada(entrada),
                            .salida(salida));
    
    //contador de autos
    contador_autos contador(.entrada(entrada),
                            .salida(salida),
                            .clk(clk),
                            .rst(rst),
                            .autos(autos));
    
    //visualizar los leds
    assign leds = {1'b0, autos}; //led3 apagado, led2-0 autos

endmodule