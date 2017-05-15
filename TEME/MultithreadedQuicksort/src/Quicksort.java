
public class Quicksort{
	
	void sort(int arr[]){
		sort(arr, 0, arr.length-1);
	}
	
	void sort(int arr[], int left, int right) {
		int leftIndx = left, rightIndx = right;
	    int pivot = arr[(left + right) / 2];

	    while (leftIndx <= rightIndx) {
	    	while (arr[leftIndx] < pivot) {
	    		leftIndx++;
	    	}

	    	while (arr[rightIndx] > pivot) {
	    		rightIndx--;
	    	}
	    	
	    	if (leftIndx <= rightIndx) {
	    		//swap
	    		int tmp = arr[leftIndx];
	    		arr[leftIndx] = arr[rightIndx];
	    		arr[rightIndx] = tmp;
	    		leftIndx++;
	            rightIndx--;
	        }
	    }
	    
	    pivot = leftIndx;
	    
	    if (left < pivot - 1) {
	    	sort(arr, left, pivot - 1);
	    }
	    
	    if (pivot < right) {
	    	sort(arr, pivot, right);
	    }
	}   
}