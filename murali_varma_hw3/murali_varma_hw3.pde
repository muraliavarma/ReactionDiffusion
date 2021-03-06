//constants
int NUM_HORIZONTAL_CELLS = 120;
int NUM_VERTICAL_CELLS = 120;
int CELL_HEIGHT = 5;
int CELL_WIDTH = 5;
int CONTROLS_WIDTH = 250;
int FRAMES_TO_SKIP = 5;

float RU = 0.082;
float RV = 0.041;

int U_MODE = 0;
int V_MODE = 1;

int RD_MODE = 0;	//reaction and diffusion
int D_MODE = 1;	//diffusion alone

int CONSTANT_MODE = 0;
int VARYING_PARAMETER_MODE = 1;

//variables
float f = 0.035;
float k = 0.0625;
float dt = 2;

int frames = 0;
boolean paused = false;
Button[] buttons;

float[][] u;
float[][] v;
int[][] neighbors = {{-1, 0}, {1, 0}, {0, -1}, {0, 1}};

int uvMode = U_MODE;
int rdMode = RD_MODE;
int pMode = CONSTANT_MODE;

float minColor;
float maxColor;
String cellDetails = "";

void setup() {
	setDefaultParams();
	size(NUM_HORIZONTAL_CELLS * CELL_WIDTH + CONTROLS_WIDTH, NUM_VERTICAL_CELLS * CELL_HEIGHT);
	background(0);
	noStroke();

	//GUI Stuff
	buttons = new Button[10];
	buttons[0] = new Button(20, 60, 120, 20, "Initialize", "I");
	buttons[1] = new Button(20, 100, 120, 20, "Show U Values", "U");
	buttons[2] = new Button(20, 140, 120, 20, "Show V Values", "V");
	buttons[3] = new Button(20, 180, 120, 20, "Play/Pause", "Space");
	buttons[4] = new Button(20, 220, 220, 20, "Toggle Reaction/Diffusion", "D");
	buttons[5] = new Button(20, 260, 220, 20, "Toggle Const/Varying Params", "P");
	buttons[6] = new Button(20, 340, 70, 20, "Spots", "1");
	buttons[7] = new Button(110, 340, 70, 20, "Stripes", "2");
	buttons[8] = new Button(20, 380, 70, 20, "Spirals", "3");
	buttons[9] = new Button(110, 380, 70, 20, "Maze", "4");
	drawControls();
}

