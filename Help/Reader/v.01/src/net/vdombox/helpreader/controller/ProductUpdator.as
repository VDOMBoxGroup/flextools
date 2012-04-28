package net.vdombox.helpreader.controller 
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
	
	import net.vdombox.helpreader.events.ProductsUpdatorEvent;
	import net.vdombox.helpreader.model.SQLProxy;
	import net.vdombox.helpreader.model.SpinnerPopupMessages;
	
	public class ProductUpdator extends EventDispatcher 
	{
		private static const STATE_PRODUCT_XML_LOADING_STARTS	: String = "stateProductXMLLoadingStarts";
		private static const STATE_PRODUCT_XML_LOADING			: String = "stateProductXMLLoading";
		
		private static const STATE_PRODUCT_XML_PARSING		: String = "stateProductXMLParsing";
		private static const STATE_PRODUCT_TOC_CONVERTING	: String = "stateProductTocConverting";
		
		private static const STATE_PRODUCT_CREATING_STARTS		: String = "stateProductCreatingStarts";
		private static const STATE_PRODUCT_CREATING_ADD_TO_DB	: String = "stateProductCreatingAddToDB";
		private static const STATE_PRODUCT_CREATING_CACHE_XML	: String = "stateProductCreatingCacheXML";
		
		private static const STATE_INSTALLED_PRODUCT_DELETING_STARTS	: String = "stateInstalledProductDeletingStarts";
		private static const STATE_INSTALLED_PAGE_DELETING_STARTS		: String = "stateInstalledPageDeletingStarts";
		private static const STATE_INSTALLED_PAGE_DELETING_COMPLETE		: String = "stateInstalledPageDeletingComplete";
		private static const STATE_INSTALLED_LAST_PAGE_DELETING_COMPLETE		: String = "stateInstalledLastPageDeletingComplete";
		private static const STATE_INSTALLED_PRODUCT_DELETING_COMPLETE	: String = "stateInstalledProductDeletingComplete";
		
		private static const STATE_PAGES_GENERATING				: String = "statePagesGenerating";
		private static const STATE_PAGE_GENERATING_START		: String = "statePageGeneratingStart";
		private static const STATE_PAGE_GENERATING_UPDATE_CONTENT_LINKS	: String = "statePageGeneratingUpdateContentLinks";
		private static const STATE_PAGE_GENERATING_ADD_TO_DB			: String = "statePageGeneratingAddToDB";
		private static const STATE_PAGE_GENERATING_CACHE_RESOURCES		: String = "statePageGeneratingCacheResources";
		private static const STATE_PAGE_GENERATING_CACHE_PAGE			: String = "statePageGeneratingCachePage";
		private static const STATE_PAGE_GENERATING_COMPLETE		: String = "statePageGeneratingComplete";
		private static const STATE_LAST_PAGE_GENERATED			: String = "stateLastPageGenerated";
		
		private static const STATE_PROJECT_UPDATE_COMPLETE				: String = "stateProjectUpdateComplete";
		private static const STATE_PROJECT_UPDATE_CANCELED				: String = "stateProjectUpdateCanceled";
		private static const STATE_PROJECT_UPDATE_NOT_REQUIRED			: String = "stateProjectUpdateNotRequired";
		
		
		
		private var xmlLoader				: ProductXMLLoader = new ProductXMLLoader();
		
		private var sqlProxy				: SQLProxy = new SQLProxy();
		
		private var spinnerManager : SpinnerPopUpManager = SpinnerPopUpManager.getInstance();
		
		private var productXML				: XML;
		private var productPages			: XMLList;
		private var pagesCounter			: Number = 0;
		
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
			trace ("++ [ProductUpdater] onAppEnterFrame: " + curState);
			switch(curState)
			{
				case STATE_PRODUCT_XML_LOADING_STARTS:
				{
					curProductMsg = SpinnerPopupMessages.MSG_PRODUCT_NAME;
					curProductMsg = curProductMsg.replace(SpinnerPopupMessages.TEMPLATE_PRODUCT_TITLE, productTitle);
					spinnerManager.setSpinnerProductText(curProductMsg);
					
					spinnerManager.setSpinnerText(SpinnerPopupMessages.MSG_PRODUCT_XML_LOADING);
					
					curState = STATE_PRODUCT_XML_LOADING;
					break;
				}
				case STATE_PRODUCT_XML_LOADING:
				{
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
				case STATE_PRODUCT_CREATING_STARTS:
				{
					curProductMsg = SpinnerPopupMessages.MSG_PRODUCT_NAME;
					curProductMsg = curProductMsg.replace(SpinnerPopupMessages.TEMPLATE_PRODUCT_TITLE, productTitle);
					spinnerManager.setSpinnerProductText(curProductMsg);
					
					spinnerManager.setSpinnerText(SpinnerPopupMessages.MSG_PRODUCT_CREATING);
					
					createProduct();
					break;					
				}
				case STATE_INSTALLED_PRODUCT_DELETING_STARTS:
				{
					tryToDeleteProduct();
					break;
				}
				case STATE_INSTALLED_PAGE_DELETING_STARTS:
				{
					if (pagesCounter >= installedPages.length)
					{
						curState = STATE_INSTALLED_PAGE_DELETING_COMPLETE;
						return;
					}
					
					deletePage(installedProductId, installedPages[pagesCounter].name);
					
					curState = STATE_INSTALLED_PAGE_DELETING_COMPLETE;
					break;
				}
				case STATE_INSTALLED_PAGE_DELETING_COMPLETE:
				{
					pagesCounter ++;
					
					if (pagesCounter >= installedPages.length)
					{
						pagesCounter = 0;
						
						curState = STATE_INSTALLED_LAST_PAGE_DELETING_COMPLETE;
					}
					else
						curState = STATE_INSTALLED_PAGE_DELETING_STARTS;
					
					break;
				}
				case STATE_INSTALLED_LAST_PAGE_DELETING_COMPLETE:
				{
					deleteProduct();
					
					curState = STATE_INSTALLED_PRODUCT_DELETING_COMPLETE;
					break;
				}
				case STATE_INSTALLED_PRODUCT_DELETING_COMPLETE:
				{
					curState = STATE_PRODUCT_CREATING_CACHE_XML;
					break;
				}
				case STATE_PRODUCT_CREATING_ADD_TO_DB:
				{
					addProductToDB();
					
					if (isNaN(installedProductId))
					{
						curState = STATE_PROJECT_UPDATE_CANCELED;
						return;
					}
					
					curState = STATE_PAGES_GENERATING;
					break;
				}
				case STATE_PRODUCT_CREATING_CACHE_XML:
				{
					cacheProductXML();
					break;
				}
				case STATE_PRODUCT_TOC_CONVERTING:
				{
					resetToc();
					
					curState = STATE_PRODUCT_CREATING_ADD_TO_DB;
					break;
				}
				case STATE_PAGES_GENERATING:
				{
					spinnerManager.setSpinnerText(SpinnerPopupMessages.MSG_PAGES_CREATING);
					
					savePages();
					break;					
				}	
				case STATE_PAGE_GENERATING_START:
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
				case STATE_PAGE_GENERATING_UPDATE_CONTENT_LINKS:
				{
					updatePageContentLinks();
					
					curState = STATE_PAGE_GENERATING_ADD_TO_DB;
					
					break;
				}
				case STATE_PAGE_GENERATING_ADD_TO_DB:
				{
					addPageToDataBase();
					
					curState = STATE_PAGE_GENERATING_CACHE_PAGE;
					
					break;
				}
				case STATE_PAGE_GENERATING_CACHE_PAGE:
				{
					cachePageXML();
					
					curState = STATE_PAGE_GENERATING_CACHE_RESOURCES;
					
					break;
				}
				case STATE_PAGE_GENERATING_CACHE_RESOURCES:
				{
					createPageResources();
					
					curState = STATE_PAGE_GENERATING_COMPLETE;
					
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

		private function get productlanguage () : String
		{
			if (!productXML)
				return "";
			
			return productXML.language.toString();
		}
		
		private function get productDescription () : String
		{
			if (!productXML)
				return "";
			
			return productXML.description.toString();
		}
		
		private function get productVersion () : String
		{
			if (!productXML)
				return "";
			
			return productXML.version.toString();
		}
		
		private function get productName () : String
		{
			if (!productXML)
				return "";
			
			return productXML.name.toString();
		}
		
		private function get location () : String
		{
			if (!productXML)
				return "";
			
			return productlanguage +"/"+productName+"/";
		}
		 
		private function get productTitle () : String
		{
			if (!productXML)
				return "";
			
			return productXML.title.toString();
		}
		
		private function resetToc () : void
		{
			for each (var tocPage : XML in productXML.toc..page)
			{
				var oldPageName : String = tocPage.@name;
				
				tocPage.@name = productlanguage + "/" + productName + "/"  + oldPageName.substr(6, 36) + ".html"; 
			}
		}
		
		public function load(url:String):void
		{
			xmlLoader.addEventListener(ProductXMLLoader.XML_FILE_LOADED,			 xmlLoaderHandler);
			xmlLoader.addEventListener(ProductXMLLoader.XML_FILE_LOADING_ERROR,		 xmlLoaderHandler);
			
			xmlLoader.loadXMLFile(url);
			
			curState = STATE_PRODUCT_XML_LOADING_STARTS;
			
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
			
			curState = STATE_PRODUCT_CREATING_STARTS;
		}
		
		private function createProduct () : void 
		{
			// save product to data base
			var installedProductVersion	: String = sqlProxy.getVersionOfProduct(productName, productlanguage);
			
			if(installedProductVersion == '')
			{
				curState = STATE_PRODUCT_CREATING_CACHE_XML;
				return;
			}
			
			if (Number(installedProductVersion) < Number(productVersion))
			{
				curState = STATE_INSTALLED_PRODUCT_DELETING_STARTS;
				return;
			} 
			
			curState = STATE_PROJECT_UPDATE_NOT_REQUIRED;
		}
		
		private function addProductToDB () : void
		{
			sqlProxy.setProduct(productName, productVersion, productTitle, productDescription, productlanguage, productXML.toc[0]);
		}
		
		private function cacheProductXML():void
		{
			if (!productXML)
			{
				curState = STATE_PROJECT_UPDATE_CANCELED;
				return;
			}
			
			var byteArray : ByteArray = new ByteArray();
			byteArray.writeMultiByte(productXML.toXMLString()+"\n", "UTF-8");
			
			var fileName : String = productXML.name.toString()+ ".xml";
			cacheFile( fileName, byteArray);
			
			curState = STATE_PRODUCT_TOC_CONVERTING;
		}
				
		private function savePages():void
		{
			productPages = productXML.pages.children();
			
			if ( !productPages || productPages.length() <= 0 ) {
				curState = STATE_LAST_PAGE_GENERATED;
				return;
			}

			pagesCounter = 0;
			
			curState = STATE_PAGE_GENERATING_START;
		}
		
		private function get currentPage () : XML
		{
			if (!productPages)
				return null;
			
			if (isNaN(pagesCounter) || pagesCounter >= productPages.length())
				return null;
			
			return productPages[pagesCounter];
		}
		
		private function get curPageLocation () : String
		{
			if (!currentPage)
				return "";
			
			var pageName:String = currentPage.name.toString();
			if (pageName.indexOf(".html") < 0) {
				pageName += ".html"; 
			}
			
			return location + pageName;
		}
		
		private function get curPageVersion () : String
		{
			if (!currentPage)
				return "";
			
			return currentPage.version.toString();
		}
		
		private function get curPageTitle () : String
		{
			if (!currentPage)
				return "";
			
			return currentPage.title.toString();
		}
		
		private function get curPageDescription () : String
		{
			if (!currentPage)
				return "";
			
			return currentPage.description.toString();
		}
		
		private function get curPageContent () : String
		{
			if (!currentPage)
				return "";
			
			return currentPage.content.toString();
		}
		
		private function generateNextPage():void
		{
			if (pagesCounter >= productPages.length())
			{
				curState = STATE_LAST_PAGE_GENERATED;
				return;
			}
			
			if (installedPageVersion == '')
			{
				curState = STATE_PAGE_GENERATING_UPDATE_CONTENT_LINKS;
				return;
			}
			
			if (Number(installedPageVersion) < Number(curPageVersion))
			{
				deletePage(installedProductId, curPageLocation);
				
				curState = STATE_PAGE_GENERATING_UPDATE_CONTENT_LINKS;
				
				return;
			}
			
			curState = STATE_PAGE_GENERATING_COMPLETE;
			
		}
		
		private function updatePageContentLinks () : void
		{
			updatePageResourceLinks();
			updatePagePagesLinks();
		}
		
		private function updatePageResourceLinks () : void
		{
			var pageContent		: String;
			var pattern 		: RegExp;
			var arrMatch 		: Array;
			var resourceGUID	: String;
			var patternLastInd	: Number;
			var resourceType	: String;
			var newResPath 		: String;
			
			pageContent = currentPage.content.toXMLString();
			
			pattern = /\#Res\([A-F0-9]{8}(?:-[A-F0-9]{4}){3}-[A-Z0-9]{12}\)/ig;
			arrMatch = pageContent.match(pattern);
			
			for each ( var oldResName : String in arrMatch )
			{
				resourceGUID = oldResName.substr(5, 36);
				resourceType = getResourceType(resourceGUID);
				newResPath = "resources/" + resourceGUID + "." + resourceType;
				
				pageContent = pageContent.replace(oldResName, newResPath);
			}
			
			currentPage.content = new XML(pageContent);
		}
		
		private function getResourceType(resourceId:String) : String
		{
			for each (var res : XML in currentPage.resources.resource)
			{
				if (res.@id == resourceId)
					return res.@type;
			}
			
			return "";
		}
		
		private function updatePagePagesLinks() : void
		{
			var pageContent		: String;
			var pattern 		: RegExp;
			var arrMatch 		: Array;
			var pageGUID		: String;
			var newPagesPath	: String;
			
			pageContent = currentPage.content.toXMLString();
			
			pattern = /\#Page\([A-F0-9]{8}(?:-[A-F0-9]{4}){3}-[A-Z0-9]{12}\)/ig;
			arrMatch = pageContent.match(pattern);
			
			for each ( var oldResName : String in arrMatch )
			{
				pageGUID = oldResName.substr(6, 36);
				newPagesPath = pageGUID + ".html";
				
				pageContent = pageContent.replace(oldResName, newPagesPath); 
			}
			
			currentPage.content = new XML(pageContent);
		}
		
		private function addPageToDataBase () : void
		{
			sqlProxy.setPage(productName, productlanguage, curPageLocation, curPageVersion, curPageTitle, curPageDescription, curPageContent);
		}
		
		private function cachePageXML () : void
		{
			var byteArray : ByteArray = new ByteArray();
			byteArray.writeMultiByte(curPageContent + "\n", "UTF-8");
			
			cacheFile(curPageLocation, byteArray);
		}
		
		private function createPageResources () : void
		{
			trace (" == createPageResources == ");
			for each(var resource:XML in currentPage.resources.children())
			{
				trace (" -- resource");
				var base64 : Base64Decoder = new Base64Decoder();
				base64.decode(resource.toString());
				
				var byteArray0 : ByteArray = base64.toByteArray();
				
				var resourceName : String = "resources/"+ resource.@id + "." + resource.@type;
				
				sqlProxy.setResource(curPageLocation, location + resourceName);
				
				cacheFile(location + resourceName , byteArray0);
			}
			
		}
		
		private function onPageGenerated():void
		{
			pagesCounter ++;
			
			curState = STATE_PAGE_GENERATING_START;
		}
		
		private function onLastPageGenerated():void
		{
			productPages = null;
			productXML = null;
			pagesCounter = 0;
			
			curState = STATE_PROJECT_UPDATE_COMPLETE;
		}
		
		private var installedPages : Object;
		
		private function get installedProductId () : Number
		{
			return sqlProxy.getProductId(productName, productlanguage);
		}
		
		private function get installedPageVersion () : String
		{
			return sqlProxy.getVersionOfPage(installedProductId, curPageLocation);
		}
		
		private function tryToDeleteProduct():void
		{
			if (isNaN(installedProductId))
			{
				curState = STATE_INSTALLED_PRODUCT_DELETING_COMPLETE;
				return;
			}
			
			installedPages = sqlProxy.getProductsPages(productName, productlanguage);
			
			if (!installedPages || installedPages.length == 0)
			{
				curState = STATE_INSTALLED_PRODUCT_DELETING_COMPLETE;
				return;
			}
			
			pagesCounter = 0;
			
			curState = STATE_INSTALLED_PAGE_DELETING_STARTS;
		}
		
		private function deleteProduct():void
		{
			sqlProxy.deleteProduct(productName, productlanguage);
			
			var productLocation : String = productName;
			if (productLocation.indexOf(".xml") < 0) {
				productLocation += ".xml"; 
			}
			deleteFile(productLocation);
		}
		
		private function deletePage(productId:Number, namePage:String):void
		{
			// delete resources
			var resources:Object = sqlProxy.getResourcesOfPage(namePage);
			
			for(var index:String in resources)
			{
				deleteFile(resources[index]['name']);
			}
			
			sqlProxy.deleteResources(productId, namePage);
			
			// delete file
			sqlProxy.deletePage(productId, namePage);
			
			deleteFile(namePage);
		}
		
		private function deleteFile(location:String):void
		{
			var newFileName:String = location;
			var newFile:File = File.applicationStorageDirectory.resolvePath(newFileName);

			if (newFile.exists) 
			{
				newFile.deleteFile();
			}
		}
		
		private function cacheFile(contentName:String, content:ByteArray):void 
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