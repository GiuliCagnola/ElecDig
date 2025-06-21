`timescale 1ns/1ps

module estacionamiento_top_tb;

    reg clk, rst;
    reg btn_A, btn_B;
    wire [3:0] leds;
    

    estacionamiento_top dut (
        .btn_A(btn_A),
        .btn_B(btn_B),
        .clk(clk),
        .rst(rst),
        .leds(leds)
    );

    // Generador de reloj
    always #5 clk = ~clk;

    // Secuencia de prueba
    initial begin
        $display("Iniciando testbench del sistema completo...");
        $dumpfile("sistema.vcd");
        $dumpvars(0, estacionamiento_top_tb);

        // Inicialización
        clk = 0;
        rst = 1;
        btn_A = 0;
        btn_B = 0;

        // Reset sincronizado (2 ciclos)
        #20 rst = 0;

        // TEST1: Secuencia de entrada (A -> B)
        $display("\nTest 1: Auto entrando (A -> B)");
        #10 btn_A = 1; btn_B = 0;  // A_BLOCK
        #100000 btn_A = 1; btn_B = 1;  // AB_BLOCK
        #100000 btn_A = 0; btn_B = 1;  // B_BLOCK
        #100000 btn_A = 0; btn_B = 0;  // CHECK -> entrada = 1
        
        // Verificar contador (debe ser 1)
        #10;
        if (leds[2:0] == 3'b001)
            $display("Éxito: 1 auto contado (leds = %b)", leds);
        else
            $display("Error: Conteo incorrecto (leds = %b)", leds);

        // TEST2: Secuencia de salida (B -> A)
        $display("\nTest 2: Auto saliendo (B -> A)");
        #10 btn_A = 0; btn_B = 1;  // B_BLOCK
        #100000 btn_A = 1; btn_B = 1;  // AB_BLOCK
        #100000 btn_A = 1; btn_B = 0;  // A_BLOCK
        #100000 btn_A = 0; btn_B = 0;  // CHECK -> salida = 1
        
        // Verificar contador (debe ser 0)
        #10;
        if (leds[2:0] == 3'b000)
            $display("Éxito: 0 autos (leds = %b)", leds);
        else
            $display("Error: Conteo incorrecto (leds = %b)", leds);

        // Finalizar
        #20 $display("Simulación completada");
        $finish;
    end

endmodule