void initCells() {
	u = new float[NUM_VERTICAL_CELLS][NUM_HORIZONTAL_CELLS];
	v = new float[NUM_VERTICAL_CELLS][NUM_HORIZONTAL_CELLS];

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
	if (!paused) {
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
}

void setColorRange() {
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

void drawCells() {
	float range = maxColor - minColor;
	for (int i = 0; i < NUM_VERTICAL_CELLS; i++) {
		for (int j = 0; j < NUM_HORIZONTAL_CELLS; j++) {
			if (range == 0) {
				drawCell(i, j, 0.5);
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
void doVaryingReaction() {
	for (int i = 0; i < NUM_VERTICAL_CELLS; i++) {
		float currF = 0.08 * (1.0 - (1.0 * i / NUM_VERTICAL_CELLS));
		for (int j = 0; j < NUM_HORIZONTAL_CELLS; j++) {
			float currK = 0.03 + ((0.04 * j) / NUM_HORIZONTAL_CELLS);
			float uvv = u[i][j] * v[i][j] * v[i][j];
			u[i][j] += dt * (-1 * uvv + currF * (1 - u[i][j]));
			v[i][j] += dt * (uvv - v[i][j] * (currF + currK));
		}
	}
}

void keyPressed() {
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
		swapMode("rd");
	}

	if (key == 'p' || key == 'P') {
		swapMode("p");
	}

	if (key == ' ') {
		paused = !paused;
		drawControls();
	}

	if (key == '1') {
		f = 0.035;
		k = 0.0625;
	}
	else if (key == '2') {
		f = 0.035;
		k = 0.06;
	}
	else if (key == '3') {
		f = 0.0118;
		k = 0.0475;
	}
	else if (key == '4') {
		f = 0.054;
		k = 0.063;
	}
}

void setDefaultParams() {
	NUM_HORIZONTAL_CELLS = 120;
	NUM_VERTICAL_CELLS = 120;
	CELL_WIDTH = 5;
	CELL_HEIGHT = 5;
	f = 0.035;
	k = 0.0625;
	initCells();
}

void setVaryingParams() {
	NUM_HORIZONTAL_CELLS = 300;
	NUM_VERTICAL_CELLS = 300;
	CELL_WIDTH = 2;
	CELL_HEIGHT = 2;
	initCells();	
}

void mousePressed() {
	int xCell = mouseX/CELL_WIDTH;
	int yCell = mouseY/CELL_HEIGHT;

	if (xCell >= NUM_HORIZONTAL_CELLS) {
		// find which control the click happened on
		for (int i = 0; i < buttons.length; i++) {
			buttons[i].click();
		}
		return;
	}

	cellDetails = "Cell[" + yCell + "][" + xCell + "]: u = " + String.format("%.3f", u[yCell][xCell]) + ", v = " + String.format("%.3f", v[yCell][xCell]) +
		(pMode == VARYING_PARAMETER_MODE ? ", k = " + String.format("%.3f", (0.03 + ((0.04 * xCell) / NUM_HORIZONTAL_CELLS))) +
		", f = " + String.format("%.3f", (0.08 * (1.0 - (1.0 * yCell / NUM_VERTICAL_CELLS)))) : "");
	println(cellDetails);
	drawControls();
}

void mouseMoved() {
	if (mouseX/CELL_WIDTH >= NUM_HORIZONTAL_CELLS) {
		//find which control the mouse is hovered on
		for (int i = 0; i < buttons.length; i++) {
			buttons[i].hover();
		}
	}
}

void swapMode(String type) {
	if (type == "rd") {
		if (rdMode == RD_MODE) {
			rdMode = D_MODE;
		}
		else {
			rdMode = RD_MODE;
		}
	}

	if (type == "p") {
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
}

//GUI Stuff
void drawControls() {
	stroke(100);
	fill(0);
	rect(NUM_HORIZONTAL_CELLS * CELL_WIDTH, 0, CONTROLS_WIDTH, NUM_VERTICAL_CELLS * CELL_HEIGHT);
	fill(255);
	text("Simulation is " + (paused ? "paused" : "playing"), NUM_HORIZONTAL_CELLS * CELL_WIDTH + 20, 30);
	text("Simulate Pattern:", NUM_HORIZONTAL_CELLS * CELL_WIDTH + 20, 310, CONTROLS_WIDTH - 40, 100);
	text(cellDetails, NUM_HORIZONTAL_CELLS * CELL_WIDTH + 20, 430, CONTROLS_WIDTH - 40, 100);
	text("Click above buttons for various actions", NUM_HORIZONTAL_CELLS * CELL_WIDTH + 20, 480, CONTROLS_WIDTH - 40, 100);
	text("Developed by Murali Varma", NUM_HORIZONTAL_CELLS * CELL_WIDTH + 20, NUM_VERTICAL_CELLS * CELL_HEIGHT - 60, CONTROLS_WIDTH - 20, 20);
	text("github.com/muraliavarma/ ReactionDiffusion", NUM_HORIZONTAL_CELLS * CELL_WIDTH + 20, NUM_VERTICAL_CELLS * CELL_HEIGHT - 40, CONTROLS_WIDTH - 20, 40);
	for (int i = 0; i < buttons.length; i++) {
		buttons[i].draw(200);
	}
	line(NUM_HORIZONTAL_CELLS * CELL_WIDTH, 290, NUM_HORIZONTAL_CELLS * CELL_WIDTH + CONTROLS_WIDTH, 290);
	line(NUM_HORIZONTAL_CELLS * CELL_WIDTH, 420, NUM_HORIZONTAL_CELLS * CELL_WIDTH + CONTROLS_WIDTH, 420);
	line(NUM_HORIZONTAL_CELLS * CELL_WIDTH, 470, NUM_HORIZONTAL_CELLS * CELL_WIDTH + CONTROLS_WIDTH, 470);
	noStroke();
}

//Button class that is used plenty of times in the GUI controls
class Button {
	int x;
	int y;
	int width;
	int height;
	String buttonText;
	String hotkey = "";

	//constructor for buttons with hotkeys
	Button(int x, int y, int width, int height, String buttonText, String hotkey) {
		this.x = NUM_HORIZONTAL_CELLS * CELL_WIDTH + x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.buttonText = buttonText;
		this.hotkey = hotkey;
	}

	//what happens when you click the button
	void click() {
		if (mouseX > x && mouseX < x + width && mouseY > y && mouseY < y + height) {
			if (hotkey == "I") {
				initCells();
			}
			if (hotkey == "Space") {
				paused = !paused;
				drawControls();
			}
			if (hotkey == "U") {
				uvMode = U_MODE;
			}
			if (hotkey == "V") {
				uvMode = V_MODE;
			}
			if (hotkey == "D") {
				swapMode("rd");
			}
			if (hotkey == "P") {
				swapMode("p");
			}

			if (hotkey == "1") {
				f = 0.035;
				k = 0.0625;
			}
			else if (hotkey == "2") {
				f = 0.035;
				k = 0.06;
			}
			else if (hotkey == "3") {
				f = 0.0118;
				k = 0.0475;
			}
			else if (hotkey == "4") {
				f = 0.054;
				k = 0.063;
			}
		}
	}

	//change color upon hovering on button
	void hover() {
		if (mouseX > x && mouseX < x + width && mouseY > y && mouseY < y + height) {
			draw(100);
		}
		else {
			draw(200);
		}
	}

	//draw the actual button
	void draw(int col) {
		fill(col);
		rect(x, y, width, height);
		fill(0);
		text(buttonText + " (" + hotkey + ")", x + 2, y + 4, width, height);
	}
};
