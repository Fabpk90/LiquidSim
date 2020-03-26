public enum Cell
{
  EMPTY(0.0f, 255, 255, 255), QUARTER(0.25f, 0, 0, 255), HALF(0.5f, 0, 0, 255), FULL(1.0f, 0, 0, 255), BLOCK(0.0f, 0, 0, 0);
  
  private final float waterLevel;
  private final int r;
  private final int g;
  private final int b;
  
  private Cell(float level, int r, int g, int b)
  {
     waterLevel = level;
     this.r =r;
     this.g = g;
     this.b = b;
  }
  
  public float getLevel()
  {
     return waterLevel; 
  }
  
  public int getR()
  {
     return r; 
  }
  
  public int getG()
  {
     return g; 
  }
  
  public int getB()
  {
     return b; 
  }
};
