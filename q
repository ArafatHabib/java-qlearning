import java.util.Scanner;
import java.text.DecimalFormat;
import java.util.Random;
public class Qlearning 
{
  Scanner arafat=new Scanner(System.in);
  final DecimalFormat df = new DecimalFormat("#.##");
  final double alpha = arafat.nextDouble(); 
  final double gamma = arafat.nextDouble(); 
  
  /* 
   mot state 6 ta. state gula ke define kora hoise akhane 
   */
  
  final int stateS = 0;
  final int stateCa = 1;
  final int stateM = 2;
  final int stateD = 3;
  final int stateR = 4;
  final int stateC = 5;
  
  final int statesCount = 6;
  final int[] states = new int[]{stateS,stateCa,stateM,stateD,stateR,stateC};
  
  /*
   Q(s,a)= Q(s,a) + alpha * (R(s,a) + gamma * Max(next state, all actions) - Q(s,a))
   Ata amader main Q function jeta update korte hobe 
   */
  // R matrix jeta dia reward look up er kaj kora hobe
  int[][] R = new int[statesCount][statesCount];     
  // Q matrix.....jeta k reward function er uopo base kore updtae kore agent er brain e rakha hobe. Reward double value o hoite pare through calculation
  double[][] Q = new double[statesCount][statesCount]; 
  
  // kon state theke onno kon kon state e jaoa jae.... tar declaration
  int[] actionsFromS = new int[] { stateCa };
  int[] actionsFromCa = new int[] { stateM, stateCa, stateD };
  int[] actionsFromM = new int[] { stateCa };
  int[] actionsFromD = new int[] { stateR };
  int[] actionsFromR = new int[] { stateC };
  int[] actionsFromC = new int[] { stateC };
  int[][] actions = new int[][] { actionsFromS, actionsFromCa, actionsFromM,actionsFromD, actionsFromR, actionsFromC };
  
  String[] stateNames = new String[] { "S", "Ca", "M", "D", "R", "C" };
  
  public Qlearning() {
    init();
  }
  // ai method e reward declare kora ase goal state er jnno
  public void init() {        
    double beta=arafat.nextDouble();
    System.out.println("Press 1 for time, 2 for money and 3 fo both");
    int priority=arafat.nextInt();
    
    if(priority==1)
    {  
    System.out.println("We will serve you the best route that conserves time");
    System.out.println("Used action set, A={E, a, E, t, r, E, E }");
    }
    else if(priority==2)
    {
      System.out.println("We will serve you the best route that conserves money");
      System.out.println("Used action set, A={E, w, E, r, r, E, E }");
    }
      else
      {
       System.out.println("We will serve you the best route that conserves time and oney both");
       System.out.println("Used action set, A={E, i, E, i, r, E, E }");
      }
    // Cost part of the reward function
    
    double Cr=50.0;   // Cost of the transport that is rented
    double Sg=100.0; // Amount of goods to be supplied or shipped 
    double T=10.0; // number of total Transports required
    double cost=Cr*Sg*(Cr*T);
  
    // Penalty part of the reward function 
    
    double Pt=-10.0; // Penalty for not meeting the deadline
    double Psla= 40.0; //Performance to be maintained by the service provider  
    double Pd=50.0; // Performance system displays randomly 
    double penalty=Pt*(1+(Pd-Psla)/Psla);
    double rew= beta*(cost) + (1-beta)*penalty;
    System.out.println(cost);
    System.out.println(penalty);
    System.out.println(rew);
    R[stateR][stateC] = (int)cost; // from b to c
    R[stateC][stateC] = (int)cost; // from f to c     
    R[stateC][stateS] = (int)penalty; 
  }
  
   public static void main(String[] args) {
    
    // Time counting shuru
    long BEGIN = System.currentTimeMillis(); 
    
    Qlearning obj = new Qlearning();
    
    obj.run();
    //obj.printResult();
    obj.showPolicy();
    // Time counting sesh
    long END = System.currentTimeMillis();
    System.out.println("Time: " + (END - BEGIN) / 1000.0 + " sec.");
  }
  
