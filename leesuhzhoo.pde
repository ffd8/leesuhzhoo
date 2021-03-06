/*  leesuhzhoo v.01
 cc teddavis.org 2015 */

import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.signals.Oscillator;
import java.util.*;

Minim minim;
AudioOutput out;
float[] outxp, outyp;
Oscil xwave, ywave, lwave;
Pan xpan = new Pan(-1);
Pan ypan = new Pan(1);
float xfreq = 80;
float yfreq  = 80;
float xphase = 90;
float yphase = 00;
float amp;

float freqMin = 20;
float freqMax = 440;
float freqMod = .01;
float freqDotSize = 20;
float border = 25;
float o, w, h, g;
boolean changeFreq = false;


color xc = color(225, 0, 0);
color yc = color(200, 200, 0);
color oc = color(128, 255, 128);
color dc = color(150);

//SCOPE
PGraphics scope;

boolean pauseScope = false;
boolean displayScope = true;
boolean glowScope = true;
boolean xyMode = true;
boolean xPhaseSweep = true;
boolean yPhaseSweep = true;
float xphaseShift = .00;
float yphaseShift = .00;

int cSize = 8;

//CONTROLS
String fontName = "Monaco";
import controlP5.*;
ControlP5 cp5;
Textfield xtf, ytf, xtp, ytp, fmint, fmaxt;
ScrollableList xd, yd, dSettings;
Toggle tphase, tscope, txy, tpause;
Button bLoad, bSave;
Numberbox xps, yps;
List waveTypesList = Arrays.asList("SINE", "SQUARE", "TRIANGLE", "SAW", "QUARTERPULSE");
Wavetable[] waveTables = {
  Waves.SINE, Waves.SQUARE, Waves.TRIANGLE, Waves.SAW, Waves.QUARTERPULSE
};
boolean shifted = false;

//settings
String settingsDir, psettingsDir;
String[] settingsList;
String curSetting;
int dMatch = 0;

void setup() {
  fullScreen(P3D);
  o = border;
  w = width-o;
  h = height-o;
  g = floor(width*.3);
  println(g);
  minim = new Minim(this);

  out = minim.getLineOut(Minim.STEREO, 1024);
  outxp = new float[out.bufferSize()];
  outyp = new float[out.bufferSize()];

  xwave = new Oscil( xfreq, 1, Waves.SINE );
  xwave.patch(xpan).patch(out); 
  ywave = new Oscil( yfreq, 1, Waves.SINE );  
  ywave.patch(ypan).patch(out);

  lwave = new Oscil( 0.01, 1, Waves.SINE );  
  xwave.setFrequency(xfreq);
  ywave.setFrequency(yfreq);
  amp = g*.48;
  resetWaves();
  setupControls();
  scope = createGraphics(int(g), int(g));
}

void resetWaves() {
  xwave.reset();
  ywave.reset();
}

void draw() {
  background(0);
  showGrid();
  showFreq();
  if (displayScope) {
    showScope();
    if (!pauseScope) {
      updateBands();
      liveUpdates();
    }
  }
  if (!xtp.isFocus() && !ytp.isFocus()) {
    if (xphaseShift > 0) {
      xphase += xphaseShift;
      if (xphase >360)
        xphase = 0;
      updatePhase();
    }

    if (yphaseShift > 0) {
      yphase += yphaseShift;
      if (yphase >360)
        yphase = 0;
      updatePhase();
    }
  }
}


