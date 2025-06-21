`timescale 1ns / 1ps

module antirebote_tb;

    reg clk, rst;
    reg btn_in;
    wire btn_out;
    
    antirebote dut (
        .clk(clk),
        .rst(rst),
        .btn_in(btn_in),
        .btn_out(btn_out)
    );

    always #5 clk = ~clk;

    // Secuencia de prueba
    initial begin
        $display("Iniciando testbench antirebote...");
        clk = 0;
        rst = 1;
        btn_in = 0;

        // Reset sincronizado (2 ciclos)
        #20 rst = 0;

        // TEST1: Rebotes al activar (btn_in -> 1)
        $display("\nTest 1: Filtrado de rebote en subida");
        btn_in = 1;
        repeat (5) begin // Simular 5 rebotes rápidos
            #1000 btn_in = ~btn_in;
        end
        btn_in = 1; // Estado final estable
        
        // Esperar a que el contador supere el límite (50000 ciclos)
        #100000;
        
        @(posedge clk);
        if (btn_out == 1)
            $display("Éxito: btn_out = 1 (rebotes filtrados)");
        else
            $display("Error: btn_out no se activó");

        // TEST2: Rebotes al desactivar (btn_in -> 0)
        $display("\nTest 2: Filtrado de rebote en bajada");
        btn_in = 0;
        repeat (5) begin
            #1000 btn_in = ~btn_in;
        end
        btn_in = 0; // Estado final estable
        
        #100000;
        @(posedge clk);
        if (btn_out == 0)
            $display("Éxito: btn_out = 0 (rebotes filtrados)");
        else
            $display("Error: btn_out no se desactivó");

        #20 $display("Simulación completada");
        $finish;
    end

    // Generar archivo VCD para GTKWave
    initial begin
        $dumpfile("antirebote_wave.vcd");
        $dumpvars(0, antirebote_tb);
    end

endmodule