  void run() {
    /*
     (a)parameter abong environment reward matrix R set kora 
     (b)Q matrix ke initial matrix hishebe zero te declare kora 
     (c) prottek episode er jonno: Random initial state select kora 
     */
    
    // For each episode
    Random rand = new Random();
    for (int i = 0; i < 1005; i++) { // train episodes
      // Select random initial state
      
      int state = rand.nextInt(statesCount);
      
      while (state != stateC) // goal state
      {
        // Select one among all possible actions for the current state
        int[] actionsFromState = actions[state];
        
        // Selecting random strategy
        int index = rand.nextInt(actionsFromState.length);
        int action = actionsFromState[index];
        
        // Action outcome is set to deterministic in our environment0.
        
        int nextState = action;
        
        // Using this possible action, consider to go to the next state
        double q = Q(state, action);
        double maxQ = maxQ(nextState);
        int r = R(state, action);
        
         Random toto=new Random();
        
         double CrMax=100;
         double CrMin=2;
         double Cr = CrMin + (CrMax - CrMin) * toto.nextDouble();  
        
         double SgMax=1000;
         double SgMin=2;
         double Sg = SgMin + (SgMax - SgMin) * toto.nextDouble();
        
        //double Va=1.0; // Va represents the specific virtual machine to be allocated, deallocatd, stopped or migrated 
        
        double TMax=10;
        double TMin=2;
        double T = TMin + (TMax - TMin) * toto.nextDouble();
        double cost=Cr*Sg*(Cr*T);
        //System.out.println(cost);
        double Pt=-10.0; // Penalty for the violation of SLA
        double Psla= 40.0; //40s response time for the work  
        
        double rangeMax=50.0;
        double rangeMin=10.0;
        double Pd = rangeMin + (rangeMax - rangeMin) * toto.nextDouble(); 
        double penalty=Pt*(1+(Pd-Psla)/Psla);
        //System.out.println(penalty);
   
       
        
        double betaMin=0.1;
        double betaMax=0.9;
        double beta = betaMin + (betaMax - betaMin) * toto.nextDouble();
        double rew= beta*(cost) + (1-beta)*penalty;
        //System.out.println(rew);
         
        r=(int)rew;
        
        
        
        
        double value = q + alpha * (r + gamma * maxQ - q);
        setQ(state, action, value);
        
        // Set the next state as the current state
        state = nextState;
      }
    }
 }
  
  double maxQ(int s) {
    int[] actionsFromState = actions[s];
    double maxValue = Double.MIN_VALUE;
    for (int i = 0; i < actionsFromState.length; i++) {
      int nextState = actionsFromState[i];
      double value = Q[s][nextState];
      
      if (value > maxValue)
        maxValue = value;
    }
    return maxValue;
  }
  
  // get policy from state
  int policy(int state) {
    int[] actionsFromState = actions[state];
    double maxValue = Double.MIN_VALUE;
    int policyGotoState = state; // default goto self if not found
    for (int i = 0; i < actionsFromState.length; i++) {
      int nextState = actionsFromState[i];
      double value = Q[state][nextState];
      
      if (value > maxValue) {
        maxValue = value;
        policyGotoState = nextState;
      }
    }
    return policyGotoState;
  }
  
  double Q(int s, int a) {
    return Q[s][a];
  }
  
  void setQ(int s, int a, double value) {
    Q[s][a] = value;
  }
  
  int R(int s, int a) {
    return R[s][a];
  }
  
  void printResult() {
    System.out.println("Print result");
    for (int i = 0; i < Q.length; i++) {
      System.out.print("out from " + stateNames[i] + ":  ");
      for (int j = 0; j < Q[i].length; j++) {
        System.out.print(df.format(Q[i][j]) + " ");
      }
      System.out.println();
    }
  }
  
  // policy is maxQ(states)
  void showPolicy() {
    System.out.println("\nshowPolicy");
    for (int i = 0; i < states.length; i++) {
      int from = states[i];
      int to =  policy(from);
      System.out.println("from "+stateNames[from]+" goto "+stateNames[to]);
    }           
  }


}
