// parameter   AXI_PORT_NUM  = `CFG_AXI_PORT_NUM;
typedef enum logic [2:0] {
  SIG_NOCHANGE    = 3'b000,
  SIG_HIGHZ       = 3'b001,
  SIG_UNDEF       = 3'b010,
  SIG_DEASSERT    = 3'b011,
  SIG_ASSERT      = 3'b100,
  SIG_CLOCK       = 3'b101
} SIG_BEH;