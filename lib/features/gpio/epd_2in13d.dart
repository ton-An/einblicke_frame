// import logging
// from . import epdconfig
// from PIL import Image
// import RPi.GPIO as GPIO

// # Display resolution
import 'package:einblicke_frame/features/gpio/raspberry_pi.dart';
import 'package:image/image.dart';

const int EPD_WIDTH = 104;
const int EPD_HEIGHT = 212;

// logger = logging.getLogger(__name__)

class Epd2in13d {
  final RaspberryPi epdconfig = RaspberryPi();

  final int reset_pin = RaspberryPi.RST_PIN;
  final int dc_pin = RaspberryPi.DC_PIN;
  final int busy_pin = RaspberryPi.BUSY_PIN;
  final int cs_pin = RaspberryPi.CS_PIN;
  final int width = EPD_WIDTH;
  final int height = EPD_HEIGHT;

  final List<int> lut_vcomDC = [
    0x00,
    0x08,
    0x00,
    0x00,
    0x00,
    0x02,
    0x60,
    0x28,
    0x28,
    0x00,
    0x00,
    0x01,
    0x00,
    0x14,
    0x00,
    0x00,
    0x00,
    0x01,
    0x00,
    0x12,
    0x12,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
  ];

  List<int> lut_ww = [
    0x40,
    0x08,
    0x00,
    0x00,
    0x00,
    0x02,
    0x90,
    0x28,
    0x28,
    0x00,
    0x00,
    0x01,
    0x40,
    0x14,
    0x00,
    0x00,
    0x00,
    0x01,
    0xA0,
    0x12,
    0x12,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
  ];

  List<int> lut_bw = [
    0x40,
    0x17,
    0x00,
    0x00,
    0x00,
    0x02,
    0x90,
    0x0F,
    0x0F,
    0x00,
    0x00,
    0x03,
    0x40,
    0x0A,
    0x01,
    0x00,
    0x00,
    0x01,
    0xA0,
    0x0E,
    0x0E,
    0x00,
    0x00,
    0x02,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
  ];

  List<int> lut_wb = [
    0x80,
    0x08,
    0x00,
    0x00,
    0x00,
    0x02,
    0x90,
    0x28,
    0x28,
    0x00,
    0x00,
    0x01,
    0x80,
    0x14,
    0x00,
    0x00,
    0x00,
    0x01,
    0x50,
    0x12,
    0x12,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
  ];

  List<int> lut_bb = [
    0x80,
    0x08,
    0x00,
    0x00,
    0x00,
    0x02,
    0x90,
    0x28,
    0x28,
    0x00,
    0x00,
    0x01,
    0x80,
    0x14,
    0x00,
    0x00,
    0x00,
    0x01,
    0x50,
    0x12,
    0x12,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
  ];

  List<int> lut_vcom1 = [
    0x00,
    0x19,
    0x01,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
  ];

  List<int> lut_ww1 = [
    0x00,
    0x19,
    0x01,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
  ];

  List<int> lut_bw1 = [
    0x80,
    0x19,
    0x01,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
  ];

  List<int> lut_wb1 = [
    0x40,
    0x19,
    0x01,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
  ];

  List<int> lut_bb1 = [
    0x00,
    0x19,
    0x01,
    0x00,
    0x00,
    0x01,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
    0x00,
  ];

//     def __init__(self):
//         self.reset_pin = epdconfig.RST_PIN
//         self.dc_pin = epdconfig.DC_PIN
//         self.busy_pin = epdconfig.BUSY_PIN
//         self.cs_pin = epdconfig.CS_PIN
//         self.width = EPD_WIDTH
//         self.height = EPD_HEIGHT

//     lut_vcomDC = [
//         0x00, 0x08, 0x00, 0x00, 0x00, 0x02,
//         0x60, 0x28, 0x28, 0x00, 0x00, 0x01,
//         0x00, 0x14, 0x00, 0x00, 0x00, 0x01,
//         0x00, 0x12, 0x12, 0x00, 0x00, 0x01,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00,
//     ]

//     lut_ww = [
//         0x40, 0x08, 0x00, 0x00, 0x00, 0x02,
//         0x90, 0x28, 0x28, 0x00, 0x00, 0x01,
//         0x40, 0x14, 0x00, 0x00, 0x00, 0x01,
//         0xA0, 0x12, 0x12, 0x00, 0x00, 0x01,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//     ]

//     lut_bw = [
//         0x40, 0x17, 0x00, 0x00, 0x00, 0x02,
//         0x90, 0x0F, 0x0F, 0x00, 0x00, 0x03,
//         0x40, 0x0A, 0x01, 0x00, 0x00, 0x01,
//         0xA0, 0x0E, 0x0E, 0x00, 0x00, 0x02,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//     ]

//     lut_wb = [
//         0x80, 0x08, 0x00, 0x00, 0x00, 0x02,
//         0x90, 0x28, 0x28, 0x00, 0x00, 0x01,
//         0x80, 0x14, 0x00, 0x00, 0x00, 0x01,
//         0x50, 0x12, 0x12, 0x00, 0x00, 0x01,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//     ]

//     lut_bb = [
//         0x80, 0x08, 0x00, 0x00, 0x00, 0x02,
//         0x90, 0x28, 0x28, 0x00, 0x00, 0x01,
//         0x80, 0x14, 0x00, 0x00, 0x00, 0x01,
//         0x50, 0x12, 0x12, 0x00, 0x00, 0x01,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//     ]

//     lut_vcom1 = [
//         0x00, 0x19, 0x01, 0x00, 0x00, 0x01,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00,
//     ]

//     lut_ww1 = [
//         0x00, 0x19, 0x01, 0x00, 0x00, 0x01,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//     ]

//     lut_bw1 = [
//         0x80, 0x19, 0x01, 0x00, 0x00, 0x01,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//     ]

//     lut_wb1 = [
//         0x40, 0x19, 0x01, 0x00, 0x00, 0x01,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//     ]

//     lut_bb1 = [
//         0x00, 0x19, 0x01, 0x00, 0x00, 0x01,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//         0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//     ]

