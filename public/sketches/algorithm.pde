float x = 0;
float xSpeed = 1;
float speed = 2;
int wMult = 0;

float scaleX = 1;
float scaleY = 1;

// HOW MANY VOICES TO INTRODUCE?
float[] voicesTH;
float[] colorsTH;
float[] wavesTH;
ArrayList voices = new ArrayList();
int voicesMax = 5;
int colorsMax = 7;
int wavesMax = 4;
int howManyNow = 0;
int addHowMany = 0;
int colorMax = 100;

boolean manualOverride = false;
boolean isDrawStacked = true;
boolean manualKill = false;
int manHowManyToAdd = 1;
boolean manModFreq = true;
int manWaveIndex = 1;

int bgColor = 0;
PFont font;

void setup() {
  size($(window).width(), $(window).height());
  colorMode(HSB, colorMax);
  background(bgColor);
  noFill();

  font = loadFont("SansSerif-16.vlw");
  textFont(font);
  textSize(12);

  // ROLL DICE TO SEE WHICH VOICES GET WHICH THRESHOLDS
  voicesTH = rollDie(voicesMax);
  colorsTH = rollDie(colorsMax);
  wavesTH = rollDie(wavesMax);
  
  noLoop();
}


void draw() {
  scale(scaleX, scaleY);
  updateInstructions();
  pushMatrix();
  translate(-width*wMult, 0);
  //println("FRAMERATE: " + frameRate);
  
  for (int i = 0; i < speed; i++) {
    x+=xSpeed;
    go();
  }
  if (x > width*(wMult+1)) {
    wMult++;
    //println("WIDTH MULTIPLIER: " + wMult);
    background(bgColor);
  }
  popMatrix();
}

void resize(float _scaleX, float _scaleY) {
	scaleX = _scaleX;
	scaleY = _scaleY;
}

void updateInstructions() {
  fill(0);
  noStroke();
  rect(0, 0, 1000, 140);
  fill(colorMax);
  text("ENTER: Manual \t SPACE: Modulate Freq \t +/-: No. Voices to Add \t 1: Sine \t 2: Square \t 3: Sawtooth \t 4: Tan \t TAB: Draw Stacked", 20, 20);
  text("MANUAL ON: " + manualOverride + "\t MANUAL KILL: " + manualKill, 20, 40);
  text("WHICH WAVE: " + manWaveIndex + "\t MOD F: " + manModFreq, 20, 60);
  text("NO. VOICES: " + howManyNow + "\t ADD: " + manHowManyToAdd, 20, 80);
  text("STACKED: " + isDrawStacked, 20, 100);
}

void go() {
  //IF THERE ARE ACTIVE VOICES...
  if (howManyNow > 0) {
    //ITERATE COUNTERS FOR EACH VOICE
    for (int i = howManyNow-1; i >=0; i--) {
      Voice thisVoice = (Voice)voices.get(i);
      int duration = thisVoice.duration;
      int counter = thisVoice.counter;
      if (counter > duration || manualKill) {
        //KILL THE VOICE & START UP NEW ONES
        voices.remove(i);
        howManyNow--;
        cueVoices();
        manualKill = false;
      }
      //ITERATE COUNTER FOR EACH VOICE
      else thisVoice.counter++;
    }
  }
  else cueVoices();


  //println( "HOW MANY VOICES? " + voices.size() );

  float totalY = 0;
  float posTotalY = 0;
  float negTotalY = 0;
  float y = 0;

  //DRAW CURVE FOR EACH ACTIVE VOICE
  for (int i = 0; i < howManyNow; i++) {
    Voice thisVoice = (Voice)voices.get(i);
    color strokeColor = thisVoice.strokeColor;
    float modFreq = thisVoice.modFreq;
    int waveIndex = thisVoice.waveIndex;
    y = drawOverlapped(thisVoice, waveIndex, strokeColor, 0);
    if (isDrawStacked) {
      totalY = drawStacked(thisVoice, waveIndex, strokeColor, y, posTotalY, negTotalY);
      if (totalY >=0 ) posTotalY = totalY;
      else negTotalY = totalY;
    }
  }
}

