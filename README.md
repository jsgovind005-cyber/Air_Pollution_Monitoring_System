AIR POLLUTION MONITORING SYSTEM - VIVADO-ONLY SIMULATION
==========================================================

Purpose
-------
This project is a hardware-free RTL simulation of the Air Pollution
Monitoring System described in the supplied project document.

No PMS5003, MQ135, DHT11/DHT22, Arduino, NodeMCU, FPGA board, or other
physical hardware is required.

Files
-----
1. threshold_detector.sv
   Detects NORMAL, WARNING, and DANGER states.

2. air_quality_monitor.sv
   Registers sensor values and the threshold status.

3. data_logger.sv
   Stores recent readings in a small synthesizable RAM-like history buffer.

4. air_pollution_top.sv
   Top-level integration module.

5. air_pollution_tb.sv
   Simulation testbench. It acts as the virtual sensor environment.

Data representation
-------------------
PM2.5      : unsigned integer, ug/m3
CO2        : unsigned integer, ppm
Temperature: unsigned integer, degrees Celsius
Humidity   : unsigned integer, percent

Default simulation thresholds
-----------------------------
PM2.5 >= 35  -> WARNING
PM2.5 >= 55  -> DANGER
CO2   >= 1000 -> WARNING
CO2   >= 1500 -> DANGER

These thresholds are configurable parameters for simulation and are not
claimed to be the official limits from the supplied project document.

Status encoding
---------------
00 = NORMAL
01 = WARNING
10 = DANGER

Vivado setup
------------
1. Create a new RTL Project.
2. Add threshold_detector.sv, air_quality_monitor.sv,
   data_logger.sv, and air_pollution_top.sv as Design Sources.
3. Add air_pollution_tb.sv as a Simulation Source.
4. Set air_pollution_tb as the simulation top.
5. Run Simulation -> Run Behavioral Simulation.
6. Add the important signals to the waveform if Vivado does not add them
   automatically.
7. Run for enough simulation time to observe all scenarios.

Expected scenarios
------------------
The testbench generates:
- Normal air
- Moderate/normal air
- PM2.5 warning
- CO2 warning
- PM2.5 danger
- CO2 danger
- Both pollutants dangerous
- Return to normal

The testbench also reads back the stored history entries.

Possible future extensions
--------------------------
- UART transmitter
- AXI4-Lite/AXI-Stream interface
- Seven-segment display model
- VGA/display controller simulation
- More detailed AQI calculation
- Time/date tagging for history
- Java/HTTP interface outside Vivado
- FPGA-board implementation after simulation is verified

