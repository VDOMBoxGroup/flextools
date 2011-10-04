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
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.utils.Base64Decoder;
	
	import spinnerFolder.SpinnerPopUpManager;
	import spinnerFolder.SpinnerPopupMessages;
	
	public class ProductUpdator extends EventDispatcher 
	{
		private static const STATE_PRODUCT_XML_LOADING		: String = "stateProductXMLLoading";
		private static const STATE_PRODUCT_XML_PARSING		: String = "stateProductXMLParsing";
		
		private static const STATE_PRODUCT_CREATING			: String = "stateProductCreating";
		private static const STATE_PAGES_GENERATING			: String = "statePagesGenerating";
		private static const STATE_PAGE_START_GENERATING	: String = "statePageStartGenerating";
		private static const STATE_PAGE_GENERATING_COMPLETE	: String = "statePageGeneratingComplete";
		private static const STATE_LAST_PAGE_GENERATED		: String = "stateLastPageGenerated";
		
		private static const STATE_PROJECT_UPDATE_COMPLETE				: String = "stateProjectUpdateComplete";
		private static const STATE_PROJECT_UPDATE_CANCELED				: String = "stateProjectUpdateCanceled";
		private static const STATE_PROJECT_UPDATE_NOT_REQUIRED			: String = "stateProjectUpdateNotRequired";
		
		
		private var xmlLoader				: ProductXMLLoader = new ProductXMLLoader();
		
		private var sqlProxy				: SQLProxy = new SQLProxy();
		
		private var spinnerManager : SpinnerPopUpManager = SpinnerPopUpManager.getInstance();
		
		private var productXML				: XML;
		private var productPages			: XMLList;
		private var currentPage				: XML;
		private var pagesCounter			: Number = 0;
		private var location				: String = "";
		private var productId				: Number;
		private var productName				: String = ""; 
		private var productTitle			: String = "";
		private var language				: String = "";
		
		private var fileStream				: FileStream = new FileStream();
		
		private var curState			: String;
		
		private var curPageMsg			: String = "";
		private var curPageResourceMsg	: String = "";
		private var curProductMsg		: String = "";
		private var spinnerCurPageTxt	: String = "";
		
		public function ProductUpdator()
		{
			
		}
		
		private function onAppEnterFrame(aEvent : Event):void
		{
			switch(curState)
			{
				case STATE_PRODUCT_XML_LOADING:
				{
					curProductMsg = SpinnerPopupMessages.MSG_PRODUCT_NAME;
					curProductMsg = curProductMsg.replace(SpinnerPopupMessages.TEMPLATE_PRODUCT_TITLE, productTitle);
					spinnerManager.setSpinnerProductText(curProductMsg);
					
					spinnerManager.setSpinnerText(SpinnerPopupMessages.MSG_PRODUCT_XML_LOADING);
					break;
				}
				
				case STATE_PRODUCT_XML_PARSING:
				{
					curProductMsg = SpinnerPopupMessages.MSG_PRODUCT_NAME;
					curProductMsg = curProductMsg.replace(SpinnerPopupMessages.TEMPLATE_PRODUCT_TITLE, productTitle);
					spinnerManager.setSpinnerProductText(curProductMsg);
					
					spinnerManager.setSpinnerText(SpinnerPopupMessages.MSG_PARSING_XML);
					
					parseData (new XML(xmlLoader.xmlFile.data));
					break;
				}
				case STATE_PRODUCT_CREATING:
				{
					curProductMsg = SpinnerPopupMessages.MSG_PRODUCT_NAME;
					curProductMsg = curProductMsg.replace(SpinnerPopupMessages.TEMPLATE_PRODUCT_TITLE, productTitle);
					spinnerManager.setSpinnerProductText(curProductMsg);
					
					spinnerManager.setSpinnerText(SpinnerPopupMessages.MSG_PRODUCT_CREATING);
					
					createProduct();
					break;					
				}
				case STATE_PAGES_GENERATING:
				{
					spinnerManager.setSpinnerText(SpinnerPopupMessages.MSG_PAGES_CREATING);
					
					savePages();
					break;					
				}	
				case STATE_PAGE_START_GENERATING:
				{
					if (pagesCounter < productPages.length())
					{
						spinnerCurPageTxt = SpinnerPopupMessages.MSG_PAGE_CREATING;
						spinnerCurPageTxt = spinnerCurPageTxt.replace(SpinnerPopupMessages.TEMPLATE_CUR_PAGE, (pagesCounter+1).toString());
						spinnerCurPageTxt = spinnerCurPageTxt.replace(SpinnerPopupMessages.TEMPLATE_TOTAL_PAGES, productPages.length().toString());
						
						spinnerManager.setSpinnerText(spinnerCurPageTxt);
					}
					
					generateNextPage();
					break;
				}
				case STATE_PAGE_GENERATING_COMPLETE:
				{
					onPageGenerated();
					break;
				}
				case STATE_LAST_PAGE_GENERATED:
				{
					onLastPageGenerated();
					break;
				}
				case STATE_PROJECT_UPDATE_CANCELED:
				{
					Application.application.removeEventListener(Event.ENTER_FRAME, onAppEnterFrame);
					
					spinnerManager.setSpinnerText("");
					spinnerManager.setSpinnerProductText("");
					
					this.dispatchEvent(new ProductsUpdatorEvent(ProductsUpdatorEvent.UPDATE_ERROR));
					break;
				}
				case STATE_PROJECT_UPDATE_COMPLETE:
				{
					Application.application.removeEventListener(Event.ENTER_FRAME, onAppEnterFrame);
					
					spinnerManager.setSpinnerText("");
					spinnerManager.setSpinnerProductText("");
					
					this.dispatchEvent(new ProductsUpdatorEvent(ProductsUpdatorEvent.UPDATE_COMPLETE));
					break;
				}
				case STATE_PROJECT_UPDATE_NOT_REQUIRED:
				{
					Application.application.removeEventListener(Event.ENTER_FRAME, onAppEnterFrame);
					
					spinnerManager.setSpinnerText("");
					spinnerManager.setSpinnerProductText("");
					
					this.dispatchEvent(new ProductsUpdatorEvent(ProductsUpdatorEvent.UPDATE_ERROR));
					break;
				}
				default:
					break;
			}
		}
		
		public function load(url:String, title:String = ""):void
		{
			productTitle = title;
			xmlLoader.addEventListener(ProductXMLLoader.XML_FILE_LOADED,			 xmlLoaderHandler);
			xmlLoader.addEventListener(ProductXMLLoader.XML_FILE_LOADING_ERROR,		 xmlLoaderHandler);
			
			xmlLoader.loadXMLFile(url);
			
			curState = STATE_PRODUCT_XML_LOADING;
			
			Application.application.addEventListener(Event.ENTER_FRAME, onAppEnterFrame);
		}
		
		private function xmlLoaderHandler(evt:Event):void
		{
			xmlLoader.removeEventListener(ProductXMLLoader.XML_FILE_LOADED,			 xmlLoaderHandler);
			xmlLoader.removeEventListener(ProductXMLLoader.XML_FILE_LOADING_ERROR,	 xmlLoaderHandler);
			
			switch (evt.type) 
			{
				case ProductXMLLoader.XML_FILE_LOADED :
					curState = STATE_PRODUCT_XML_PARSING;
					break;
				
				case ProductXMLLoader.XML_FILE_LOADING_ERROR :
					curState = STATE_PROJECT_UPDATE_CANCELED;
					break;
			}
			
		}
		
		public function parseData(product:XML):void
		{
			productXML = null;
			
			if (!Application.application.hasEventListener(Event.ENTER_FRAME))
				Application.application.addEventListener(Event.ENTER_FRAME, onAppEnterFrame);
			
			if (product == null || product.name() != "product")
			{
				curState = STATE_PROJECT_UPDATE_CANCELED;
				return;
			}
			
			productXML = product;
			
			productTitle = productXML.title.toString();
			
			curState = STATE_PRODUCT_CREATING;
		}
		
		private function createProduct () : void 
		{
			productXML = resetProductXML();
			
			var name:String = productXML.name.toString();
			var version:String = productXML.version.toString();
			var title:String = productXML.title.toString();
			var description:String = productXML.description.toString();
			var language:String = productXML.language.toString();
			var toc:XML = tocToBD(productXML.toc[0],language, name);
			
			// save product to data base
			var curProductVersion:String = sqlProxy.getVersionOfProduct(name, language);
			
			if(curProductVersion == '')
			{
				sqlProxy.setProduct(name,version,title,description, language,toc);
			}
			else 
			{
				if (Number(curProductVersion)< Number(version))
				{
					//delete old data Find nessesary page 
					deleteProduct(name, language);
					
					sqlProxy.setProduct(name, version, title, description, language,toc);
				} else
				{
					curState = STATE_PROJECT_UPDATE_NOT_REQUIRED;
					return;
				}
			}
			
			// save loaded data to local diskDrive 
			saveLoadedXMLData( productXML);
			
			productId = sqlProxy.getProductId(name, language);
			if (isNaN(productId))
			{
				curState = STATE_PROJECT_UPDATE_CANCELED;
				return;
			}
			
			curState = STATE_PAGES_GENERATING;
		
		}
		
		private function resetProductXML() : XML
		{
			productXML = resetResourceLinksInProductXML();
			productXML.toc = resetPagesLinksInProductXML(productXML.toc[0]);
			productXML.pages = resetPagesLinksInProductXML(productXML.pages[0], false);
			
			return productXML; 
		}
		
		private function resetResourceLinksInProductXML():XML
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
		
		private function resetPagesLinksInProductXML(xml:XML, isToc:Boolean = true):XML
		{
			var xmlString 		: String;
			var pattern 		: RegExp;
			var arrMatch 		: Array;
			var pageGUID		: String;
			var newPagesPath	: String;
			
			xmlString = xml.toXMLString();
			
			pattern = /\#Page\([A-F0-9]{8}(?:-[A-F0-9]{4}){3}-[A-Z0-9]{12}\)/ig;
			arrMatch = xmlString.match(pattern);
			
			for each ( var oldResName : String in arrMatch )
			{
				pageGUID = oldResName.substr(6, 36);
				newPagesPath = isToc ? pageGUID : pageGUID + ".html";
				xmlString = xmlString.replace(oldResName, newPagesPath);
			}
			
			return new XML(xmlString);
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
		
		private function saveLoadedXMLData(product:XML):void
		{
			var byteArray : ByteArray = new ByteArray();
			byteArray.writeMultiByte(product.toXMLString()+"\n", "UTF-8");
				
			var fileName : String = product.name.toString()+ ".xml";
			cacheFile( fileName, byteArray);
		}
		
		private function savePages():void
		{
			productName =  productXML.name.toString(); 
			language =  productXML.language.toString(); 
			
			location = language +"/"+productName+"/"; 
			
			productPages = productXML.pages.children();
			
			if ( !productPages || productPages.length() <= 0 ) {
				curState = STATE_LAST_PAGE_GENERATED;
				return;
			}

			curState = STATE_PAGE_START_GENERATING;
		}
		
		private function generateNextPage():void
		{
			if (pagesCounter >= productPages.length())
			{
				curState = STATE_LAST_PAGE_GENERATED;
				return;
			}
			
			currentPage = productPages[pagesCounter];
			
			var pageName:String = currentPage.name.toString();
			
			if (pageName.indexOf(".html") < 0) {
				pageName += ".html"; 
			}
			var version:String = currentPage.version.toString(); 
			var title:String = currentPage.title.toString();
			var description:String = currentPage.description.toString();
			var content:String = currentPage.content.toString();
			var pageLocation:String = location + pageName;
			
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
				curState = STATE_PAGE_GENERATING_COMPLETE;
				return;
			}
			
			var byteArray : ByteArray = new ByteArray();
			byteArray.writeMultiByte(currentPage.content.toString()+"\n", "UTF-8");
			
			cacheFile(pageLocation, byteArray);
			
			//*************  Creat Resources  ***************//
			for each(var resource:XML in currentPage.resources.children())
			{
				var base64 : Base64Decoder = new Base64Decoder();
				base64.decode(resource.toString());
				
				var byteArray0 : ByteArray = base64.toByteArray();
				
				var resourceName : String = "resources/"+ resource.@id + "." + resource.@type;
				
				cacheFile(location + resourceName , byteArray0);
				
				sqlProxy.setResource(pageLocation, location + resourceName);
			}
			
			curState = STATE_PAGE_GENERATING_COMPLETE;
		}
		
		private function onPageGenerated():void
		{
			pagesCounter ++;
			
			curState = STATE_PAGE_START_GENERATING;
		}
		
		private function onLastPageGenerated():void
		{
			productPages = null;
			productXML = null;
			pagesCounter = 0;
			
			curState = STATE_PROJECT_UPDATE_COMPLETE;
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
			var newFileName:String = location;
			var newFile:File = File.applicationStorageDirectory.resolvePath(newFileName);

			if (newFile.exists) {
				newFile.deleteFile();
			}
		}
		
		public function cacheFile(contentName:String, content:ByteArray):void 
		{
			var newFileName:String = contentName;
			var newFile:File = File.applicationStorageDirectory.resolvePath(newFileName);

			try 
			{
				fileStream.open(newFile, FileMode.WRITE);
				fileStream.writeBytes(content);
				fileStream.close();
			} 
			catch(error:IOError) 
			{
				trace ("[ProductUpdator] cacheFile error: " + error.message);
			}
		}

	}
}