float drawOverlapped(Voice thisVoice, int waveIndex, color strokeColor, float y) {
  int anchor = int(height/2 + height/7);

  //fetch correct curve
  switch(waveIndex) {
  case 1:
    y = thisVoice.newSine.run();
    drawLine( anchor, y, strokeColor );
    break;  
  case 2:
    y = thisVoice.newSquare.run();
    drawLine( anchor, y, strokeColor ); 
    break;  
  case 3:
    y = thisVoice.newSaw.run();
    drawLine( anchor, y, strokeColor );
    break;
  case 4:
    y = thisVoice.newTan.run();
    drawLine( anchor, y, strokeColor ); 
    break;
  } 

  return y;
}

float drawStacked(Voice thisVoice, int waveIndex, color strokeColor, float y, float posTotalY, float negTotalY) {
  int anchor = int(height/2 + height/7);
  float totalY = 0;

  if (y >=0) {
    totalY = posTotalY + y;
  }
  else if (y < 0) {
    totalY = negTotalY + y;
  }

  drawLine( anchor, totalY, strokeColor );
  return totalY;
}

void cueVoices() {
  if (manualOverride) {
    addHowMany = manHowManyToAdd;
    voices = addVoices(addHowMany, voices);
    manHowManyToAdd = 1;
  }
  else {
    addHowMany = howManyToAdd(howManyNow);
    voices = addVoices(addHowMany, voices);
  }
  howManyNow = voices.size();

  //println("HOW MANY VOICES? " + howManyNow + "\t" + "HOW MANY TO ADD? " + addHowMany);
}

void drawLine(float anchor, float y, color strokeColor) {
  stroke(strokeColor);
  line(x, anchor, x, anchor - int(y));
}

void keyPressed() {
  if (key == 'r') reset();

  if (key == ENTER) manualOverride = !manualOverride;
  if (key == TAB) isDrawStacked = !isDrawStacked;
  if (key == 'k') manualKill = true;

  if (key == CODED) {
    if (keyCode ==UP) manHowManyToAdd++;
    else if (keyCode == DOWN) manHowManyToAdd--;
  }

  if (key == 32) manModFreq = !manModFreq;  

  // CHOOSE A PROBABILITY FUNCTION

  // SINE
  if (key == '1') manWaveIndex = 1;

  // SQUARE
  else if (key =='2') manWaveIndex = 2;

  // SAWTOOTH
  else if (key =='3') manWaveIndex = 3;

  // TANGENT
  else if (key == '4') manWaveIndex = 4;
}

void reset() {
  x = 0;
  wMult = 0;
  voices = new ArrayList<Voice>();
  howManyNow = 0;
  background(0);
}

/////////////////////////////
////////////////////////////
float[] rollDie(int divisions) {
  float [] thresholds = new float[divisions];
  float addOn = 0;

  
   // ROLL DICE TO SEE WHICH VOICES GET WHICH THRESHOLDS
  for(int i = 0; i < divisions; i++) {
    float value = addOn + random(0,1);
    thresholds[i] = value;
    addOn = value;
    // Print out the values all in one line
    print(thresholds[i] + "\t");
    if(i == divisions-1) print("\n");
  }
 
 return thresholds; 
}

int howManyToAdd(int howManyNow) {
    
  // How many voices can I activate max?
  int howManyToAdd = constrain(voicesMax - howManyNow, 1, voicesMax);
  //println("HOW MANY NOW? " + howManyNow);
  
  howManyToAdd = pickOne(howManyToAdd, voicesTH) + 1;
  return howManyToAdd;
}

int pickOne(int maxValue, float[] divvyRange) {
  
  // Pick a number within that range
  float pickANumber = random(0, divvyRange[maxValue-1]);
  
  
  // Load a new array of THs with randomly picked number
  float[] pickOne = new float[maxValue+1];
  for(int i = 0; i < maxValue+1; i++) {
    if(i == maxValue) pickOne[i] = pickANumber;
    else pickOne[i] = divvyRange[i];
  }
  
  // Sort it
  pickOne = sort(pickOne);
  int pickedOne = 0;
  
  // The index above pickANumber is the winner
  for (int i = 0; i < maxValue+1; i++) {
    if (pickOne[i] == pickANumber) {
      pickedOne = i;
    }
  }
  return pickedOne;
}
ArrayList addVoices(int howManyToAdd, ArrayList voices) {
  //Create voices
  // Store values for color, whether to modulate frequency, duration, duration counter and curve type
  for (int i = 0; i < howManyToAdd; i++) {
    voices.add(new Voice(i));
  }
  return voices;
}

