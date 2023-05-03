#include "esphome.h"
#include "EmonLib.h"

class MyPowerSensor : public PollingComponent, public Sensor {
 public:
  EnergyMonitor emon1;
  Sensor *realpower_sensor = new Sensor();
  Sensor *apparentpower_sensor = new Sensor();
  Sensor *powerfactor_sensor = new Sensor();
  Sensor *voltage_sensor = new Sensor();
  Sensor *current_sensor = new Sensor();
  MyPowerSensor() : PollingComponent(500) { }
  
  void setup() override {
   emon1.voltage(33, 520, 1.5);
   emon1.current(35, 0.1);
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