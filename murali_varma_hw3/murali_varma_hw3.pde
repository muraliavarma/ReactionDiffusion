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

int mode = U_MODE;

float minColor = 10000;
float maxColor = 0;

void setup() {
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
				u[i][j] = 1;
				v[i][j] = 0;
			}
		}
	}
}

void draw() {
	setColorRange();
	drawCells();
}

void setColorRange() {
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