void setupControls() {
  cp5 = new ControlP5(this);
  PFont font = createFont(fontName, 14);
  PFont labelFont = createFont(fontName, 20);

  int tw = 100; 

  // SETTINGS
  int settingsOffset = int(o);
  cp5.addTextlabel("SETTINGS")
    .setText("LEESUHZHOO v.1")
    .setPosition(h+o/2, settingsOffset)
    .setColorValue(color(255))
    .setFont(font)
    ;
  bSave = cp5.addButton("saveSettings")
    .setPosition(h+o, settingsOffset+o)
    .setSize(45, 20)
    .setLabel("save")
    ;

  bLoad = cp5.addButton("loadSettings")
    .setPosition(h+o*2+30, settingsOffset+o)
    .setSize(45, 20)
    .setLabel("load")
    ;

  int gridOffset = int(o*3.5);

  cp5.addTextlabel("GRID")
    .setText("RANGE")
    .setPosition(h+o/2, gridOffset)
    .setColorValue(color(255))
    .setFont(font)
    ;

  fmint = cp5.addTextfield("fmint")
    .setPosition(h+o, gridOffset+o)
    .setSize(45, 20)
    .setAutoClear(false)
    .setLabel("min")
    ;
  fmint.setValue(nf(freqMin, 1, 0));

  fmaxt = cp5.addTextfield("fmaxt")
    .setPosition(h+o*2+30, gridOffset+o)
    .setSize(45, 20)
    .setAutoClear(false)
    .setLabel("max")
    ;
  fmaxt.setValue(nf(freqMax, 1, 0));

  // SCOPE
  cp5.addTextlabel("SCOPE")
    .setText("SCOPE")
    .setPosition(h+(o/2*3)+tw, gridOffset)
    .setColorValue(color(255))
    .setFont(font)
    ;

  tscope = cp5.addToggle("displayScope")
    .setPosition(h+o*2+tw, gridOffset+o)
    .setSize(20, 20)
    .setLabel("show")
    ;


  tpause = cp5.addToggle("pauseScope")
    .setPosition(h+o*2+tw*1.4, gridOffset+o)
    .setSize(20, 20)
    .setLabel("pause")
    ;

  txy = cp5.addToggle("xyMode")
    .setPosition(h+o*2+tw*1.8, gridOffset+o)
    .setSize(20, 20)
    .setLabel("xy-Mode")
    ;

  int freqOffset = int(gridOffset+o*3);

  cp5.addTextlabel("X")
    .setText("X")
    .setPosition(h+o/2, freqOffset)
    .setColorValue(color(255))
    .setFont(font)
    ;
  cp5.addTextlabel("Y")
    .setText("Y")
    .setPosition(h+(o/2*3)+tw, freqOffset)
    .setColorValue(color(255))
    .setFont(font)
    ;                  

  xtf = cp5.addTextfield("xfreqt")
    .setPosition(h+o, freqOffset+o*2)
    .setSize(tw, 20)
    .setAutoClear(false)
    .setLabel("frequency")
    ;
  xtf.setValue(nf(xfreq, 2, 2));

  int phaseOffset = int(freqOffset+o*2.75);

  xtp = cp5.addTextfield("xphaset")
    .setPosition(h+o, phaseOffset+o)
    .setSize(int(tw*.25), 20)
    .setAutoClear(false)
    .setLabel("phase")
    ;
  xtp.setValue(nf(xphase, 3, 0));


  xps = cp5.addNumberbox("xphaseShift")
    .setPosition(h+o+tw*.35, phaseOffset+o)
    .setSize(int(tw*.35), 20)
    .setLabel("sweep")
    .setRange(0, 180)
    .setMultiplier(0.01) // set the sensitifity of the numberbox
    ;
  xps.setValue(xphaseShift);

  ytf = cp5.addTextfield("yfreqt")
    .setPosition(h+o*2+tw, freqOffset+o*2)
    .setSize(tw, 20)
    .setAutoClear(false)
    .setLabel("frequency")
    ;
  ytf.setValue(nf(yfreq, 2, 2));

  ytp = cp5.addTextfield("yphaset")
    .setPosition(h+o*2+tw, phaseOffset+o)
    .setSize(int(tw*.25), 20)
    .setAutoClear(false)
    .setLabel("phase")
    ;
  ytp.setValue(nf(yphase, 1, 2));

  yps = cp5.addNumberbox("yphaseShift")
    .setPosition(h+o*2+tw+tw*.35, phaseOffset+o)
    .setSize(int(tw*.35), 20)
    .setLabel("sweep")
    .setRange(0, 180)
    .setMultiplier(0.01) // set the sensitifity of the numberbox
    ;
  yps.setValue(yphaseShift);
  updatePhase();

  // WAVE TABLE
  xd = cp5.addScrollableList("xwaved")
    .setPosition(h+o, freqOffset+o)
    .setSize(tw, 200)
    ;
  dropdownWaveList(xd);

  yd = cp5.addScrollableList("ywaved")
    .setPosition(h+o*2+tw, freqOffset+o)
    .setSize(tw, 200)
    ;
  dropdownWaveList(yd);

  //settings dropdown
  dSettings = cp5.addScrollableList("dSettings")
    .setPosition(h+o*2+tw, settingsOffset+o)
    .setSize(tw, 200)
    .setBarHeight(20)
    .setItemHeight(20)
    .setLabel("Settings")
    .setVisible(false)
    ;
  dSettings.setColorActive(color(255, 128));
  dSettings.setBackgroundColor(color(190));
}

void dropdownWaveList(ScrollableList ddl) {
  ddl.setBackgroundColor(color(190));
  ddl.setColorActive(color(255, 128));
  ddl.setBarHeight(20);
  ddl.setItemHeight(20);
  ddl.addItems(waveTypesList);
  ddl.setValue(0);
}


