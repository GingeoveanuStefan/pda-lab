import java.util.Random;



public class Main {
	public static void main(String[] args) {
		
		Quicksort recQS = new Quicksort();
		QuicksortMultithreaded mthQS = new QuicksortMultithreaded();
		
		long qrecTime, qitrTime, qmthTime;
		
		int arraySize = 100;
		int arr[];
		
		long startTime, endTime;
		
		arr = generateArray(arraySize);
		startTime = System.currentTimeMillis();
		recQS.sort(arr);
		endTime   = System.currentTimeMillis();
		qrecTime = endTime - startTime;
		System.out.println("Recursive runtime: "+qrecTime);
		printArray(arr);
		
		
		arr = generateArray(arraySize);
		startTime = System.currentTimeMillis();
		mthQS.sort(arr);
		endTime   = System.currentTimeMillis();
		qmthTime = endTime - startTime;
		System.out.println("Multithreaded runtime: "+qmthTime);
		printArray(arr);
		
	}
	
	static int[] generateArray(int size){
		Random rand = new Random();
		int array[] = new int[size];
		for(int i=0; i<size; i++)
			array[i] = rand.nextInt((100 - 0) + 1) + 0;
		
		return array;
	}
	
	static void printArray(int[] array){
		for(int i : array){
			System.out.print(i + " ");
		}
		System.out.println();
	}
}
