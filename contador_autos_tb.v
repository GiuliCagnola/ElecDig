`timescale 1ns / 1ps

module contador_tb;

    reg clk, rst;
    reg entrada, salida;
    wire [2:0] autos;
    
    contador_autos dut (.entrada(entrada),
                        .salida(salida),
                        .clk(clk),
                        .rst(rst),
                        .autos(autos));

    always #5 clk = ~clk;
    // Secuencia de prueba
    initial begin
        // Inicializar señales
        clk = 0;
        rst = 1;
        entrada = 0;
        salida = 0;
        
        $display("Iniciando simulación...");
        
        // Reset inicial (2 ciclos)
        #20 rst = 0;
        
        // TEST1: Contar 3 autos entrando
        $display("\nTest 1: Incrementar contador");
        repeat (3) begin
            #10 entrada = 1; 
            #10 entrada = 0;
            $display("Autos = %d", autos);
        end
        
        // TEST2: Sacar 2 autos
        $display("\nTest 2: Decrementar contador");
        repeat (2) begin
            #10 salida = 1;
            #10 salida = 0;
            $display("Autos = %d", autos);
        end
        
        // TEST3: Intentar sacar con contador en 0
        $display("\nTest 3: Protección bajo cero");
        #10 salida = 1;
        #10 salida = 0;
        if (autos == 0)
            $display("Éxito: Contador no bajó de 0");
        else
            $display("Error: Contador bajo de 0");
        
        // TEST4: Llenar estacionamiento (hasta 7)
        $display("\nTest 4: Llenar estacionamiento");
        repeat (4) begin  // Ya hay 1 auto
            #10 entrada = 1;
            #10 entrada = 0;
        end
        repeat (2) begin  // Llegar a 7
            #10 entrada = 1;
            #10 entrada = 0;
        end
        
        // TEST5: Intentar entrar con contador lleno
        $display("\nTest 5: Protección sobre 7");
        #10 entrada = 1;
        #10 entrada = 0;
        if (autos == 3'b111)
            $display("Éxito: Contador no pasó de 7");
        else
            $display("Error: Contador sobrepasó 7");
        
        #20 $display("Simulación completada");
        $finish;
    end

    // Generar archivo VCD para visualización
    initial begin
        $dumpfile("contador_wave.vcd");
        $dumpvars(0, contador_tb);
    end

endmodule