void controlEvent(ControlEvent theEvent) {
  println(theEvent.getName());
  if (theEvent.getName() == "xfreqt") {
    xfreq = float(xtf.getStringValue());
    xtf.setFocus(false);
    updateFreq();
  } else if (theEvent.getName() == "yfreqt") {
    yfreq = float(ytf.getStringValue());
    ytf.setFocus(false);
    updateFreq();
  } else if (theEvent.getName() == "xwaved") {
    xwave.setWaveform( waveTables[int(theEvent.getValue())] );
  } else if (theEvent.getName() == "ywaved") {
    ywave.setWaveform( waveTables[int(theEvent.getValue())] );
  } else if (theEvent.getName() == "xphaset") {
    xphase = int(xtp.getStringValue());
    xtp.setFocus(false);
    updatePhase();
  } else if (theEvent.getName() == "yphaset") {
    yphase = int(ytp.getStringValue());
    ytp.setFocus(false);
    updatePhase();
  } else if (theEvent.getName() == "fmint") {
    freqMin = int(fmint.getStringValue());
    fmint.setFocus(false);
  } else if (theEvent.getName() == "fmaxt") {
    freqMax = int(fmaxt.getStringValue());
    fmaxt.setFocus(false);
  } else if  (theEvent.getName() == "dSettings") {
    int setSel = int(theEvent.getValue());
    File lSet = new File(settingsDir+"/"+settingsList[setSel]);
    loadSelected(lSet);
  }
}

void saveSettings() {
  selectOutput("Store settings:", "saveSelected");
}

void saveSelected(File selection) {
  String[] sSettings = {
    "freqMin="+nf(freqMin, 1, 2), 
    "freqMax="+nf(freqMax, 1, 2), 
    "xfreq="+nf(xfreq, 1, 2), 
    "xwavetype="+nf(int(xd.getValue()), 1), 
    "yfreq="+nf(yfreq, 1, 2), 
    "ywavetype="+nf(int(yd.getValue()), 1), 
    "xphase="+nf(xphase, 1, 2), 
    "xphaseShift="+nf(xphaseShift, 1, 3), 
    "yphase="+nf(yphase, 1, 2), 
    "yphaseShift="+nf(yphaseShift, 1, 3), 
    "displayScope="+str(displayScope), 
    "pauseScope="+str(pauseScope), 
    "xyMode="+str(xyMode)
  };
  saveStrings(selection+".txt", sSettings);
  settingsDir = selection.getParent();
  curSetting = selection.getName()+".txt";
  updateSettings();
}

void loadSettings() {
  selectInput("Load settings:", "loadSelected");
}
void loadSelected(File selection) {
  String lSettings[] = loadStrings(selection);
  freqMin = float(split(lSettings[0], "=")[1]);
  freqMax = float(split(lSettings[1], "=")[1]);
  xfreq = float(split(lSettings[2], "=")[1]);
  xd.setValue(float(split(lSettings[3], "=")[1]));
  yfreq = float(split(lSettings[4], "=")[1]);
  yd.setValue(float(split(lSettings[5], "=")[1]));
  xphase = float(split(lSettings[6], "=")[1]);
  xphaseShift = float(split(lSettings[7], "=")[1]);
  yphase = float(split(lSettings[8], "=")[1]);
  yphaseShift = float(split(lSettings[9], "=")[1]);
  tscope.setValue(boolean(split(lSettings[10], "=")[1]));
  tpause.setValue(boolean(split(lSettings[11], "=")[1]));
  txy.setValue(boolean(split(lSettings[12], "=")[1]));
  updateFreq();
  updatePhase();
  settingsDir = selection.getParent();
  curSetting = selection.getName();
  updateSettings();
}

