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
	
	import spinnerFolder.SpinnerPopUp;
	import spinnerFolder.SpinnerPopUpManager;
	import spinnerFolder.SpinnerPopupMessages;
	import net.vdombox.helpeditor.model.SQLProxy;

	public class ProjectsUpdater extends EventDispatcher
	{
		private static const STATE_XML_START_LOAD						: String = "stateXMLStartLoad";
		private static const STATE_XML_LOADING							: String = "stateXMLLoading";
		private static const STATE_XML_PARSING							: String = "stateXMLParsing";
		private static const STATE_PRODUCT_CREATING						: String = "stateProductCreating";
		
		private static const STATE_PAGES_GENERATING						: String = "statePagesGenerating";
		private static const STATE_NEXT_PAGE_GENERATING_START			: String = "stateNextPageGeneratingStart";
		private static const STATE_PAGE_GENERATING_IN_PROGRESS			: String = "statePageGeneratingInProgress";
		private static const STATE_PAGE_GENERATING_COMPLETE				: String = "statePageGeneratingComplete";
		private static const STATE_LAST_PAGE_GENERATED					: String = "stateLastPageGenerated";
		
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
		private var currentPage		: XML;
		
		private var productXML	: XML;
		private var productId	: Number;
		private var productName	: String = ""; 
		private var language	: String = ""; 
		private var location	: String = ""; 
		
		private var curState			: String;
		
		private var spinnerCurPageTxt	: String = "";
		
		public function ProjectsUpdater()
		{
		}
		
		private function onAppEnterFrame(aEvent : Event):void
		{
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
				case STATE_PAGE_GENERATING_IN_PROGRESS :
				{
					break;
				}
				case STATE_PAGE_GENERATING_COMPLETE : 
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
			
			productXML = resetPagesLinks(productXML);
			
			if(productXML == null || productXML.name() != "product")
			{
				trace("!!!!!!!!!!!! not Correct data from server !!!!!!!!!!!!!");
				curState = STATE_PROJECT_UPDATE_CANCELED;
				return;
			}
			
			
			curState = STATE_PRODUCT_CREATING;
			
		}
		
		private function createProduct():void
		{
			var name:String = productXML.name.toString();
			var version:int = int(productXML.version);
			var title:String = productXML.title.toString();
			var description:String = productXML.description.toString();
			var language:String = productXML.language.toString();
			var toc:XML = tocToBD(productXML.toc[0],language, name);
			
			
			// save product to data base
			spinnerManager.setSpinnerText(SpinnerPopupMessages.MSG_PRODUCT_CREATING);
			
			var curProductVersion:String = sqlProxy.getVersionOfProduct(name, language);			
			if(curProductVersion == '')
			{
				//sqlProxy.setPage(productName, language, pageLocation, version, title, description, content);
				sqlProxy.setProduct(name,version,title,description, language, toc);
			}
			else 
			{
				if (int(curProductVersion)< version)
				{
					//delete old data Find nessasri page 
					deleteProduct(name, language);
					//					sqlProxy.setPage(productName, language, pageLocation, version, title, description, content);
					
					sqlProxy.setProduct(name, version, title, description, language, toc);
				} else
				{
					//this.dispatchEvent(new Event(UPDATE_NOT_REQUIRED));
					curState = STATE_PROJECT_UPDATE_NOT_REQUIRED;
					return;
				}
			}
			
			productId= sqlProxy.getProductId(name, language);
			
			if (isNaN(productId))
			{
				curState = STATE_PROJECT_UPDATE_CANCELED;
				return;
			}
			
			curState = STATE_PAGES_GENERATING;
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
		
		private function savePages():void
		{
			var spinnerTxt : String = "";
			
			productName	= productXML.name.toString(); 
			language = productXML.language.toString(); 
			location = language +"/"+productName+"/"; 
			
			pagesCounter = 0;
			productPages = productXML.pages.children();
			
			if (!productPages || productPages.length() <= 0) {
				
				curState = STATE_LAST_PAGE_GENERATED;
				return;
				
			}
			
			curState = STATE_NEXT_PAGE_GENERATING_START;
			
		}  
		
		private function generateNextPage():void
		{
			if (pagesCounter >= productPages.length())
			{
				curState = STATE_LAST_PAGE_GENERATED;
				return;
			}
			
			curState = STATE_PAGE_GENERATING_IN_PROGRESS;
			
			currentPage = productPages[pagesCounter];
			
			var pageName		: String = currentPage.name.toString();// + ".html"; 
			var version			: String = currentPage.version.toString(); 
			var title			: String = currentPage.title.toString();
			var description		: String = currentPage.description.toString();
			var content			: String = contentToBD(currentPage.content.toString(), currentPage.resources.toString());
			var pageLocation	: String = location + pageName;
			
			var curPageVersion	: String = sqlProxy.getVersionOfPage(productId, pageName);
			
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
				curState = STATE_PAGE_GENERATING_COMPLETE;
				return;
			}
			
			var base64 : Base64Decoder = new Base64Decoder();
			var byteArray0 : ByteArray;
			var resourceName : String;
			//*************  Creat Resources  ***************//
			for each(var resource:XML in currentPage.resources.children())
			{
				base64.reset();
				base64.decode(resource.toString());
				
				byteArray0 = base64.toByteArray();
				
				resourceName = "resources/"+ resource.@id + "." + resource.@type;
				
				cacheFile(resourceName , byteArray0);
			}
			
			curState = STATE_PAGE_GENERATING_COMPLETE;
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