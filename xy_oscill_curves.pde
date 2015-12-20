import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.signals.Oscillator;

Minim minim;
AudioOutput out;
Oscil xwave, ywave;
Pan xpan = new Pan(-1);
Pan ypan = new Pan(1);
float xfreq = 80;
float yfreq  = 80;
float xphase = 90;
float yphase = 0;
// keep track of the current Frequency so we can display it
Frequency  currentFreq;

float freqMin = 20;
float freqMax = 440;
float freqMod = .25;
float freqDotSize = 20;
float border = 25;
float o, w, h;

color xc = color(225, 0, 0);
color yc = color(200, 200, 0);
color oc = color(0, 200, 0);
color dc = color(150);

boolean xyMode = true;
boolean xPhaseShift = false;
boolean yPhaseShift = false;
float phaseShift = .001;

int cSize = 8;

//CONTROLS
import controlP5.*;
ControlP5 cp5;
Textfield xtf, ytf, xtp, ytp, fmint, fmaxt;
DropdownList xd, yd;
Numberbox ps;
String[] waveTypes = {
  "SINE", "SQUARE", "TRIANGLE", "SAW", "QUARTERPULSE"
};
Wavetable[] waveTables = {
  Waves.SINE, Waves.SQUARE, Waves.TRIANGLE, Waves.SAW, Waves.QUARTERPULSE
};

void setup() {
  size(900, 600);
  //size(displayWidth,displayHeight);
  o = border;
  w = width-o;
  h = height-o;
  minim = new Minim(this);
  
  
  out = minim.getLineOut(Minim.STEREO, 1024);
  xwave = new Oscil( xfreq, .5, Waves.SINE );
  xwave.patch(xpan).patch(out); 
  ywave = new Oscil( yfreq, .5, Waves.SINE );  
  ywave.patch(ypan).patch(out);
  //  xfreq = int(random(freqMin, freqMax));
  //  yfreq = int(random(freqMin, freqMax));
  xwave.setFrequency(xfreq);
  ywave.setFrequency(yfreq);
  setupControls();
}

void draw() {
  background(0);
  showGrid();
  showFreq();
  showScope();
  if (xPhaseShift || yPhaseShift) {
    if (xPhaseShift){
      xphase += phaseShift;
      if(xphase >360)
        xphase = 0;
    }

    updatePhase();
  }
}

void setupControls() {
  cp5 = new ControlP5(this);
  PFont font = createFont("Monaco", 14);
  PFont labelFont = createFont("Monaco", 20);

  int tw = 100; // w*.15;
  
  
  cp5.addTextlabel("GRID")
                    .setText("_FREQ RANGE")
                    .setPosition(h+o, o*1.3)
                    .setColorValue(color(255))
                    .setFont(font)
                    ;
  
  
  int gridOffset = int(o*1.5);
  
  fmint = cp5.addTextfield("fmint")
    .setPosition(h+o, gridOffset+o)
      .setSize(tw, 20)
        .setFont(font)
          .setAutoClear(false)
            .setLabel("min")
              ;
  fmint.setValue(nf(freqMin, 1, 0));
  
  fmaxt = cp5.addTextfield("fmaxt")
    .setPosition(h+o*2+tw, gridOffset+o)
      .setSize(tw, 20)
        .setFont(font)
          .setAutoClear(false)
            .setLabel("max")
              ;
  fmaxt.setValue(nf(freqMax, 1, 0));
  
  
  int freqOffset = int(o*5);

  cp5.addTextlabel("WAVES")
                    .setText("_WAVES")
                    .setPosition(h+o, freqOffset-o*.25)
                    .setColorValue(color(255))
                    .setFont(font)
                    ;
  

  xtf = cp5.addTextfield("xfreqt")
    .setPosition(h+o, freqOffset+o*2.5)
      .setSize(tw, 20)
        .setFont(font)
          .setAutoClear(false)
            .setLabel("x - frequency")
              ;
  xtf.setValue(nf(xfreq, 2, 2));

  xtp = cp5.addTextfield("xphaset")
    .setPosition(h+o, freqOffset+o*4.5)
      .setSize(int(tw*.25), 20)
        .setFont(font)
          .setAutoClear(false)
            .setLabel("phase")
              ;
  xtp.setValue(nf(xphase, 3, 0));

  cp5.addToggle("xPhaseShift")
    .setPosition(h+o+tw*.35, freqOffset+o*4.5)
      .setSize(20, 20)
      .setLabel("shift")
        ;
        
  ps = cp5.addNumberbox("phaseShift")
    .setPosition(h+o+tw*.6, freqOffset+o*4.5)
      .setSize(int(tw*.25), 20)
            .setLabel("speed")
            .setRange(0,180)
           .setMultiplier(0.01) // set the sensitifity of the numberbox
           //.setDirection(cp5.HORIZONTAL)
              ;
  ps.setValue(phaseShift);
  updatePhase();


  ytf = cp5.addTextfield("yfreqt")
    .setPosition(h+o*2+tw, freqOffset+o*2.5)
      .setSize(tw, 20)
        .setFont(font)
          .setAutoClear(false)
            .setLabel("y - frequency")
              ;
  ytf.setValue(nf(yfreq, 2, 2));

/*
  ytp = cp5.addTextfield("yphaset")
    .setPosition(h+o*2+tw, freqOffset+o*4.5)
      .setSize(int(tw*.5), 20)
        .setFont(font)
          .setAutoClear(false)
            .setLabel("y - phase")
              ;
  ytp.setValue(nf(yphase, 1, 2));
  

  cp5.addToggle("yPhaseShift")
    .setPosition(h+o*2+tw+tw*.65, freqOffset+o*4.5)
      .setSize(20, 20)
        ;
*/

  // WAVE TABLE
  xd = cp5.addDropdownList("xwaved")
    .setPosition(h+o, freqOffset+o*2)
      .setSize(tw, 200);

      ;
  dropdownWave(xd);

  yd = cp5.addDropdownList("ywaved")
    .setPosition(h+o*2+tw, freqOffset+o*2)
      .setSize(tw, 200);

      ;
  dropdownWave(yd);
}

