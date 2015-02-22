//package edu.ucdenver.ccp.nlp.ass2;
import org.apache.lucene.analysis.standard.StandardAnalyzer;
import org.apache.lucene.document.Document;
import org.apache.lucene.document.Field;
import org.apache.lucene.document.StringField;
import org.apache.lucene.document.TextField;
import org.apache.lucene.index.DirectoryReader;
import org.apache.lucene.index.IndexReader;
import org.apache.lucene.index.IndexWriter;
import org.apache.lucene.index.IndexWriterConfig;
import org.apache.lucene.queryparser.classic.ParseException;
import org.apache.lucene.queryparser.classic.QueryParser;
import org.apache.lucene.search.IndexSearcher;
import org.apache.lucene.search.Query;
import org.apache.lucene.search.ScoreDoc;
import org.apache.lucene.search.TopScoreDocCollector;
import org.apache.lucene.store.Directory;
import org.apache.lucene.store.RAMDirectory;
import org.apache.lucene.util.Version;

import java.io.IOException;
import java.io.FileReader;
import java.io.BufferedReader;

import java.util.HashMap;
import java.util.Map;
import java.util.ArrayList;
import java.util.List;
import java.util.Collection;

import org.apache.lucene.analysis.en.EnglishAnalyzer;

public class Indexer {

	public static void main(String args []) throws IOException, ParseException{

		BufferedReader br = new BufferedReader(new FileReader(args[0]));
		String line = null;
		String docID =  "";
		String docAbstract = "";
		Map<String, String> dictionary = new HashMap<String, String>();	//dictionary to store docId and abstract for each article
        
        Map<String, List<String>> dictPredict = new HashMap<String, List<String>>(); //stores retrieved doc for each query
		         
		// 0. Specify the analyzer for tokenizing text.
		//    The same analyzer should be used for indexing and searching
		//StandardAnalyzer analyzer = new StandardAnalyzer(Version.LUCENE_40);
        EnglishAnalyzer en_an = new EnglishAnalyzer(Version.LUCENE_40);
        
		// 1. create the index
		Directory index = new RAMDirectory();

		//IndexWriterConfig config = new IndexWriterConfig(Version.LUCENE_40, analyzer);
		IndexWriterConfig config = new IndexWriterConfig(Version.LUCENE_40, en_an);

		IndexWriter w = new IndexWriter(index, config);
		while ((line = br.readLine()) != null) {
			if (line.startsWith(".I")) {
				docID = "";
				docAbstract = "";
				}
			if (line.startsWith(".U")) {
				docID = br.readLine();
				}
			if(line.startsWith(".W")) {
				docAbstract = br.readLine();
			}
			dictionary.put(docID, docAbstract);
			//addDoc(w, docAbstract, docID);
		}
		for (Map.Entry<String, String> entry : dictionary.entrySet())	{
			if (entry.getValue() != "") 
			//System.out.println(entry.getKey() + "/" + entry.getValue());
			addDoc(w, entry.getValue(), entry.getKey());
		}
  		w.close();
		br.close();
	
		 // 2. query
		
		br = new BufferedReader(new FileReader(args[1]));	
		String [] queryId= new String[100];
		String [] myQuery = new String[100];
		int countNum = 0;
		int countTitle = 0;
		while ((line = br.readLine()) != null) {
			if (line.startsWith("<num>")) {
				//System.out.print(line);
				queryId[countNum++] = line.split("Number:")[1].replaceAll("\\s+","");
				}
				
			else if (line.startsWith("<title>")) {
				//System.out.print("\t" + line);
				myQuery[countTitle] = line.split("title>")[1] + ' ';
				}
				
			else if (line.startsWith("<desc>")) {
				//System.out.println("\t" + br.readLine());
				myQuery[countTitle++] += br.readLine();
				//myQuery[countTitle++] = br.readLine();
				}
			
			}
		br.close();
		
		String querystr = null; //"60 year old menopausal woman without hormone replacement therapy";//args.length > 0 ? args[0] : "lucene";
		int count = 0;
		for (String s: myQuery) {
				querystr = s;
				if (querystr != null) { //avoid null queries
						//System.out.println(number[count++] + "\t" + "\tq: " + querystr);			
						// the "title" arg specifies the default field to use
						// when no field is explicitly specified in the query.
						//Query q = new QueryParser(Version.LUCENE_40, "title", analyzer).parse(querystr);
						Query q = new QueryParser(Version.LUCENE_40, "title", en_an).parse(querystr);

						// 3. search
						int hitsPerPage = 50;
						IndexReader reader = DirectoryReader.open(index);
						IndexSearcher searcher = new IndexSearcher(reader);
						TopScoreDocCollector collector = TopScoreDocCollector.create(hitsPerPage, true);
						searcher.search(q, collector);
						ScoreDoc[] hits = collector.topDocs().scoreDocs;
						// 4. display results
						//System.out.println("Found " + hits.length + " hits.");

                        //declare temporary List to store retrieved docIds for each query
                        List<String> retrievedDocs = new ArrayList<String>();

						for(int i=0;i<hits.length;++i) {
							int docId = hits[i].doc;
							Document d = searcher.doc(docId);
							//System.out.println(number[count] + "\t" + d.get("isbn") + '\t');
							//System.out.println((i + 1) + ". " + d.get("isbn") + "\t" + d.get("title"));
                            //populate dictPredict
                            retrievedDocs.add(d.get("isbn"));
						}
                        dictPredict.put(queryId[count], retrievedDocs);
						count++; //process next query
						//System.out.println();
		
				// reader can only be closed when there
   				// is no need to access the documents any more.
    			reader.close();
			}
		}	
    //call rprecision method
    rPrecision(dictPredict, new BufferedReader(new FileReader(args[2])));	
	} //main