class Voice {
  int colorIndex = 0;
  color strokeColor = color(100, 180, 180, 50);
  float modFreq = -1;
  int waveIndex = 1;
  SineWave newSine;
  TanWave newTan;
  SquareWave newSquare;
  SawTooth newSaw;
  int duration = 1000;
  int counter = 0;  
  
  Voice(int index) {
    //Select Color
    colorIndex = pickOne(colorsMax, colorsTH);
    int hueValue = int(colorIndex*colorMax/voicesMax);
    strokeColor = color(hueValue, colorMax, colorMax, 50);
    //strokeColor = color(0, 0, 100, 100);
    
    //Modulate Frequency?
    modFreq = random(0, 1);
    if (manualOverride) {
      if(manModFreq) modFreq = 1;
      else modFreq = 0;
      }
    
    //Which Curve?
    waveIndex = pickOne(wavesMax, wavesTH);
    if (manualOverride) waveIndex = manWaveIndex;
    
    //Store curve
    switch(waveIndex) {
     case 1:
      newSine = new SineWave(modFreq); 
      break;  
     case 2:
      newSquare = new SquareWave(modFreq); 
      break;  
     case 3:
      newSaw = new SawTooth(modFreq); 
      break;  
     case 4:
      newTan = new TanWave(modFreq); 
      break;     
    }
    
    //Pick a Duration
    duration = int(random(100, 1000));
    
    //Kick off Duration counter for each voice
    counter = 0;

    //println("COLOR: " + colorIndex + "\t" + "MOD FREQ: " + modFreq + "\t" + "DURATION: " + duration + "\t" + "WHICH CURVE: " + waveIndex);    
  }
}
class Wave {
  float x = 0;
  float xFactor = 0.01;
  float yFactor = 50;
  float modFreq = 0;
  float xChange = 1.5;

  Wave() {
  }
}

//Gradual Growth and Decay
class SineWave extends Wave {
  SineWave modulate;
  
  SineWave(float modFreq_) {
    super(); 
    modFreq = modFreq_; 
    if (modFreq > .1) modulate = new SineWave(-1);
    else if (modFreq == -1) xFactor = 0.000001;
    else xFactor = 0.01;
  }

  float run() {
    x+=xChange;
    if (modFreq > .1) xFactor = modulate.run();
    return sin(xFactor*x)*yFactor;
  }
}

// Regular pulses
// Unpredictable pulses
class TanWave extends Wave {

  TanWave(float modFreq_) {
    super();
    modFreq = modFreq_; 
    xFactor = .01;
  }

  float run() {
    x+=xChange;
    if (modFreq > .5) xFactor = random(0, 1);
    return tan(x*xFactor);
  }
}

// Sudden and Sustained Change
class SquareWave extends Wave {
  int counter = 0;
  float hiPeriod = 100;
  float loPeriod = 30;
  boolean high = true;
  SineWave modulateLo;
  SineWave modulateHi;
    
  SquareWave(float modFreq_) {
    super();
    modFreq = modFreq_; 
    if(modFreq > .5) modulateLo = new SineWave(-1);
    if(modFreq > .3) modulateHi = new SineWave(-1);

  }

  float run() {
    counter+=xChange;
    if (high && counter < hiPeriod) x = 50;
    else if (!high && counter < loPeriod) x = -50;
    else {
      high = !high;
      counter = 0;
      if (modFreq > .5) loPeriod = modulateLo.run();
      if (modFreq > .3) hiPeriod = modulateHi.run();
    }
    return x;
  }
}

// Linear Growth, Sudden Extinction
class SawTooth extends Wave {
  float period = 100;
  SineWave modulate;

  SawTooth(float modFreq_) {
    super();
    modFreq = modFreq_; 
    if (modFreq > .3) modulate = new SineWave(-1);
    x = -100; 
  }

  float run() {
    if (x < period) x+=xChange;
    else {
      x = -100;
      if(modFreq > .3) period = modulate.run();
    }

    return x;
  }
}


