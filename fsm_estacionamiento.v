module fsm_estacionamiento (
    input wire clk,
    input wire reset,
    input wire [1:0] sensor,   // sensor = {a, b}
    output reg entrada,
    output reg salida
);

    // Estados
    reg [2:0] state, next_state;

    localparam IDLE      = 3'b000,
               A_BLOCK   = 3'b001,
               AB_BLOCK  = 3'b010,
               B_BLOCK   = 3'b011,
               CHECK     = 3'b100;

    reg flag_in;  // 1 si esperamos entrada, 0 si salida

    // Lógica secuencial
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= IDLE;
        else
            state <= next_state;
    end

    // Lógica secuencial para flag_in
    always @(posedge clk or posedge reset) begin
        if (reset)
            flag_in <= 0;
        else if (state == IDLE) begin
            if (sensor == 2'b10)      // a bloqueado primero
                flag_in <= 1;
            else if (sensor == 2'b01) // b bloqueado primero
                flag_in <= 0;
        end
    end

    // Lógica combinacional de transición y salidas
    always @(*) begin
        entrada = 0;
        salida  = 0;
        next_state = state; // valor por defecto

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
                else if (sensor == 2'b10)
                    next_state = A_BLOCK;
                else
                    next_state = IDLE; // secuencia inválida
            end

            AB_BLOCK: begin
                if (sensor == 2'b01)
                    next_state = B_BLOCK;
                else if (sensor == 2'b10)
                    next_state = A_BLOCK;
                else
                    next_state = AB_BLOCK;
            end

            B_BLOCK: begin
                if (sensor == 2'b00)
                    next_state = CHECK;
                else
                    next_state = B_BLOCK;
            end

            CHECK: begin
                if (flag_in)
                    entrada = 1;
                else
                    salida = 1;
                next_state = IDLE;
            end

            default: next_state = IDLE;
        endcase
    end

endmodule
