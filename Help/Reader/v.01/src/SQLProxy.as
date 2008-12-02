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
	
	public class SQLProxy 
	{
		private var  file:File ;
		private var connection:SQLConnection = new SQLConnection();
		private var sqlStatement:SQLStatement = new SQLStatement;
		
		public function SQLProxy()
		{
			super();
			
			
			file = File.applicationStorageDirectory.resolvePath("HelpDB.db");
			sqlStatement.sqlConnection = connection;
			sqlStatement.addEventListener(SQLEvent.RESULT, resultHandler);
			sqlStatement.addEventListener(SQLErrorEvent.ERROR, errorHandler);
			
		}
		
		public function  creatDB():Boolean
		{
			
			try {
				sqlStatement.sqlConnection.open(file, SQLMode.CREATE );
				 
				 /*****************  !!!   проверить необходимость создания каждой таблички отдельно !!!   *******************/
				 
				//       PAGE    (id, name, version, title, description, content ) //
				sqlStatement.text = "CREATE TABLE page   (id INTEGER PRIMARY KEY AUTOINCREMENT, " + 
											"name TEXT NOT NULL,  " + 
											"version TEXT NOT NULL,  " + 
											"title TEXT NOT NULL,  " + 
											"description TEXT , " + 
											"content TEXT, " + 
											"id_product INTEGER);";
				sqlStatement.execute();
				
				//       PRODUCT  (id, name, version, title, description, language, toc )   //
				sqlStatement.text = "CREATE TABLE product (id INTEGER PRIMARY KEY AUTOINCREMENT, " + 
												"name CHAR NOT NULL, " + 
												"version TEXT NOT NULL,  " + 
												"title TEXT NOT NULL,  " + 
												"description TEXT , " + 
												"language TEXT,"+
												"toc XML);";
				sqlStatement.execute();
				
				sqlStatement.text = "CREATE TABLE resource  (id INTEGER PRIMARY KEY AUTOINCREMENT, " + 
											"name TEXT NOT NULL,  " + 
											"id_page INTEGER);";
				sqlStatement.execute();
				
				sqlStatement.text = "CREATE INDEX index_name ON  page(content)";
				sqlStatement.execute();
				
				sqlStatement.sqlConnection.close();
				
			} catch (err:SQLError) {
				// since there is no column "name", an error will be thrown
				sqlStatement.sqlConnection.close();
				
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
				sqlStatement.sqlConnection.open(file, SQLMode.UPDATE );
				 
				sqlStatement.text = "SELECT product.id " + 
						"FROM product " + 
						"WHERE ((name ='"+ name +"') AND (version='"+ version +"') AND (language='"+ language +"'));";
				sqlStatement.execute();
//				sqlConnection.close();
				var result:SQLResult = sqlStatement.getResult();
				
				if( result.data)
				{
					sqlStatement.sqlConnection.close();
					return -1;
				}
				
				sqlStatement.text = "INSERT INTO product(name, version, title, description, language, toc) " + 
						"VALUES('"+ name +"','"+ version +"','"+ title +"','"+ 
																description +"','"+ 
																language +"','"+ 
																toc.toString() +"');";
				sqlStatement.execute();
				
				
				sqlStatement.text = "SELECT product.id " + 
						"FROM product " + 
						"WHERE ((name ='"+ name +"') AND (version='"+ version +"') AND (language='"+ language +"'));";
				sqlStatement.execute();
				result = sqlStatement.getResult();
				
				sqlStatement.sqlConnection.close();
			} catch (err:SQLError) 
			{
				sqlStatement.sqlConnection.close();
				
				localizeError(err);
				return -1;
			}
			
			return result.data[0]['id'];
		}
		
		public function setPage(productName:String, language:String, pageName:String, 
																		version:String, 
																		title:String,
																		description:String,
																		content:String):int
		{
			try {
				
				content = cleanContent(content);
				sqlStatement.sqlConnection.open(file, SQLMode.UPDATE );
				 
				sqlStatement.text = "SELECT product.id " + 
						"FROM product " + 
						"WHERE ((name ='"+ productName +"')  AND (language='"+ language +"'));";
				sqlStatement.execute();
//				sqlConnection.close();
				var result:SQLResult = sqlStatement.getResult();
				
				if( !result.data)
				{
					sqlStatement.sqlConnection.close();
					return -1;
				}
				
				
				sqlStatement.text = "INSERT INTO page(name, version, title, description, content, id_product) " + 
						"VALUES('"+ pageName +"','"+ version +"','"+ title +"','"+ 
																description +"','"+ 
																content +"','"+ 
																result.data[0]['id'] +"');";
				sqlStatement.execute();
				
				sqlStatement.sqlConnection.close();

			} catch (err:SQLError) 
			{
				sqlStatement.sqlConnection.close();
				
				localizeError(err);
				return -1;
			}
			
			return result.data[0]['id'];
		}
		
		public function setResource(pageName:String, resourceName:String	):int
		{
			try {
				sqlStatement.sqlConnection.open(file, SQLMode.UPDATE );
				 
				sqlStatement.text = "SELECT page.id " + 
						"FROM page " + 
						"WHERE (name ='"+ pageName +"');";
				sqlStatement.execute();
//				sqlConnection.close();
				var result:SQLResult = sqlStatement.getResult();
				
				if( !result.data)
				{
					sqlStatement.sqlConnection.close();
					return -1;
				}
				
				
				sqlStatement.text = "INSERT INTO resource(name, id_page) " + 
						"VALUES('"+ resourceName +"','"+ result.data[0]['id'] +"');";
				sqlStatement.execute();
				
				sqlStatement.sqlConnection.close();

			} catch (err:SQLError) 
			{
				sqlStatement.sqlConnection.close();
				
				localizeError(err);
				return -1;
			}
			
			return result.data[0]['id'];
		}
		
		public function search(	value:String, productName:String = "",	language:String = "en_US"):Array
		{
			var phraseRE:RegExp = new RegExp("[^\w]+","gimsx");

			value = " " + value + " ";
			value = value.replace(phraseRE,"%"); 
			
			try {
				sqlStatement.sqlConnection.open(file, SQLMode.UPDATE );
				 
				 
				sqlStatement.text = "SELECT page.name, page.title " +
						"FROM product INNER JOIN page ON product.id = page.id_product "+
						"WHERE (((product.name)='"+productName+"') AND ((page.content) LIKE'"+value+"') AND ((product.language)='"+language+"'));"
//				sqlStatement.text = "SELECT page.id " + 
//						"FROM page " + 
//						"WHERE (name ='"+ pageName +"');";
				sqlStatement.execute();
//				sqlConnection.close();
				var result:SQLResult = sqlStatement.getResult();
				
				if( result.data)
				{
					sqlStatement.sqlConnection.close();
					return result.data;
				}
				
				
//				sqlStatement.text = "INSERT INTO resource(name, id_page) " + 
//						"VALUES('"+ resourceName +"','"+ result.data[0]['id'] +"');";
//				sqlStatement.execute();
				
				sqlStatement.sqlConnection.close();

			} catch (err:SQLError) 
			{
				sqlStatement.sqlConnection.close();
				
				localizeError(err);
//				return result.data;
			}
			
			return result.data;
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
		
		private function cleanContent(value:String):String
		{
			var phraseRE1:RegExp = new RegExp("<script.*?>.*?<\/script>|<style.*?>.*?<\/style>|<\/?[a-z][a-z0-9]*[^<>]*>|<!--.*?-->|<\!\[CDATA\[.*?\]\]>|&#?[\w\d]+","gimsx");
			
			var phraseRE2:RegExp = new RegExp("[^\w]+","gimsx");
//  
			var words:String = value.replace(phraseRE1," "); 
//				words = words.replace(phraseRE2," ");
			return words;
		}
	}
}