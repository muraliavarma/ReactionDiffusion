import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class murali_varma_hw3 extends PApplet {

//constants
int NUM_HORIZONTAL_CELLS = 100;
int NUM_VERTICAL_CELLS = 100;
int CELL_HEIGHT = 8;
int CELL_WIDTH = 8;
int CONTROLS_WIDTH = 200;

int U_MODE = 0;
int V_MODE = 1;

//variables
float[][] u;
float[][] v;

int mode = V_MODE;

float minColor = 10000;
float maxColor = 0;

public void setup() {
	size(NUM_HORIZONTAL_CELLS * CELL_WIDTH + CONTROLS_WIDTH, NUM_VERTICAL_CELLS * CELL_HEIGHT);
	background(0);
	noStroke();

	//initialize variables
	u = new float[NUM_VERTICAL_CELLS][NUM_HORIZONTAL_CELLS];
	v = new float[NUM_VERTICAL_CELLS][NUM_HORIZONTAL_CELLS];

	// initCells();
}

public void initCells() {
	int horizontalOffset = 20;
	int verticalOffset = 20;
	int blockWidth = 10;
	int blockHeight = 10;

	for(int i = 0; i < NUM_VERTICAL_CELLS; i++) {
		for(int j = 0; j < NUM_HORIZONTAL_CELLS; j++) {
			if (i >= verticalOffset && i < verticalOffset + blockHeight && j >= horizontalOffset && j < horizontalOffset + blockWidth) {
				u[i][j] = 0.5f;
				v[i][j] = 0.25f;
			}
			else {
				u[i][j] = 1;
				v[i][j] = 0;
			}
		}
	}
}

public void draw() {
	setColorRange();
	drawCells();
}

public void setColorRange() {
	if (mode == U_MODE) {
		for (int i = 0; i < NUM_VERTICAL_CELLS; i++) {
			for (int j = 0; j < NUM_HORIZONTAL_CELLS; j++) {
				minColor = min(minColor, u[i][j]);
				maxColor = max(maxColor, u[i][j]);
			}
		}	
	}
	else {
		for (int i = 0; i < NUM_VERTICAL_CELLS; i++) {
			for (int j = 0; j < NUM_HORIZONTAL_CELLS; j++) {
				minColor = min(minColor, v[i][j]);
				maxColor = max(maxColor, v[i][j]);
			}
		}	
	}
}

public void drawCells() {
	float range = maxColor - minColor;
	for (int i = 0; i < NUM_VERTICAL_CELLS; i++) {
		for (int j = 0; j < NUM_HORIZONTAL_CELLS; j++) {
			if (range == 0) {
				drawCell(i, j, 0.5f);
			}
			else if (mode == U_MODE){
				drawCell(i, j, (u[i][j] - minColor) / range);
			}
			else{
				drawCell(i, j, (v[i][j] - minColor) / range);
			}
		}
	}
}

public void drawCell(int i, int j, float col) {
	fill(255 * col);
	rect (CELL_WIDTH * j, CELL_HEIGHT * i, CELL_WIDTH, CELL_HEIGHT);
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "murali_varma_hw3" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
