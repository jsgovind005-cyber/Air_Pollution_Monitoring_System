1.AIR POLLUTION MONITORING SYSTEM - VIVADO-ONLY SIMULATION
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

  ------------------------------------------------------------------------------------
  
2.IOT HEALTH MONITORING SYSTEM
==========================================================

Hardware-Free Vivado RTL Simulation
-------------------------------------

DESIGN SOURCES:
----------------
- sensor_calibration.sv
- sensor_stability_checker.sv
- health_threshold_detector.sv
- health_monitor.sv
- health_data_logger.sv
- health_packetizer.sv
- uart_tx.sv
- health_monitor_top.sv

SIMULATION SOURCE:
-------
- health_monitor_tb.sv

SET SIMULATION TOP:
-------
- health_monitor_tb

RUN:
-------
- Run Simulation -> Run Behavioral Simulation

WAVEFORM:
-------
- clk
- rst
- sample_en
- heart_rate_raw
- temperature_raw
- spo2_raw
- current_heart_rate
- current_temperature
- current_spo2
- sensor_valid
- sensor_stable
- sensor_error
- warning
- danger
- status
- write_addr
- read_addr
- read_heart_rate
- read_temperature
- read_spo2
- read_status
- packet_busy
- packet_done
- packet_index
- tx_data
- tx_start
- tx_busy
- tx_done
- tx_serial

Temperature representation:
-------
- 367 = 36.7 C
- 390 = 39.0 C

Status:
-------
- 00 = NORMAL
- 01 = WARNING
- 10 = DANGER

The physical sensors, Wi-Fi and cloud are represented by simulation equivalents.


------------------------------------------------------------------------------------

# 3.Smart Energy Meter — Vivado Simulation

## Project purpose

This is a software-only RTL implementation of the Smart Energy Meter internship project.

The physical voltage/current sensors are represented by synthesizable simulation models.
The project demonstrates:

- virtual appliance/load generation
- voltage and current sensor modeling
- power calculation
- cumulative energy calculation
- threshold-based alerts
- alert state controller
- billing estimate
- internal data packet generation
- serial packet transmission
- Vivado behavioral simulation

## Important scope

This project is a simulation/RTL prototype. It does not claim to physically measure mains electricity.
Actual ACS712/CT/ZMPT101B interfacing, ADC circuitry, Wi-Fi/GSM and cloud deployment are future hardware/integration stages.

## Units

- voltage_x10: voltage multiplied by 10. Example: 2300 = 230.0 V
- current_x100: current multiplied by 100. Example: 200 = 2.00 A
- power_w: watts
- energy_wh: watt-hours
- cost_rupees: integer rupees in the simulation

## Default thresholds

- Warning: >= 1500 W
- Danger: >= 2500 W
- Tariff: Rs.7/kWh

## Vivado setup

1. Create a new RTL Project.
2. Add all files under `rtl/` as Design Sources.
3. Add `sim/smart_energy_meter_tb.sv` as a Simulation Source.
4. Set `smart_energy_meter_tb` as simulation top.
5. Run Behavioral Simulation.
6. Add these signals to the waveform:
   - clk
   - rst
   - light_on
   - fan_on
   - tv_on
   - computer_on
   - ac_on
   - load_power_w
   - voltage_x10
   - current_x100
   - power_w
   - energy_wh
   - cost_rupees
   - warning
   - danger
   - alert
   - alert_code
   - uart_tx
   - uart_busy

## Recommended presentation

Explain the architecture as:

Virtual Load -> Sensor Model -> Power -> Energy -> Alert/Billing -> Packetizer -> UART

The physical sensor and communication interfaces can later be substituted with actual FPGA I/O, ADC and communication IP/hardware.

---------------------------------------------------------------------------------------------------------------------------------------
  
# 4. Smart Traffic Light Control System — Arduino Simulation

## Basis
This simulation implements the supplied internship brief:
- real-time traffic-density sensing
- adaptive signal timing / route prioritization
- LED traffic lights
- software simulation
- serial monitoring of traffic density and selected lane

The supplied PDF lists Arduino/Raspberry Pi, vehicle-detection sensors, Arduino IDE/Python, optional Proteus/Tinkercad/MATLAB Simulink simulation, and optional IoT/dashboard communication.

## Simulation model
The included Wokwi diagram uses an **Arduino Mega** because it provides enough GPIO pins for 8 sensor inputs and 12 traffic-light LED outputs. Because a pure software simulation does not have physical IR sensors, **two pushbuttons per lane are used as IR-sensor emulators**:
- Button released = no vehicle (`HIGH`)
- Button pressed = vehicle detected (`LOW`)
- Each lane therefore has a density score from 0 to 2.

### Lanes
| Lane | Sensor 1 | Sensor 2 | Red | Yellow | Green |
|---|---:|---:|---:|---:|---:|
| L1 | D2 | D3 | D10 | D11 | D12 |
| L2 | D4 | D5 | D13 | A0 | A1 |
| L3 | D6 | D7 | A3 | A4 | A2 |
| L4 | D8 | D9 | A3* | A5 | A7 |

> For an actual Arduino Uno, avoid using A6/A7 as digital outputs. The provided sketch is intended as a logic reference; use an Arduino Mega, or remap the last lane's LEDs to free digital pins.

## Recommended clean Uno pin assignment
For the most reliable Uno simulation, use this mapping instead:

- L1 IR: D2, D3 | LEDs: D10, D11, D12
- L2 IR: D4, D5 | LEDs: D13, A0, A1
- L3 IR: D6, D7 | LEDs: A2, A3, A4
- L4 IR: D8, D9 | LEDs: A5, A6, A7

If using an Uno model that does not expose A6/A7 as digital GPIO, change the last three LED pins to another Arduino model or reduce each lane to two LEDs for the simulation.

## How the controller works
1. Read all eight vehicle-detection inputs.
2. Count active sensors in each lane.
3. Find the lane with maximum density.
4. Give that lane GREEN.
5. Other lanes remain RED.
6. After the green interval, the selected lane becomes YELLOW.
7. After yellow, all lanes become RED briefly.
8. Re-evaluate density and select the next lane.
9. Equal-density lanes are handled in round-robin order.

## Threshold / decision rule
There is no numerical threshold in the supplied brief. In this simulation, the adaptive decision threshold is:
**maximum density among the four lanes**.

Example:
- L1 = 0
- L2 = 2
- L3 = 1
- L4 = 0

Then L2 receives green because it has the highest measured traffic density.

## Simulation procedure
1. Open the project in Arduino IDE or a compatible Arduino simulator.
2. Upload `smart_traffic_light.ino`.
3. Start the simulation.
4. Press different lane sensor buttons to emulate vehicles.
5. Observe the red/yellow/green LEDs.
6. Open Serial Monitor at 9600 baud.
7. The monitor reports the selected lane and density of every lane.

## Expected result
When traffic density changes, the controller changes the selected green lane at the next decision point. Thus, a heavily congested lane is prioritized instead of using a fixed sequence.

This demonstrates the core objective in the supplied PDF: dynamically adjusting signal control based on real-time traffic density.

