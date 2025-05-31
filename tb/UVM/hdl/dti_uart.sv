module dti_uart #(
  parameter       APB_DATA_WIDTH      =     32                           ,
                  APB_ADDR_WIDTH      =     12                           ,
                  APB_STRB_WIDTH      =     4                            ,
                  DATA_SIZE           =     8                            ,
        
                  BAUDRATE            =     115200                       ,
                  FREQ_FPGA           =     50000000                     ,

                  BIT_COUNT_SIZE  = 4
  ) (
  input                        clk      ,
  input                        reset_n  ,

  input                        pclk     ,    // Clock
  input                        presetn  ,    // Asynchronous reset active low
  input                        psel     ,
  input                        penable  ,
  input                        pwrite   ,
  input   [APB_STRB_WIDTH-1:0] pstrb    ,
  input   [APB_ADDR_WIDTH-1:0] paddr    ,
  input   [APB_DATA_WIDTH-1:0] pwdata   ,

  output                       pready   ,
  output                       pslverr  ,
  output  [APB_DATA_WIDTH-1:0] prdata   ,

  input                        rx       ,
  output                       tx       ,
  input                        cts_n    ,
  output                       rts_n
);

logic [DATA_SIZE-1:0] tx_data;
logic [DATA_SIZE-1:0] rx_data;
logic [1:0]           data_bit_num;
logic                 stop_bit_num;
logic                 parity_en;
logic                 parity_type;
logic                 start_tx;
logic                 tx_done;
logic                 rx_done;
logic                 parity_error;

logic clk_tx;
logic clk_rx;

uart_generator_clock #(BAUDRATE, FREQ_FPGA)
uart_generator_clock (
  .clk       (clk       ),
  .reset_n   (reset_n   ),
  .clk_tx    (clk_tx    ),
  .clk_rx    (clk_rx    )
  );

APB_Slave_Register #(APB_DATA_WIDTH, APB_ADDR_WIDTH, APB_STRB_WIDTH, DATA_SIZE)
APB_Slave_Register(
  .clk              (clk            ),
  .reset_n          (reset_n        ),

  .pclk             (clk            ),
  .presetn          (reset_n        ),
  .psel             (psel           ),
  .penable          (penable        ),
  .pwrite           (pwrite         ),
  .pstrb            (pstrb          ),
  .paddr            (paddr          ),
  .pwdata           (pwdata         ),

  .pready           (pready         ),
  .pslverr          (pslverr        ),
  .prdata           (prdata         ),

  .tx_data          (tx_data        ),
  .rx_data          (rx_data        ),
  .data_bit_num     (data_bit_num   ),
  .stop_bit_num     (stop_bit_num   ),
  .parity_en        (parity_en      ),
  .parity_type      (parity_type    ),
  .start_tx         (start_tx       ),
  .tx_done          (tx_done        ),
  .rx_done          (rx_done        ),
  .parity_error     (parity_error   ),
  .clk_tx           (clk_tx         )
);





uart_transmitter #(DATA_SIZE, BIT_COUNT_SIZE)
uart_transmitter(
  .clk            (clk            ),
  .clk_tx         (clk_tx         ),
  .reset_n        (reset_n        ),
  .start_tx       (start_tx       ),
  .tx_data        (tx_data        ),
  .cts_n          (cts_n          ),

  .data_bit_num   (data_bit_num   ),
  .stop_bit_num   (stop_bit_num   ),
  .parity_en      (parity_en      ),
  .parity_type    (parity_type    ),

  .tx             (tx             ),
  .tx_done        (tx_done        )
  );



uart_receiver #(DATA_SIZE, BIT_COUNT_SIZE)
uart_receiver(
  .clk           (clk           ),
  .clk_rx        (clk_rx        ),
  .reset_n       (reset_n       ),
  .rx            (rx            ),
  .rts_n         (rts_n         ),

  .data_bit_num  (data_bit_num  ),
  .stop_bit_num  (stop_bit_num  ),
  .parity_en     (parity_en     ),
  .parity_type   (parity_type   ),

  .rx_data       (rx_data       ),
  .rx_done       (rx_done       ),
  .parity_error  (parity_error  )
  );


endmodule : dti_uart