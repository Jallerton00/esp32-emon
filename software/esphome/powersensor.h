#include "esphome.h"
#include "EmonLib.h"

#define VOLTAGE_PIN 33
#define VOLTAGE_CALIBRATION 57.19
#define PHASE_CALIBRATION 1.28
#define CURRENT_1_CALIBRATION 26.4
#define CURRENT_1_PIN 34

class MyPowerSensor : public PollingComponent, public Sensor {
 public:
  EnergyMonitor emon1;
  Sensor *realpower_sensor = new Sensor();
  Sensor *apparentpower_sensor = new Sensor();
  Sensor *powerfactor_sensor = new Sensor();
  Sensor *voltage_sensor = new Sensor();
  Sensor *current_sensor = new Sensor();
  MyPowerSensor() : PollingComponent(2000) { }
  
  void setup() override {
   voltage_sensor->set_unit_of_measurement("V");
   voltage_sensor->set_accuracy_decimals(2);
   voltage_sensor->set_device_class("voltage");

   current_sensor->set_unit_of_measurement("A");
   current_sensor->set_accuracy_decimals(2);
   current_sensor->set_device_class("current");

   realpower_sensor->set_unit_of_measurement("W");
   realpower_sensor->set_accuracy_decimals(2);
   realpower_sensor->set_device_class("power");

   apparentpower_sensor->set_unit_of_measurement("VA");
   apparentpower_sensor->set_accuracy_decimals(2);
   apparentpower_sensor->set_device_class("power");

   powerfactor_sensor->set_accuracy_decimals(2);
   powerfactor_sensor->set_device_class("power");


   emon1.voltage(VOLTAGE_PIN, VOLTAGE_CALIBRATION, PHASE_CALIBRATION);
   emon1.current(CURRENT_1_PIN, CURRENT_1_CALIBRATION);
  }
  
  void update() override {
   emon1.calcVI(20,2000);
   float realPower = emon1.realPower;
   realpower_sensor->publish_state(realPower);
   float apparentPower = emon1.apparentPower;
   apparentpower_sensor->publish_state(apparentPower);
   float powerFactor= emon1.powerFactor;
   powerfactor_sensor->publish_state(powerFactor);
   voltage_sensor->publish_state(emon1.Vrms);
   current_sensor->publish_state(emon1.Irms);
   }
};