package 
{
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.controls.Label;
	import mx.core.UIComponent;
	import mx.utils.Base64Decoder;
	
	public class Update extends UIComponent 
	{
		private var sqlProxy:SQLProxy = new SQLProxy();
		private var XML_URL:String = "StartXML.xml";
		private var fileStream:FileStream = new FileStream();
		private var myXMLURL:URLRequest;
		private var myLoader:URLLoader;
		private var install:XML = new XML();
		
		private var dispatcher:EventDispatcher = new EventDispatcher();
		
		public function Update()
		{
			
		}
		
		public function frstLoadXML():void
		{
			sqlProxy.creatDB();
			
			loadersArray.removeAll();
			
			myXMLURL = new URLRequest(XML_URL)
			myLoader = new URLLoader(myXMLURL);
			
			myLoader.addEventListener(Event.COMPLETE, startXMLLoaded);
			myLoader.addEventListener(IOErrorEvent.IO_ERROR, startXMLLoaded);
			
			checJSFile();
		}
		 	
		private var JSFileName : String = "searchhi_slim.js";
		private var cssFileName : String = "main.css";
		private function checJSFile():void
		{
			
//			var loadJSFile : File = new File(urlJSFile);
//			loadJSFile.load();
			
			
			var newFile:File = File.applicationStorageDirectory.resolvePath(JSFileName);
			try {
				fileStream.open(newFile, FileMode.READ);
				fileStream.close();
				
			} catch(error:IOError) {
//				var er:* =  error;
				trace("'''''Will Copy JS File  \n" + JSFileName);
				var JSURL  : URLRequest = new URLRequest(JSFileName)
				var JSLoader : URLLoader  = new URLLoader(JSURL);
				
				JSLoader.addEventListener(Event.COMPLETE, startCopyJSFile);
				
				var cssData : String = ".searchword { background-color : #ffff00;}"
			
				var byteArray:ByteArray = new ByteArray();
				byteArray.writeMultiByte(cssData + "\n", "UTF-8");
				
				newFile = File.applicationStorageDirectory.resolvePath(cssFileName);
				try {
					fileStream.open(newFile, FileMode.WRITE);
					fileStream.writeBytes(byteArray);
					fileStream.close();
					
				}catch(error:IOError) {
	//				var er:* =  error;
					trace("!!!!!!!!!!!!!!!! Error Write !!!!!!!!!!!!!!! \n" + error.message +"\n"+ cssFileName);
					return;
				}
			
			}
			
		}
		
		
		private function startCopyJSFile(evt:Event):void
		{
			var byteArray:ByteArray = new ByteArray();
				byteArray.writeMultiByte(evt.target.data + "\n", "UTF-8");
			
			var newFile:File = File.applicationStorageDirectory.resolvePath(JSFileName);
			try {
				fileStream.open(newFile, FileMode.WRITE);
				fileStream.writeBytes(byteArray);
				fileStream.close();
				
			}catch(error:IOError) {
//				var er:* =  error;
				trace("!!!!!!!!!!!!!!!! Error Write !!!!!!!!!!!!!!! \n" + error.message +"\n"+ JSFileName);
				return;
			}
		}
		
		private function startXMLLoaded(event:Event):void
		{
			myLoader.removeEventListener(Event.COMPLETE, startXMLLoaded);
			if(event.type == IOErrorEvent.IO_ERROR)
			{
				dispatchEvent(new HelpEvent(HelpEvent.INSTALL_FILE_LOADED_ERROR, install));
				trace("!!!!!!!!!!!!!! Start XML not Finded !!!!!!!!!")	
			} 
			else if(event.type == Event.COMPLETE)
			{
//			    trace("Start loaded.");
				install = XML(myLoader.data);
				dispatchEvent(new HelpEvent(HelpEvent.INSTALL_FILE_LOADED, install));
				 
				 /*
				for each(var product:XML in install.children())
				{
//					trace(product.@url);
					var xmlURL:URLRequest = new URLRequest(product.@url)
					var loader:URLLoader = new URLLoader(xmlURL);
					loader.addEventListener(Event.COMPLETE, xmlLoaded);
					loader.addEventListener(IOErrorEvent.IO_ERROR, xmlLoaded);
				} 
				*/
			}
		}
		
		private var loadersArray:ArrayCollection = new ArrayCollection();
		public function load(url:String, lstLabel:Label):void
		{
			var xmlURL:URLRequest = new URLRequest(url);
			var loader:URLLoader = new URLLoader(xmlURL);
			
			loadersArray.addItem({loader:loader, lstLabel:lstLabel });
			
			loader.addEventListener(Event.COMPLETE, xmlLoaded);
			loader.addEventListener(IOErrorEvent.IO_ERROR, xmlLoaded);
		}
		
		
		private function xmlLoaded(event:Event):void
		{
			for( var i:String in loadersArray)
			{
				if(loadersArray[i]["loader"] == event.currentTarget)
				{
					var lstLabel:Label = loadersArray[i]["lstLabel"];
				}
			}
			
			if(event.type == IOErrorEvent.IO_ERROR)
			{
//				event.currentTarget.
				trace("!!!! XML not Finded  !!!!")	
				lstLabel.text = "XML not Finded";
			} 
			else if(event.type == Event.COMPLETE)
			{
				lstLabel.text = "XML Loaded";
				
				dispatchEvent(new HelpEvent(HelpEvent.UPDATE_DISPLAY_LIST));
				
			  parsingData(XML(event.target.data), lstLabel);
			    
			}
		}
		
		
		private function parsingData(product:XML, lstLabel:Label):void
		{ 
			if(product == null || product.name() != "product")
			{
//				if(product.produc[])
				trace("!!!!!!!!!!!! not Correct data from server !!!!!!!!!!!!!");
				lstLabel.text = "not Correct data from server";
				lstLabel.validateNow();
				return;
			}
			var name:String = product.name.toString();
			var version:String = product.version.toString();
			var title:String = product.title.toString();
			var description:String = product.description.toString();
			var language:String = product.language.toString();
			var toc:XML = tocToBD(product.toc[0],language, name);
			
			
			// save product to data base
			
			var curProductVersion:String = sqlProxy.getVersionOfProduct(name, language);
				
				if(curProductVersion == '')
				{
//					sqlProxy.setPage(productName, language, pageLocation, version, title, description, content);
					sqlProxy.setProduct(name,version,title,description, language,toc);
				}
				else if (Number(curProductVersion)< Number(version))
				{
					//delete old data Find nessasri page 
					deleteProduct(name, language);
//					sqlProxy.setPage(productName, language, pageLocation, version, title, description, content);
					
					sqlProxy.setProduct(name, version, title, description, language,toc);
				}
			
			// save loaded data to local diskDrive 
			lstLabel.text = "Saving data";
			lstLabel.validateNow();
			saveLoadedData( product);
			
			// выбрать странички сохранить их на диск
			lstLabel.text = "Creating DB ";
			lstLabel.validateNow();
			savePages( product);
			
			lstLabel.text = "Fineshed ";
			
//			creatTree(toc);
			
		}
		
		private function tocToBD(value:XML, lan:String, product:String):XML
		{
			changeStruxcture(value);
		
			return value ;
			
			function changeStruxcture(xml:XML):void
			{
				for each(var page:XML in xml.children())
				{
					page.@name = lan + "/" + product + "/"  + page.@name + ".html";
					changeStruxcture(page);
				}
			}
		}
		
		private function saveLoadedData(product:XML):void
		{
			var byteArray:ByteArray = new ByteArray();
				byteArray.writeMultiByte(product.toXMLString()+"\n", "UTF-8");
				
				var fileName:String =  product.name.toString()+ ".xml";
			cacheFile( fileName, byteArray);
		}
		
		
		private function savePages(product:XML):void
		{
			var productName:String =  product.name.toString(); 
			var language:String =  product.language.toString(); 
			var location:String = language +"/"+productName+"/"; 
			
			//********* Creat PAGES ***********//
			for each(var page:XML in product.pages.children())
			{
				var pageName:String = page.name.toString() + ".html"; 
				var version:String = page.version.toString(); 
				var title:String = page.title.toString();
				var description:String = page.description.toString();
				var content:String = page.content.toString();
				var pageLocation:String = location + pageName;
				
//				arrayOfPages[pageLocation] = true;
//				sqlProxy.

				// проверяем есть ли эта страница уже в базе. берем версию страницы ////getVersionOfPage(): string//////
				// страница не найдена - записываем
				// страница найдена 1) старая - удаляем, записываем 2) такая же - пропускаем				
				// deletePage(namePage); getResourcesOfPage(namePage):Array; deleteResorces(namePage);
				
				var curPageVersion:String = sqlProxy.getVersionOfPage(pageLocation);
				
				if(curPageVersion == '')
				{
					sqlProxy.setPage(productName, language, pageLocation, version, title, description, content);
				}
				else if (Number(curPageVersion)< Number(version))
				{
					//delete old data
					deletePage(pageLocation);
					sqlProxy.setPage(productName, language, pageLocation, version, title, description, content);
				} else
				{
					continue;
				}
				
				
				
				var byteArray:ByteArray = new ByteArray();
					byteArray.writeMultiByte(page.content.toString()+"\n", "UTF-8");
//				var fileName:String = pageName;
				
				cacheFile(pageLocation, byteArray);
				
//				arrayOfPages[pageLocation] = true;
				
				
				//*************  Creat Resources  ***************//
				for each(var resource:XML in page.resources.children())
				{
					var base64:Base64Decoder = new Base64Decoder();
						base64.decode(resource.toString());
					
					var byteArray0:ByteArray = base64.toByteArray();
					
					var resourceName:String = "resources/"+ resource.@id + "." + resource.@type;
					
					cacheFile(location + resourceName , byteArray0);
					
					sqlProxy.setResource(pageLocation, location + resourceName);
				}
			}
			
			
//			pageList.dataProvider = sqlProxy.search("conten of page","VdomHelp_en_US");
			
		}  
		
		private function deleteProduct(name:String, language:String):void
		{
//			get All pages of product 
			var pages:Object = sqlProxy.getProductsPages(name, language);
			for (var page:String in pages)
			 deletePage(pages[page].name);
			 
			sqlProxy.deleteProduct(name, language);
		}
		
		private function deletePage(namePage:String):void
		{
			var resources:Object = sqlProxy.getResourcesOfPage(namePage);
			
			for(var index:String in resources)
			{
				deleteFile(resources[index]['name']);
			}
			
			sqlProxy.deleteResources(namePage);
			sqlProxy.deletePage(namePage);
			
		}
		
		private function deleteFile(location:String):void
		{
			trace("Delete: " + location);
			var newFileName:String = location;
			var newFile:File = File.applicationStorageDirectory.resolvePath(newFileName);
			newFile.deleteFile();
//			trace(newFile.toString())
		}
		
		public function cacheFile(contentName:String, content:ByteArray):void 
		{
			var newFileName:String = contentName;
			var newFile:File = File.applicationStorageDirectory.resolvePath(newFileName);
//			trace(newFile.toString())
				try {
				
				fileStream.open(newFile, FileMode.WRITE);
				fileStream.writeBytes(content);
				fileStream.close();
				
			} catch(error:IOError) {
//				var er:* =  error;
				trace("!!!!!!!!!!!!!!!! Error Write !!!!!!!!!!!!!!! \n" + error.message +"\n"+newFileName);
				return;
			}
		}
		
		/*
		public function addEventListener(type:String, listener:Function, 
						useCapture:Boolean = false, priority:int = 0, 
						useWeakReference:Boolean = false):void 
		{
				dispatcher.addEventListener(type, listener, useCapture, priority);
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return dispatcher.hasEventListener(type);
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			return dispatcher.dispatchEvent(event);
		}
	
		public function removeEventListener(type:String, listener:Function, 
										useCapture:Boolean = false):void
		{
			dispatcher.removeEventListener(type, listener, useCapture);
		}
	
		
		public function willTrigger(type:String):Boolean
		{
			return dispatcher.willTrigger(type);
		}
*/


	}
}