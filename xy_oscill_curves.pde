/*  xy_oscill_curves v.01
 cc teddavis.org 2015 */

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
float o, w, h, g;


color xc = color(225, 0, 0);
color yc = color(200, 200, 0);
color oc = color(128, 255, 128);
color dc = color(150);

//SCOPE
PGraphics scope;

boolean displayScope = true;
boolean glowScope = true;
boolean xyMode = true;
boolean xPhaseShift = false;
boolean yPhaseShift = false;
float phaseShift = .01;

int cSize = 8;

//CONTROLS
import controlP5.*;
ControlP5 cp5;
Textfield xtf, ytf, xtp, ytp, fmint, fmaxt;
DropdownList xd, yd, dSettings;
Toggle tphase, tscope, txy, tglow;
Button bLoad, bSave;
Numberbox ps;
String[] waveTypes = {
  "SINE", "SQUARE", "TRIANGLE", "SAW", "QUARTERPULSE"
};
Wavetable[] waveTables = {
  Waves.SINE, Waves.SQUARE, Waves.TRIANGLE, Waves.SAW, Waves.QUARTERPULSE
};

//settings
String settingsDir, psettingsDir;
String[] settingsList;
String curSetting;
int dMatch = 0;

void setup() {
  size(900, 600);
  //size(displayWidth,displayHeight);
  o = border;
  w = width-o;
  h = height-o;
  g = w-h-o*2;
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
  scope = createGraphics(int(g), int(g));
}

