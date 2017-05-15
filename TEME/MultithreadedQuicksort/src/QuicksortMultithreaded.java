import java.util.Random;

public class QuicksortMultithreaded{
	
	static int threadId=0;
	
	void sort(int arr[]){
		sort(arr, 0, arr.length-1);
	}
	
	static void sort(int arr[], int left, int right) {
		if(left >= right)
			return;
		
		int leftIndx = left, rightIndx = right;
	    int pivot = arr[(left + right) / 2];

	    while (leftIndx <= rightIndx) {
	    	while (arr[leftIndx] < pivot)
	    		leftIndx++;

	    	while (arr[rightIndx] > pivot)
	    		rightIndx--;
	    	
	    	if (leftIndx <= rightIndx) {
	    		int tmp = arr[leftIndx];
	    		arr[leftIndx] = arr[rightIndx];
	    		arr[rightIndx] = tmp;
	    		leftIndx++;
	    		rightIndx--;
	    	}
	    }
	    
	    pivot = leftIndx;
	    
	    ParallelQuicksortThread leftThread = new ParallelQuicksortThread(arr, left, pivot -1, ++threadId);

	    ParallelQuicksortThread rightThread = new ParallelQuicksortThread(arr, pivot, right, ++threadId);
	    
	    leftThread.start();
	    rightThread.start();
	    
        try {
            leftThread.join();
            rightThread.join();
        } catch (InterruptedException ex) {
            throw new IllegalStateException(
                    "Parallel quicksort threw an InterruptedException.");
        }
	}   
	
	private static final class ParallelQuicksortThread extends Thread {
		int[] arr;
		int left, right;
		int id;
		
        ParallelQuicksortThread(int[] arr, int left,  int right, int id) {
            this.arr = arr;
            this.left = left;
            this.right = right;
            this.id = id;
        }
        
        @Override
        public void run() {
        	
        	System.out.print("Thread "+id+" gets interval: ");
        	for(int i=left; i<=right; i++)
        		System.out.print(arr[i]+" ");
        	System.out.print("\n");
        	
        	sort(arr, left, right);
        	
        	System.out.println("Thread "+id+" finished.");
        }
	}

	
}