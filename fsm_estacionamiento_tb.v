`timescale 1ns / 1ps

module fsm_tb;

    reg clk, reset;
    reg [1:0] sensor;
    wire entrada, salida;

    fsm_estacionamiento dut (
        .clk(clk),
        .reset(reset),
        .sensor(sensor),
        .entrada(entrada),
        .salida(salida)
    );

    //reloj de 10 ns
    always #5 clk = ~clk;

    initial begin
        $display("Iniciando testbench FSM...");
        clk = 0;
        reset = 1;
        sensor = 2'b00;

        //reset sincronizado (activo por 2 ciclos de reloj)
        #20 reset = 0;

        //TEST1 -> Secuencia de entrada (a -> ab -> b -> 00)
        $display("\nTest 1: Secuencia de entrada");
        #10 sensor = 2'b10; // A_BLOCK
        #10 sensor = 2'b11; // AB_BLOCK
        #10 sensor = 2'b01; // B_BLOCK
        #10 sensor = 2'b00; // CHECK

        //verificar entrada en el próximo flanco de reloj
        @(posedge clk); 
        if (entrada) 
            $display("Éxito: Entrada detectada correctamente");
        else 
            $display("Error: Entrada no detectada");

        // TEST2 -> Secuencia de salida (b -> ab -> a -> 00)
        $display("\nTest 2: Secuencia de salida");
        #10 sensor = 2'b01; // B_BLOCK
        #10 sensor = 2'b11; // AB_BLOCK
        #10 sensor = 2'b10; // A_BLOCK
        #10 sensor = 2'b00; // CHECK

        //TEST3: Secuencia de salida interrumpida por entrada (B -> AB -> A)
        $display("\nTest 3: Salida interrumpida por entrada");
        #10 sensor = 2'b01; // B_BLOCK
        #10 sensor = 2'b11; // AB_BLOCK
        #10 sensor = 2'b10; // A_BLOCK (¡nuevo auto entrando!)
        #10 sensor = 2'b00; // CHECK (debe activar 'entrada')
        @(posedge clk);
        if (entrada)
            $display("Éxito: Secuencia de entrada priorizada");
        else
            $display("Error: No se detectó entrada");

        //verificar salida en el próximo flanco de reloj
        @(posedge clk);
        if (salida) 
            $display("Éxito: Salida detectada correctamente");
        else 
            $display("Error: Salida no detectada");

        #20 $finish;
    end

    // Generar archivo VCD para GTKWave
    initial begin
        $dumpfile("fsm_wave.vcd");
        $dumpvars(0, fsm_tb);
    end

endmodule
