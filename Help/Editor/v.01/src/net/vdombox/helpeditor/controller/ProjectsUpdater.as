package net.vdombox.helpeditor.controller
{
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import mx.automation.delegates.controls.NavBarAutomationImpl;
	import mx.core.Application;
	import mx.core.ContextualClassFactory;
	import mx.events.FlexEvent;
	import mx.utils.Base64Decoder;
	
	import net.vdombox.helpeditor.model.SQLProxy;
	import net.vdombox.helpeditor.model.SpinnerPopupMessages;
	import net.vdombox.helpeditor.view.spinner.SpinnerPopUp;

	public class ProjectsUpdater extends EventDispatcher
	{
		private static const STATE_XML_START_LOAD						: String = "stateXMLStartLoad";
		private static const STATE_XML_LOADING							: String = "stateXMLLoading";
		private static const STATE_XML_PARSING							: String = "stateXMLParsing";
		
		private static const STATE_PRODUCT_CREATING						: String = "stateProductCreating";
		private static const STATE_PRODUCT_ADD_TO_DB					: String = "stateProductAddToDB";
		private static const STATE_PRODUCT_DELETING_STARTS				: String = "stateProductDeletingStarts";
		private static const STATE_PRODUCT_DELETING_NEXT_PAGE			: String = "stateProductDeletingNextPage";
		private static const STATE_PRODUCT_DELETING_NEXT_PAGE_COMPLETE	: String = "stateProductDeletingNextPageComplete";
		private static const STATE_PRODUCT_DELETING_LAST_PAGE_COMPLETE	: String = "stateProductDeletingLastPageComplete";
		
		private static const STATE_PAGES_GENERATING									: String = "statePagesGenerating";
		private static const STATE_NEXT_PAGE_GENERATING_START						: String = "stateNextPageGeneratingStart";
		private static const STATE_NEXT_PAGE_GENERATING_RESOURCES_CREATING_START			: String = "stateNextPageGeneratingResourcesCreatingStart";
		private static const STATE_NEXT_PAGE_GENERATING_NEXT_RESOURCE_CREATING				: String = "stateNextPageGeneratingNextResourceCreating";
		private static const STATE_NEXT_PAGE_GENERATING_NEXT_RESOURCE_CREATING_COMPLETE		: String = "stateNextPageGeneratingNextResourceCreatingComplete";
		private static const STATE_NEXT_PAGE_GENERATING_LAST_RESOURCE_CREATING_COMPLETE		: String = "stateNextPageGeneratingLastResourceCreatingComplete";
		private static const STATE_NEXT_PAGE_GENERATING_COMPLETE					: String = "stateNextPageGeneratingComplete";
		private static const STATE_LAST_PAGE_GENERATED								: String = "stateLastPageGenerated";
		
		private static const STATE_PROJECT_UPDATE_COMPLETE				: String = "stateProjectUpdateComplete";
		private static const STATE_PROJECT_UPDATE_CANCELED				: String = "stateProjectUpdateCanceled";
		private static const STATE_PROJECT_UPDATE_NOT_REQUIRED			: String = "stateProjectUpdateNotRequired";
		
		public static var UPDATE_COMPLETED		: String = "UPDATE_COMPLETED";
		public static var UPDATE_CANCELED		: String = "UPDATE_CANCELED";
		public static var UPDATE_NOT_REQUIRED	: String = "UPDATE_NOT_REQUIRED";
		
		private var file					: File;
		
		private var sqlProxy : SQLProxy = new SQLProxy();
		
		private var spinnerManager		: SpinnerPopUpManager = SpinnerPopUpManager.getInstance();
		
		private var pagesCounter	: Number = 0;
		private var productPages	: XMLList;
		
		private var pageResources	: XMLList;
		
		private var resourcesCounter : Number = 0;
		
		private var productXML	: XML;
		
		private var curState			: String;
		
		private var spinnerCurPageTxt	: String = "";
		
		public function ProjectsUpdater()
		{
		}
		
		private function onAppEnterFrame(aEvent : Event):void
		{
			trace ("-- onAppEnterFrame: " + curState);
			switch (curState)
			{
				case STATE_XML_START_LOAD: 
				{
					spinnerManager.setSpinnerText(SpinnerPopupMessages.MSG_PRODUCT_XML_LOADING);
					
					loadProductXML();
					break;
				}
				case STATE_XML_LOADING: 
				{
					break;
				}
				case STATE_XML_PARSING: 
				{
					spinnerManager.setSpinnerText(SpinnerPopupMessages.MSG_PARSING_XML);
					
					parseXMLData();
					break;
				}
				case STATE_PRODUCT_CREATING: 
				{
					spinnerManager.setSpinnerText(SpinnerPopupMessages.MSG_PRODUCT_CREATING);
					
					createProduct();
					break;
				}
				case STATE_PRODUCT_ADD_TO_DB:
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
				case STATE_PRODUCT_DELETING_STARTS:
				{
					pagesCounter = 0;
					
					if (!installedProductPages || installedProductPages.length == 0)
					{
						curState = STATE_PRODUCT_DELETING_LAST_PAGE_COMPLETE;
						return;
					}
					
					curState = STATE_PRODUCT_DELETING_NEXT_PAGE;
					break;
				}
				case STATE_PRODUCT_DELETING_NEXT_PAGE:
				{
					if (pagesCounter >= installedProductPages.length)
					{
						curState = STATE_PRODUCT_DELETING_LAST_PAGE_COMPLETE;
						return;
					}
					
					deletePageFromDB(installedProductId, installedProductPages[pagesCounter].name);
					
					curState = STATE_PRODUCT_DELETING_NEXT_PAGE_COMPLETE;
					break;
				}
				case STATE_PRODUCT_DELETING_NEXT_PAGE_COMPLETE:
				{
					pagesCounter ++;
					
					if (pagesCounter >= installedProductPages.length)
					{
						curState = STATE_PRODUCT_DELETING_LAST_PAGE_COMPLETE;
						return;
					}
					
					curState = STATE_PRODUCT_DELETING_NEXT_PAGE;
					break;
				}
				case STATE_PRODUCT_DELETING_LAST_PAGE_COMPLETE:
				{
					pagesCounter = 0;
					
					deleteProductFromDB();
					
					curState = STATE_PRODUCT_ADD_TO_DB;
					break;
				}
				case STATE_PAGES_GENERATING : 
				{
					spinnerManager.setSpinnerText(SpinnerPopupMessages.MSG_PAGES_CREATING);
					
					savePages();
					break;
				}
				case STATE_NEXT_PAGE_GENERATING_START : 
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
				case STATE_NEXT_PAGE_GENERATING_RESOURCES_CREATING_START:
				{
					createPageResources();
					break;
				}
				case STATE_NEXT_PAGE_GENERATING_NEXT_RESOURCE_CREATING:
				{
					if (resourcesCounter >= pageResources.length())
					{
						curState = STATE_NEXT_PAGE_GENERATING_LAST_RESOURCE_CREATING_COMPLETE;
						return;
					}
					
					createNextPageResource();
					
					curState = STATE_NEXT_PAGE_GENERATING_NEXT_RESOURCE_CREATING_COMPLETE;
					break;
				}
				case STATE_NEXT_PAGE_GENERATING_NEXT_RESOURCE_CREATING_COMPLETE:
				{
					resourcesCounter ++;
					
					if (resourcesCounter >= pageResources.length())
					{
						curState = STATE_NEXT_PAGE_GENERATING_LAST_RESOURCE_CREATING_COMPLETE;
						return;
					}
					
					curState = STATE_NEXT_PAGE_GENERATING_NEXT_RESOURCE_CREATING;
					break;
				}
				case STATE_NEXT_PAGE_GENERATING_LAST_RESOURCE_CREATING_COMPLETE:
				{
					resourcesCounter = 0;
					
					curState = STATE_NEXT_PAGE_GENERATING_COMPLETE;
					break;
				}
				case STATE_NEXT_PAGE_GENERATING_COMPLETE : 
				{
					onPageGenerated();
					break;
				}
				case STATE_LAST_PAGE_GENERATED : 
				{
					onLastPageGenerated();
					break;
				}
				case STATE_PROJECT_UPDATE_COMPLETE : 
				{
					Application.application.removeEventListener(Event.ENTER_FRAME, onAppEnterFrame);
					
					spinnerManager.addEventListener(SpinnerPopUpManager.EVENT_SPINNER_WINDOW_HIDE, onProjectUpdateComplete);
					setTimeout(spinnerManager.hideSpinner, 500);
					break;
				}
				case STATE_PROJECT_UPDATE_CANCELED : 
				{
					Application.application.removeEventListener(Event.ENTER_FRAME, onAppEnterFrame);
					
					spinnerManager.addEventListener(SpinnerPopUpManager.EVENT_SPINNER_WINDOW_HIDE, onProjectUpdateCanceled);
					setTimeout(spinnerManager.hideSpinner, 500);
					break;
				}
				case STATE_PROJECT_UPDATE_NOT_REQUIRED : 
				{
					Application.application.removeEventListener(Event.ENTER_FRAME, onAppEnterFrame);
					
					spinnerManager.addEventListener(SpinnerPopUpManager.EVENT_SPINNER_WINDOW_HIDE, onProjectUpdateNotRequired);
					setTimeout(spinnerManager.hideSpinner, 500);
					break;
				}	
					
			}
		}
		
		public function addProductFromXML():void
		{
			curState = "";
			
			file = new File();
			
			file.addEventListener(Event.SELECT, onXMLFileSelected); 
			file.addEventListener(Event.CANCEL, onCancelSelectXML); 
			file.addEventListener(IOErrorEvent.IO_ERROR, onError); 
			file.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onError); 
			
			var textTypeFilter:FileFilter = new FileFilter("XML Files (*.xml)",	"*.xml"); 
			file.browse([textTypeFilter]);
			
			function onXMLFileSelected(aEvent:Event):void
			{
				file.removeEventListener(Event.SELECT, 						onXMLFileSelected); 
				file.removeEventListener(Event.CANCEL,						onCancelSelectXML);
				
				spinnerManager.addEventListener(SpinnerPopUpManager.EVENT_SPINNER_WINDOW_ADDED, onSpinnerAdded);
				spinnerManager.showSpinner();
			}
			
			function onCancelSelectXML(aEvent:Event):void
			{
				file.removeEventListener(Event.SELECT, 						onXMLFileSelected); 
				file.removeEventListener(Event.CANCEL,						onCancelSelectXML);
				file.removeEventListener(IOErrorEvent.IO_ERROR, 			onError); 
				file.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
				
				curState = STATE_PROJECT_UPDATE_CANCELED;
				
				Application.application.addEventListener(Event.ENTER_FRAME, onAppEnterFrame);
			}
			
		}
		
		private function onSpinnerAdded(evt:Event):void
		{
			spinnerManager.removeEventListener(SpinnerPopUpManager.EVENT_SPINNER_WINDOW_ADDED, onSpinnerAdded);
			
			curState = STATE_XML_START_LOAD;
			
			Application.application.addEventListener(Event.ENTER_FRAME, onAppEnterFrame);
		}
		
		private function loadProductXML():void
		{
			file.addEventListener(Event.COMPLETE, onXMLFileLoadComplete);
			
			file.load();
			
			curState = STATE_XML_LOADING;
		}
		
		private function onXMLFileLoadComplete(aEvent:Event):void
		{
			file.removeEventListener(Event.COMPLETE, 					onXMLFileLoadComplete);
			file.removeEventListener(IOErrorEvent.IO_ERROR, 			onError); 
			file.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			
			curState = STATE_XML_PARSING;
		}
		
		private function onError(aEvent:Event):void
		{
			file.removeEventListener(Event.COMPLETE, 					onXMLFileLoadComplete);
			file.removeEventListener(IOErrorEvent.IO_ERROR, 			onError); 
			file.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onError);
			
			curState = STATE_PROJECT_UPDATE_CANCELED;
		}
		
		private function parseXMLData():void
		{ 
			productXML = new XML(file.data);
			
			if (productXML == null || productXML.name() != "product")
			{
				trace("!!!!!!!!!!!! not Correct data from server !!!!!!!!!!!!!");
				curState = STATE_PROJECT_UPDATE_CANCELED;
				return;
			}
			
			
			curState = STATE_PRODUCT_CREATING;
			
		}
		
		private function get productName () : String
		{
			if (!productXML)
				return "";
			
			return productXML.name.toString();
		}
		
		private function get productVersion () : String
		{
			if (!productXML)
				return "";
			
			return productXML.version.toString();
		}
		
		private function get productTitle () : String
		{
			if (!productXML)
				return "";
			
			return productXML.title.toString();
		}
		
		private function get productDescription () : String
		{
			if (!productXML)
				return "";
			
			return productXML.description.toString();
		}
		
		private function get productLang () : String
		{
			if (!productXML)
				return "";
			
			return productXML.language.toString();
		}
		
		private function get installedProductVersion () : String
		{
			return sqlProxy.getVersionOfProduct(productName, productLang);
		}
		
		private function get installedProductId () : Number
		{
			return sqlProxy.getProductId(productName, productLang);
		}
		
		private function get installedProductPages () : Object
		{
			return sqlProxy.getProductsPages(productName, productLang);
		}
		
		private function createProduct():void
		{
			spinnerManager.setSpinnerText(SpinnerPopupMessages.MSG_PRODUCT_CREATING);
			
			if (installedProductVersion == '')
			{
				curState = STATE_PRODUCT_ADD_TO_DB;
				return;
			}
			
			if (Number(installedProductVersion) < Number(productVersion))
			{
				curState = STATE_PRODUCT_DELETING_STARTS;
				return;
			} 
			
			curState = STATE_PROJECT_UPDATE_NOT_REQUIRED;
		}
		
		private function addProductToDB () : void
		{
			tocToBD();
			
			sqlProxy.setProduct(productName, productVersion, productTitle, productDescription, productLang, productXML.toc[0]);
		}
		
		private function deleteProductFromDB () : void
		{
			sqlProxy.deleteProduct(productName, productLang);
		}
		
		private function savePages():void
		{
			pagesCounter = 0;
			
			productPages = productXML.pages.children();
			
			if (!productPages || productPages.length() <= 0) {
				
				curState = STATE_LAST_PAGE_GENERATED;
				return;
				
			}
			
			curState = STATE_NEXT_PAGE_GENERATING_START;
			
		}  
		
		private function get currentPage () : XML
		{
			if (!productPages)
				return null;
			
			if (isNaN(pagesCounter) || pagesCounter >= productPages.length())
				return null;
			
			return productPages[pagesCounter];
		}
		
		private function get curPageName () : String
		{
			if (!currentPage)
				return "";
			
			return currentPage.name.toString();
		}
		
		private function get curPageTitle () : String
		{
			if (!currentPage)
				return "";
			
			return currentPage.title.toString();
		}
		
		private function get curPageVersion () : String
		{
			if (!currentPage)
				return "";
			
			return currentPage.version.toString();
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
			
			resetImgPath();
			
			resetPagesLinks();
			
			return currentPage.content[0];
		}
		
		private function generateNextPage():void
		{
			if (pagesCounter >= productPages.length())
			{
				curState = STATE_LAST_PAGE_GENERATED;
				return;
			}
			
			var curPageVersion	: String = sqlProxy.getVersionOfPage(installedProductId, curPageName);
			
			if (curPageVersion == '')
			{
				addPageToDB();
				
				curState = STATE_NEXT_PAGE_GENERATING_RESOURCES_CREATING_START;
				
				return;
			}
			
			if (Number(curPageVersion) < Number(curPageVersion))
			{
				deletePageFromDB(installedProductId, curPageName);
				
				addPageToDB();
				
				curState = STATE_NEXT_PAGE_GENERATING_RESOURCES_CREATING_START;
				
				return;
			} 
			
			curState = STATE_NEXT_PAGE_GENERATING_COMPLETE;
			
		}
		
		private function createPageResources () : void
		{
			resourcesCounter = 0;
			
			pageResources = currentPage.resources.children();
			
			if (!pageResources || pageResources.length() == 0)
			{
				curState = STATE_NEXT_PAGE_GENERATING_LAST_RESOURCE_CREATING_COMPLETE;
				return;
			}
			
			curState = STATE_NEXT_PAGE_GENERATING_NEXT_RESOURCE_CREATING;
		}
		
		private function createNextPageResource () : void
		{
			var resource : XML = pageResources[resourcesCounter];
			var resourceName : String;
			
			var base64 : Base64Decoder = new Base64Decoder();
			var byteArray : ByteArray;
			
			base64.reset();
			base64.decode(resource.toString());
			
			byteArray = base64.toByteArray();
			
			resourceName = "resources/"+ resource.@id + "." + resource.@type;
			
			cacheFile(resourceName , byteArray);
		}
		
		private function addPageToDB () : void
		{
			sqlProxy.addPage(productName, productLang, curPageName, Number(curPageVersion), curPageTitle, curPageDescription, curPageContent);
		}
		
		private function deletePageFromDB (productId : Number, pageName : String) : void
		{
			sqlProxy.deletePage(productId, pageName);
		}
		
		private function onPageGenerated():void
		{
			pagesCounter ++;
			
			curState = STATE_NEXT_PAGE_GENERATING_START;
		}
		
		private function onLastPageGenerated():void
		{
			pagesCounter = 0;
			
			curState = STATE_PROJECT_UPDATE_COMPLETE;
		}
		
		private function onProjectUpdateComplete(evt:Event):void
		{
			spinnerManager.removeEventListener(SpinnerPopUpManager.EVENT_SPINNER_WINDOW_HIDE, onProjectUpdateComplete);
			
			this.dispatchEvent(new Event(UPDATE_COMPLETED));
		}
		
		private function onProjectUpdateCanceled(evt:Event):void
		{
			spinnerManager.removeEventListener(SpinnerPopUpManager.EVENT_SPINNER_WINDOW_HIDE, onProjectUpdateCanceled);
			
			this.dispatchEvent(new Event(UPDATE_CANCELED));
		}
		
		private function onProjectUpdateNotRequired(evt:Event):void
		{
			spinnerManager.removeEventListener(SpinnerPopUpManager.EVENT_SPINNER_WINDOW_HIDE, onProjectUpdateNotRequired);
			
			this.dispatchEvent(new Event(UPDATE_NOT_REQUIRED));
		}
		
		private function resetImgPath() : void
		{
			var pattern 		: RegExp;
			var arrMatch 		: Array;
			var newResPath 		: String;
			var resourceGUID	: String;
			
			var content : String = currentPage.content.toXMLString();
			
			pattern = /\#Res\([A-F0-9]{8}(?:-[A-F0-9]{4}){3}-[A-Z0-9]{12}\)/ig;
			arrMatch = content.match(pattern);

			for each ( var oldResName : String in arrMatch )
			{
				resourceGUID = oldResName.substr(5, 36);
				newResPath = "app-storage:/resources/" + resourceGUID + "." + getResourceType(resourceGUID);
				
				content = content.replace(oldResName, newResPath);
			}
			
			currentPage.content = new XML(content);
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
		
		private function resetPagesLinks() : void
		{
			var pattern		 : RegExp;
			var arrMatch	 : Array;
			var pageGUID	 : String;
			
			
			var content : String = currentPage.content.toXMLString();
			
			pattern = /\#Page\([A-F0-9]{8}(?:-[A-F0-9]{4}){3}-[A-Z0-9]{12}\)/ig;
			arrMatch = content.match(pattern);
			
			for each ( var oldPageName : String in arrMatch )
			{
				pageGUID = oldPageName.substr(6, 36);
				
				content = content.replace(oldPageName, pageGUID);
			}
			
			currentPage.content = new XML(content);
		}
		
		private function cacheFile(contentName:String, content:ByteArray):void 
		{
			var fileStream:FileStream = new FileStream();
			var newFileName:String = contentName;
			var newFile:File = File.applicationStorageDirectory.resolvePath(newFileName);
			
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
		
		private function tocToBD() : void
		{
			for each (var tocPage : XML in productXML.toc..page)
			{
				var oldPageName : String = tocPage.@name;
				
				if (oldPageName.indexOf("#Page(") == 0)
					tocPage.@name = oldPageName.substr(6, 36); 
			}
		}
		
	}
}