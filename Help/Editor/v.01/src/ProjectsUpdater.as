package
{
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import mx.automation.delegates.controls.NavBarAutomationImpl;
	import mx.core.ContextualClassFactory;
	import mx.utils.Base64Decoder;

	public class ProjectsUpdater extends EventDispatcher
	{
		public static var UPDATE_COMPLETED	: String = "UPDATE_COMPLETED";
		public static var UPDATE_CANCELED	: String = "UPDATE_CANCELED";
		
		private var sqlProxy : SQLProxy = new SQLProxy();
		
		public function ProjectsUpdater()
		{
		}
		
		public function parseXMLData(product:XML):void
		{ 
			product = resetPagesLinks(product);
			
			if(product == null || product.name() != "product")
			{
				trace("!!!!!!!!!!!! not Correct data from server !!!!!!!!!!!!!");
				this.dispatchEvent(new Event(UPDATE_CANCELED));
				return;
			}
			
			var name:String = product.name.toString();
			var version:int = int(product.version);
			var title:String = product.title.toString();
			var description:String = product.description.toString();
			var language:String = product.language.toString();
			var toc:XML = tocToBD(product.toc[0],language, name);
			var productId : Number;
			
			// save product to data base
			var curProductVersion:String = sqlProxy.getVersionOfProduct(name, language);			
			if(curProductVersion == '')
			{
				//sqlProxy.setPage(productName, language, pageLocation, version, title, description, content);
				sqlProxy.setProduct(name,version,title,description, language, toc);
			}
			else if (int(curProductVersion)< version)
			{
				//delete old data Find nessasri page 
				deleteProduct(name, language);
				//					sqlProxy.setPage(productName, language, pageLocation, version, title, description, content);
				
				sqlProxy.setProduct(name, version, title, description, language, toc);
			}
			
			// выбрать странички сохранить их на диск
			productId= sqlProxy.getProductId(name, language);
			
			if (isNaN(productId)) return;
			
			savePages(product, productId);
			
			this.dispatchEvent(new Event(UPDATE_COMPLETED));
		}
		
		private function resetPagesLinks(xml: XML):XML
		{
			var pattern		 : RegExp;
			var arrMatch	 : Array;
			var strXML		 : String;
			var strPageGUID	 : String;
			
			
			strXML = xml.toXMLString();
			
			pattern = /\#Page\([A-F0-9]{8}(?:-[A-F0-9]{4}){3}-[A-Z0-9]{12}\)/ig;
			arrMatch = strXML.match(pattern);
			
			var i:uint = 0;
			for each ( var oldPageName : String in arrMatch )
			{
				strPageGUID = oldPageName.substr(6, 36);
				strXML = strXML.replace(oldPageName, strPageGUID);
			}
			
			return new XML(strXML);
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
			sqlProxy.deletePage(productId, namePage);
		}
		
		private function savePages(product:XML, productId:Number):void
		{
			var productName:String =  product.name.toString(); 
			var language:String =  product.language.toString(); 
			var location:String = language +"/"+productName+"/"; 
			
			//********* Creat PAGES ***********//
			for each(var page:XML in product.pages.children())
			{
				var pageName:String = page.name.toString();// + ".html"; 
				var version:String = page.version.toString(); 
				var title:String = page.title.toString();
				var description:String = page.description.toString();
				var content:String = contentToBD(page.content.toString(), page.resources.toString());
				var pageLocation:String = location + pageName;
				
				//				arrayOfPages[pageLocation] = true;
				//				sqlProxy.
				
				// проверяем есть ли эта страница уже в базе. берем версию страницы ////getVersionOfPage(): string//////
				// страница не найдена - записываем
				// страница найдена 1) старая - удаляем, записываем 2) такая же - пропускаем				
				// deletePage(namePage); getResourcesOfPage(namePage):Array; deleteResorces(namePage);
				
				var curPageVersion:String = sqlProxy.getVersionOfPage(productId, pageName);
				
				if(curPageVersion == '')
				{
					sqlProxy.addPage(productName, language, pageName, Number(version), title, description, content);
				}
				else if (Number(curPageVersion)< Number(version))
				{
					//delete old data
					deletePage(productId, pageLocation);
					sqlProxy.addPage(productName, language, pageName, Number(version), title, description, content);
				} else
				{
					continue;
				}
				
				//*************  Creat Resources  ***************//
				for each(var resource:XML in page.resources.children())
				{
					var base64:Base64Decoder = new Base64Decoder();
					base64.decode(resource.toString());
					
					var byteArray0:ByteArray = base64.toByteArray();
					
					var resourceName:String = "resources/"+ resource.@id + "." + resource.@type;
					
					cacheFile(resourceName , byteArray0);
				}
				
			}
			
		}  
		
		private function contentToBD(content:String, resources:String):String
		{
			return resetImgPath(content, resources);
		}
		
		private function resetImgPath(content:String, resources:String) : String
		{
			var pattern 		: RegExp;
			var patternLastInd	: Number;
			var arrMatch 		: Array;
			var newResPath 		: String;
			var newContent		: String;
			var pageType		: String;
			var resourceGUID	: String;
			
			
			newContent = content;
			
			pattern = /\#Res\([A-F0-9]{8}(?:-[A-F0-9]{4}){3}-[A-Z0-9]{12}\)/ig;
			arrMatch = content.match(pattern);
			
			var i:uint = 0;
			for each ( var oldResName : String in arrMatch )
			{
				resourceGUID = oldResName.substr(5, 36);
				patternLastInd = content.search(pattern) + oldResName.length; 
				newResPath = "app-storage:/resources/" + resourceGUID + "." + getResourceType(resources, resourceGUID);
				newContent = newContent.replace(oldResName, newResPath);
			}
			
			return newContent;
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
		
		public function cacheFile(contentName:String, content:ByteArray):void 
		{
			var fileStream:FileStream = new FileStream();
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
		
		private function tocToBD(value:XML, lan:String, product:String):XML
		{
			changeStruxcture(value);
			
			return value ;
			
			function changeStruxcture(xml:XML):void
			{
				for each(var page:XML in xml.children())
				{
					if (String(page.@name).lastIndexOf("/") >= 0) {
						page.@name = String(page.@name).substring(String(page.@name).lastIndexOf("/")+1, String(page.@name).length);
					}
					
					if (String(page.@name).lastIndexOf(".") >= 0) {
						page.@name = String(page.@name).substring(0, String(page.@name).lastIndexOf("."));
					}
					page.@isBranch = "true"; 
					changeStruxcture(page);
				}
			}
		}
		
	}
}