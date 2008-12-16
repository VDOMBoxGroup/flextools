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
		
		
		public function SQLProxy()
		{
			super();
			
			
			file = File.applicationStorageDirectory.resolvePath("HelpDB.db");
			
			
		}
		
		public function  creatDB():Boolean
		{
			var sqlStatement:SQLStatement = new SQLStatement;
			 		sqlStatement.sqlConnection = connection;
					sqlStatement.addEventListener(SQLEvent.RESULT, resultHandler);
					sqlStatement.addEventListener(SQLErrorEvent.ERROR, errorHandler);
			
			try {
				sqlStatement.sqlConnection.open(file, SQLMode.CREATE );
				 
				 /*****************  !!!   проверить необходимость создания каждой таблички отдельно !!!   *******************/
				 
				//       PAGE    (id, name, version, title, description, content ) //
				sqlStatement.text = "CREATE TABLE IF NOT EXISTS page   (id INTEGER PRIMARY KEY AUTOINCREMENT, " + 
											"name TEXT NOT NULL,  " + 
											"version TEXT NOT NULL,  " + 
											"title TEXT NOT NULL,  " + 
											"description TEXT , " + 
											"content TEXT, " + 
											"id_product INTEGER);";
				sqlStatement.execute();
				
				//       PRODUCT  (id, name, version, title, description, language, toc )   //
				sqlStatement.text = "CREATE TABLE IF NOT EXISTS product (id INTEGER PRIMARY KEY AUTOINCREMENT, " + 
												"name CHAR NOT NULL, " + 
												"version TEXT NOT NULL,  " + 
												"title TEXT NOT NULL,  " + 
												"description TEXT , " + 
												"language TEXT,"+
												"toc XML);";
				sqlStatement.execute();
				
				sqlStatement.text = "CREATE TABLE IF NOT EXISTS resource  (id INTEGER PRIMARY KEY AUTOINCREMENT, " + 
											"name TEXT NOT NULL,  " + 
											"id_page INTEGER);";
				sqlStatement.execute();
				
				sqlStatement.text = "CREATE INDEX IF NOT EXISTS index_name ON  page(content)";
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
		
	//       PRODUCT  (id, name, version, title, description, language, toc )   //
	
		/// ********* curentPruduct, curentPage ******************************	
		public function setProduct(name:String, version:String, title:String, 
																description:String,
																language:String,
																toc:XML):void
		{
				 
				var query:String = "SELECT product.id " + 
						"FROM product " + 
						"WHERE name = :name " + 
							" AND version = :version " + 
							" AND language = :language ;";
							
				var parameters:Object = new Object();
					parameters[":name"] = name;
					parameters[":version"] = version;
					parameters[":language"] = language;
					
				var result:Object = executeQuery(query, parameters);
				
				if( !result)
				{
					query = "INSERT INTO product(name, version, title, description, language, toc) " + 
								"VALUES(:name, :version, :title, :description, :description, :toc);";
					
					parameters = [];
					parameters[":name"] = name;
					parameters[":version"] = version;
					parameters[":title"] = title;
					parameters[":description"] = description;
					parameters[":description"] = description;
					parameters[":toc"] = toc.toXMLString();
													
					executeQuery(query, parameters);				
				}
				
				
		}
		
		public function getVersionOfPage(pageName:String):String
		{
			var query:String = "SELECT page.version, page.id  FROM page WHERE name = :pageName ;"; 
			var parameters:Object = new Object();
				parameters[":pageName"] = pageName;
								
			var result:Object = executeQuery(query,parameters);
			if(!result)
			{
				return "";
			}
			return result[0]["version"];
		}
		
		public function setPage(productName:String, language:String, pageName:String, 
																		version:String, 
																		title:String,
																		description:String,
																		content:String):void
		{
				
				content = cleanContent(content);
				 
				var query:String = "SELECT product.id " + 
						"FROM product " + 
						"WHERE name = :productName  AND language = :language;";
						
				var parameters:Object = new Object();
					parameters[":productName"] = productName;
					parameters[":language"] = language;
						
				var result:Object = executeQuery(query, parameters);
				
				if( result)
				{
					var productID:int  = result[0]['id'];
					query = "INSERT INTO page(name, version, title, description, content, id_product) " + 
							"VALUES(:pageName , :version, :title,	:description, :content, :productID);";
					
					parameters = [];
					parameters[":pageName"] 	= pageName;
					parameters[":version"] 		= version;
					parameters[":title"] 		= title;
					parameters[":description"] 	= description;
					parameters[":content"] 		= content;
					parameters[":productID"] 	= productID;

					executeQuery(query, parameters);			
				}


		}
	
		public function deletePage(namePage:String):void
		{
			var query:String = "DELETE FROM 	page WHERE name = :namePage";
			var parameters:Object = new Object();
				parameters[":namePage"] = namePage;
			executeQuery(query, parameters);
		}
		
		
		public function deleteResources(namePage:String):void
		{
			
				var query:String = "SELECT page.id FROM 	page  WHERE name = :namePage";
				var parameters:Object = new Object();
					parameters[":namePage"] = namePage;
				
				var result:Object = executeQuery(query, parameters);
				var pageID:int = result[0]['id']; 
				
				query = "DELETE FROM 	resource WHERE id_page = :pageID";
					parameters = [];
					parameters[":pageID"] = pageID;
				executeQuery(query, parameters);
		}
		
		public function getResourcesOfPage(namePage:String):Object
		{
				var query:String  = "SELECT page.id FROM 	page  WHERE name = :namePage";
				var parameters:Object = new Object();
					parameters[":namePage"] = namePage;
				
				var result:Object = executeQuery(query, parameters);
				var pageID:int = result[0]['id']; 
				
				query = "SELECT resource.name  FROM	resource WHERE id_page = :pageID";
				
				parameters = [];
				parameters[":pageID"] = pageID;
				
				result = executeQuery(query, parameters);

				return result;
		}
		
		
		public function setResource(pageName:String, resourceName:String	):void
		{
				var query:String = "SELECT page.id " + 
						"FROM page " + 
						"WHERE (name = :pageName );";
				
				var parameters:Object = new Object();
					parameters[":pageName"] = pageName;						
				var result:Object = executeQuery(query, parameters);
				
				if( result)
				{
					query = "INSERT INTO resource(name, id_page) " + 
							"VALUES (:resourceName, :result);";
					parameters = [];
					parameters[":resourceName"] = resourceName;
					parameters[":result"] = result[0]['id'];
					executeQuery(query, parameters);
				}
				
		}
		
		public function search(	value:String, productName:String = "",	language:String = "en_US"):Object
		{
			var phraseRE:RegExp = /\s+/gim;

			value = " " + value + " ";
			value = value.replace(phraseRE,"%"); 
			
			var query:String = "SELECT page.name, page.title " +
						"FROM product INNER JOIN page ON product.id = page.id_product "+
						"WHERE product.name = :productName " + 
						"	AND page.content = :value  AND product.language = :language;"
			
			var parameters:Object = new Object();
				parameters[":productName"] = productName;
				parameters[":value"] = value;
				parameters[":language"] = language;

			var result:Object = executeQuery(query, parameters);
			
			return result;
		}
		
		private function executeQuery(query:String, parameters:Object):Object
		{
			 var sqlStatement:SQLStatement = new SQLStatement;
			 		sqlStatement.sqlConnection = connection;
					sqlStatement.addEventListener(SQLEvent.RESULT, resultHandler);
					sqlStatement.addEventListener(SQLErrorEvent.ERROR, errorHandler);
					
			try {
				sqlStatement.sqlConnection.open(file, SQLMode.UPDATE );
				sqlStatement.text = query;
				
				for(var name:String in parameters )
					sqlStatement.parameters[name] = parameters[name];
				
				sqlStatement.execute();
				
				
				var result:SQLResult = sqlStatement.getResult();
				sqlStatement.sqlConnection.close();
			} 
			catch (err:SQLError) 
			{
				sqlStatement.sqlConnection.close();
				
				localizeError(err);
				return null;
			}
				return result.data;
		}
			
		private function displayLocalizedDetail(str:String):void 
		{
			trace(str)
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