//constants
int NUM_HORIZONTAL_CELLS = 120;
int NUM_VERTICAL_CELLS = 120;
int CELL_HEIGHT = 5;
int CELL_WIDTH = 5;
int CONTROLS_WIDTH = 200;

float RU = 0.082;
float RV = 0.041;

int U_MODE = 0;
int V_MODE = 1;
float f = 0.035;
float k = 0.0625;
float dt = 3;

//variables
float[][] u;
float[][] v;
int[][] neighbors = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}};

int mode = U_MODE;

float minColor;
float maxColor;

void setup() {
	// frameRate(100);
	size(NUM_HORIZONTAL_CELLS * CELL_WIDTH + CONTROLS_WIDTH, NUM_VERTICAL_CELLS * CELL_HEIGHT);
	background(0);
	noStroke();

	//initialize variables
	u = new float[NUM_VERTICAL_CELLS][NUM_HORIZONTAL_CELLS];
	v = new float[NUM_VERTICAL_CELLS][NUM_HORIZONTAL_CELLS];

	initCells();
}

void initCells() {
	int horizontalOffset = 20;
	int verticalOffset = 20;
	int blockWidth = 10;
	int blockHeight = 10;

	for(int i = 0; i < NUM_VERTICAL_CELLS; i++) {
		for(int j = 0; j < NUM_HORIZONTAL_CELLS; j++) {
			if (i >= verticalOffset && i < verticalOffset + blockHeight && j >= horizontalOffset && j < horizontalOffset + blockWidth) {
				u[i][j] = 0.5;
				v[i][j] = 0.25;
			}
			else {
				u[i][j] = 1.0;
				v[i][j] = 0.0;
			}
		}
	}
}

void draw() {
	doDiffusion();
	doReaction();
	setColorRange();
	drawCells();
}

void setColorRange() {
	minColor = 10000;
	maxColor = 0;
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

void drawCells() {
	float range = maxColor - minColor;
	for (int i = 0; i < NUM_VERTICAL_CELLS; i++) {
		for (int j = 0; j < NUM_HORIZONTAL_CELLS; j++) {
			if (range == 0) {
				drawCell(i, j, 0.5);
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

void drawCell(int i, int j, float col) {
	fill(255 * col);
	rect (CELL_WIDTH * j, CELL_HEIGHT * i, CELL_WIDTH, CELL_HEIGHT);
}

void doDiffusion() {
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

void doReaction() {
	for (int i = 0; i < NUM_VERTICAL_CELLS; i++) {
		for (int j = 0; j < NUM_HORIZONTAL_CELLS; j++) {
			float uvv = u[i][j] * v[i][j] * v[i][j];
			u[i][j] += dt * (-1 * uvv + f * (1 - u[i][j]));
			v[i][j] += dt * (uvv - v[i][j] * (f + k));
		}
	}
}