  void reset() {
    epdconfig.digital_write(reset_pin, true);
    epdconfig.delay_ms(200);
    epdconfig.digital_write(reset_pin, false);
    epdconfig.delay_ms(5);
    epdconfig.digital_write(reset_pin, true);
    epdconfig.delay_ms(200);
  }

//     # Hardware reset
//     def reset(self):
//         epdconfig.digital_write(self.reset_pin, 1)
//         epdconfig.delay_ms(200)
//         epdconfig.digital_write(self.reset_pin, 0)
//         epdconfig.delay_ms(5)
//         epdconfig.digital_write(self.reset_pin, 1)
//         epdconfig.delay_ms(200)

  void send_command(int command) {
    epdconfig.digital_write(dc_pin, false);
    epdconfig.digital_write(cs_pin, false);
    epdconfig.spi_writebyte([command]);
    epdconfig.digital_write(cs_pin, true);
  }

//     def send_command(self, command):
//         epdconfig.digital_write(self.dc_pin, 0)
//         epdconfig.digital_write(self.cs_pin, 0)
//         epdconfig.spi_writebyte([command])
//         epdconfig.digital_write(self.cs_pin, 1)

  void send_data(int data) {
    epdconfig.digital_write(dc_pin, true);
    epdconfig.digital_write(cs_pin, false);
    epdconfig.spi_writebyte([data]);
    epdconfig.digital_write(cs_pin, true);
  }

//     def send_data(self, data):
//         epdconfig.digital_write(self.dc_pin, 1)
//         epdconfig.digital_write(self.cs_pin, 0)
//         epdconfig.spi_writebyte([data])
//         epdconfig.digital_write(self.cs_pin, 1)

  void send_data2(List<int> data) {
    epdconfig.digital_write(dc_pin, true);
    epdconfig.digital_write(cs_pin, false);
    epdconfig.spi_writebyte(data);
    epdconfig.digital_write(cs_pin, true);
  }

//     # send a lot of data
//     def send_data2(self, data):
//         epdconfig.digital_write(self.dc_pin, 1)
//         epdconfig.digital_write(self.cs_pin, 0)
//         epdconfig.spi_writebyte2(data)
//         epdconfig.digital_write(self.cs_pin, 1)

  /// TODO SHOULD BUSY PIN CHECK REALLY BE FALSE?

  void ReadBusy() {
    print("e-Paper busy");
    while (epdconfig.digital_read(busy_pin) == false) {
      // 0: idle, 1: busy
      send_command(0x71);
      epdconfig.delay_ms(100);
    }
    print("e-Paper busy release");
  }

//     def ReadBusy(self):
//         logger.debug("e-Paper busy")
//         while(epdconfig.digital_read(self.busy_pin) == 0):      # 0: idle, 1: busy
//             self.send_command(0x71)
//             epdconfig.delay_ms(100)
//         logger.debug("e-Paper busy release")

  void TurnOnDisplay() {
    send_command(0x12);
    epdconfig.delay_ms(100);
    ReadBusy();
  }

//     def TurnOnDisplay(self):
//         self.send_command(0x12)
//         epdconfig.delay_ms(100)
//         self.ReadBusy()

