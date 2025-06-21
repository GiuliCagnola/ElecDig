`timescale 1ns / 1ps

module fsm_tb;

    reg clk, rst;
    reg [1:0] sensor;
    wire entrada, salida;

    reg detecto_entrada, detecto_salida;

    fsm_estacionamiento dut (
        .clk(clk),
        .rst(rst),
        .sensor(sensor),
        .entrada(entrada),
        .salida(salida)
    );

    always #5 clk = ~clk;

    // Inicialización y pruebas
    initial begin
        $display("Iniciando testbench FSM...");
        clk = 0;
        rst = 1;
        sensor = 2'b00;
        detecto_entrada = 0;
        detecto_salida  = 0;

        // Archivo de salida para GTKWave
        $dumpfile("fsm_wave.vcd");
        $dumpvars(0, fsm_tb);

        // Reset sincronizado
        @(posedge clk); rst = 0;

        // TEST 1: Secuencia de entrada
        $display("\nTest 1: Secuencia de entrada");
        @(posedge clk); sensor = 2'b10; // A_BLOCK
        @(posedge clk); sensor = 2'b11; // AB_BLOCK
        @(posedge clk); sensor = 2'b01; // B_BLOCK
        @(posedge clk); sensor = 2'b00; // CHECK

        // Esperar algunos ciclos para captura
        repeat(2) @(posedge clk);

        if (detecto_entrada)
            $display("Entrada detectada correctamente");
        else
            $display("Entrada no detectada");

        detecto_entrada = 0;
        sensor = 2'b00;

        // TEST 2: Secuencia de salida
        $display("\nTest 2: Secuencia de salida");
        @(posedge clk); sensor = 2'b01; // B_BLOCK
        @(posedge clk); sensor = 2'b11; // AB_BLOCK
        @(posedge clk); sensor = 2'b10; // A_BLOCK
        @(posedge clk); sensor = 2'b00; // CHECK

        repeat(2) @(posedge clk);

        if (detecto_salida)
            $display("Salida detectada correctamente");
        else
            $display("Salida no detectada");

        detecto_salida = 0;
        sensor = 2'b00;

        // TEST 3: Secuencia interrumpida
        $display("\nTest 3: Salida interrumpida por nueva entrada");
        @(posedge clk); sensor = 2'b01; // B_BLOCK
        @(posedge clk); sensor = 2'b11; // AB_BLOCK
        @(posedge clk); sensor = 2'b10; // vuelve A_BLOCK
        @(posedge clk); sensor = 2'b00; // CHECK

        repeat(2) @(posedge clk);

        if (detecto_entrada)
            $display("Entrada detectada tras interrupción.");
        else
            $display("Entrada no detectada tras interrupción.");

        @(posedge clk);
        $finish;
    end

    // Detección de señales de salida (pulsos de 1 ciclo)
    always @(posedge clk) begin
        if (entrada) detecto_entrada = 1;
        if (salida)  detecto_salida = 1;
    end

endmodule
