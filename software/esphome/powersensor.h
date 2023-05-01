#include "esphome.h"
#include "EmonLib/EmonLib.h"

class MyPowerSensor : public PollingComponent, public Sensor {
 public:
  EnergyMonitor emon1;
  Sensor *realpower_sensor = new Sensor();
  Sensor *apparentpower_sensor = new Sensor();
  Sensor *powerfactor_sensor = new Sensor();
  MyPowerSensor() : PollingComponent(1000) { }
  
  void setup() override {
   emon1.voltage(34, 269.5, 1.7);
   emon1.current(35, 4.9);
  }
  
  void update() override {
   emon1.calcVI(20,2000);
   float realPower = emon1.realPower;
   realpower_sensor->publish_state(realPower);
   float apparentPower = emon1.apparentPower;
   apparentpower_sensor->publish_state(apparentPower);
   float powerFactor= emon1.powerFactor;
   powerfactor_sensor->publish_state(powerFactor);
   }
};