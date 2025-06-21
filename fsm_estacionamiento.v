module fsm_estacionamiento (
    input wire clk,
    input wire rst,
    input wire [1:0] sensor,   // sensor = {a, b}
    output reg entrada,
    output reg salida
);

    //estados
    reg [2:0] state, next_state;

    localparam IDLE      = 3'b000,
               A_BLOCK   = 3'b001,
               AB_BLOCK  = 3'b010,
               B_BLOCK   = 3'b011,
               CHECK     = 3'b100;

    reg flag_in;  // 1 -> entrada, 0 -> salida

    //lógica secuencial
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            flag_in <= 0;
        end
        else begin
            state <= next_state;
            //actualizar flag_in solo en IDLE para evitar sobreescrituras
            if (state == IDLE) begin
                if (sensor == 2'b10) //a bloqueado primero
                    flag_in <= 1;
                else if (sensor == 2'b01) //b bloqueado primero
                    flag_in <= 0;
            end
        end
    end

    //lógica combinacional de transición
    always @(*) begin
        next_state = state; //valor por defecto
        case (state)
            IDLE: begin
                if (sensor == 2'b10)
                    next_state = A_BLOCK;
                else if (sensor == 2'b01)
                    next_state = B_BLOCK;
            end

            A_BLOCK: begin
                if (sensor == 2'b11)
                    next_state = AB_BLOCK;
                else if (sensor == 2'b00)
                    next_state = IDLE; //secuencia cancelada
            end

            AB_BLOCK: begin
                if (sensor == 2'b01)       // B activo -> continuar secuencia de SALIDA
                    next_state = B_BLOCK;
                else if (sensor == 2'b10)  // A activo -> posible secuencia de ENTRADA (cancelar salida)
                    next_state = A_BLOCK;
                else if (sensor == 2'b00)  // Ningún sensor activo -> secuencia cancelada
                    next_state = IDLE;
                else                       // Mantener estado si sensor == 2'b11
                    next_state = AB_BLOCK;
            end

            B_BLOCK: begin
                if (sensor == 2'b00)
                    next_state = CHECK;
                else if (sensor == 2'b11)
                    next_state = IDLE; //secuencia inválida
            end

            CHECK: begin
                next_state = IDLE; //siempre regresa a IDLE
            end

            default: next_state = IDLE;
        endcase
    end

    //lógica combinacional de salidas (pulsos de 1 ciclo)
    always @(*) begin
        entrada = 0;
        salida = 0;
        if (state == CHECK) begin
            entrada = flag_in;
            salida = !flag_in;
        end
    end

endmodule
