`timescale 1ns / 1ps

module antirebote_tb;

    parameter CLK_PERIOD = 10;   
    parameter DEBOUNCE_LIMIT = 50000; 
    parameter DEBOUNCE_TIME = (DEBOUNCE_LIMIT * CLK_PERIOD) / 1000; 
    
    reg clk, rst;
    reg btn_in;
    wire btn_out;
    
    antirebote dut (
        .clk(clk),
        .rst(rst),
        .btn_in(btn_in),
        .btn_out(btn_out)
    );

    always #(CLK_PERIOD/2) clk = ~clk;

    // Tarea para simular rebotes
    task rebotar;
        input estado_final;
        integer i;
        begin
            for (i = 0; i < 5; i = i + 1) begin
                #1000 btn_in = ~btn_in; // Rebotes cada 1 us
            end
            btn_in = estado_final; // Estado final estable
        end
    endtask

    // Secuencia de prueba
    initial begin
        $display("\nIniciando testbench antirebote...");
        $display("Tiempo de debounce configurado: %0d ns", DEBOUNCE_TIME);
        $dumpfile("antirebote_wave.vcd");
        $dumpvars(0, antirebote_tb);

        // Inicialización
        clk = 0;
        rst = 1;
        btn_in = 0;

        // TEST 0: Comportamiento durante reset
        $display("\n[TEST 0] Comportamiento durante reset");
        #5 btn_in = 1; // Intentar activar durante reset
        #15;
        if (btn_out !== 0)
            $display(" Error: btn_out debería ser 0 durante reset");
        else
            $display(" Éxito: btn_out = 0 durante reset");
        
        // Liberar reset
        #5 rst = 0;

        // TEST 1: Rebotes en activación (0 -> 1)
        $display("\n[TEST 1] Rebotes en activación");
        btn_in = 1;
        rebotar(1); // Rebotes terminando en 1
        
        // Esperar tiempo de debounce + margen
        #(DEBOUNCE_TIME + 1000);
        
        if (btn_out === 1)
            $display(" Éxito: btn_out = 1 (rebotes filtrados)");
        else
            $display(" Error: btn_out no se activó");

        // TEST 2: Rebotes en desactivación (1 -> 0)
        $display("\n[TEST 2] Rebotes en desactivación");
        btn_in = 0;
        rebotar(0); // Rebotes terminando en 0
        
        #(DEBOUNCE_TIME + 1000);
        
        if (btn_out === 0)
            $display(" Éxito: btn_out = 0 (rebotes filtrados)");
        else
            $display(" Error: btn_out no se desactivó");

        // TEST 3: Rebotes prolongados
        $display("\n[TEST 3] Rebotes que exceden tiempo de debounce");
        btn_in = 1;
        repeat(15) #1000 btn_in = ~btn_in; // Rebotes por 15 us
        btn_in = 1;
        
        #(DEBOUNCE_TIME/2);
        if (btn_out !== 0)
            $display(" Éxito: btn_out sigue 0 durante rebotes prolongados");
        else
            $display(" Error: btn_out no mantuvo 0 durante rebotes");
        
        #(DEBOUNCE_TIME);
        if (btn_out === 1)
            $display(" Éxito: btn_out = 1 tras rebotes prolongados");
        else
            $display(" Error: btn_out no se activó tras rebotes");

        // Finalizar
        #100 $display("\nSimulación completada");
        $finish;
    end

endmodule
