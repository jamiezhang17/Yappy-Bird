onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label CLOCK_50 -radix binary /testbench/CLOCK_50
add wave -noupdate -label resetn -radix binary /testbench/resetn
add wave -noupdate -label audio_in_available -radix binary /testbench/audio_in_available
add wave -noupdate -label audio_sample -radix binary /testbench/audio_sample
add wave -noupdate -label led -radix binary /testbench/led
add wave -noupdate -divider mic_detector
add wave -noupdate -label audio_magnitude -radix binary /testbench/U1/audio_magnitude
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {10000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 80
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {120 ns}