void dropdownWave(DropdownList ddl) {
  ddl.setBackgroundColor(color(190));
  //ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
  ddl.captionLabel().set("Wave Type");
  ddl.captionLabel().style().marginTop = 5;
  ddl.setBarHeight(20);
  ddl.setItemHeight(20);
  ddl.addItems(waveTypes);
  ddl.setValue(0);
}

void controlEvent(ControlEvent theEvent) {
  println(theEvent.getName());
  if (theEvent.getName() == "xfreqt") {
    xfreq = float(xtf.getStringValue());
    updateFreq();
  } else if (theEvent.getName() == "yfreqt") {
    yfreq = float(ytf.getStringValue());
    updateFreq();
  } else if (theEvent.getName() == "xwaved") {
    xwave.setWaveform( waveTables[int(theEvent.getValue())] );
  } else if (theEvent.getName() == "ywaved") {
    ywave.setWaveform( waveTables[int(theEvent.getValue())] );
  } else if (theEvent.getName() == "xphaset") {
    xphase = int(xtp.getStringValue());
    updatePhase();
  } else if (theEvent.getName() == "yphaset") {
    yphase = float(ytp.getStringValue())/360;
    updatePhase();
  }else if (theEvent.getName() == "fmint") {
    freqMin = int(fmint.getStringValue());
  }else if (theEvent.getName() == "fmaxt") {
    freqMax = int(fmaxt.getStringValue());
  }
  /*
  if(theEvent.isAssignableFrom(Textfield.class)) {
   println("controlEvent: accessing a string from controller '"
   +theEvent.getName()+"': "
   +theEvent.getStringValue()
   );
   }
   */
}

void showCursor() {
  noCursor();
  smooth();
  stroke(200);
  strokeWeight(3);
  line(mouseX-cSize, mouseY, mouseX+cSize, mouseY);
  line(mouseX, mouseY-cSize, mouseX, mouseY+cSize);
  strokeWeight(1);
}

void showGrid() {
  for (float i=freqMin; i<freqMax; i+= ( (freqMax-freqMin)/10)) {
    float x = map(i, freqMin, freqMax, o*2, h);
    float y = map(i, freqMin, freqMax, o*2, h);

    // channel 1
    stroke(dc);
    noSmooth();
    textSize(9);

    fill(xc);
    if (xyMode)
      fill(dc);

    text(int(i)+"Hz", x+3, o+15);
    line(x, o, x, h);

    // channel 2
    line(o, y, h, y);
    pushMatrix();
    translate(o+5, y+3);
    rotate(radians(90));
    fill(yc);
    if (xyMode)
      fill(dc);
    text(int(i)+"Hz", 0, 0);
    popMatrix();
  }
  line(h, o, h, h);
  line(o, h, h, h);
}

