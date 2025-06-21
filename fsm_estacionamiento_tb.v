`timescale 1ns/1ps

module fsm_estacionamiento_tb;

    parameter CLK_PERIOD = 10; // 100 MHz

    reg clk;
    reg reset;
    reg [1:0] sensor;
    wire entrada;
    wire salida;

    fsm_estacionamiento dut (
        .clk(clk),
        .reset(reset),
        .sensor(sensor),
        .entrada(entrada),
        .salida(salida)
    );

    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        $dumpfile("fsm_wave.vcd");
        $dumpvars(0, fsm_estacionamiento_tb);
        
        reset = 1;
        sensor = 2'b00; // IDLE
        #20;
        
        //TEST1: Secuencia de entrada completa
        $display("\nTest 1: Secuencia ENTRADA (00->10->11->01->00)");
        reset = 0;
        #10 sensor = 2'b10; // A_ON
        #10 sensor = 2'b11; // AB_ON
        #10 sensor = 2'b01; // B_ON
        #10 sensor = 2'b00; // IDLE (debe activar entrada)
        
        #5;
        if (entrada) 
            $display("Éxito: entrada=1 detectado");
        else
            $display("Error: entrada no se activó");
        #5;

        // TEST2: Secuencia de salida completa
        $display("\nTest 2: Secuencia SALIDA (00->01->11->10->00)");
        #10 sensor = 2'b01; // B_ON
        #10 sensor = 2'b11; // AB_ON
        #10 sensor = 2'b10; // A_ON
        #10 sensor = 2'b00; // IDLE (debe activar salida)
        
        #5;
        if (salida)
            $display("Éxito: salida=1 detectado");
        else
            $display("Error: salida no se activó");
        #5;

        // TEST3: Secuencia interrumpida
        $display("\nTest 3: Secuencia interrumpida (00->10->00)");
        #10 sensor = 2'b10; // A_ON
        #10 sensor = 2'b00; // IDLE
        
        #5;
        if (!entrada && !salida)
            $display("Éxito: No hay activación con secuencia incompleta");
        else
            $display("Error: Activación incorrecta");
        #5;

        // TEST4: Secuencia inválida
        $display("\nTest 4: Secuencia inválida (00->10->01->11->00)");
        #10 sensor = 2'b10; // A_ON
        #10 sensor = 2'b01; // Transición inválida
        #10 sensor = 2'b11; // AB_ON
        #10 sensor = 2'b00; // IDLE
        
        #5;
        if (!entrada && !salida)
            $display("Éxito: No hay activación con secuencia inválida");
        else
            $display("Error: Activación incorrecta");
        #5;

        #100;
        $display("\nSimulación completada");
        $finish;
    end

endmodule
