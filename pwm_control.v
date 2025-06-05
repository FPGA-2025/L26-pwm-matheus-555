module PWM_Control #(
    parameter CLK_FREQ = 25_000_000,
    parameter PWM_FREQ = 1_250
) (
    input  wire clk,
    input  wire rst_n,
    output wire [7:0] leds
);
    localparam [15:0] PWM_CLK_PERIOD = CLK_FREQ / PWM_FREQ;
    localparam integer PWM_DUTY_CYCLE = 50; // 0.0025% duty cycle

    localparam integer PWM_DUTY_CYCLE_MIN = PWM_CLK_PERIOD * (25/1_000_000);
    localparam integer PWM_DUTY_CYCLE_MAX = PWM_CLK_PERIOD * (70/100);

    localparam SECOND         = CLK_FREQ;
    localparam HALF_SECOND    = SECOND / 2;
    localparam QUARTER_SECOND = SECOND / 4;
    localparam EIGHTH_SECOND  = SECOND / 8;

    reg [15:0] duty;
    reg [15:0] fade;
    reg direction;
    wire pwm_out;

    PWM dut (
        .clk(clk),
        .rst_n(rst_n),
        .duty_cycle(duty),
        .period(PWM_CLK_PERIOD),
        .pwm_out(pwm_out)
    );

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            duty      <= PWM_DUTY_CYCLE_MIN;
            fade      <= 16'b0;
            direction <= 1'b0;
        end else begin
            if (direction) begin
                if (duty < PWM_DUTY_CYCLE_MAX)
                    duty <= duty+1;
                else
                    direction <= 0;
            end else begin
                if (duty > PWM_DUTY_CYCLE_MIN)
                    duty <= duty-1;
                else
                    direction <= 1;
            end

            fade <= (fade == PWM_CLK_PERIOD-1) ? 0 : fade+1;
        end
    end


    assign leds = {8{pwm_out}};
endmodule