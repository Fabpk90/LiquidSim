//Some optimizations:
// Pre allocate the matrix used for updating the automaton
// use a automaton that starts at 1, to remove some checks in the loops

public class Automata
{
  int cellSize;
  int cellAmountX;
  int cellAmountY;
  
  float maxMass = 1.0; //The normal, un-pressurized mass of a full liquid cell
  float maxCompress = 0.02; //How much excess liquid a cell can store, compared to the cell above it
  float minMass = 0.0001; //Ignore cells that are almost dry
  
  Cell[][] cells;

  float [][] cellsMass;
  
  boolean useNormalGravity = true;
  float animStep = 0.5f;
  
  Automata(int cellSize, float maxMass, float maxCompression, float minMass, float animStep)
  {
    this.cellSize = cellSize;
    
    this.maxMass = maxMass;
    this.minMass = minMass;
    
    this.animStep = animStep;
    
    cellAmountX = width / cellsSize;
    cellAmountY = height / cellsSize;

    cells = new Cell[cellAmountX][cellAmountY];
    cellsMass = new float[cellAmountX][cellAmountY];
    
    initSim();
    
  }
  
  void initSim()
  {
    for (int i = 0; i < cellAmountY; i++)
    {
      for (int j = 0; j < cellAmountX; j++)
      {
        cells[j][i] = Cell.EMPTY;
      }
    }
  }
  
  void draw()
  {
    for (int i = 0; i < cellAmountY; i++)
    {
      for (int j = 0; j < cellAmountX; j++)
      {
        Cell c = cells[j][i];
        if (c != Cell.EMPTY)
        {
          fill(c.getR(), c.getG(), c.getB());
          rect(j * cellsSize, i * cellsSize, cellsSize, cellsSize * -constrain(cellsMass[j][i], 0.0f, 1.0f));
        }
      }
    }
  }
  
  void updateAutomaton()
  {
    //copying the actual masses of the automaton
    float[][] copiedMass = new float[cellsMass.length][];
    for (int i = 0; i < cells.length; i++)
    {
      float[] aMatrix = cellsMass[i];
      int aLength = aMatrix.length;
      
      copiedMass[i] = new float[aLength];
      
      System.arraycopy(aMatrix, 0, copiedMass[i], 0, aLength);
    }
    
    float flow = 0.0f;
    
    for(int x = 0; x < cellAmountX; ++x)
    {
       for(int y = 0; y < cellAmountY; ++y)
       {
           Cell c = cells[x][y];
           
           if(c != Cell.EMPTY && c != Cell.BLOCK)
           {
              float currentMass = cellsMass[x][y];
              if(useNormalGravity)
              {
                 //can we analyse below and can share some water
                if(y + 1 < cellAmountY && cells[x][y + 1] != Cell.BLOCK)
                {
                  //what happens if we transfer all the water ?
                  flow = getStableState(currentMass + cellsMass[x][y + 1]);
                  
                  flow = constrain(flow, 0, currentMass);
                  
                  //smooth anim
                  flow *= animStep;
                  
                  copiedMass[x][y + 1] += flow;
                  copiedMass[x][y] -= flow;
                  currentMass -= flow;
                }
              }
              else
              {
                if(y - 1 > 0 && cells[x][y - 1] != Cell.BLOCK)
                {
                  //what happens if we transfer all the water ?
                  flow = getStableState(currentMass + cellsMass[x][y - 1]);
                  
                  flow = constrain(flow, 0, currentMass);
                  
                  //smooth anim
                  flow *= animStep;
                  
                  copiedMass[x][y - 1] += flow;
                  copiedMass[x][y] -= flow;
                  currentMass -= flow;
                }
              }
             
              
              //we check the left
              if(x - 1 > 0 && cells[x - 1][y] != Cell.BLOCK && currentMass > 0.0f)
              {
                  flow = currentMass - cellsMass[x-1][y];
                  
                  //to make sure that we don't overshare or have less than our neighbor
                  flow = constrain(flow, 0, currentMass);
                  
                  //smooth anim
                  flow *= animStep;
                
                  copiedMass[x - 1][y] += flow;
                  copiedMass[x][y] -= flow;
                  currentMass -= flow;
              }
              
              //we check the right
              if(x + 1 < cellAmountX && cells[x + 1][y] != Cell.BLOCK && currentMass > 0.0f)
              {
                  flow = currentMass - cellsMass[x + 1][y];
                  
                  //to make sure that we don't overshare or have less than our neighbor
                  flow = constrain(flow, 0, currentMass);
                  
                  //smooth anim
                  flow *= animStep;
                
                  copiedMass[x + 1][y] += flow;
                  copiedMass[x][y] -= flow;
                  currentMass -= flow;
              }
              
              if(useNormalGravity)
              {
                   //we check above, to simulate compressed liquid
                 if (y - 1 > 0 && cells[x][y - 1] != Cell.BLOCK)
                 {
                     flow = currentMass - getStableState(currentMass + cellsMass[x][y - 1]);
    
                     flow = constrain(flow, 0, currentMass);
                     
                     copiedMass[x][y] -= flow;
                     copiedMass[x][y - 1] += flow;   
                     currentMass -= flow;
                 }  
              }
              else 
              {
                 //we check above, to simulate compressed liquid
               if (y + 1 < cellAmountY && cells[x][y + 1] != Cell.BLOCK)
               {
                   flow = currentMass - getStableState(currentMass + cellsMass[x][y + 1]);
  
                   flow = constrain(flow, 0, currentMass);
                   
                   copiedMass[x][y] -= flow;
                   copiedMass[x][y + 1] += flow;   
                   currentMass -= flow;
               }  
              }  
           }
       }
    }
    
    //copying back the actual state of the masses
    for (int i = 0; i < cells.length; i++)
    {
      float[] aMatrix = copiedMass[i];
      int aLength = aMatrix.length;
      
      System.arraycopy(aMatrix, 0, cellsMass[i], 0, aLength);
    }
    
   updateStates();
  }
  
  void updateStates()
  {
    for(int x = 0; x < cellAmountX; ++x)
    {
       for(int y = 0; y < cellAmountY; ++y)
       {
          if(cells[x][y] != Cell.BLOCK)
          {
            cells[x][y] = cellsMass[x][y] > MinMass ? Cell.LIQUID : Cell.EMPTY;
          }
       }
    }
  }
  
   public void setCell(Cell c, int x, int y)
   {
      cells[x][y] = c; 
   }
   
   public void setCellMass(float mass, int x, int y)
   {
      cellsMass[x][y] = mass; 
   }
   
   public void toggleGravity()
   {
      useNormalGravity = !useNormalGravity; 
   }
}
