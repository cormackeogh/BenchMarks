package com.nomodb;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Set;
import java.util.Vector;

import java.util.Base64;

import com.yahoo.ycsb.ByteIterator;
import com.yahoo.ycsb.DB;
import com.yahoo.ycsb.DBException;
import com.yahoo.ycsb.StringByteIterator;

import java.util.Map;
import java.util.Properties;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.OutputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;




/**
 * @author Cormac Keogh ITTDublin.ie
 * 
 *         Node MongoDB Interface Layer - NoMoDBIL This class represents the
 *         adapter code required to link to the Node and MongoDB Server
 *         environment configured for benchmark testing with YCSB
 *
 */
public class NoMoDbIL extends DB {

	public static final int CONN_TIMEOUT_MS = 25000;
	private HttpURLConnection conn;
	private URL url;

	public NoMoDbIL() {

	}

	/**
	 * Initialize any state for this DB. Called once per DB instance; there is
	 * one DB instance per client thread.
	 */
	@Override
	public void init() throws DBException {

		Properties props = getProperties();

		try {
			
			String urlStr = props.getProperty("server.url");
			url = new URL(urlStr);


		} catch (MalformedURLException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
	}

	/**
	 * Cleanup any state for this DB. Called once per DB instance; there is one
	 * DB instance per client thread.
	 */
	@Override
	public void cleanup() {
		conn.disconnect();
	}
	
	
	/**
	 * Cleanup any state for this DB. Called once per DB instance; there is one
	 * DB instance per client thread.
	 */
	public void setUpConnection() {
		try {
			
			conn = (HttpURLConnection) url.openConnection();
			conn.setDoOutput(true);
			conn.setRequestMethod("POST");
			conn.setRequestProperty("Content-Type", "application/json");

		} catch (MalformedURLException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}

	}
	
	
	

	private String getJsonValue(Object value) {
		if (value == null) {
			return "";
		} else if (value instanceof Number || value instanceof Boolean) {
			return value.toString();
		} else {
			return "\"" + value + "\"";
		}
	}

	private String createJsonString(Map<String, String> map) {
		String jsonString = "{ ";
		Set<Map.Entry<String, String>> entries = map.entrySet();
		for (Map.Entry<String, String> entry : entries) {

			jsonString = jsonString + "\"" + entry.getKey() + "\"";
			jsonString += " : ";
			jsonString = jsonString + getJsonValue("Hello"); //entry.getValue());
			jsonString += ",  ";
		}
		int i = jsonString.lastIndexOf(",");
		if (i != -1)
			jsonString = jsonString.substring(0, i);

		jsonString += " }";

		return jsonString;
	}
	
	private int CallRestService(String jsonCmdString) 
	{
		// Call the Server
		try {
			setUpConnection();
			
			OutputStream os = conn.getOutputStream();
			os.write(jsonCmdString.getBytes());
			os.flush();

    	    conn.setConnectTimeout(CONN_TIMEOUT_MS); 
						
			int rc = conn.getResponseCode();
									
			if (rc != HttpURLConnection.HTTP_OK) {
				throw new RuntimeException("Failed : HTTP error code : "
						+ conn.getResponseCode());
			}

			BufferedReader br = new BufferedReader(new InputStreamReader(
					(conn.getInputStream())));
			
			
			cleanup();
			// Success
			return 0;

		} catch (MalformedURLException e) {

			e.printStackTrace();
			return -1;

		} catch (IOException e) {

			e.printStackTrace();
			return -1;
		}
	}
	
	

	/**
	 * Delete a record from the database.
	 * 
	 * @param table
	 *            The name of the table
	 * @param key
	 *            The record key of the record to delete.
	 * @return Zero on success, a non-zero error code on error. See the
	 *         {@link DB} class's description for a discussion of error codes.
	 */
	@Override
	public int delete(String table, String key) {
		
		String jsonCmdString = "{" + "\"cmd\":"   + "\"Delete\"," + "\"table\":\"" + table
				+ "\",\"key\":\"" + key + "\"}";

		int rc = CallRestService(jsonCmdString);
		
		return rc;		
		
	}

	/**
	 * Insert a record in the database. Any field/value pairs in the specified
	 * values HashMap will be written into the record with the specified record
	 * key.
	 * 
	 * @param table
	 *            The name of the table
	 * @param key
	 *            The record key of the record to insert.
	 * @param values
	 *            A HashMap of field/value pairs to insert in the record
	 * @return Zero on success, a non-zero error code on error. See the
	 *         {@link DB} class's description for a discussion of error codes.
	 */
	@Override
	public int insert(String table, String key,
			HashMap<String, ByteIterator> values) {

		HashMap<String, String> strValues = new HashMap<String, String>();

		// Convert Bytes to Strings
		StringByteIterator.putAllAsStrings(strValues, values);

		// Convert HashMap of Strings to JSON Structure
		String mapStr = createJsonString(strValues);
		
		// encode without padding
		String encoded = Base64.getEncoder().withoutPadding().encodeToString(mapStr.getBytes());
	
		String jsonCmdString = "{" + "\"cmd\":"   + "\"Insert\"," + "\"table\":\"" + table
				+ "\",\"key\":\"" + key + "\",\"values\":\"" + encoded + "\"}";

		
		int rc = CallRestService(jsonCmdString);
		
		return rc;
	}

	/**
	 * Read a record from the database. Each field/value pair from the result
	 * will be stored in a HashMap.
	 * 
	 * @param table
	 *            The name of the table
	 * @param key
	 *            The record key of the record to read.
	 * @param fields
	 *            The list of fields to read, or null for all of them
	 * @param result
	 *            A HashMap of field/value pairs for the result
	 * @return Zero on success, a non-zero error code on error or "not found".
	 */
	public int read(String table, String key, Set<String> fields,
			HashMap<String, ByteIterator> result) {

		HashMap<String, String> strValues = new HashMap<String, String>();
		StringByteIterator.putAllAsStrings(strValues, result);

		String resultStr = createJsonString(strValues);
		
		// encode without padding
		String encoded = Base64.getEncoder().withoutPadding().encodeToString(resultStr.getBytes());
	
		String jsonCmdString = "{" + "\"cmd\":"   + "\"Read\"," + "\"table\":\"" + table
				+ "\",\"key\":\"" + key + "\",\"result\":\"" + encoded + "\"}";

		System.out.println(jsonCmdString);

		int rc = CallRestService(jsonCmdString);
		
		return rc;		
	}

	/**
	 * Perform a range scan for a set of records in the database. Each
	 * field/value pair from the result will be stored in a HashMap.
	 * 
	 * @param table
	 *            The name of the table
	 * @param startkey
	 *            The record key of the first record to read.
	 * @param recordcount
	 *            The number of records to read
	 * @param fields
	 *            The list of fields to read, or null for all of them
	 * @param result
	 *            A Vector of HashMaps, where each HashMap is a set field/value
	 *            pairs for one record
	 * @return Zero on success, a non-zero error code on error. See the
	 *         {@link DB} class's description for a discussion of error codes.
	 */
	public int scan(String table, String startkey, int recordcount,
			Set<String> fields, Vector<HashMap<String, ByteIterator>> resultVector) {

		// Encode the fields and values for the query
		Iterator<HashMap<String, ByteIterator>> itr = resultVector.iterator();
		String queryArr = "[";		
		while(itr.hasNext())
		{
			HashMap<String, String> strValues = new HashMap<String, String>();
			StringByteIterator.putAllAsStrings(strValues, itr.next());
			String resultStr = createJsonString(strValues);
			String encoded = Base64.getEncoder().withoutPadding().encodeToString(resultStr.getBytes());
			
			queryArr += encoded ;
			if(itr.hasNext())
				queryArr += "," ;				
		}
		queryArr += "]" ;
		
		
		// Encode the fields to return i.e. the projection
		String fieldsArr = "[";		
		Iterator<String> itrSet = fields.iterator();
		while(itrSet.hasNext()){
			String element = (String) itrSet.next();
			
			fieldsArr += element ;
			if(itrSet.hasNext())
				fieldsArr += "," ;	
		}
		fieldsArr += "]" ;
		
		String jsonCmdString = "{" + "\"cmd\":"   + "\"Scan\"," + "\"table\":\"" + table
				+ "\",\"startkey\":\"" + startkey 
				+ "\",\"recordCount\":\"" + recordcount
				+ "\",\"values\":\""	+ queryArr 
				+ "\",\"fields\":\"" + fieldsArr + "\"}";
	
		System.out.println(jsonCmdString);

		int rc = CallRestService(jsonCmdString);
		
		return rc;		
	}

	/**
	 * Update a record in the database. Any field/value pairs in the specified
	 * values HashMap will be written into the record with the specified record
	 * key, overwriting any existing values with the same field name.
	 * 
	 * @param table
	 *            The name of the table
	 * @param key
	 *            The record key of the record to write.
	 * @param values
	 *            A HashMap of field/value pairs to update in the record
	 * @return Zero on success, a non-zero error code on error. See this class's
	 *         description for a discussion of error codes.
	 */
	public int update(String table, String key,
			HashMap<String, ByteIterator> values) {

		HashMap<String, String> strValues = new HashMap<String, String>();
		StringByteIterator.putAllAsStrings(strValues, values);
		String resultStr = createJsonString(strValues);
		String encoded = Base64.getEncoder().withoutPadding().encodeToString(resultStr.getBytes());
	
		String jsonCmdString = "{" + "\"cmd\":"   + "\"Update\"," + "\"table\":\"" + table
				+ "\",\"key\":\"" + key + "\",\"values\":\"" + encoded + "\"}";
		
		System.out.println(jsonCmdString);

		int rc = CallRestService(jsonCmdString);
		
		return rc;		
	}

}
