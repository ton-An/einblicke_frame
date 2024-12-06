import 'package:dart_periphery/dart_periphery.dart' as dart_periphery;

class RaspberryPi {
  // Pin definition
  static int RST_PIN = 17;
  static int DC_PIN = 25;
  static int CS_PIN = 8;
  static int BUSY_PIN = 24;
  static int PWR_PIN = 18;
  static int MOSI_PIN = 10;
  static int SCLK_PIN = 11;

  final dart_periphery.GPIO GPIO_RST_PIN =
      dart_periphery.GPIO(RST_PIN, dart_periphery.GPIOdirection.gpioDirOut);
  final dart_periphery.GPIO GPIO_DC_PIN =
      dart_periphery.GPIO(DC_PIN, dart_periphery.GPIOdirection.gpioDirOut);
  final dart_periphery.GPIO GPIO_PWR_PIN =
      dart_periphery.GPIO(PWR_PIN, dart_periphery.GPIOdirection.gpioDirOut);
  final dart_periphery.GPIO GPIO_BUSY_PIN =
      dart_periphery.GPIO(BUSY_PIN, dart_periphery.GPIOdirection.gpioDirIn);
  late dart_periphery.SPI SPI;

  void digital_write(pin, bool value) {
    if (pin == RST_PIN) {
      GPIO_RST_PIN.write(value);
    } else if (pin == DC_PIN) {
      GPIO_DC_PIN.write(value);
    } else if (pin == PWR_PIN) {
      GPIO_PWR_PIN.write(value);
    }
    // if pin == self.RST_PIN:
    //     if value:
    //       self.GPIO_RST_PIN.on()
    //     else:
    //       self.GPIO_RST_PIN.off()
    // elif pin == self.DC_PIN:
    //     if value:
    //         self.GPIO_DC_PIN.on()
    //     else:
    //         self.GPIO_DC_PIN.off()
    // # elif pin == self.CS_PIN:
    // #     if value:
    // #         self.GPIO_CS_PIN.on()
    // #     else:
    // #         self.GPIO_CS_PIN.off()
    // elif pin == self.PWR_PIN:
    //     if value:
    //         self.GPIO_PWR_PIN.on()
    //     else:
    //         self.GPIO_PWR_PIN.off()
  }

  bool? digital_read(int pin) {
    if (pin == BUSY_PIN) {
      return GPIO_BUSY_PIN.read();
    } else if (pin == RST_PIN) {
      return GPIO_RST_PIN.read();
    } else if (pin == DC_PIN) {
      return GPIO_DC_PIN.read();
    } else if (pin == PWR_PIN) {
      return GPIO_PWR_PIN.read();
    }
  }
  // def digital_read(self, pin):
  //     if pin == self.BUSY_PIN:
  //         return self.GPIO_BUSY_PIN.value
  //     elif pin == self.RST_PIN:
  //         return self.RST_PIN.value
  //     elif pin == self.DC_PIN:
  //         return self.DC_PIN.value
  //     # elif pin == self.CS_PIN:
  //     #     return self.CS_PIN.value
  //     elif pin == self.PWR_PIN:
  //         return self.PWR_PIN.value

  Future delay_ms(int delaytime) =>
      Future.delayed(Duration(milliseconds: delaytime));

  // def delay_ms(self, delaytime):
  //     time.sleep(delaytime / 1000.0)

  void spi_writebyte(List<int> data) {
    SPI.transfer(data, false);
  }

  // def spi_writebyte(self, data):
  //     self.SPI.writebytes(data)

  void spi_writebyte2(List<int> data) {
    SPI.transfer(data, false);
  }

  // def spi_writebyte2(self, data):
  //     self.SPI.writebytes2(data)

  void module_exit({bool cleanup = false}) {
    SPI.dispose();

    GPIO_RST_PIN.write(false);
    GPIO_DC_PIN.write(false);
    GPIO_PWR_PIN.write(false);

    if (cleanup) {
      GPIO_RST_PIN.dispose();
      GPIO_DC_PIN.dispose();
      GPIO_PWR_PIN.dispose();
      GPIO_BUSY_PIN.dispose();
    }
  }

  // def module_exit(self, cleanup=False):
  //     logger.debug("spi end")
  //     self.SPI.close()

  //     self.GPIO_RST_PIN.off()
  //     self.GPIO_DC_PIN.off()
  //     self.GPIO_PWR_PIN.off()
  //     logger.debug("close 5V, Module enters 0 power consumption ...")

  //     if cleanup:
  //         self.GPIO_RST_PIN.close()
  //         self.GPIO_DC_PIN.close()
  //         # self.GPIO_CS_PIN.close()
  //         self.GPIO_PWR_PIN.close()
  //         self.GPIO_BUSY_PIN.close()

  // def DEV_SPI_write(self, data):
  //     self.DEV_SPI.DEV_SPI_SendData(data)

  // def DEV_SPI_nwrite(self, data):
  //     self.DEV_SPI.DEV_SPI_SendnData(data)

  // def DEV_SPI_read(self):
  //     return self.DEV_SPI.DEV_SPI_ReadData()

  void module_init() {
    GPIO_PWR_PIN.write(true);
    SPI = dart_periphery.SPI(0, 0, dart_periphery.SPImode.mode0, 4000000);
  }

  // def module_init(self, cleanup=False):
  //     self.GPIO_PWR_PIN.on()

  //     if cleanup:
  //         find_dirs = [
  //             os.path.dirname(os.path.realpath(__file__)),
  //             '/usr/local/lib',
  //             '/usr/lib',
  //         ]
  //         self.DEV_SPI = None
  //         for find_dir in find_dirs:
  //             val = int(os.popen('getconf LONG_BIT').read())
  //             logging.debug("System is %d bit"%val)
  //             if val == 64:
  //                 so_filename = os.path.join(find_dir, 'DEV_Config_64.so')
  //             else:
  //                 so_filename = os.path.join(find_dir, 'DEV_Config_32.so')
  //             if os.path.exists(so_filename):
  //                 self.DEV_SPI = CDLL(so_filename)
  //                 break
  //         if self.DEV_SPI is None:
  //             RuntimeError('Cannot find DEV_Config.so')

  //         self.DEV_SPI.DEV_Module_Init()

  //     else:
  //         # SPI device, bus = 0, device = 0
  //         self.SPI.open(0, 0)
  //         self.SPI.max_speed_hz = 4000000
  //         self.SPI.mode = 0b00
  //     return 0
}
