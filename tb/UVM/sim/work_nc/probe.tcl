database -open WAVE_TEST_NORMAL -shm -default -event
probe -create apb_uart_top -depth all -all -shm -database WAVE_TEST_NORMAL
run
exit