  void init() {
    epdconfig.module_init();

    reset();

    send_command(0x01); // POWER SETTING
    send_data(0x03);
    send_data(0x00);
    send_data(0x2b);
    send_data(0x2b);
    send_data(0x03);

    send_command(0x06); // boost soft start
    send_data(0x17); // A
    send_data(0x17); // B
    send_data(0x17); // C

    send_command(0x04);
    ReadBusy();

    send_command(0x00); // panel setting
    send_data(0xbf); // LUT from OTP,128x296
    send_data(0x0d); // VCOM to 0V fast

    send_command(0x30); // PLL setting
    send_data(0x3a); // 3a 100HZ   29 150Hz 39 200HZ	31 171HZ

    send_command(0x61); // resolution setting
    send_data(width);
    send_data((height >> 8) & 0xff);
    send_data(height & 0xff);

    send_command(0x82); // vcom_DC setting
    send_data(0x28);
  }

//     def init(self):
//         if (epdconfig.module_init() != 0):
//             return -1
//         # EPD hardware init start
//         self.reset()

//         self.send_command(0x01)	# POWER SETTING
//         self.send_data(0x03)
//         self.send_data(0x00)
//         self.send_data(0x2b)
//         self.send_data(0x2b)
//         self.send_data(0x03)

//         self.send_command(0x06)	# boost soft start
//         self.send_data(0x17) # A
//         self.send_data(0x17) # B
//         self.send_data(0x17) # C

//         self.send_command(0x04)
//         self.ReadBusy()

//         self.send_command(0x00)	# panel setting
//         self.send_data(0xbf) # LUT from OTP,128x296
//         self.send_data(0x0d) # VCOM to 0V fast

//         self.send_command(0x30)	# PLL setting
//         self.send_data(0x3a) # 3a 100HZ   29 150Hz 39 200HZ	31 171HZ

//         self.send_command(0x61)	# resolution setting
//         self.send_data(self.width)
//         self.send_data((self.height >> 8) & 0xff)
//         self.send_data(self.height& 0xff)

//         self.send_command(0x82)	# vcom_DC setting
//         self.send_data(0x28)
//         return 0

  void SetFullReg() {
    send_command(0x82);
    send_data(0x00);
    send_command(0x50);
    send_data(0x97);

    send_command(0x20); // vcom
    send_data2(lut_vcomDC);
    send_command(0x21); // ww --
    send_data2(lut_ww);
    send_command(0x22); // bw r
    send_data2(lut_bw);
    send_command(0x23); // wb w
    send_data2(lut_wb);
    send_command(0x24); // bb b
    send_data2(lut_bb);
  }

//     def SetFullReg(self):
//         self.send_command(0x82)
//         self.send_data(0x00)
//         self.send_command(0X50)
//         self.send_data(0x97)

//         self.send_command(0x20) # vcom
//         self.send_data2(self.lut_vcomDC)
//         self.send_command(0x21) # ww --
//         self.send_data2(self.lut_ww)
//         self.send_command(0x22) # bw r
//         self.send_data2(self.lut_bw)
//         self.send_command(0x23) # wb w
//         self.send_data2(self.lut_wb)
//         self.send_command(0x24) # bb b
//         self.send_data2(self.lut_bb)

  void SetPartReg() {
    send_command(0x82);
    send_data(0x03);
    send_command(0x50);
    send_data(0x47);

    send_command(0x20); // vcom
    send_data2(lut_vcom1);
    send_command(0x21); // ww --
    send_data2(lut_ww1);
    send_command(0x22); // bw r
    send_data2(lut_bw1);
    send_command(0x23); // wb w
    send_data2(lut_wb1);
    send_command(0x24); // bb b
    send_data2(lut_bb1);
  }

//     def SetPartReg(self):
//         self.send_command(0x82)
//         self.send_data(0x03)
//         self.send_command(0X50)
//         self.send_data(0x47)

//         self.send_command(0x20) # vcom
//         self.send_data2(self.lut_vcom1)
//         self.send_command(0x21) # ww --
//         self.send_data2(self.lut_ww1)
//         self.send_command(0x22) # bw r
//         self.send_data2(self.lut_bw1)
//         self.send_command(0x23) # wb w
//         self.send_data2(self.lut_wb1)
//         self.send_command(0x24) # bb b
//         self.send_data2(self.lut_bb1)

