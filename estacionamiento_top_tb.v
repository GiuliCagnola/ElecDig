`timescale 1ns/1ps

module estacionamiento_top_tb;

    parameter DEBOUNCE_TIME = 100000; 
    parameter CLK_PERIOD = 10;      

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

    always #(CLK_PERIOD/2) clk = ~clk;

    // Tarea para secuencia de entrada
    task secuencia_entrada;
        begin
            btn_A = 1; btn_B = 0;  // A_BLOCK
            #DEBOUNCE_TIME;
            btn_A = 1; btn_B = 1;  // AB_BLOCK
            #DEBOUNCE_TIME;
            btn_A = 0; btn_B = 1;  // B_BLOCK
            #DEBOUNCE_TIME;
            btn_A = 0; btn_B = 0;  // CHECK
        end
    endtask

    // Tarea para secuencia de salida
    task secuencia_salida;
        begin
            btn_B = 1; btn_A = 0;  // B_BLOCK
            #DEBOUNCE_TIME;
            btn_B = 1; btn_A = 1;  // AB_BLOCK
            #DEBOUNCE_TIME;
            btn_B = 0; btn_A = 1;  // A_BLOCK
            #DEBOUNCE_TIME;
            btn_B = 0; btn_A = 0;  // CHECK
        end
    endtask

    // Secuencia de prueba
    initial begin
        $display("\nIniciando testbench del sistema completo...");
        $dumpfile("sistema.vcd");
        $dumpvars(0, estacionamiento_top_tb);

        // Inicialización
        clk = 0;
        rst = 1;
        btn_A = 0;
        btn_B = 0;

        // Reset inicial (2 ciclos)
        #20 rst = 0;

        // TEST 1: Secuencia de entrada válida
        $display("\n[TEST 1] Secuencia de entrada válida");
        secuencia_entrada;
        #10;
        if (leds[2:0] == 3'b001)
            $display(" Éxito: Contador = 1 (leds = %b)", leds);
        else
            $display(" Error: Contador debería ser 1 (leds = %b)", leds);

        // TEST 2: Secuencia de salida válida
        $display("\n[TEST 2] Secuencia de salida válida");
        secuencia_salida;
        #10;
        if (leds[2:0] == 3'b000)
            $display(" Éxito: Contador = 0 (leds = %b)", leds);
        else
            $display(" Error: Contador debería ser 0 (leds = %b)", leds);

        // TEST 3: Llenar estacionamiento
        $display("\n[TEST 3] Llenar estacionamiento (7 autos)");
        repeat(7) begin
            secuencia_entrada;
            #10;
            $display(" Autos actuales: %d (leds = %b)", leds[2:0], leds);
        end
        
        // Verificar lleno
        if (leds == 4'b1111)
            $display(" Éxito: Estacionamiento lleno (leds = %b)", leds);
        else
            $display(" Error: Debería estar lleno (leds = %b)", leds);

        // TEST 4: Secuencia inválida
        $display("\n[TEST 4] Secuencia inválida (A->B->A)");
        #10 btn_A = 1; btn_B = 0;  // A
        #DEBOUNCE_TIME btn_A = 0; btn_B = 1;  // B (inválido)
        #DEBOUNCE_TIME btn_A = 1; btn_B = 0;  // A
        #DEBOUNCE_TIME btn_A = 0; btn_B = 0;  // IDLE
        
        #10;
        if (leds == 4'b1111)
            $display(" Éxito: Contador no cambió (leds = %b)", leds);
        else
            $display(" Error: Contador no debería cambiar (leds = %b)", leds);

        // TEST 5: Reset asíncrono
        $display("\n[TEST 5] Reset durante operación");
        #10 btn_A = 1; btn_B = 0;  // Iniciar secuencia
        #50000 rst = 1;             // Reset en medio
        #20 rst = 0;
        #10;
        if (leds == 4'b0000)
            $display(" Éxito: Reset funcionó (leds = %b)", leds);
        else
            $display(" Error: Reset falló (leds = %b)", leds);

        // Finalizar
        #100 $display("\nSimulación completada");
        $finish;
    end
endmodule`timescale 1ns/1ps

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
