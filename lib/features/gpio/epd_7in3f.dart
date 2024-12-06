import 'package:einblicke_frame/features/gpio/raspberry_pi.dart';
import 'package:image/image.dart';

const int EPD_WIDTH = 800;
const int EPD_HEIGHT = 480;

class EPD7in3f {
  final RaspberryPi epdconfig = RaspberryPi();

  final int reset_pin = RaspberryPi.RST_PIN;
  final int dc_pin = RaspberryPi.DC_PIN;
  final int busy_pin = RaspberryPi.BUSY_PIN;
  final int cs_pin = RaspberryPi.CS_PIN;
  final int width = EPD_WIDTH;
  final int height = EPD_HEIGHT;
  final int BLACK = 0x000000; //  0000  BGR
  final int WHITE = 0xffffff; //  0001
  final int GREEN = 0x00ff00; //  0010
  final int BLUE = 0xff0000; //  0011
  final int RED = 0x0000ff; //  0100
  final int YELLOW = 0x00ffff; //  0101
  final int ORANGE = 0x0080ff; //   0110

  // Hardware reset
  void reset() {
    epdconfig.digital_write(reset_pin, true);
    epdconfig.delay_ms(20);
    epdconfig.digital_write(reset_pin, false); // module reset
    epdconfig.delay_ms(2);
    epdconfig.digital_write(reset_pin, true);
    epdconfig.delay_ms(20);
  }

  void send_command(int command) {
    epdconfig.digital_write(dc_pin, false);
    epdconfig.digital_write(cs_pin, false);
    epdconfig.spi_writebyte([command]);
    epdconfig.digital_write(cs_pin, true);
  }

  // def send_command(self, command):
  //     epdconfig.digital_write(self.dc_pin, 0)
  //     epdconfig.digital_write(self.cs_pin, 0)
  //     epdconfig.spi_writebyte([command])
  //     epdconfig.digital_write(self.cs_pin, 1)

  void send_data(int data) {
    epdconfig.digital_write(dc_pin, true);
    epdconfig.digital_write(cs_pin, false);
    epdconfig.spi_writebyte([data]);
    epdconfig.digital_write(cs_pin, true);
  }

  // def send_data(self, data):
  //     epdconfig.digital_write(self.dc_pin, 1)
  //     epdconfig.digital_write(self.cs_pin, 0)
  //     epdconfig.spi_writebyte([data])
  //     epdconfig.digital_write(self.cs_pin, 1)

  void send_data2(List<int> data) {
    epdconfig.digital_write(dc_pin, true);
    epdconfig.digital_write(cs_pin, false);
    epdconfig.spi_writebyte2(data);
    epdconfig.digital_write(cs_pin, true);
  }

  // # send a lot of data
  // def send_data2(self, data):
  //     epdconfig.digital_write(self.dc_pin, 1)
  //     epdconfig.digital_write(self.cs_pin, 0)
  //     epdconfig.spi_writebyte2(data)
  //     epdconfig.digital_write(self.cs_pin, 1)

  void ReadBusyH() {
    print("e-Paper busy H");
    while (epdconfig.digital_read(busy_pin) == false) {
      epdconfig.delay_ms(5);
      print("e-Paper busy H release");
    }
  }

  // def ReadBusyH(self):
  //     logger.debug("e-Paper busy H")
  //     while(epdconfig.digital_read(self.busy_pin) == 0):      # 0: busy, 1: idle
  //         epdconfig.delay_ms(5)
  //     logger.debug("e-Paper busy H release")

  void TurnOnDisplay() {
    send_command(0x04); // POWER_ON
    ReadBusyH();

    send_command(0x12); // DISPLAY_REFRESH
    send_data(0X00);
    ReadBusyH();

    send_command(0x02); // POWER_OFF
    send_data(0X00);
    ReadBusyH();
  }

  // def TurnOnDisplay(self):
  //     self.send_command(0x04) # POWER_ON
  //     self.ReadBusyH()

  //     self.send_command(0x12) # DISPLAY_REFRESH
  //     self.send_data(0X00)
  //     self.ReadBusyH()

  //     self.send_command(0x02) # POWER_OFF
  //     self.send_data(0X00)
  //     self.ReadBusyH()

