module fsm_estacionamiento (
    input wire clk,
    input wire reset,
    input wire [1:0] sensor,  // sensor = {a, b}
    output reg entrada,
    output reg salida
);
  localparam [1:0] IDLE = 2'b00, A_ON = 2'b10, AB_ON = 2'b11, B_ON = 2'b01;
  localparam [9:0] PATH_ENTRADA = {IDLE, A_ON, AB_ON, B_ON, IDLE};
  localparam [9:0] PATH_SALIDA = {IDLE, B_ON, AB_ON, A_ON, IDLE};

  //estados
  reg [1:0] state, next_state;
  reg [9:0] path;
  reg match_entrada, match_salida;

  //lógica combinacional de transición
  always @(*) begin
    next_state = state;  //valor por defecto

    case (state)
      IDLE: begin
        if (sensor == A_ON) next_state = A_ON;
        else if (sensor == B_ON) next_state = B_ON;
      end

      A_ON: begin
        if (sensor == AB_ON) next_state = AB_ON;
        else if (sensor == IDLE) next_state = IDLE;
      end

      AB_ON: begin
        if (sensor == B_ON) next_state = B_ON;  // secuencia de entrada
        else if (sensor == A_ON) next_state = A_ON;  // secuencia de salida
        else if (sensor == IDLE) next_state = IDLE;  //secuencia cancelada
      end

      B_ON: begin
        if (sensor == IDLE) next_state = IDLE;
        else if (sensor == AB_ON) next_state = AB_ON;
      end
      default: next_state = IDLE;
    endcase
  end

  //lógica combinacional de salidas (pulsos de 1 ciclo)
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      state = IDLE;
      path = 10'b0;
      entrada = 0;
      salida = 0;
    end else begin
      entrada = 0;
      salida = 0;
      path = {path[7:0], sensor};

      if (path == PATH_ENTRADA)  // Chequea la secuencia 00 -> 10 -> 11 -> 01 -> 00
        entrada = 1;
      else if (path == PATH_SALIDA)  // Chequea la secuencia 00 -> 01 -> 11 -> 10 -> 00
        salida = 1;
    end
  end
endmodule
