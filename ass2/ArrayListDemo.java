import java.util.ArrayList;
import java.util.Map;
import java.util.HashMap;
import java.util.List;

public class ArrayListDemo {
	public static void main(String[] args) {

		// create an empty array list with an initial capacity
		List<Integer> arrlist = new ArrayList<Integer>(5);
		Map<String, List<Integer>> dic = new HashMap<String, List<Integer>>();

		// use add() method to add elements in the list
		arrlist.add(20);
		arrlist.add(30);
		arrlist.add(10);
		arrlist.add(50);
		List<Integer> newList = new ArrayList<Integer>(arrlist);		
		dic.put("neg", newList);
		// let us print all the elements available in list
		for (Integer number : arrlist) {
		System.out.println("Number = " + number);
		}      
		for (Map.Entry<String, List<Integer>> entry : dic.entrySet())    {
            String key = entry.getKey();
            List<Integer> values = entry.getValue();
            System.out.println("Key = " + key);
            System.out.println("Values = " + values);
            //System.out.println(entry.getKey() + "/" + entry.getValue());
        }


		// finding size of this list
		int retval = arrlist.size();
		System.out.println("List consists of "+ retval +" elements");

		System.out.println("Performing clear operation !!");
		arrlist.clear();
		retval = arrlist.size();
		System.out.println("Now, list consists of "+ retval +" elements");
		
		for (Map.Entry<String, List<Integer>> entry : dic.entrySet())    {
            String key = entry.getKey();
            List<Integer> values = entry.getValue();
            System.out.println("Key = " + key);
            System.out.println("Values = " + values);
            //System.out.println(entry.getKey() + "/" + entry.getValue());
        }
}
} 