void updateSettings() {
  dSettings.clear();
  dMatch = 0;
  File dir = new File(settingsDir);
  settingsList = dir.list();
  if (settingsList != null) {
    for (int i=0; i<settingsList.length; i++) {
      if (!settingsList[i].equals(".DS_Store")) {
        String[] item = split(settingsList[i], ".txt");
        dSettings.addItem(item[0], i);
      }
      if (curSetting.equals(settingsList[i])) {
        dMatch = i;
      }
    }
    println("match = "+dMatch);
    dSettings.setVisible(true);
    cp5.setBroadcast(false);
    dSettings.setValue(dMatch);
    cp5.setBroadcast(true);
  }
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
    float x = floor(map(i, freqMin, freqMax, o*2, h));
    float y = floor(map(i, freqMin, freqMax, o*2, h));

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
    translate(o+10, y+3);
    rotate(radians(90));
    fill(yc);
    if (xyMode)
      fill(dc);
    text(int(i)+"Hz", 0, 0);

    popMatrix();
  }
  line(h, o, h, h);
  line(o, h, h, h);

  fill(xc);
  if (xyMode)
    fill(dc);
  text("x - frequency", floor(h/2), floor(o*.5));

  fill(yc);
  if (xyMode)
    fill(dc);

  pushMatrix();
  translate(o+5, 0);
  rotate(radians(90));
  text("y - frequency", floor(h/2), floor(o*.5));
  popMatrix();
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
  scope.beginDraw();
  scope.smooth();
  scope.noStroke();
  if (glowScope && xyMode) {
    scope.fill(0, 32, 0, 50);
  } else {
    scope.background(0, 32, 0);
  }
  scope.rect(0, 0, scope.width, scope.height);
  scope.noFill();
  scope.strokeWeight(1);

  scope.pushMatrix();
  scope.translate(g/2, g/2);

  if (!pauseScope) {
  }
  if (xyMode) {
    scope.stroke(oc);
    scope.beginShape();

    for (int i = 0; i < outxp.length; i++)
    {
      float x = map(i, 0, out.bufferSize(), -amp/2, amp/2);
      float y = map(i, 0, out.bufferSize(), -amp/2, amp/2);
      float lAudio = outxp[i];
      float rAudio = outyp[i];
      scope.vertex(lAudio, rAudio);
    }
    scope.endShape();
  } else {
    scope.stroke(xc);
    scope.beginShape();
    for (int i = 0; i < outxp.length; i++)
    {
      float x = map(i, 0, outxp.length, -amp, amp);
      float lAudio = outxp[i];
      scope.vertex(x, lAudio);
    }
    scope.endShape();
    scope.stroke(yc);
    scope.beginShape();
    for (int i = 0; i < outyp.length; i++)
    {
      float x = map(i, 0, outyp.length, -amp, amp);
      float rAudio = outyp[i];
      scope.vertex(x, rAudio);
    }
    scope.endShape();
  }
  scope.popMatrix();
  scope.endDraw();
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
  image(scope, h+o, h-o/2-g, g, g);
}

void mousePressed() {
  if (mouseX < h)
    changeFreq = true;
}

void mouseReleased() {
  changeFreq = false;
}

void mouseDragged() {
  if (changeFreq) {
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
}

void updateFreq() {
  xwave.setFrequency(xfreq);
  xtf.setValue(nf(xfreq, 2, 2));
  ywave.setFrequency(yfreq);
  ytf.setValue(nf(yfreq, 2, 2));
}

void liveUpdates() {
  if (xtf.isActive()) {
    if (float(xtf.getText()) >0) {
      xfreq = float(xtf.getText());
      //updatePhase();
      xwave.setFrequency(xfreq);
      selInput = 1;
    }
  } else if (ytf.isActive()) {
    if (float(ytf.getText()) > 0) {
      yfreq = float(ytf.getText());
      ywave.setFrequency(yfreq);
      selInput = 2;
    }
  } else if (xtp.isActive()) {
    if (xtp.getText() != "") {
      xphase = float(xtp.getText());
      xwave.setPhase(map(constrain(xphase, 0, 360), 0, 360, 0, 1));
    }
  }
}

void updateBands() {
  for (int i = 0; i < out.bufferSize (); i++)
  {
    float lAudio = out.left.get(i)*amp;
    float rAudio = out.right.get(i)*amp;
    outxp[i] = lAudio;
    outyp[i] = rAudio;
  }
}

void updatePhase() {
  xwave.setPhase(map(constrain(xphase, 0, 360), 0, 360, 0, 1));
  xtp.setValue(nf(int(xphase), 1, 0));
  ywave.setPhase(map(constrain(yphase, 0, 360), 0, 360, 0, 1));
  ytp.setValue(nf(int(yphase), 1, 0));
  xps.setBroadcast(false);
  xps.setValue(xphaseShift);
  xps.setBroadcast(true);
}

void keyPressed() {
  println(keyCode);

  freqMod = .01;
  if (shifted)
    freqMod = .25;

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
      yfreq+=freqMod;
      updateFreq();
      break;
    case 40:
      yfreq-=freqMod;
      updateFreq();
      break;
    case 88: // x
      if (xyMode) {
        xyMode = false;
        txy.setValue(false);
      } else {
        xyMode = true;
        txy.setValue(true);
      }
      break;
    case 80: // p
      if (pauseScope) {
        pauseScope = false;
        tpause.setValue(false);
      } else {
        pauseScope = true;
        tpause.setValue(true);
      }
      break;
    case 16: // SHIFT
      shifted = true;
      break;
    case 9:
      cycleInputs();
      break;
    default: 
      break;
    }
  }
}

void keyReleased() {
  if (keyCode == 16) {
    shifted = false;
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