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
	
	import mx.controls.Alert;

	public class SQLProxy
	{
		private var file : File;

		private var connection : SQLConnection = new SQLConnection();


		public function SQLProxy()
		{
			super();
			file = File.applicationStorageDirectory.resolvePath("HelpDB.db");
		}

		/**
		 * create tables in DB if not exist
		 * 
		 * @return 
		 * 
		 */		
		public function creatDB() : Boolean
		{
			var sqlStatement : SQLStatement = new SQLStatement;
			sqlStatement.sqlConnection = connection;
			sqlStatement.addEventListener(SQLEvent.RESULT, resultHandler);
			sqlStatement.addEventListener(SQLErrorEvent.ERROR, errorHandler);

			try
			{
				sqlStatement.sqlConnection.open(file, SQLMode.CREATE );

				/*****************  !!!   проверить необходимость создания каждой таблички отдельно !!!   *******************/

				//       PAGE    (id, name, version, title, description, content ) //
				sqlStatement.text = "CREATE TABLE IF NOT EXISTS page   (id INTEGER PRIMARY KEY AUTOINCREMENT, " +
					"name TEXT NOT NULL,  " +
					"version INTEGER NOT NULL,  " +
					"title TEXT NOT NULL,  " +
					"description TEXT , " +
					"content TEXT, " +
					"mark TEXT, " +
					"useToc INTEGER NOT NULL,  " +
					"id_product INTEGER);";
				sqlStatement.execute();
				
				
				sqlStatement.text = "SELECT useToc FROM page;";
				try {
					sqlStatement.execute();
				} catch (e:Error) {
					sqlStatement.text = "ALTER TABLE page ADD COLUMN useToc INTEGER;";
					sqlStatement.execute();
					
					sqlStatement.text = "UPDATE page SET useToc = 1";
					sqlStatement.execute();
				}
				
				//       PRODUCT  (id, name, version, title, description, language, toc )   //
				sqlStatement.text = "CREATE TABLE IF NOT EXISTS product (id INTEGER PRIMARY KEY AUTOINCREMENT, " +
					"name CHAR NOT NULL, " +
					"version INTEGER NOT NULL,  " +
					"title TEXT NOT NULL,  " +
					"description TEXT , " +
					"language TEXT," +
					"toc XML);";
				sqlStatement.execute();
				sqlStatement.sqlConnection.close();

			}
			catch ( err : SQLError )
			{
				// since there is no column "name", an error will be thrown
				sqlStatement.sqlConnection.close();

				localizeError(err);
				return false;
			}

			return true;
		}

		/**
		 * add new (empty) product to DB 
		 * (if this product doesn't exist)
		 * 
		 * @param name
		 * @param version
		 * @param title
		 * @param description
		 * @param language
		 * 
		 */		
		public function addProduct(name:String, version:int, title:String, 
								   description:String,
								   language:String) : void
		{
			var query : String      = "SELECT product.id " +
				"FROM product " +
				"WHERE name = :name " +
				" AND version = :version " +
				" AND language = :language ;";

			var parameters : Object = new Object();
			parameters[ ":name" ] = name;
			parameters[ ":version" ] = version;
			parameters[ ":language" ] = language;

			var result : Object = executeQuery(query, parameters);

			if ( !result )
			{
				query = "INSERT INTO product(name, version, title, description, language, toc) " +
					"VALUES(:name, :version, :title, :description, :language, :toc);";

				parameters = [];
				parameters[ ":name" ] = name;
				parameters[ ":version" ] = version;
				parameters[ ":title" ] = title;
				parameters[ ":description" ] = description;
				parameters[ ":language" ] = language;
				parameters[ ":toc" ] = "<page title = '" +
					title + "' name = '" + name + "' isBranch='true' />";

				executeQuery(query, parameters);
			}
		}
		
		/**
		 * delete product from DB 
		 * (if this product exists)
		 * 
		 * @param productsName
		 * @param language
		 * @return 
		 * 
		 */		
		public function deleteProduct(productsName:String, language:String) : Object
		{
			var query : String      = "SELECT id " +
				"FROM product " +
				"WHERE name = :name  AND language = :language;";

			var parameters : Object = new Object();
			parameters[ ":name" ] = productsName;
			parameters[ ":language" ] = language;

			var result : Object = executeQuery(query, parameters);


			if ( result )
			{
				var id_product : Number = result[ 0 ][ "id" ];
				query = "DELETE " +
					"FROM page " +
					"WHERE id_product = :id_product ; ";

				parameters = [];
				parameters[ ":id_product" ] = id_product;

				executeQuery(query, parameters);

				query = "DELETE " +
					"FROM  product " +
					"WHERE id = :id_product ; ";

				executeQuery(query, parameters);
			}



			return result;
		}

		/**
		 * return object that consists of all products in DB
		 * (or null if there are no products in DB)
		 * 
		 * @return 
		 * 
		 */		
		public function getAllProducts() : Object
		{
			var query : String      = "SELECT * " +
				"FROM product;";

			var parameters : Object = new Object();

			var result : Object     = executeQuery(query, parameters);

			if ( !result )
				return null;
			return result;
		}

		/**
		 * get version of specific product in DB
		 * (or "" if this product doesn't exist)
		 *   
		 * @param name
		 * @param language
		 * @return 
		 * 
		 */		
		public function getVersionOfProduct(name:String, language:String):String
		{
			
			var query:String = "SELECT product.version " + 
				"FROM product " + 
				"WHERE name = :name " + 
				" AND language = :language ;";
			
			var parameters:Object = new Object();
			parameters[":name"] = name;
			parameters[":language"] = language;
			
			var result:Object = executeQuery(query, parameters);
			
			if(!result)
			{
				return "";
			}
			return result[0]["version"];
		}
		
		/**
		 * get product form DB by product name 
		 *  
		 * @param productsName
		 * @return 
		 * 
		 */		
		public function productInDB(productsName:String) : Object
		{
			var query : String      = "SELECT  name " +
				"FROM product " +
				"WHERE name = :name ;";

			var parameters : Object = new Object();
			parameters[ ":name" ] = productsName;

			var result : Object = executeQuery(query, parameters);

			return result;
		}


		/**
		 * get toc of product by product name
		 *   
		 * @param productName
		 * @return 
		 * 
		 */		
		public function getToc(productName:String) : Object
		{

			var query : String      = "SELECT product.toc " +
				"FROM product " +
				" WHERE   name = :name ;";

			var parameters : Object = new Object();
			parameters[ ":name" ] = productName;

			var result : Object = executeQuery(query, parameters);

			return result[ 0 ][ "toc" ];
		}

		/**
		 * set toc for specific product (by product name) in DB
		 *  
		 * @param toc
		 * @param productName
		 * @return 
		 * 
		 */		
		public function setToc(toc:String, productName:String) : Object
		{
			var query : String      = "UPDATE product " +
				"SET toc = :toc " +
				"WHERE name = :name ;";

			var parameters : Object = new Object();
			parameters[ ":name" ] = productName;
			parameters[ ":toc" ] = toc;

			var result : Object = executeQuery(query, parameters);

			return result;
		}

		/**
		 * checks whether there is a page with that name in DB 
		 * 
		 * @param pageName
		 * @return 
		 * 
		 */		
		public function checkPageName(pageName:String) : Object
		{
			var query : String      = "SELECT id " +
				"FROM page " +
				" WHERE   name = :name ;";

			var parameters : Object = new Object();
			parameters[ ":name" ] = pageName;

			var result : Object = executeQuery(query, parameters);

			return result;
		}

		/**
		 * add new page for specific product to DB  
		 * (if this product exists in DB)  
		 *  
		 * @param productName
		 * @param language
		 * @param pageName
		 * @param version
		 * @param title
		 * @param description
		 * @param content
		 * 
		 */		
		public function addPage(productName:String, language:String, pageName:String, 
								version:int, 
								title:String,
								description:String,
								content:String) : void
		{

			var query : String      = "SELECT id " +
				"FROM product " +
				"WHERE name = :name  AND language = :language;";

			var parameters : Object = new Object();
			parameters[ ":name" ] = productName;
			parameters[ ":language" ] = language;

			var result : Object = executeQuery(query, parameters);

			if ( result )
			{
				var productID : int = result[ 0 ][ 'id' ];
				query = "INSERT INTO page(name, version, title, description, content, id_product, useToc) " +
					"VALUES(:pageName , :version, :title,	:description, :content, :id_product, 1);";

				parameters = [];
				parameters[ ":pageName" ] = pageName;
				parameters[ ":version" ] = version;
				parameters[ ":title" ] = title;
				parameters[ ":description" ] = description;
				parameters[ ":content" ] = content;
				parameters[ ":id_product" ] = productID;

				executeQuery(query, parameters);
			}
		}

		/**
		 * gets page by name for specific product from DB
		 * (if this product exists in DB)
		 *   
		 * @param productName
		 * @param language
		 * @param pageName
		 * @return 
		 * 
		 */		
		public function getPage(productName:String, language:String, pageName:String) : Object
		{
			var query : String      = "SELECT id " +
				"FROM product " +
				"WHERE name = :name  AND language = :language;";

			var parameters : Object = new Object();
			parameters[ ":name" ] = productName;
			parameters[ ":language" ] = language;

			var result : Object = executeQuery(query, parameters);

			if ( result )
			{
				var productID : int = result[ 0 ][ 'id' ];

				query = "SELECT * " +
					"FROM page " +
					"WHERE name = :name  AND id_product = :id_product ;";

				parameters = {};
				parameters[ ":name" ] = pageName;
				parameters[ ":id_product" ] = productID;

				result = executeQuery(query, parameters);
			}

			return result;

		}
		
		/**
		 * update page content and version for specific product from DB
		 * 
		 * @param productName
		 * @param language
		 * @param pageName
		 * @param content
		 * @param version
		 * @return 
		 * 
		 */
		public function setPageContent(productName:String, language:String, pageName:String, content:String, version:int ) : Object
		{
			var query : String      = "SELECT id " +
				"FROM product " +
				"WHERE name = :name  AND language = :language;";

			var parameters : Object = new Object();
			parameters[ ":name" ] = productName;
			parameters[ ":language" ] = language;

			var result : Object = executeQuery(query, parameters);

			if ( result )
			{
				var productID : int = result[ 0 ][ 'id' ];

				query = "UPDATE page " +
					"SET content = :content , version = :version " +
					"WHERE name = :name  AND id_product = :id_product ;";

				parameters = {};
				parameters[ ":name" ] = pageName;
				parameters[ ":id_product" ] = productID;
				parameters[ ":content" ] = content;
				parameters[ ":version" ] = version + 1;


				result = executeQuery(query, parameters);
			}

			return result;
		}

		/**
		 * get all pages for specific product
		 * 
		 * @param productName
		 * @param language
		 * @return 
		 * 
		 */		
		public function getProductsPages(productName:String, language:String) : Object
		{
			var query : String      = "SELECT id " +
				"FROM product " +
				"WHERE name = :name  AND language = :language;";

			var parameters : Object = new Object();
			parameters[ ":name" ] = productName;
			parameters[ ":language" ] = language;

			var result : Object = executeQuery(query, parameters);

			if ( result )
			{
				var productID : int = result[ 0 ][ 'id' ];

				query = "SELECT * " +
					"FROM page " +
					"WHERE  id_product = :id_product ;";

				parameters = [];
				parameters[ ":id_product" ] = productID;

				result = executeQuery(query, parameters);

			}

			return result;
		}
		
		/**
		 * get id of product
		 *  
		 * @param productName
		 * @param language
		 * @return 
		 * 
		 */		
		public function getProductId(productName:String, language:String) : Number
		{
			var query : String      = "SELECT id " +
				"FROM product " +
				"WHERE name = :name  AND language = :language;";
			
			var parameters : Object = new Object();
			parameters[ ":name" ] = productName;
			parameters[ ":language" ] = language;
			
			var result : Object = executeQuery(query, parameters);
			
			if (result) {
				return Number(result[ 0 ][ 'id' ]);
			}
			
			return NaN;
		}

		/**
		 * increments product version
		 * 
		 * @param productName
		 * @param language
		 * @return 
		 * 
		 */		
		public function upVersion(productName:String, language:String) : String
		{
			var query : String      = "SELECT id, version " +
				"FROM product " +
				"WHERE name = :name  AND language = :language;";

			var parameters : Object = new Object();
			parameters[ ":name" ] = productName;
			parameters[ ":language" ] = language;

			var result : Object = executeQuery(query, parameters);

			if ( result )
			{
				var productVersion : int = result[ 0 ][ 'version' ] + 1;
				var productID : int      = result[ 0 ][ 'id' ];


				query = "UPDATE product " +
					"SET  version = :version " +
					"WHERE id = :id;";

				parameters = [];
				parameters[ ":id" ] = productID;
				parameters[ ":version" ] = productVersion;

				result = executeQuery(query, parameters);

			}
			return productVersion.toString();
		}

		/**
		 * update product properties (specify product by product id)
		 *  
		 * @param id
		 * @param title
		 * @param name
		 * @param description
		 * @return 
		 * 
		 */		
		public function changeProductProperties( id:Number, title:String, name:String, description:String) : Object
		{
			var query : String      = "UPDATE product " +
				"SET name = :name , title = :title ,  description = :description " +
				"WHERE id = :id ;";

			var parameters : Object = new Object();
			parameters[ ":id" ] = id;
			parameters[ ":title" ] = title;
			parameters[ ":name" ] = name;
			parameters[ ":description" ] = description;

			var result : Object = executeQuery(query, parameters);

			return result;
		}

		/**
		 * update page properties (specify page by product name, language and page id)
		 * 
		 * @param productName
		 * @param ln
		 * @param oldPageName
		 * @param newPageName
		 * @param title
		 * @param description
		 * @return 
		 * 
		 */		
		public function changePageProperties( productName:String, ln:String, oldPageName:String, newPageName:String, title:String, 
											  description:String, newContent:String, useToc:Boolean) : Object
		{
			var query : String      = "SELECT id " +
				"FROM product " +
				"WHERE name = :name  AND language = :language;";

			var parameters : Object = new Object();
			parameters[ ":name" ] = productName;
			parameters[ ":language" ] = ln;

			var result : Object = executeQuery(query, parameters);

			if ( result )
			{
				query = "UPDATE page " +
					"SET name = :new_name , title = :title ,  description = :description , content = :newContent , useToc = :useToc " +
					"WHERE id_product = :id_product AND name = :old_name ;";

				var id_product : Number = result[ 0 ][ 'id' ];

				parameters = {};
				parameters[ ":id_product" ] = id_product;
				parameters[ ":title" ] = title;
				parameters[ ":new_name" ] = newPageName;
				parameters[ ":old_name" ] = oldPageName;
				parameters[ ":description" ] = description;
				parameters[ ":newContent" ] = newContent;
				parameters[ ":useToc" ] = useToc;

				result = executeQuery(query, parameters);

				query = "SELECT * " +
					"FROM page " +
					"WHERE name = :new_name  AND id_product = :id_product;";

				parameters = {};
				parameters[ ":id_product" ] = id_product;
				parameters[ ":new_name" ] = newPageName;


				result = executeQuery(query, parameters);
			}
			return result;
		}

		/**
		 * import product to DB
		 * (product can be not empty)
		 * 
		 * @param name
		 * @param version
		 * @param title
		 * @param description
		 * @param language
		 * @param toc
		 * 
		 */		
		public function setProduct(name:String, version:int, title:String,
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
								"VALUES(:name, :version, :title, :description, :language, :toc);";

					parameters = [];
					parameters[":name"] = name;
					parameters[":version"] = version;
					parameters[":title"] = title;
					parameters[":description"] = description;
					parameters[":language"] = language;
					parameters[":toc"] = toc.children().toXMLString();

					executeQuery(query, parameters);
				}


		}

		/**
		 * get version of specific page (by page name) 
		 * @param pageName
		 * @return 
		 * 
		 */		
		public function getVersionOfPage(productId:Number, pageName:String):String
		{
			var query:String = "SELECT page.version, page.id  FROM page WHERE name = :pageName " +
																	   " AND id_product = :productId ;";
			var parameters:Object = new Object();
				parameters[":pageName"] = pageName;
				parameters[":productId"] = productId;

			var result:Object = executeQuery(query,parameters);
			if(!result)
			{
				return "";
			}
			return result[0]["version"];
		}

		/**
		 * delet specific page (by page name) form DB 
		 * @param namePage
		 * 
		 */		
		public function deletePage(productId:Number, namePage:String):void
		{
			var query:String = "DELETE FROM 	page WHERE name = :namePage" +
														   " AND id_product = :productId ;";
			var parameters:Object = new Object();
				parameters[":namePage"] = namePage;
				parameters[":productId"] = productId;
				
			executeQuery(query, parameters);
		}

		/**
		 * executes SQL query
		 *  
		 * @param query
		 * @param parameters
		 * @return 
		 * 
		 */		
		private function executeQuery(query:String, parameters:Object) : Object
		{
			var sqlStatement : SQLStatement = new SQLStatement;
			sqlStatement.sqlConnection = connection;
			sqlStatement.addEventListener(SQLEvent.RESULT, resultHandler);
			sqlStatement.addEventListener(SQLErrorEvent.ERROR, errorHandler);

			try
			{
				sqlStatement.sqlConnection.open(file, SQLMode.UPDATE );
				sqlStatement.text = query;

				for ( var name : String in parameters )
				{
					sqlStatement.parameters[ name ] = parameters[ name ];
				}

				sqlStatement.execute();


				var result : SQLResult = sqlStatement.getResult();
				sqlStatement.sqlConnection.close();
			}
			catch ( err : SQLError )
			{
				sqlStatement.sqlConnection.close();

				localizeError(err);
				return null;
			}
			return result.data;
		}

		private function resultHandler(event:SQLEvent) : void
		{
			//trace("  SQLEvent Ok! ");
		}

		/**
		 * show alert that describes an error 
		 * @param str
		 * 
		 */		
		private function displayLocalizedDetail(str:String) : void
		{
			trace(str);
			Alert.show(str, AlertMessages.MSG_TYPE_SQL_ERROR);
		}


		private function errorHandler(event:SQLErrorEvent) : void
		{
			trace("!!!!!!!!!!!!!!!!!  SQLErrorEvent !!!!!!!!!!!!!!!");
		}

		/**
		 * determines the type of SQL error
		 *  
		 * @param e
		 * 
		 */		
		private function localizeError(e:SQLError) : void
		{
			var argsLength : int = e.detailArguments.length;

			switch ( e.detailID )
			{
				case 2030:
					// default details string: "trigger '%s' already exists"
					// do stuff
					break;
				// ... other cases ...
				case 2036:
				{
					// default details string: "no such column: '%s[.%s[.%s]]'"
					var colPath : String = "";

					if ( argsLength == 1 )
						colPath = e.detailArguments[ 0 ];
					else if ( argsLength == 2 )
						colPath = e.detailArguments[ 0 ] + "." + e.detailArguments[ 1 ];
					else if ( argsLength == 3 )
						colPath = e.detailArguments[ 0 ] + "." + e.detailArguments[ 1 ] + "." + e.detailArguments[ 2 ];
					// or use the locale information to generate a localized string
					displayLocalizedDetail("Column '" + colPath + "' does not exist.");
					break;
				}
				default:
				{
					displayLocalizedDetail(e.details);
				}
			}
		}

	}
}
