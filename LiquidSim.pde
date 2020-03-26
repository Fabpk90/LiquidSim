
int cellsSize = 10; //must be a euclidean divisor of size (r must be 0)
int cellAmountX;
int cellAmountY;
Cell[][] cells;

int stepCounter = 0;
int stepTick = 2; //1 step per second

void setup()
{
  size(400, 400);
  frameRate(60.0f);
  cellAmountX = width / cellsSize;
  cellAmountY = height / cellsSize;
  
  cells = new Cell[cellAmountX][cellAmountY];
  
  for(int i = 0; i < cellAmountY; i++)
  {
     for(int j = 0; j < cellAmountX; j++)
     {
        cells[j][i] = Cell.EMPTY; 
     }
  }
}

void draw()
{
  background(255);
  if(stepCounter++ % stepTick == 0)
    updateAutomaton();
    
  drawAutomaton();
}

void updateAutomaton()
{
  //copying the actual state of the automaton
  Cell [][] copiedState = new Cell[cells.length][];
  for(int i = 0; i < cells.length; i++)
  {
    Cell[] aMatrix = cells[i];
    int   aLength = aMatrix.length;
    copiedState[i] = new Cell[aLength];
    System.arraycopy(aMatrix, 0, copiedState[i], 0, aLength);
  }
  
  for(int i = 0; i < cellAmountY; i++)
  {
    for(int j = 0; j < cellAmountX; j++)
    {
       Cell c = cells[j][i];
       
       if(c != Cell.BLOCK && c != Cell.EMPTY)
       {
         if(c.getLevel() > 0)
         {
           //check if the cell can fall
           if( i + 1 < cellAmountY && cells[j][i + 1] == Cell.EMPTY)
           {
             copiedState[j][i + 1] = cells[j][i];
             copiedState[j][i] = Cell.EMPTY;
           }
         }
       }
    }
  }
  
   //copying back the actual state of the automaton
  for(int i = 0; i < cells.length; i++)
  {
    Cell[] aMatrix = copiedState[i];
    int   aLength = aMatrix.length;
    System.arraycopy(aMatrix, 0, cells[i], 0, aLength);
  }
}

void drawAutomaton()
{
  for(int i = 0; i < cellAmountY; i++)
  {
    for(int j = 0; j < cellAmountX; j++)
     {
       if(cells[j][i] != Cell.EMPTY)
       {
           fill(cells[j][i].getR(),cells[j][i].getG(),cells[j][i].getB());
           rect(j * cellsSize, i * cellsSize, cellsSize, cellsSize);
           rect(j * cellsSize, i * cellsSize, cellsSize, cellsSize * cells[j][i].getLevel());
       }
     }  
  }
}

void mouseClicked()
{
  handleMouse();
}

void mouseDragged()
{
  handleMouse(); 
}

void handleMouse()
{
  int positionX = mouseX / cellsSize;
  int positionY = mouseY / cellsSize;
  
  //out of bound checking
  if(positionX >= 0 && positionX < cellAmountX
  && positionY >= 0 && positionY < cellAmountY)
  {
    //TODO: make sure the cell can be placed
    if(mouseButton == LEFT)
    cells[positionX][positionY] = Cell.BLOCK;
   else if(mouseButton == RIGHT)
    cells[positionX][positionY] = Cell.FULL; 
    else if(mouseButton == CENTER)
    cells[positionX][positionY] = Cell.EMPTY;
  }
}
