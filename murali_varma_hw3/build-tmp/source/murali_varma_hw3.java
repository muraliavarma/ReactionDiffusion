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
int NUM_HORIZONTAL_CELLS = 120;
int NUM_VERTICAL_CELLS = 120;
int CELL_HEIGHT = 5;
int CELL_WIDTH = 5;
int CONTROLS_WIDTH = 200;
int FRAMES_TO_SKIP = 5;

float RU = 0.082f;
float RV = 0.041f;

int U_MODE = 0;
int V_MODE = 1;

int RD_MODE = 0;	//reaction and diffusion
int D_MODE = 1;	//diffusion alone

int CONSTANT_MODE = 0;
int VARYING_PARAMETER_MODE = 1;

float f = 0.035f;
float k = 0.0625f;
float dt = 2;

int frames = 0;
boolean paused = false;

//variables
float[][] u;
float[][] v;
int[][] neighbors = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}};

int uvMode = U_MODE;
int rdMode = RD_MODE;
int pMode = CONSTANT_MODE;

float minColor;
float maxColor;

public void setup() {
	setDefaultParams();
	size(NUM_HORIZONTAL_CELLS * CELL_WIDTH + CONTROLS_WIDTH, NUM_VERTICAL_CELLS * CELL_HEIGHT);
	background(0);
	noStroke();
}

public void initCells() {
	u = new float[NUM_VERTICAL_CELLS][NUM_HORIZONTAL_CELLS];
	v = new float[NUM_VERTICAL_CELLS][NUM_HORIZONTAL_CELLS];

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
				u[i][j] = 1.0f;
				v[i][j] = 0.0f;
			}
		}
	}
}

public void draw() {
	frames ++;
	doDiffusion();
	if (rdMode == RD_MODE) {
		if (pMode == CONSTANT_MODE) {
			doReaction();
		}
		else {
			doVaryingReaction();
		}
	}
	if (frames % FRAMES_TO_SKIP == 0) {
		frames = 0;
		setColorRange();
		drawCells();
	}
}

public void setColorRange() {
	minColor = 10000;
	maxColor = 0;
	if (uvMode == U_MODE) {
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
			else if (uvMode == U_MODE){
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
			for (int l = 0; l < neighbors.length; l++) {
				int y = (i + neighbors[l][1] + NUM_VERTICAL_CELLS) % NUM_VERTICAL_CELLS;
				int x = (j + neighbors[l][0] + NUM_HORIZONTAL_CELLS) % NUM_HORIZONTAL_CELLS;
				sumU += u[y][x];
				sumV += v[y][x];
			}
			u2[i][j] = u[i][j] + dt * RU * (sumU - 4 * u[i][j]);
			v2[i][j] = v[i][j] + dt * RV * (sumV - 4 * v[i][j]);
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

public void doReaction() {
	for (int i = 0; i < NUM_VERTICAL_CELLS; i++) {
		for (int j = 0; j < NUM_HORIZONTAL_CELLS; j++) {
			float uvv = u[i][j] * v[i][j] * v[i][j];
			u[i][j] += dt * (-1 * uvv + f * (1 - u[i][j]));
			v[i][j] += dt * (uvv - v[i][j] * (f + k));
		}
	}
}
public void doVaryingReaction() {
	for (int i = 0; i < NUM_VERTICAL_CELLS; i++) {
		float currF = 0.08f * (1.0f - (1.0f * i / NUM_VERTICAL_CELLS));
		for (int j = 0; j < NUM_HORIZONTAL_CELLS; j++) {
			float currK = 0.03f + ((0.04f * j) / NUM_HORIZONTAL_CELLS);
			float uvv = u[i][j] * v[i][j] * v[i][j];
			u[i][j] += dt * (-1 * uvv + currF * (1 - u[i][j]));
			v[i][j] += dt * (uvv - v[i][j] * (currF + currK));
			// println("i: " + i + ", j: " + j + ", u: " + u[i][j] + ", v: " + v[i][j] + ", f: " + currF + ", k: " + currK);
		}
	}
}

public void keyPressed() {
	if (key == 'i' || key == 'I') {
		initCells();
	}

	if (key == 'u' || key == 'U') {
		uvMode = U_MODE;
	}
	else if (key == 'v' || key == 'V') {
		uvMode = V_MODE;
	}

	if (key == 'd' || key == 'D') {
		if (rdMode == RD_MODE) {
			rdMode = D_MODE;
		}
		else {
			rdMode = RD_MODE;
		}
	}

	if (key == 'p' || key == 'P') {
		if (pMode == CONSTANT_MODE) {
			rdMode = RD_MODE;
			pMode = VARYING_PARAMETER_MODE;
			setVaryingParams();
		}
		else {
			setDefaultParams();
			pMode = CONSTANT_MODE;
		}
	}

	if (key == ' ') {
		if (paused) {
			loop();
		}
		else {
			noLoop();
		}
		paused = !paused;
	}

	if (key == '1') {
		f = 0.035f;
		k = 0.0625f;
	}
	else if (key == '2') {
		f = 0.035f;
		k = 0.06f;
	}
	else if (key == '3') {
		f = 0.0118f;
		k = 0.0475f;
	}
	else if (key == '4') {
		f = 0.054f;
		k = 0.063f;
	}
}

public void setDefaultParams() {
	NUM_HORIZONTAL_CELLS = 120;
	NUM_VERTICAL_CELLS = 120;
	CELL_WIDTH = 5;
	CELL_HEIGHT = 5;
	f = 0.035f;
	k = 0.0625f;
	initCells();
}

public void setVaryingParams() {
	NUM_HORIZONTAL_CELLS = 300;
	NUM_VERTICAL_CELLS = 300;
	CELL_WIDTH = 2;
	CELL_HEIGHT = 2;
	initCells();	
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
