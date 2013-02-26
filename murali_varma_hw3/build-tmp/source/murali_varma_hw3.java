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

float RU = 0.082f;
float RV = 0.041f;

int U_MODE = 0;
int V_MODE = 1;

//variables
float[][] u;
float[][] v;
int[][] neighbors = {{-1, -1}, {-1, 1}, {1, -1}, {1, 1}};

int mode = U_MODE;

float minColor = 10000;
float maxColor = 0;

public void setup() {
	frameRate(1);
	size(NUM_HORIZONTAL_CELLS * CELL_WIDTH + CONTROLS_WIDTH, NUM_VERTICAL_CELLS * CELL_HEIGHT);
	background(0);
	noStroke();

	//initialize variables
	u = new float[NUM_VERTICAL_CELLS][NUM_HORIZONTAL_CELLS];
	v = new float[NUM_VERTICAL_CELLS][NUM_HORIZONTAL_CELLS];

	initCells();
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
	doDiffusion();
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

public void doDiffusion() {
	float[][] u2 = new float[NUM_VERTICAL_CELLS][NUM_HORIZONTAL_CELLS];
	float[][] v2 = new float[NUM_VERTICAL_CELLS][NUM_HORIZONTAL_CELLS];

	for (int i = 0; i < NUM_VERTICAL_CELLS; i++) {
		for (int j = 0; j < NUM_HORIZONTAL_CELLS; j++) {
			float sumU = 0;
			float sumV = 0;
			for (int k = 0; k < neighbors.length; k++) {
				int y = (i + neighbors[k][1] + NUM_VERTICAL_CELLS) % NUM_VERTICAL_CELLS;
				int x = (j + neighbors[k][0] + NUM_HORIZONTAL_CELLS) % NUM_HORIZONTAL_CELLS;
				sumU += u[y][x];
				sumV += v[y][x];
			}
			u2[i][j] = RU * (sumU - 4 * u[i][j]);
			v2[i][j] = RV * (sumV - 4 * v[i][j]);
			if (i == 20 && j == 20)
			println(i + ", " + j + ", " + u2[i][j]);
		}
	}
	//copy new array values into original array
	for (int i = 0; i < NUM_VERTICAL_CELLS; i++) {
		for (int j = 0; j < NUM_HORIZONTAL_CELLS; j++) {
			u[i][j] = u2[i][j];
			v[i][j] = v2[i][j];
		}
	}
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
