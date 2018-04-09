#!/bin/tclsh

proc sim { tb } {
    set_property top_lib xil_defaultlib [ get_filesets sim_1 ]
    set_property top $tb [ get_filesets sim_1 ]
    launch_simulation
}

proc pgm { bit } {
    set dev [ get_hw_devices "xc7z020_1" ]
    set_property PROGRAM.FILE $bit $dev
    program_hw_devices $dev
}

set part "xc7z020clg484-1"

set dir [ lindex $argv 0 ]
if { [ file isdirectory $dir ] == 0 } {
    error "path '$dir' does not exist"
}

create_project -in_memory -part $part
read_xdc "top.xdc"

read_vhdl "util.vhd"
foreach { file } [ glob -nocomplain -directory "util/" -- "*.vhd" ] {
    add_files -fileset sources_1 "$file"
}
foreach { file } [ glob -nocomplain -directory "util/" -- "*.v" ] {
    add_files -fileset sources_1 "$file"
}

foreach { file } [ glob -nocomplain -directory "tb/" -- "*.vhd" ] {
    add_files -fileset sim_1 "$file"
}
foreach { file } [ glob -nocomplain -directory "tb/" -- "*.v" ] {
    add_files -fileset sim_1 "$file"
}

read_vhdl "$dir/top.vhd"
set_property top top [ current_fileset ]