  List<int> getbuffer(Image image) {
    List<int> buf = List.filled((width ~/ 8) * height, 0xFF);

    Image image_monocolor = monochrome(image);
    int imwidth = image_monocolor.width;
    int imheight = image_monocolor.height;

    if (imwidth == width && imheight == height) {
      for (int y = 0; y < imheight; y++) {
        for (int x = 0; x < imwidth; x++) {
          if (image_monocolor.getPixel(x, y) == 0) {
            buf[(x + y * width) ~/ 8] &= ~(0x80 >> (x % 8));
          }
        }
      }
    } else if (imwidth == height && imheight == width) {
      for (int y = 0; y < imheight; y++) {
        for (int x = 0; x < imwidth; x++) {
          int newx = y;
          int newy = height - x - 1;
          if (image_monocolor.getPixel(x, y) == 0) {
            buf[(newx + newy * width) ~/ 8] &= ~(0x80 >> (y % 8));
          }
        }
      }
    }

    return buf;
  }

//     def getbuffer(self, image):
//         # logger.debug("bufsiz = ",int(self.width/8) * self.height)
//         buf = [0xFF] * (int(self.width/8) * self.height)
//         image_monocolor = image.convert('1')
//         imwidth, imheight = image_monocolor.size
//         pixels = image_monocolor.load()
//         # logger.debug("imwidth = %d, imheight = %d",imwidth,imheight)
//         if(imwidth == self.width and imheight == self.height):
//             logger.debug("Vertical")
//             for y in range(imheight):
//                 for x in range(imwidth):
//                     # Set the bits for the column of pixels at the current position.
//                     if pixels[x, y] == 0:
//                         buf[int((x + y * self.width) / 8)] &= ~(0x80 >> (x % 8))
//         elif(imwidth == self.height and imheight == self.width):
//             logger.debug("Horizontal")
//             for y in range(imheight):
//                 for x in range(imwidth):
//                     newx = y
//                     newy = self.height - x - 1
//                     if pixels[x, y] == 0:
//                         buf[int((newx + newy*self.width) / 8)] &= ~(0x80 >> (y % 8))
//         return buf

  void display(Image image) {
    int linewidth;
    if (width % 8 == 0) {
      linewidth = width ~/ 8;
    } else {
      linewidth = width ~/ 8 + 1;
    }

    send_command(0x10);
    send_data2(List<int>.filled(height * linewidth, 0x00));
    epdconfig.delay_ms(10);

    send_command(0x13);
    send_data2(getbuffer(image));
    epdconfig.delay_ms(10);

    SetFullReg();
    TurnOnDisplay();
  }

//     def display(self, image):
//         if (Image == None):
//             return

//         if self.width%8 == 0:
//             linewidth = int(self.width/8)
//         else:
//             linewidth = int(self.width/8) + 1

//         self.send_command(0x10)
//         self.send_data2([0x00] * self.height * linewidth)
//         epdconfig.delay_ms(10)

//         self.send_command(0x13)
//         self.send_data2(image)
//         epdconfig.delay_ms(10)

//         self.SetFullReg()
//         self.TurnOnDisplay()

//     def DisplayPartial(self, image):
//         if (Image == None):
//             return

//         self.send_command(0x91)
//         self.send_command(0x90)
//         self.send_data(0)
//         self.send_data(self.width - 1)

//         self.send_data(0)
//         self.send_data(0)
//         self.send_data(int(self.height / 256))
//         self.send_data(self.height % 256 - 1)
//         self.send_data(0x28)

//         if self.width%8 == 0:
//             linewidth = int(self.width/8)
//         else:
//             linewidth = int(self.width/8) + 1

//         buf = [0x00] * self.height * linewidth

//         for i in range(self.height * linewidth):
//             buf[i] = ~image[i]

//         self.send_command(0x10)
//         self.send_data2(image)
//         epdconfig.delay_ms(10)

//         self.send_command(0x13)
//         self.send_data2(buf)
//         epdconfig.delay_ms(10)

//         self.SetPartReg()
//         self.TurnOnDisplay()

  void Clear() {
    int linewidth;
    if (width % 8 == 0) {
      linewidth = width ~/ 8;
    } else {
      linewidth = width ~/ 8 + 1;
    }

    send_command(0x10);
    send_data2(List<int>.filled(height * linewidth, 0x00));
    epdconfig.delay_ms(10);

    send_command(0x13);
    send_data2(List<int>.filled(height * linewidth, 0xFF));
    epdconfig.delay_ms(10);

    SetFullReg();
    TurnOnDisplay();
  }

//     def Clear(self):
//         if self.width%8 == 0:
//             linewidth = int(self.width/8)
//         else:
//             linewidth = int(self.width/8) + 1

//         self.send_command(0x10)
//         self.send_data2([0x00] * self.height * linewidth)
//         epdconfig.delay_ms(10)

//         self.send_command(0x13)
//         self.send_data2([0xFF] * self.height * linewidth)
//         epdconfig.delay_ms(10)

//         self.SetFullReg()
//         self.TurnOnDisplay()

  void sleep() {
    send_command(0X50);
    send_data(0xf7);
    send_command(0X02); // power off
    send_command(0X07); // deep sleep
    send_data(0xA5);

    epdconfig.delay_ms(2000);
    epdconfig.module_exit();
  }

//     def sleep(self):
//         self.send_command(0X50)
//         self.send_data(0xf7)
//         self.send_command(0X02) # power off
//         self.send_command(0X07) # deep sleep
//         self.send_data(0xA5)

//         epdconfig.delay_ms(2000)
//         epdconfig.module_exit()

// ### END OF FILE ###
}
