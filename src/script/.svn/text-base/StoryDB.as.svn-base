package script
{
	import com.adobe.air.crypto.EncryptionKeyGenerator;
	
	import flash.data.*;
	import flash.errors.SQLError;
	import flash.filesystem.*;
	import flash.utils.ByteArray;
	
	public class StoryDB
	{
		public function StoryDB()
		{
		}
		
		public static function Open():SQLConnection
		{
			var conn:SQLConnection;
			var dbFile:File;
			var createNewDb:Boolean;
			
			conn = new SQLConnection();
			dbFile = File.applicationStorageDirectory.resolvePath("storyblue_db");
			if(dbFile.exists)
			{
				createNewDb = false;
			}
			else	//create db
				createNewDb = true;
			
			var keyGen:EncryptionKeyGenerator = new EncryptionKeyGenerator();
			var password:String = "th1s1s1zr4zypaSSWORD,man";
			var encryptionKey :ByteArray = keyGen.getEncryptionKey(password);
			
			conn.open(dbFile, SQLMode.CREATE, false, 1024, encryptionKey);
			
			return conn;
		}
		
		public static function Get(conn:SQLConnection, sql:String):SQLResult
		{
			var createStmt:SQLStatement = new SQLStatement();
			createStmt.sqlConnection = conn;
			createStmt.text = sql;
			
			return ExecGet(createStmt);
		}
		
		public static function ExecGet(st:SQLStatement):SQLResult
		{
			try
			{
			    st.execute();
			}
			catch (error:SQLError)
			{
			    //status = "Error loading data";
			    trace("SELECT error:", error);
			    trace("error.message:", error.message);
			    trace("error.details:", error.details);
			    return null;
			}
			
			var result:SQLResult = st.getResult();
			if(result.data == null || result.data.length == 0)
				return null;
				
			return result;
		}
		
		public static function Exec(conn:SQLConnection, sql:String):void
		{
			var createStmt:SQLStatement = new SQLStatement();
			createStmt.sqlConnection = conn;
			createStmt.text = sql;
			createStmt.execute();
		}
	
	}
}