#

source {device.tcl}

source {util/nios_base.tcl}
set_instance_parameter_value ram {memorySize} {0x00080000}
source {a10/flash1616.tcl}

source {nios_pcie.tcl}
