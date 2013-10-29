
// k-means clustering
// implemented using tutorial at http://mnemstudio.org/clustering-k-means-example-1.htm
class KClusters {
  int rowCount;
  int columnCount;
  FloatTable data;
  float[][] means;      // k rows, columnCount cols
  int k;
  
  HashMap<Integer, Integer> clusterGroups;
  ArrayList<ArrayList<Integer>> rowsInCluster;
  
  // constructor
  KClusters(int _k, FloatTable _data) {
    k = _k;
    data = _data;

    initVars();
    initMeans();
    
    for (int i = 0; i < 3; i++) {
      addToClusters();
    }

  }// constructor()
  
  void initVars() {
    columnCount = data.getColumnCount();
    rowCount = data.getRowCount();
    means = new float[k][columnCount];
    
    clusterGroups = new HashMap<Integer, Integer>();
    rowsInCluster = new ArrayList<ArrayList<Integer>>();
   
    for(int i = 0; i < k; i++) {
      ArrayList<Integer> ll = new ArrayList<Integer>();
      rowsInCluster.add(ll);
    }
  }// initVars()
  
  void printClusters() {
    println(rowsInCluster);
  }// printClusters()
  
  void printMeans() {
    println("PRINTING MEANS");
    for (int i = 0; i < k; i++) {
      println();
      for (int j = 0; j < columnCount; j++) {
        print(means[i][j] + "\t"); 
      }
    }
    println();
  }// printMeans()
  
  void initMeans() {
    for (int col = 0; col < columnCount; col++) {
      float[] column = data.getSortedColumnData(col);
     
      int spacing = rowCount/k;
      int meansCount = 0;
      for (int row = 0; row < rowCount; row+=spacing) {
        if (meansCount == k)
          break;
        means[meansCount][col] = column[row];
        meansCount++;
      }// inner for
    }// outer for
  }// initMeans()
  
  void addToClusters() {
    for (int row = 0; row < rowCount; row++) {
      getDistances(row);
    }
  }// addToClusters()
  
  float getDistances(int row) {
    float minDist = 10000000;
    int group = -1;
    for (int m = 0; m < k; m++) {
      float dist = 0.0;
      for (int col = 0; col < columnCount; col++) {
        if (data.isValid(row, col)) {
          float value = data.getFloat(row, col);
          dist += pow(means[m][col] - value, 2);
        }
      }// forloop
      
      dist = sqrt(dist);
      if (dist < minDist) {
        minDist = dist;
        group = m;   
      }
    }// outer for
    clusterGroups.put(row, group);
    rowsInCluster.get(group).add(row);
    recalculateMeans(group); 
    return minDist;
  }// getDistances()
  
  void recalculateMeans(int cluster) {
    ArrayList<Integer> rowsToIncl = rowsInCluster.get(cluster);

    for (int col = 0; col < columnCount; col++) {
      float newVal = 0.0;
      for (int r = 0; r < rowsToIncl.size(); r++) {
        int row = rowsToIncl.get(r);
        newVal += data.getFloat(row, col);
      }
      newVal = newVal/rowsToIncl.size();
      means[cluster][col] = newVal;
    }
  }// recalculateMeans()
  
  int getCluster(int row) {
    return clusterGroups.get(row);
  }// getCluster()
  

}// KClusters class