  void init() {
    epdconfig.module_init();

    reset();
    ReadBusyH();
    epdconfig.delay_ms(30);

    send_command(0xAA); // CMDH
    send_data(0x49);
    send_data(0x55);
    send_data(0x20);
    send_data(0x08);
    send_data(0x09);
    send_data(0x18);

    send_command(0x01);
    send_data(0x3F);
    send_data(0x00);
    send_data(0x32);
    send_data(0x2A);
    send_data(0x0E);
    send_data(0x2A);

    send_command(0x00);
    send_data(0x5F);
    send_data(0x69);

    send_command(0x03);
    send_data(0x00);
    send_data(0x54);
    send_data(0x00);
    send_data(0x44);

    send_command(0x05);
    send_data(0x40);
    send_data(0x1F);
    send_data(0x1F);
    send_data(0x2C);

    send_command(0x06);
    send_data(0x6F);
    send_data(0x1F);
    send_data(0x1F);
    send_data(0x22);

    send_command(0x08);
    send_data(0x6F);
    send_data(0x1F);
    send_data(0x1F);
    send_data(0x22);

    send_command(0x13); // IPC
    send_data(0x00);
    send_data(0x04);

    send_command(0x30);
    send_data(0x3C);

    send_command(0x41); // TSE
    send_data(0x00);

    send_command(0x50);
    send_data(0x3F);

    send_command(0x60);
    send_data(0x02);
    send_data(0x00);

    send_command(0x61);
    send_data(0x03);
    send_data(0x20);
    send_data(0x01);
    send_data(0xE0);

    send_command(0x82);
    send_data(0x1E);

    send_command(0x84);
    send_data(0x00);

    send_command(0x86); // AGID
    send_data(0x00);

    send_command(0xE3);
    send_data(0x2F);

    send_command(0xE0); // CCSET
    send_data(0x00);

    send_command(0xE6); // TSSET
    send_data(0x00);
  }

  // def init(self):
  //     if (epdconfig.module_init() != 0):
  //         return -1
  //     # EPD hardware init start
  //     self.reset()
  //     self.ReadBusyH()
  //     epdconfig.delay_ms(30)

  //     self.send_command(0xAA)    # CMDH
  //     self.send_data(0x49)
  //     self.send_data(0x55)
  //     self.send_data(0x20)
  //     self.send_data(0x08)
  //     self.send_data(0x09)
  //     self.send_data(0x18)

  //     self.send_command(0x01)
  //     self.send_data(0x3F)
  //     self.send_data(0x00)
  //     self.send_data(0x32)
  //     self.send_data(0x2A)
  //     self.send_data(0x0E)
  //     self.send_data(0x2A)

  //     self.send_command(0x00)
  //     self.send_data(0x5F)
  //     self.send_data(0x69)

  //     self.send_command(0x03)
  //     self.send_data(0x00)
  //     self.send_data(0x54)
  //     self.send_data(0x00)
  //     self.send_data(0x44)

  //     self.send_command(0x05)
  //     self.send_data(0x40)
  //     self.send_data(0x1F)
  //     self.send_data(0x1F)
  //     self.send_data(0x2C)

  //     self.send_command(0x06)
  //     self.send_data(0x6F)
  //     self.send_data(0x1F)
  //     self.send_data(0x1F)
  //     self.send_data(0x22)

  //     self.send_command(0x08)
  //     self.send_data(0x6F)
  //     self.send_data(0x1F)
  //     self.send_data(0x1F)
  //     self.send_data(0x22)

  //     self.send_command(0x13)    # IPC
  //     self.send_data(0x00)
  //     self.send_data(0x04)

  //     self.send_command(0x30)
  //     self.send_data(0x3C)

  //     self.send_command(0x41)     # TSE
  //     self.send_data(0x00)

  //     self.send_command(0x50)
  //     self.send_data(0x3F)

  //     self.send_command(0x60)
  //     self.send_data(0x02)
  //     self.send_data(0x00)

  //     self.send_command(0x61)
  //     self.send_data(0x03)
  //     self.send_data(0x20)
  //     self.send_data(0x01)
  //     self.send_data(0xE0)

  //     self.send_command(0x82)
  //     self.send_data(0x1E)

  //     self.send_command(0x84)
  //     self.send_data(0x00)

  //     self.send_command(0x86)    # AGID
  //     self.send_data(0x00)

  //     self.send_command(0xE3)
  //     self.send_data(0x2F)

