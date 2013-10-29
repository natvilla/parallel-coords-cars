// Author: Natalee Villa
// For: CS 6630, Fall 2013
// Parallel Coordinates
// Date: Oct 22, 2013

// full dataset
FloatTable data;
float dataMin, dataMax;
float colMin[], colMax[];

float plotX1, plotY1;
float plotX2, plotY2;
float labelX, labelY;
float lineTop;

int axisColor;
int lineColor;

int rowCount;
int columnCount;
int currentColumn = 1;

float axisPosX[];
int colToMove = -1;
int axisToHighlight = -1;
float yHighStart[];
float yHighFinish[];
boolean isDraggingBox[];
boolean highlightRow[];

float axisLblY;
float axisLblLeft[];
float axisLblRight[];
float axisMoveLeft[];
float axisMoveRight[];
boolean axisIsFlipped[];

PImage crosshairs;      // 20x20 px

KClusters kc;
int k = 6;
color[] kPalette;
boolean showClusters;

float plotSize;
PFont plotFont;

String origin[];

// setup loop (runs once)
void setup() {
  size(1200, 600);
  //size(1600, 800);
  
  // import data
  //data = new FloatTable("stations-data.tsv");
  data = new FloatTable("Cars-data-nonames.tsv");
  columnCount = data.getColumnCount();
  rowCount = data.getRowCount();
  
  crosshairs = loadImage("target_32.png");
  
  // assign data variables
  initializeVars();
  
  origin = new String[] {
    "USA",
    "Japan",
    "Europe"
  };
  
  smooth();
  
}// setup()

void initializeVars() {
  colMin = new float[columnCount];
  colMax = new float[columnCount];
  
//  println("col count: "+columnCount);
//  println("row count: "+rowCount);
  
  getColMinMax();
  
  axisPosX = new float[columnCount];
  axisLblLeft = new float[columnCount];
  axisLblRight = new float[columnCount];
  axisMoveLeft = new float[columnCount];
  axisMoveRight = new float[columnCount];
  axisIsFlipped = new boolean[columnCount];
  yHighStart = new float[columnCount];
  yHighFinish = new float[columnCount];
  isDraggingBox = new boolean[columnCount];
  highlightRow = new boolean[rowCount];
  
  kc = new KClusters(k, data);
  kPalette = new color[k];

  kPalette[0] = color(200, 0, 0);
  kPalette[1] = color(0, 200, 0);
  kPalette[2] = color(0, 0, 200);
  kPalette[3] = color(200, 200, 0);
  kPalette[4] = color(0, 200, 200);
  kPalette[5] = color(200, 0, 200);

  // blue/green pal
//  kPalette[0] = #282938;
//  kPalette[1] = #2a505f;
//  kPalette[2] = #247b79;
//  kPalette[3] = #47a77e;
//  kPalette[4] = #90ce73;
//  kPalette[5] = #efee69;
// colorblind pal
//  kPalette[0] = #d73027;
//  kPalette[1] = #fc8d59;
//  kPalette[2] = #efee69;
//  kPalette[3] = #e0f3f8;
//  kPalette[4] = #918fd8;
//  kPalette[5] = #4575b4;
// rainbow
//  kPalette[0] = #39536e;
//  kPalette[1] = #1d9c7f;
//  kPalette[2] = #4abba1;
//  kPalette[3] = #f0c115;
//  kPalette[4] = #e44133;
//  kPalette[5] = #ba3427;

// att pal
//  kPalette[0] = #80017e;
//  kPalette[1] = #7dc6ff;
//  kPalette[2] = #6dba1f;
//  kPalette[3] = #efee69;
//  kPalette[4] = #057ab4;
//  kPalette[5] = #ff7300;
  showClusters = true;
  
  // corners of the plotted time series
  plotX1 = 120;
  plotX2 = width - 80;
  labelX = 50;
  plotY1 = 60;
  plotY2 = height - 70;
  labelY = height - 25;
  
  // top of the lines
  float lnMargin = (plotY2-plotY1)*0.1;
  lineTop = plotY1+lnMargin;
  
  plotSize = ((plotX2 - plotX1)/(columnCount-1));
  axisColor = #000000;
  lineColor = #417d94;
  
  initAxisPos();
  
}// initializeVars()

