float scale = 1;

//  card numbers
int lowASCII = 32;
int highASCII = 90;

//create card
int flapHeight = 24;
int flapWidth = 18;

PFont flapFont; 


PGraphics[] flaps = new PGraphics[highASCII - lowASCII +1];

int digitsAnimating = 0;

int maxDigitsAnimating = 9;

float flipVelocity = 40.0/1000.0;

float misfireProbability = 0.2;

int nColumns =10;
int nLines = 10;

SolariDigitLine[] lines = new SolariDigitLine[nLines];



void createflaps() {
  
  for (int i=0; i < highASCII - lowASCII +1; i++) {
    flaps[i] = createGraphics(flapWidth, flapHeight);
    flaps[i].beginDraw();
    flaps[i].background(20);
    flaps[i].fill(200);
    flaps[i].textAlign(CENTER, CENTER);
    flapFont = createFont("monotype", 24);
    flaps[i].textFont(flapFont);
    //flaps[i].textSize(24);
    flaps[i].text((char)(i + lowASCII),5.2, 5.2);
    flaps[i].endDraw();
  }
}

PGraphics getFlap(byte c) {
   return flaps[c - lowASCII]; 
}

    
class SolariDigit {
  
  byte digit = byte(lowASCII);
  byte seekDigit = byte(lowASCII);
  
  float angle = 0;
  
  PGraphics topFlap, bottomFlap;
  
  SolariDigit() {
    
    topFlap = getFlap(digit);
    bottomFlap = getFlap(digit);
  }
  
  void seekDigit(char d) {
    seekDigit = (byte)d; 
  }
  
  void advanceDigit() {
   bottomFlap = getFlap(digit);
   
   digit++;
   
   if(digit > highASCII)
     digit = byte(lowASCII);
     
   topFlap = getFlap(digit);
   
  }
  
  void flipStep(int ms) {
     if (angle == 0) {
       if (digitsAnimating > maxDigitsAnimating) {
         image(topFlap, -flapWidth>>1, -flapHeight>>1);
         return;
       }
       advanceDigit();
     }
     
     image(topFlap.get(0, 0, flapWidth, flapHeight>>1), -flapWidth>>1, -flapHeight>>1);
     image(bottomFlap.get(0, flapHeight>>1, flapWidth, flapHeight>>1), -flapWidth>>1, 0);
     
        angle += ms *flipVelocity;
        if(angle > 1) {
          angle= 0;
        }
        
        digitsAnimating++;
     }
     
     void display(int ms) {
       
       if (angle > 0 || digit != seekDigit)
       flipStep(ms);
       else
       image(topFlap, -flapWidth>>1, -flapHeight>>1);
     
  }
}  
        
        
     
    


class SolariDigitLine {
  int length;
  SolariDigit[] digits;
  
  SolariDigitLine(int l) {
    length = l;
    digits = new SolariDigit[length];
    for (int i=0; i<length; i++) {
      digits[i] = new SolariDigit();
    }
  }
  void setText(String str) {
    
    char[] chars = str.toUpperCase().toCharArray();
    for (int i=0; i<min(chars.length, length); i++) {
      digits[i].seekDigit(chars[i]);
    }
  }
  
  void display(int ms) {
    for (int i=0; i<length; i++) {
      pushMatrix();
      translate(flapWidth * 1.1 * i, 0);
      digits[i].display(ms);
      popMatrix();
    }
  }

}
  

String getMultilinePartition(String str, int lineNum) {
  return str.substring(min(lineNum * nColumns, str.length()), min((lineNum + 1) * nColumns, str.length()));
}

void showNum() {
  lines[0].setText( "4.12  6.24" );
  lines[1].setText( "5.65  1.10" ); 
  lines[2].setText( "6.14  8.05" ); 
  lines[3].setText( "5.90  1.81" ); 
  lines[4].setText( "1.07  5.25" ); 
  lines[5].setText( "0.82  5.80" ); 
  lines[6].setText( "3.01  5.30" ); 
  lines[7].setText( "5.05  5.20" ); 
  lines[8].setText( "4.20  8.11" ); 
  lines[9].setText( "8.02  5.02" ); 
}


void showNum1() {
  lines[0].setText( "1.04  8.15" );
  lines[1].setText( "2.75  2.31" ); 
  lines[2].setText( "1.68  1.21" ); 
  lines[3].setText( "5.85  6.58" ); 
  lines[4].setText( "0.07  1.81" ); 
  lines[5].setText( "6.82  7.52" ); 
  lines[6].setText( "5.91  5.70" ); 
  lines[7].setText( "1.12  8.02" ); 
  lines[8].setText( "0.02  2.65" ); 
  lines[9].setText( "5.78  1.26" ); 
}

void setup() {
  frameRate(30);
  size(700,400,P3D);
  surface.setResizable(true);
  flapFont = createFont("Consolas",46, true);
  createflaps();
  
  for (int i = 0; i <nLines; i++) {
   lines[i] = new SolariDigitLine(nColumns);
  }
     
 }
 
int nextFramerateDisplay = 5000;
int nextScreenChange = 0;
int nextScreen = 0;

boolean isDrawing = false;

int z = 0;
void drawLines() {
    z = z + 1;
    print("draw lines function called, z is " + z + "\n");
    if (z < 200) {
      print("z less than 10, draw\n");
      for (int i=0; i<nLines; i++) {
        pushMatrix();
        translate(int (random(10)), flapHeight * 1.1 *i);
         //translate(int (random(200)), int (random(200)));
        //lines[i].display(millis() - lastDraw);
        lines[i].display(0);
        popMatrix();
      }
    } else {
      z = 0;
      if (nextScreen == 0) {
        nextScreen = 1;  
      } else {
        nextScreen = 0;
      }
      drawLines();
    }
  isDrawing = true;
}

void draw() {
  
  background(20);
  
  scale(scale);
  
  pushMatrix();
  translate(258, 30);
  popMatrix();
  
    if (nextScreen ==0) {
      showNum();
    } 
    if (nextScreen == 1) {
      showNum1();
    }
    
    //nextScreen = (nextScreen+1) %2;
  
  pushMatrix();
  digitsAnimating = 0;
  translate(mouseX, mouseY);
  
  drawLines();
  popMatrix();
  
}



  