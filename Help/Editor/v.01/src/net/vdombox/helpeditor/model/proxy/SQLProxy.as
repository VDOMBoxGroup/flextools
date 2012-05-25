package net.vdombox.helpeditor.model.proxy
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
	
	import net.vdombox.helpeditor.model.vo.TemplateVO;
	import net.vdombox.helpeditor.model.AlertMessages;

	public class SQLProxy
	{
		private var file : File;

		private var sqlStatement : SQLStatement = new SQLStatement();

		public function SQLProxy()
		{
			super();
			file = File.applicationStorageDirectory.resolvePath("HelpDB.db");
			
			sqlStatement.sqlConnection = new SQLConnection();
		}

		private function addHandlers () : void
		{
			if (!sqlStatement.hasEventListener(SQLEvent.RESULT))
				sqlStatement.addEventListener(SQLEvent.RESULT, resultHandler);
			
			if (!sqlStatement.hasEventListener(SQLErrorEvent.ERROR))
				sqlStatement.addEventListener(SQLErrorEvent.ERROR, errorHandler);
		}
		
		private function removeHandlers () : void
		{
			sqlStatement.removeEventListener(SQLEvent.RESULT, resultHandler);
			sqlStatement.removeEventListener(SQLErrorEvent.ERROR, errorHandler);
		}
		/**
		 * create tables in DB if not exist
		 * 
		 * @return 
		 * 
		 */	
		
		public function creatDB() : Boolean
		{
			addHandlers();

			try
			{
				sqlStatement.sqlConnection.open(file, SQLMode.CREATE );

				/*****************  !!!   проверить необходимость создания каждой таблички отдельно !!!   *******************/

				tryToCreatePageTable();
				
				tryToCreateProductTable();
				
				tryToCreatePagesSyncronizationTable();
				
				tryToCreateTemplateTable();
				
				tryToCreateFoldersTable();
				
				sqlStatement.sqlConnection.close();
				removeHandlers();

			}
			catch ( err : SQLError )
			{
				// since there is no column "name", an error will be thrown
				sqlStatement.sqlConnection.close();
				removeHandlers();

				localizeError(err);
				return false;
			}

			return true;
		}
		
		private function tryToCreatePageTable () : void
		{
			//       PAGE    (id, name, version, title, description, content ) //
			sqlStatement.text = "CREATE TABLE IF NOT EXISTS page   (id INTEGER PRIMARY KEY AUTOINCREMENT, " +
				"name TEXT NOT NULL,  " +
				"version INTEGER NOT NULL,  " +
				"title TEXT NOT NULL,  " +
				"description TEXT , " +
				"content TEXT, " +
				"mark TEXT, " +
				"useToc INTEGER NOT NULL,  " +
				"sync_group TEXT,  " +
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
			
			sqlStatement.text = "SELECT sync_group FROM page;";
			try {
				sqlStatement.execute();
			} catch (e:Error) {
				sqlStatement.text = "ALTER TABLE page ADD COLUMN sync_group TEXT;";
				sqlStatement.execute();
			}
		}
		
		private function tryToCreateProductTable () : void
		{
			//       PRODUCT  (id, name, version, title, description, language, toc )   //
			sqlStatement.text = "CREATE TABLE IF NOT EXISTS product (id INTEGER PRIMARY KEY AUTOINCREMENT, " +
				"name CHAR NOT NULL, " +
				"version INTEGER NOT NULL,  " +
				"title TEXT NOT NULL,  " +
				"description TEXT , " +
				"language TEXT," +
				"toc XML);";
			
			sqlStatement.execute();
		}
		
		private function tryToCreatePagesSyncronizationTable () : void
		{
			//       PAGES_SYNC  (id, group_name, group_title, pages)   //
			sqlStatement.text = "CREATE TABLE IF NOT EXISTS pages_sync (id INTEGER PRIMARY KEY AUTOINCREMENT, " +
				"group_name TEXT NOT NULL, " +
				"group_title TEXT NOT NULL, " +
				"pages TEXT);";
			
			sqlStatement.execute();
		}
		
		private function tryToCreateTemplateTable () : void
		{
			//       TEMPLATE  (id, name, content )   //
			sqlStatement.text = "CREATE TABLE IF NOT EXISTS template (id INTEGER PRIMARY KEY AUTOINCREMENT, " +
								"name CHAR NOT NULL, " +
								"content TEXT, " +
								"folder TEXT" +
								");";
			
			sqlStatement.execute();
		}
		
		private function tryToCreateFoldersTable () : void
		{
			//       template_folder  (id, name)   //
			sqlStatement.text = "CREATE TABLE IF NOT EXISTS template_folder (id INTEGER PRIMARY KEY AUTOINCREMENT, " +
				"name CHAR NOT NULL);";
			
			sqlStatement.execute();
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
								content:String) : Boolean
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
				query = "INSERT INTO page(name, version, title, description, content, id_product, useToc, sync_group) " +
					"VALUES(:pageName , :version, :title,	:description, :content, :id_product, 1, :sync_group);";

				parameters = [];
				parameters[ ":pageName" ] = pageName;
				parameters[ ":version" ] = version;
				parameters[ ":title" ] = title;
				parameters[ ":description" ] = description;
				parameters[ ":content" ] = content;
				parameters[ ":id_product" ] = productID;
				parameters[ ":sync_group" ] = "";

				executeQuery(query, parameters);
				
				return true;
			} 
			
			return false;
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
		
		public function getPageVersion (pageName:String) : Object
		{
			var query : String = "SELECT * " +
				"FROM page " +
				"WHERE name = :name;";
			
			var parameters : Object = {};
			parameters[ ":name" ] = pageName;
			
			var result : Object = executeQuery(query, parameters);
			
			if (!result)
				return "";
			
			return result[0]["version"];
			
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
		public function setPageContent(pageName:String, content:String, version:int ) : void
		{
			var query : String = "UPDATE page " +
								"SET content = :content, version = :version " +
								"WHERE name = :name;";

			var parameters : Object = {};
			parameters[ ":name" ] = pageName;
			parameters[ ":content" ] = content;
			parameters[ ":version" ] = version + 1;

			executeQuery(query, parameters);
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
		
		public function changePageSyncProperty( pageName:String, syncGroupName:String) : Object
		{
			var query : String = "UPDATE page " +
								"SET sync_group = :sync_group " +
								"WHERE name = :page_name ;";
			
			var parameters : Object = {};
			parameters[ ":page_name" ] = pageName;
			parameters[ ":sync_group" ] = syncGroupName;
			
			var result : Object = executeQuery(query, parameters);
		
			return result;
		}
		
		public function getPageSyncGroup (pageName:String) : String
		{
			var query : String = "SELECT sync_group " +
								"FROM page " +
								"WHERE name = :name;";
			
			var parameters : Object = {};
			parameters[ ":name" ] = pageName;
			
			var result : Object = executeQuery(query, parameters);
			
			if (!result)
				return "";
			
			return result[ 0 ][ 'sync_group' ];
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
			removePageFromSyncGroup(namePage);
			
			var query:String = "DELETE FROM 	page WHERE name = :namePage" +
														   " AND id_product = :productId ;";
			var parameters:Object = new Object();
				parameters[":namePage"] = namePage;
				parameters[":productId"] = productId;
				
			executeQuery(query, parameters);
			
		}
		
		public function addSyncGroup (groupName:String, groupTitle:String, pages:Array) : void
		{
			var query : String      = "SELECT pages_sync.id " +
				"FROM pages_sync " +
				"WHERE group_name = :name;";
			
			var parameters : Object = new Object();
			parameters[ ":name" ] = groupName;
			
			var result : Object = executeQuery(query, parameters);
			
			if ( !result )
			{
				query = "INSERT INTO pages_sync(group_name, group_title, pages) " +
					"VALUES(:name, :title, :pages);";
				
				parameters = [];
				parameters[ ":name" ] = groupName;
				parameters[ ":title" ] = groupTitle;
				parameters[ ":pages" ] = !pages ? "" : pages.join(",");
				
				result = executeQuery(query, parameters);
			}
		}
		
		public function updateSyncGroupTitle (groupName:String, groupTitle:String) : void
		{
			var query : String    = "UPDATE pages_sync " +
									"SET group_title = :group_title " +
									"WHERE group_name = :group_name;";
			
			var parameters : Object = new Object();
			parameters[ ":group_title" ] = groupTitle;
			parameters[ ":group_name" ] = groupName;
			
			var result : Object = executeQuery(query, parameters);
		}
		
		public function updateSyncGroupPages (groupName:String, groupPages:Array) : void
		{
			var query : String    = "UPDATE pages_sync " +
				"SET pages = :pages " +
				"WHERE group_name = :group_name;";
			
			var parameters : Object = new Object();
			parameters[ ":group_name" ] = groupName;
			parameters[ ":pages" ] = groupPages.join(",");
			
			executeQuery(query, parameters);
		}

		public function removeSyncGroup (groupName:String) : void
		{
			clearPagesSyncProperty(groupName);
			
			var query:String = "DELETE FROM pages_sync WHERE group_name = :name;";
			
			var parameters:Object = new Object();
			parameters[":name"] = groupName;
			
			executeQuery(query, parameters);
		}
		
		public function addPageToSyncGroup (pageName : String, groupName:String) : void
		{
			var groupPages : Array = getGroupPages(groupName);
			
			if (!groupPages)
				groupPages = [pageName];
			else 
				groupPages.push(pageName);
			
			updateSyncGroupPages(groupName, groupPages);
			
			changePageSyncProperty(pageName, groupName);
		}
		
		public function removePageFromSyncGroup (pageName : String, groupName : String = "") : void
		{
			var syncGroupName : String = groupName || getPageSyncGroup(pageName);
			
			if (!syncGroupName)
				return;
			
			var groupPages : Array = getGroupPages(syncGroupName);
			
			if (!groupPages)
				return;
			
			var pageIndex : int = groupPages.indexOf(pageName);
			
			if (pageIndex >= 0)
			{
				groupPages.splice(pageIndex,1);
				
				updateSyncGroupPages(syncGroupName, groupPages);
			}
			
			changePageSyncProperty(pageName, "");
		}
		
		public function getGroupPages (groupName:String) : Array
		{
			var query : String      = "SELECT pages_sync.pages FROM pages_sync WHERE group_name = :name ;";
			
			var parameters : Object = new Object();
			parameters[ ":name" ] = groupName;
			
			var result : Object = executeQuery(query, parameters);
	
			if (!result)
				return null;
			
			var pagesStr : String = result[0]["pages"];
			
			if (!pagesStr)
				return null;
			
			return pagesStr.split(",");
		}
		
		private function clearPagesSyncProperty (groupName : String) : void
		{
			var groupPages : Array = getGroupPages(groupName);
			
			if (!groupPages)
				return;
			
			for each (var pageName : String in groupPages)
			{
				changePageSyncProperty(pageName, "");
			}
			
		}
		
		public function getAllSyncGroups() : Object
		{
			var query : String      = "SELECT * FROM pages_sync;";
			
			var parameters : Object = new Object();
			
			var result : Object     = executeQuery(query, parameters);
			
			if ( !result )
				return null;
			
			return result;
		}
		
		public function syncronizePagesContent (sourcePageName:String, sourcePageContent:String, groupName:String) : void
		{
			var groupPages : Array = getGroupPages(groupName);
			
			if (!groupPages)
				return;
			
			for each (var pageName : String in groupPages)
			{
				if (sourcePageName == pageName)
					continue;
				
				var pageVersion : Number = Number(getPageVersion(pageName));
				pageVersion = isNaN(pageVersion) ? 0 : pageVersion + 1;
				
				setPageContent(pageName, sourcePageContent, pageVersion);
			}
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
			addHandlers();
			
			try
			{
				sqlStatement.sqlConnection.open(file, SQLMode.UPDATE );
				sqlStatement.text = query;

				sqlStatement.clearParameters();
				
				for (var name:String in parameters )
				{
					sqlStatement.parameters[ name ] = parameters[ name ];
				}

				sqlStatement.execute();


				var result : SQLResult = sqlStatement.getResult();
				
				sqlStatement.sqlConnection.close();
				removeHandlers();
			}
			catch ( err : SQLError )
			{
				sqlStatement.sqlConnection.close();
				removeHandlers();

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
		
		// template table ...
		public function addTemplate (name:String, content:String, folderName:String) : void
		{
			var query : String      = "SELECT template.id " +
									"FROM template " +
									"WHERE name = :name;";
			
			var parameters : Object = {};
			parameters[ ":name" ] = name;
			
			var result : Object = executeQuery(query, parameters);
			
			if ( !result )
			{
				query = "INSERT INTO template(name, content, folder) " +
						"VALUES(:name, :content, :folderName);";
				
				parameters = [];
				parameters[ ":name" ] = name;
				parameters[ ":content" ] = content;
				parameters[ ":folderName" ] = folderName;
				
				executeQuery(query, parameters);
			}
		}
		
		public function removeTemplate (name:String) : void
		{
			var query:String = "DELETE FROM template WHERE name = :name;";
			
			var parameters:Object = {};
			parameters[":name"] = name;
			
			executeQuery(query, parameters);
		}
		
		public function updateTemplateName (name:String, newName:String) : void
		{
			var query : String = "UPDATE template " +
								"SET name = :newName " +
								"WHERE name = :name;";
			
			var parameters : Object = {};
			parameters[ ":name" ] = name;
			parameters[ ":newName" ] = newName;
			
			executeQuery(query, parameters);

		}
		
		public function updateTemplateContent (name:String, content:String) : void
		{
			var query : String = "UPDATE template " +
				"SET content = :content " +
				"WHERE name = :name;";
			
			var parameters : Object = {};
			parameters[ ":name" ] = name;
			parameters[ ":content" ] = content;
			
			executeQuery(query, parameters);
			
		}
		
		public function getTemplateContent (name:String) : String
		{
			var query : String = "SELECT content " +
									"FROM template " +
									"WHERE name = :name;";
			
			var parameters : Object = {};
			parameters[ ":name" ] = name;
			
			var result : Object = executeQuery(query, parameters);
			
			if (!result)
				return "";
			
			return result[0]["content"];
		}
		
		public function updateTemplateFolder (name:String, folder:String) : void
		{
			var query : String = "UPDATE template " +
								"SET folder = :content " +
								"WHERE name = :name;";
			
			var parameters : Object = {};
			parameters[ ":name" ] = name;
			parameters[ ":folder" ] = folder;
			
			executeQuery(query, parameters);
			
		}
		
		public function getTemplateFolder (name:String) : String
		{
			var query : String = "SELECT folder " +
								"FROM template " +
								"WHERE name = :name;";
			
			var parameters : Object = {};
			parameters[ ":name" ] = name;
			
			var result : Object = executeQuery(query, parameters);
			
			if (!result)
				return "";
			
			return result[0]["folder"];
		}
		
		public function getAllTemplates() : Array
		{
			var query : String      = "SELECT * FROM template;";
			
			var result : Object     = executeQuery(query, {});
			
			if ( !result )
				return null;
			
			return convertTemplates(result);
		}
		
		private function convertTemplates(templates:Object) : Array
		{
			if (!templates)
				return null;
			
			var resultTemplates : Array = [];
			
			for each (var template : Object in templates)
			{
				resultTemplates.push(new TemplateVO(template));
			}
			
			return resultTemplates;
		}
		
		public function getTemplatesByFolderName (folderName:String) : Array
		{
			var query : String      = "SELECT * FROM template WHERE folder=:folderName;";
			
			var parameters : Object = {};
			parameters[ ":folderName" ] = folderName;
			
			var result : Object     = executeQuery(query, parameters);
			 
			if ( !result )
				return null;
				
			return convertTemplates(result);
		}
		// ... template table
		
		// template folders ...
		public function getAllFolders() : Object
		{
			var query : String      = "SELECT * FROM template_folder;";
			
			var result : Object     = executeQuery(query, {});
			
			if ( !result )
				return null;
			
			return result;
		}
		
		public function addFolder (name:String) : void
		{
			var query : String      = "SELECT id " +
										"FROM template_folder " +
										"WHERE name = :name;";
			
			var parameters : Object = {};
			parameters[ ":name" ] = name;
			
			var result : Object = executeQuery(query, parameters);
			
			if ( !result )
			{
				query = "INSERT INTO template_folder(name) " +
						"VALUES(:name);";
				
				executeQuery(query, parameters);
			}
		}
		
		public function removeFolder (name:String) : void
		{
			var query:String = "DELETE FROM template_folder WHERE name = :name;";
			
			var parameters:Object = {};
			parameters[":name"] = name;
			
			executeQuery(query, parameters);
		}
		
		public function updateFolderName (name:String, newName:String) : void
		{
			var query : String = "UPDATE template_folder " +
									"SET name = :newName " +
									"WHERE name = :name;";
			
			var parameters : Object = {};
			parameters[ ":name" ] = name;
			parameters[ ":newName" ] = newName;
			
			executeQuery(query, parameters);
			
			query = "UPDATE template " +
					"SET folder = :folder " +
					"WHERE folder = :oldFolder;";
			
			parameters = {};
			parameters[ ":oldFolder" ] = name;
			parameters[ ":folder" ] = newName;
			
			executeQuery(query, parameters);
		}
		// ... template folders

	}
}