void getColMinMax() {
  // get data mins/maxes for each column axis
  colMin[0] = 0;
  colMax[0] = 0;
  for (int col = 0; col < columnCount; col++) {
    colMin[col] = data.getColumnMin(col);
    colMax[col] = data.getColumnMax(col);
  }
}// getColMinMax()

// draw loop (runs infinitely)
void draw() {
  
  // background color white
  background(255);
  
  // show the plot area as a white box
  fill(255);
  rectMode(CORNERS);
  noStroke();
  rect(plotX1, plotY1, plotX2, plotY2);
  
  // draw title of current plot
  drawTitle();
  // draw axes
  drawAxes();
  
  drawAllLines();
  drawClusterBox();
  
  axisToHighlight = mouseOverAxis();
  updateHighlightBox();

}// draw()

void drawClusterBox() {
    stroke(#000000);
    strokeWeight(1);
    rect(plotX2-16, 30, plotX2, 46); 
    
    fill(#000000);
    
    if (showClusters) {
      plotFont = createFont("Verdana", 16);
      textFont(plotFont);
      textAlign(CENTER);
      text("X", plotX2-8, 45);
    }
    
    plotFont = createFont("Verdana", 10);
    textFont(plotFont);
    textAlign(RIGHT);
    String label = "Show Clusters";
    float sw = textWidth(label);
    text(label, plotX2-21, 40);
    
    noStroke();
    noFill();
}// drawClusterBox()

int mouseOverAxis() {
  if (colToMove > -1) {
    return -1;
  }
  if (axisToHighlight > -1 && isDraggingBox[axisToHighlight]) {
    return axisToHighlight;
  }
   for (int col = 0; col < columnCount; col++) {
      if (mouseX >= axisPosX[col]-5 && mouseX <= axisPosX[col]+5
        && mouseY < plotY2+5 && mouseY > lineTop-5) {
        cursor(CROSS);
        return col;
      } else {
        if (colToMove <= -1) {
          cursor(ARROW);
        }
      }
   }
   return -1;
}// mouseOverAxis()

void drawAllLines() {
  
  boolean highlightIsOn = false;
  for (int row = 0; row < rowCount; row++) {
    if (highlightRow(row)) {
      highlightIsOn = true;
    }
  }
  for (int col = 0; col < columnCount; col++) {
    if (yHighStart[col] != yHighFinish[col]) {
      highlightIsOn = true;
    }
  }
  
  for (int row = 0; row < rowCount; row++) {
    beginShape();
    
    boolean hr = highlightRow(row);
    int cluster = kc.getCluster(row);
    noFill();
    
    if (hr) {
      continue;
    } else {
      // if any rows are highlighted, make other lines grey
      if (highlightIsOn) {
        stroke(#bbbbbb, 50);
      } else if (showClusters) {
        stroke(kPalette[cluster], 50);
      } else {
        stroke(lineColor, 50);
      }
      strokeWeight(1);
    }
    
    for (int col = 0; col < columnCount; col++) {
      if (data.isValid(row, col)) {
        float value = data.getFloat(row, col);
        float x = xValForCol(col);
        float y = 0.0;
        if (axisIsFlipped[col]) {
          y = map(value, colMax[col], colMin[col], plotY2, lineTop);
        } else {
          y = map(value, colMin[col], colMax[col], plotY2, lineTop);
        }      
        vertex(x, y);
      }
    }// inner for
    endShape();
  }// outer for
  
  // draw highlited lines on top
  drawHighlightedLines();
}// drawAllLines()

void drawHighlightedLines() {
  
  for (int row = 0; row < rowCount; row++) {
    beginShape();
    
    boolean hr = highlightRow(row);
    int cluster = kc.getCluster(row);
    noFill();
    
    if (hr) {
      if (showClusters) {
        stroke(kPalette[cluster], 255);
      } else {
        stroke(#325f71, 255);
      }
      strokeWeight(2);
    } else {
      continue;
    }
    
    for (int col = 0; col < columnCount; col++) {
      if (data.isValid(row, col)) {
        float value = data.getFloat(row, col);
        float x = xValForCol(col);
        float y = 0.0;
        if (axisIsFlipped[col]) {
          y = map(value, colMax[col], colMin[col], plotY2, lineTop);
        } else {
          y = map(value, colMin[col], colMax[col], plotY2, lineTop);
        }
        vertex(x, y);
      }
    }// inner for
    endShape();
  }// outer for
}// drawAllLines()

boolean highlightRow(int row) {  
    boolean highlight = false;
    for (int col = 0; col < columnCount; col++) {
      float y = 0.0;
      if (data.isValid(row, col)) {
        float value = data.getFloat(row, col);
        if (axisIsFlipped[col]) {
          y = map(value, colMax[col], colMin[col], plotY2, lineTop);
        } else {
          y = map(value, colMin[col], colMax[col], plotY2, lineTop);
        }
      }
        
      if (yHighStart[col] > 0 && yHighFinish[col] > 0) {
          if ( (y > yHighStart[col] && y < yHighFinish[col]) 
            || (y < yHighStart[col] && y > yHighFinish[col]) ) {
              highlight = true;
          } else {
              highlight = false;
              break;
          }
      } 
   }// inner for
   return highlight;
   
}// highlightRow()

float xValForCol(int col) {
  return axisPosX[col];
}// xValForCol()

void initAxisPos() {
  for (int line = 0; line < columnCount; line++) {
     float x = plotSize*line + plotX1;
     axisPosX[line] = x; 
  }

}// initAxisPos()

void drawAxes() {
  
  for (int line = 0; line < columnCount; line++) {
    fill(0);
    textSize(10);
    textAlign(RIGHT);
    stroke(axisColor);
    strokeWeight(2);
  
    plotFont = createFont("Georgia", 10);
    textFont(plotFont);
    
    noFill();
    renderAxis(line);    
  }
}// drawAxes()

// renders axis of column 'line'
void renderAxis(int line) {
    // draw axis lines & labels   
    float x = axisPosX[line];
    line(x, lineTop, x, plotY2);
    
    // col labels
    textAlign(CENTER);
    axisLblY = lineTop-25;
    
    String label = data.getColumnName(line);
    float sw = textWidth(label);
    text(label, x, axisLblY);
    axisLblLeft[line] = x - sw/2-5;
    axisLblRight[line] = x + sw/2+5;
    
    float triHt = axisLblY - textAscent()/2.0;
    fill(#000000);
    if (axisIsFlipped[line])
      triangle(axisLblRight[line]+4, triHt, axisLblRight[line]+8, axisLblY-2, axisLblRight[line]+12, triHt);
    else 
      triangle(axisLblRight[line]+4, axisLblY-2, axisLblRight[line]+8, triHt, axisLblRight[line]+12, axisLblY-2);
    noFill();
    
    // draw move rect, xy = ul
    stroke(#000000);
    strokeWeight(1);
    rect(x-12, plotY2+15, x+12, plotY2+39);
    image(crosshairs, x-10, plotY2+17);
    axisMoveLeft[line] = x-10;
    axisMoveRight[line] = x+10;

    strokeWeight(2);
    
    // draw tick marks
    float max = colMax[line];
    float min = colMin[line];
    float interval = (ceil(max) - floor(min))/10.0;

    if (isCyl(line) || isYear(line) || isOrigin(line)) {
      interval = 1;
    } 
    
    // draw ticks labels & marks
    for (float v = min; v <= max; v += interval) {
        float y = 0.0;
        if (axisIsFlipped[line]) {
          y = map(v, max, min, plotY2, lineTop);
        } else {
          y = map(v, min, max, plotY2, lineTop);
        }
        if (v == min) { // if major tick mark
          textAlign(RIGHT); // align by the bottom
        } else if (v == max) {
          textAlign(RIGHT, CENTER); // align by the top
        } else {
          textAlign(RIGHT, CENTER); // align by the top
        }

        line(x - 5, y, x, y);
        
        if (isOrigin(line)) {
          int index = (int)(v-1);
          text(origin[index], x-12, y);
        } else {
          text(roundToTenth(v), x-12, y);
        }
      
    }// for 
    
    drawHighlightBox(line);
}// renderAxis()

// rounds 'num' to nearest tenth
String roundToTenth(float num) {
  return nf(round(num*10.0)/10.0, 0, 1);
}// roundToTenth()

boolean isCyl(int col) {
  if (data.getColumnName(col).equals("Cylinders")) {
    return true;
  }
  return false;
}
boolean isYear(int col) {
  if (data.getColumnName(col).equals("Year")) {
    return true;
  }
  return false;
}
boolean isOrigin(int col) {
  if (data.getColumnName(col).equals("Origin")) {
    return true;
  }
  return false;
}

void drawHighlightBox(int col) {
  if (!isDraggingBox[col]) {
    if (yHighStart[col] > 0 && yHighFinish[col] > 0) {
      fill(#000000, 100);
      noStroke();
      rect(axisPosX[col]-25, yHighStart[col], axisPosX[col]+25, yHighFinish[col]);
      noFill();
      stroke(#000000);
    }
  }
}// drawHighlightBox()

void updateHighlightBox() {
  if (axisToHighlight > -1) {
    fill(#000000, 100);
    noStroke();
    rect(axisPosX[axisToHighlight]-25, yHighStart[axisToHighlight], axisPosX[axisToHighlight]+25, yHighFinish[axisToHighlight]);
    noFill();
    stroke(#000000);
  }
}// updateHighlightBox()

void drawTitle() {
  fill(0);
  textAlign(LEFT);
  
  plotFont = createFont("Verdana", 20);
  textFont(plotFont);
  
  String title = "Cars 1970-1982"; 
  
  text(title, plotX1, plotY1 - 20);
  
}// drawTitle()

// mouse click events
void mousePressed() {

  // if user clicks label, flip axis
  if (mouseY > axisLblY-textAscent() && mouseY < axisLblY) {
    for (int col = 0; col < columnCount; col++) {
      if (mouseX > axisLblLeft[col] && mouseX < axisLblRight[col]+15) {
        flipAxis(col);
        break;
      }
    }
  }
  
  // if user clicks move axis
  if (mouseY > plotY2+15 && mouseY < plotY2+40) {
    for (int col = 0; col < columnCount; col++) {
      if (mouseX > axisMoveLeft[col] && mouseX < axisMoveRight[col]) {
        colToMove = col;
        cursor(MOVE);
        break;
      }
    }
  } else {
    colToMove = -1;
    cursor(ARROW);
  }
  
  // show clusters box = rect(plotX2-16, 30, plotX2, 46);
  if (mouseX < plotX2 && mouseX > plotX2-16 && mouseY > 30 && mouseY < 46) {
    showClusters = !showClusters;
  }
    
  if (axisToHighlight > -1) {
    yHighStart[axisToHighlight] = mouseY;
  }
  
}// mousePressed()

void mouseDragged() {
  if (colToMove > -1) {       
    moveAxis(colToMove);
  }
  
  if (axisToHighlight > -1) {
    isDraggingBox[axisToHighlight] = true;
    yHighFinish[axisToHighlight] = mouseY;
  }

}// mouseDragged()

void mouseReleased() {
  colToMove = -1;
  cursor(ARROW);
  
  if (axisToHighlight > -1) {
    yHighFinish[axisToHighlight] = mouseY;
    isDraggingBox[axisToHighlight] = false;
    
    if (yHighFinish[axisToHighlight] == yHighStart[axisToHighlight]) {
      yHighFinish[axisToHighlight] = 0;
      yHighStart[axisToHighlight] = 0;
    }
    axisToHighlight = -1;
  }
  
}// mouseReleased()

// denote axis as flipped
void flipAxis(int col) {
  axisIsFlipped[col] = !axisIsFlipped[col];
  
}// flipAxis()

// update axis position
void moveAxis(int col) {
  if (mouseX <= plotX1) {
    axisPosX[col] = plotX1;
  } 
  else if (mouseX >= plotX2) {
    axisPosX[col] = plotX2;
  }
  else if (col < columnCount-1 && mouseX >= axisPosX[col+1]) {
    swapColumns(col, col+1);
    colToMove = col+1;
  }
  else if (col > 0 && mouseX < axisPosX[col-1]) {
    swapColumns(col-1, col);
    colToMove = col-1;
  }
  else {
    axisPosX[col] = mouseX;
  }
  
}// moveAxis()

void swapColumns(int col1, int col2) {
    noLoop();
    data.swapColumnData(col1, col2);
    delay(1);
    getColMinMax();
    redraw();
    loop();
    
}// swapColumns()

void printData() {
  println(columnCount);
  for (int row = 0; row < rowCount; row++) {
    println();
    for (int col = 0; col < columnCount; col++) {
      if (data.isValid(row, col)) {
        print(data.getFloat(row, col) + "\t"); 
      }
    }
    println();
  }
  
}// printData()

void keyPressed() {
  if (key == ' ') {
    showClusters = !showClusters;
  } 
  
}// keyPressed()
