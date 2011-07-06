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
		public static var PARSING_COMPLETED		: String = "PARSING_COMPLETED";
		
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

				trace("'''''Will Copy JS File  \n" + JSFileName);
				var JSURL  : URLRequest = new URLRequest(JSFileName);
				var JSLoader : URLLoader  = new URLLoader(JSURL);
				
				JSLoader.addEventListener(Event.COMPLETE, startCopyJSFile);
				
				trace("'''''Will Copy css File  \n" + cssFileName);
				var cssURL  : URLRequest = new URLRequest(cssFileName);
				var cssLoader : URLLoader  = new URLLoader(cssURL);
				
				cssLoader.addEventListener(Event.COMPLETE, startCopyCSSFile);
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
		
		private function startCopyCSSFile(evt:Event):void
		{
			var byteArray:ByteArray = new ByteArray();
			byteArray.writeMultiByte(evt.target.data + "\n", "UTF-8");
			
			var newFile:File = File.applicationStorageDirectory.resolvePath(cssFileName);
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
		
		
		public function parsingData(product:XML, lstLabel:Label):void
		{
			if(product == null || product.name() != "product")
			{
//				if(product.produc[])
				trace("!!!!!!!!!!!! not Correct data from server !!!!!!!!!!!!!");
				this.dispatchEvent(new Event(PARSING_COMPLETED));
				lstLabel.text = "not Correct data from server";
				lstLabel.validateNow();
				return;
			}
			
			product = resetProductXML(product);
			
			var name:String = product.name.toString();
			var version:String = product.version.toString();
			var title:String = product.title.toString();
			var description:String = product.description.toString();
			var language:String = product.language.toString();
			var toc:XML = tocToBD(product.toc[0],language, name);
			var productId : Number;
			
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
			
			productId = sqlProxy.getProductId(name, language);
			if (isNaN(productId)) return;
			
			savePages(product, productId);
			
			
			lstLabel.text = "Fineshed ";
			this.dispatchEvent(new Event(PARSING_COMPLETED));
//			creatTree(toc);
			
		}
		
		private function resetProductXML(productXML:XML) : XML
		{
			productXML = resetResourceLinksInProductXML(productXML);
			productXML = resetPageLinksInProductXML(productXML);
			
			return productXML; 
		}
		
		private function resetResourceLinksInProductXML(productXML:XML):XML
		{
			var xmlString 		: String;
			var pattern 		: RegExp;
			var arrMatch 		: Array;
			var resourceGUID	: String;
			var patternLastInd	: Number;
			var newResPath 		: String;
			
			xmlString = productXML.toXMLString();
			pattern = /\#Res\([A-F0-9]{8}(?:-[A-F0-9]{4}){3}-[A-Z0-9]{12}\)/ig;
			arrMatch = xmlString.match(pattern);
			
			for each ( var oldResName : String in arrMatch )
			{
				resourceGUID = oldResName.substr(5, 36);
				patternLastInd = xmlString.search(pattern) + oldResName.length; 
				newResPath = "resources/" + resourceGUID + "." + getResourceType(xmlString.substring(patternLastInd, xmlString.length), resourceGUID);
				xmlString = xmlString.replace(oldResName, newResPath);
			}
			
			return new XML(xmlString);
		}
		
		private function resetPageLinksInProductXML(productXML:XML):XML
		{
			return productXML;
		}
		
		private function getResourceType(content:String, resourceName:String) : String
		{
			var pattern 		: RegExp;
			var arrMatch 		: Array;
			var resourceType 	: String = "";
			
			pattern = /type[ ]*=[ ]*"[A-Z]+"/i;
			
			if (content.indexOf(resourceName) != -1) {
				content = content.substring(content.indexOf(resourceName) + resourceName.length, content.length);
				
				arrMatch = content.match(pattern);
				if (arrMatch.length > 0) {
					resourceType = String(arrMatch[0]).split("\"")[String(arrMatch[0]).split("\"").length - 2]
				}
			}
			
			return resourceType;
		}
		
		private function tocToBD(value:XML, lan:String, product:String):XML
		{
			changeStruxcture(value);
		
			return value ;
			
			function changeStruxcture(xml:XML):void
			{
				for each(var page:XML in xml.children())
				{
					if (String(page.@name).indexOf(".html") < 0) {
						page.@name = lan + "/" + product + "/"  + page.@name + ".html";
					}
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
		
		
		private function savePages(product:XML, productId:Number):void
		{
			var productName:String =  product.name.toString(); 
			var language:String =  product.language.toString(); 
			var location:String = language +"/"+productName+"/"; 
			
			//********* Creat PAGES ***********//
			for each(var page:XML in product.pages.children())
			{
				var pageName:String = page.name.toString();
				
				if (pageName.indexOf(".html") < 0) {
					pageName += ".html"; 
				}
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
				
				var curPageVersion:String = sqlProxy.getVersionOfPage(productId, pageLocation);
				
				if(curPageVersion == '')
				{
					sqlProxy.setPage(productName, language, pageLocation, version, title, description, content);
				}
				else if (Number(curPageVersion)< Number(version))
				{
					//delete old data
					deletePage(productId, pageLocation);
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
			var productId : Number = sqlProxy.getProductId(name, language);
			
			if (isNaN(productId)) return;
			
			for (var page:String in pages)
			 deletePage(productId, pages[page].name);
			 
			sqlProxy.deleteProduct(name, language);
		}
		
		private function deletePage(productId:Number, namePage:String):void
		{
			var resources:Object = sqlProxy.getResourcesOfPage(namePage);
			
			for(var index:String in resources)
			{
				deleteFile(resources[index]['name']);
			}
			
			sqlProxy.deleteResources(productId, namePage);
			sqlProxy.deletePage(productId, namePage);
			
		}
		
		private function deleteFile(location:String):void
		{
			trace("Delete: " + location);
			var newFileName:String = location;
			var newFile:File = File.applicationStorageDirectory.resolvePath(newFileName);
			if (newFile.exists) {
				newFile.deleteFile();
			}
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