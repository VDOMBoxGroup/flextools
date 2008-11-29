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
	
	public class SQLProxy extends SQLStatement 
	{
		private var  file:File ;
//		private var connection:SQLConnection = new SQLConnection();
//		private var selectStatement:SQLStatement;
		
		public function SQLProxy()
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
				 
				 /*****************  !!!   проверить необходимость создания каждой таблички отдельно !!!   *******************/
				 
				//       PAGE    (id, name, version, title, description, content ) //
				text = "CREATE TABLE page   (id INTEGER PRIMARY KEY AUTOINCREMENT, " + 
											"name TEXT NOT NULL,  " + 
											"version TEXT NOT NULL,  " + 
											"title TEXT NOT NULL,  " + 
											"description TEXT , " + 
											"content TEXT);";
				execute();
				
				//       PRODUCT  (id, name, version, title, description, language, toc )   //
				text = "CREATE TABLE product (id INTEGER PRIMARY KEY AUTOINCREMENT, " + 
												"name CHAR NOT NULL, " + 
												"version TEXT NOT NULL,  " + 
												"title TEXT NOT NULL,  " + 
												"description TEXT , " + 
												"language TEXT,"+
												"toc XML);";
				execute();
				
				text = "CREATE TABLE resource  (id INTEGER PRIMARY KEY AUTOINCREMENT, " + 
											"name TEXT NOT NULL,  " + 
											"id_page INTEGER);";
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
		
/*		
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
	*/	
	//       PRODUCT  (id, name, version, title, description, language, toc )   //
	
		/// ********* curentPruduct, curentPage ******************************	
		public function setProduct(name:String, version:String, title:String, 
																description:String,
																language:String,
																toc:XML):int
		{
			try {
				sqlConnection.open(file, SQLMode.UPDATE );
				 
				text = "SELECT product.id " + 
						"FROM product " + 
						"WHERE ((name ='"+ name +"') AND (version='"+ version +"') AND (language='"+ language +"'));";
				execute();
//				sqlConnection.close();
				var result:SQLResult = getResult();
				
				if( result.data)
				{
					sqlConnection.close();
					return -1;
				}
				
				text = "INSERT INTO product(name, version, title, description, language, toc) " + 
						"VALUES('"+ name +"','"+ version +"','"+ title +"','"+ 
																description +"','"+ 
																language +"','"+ 
																toc.toString() +"');";
				execute();
				
				
				text = "SELECT product.id " + 
						"FROM product " + 
						"WHERE ((name ='"+ name +"') AND (version='"+ version +"') AND (language='"+ language +"'));";
				execute();
				result = getResult();
				
				sqlConnection.close();
			} catch (err:SQLError) 
			{
				sqlConnection.close();
				
				localizeError(err);
				return -1;
			}
			
			return result.data[0]['id'];
		}
		/*
		public function creatHelp(value:String):Boolean
		{
			try {
				sqlConnection.open(file, SQLMode.UPDATE );
				 
				text = "SELECT ALL  name FROM product WHERE name='"+value+"';";
				execute();
				
				var result:SQLResult = getResult();
				if( !result.data)
				{
					text = "INSERT INTO product(name) VALUES('"+value+"');";
					execute();
				}
				
				sqlConnection.close();
			} catch (err:SQLError) 
			{
				sqlConnection.close();
				
				localizeError(err);
				return false;
			}
			
			return true;
		}
		*/
			
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