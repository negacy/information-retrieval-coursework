#javac -classpath .:lucene-core-4.0.0.jar:lucene-analyzers-common-4.0.0.jar:lucene-queryparser-4.0.0.jar Indexer.java
java -classpath .:lucene-core-4.0.0.jar:lucene-analyzers-common-4.0.0.jar:lucene-queryparser-4.0.0.jar Indexer medical.txt queries.txt qrels.txt