    private static void addDoc(IndexWriter w, String title, String isbn) throws IOException {
    Document doc = new Document();
    doc.add(new TextField("title", title, Field.Store.YES));

    // use a string field for isbn because we don't want it tokenized
    doc.add(new StringField("isbn", isbn, Field.Store.YES));
    w.addDocument(doc);
    }
    
    private static void rPrecision(Map<String, List<String>> dictPredict, BufferedReader br) throws IOException {//, Map<String, String> dictGold) {
        Map<String, List<String>> dictGold = new HashMap<String, List<String>>(); //stores human gugement relevant document for each query
		String key = null;
		String tmp = null;
		List<String> values = new ArrayList<String>();

		for (String next, line = br.readLine(); line != null; line = next) {
				next = br.readLine();
				String currentDocId = line.split("\\s+")[0].replaceAll("\\s+","");
				String nextDocId = null;
				if (next != null) 
					nextDocId = next.split("\\s+")[0].replaceAll("\\s+","");
			//	System.out.println("Current line: " + line);
			//	System.out.println("Next line: " + next);
				if (currentDocId.equals(nextDocId)) {
					//System.out.print(line.split("\\s+")[1].replaceAll("\\s+","") + " ");
					values.add(line.split("\\s+")[1].replaceAll("\\s+",""));
					}
				else {
					//System.out.println(line.split("\\s+")[1].replaceAll("\\s+","") + " ");
					values.add(line.split("\\s+")[1].replaceAll("\\s+",""));
					List<String> newList = new ArrayList<String>(values);
					dictGold.put(currentDocId, newList);
					//System.out.println(currentDocId);
					/*					
					for (String s: values) {
							System.out.print(s + " ");
					}*/
					values.clear();
					//System.out.println();
				}
			}
		double avgRprecision = 0;	
		for (Map.Entry<String, List<String>> e: dictGold.entrySet()) {
			String keyGold = e.getKey();
			List<String> valueGold = e.getValue();
			int k = valueGold.size();
				for (Map.Entry<String, List<String>> entry : dictPredict.entrySet())    {
					String keyPre = entry.getKey();
					//List<String> valuePre = entry.getValue();
					if (keyGold.equals(keyPre)) {
						System.out.println(keyGold);
						System.out.println(dictGold.get(keyGold));
						System.out.println(dictPredict.get(keyPre).subList(0, k));//display top k of the maxhits retrieved
						//create collection to get intersection of lists
						Collection<String> col1 = dictGold.get(keyGold);  
						Collection<String> col2 = dictPredict.get(keyPre).subList(0, k);
						col1.retainAll(col2);
						System.out.println(col1); 
						System.out.print("r: " + col1.size() + " rel: " + k );
						System.out.printf(" R- precision: %.2f", (double) col1.size()/k);
						avgRprecision += (double) col1.size()/k;

					}
				}
			System.out.println();
		}
		System.out.println();
		System.out.println();
		System.out.printf("avg R-precison: %.2f", (double)avgRprecision/63);
		System.out.println();
		System.out.println();
		
    }
}