  //     self.send_command(0xE0)   # CCSET
  //     self.send_data(0x00)

  //     self.send_command(0xE6)   # TSSET
  //     self.send_data(0x00)
  //     return 0

  List<int> getbuffer(Image image) {
    // // Create a pallette with the 7 colors supported by the panel
    // Palette palette = PaletteInt8(256, 3);
    // palette.setRgb(0, 0, 0, 0);
    // palette.setRgb(1, 255, 255, 255);
    // palette.setRgb(2, 0, 255, 0);
    // palette.setRgb(3, 0, 0, 255);
    // palette.setRgb(4, 255, 0, 0);
    // palette.setRgb(5, 255, 255, 0);
    // palette.setRgb(6, 255, 128, 0);
    // for (int i = 7; i < 256; i++) {
    //   palette.setRgb(i, 0, 0, 0);
    // }

    // Image pal_image = Image(width: 1, height: 1, palette: palette);

    // Check if we need to rotate the image
    int imwidth = image.width;
    int imheight = image.height;

    Image? image_temp;

    if (imwidth == width && imheight == height) {
      image_temp = image;
    } else if (imwidth == height && imheight == width) {
      Image image_temp = copyRotate(image, angle: 90);
    } else {
      print(
          "Invalid image dimensions: $imwidth x $imheight, expected $width x $height");
    }

    // Convert the soruce image to the 7 colors, dithering if needed
    Image image_7color = quantize(
      image_temp!.convert(numChannels: 3),
      numberOfColors: 7,
    );
    final buf_7color = image_7color.getBytes(order: ChannelOrder.rgb);

    // PIL does not support 4 bit color, so pack the 4 bits of color
    // into a single byte to transfer to the panel
    final buf = List<int>.filled(width * height ~/ 2, 0x00);
    int idx = 0;
    for (int i = 0; i < buf_7color.length; i += 2) {
      buf[idx] = (buf_7color[i] << 4) + buf_7color[i + 1];
      idx += 1;
    }

    return buf;
  }

  // def getbuffer(self, image):
  //     # Create a pallette with the 7 colors supported by the panel
  //     pal_image = Image.new("P", (1,1))
  //     pal_image.putpalette( (0,0,0,  255,255,255,  0,255,0,   0,0,255,  255,0,0,  255,255,0, 255,128,0) + (0,0,0)*249)

  //     # Check if we need to rotate the image
  //     imwidth, imheight = image.size
  //     if(imwidth == self.width and imheight == self.height):
  //         image_temp = image
  //     elif(imwidth == self.height and imheight == self.width):
  //         image_temp = image.rotate(90, expand=True)
  //     else:
  //         logger.warning("Invalid image dimensions: %d x %d, expected %d x %d" % (imwidth, imheight, self.width, self.height))

  //     # Convert the soruce image to the 7 colors, dithering if needed
  //     image_7color = image_temp.convert("RGB").quantize(palette=pal_image)
  //     buf_7color = bytearray(image_7color.tobytes('raw'))

  //     # PIL does not support 4 bit color, so pack the 4 bits of color
  //     # into a single byte to transfer to the panel
  //     buf = [0x00] * int(self.width * self.height / 2)
  //     idx = 0
  //     for i in range(0, len(buf_7color), 2):
  //         buf[idx] = (buf_7color[i] << 4) + buf_7color[i+1]
  //         idx += 1

  //     return buf

  void display(Image image) {
    send_command(0x10);
    send_data2(getbuffer(image));

    TurnOnDisplay();
  }

  // def display(self, image):
  //     self.send_command(0x10)
  //     self.send_data2(image)

  //     self.TurnOnDisplay()

  void Clear(int color) {
    send_command(0x10);
    send_data2(List<int>.filled(height * width ~/ 2, color));

    TurnOnDisplay();
  }

  // def Clear(self, color=0x11):
  //     self.send_command(0x10)
  //     self.send_data2([color] * int(self.height) * int(self.width/2))

  //     self.TurnOnDisplay()

  void sleep() {
    send_command(0x07); // DEEP_SLEEP
    send_data(0xA5);

    epdconfig.delay_ms(2000);
    epdconfig.module_exit();
  }

  // def sleep(self):
  //     self.send_command(0x07) # DEEP_SLEEP
  //     self.send_data(0XA5)

  //     epdconfig.delay_ms(2000)
  //     epdconfig.module_exit()
}
