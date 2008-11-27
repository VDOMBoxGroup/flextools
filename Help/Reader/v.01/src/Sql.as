package 
{
	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	
	public class Sql extends SQLStatement 
	{
		private var  file:File ;
//		private var connection:SQLConnection = new SQLConnection();
//		private var selectStatement:SQLStatement;
		
		public function Sql()
		{
			super();
			
			
			file = File.applicationStorageDirectory.resolvePath("HelpDB.db");
			sqlConnection = new SQLConnection();
			addEventListener(SQLEvent.RESULT, resultHandler);
			addEventListener(SQLErrorEvent.ERROR, errorHandler);
			
		}
		
		public function  creatDB():Boolean
		{
			try {
				sqlConnection.open(file, SQLMode.CREATE );
				 
				 
				text = "CREATE TABLE page (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL,  data TEXT  , resources TEXT, id_help INTEGER NOT NULL);";
				execute();
				
				text = "CREATE TABLE help (id INTEGER PRIMARY KEY AUTOINCREMENT, toc XML, id_product INTEGER NOT NULL, id_locale INTEGER NOT NULL);";
				execute();
				
				
				text = "CREATE TABLE product (id INTEGER PRIMARY KEY AUTOINCREMENT, name CHAR NOT NULL, version CHAR NOT NULL);";
				execute();
				
				text = "CREATE TABLE locale (id INTEGER PRIMARY KEY AUTOINCREMENT, name CHAR NOT NULL);";
				execute();
				
				sqlConnection.close();
				
			} catch (err:SQLError) {
				// since there is no column "name", an error will be thrown
				sqlConnection.close();
				
				localizeError(err);
				return false;
			}
			
			return true;
		}
		
		private function localizeError(e:SQLError):void 
		{
				var argsLength:int = e.detailArguments.length;
				switch (e.detailID) 
				{
					case 2030:
					// default details string: "trigger '%s' already exists"
					// do stuff
						break;
					// ... other cases ...
					case 2036:
					// default details string: "no such column: '%s[.%s[.%s]]'"
						var colPath:String = "";
						if (argsLength == 1) 
						{
							colPath = e.detailArguments[0];
						} else if (argsLength == 2) 
						{
							colPath = e.detailArguments[0]+"."+e.detailArguments[1];
						} else if (argsLength == 3) 
						{
							colPath = e.detailArguments[0]+"."+e.detailArguments[1]+"."+e.detailArguments[2];
						}
			// or use the locale information to generate a localized string
						displayLocalizedDetail("Column '" + colPath + "' does not exist.");
						break;
				default:
					displayLocalizedDetail(e.details);
			}
		}
		
		
		public function locale(value:String):Boolean
		{
			
			try {
				sqlConnection.open(file, SQLMode.UPDATE );
				 
				 
				text = "INSERT INTO locale(name) VALUES('en_us');";
				execute();
				
				
				sqlConnection.close();
				
			} catch (err:SQLError) 
			{
				sqlConnection.close();
				
				localizeError(err);
				return false;
			}
			
			return true;
		}
		
		public function getLocale():Array
		{
			
			try {
				sqlConnection.open(file, SQLMode.UPDATE );
				 
				 
				text = "SELECT ALL  name FROM locale;";
				execute();
				sqlConnection.close();
				var result:SQLResult = getResult();
				return result.data;
			
			} catch (err:SQLError) 
			{
				sqlConnection.close();
				
				localizeError(err);
				return new Array();
			}
			return new Array();
		}
			
		private function displayLocalizedDetail(str:String):void 
		{
			trace(str)
		// display error detail
		}

		private function resultHandler(event:SQLEvent):void 
		{
			trace("  SQLEvent Ok! ");
		}
		
		
		private function errorHandler(event:SQLErrorEvent):void 
		{
			trace("!!!!!!!!!!!!!!!!!  SQLErrorEvent !!!!!!!!!!!!!!!");
		}
	}
}