void draw() {
  background(0);
  showGrid();
  showFreq();
  if (displayScope)
    showScope();
  if (xPhaseShift || yPhaseShift) {
    if (xPhaseShift) {
      xphase += phaseShift;
      if (xphase >360)
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

  // SETTINGS
  int settingsOffset = int(o);
  cp5.addTextlabel("SETTINGS")
    .setText("SETTINGS")
      .setPosition(h+o/2, settingsOffset)
        .setColorValue(color(255))
          .setFont(font)
            ;
  bSave = cp5.addButton("saveSettings")
    .setPosition(h+o, settingsOffset+o)
      .setSize(30, 20)
        .setLabel("save")
          ;

  bLoad = cp5.addButton("loadSettings")
    .setPosition(h+o*2.5, settingsOffset+o)
      .setSize(30, 20)
        .setLabel("load")
          ;

  int gridOffset = int(o*3);

  cp5.addTextlabel("GRID")
    .setText("RANGE")
      .setPosition(h+o/2, gridOffset)
        .setColorValue(color(255))
          .setFont(font)
            ;

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
        .setFont(font)
          .setAutoClear(false)
            .setLabel("x - frequency")
              ;
  xtf.setValue(nf(xfreq, 2, 2));

  int phaseOffset = int(freqOffset+o*4);

  //PHASE
  cp5.addTextlabel("PHASE")
    .setText("PHASE")
      .setPosition(h+o/2, phaseOffset)
        .setColorValue(color(255))
          .setFont(font)
            ;

  xtp = cp5.addTextfield("xphaset")
    .setPosition(h+o, phaseOffset+o)
      .setSize(int(tw*.25), 20)
        .setFont(font)
          .setAutoClear(false)
            .setLabel("phase")
              ;
  xtp.setValue(nf(xphase, 3, 0));

  tphase = cp5.addToggle("xPhaseShift")
    .setPosition(h+o+tw*.8, phaseOffset+o)
      .setSize(20, 20)
        .setLabel("shift")
          ;

  ps = cp5.addNumberbox("phaseShift")
    .setPosition(h+o+tw*.35, phaseOffset+o)
      .setSize(int(tw*.35), 20)
        .setLabel("speed")
          .setRange(0, 180)
            .setMultiplier(0.01) // set the sensitifity of the numberbox
              //.setDirection(cp5.HORIZONTAL)
              ;
  ps.setValue(phaseShift);
  updatePhase();


  ytf = cp5.addTextfield("yfreqt")
    .setPosition(h+o*2+tw, freqOffset+o*2)
      .setSize(tw, 20)
        .setFont(font)
          .setAutoClear(false)
            .setLabel("y - frequency")
              ;
  ytf.setValue(nf(yfreq, 2, 2));


  // SCOPE
  cp5.addTextlabel("SCOPE")
    .setText("SCOPE")
      .setPosition(h+(o/2*3)+tw, phaseOffset)
        .setColorValue(color(255))
          .setFont(font)
            ;

  tscope = cp5.addToggle("displayScope")
    .setPosition(h+o*2+tw, phaseOffset+o)
      .setSize(20, 20)
        .setLabel("display")
          ;

  txy = cp5.addToggle("xyMode")
    .setPosition(h+o*2+tw*1.5, phaseOffset+o)
      .setSize(20, 20)
        .setLabel("xy")
          ;

  tglow = cp5.addToggle("glowScope")
    .setPosition(h+o*2+tw*2, phaseOffset+o)
      .setSize(20, 20)
        .setLabel("glow")
          ;

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
    .setPosition(h+o, freqOffset+o*1.75)
      .setSize(tw, 200);

  ;
  dropdownWave(xd);

  yd = cp5.addDropdownList("ywaved")
    .setPosition(h+o*2+tw, freqOffset+o*1.75)
      .setSize(tw, 200);

  ;
  dropdownWave(yd);

  //settings dropdown
  dSettings = cp5.addDropdownList("dSettings")
    .setPosition(h+o*2+tw, settingsOffset+o*1.9)
      .setSize(tw, 200)
        .setBarHeight(20)
          .setItemHeight(20)
            .setLabel("Settings")
              .setVisible(false)
            ;
   dSettings.captionLabel().style().marginTop = 5;
   dSettings.setColorActive(color(255, 128));
   dSettings.setBackgroundColor(color(190));

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
  //println(theEvent.getName());
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
    yphase = float(ytp.getStringValue())/360;
    updatePhase();
  } else if (theEvent.getName() == "fmint") {
    freqMin = int(fmint.getStringValue());
    fmint.setFocus(false);
  } else if (theEvent.getName() == "fmaxt") {
    freqMax = int(fmaxt.getStringValue());
    fmaxt.setFocus(false);
  }else if  (theEvent.getName() == "dSettings"){
    int setSel = int(theEvent.getValue());
    //println(settingsList[setSel]);
    //if(curSetting.equals(settingsList[setSel])){
    File lSet = new File(settingsDir+"/"+settingsList[setSel]);
    loadSelected(lSet);
    //}
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


void saveSettings() {
  selectOutput("Store settings:", "saveSelected");
  //settings {rmin, rmax, xfreq, yfreq, xwavetype, ywavetype, phase, phaseshift}
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
    "phaseShift="+nf(phaseShift, 1, 3), 
    "xPhaseShift="+str(xPhaseShift), 
    "displayScope="+str(displayScope), 
    "xyMode="+str(xyMode), 
    "glowScope="+str(glowScope)
    };
    //saveStrings("data/settings.txt", sSettings);
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
  phaseShift = float(split(lSettings[7], "=")[1]);
  tphase.setValue(boolean(split(lSettings[8], "=")[1]));
  tscope.setValue(boolean(split(lSettings[9], "=")[1]));
  txy.setValue(boolean(split(lSettings[10], "=")[1]));
  tglow.setValue(boolean(split(lSettings[11], "=")[1]));
  updateFreq();
  updatePhase();
  settingsDir = selection.getParent();
  curSetting = selection.getName();
  //println(curSetting);
    updateSettings();

}

void updateSettings(){
  dSettings.clear();
  dMatch = 0;
  File dir = new File(settingsDir);
  settingsList = dir.list();
  if (settingsList != null) {
    for(int i=0;i<settingsList.length;i++){
      if(!settingsList[i].equals(".DS_Store")){
        String[] item = split(settingsList[i],".txt");
        dSettings.addItem(item[0],i);
      }
       if(curSetting.equals(settingsList[i])){
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

public void mouseWheelMoved(java.awt.event.MouseWheelEvent e) {
  super.mouseWheelMoved(e);
  cp5.setMouseWheelRotation(e.getWheelRotation());
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
  text("x - frequency", h/2, o*.5);

  fill(yc);
  if (xyMode)
    fill(dc);

  pushMatrix();
  translate(o+5, 0);
  rotate(radians(90));
  text("y - frequency", h/2, o*.5);
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
  float amp = h*.40;
  scope.beginDraw();
  scope.smooth();
  scope.noStroke();
  if (glowScope) {
    scope.fill(0, 32, 0, 32);
  } else {
    scope.background(0, 32, 0);
  }
  scope.rect(0, 0, scope.width, scope.height);
  scope.noFill();
  scope.strokeWeight(1);
  //scope.stroke(255);
  //scope.noFill();
  //line(mouseX,mouseY,pmouseX,pmouseY);
  scope.pushMatrix();
  scope.translate(g/2, g/2);
  if (xyMode) {
    scope.stroke(oc);
    scope.beginShape();
    for (int i = 0; i < out.bufferSize (); i++)
    {
      float x = map(i, 0, out.bufferSize(), -amp/2, amp/2);
      float y = map(i, 0, out.bufferSize(), -amp/2, amp/2);
      float lAudio = out.left.get(i)*amp;
      float rAudio = out.right.get(i)*amp;
      scope.vertex(lAudio, rAudio);
    }
    scope.endShape();
  } else {
    scope.stroke(xc);
    scope.beginShape();
    for (int i = 0; i < out.bufferSize (); i++)
    {
      float x = map(i, 0, out.bufferSize(), -amp/2, amp/2);
      float lAudio = out.left.get(i)*amp;
      scope.vertex(x, lAudio);
    }
    scope.endShape();
    scope.stroke(yc);
    scope.beginShape();
    for (int i = 0; i < out.bufferSize (); i++)
    {
      float x = map(i, 0, out.bufferSize(), -amp/2, amp/2);
      float rAudio = out.right.get(i)*amp;
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
  xwave.setPhase(map(constrain(xphase, 0, 360), 0, 360, 0, 1));
  xtp.setValue(nf(int(xphase), 1, 0));
  ps.setBroadcast(false);
  ps.setValue(phaseShift);
  ps.setBroadcast(true);
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