void showFreq() {

  // freq dot
  fill(255);
  noStroke();
  smooth();
  ellipse(map(xfreq, freqMin, freqMax, o*2, h), map(yfreq, freqMin, freqMax, o*2, h), freqDotSize, freqDotSize);

  // freq text
  noSmooth();
  textSize(12);
  fill(xc);
  //text("Channel 1: "+nf(xfreq, 2, 2)+"Hz", h+o, o*2.5);
  fill(yc);
  //text("Channel 2: "+nf(yfreq, 2, 2)+"Hz", h+o*8, o*2.5);
}

void showScope() {
  float amp = w*.30;
  stroke(255);
  noFill();
  //line(mouseX,mouseY,pmouseX,pmouseY);
  pushMatrix();
  translate(h+o+amp/2, h-o-amp/2);
  if (xyMode) {
    stroke(oc);
    beginShape();
    for (int i = 0; i < out.bufferSize (); i++)
    {
      float x = map(i, 0, out.bufferSize(), -amp/2, amp/2);
      float y = map(i, 0, out.bufferSize(), -amp/2, amp/2);
      float lAudio = out.left.get(i)*amp;
      float rAudio = out.right.get(i)*amp;
      vertex(lAudio, rAudio);
    }
    endShape();
  } else {
    stroke(xc);
    beginShape();
    for (int i = 0; i < out.bufferSize (); i++)
    {
      float x = map(i, 0, out.bufferSize(), -amp/2, amp/2);
      float lAudio = out.left.get(i)*amp;
      vertex(x, lAudio);
    }
    endShape();
    stroke(yc);
    beginShape();
    for (int i = 0; i < out.bufferSize (); i++)
    {
      float x = map(i, 0, out.bufferSize(), -amp/2, amp/2);
      float rAudio = out.right.get(i)*amp;
      vertex(x, rAudio);
    }
    endShape();
  }
  popMatrix();
  //xymode
  textSize(10);
  if (xyMode) {
    fill(dc);
    text("XY MODE", h+o, h);
  } else {
    fill(xc);
    text("X", h+o, h);
    fill(yc);
    text("Y", h+o*2, h);
  }
}

void mouseDragged() {
  //showCursor();
  float mouseXLim = constrain(mouseX, o*2, h);
  float mouseYLim = constrain(mouseY, o*2, h);
  if (mouseX < h) {
    if (keyPressed && keyCode == 16) {
      //xwave.setPhase(map(mouseXLim, o*2, h, 0,1));
      //ywave.setPhase(map(mouseYLim, o*2, h-o, 0,1));
    } else {
      xfreq = map(mouseXLim, o*2, h, freqMin, freqMax);
      yfreq = map(mouseYLim, o*2, h, freqMin, freqMax);
      updateFreq();
    }
  }
}

void updateFreq() {
  xwave.setFrequency(xfreq);
  xtf.setValue(nf(xfreq, 2, 2));
  ywave.setFrequency(yfreq);
  ytf.setValue(nf(yfreq, 2, 2));
}

void updatePhase() {
  xwave.setPhase(map(constrain(xphase,0,360),0,360,0,1));
  xtp.setValue(nf(int(xphase), 1, 0));
  //ywave.setPhase(yphase);
  //ytp.setValue(nf(yphase*360, 1, 0));
}

void keyPressed() {
  println(keyCode);

  if (!xtf.isActive() && !ytf.isActive() && !xtp.isActive() && !fmint.isActive() && !fmaxt.isActive()) {
    switch(keyCode) {
    case 37:
      xfreq-=freqMod;
      updateFreq();
      break;
    case 39:
      xfreq+=freqMod;
      updateFreq();
      break;
    case 38:
      yfreq-=freqMod;
      updateFreq();
      break;
    case 40:
      yfreq+=freqMod;
      updateFreq();
      break;
    case 88: // 'x'
      if (xyMode) {
        xyMode = false;
      } else {
        xyMode = true;
      }
      break;
    default: 
      break;
    }
  }

  if (keyCode == 9) {
    cycleInputs();
  }


}

int selInput = 0;
void cycleInputs() {
  if (selInput == 0) {
    xtf.setFocus(true);
    ytf.setFocus(false);
  } else if (selInput == 1) {
    xtf.setFocus(false);
    ytf.setFocus(true);
  } else {
    xtf.setFocus(false);
    ytf.setFocus(false);
  }
  selInput++;
  if (selInput > 2) {
    selInput = 0;
  }
}

