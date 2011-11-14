package
{
	
	import com.adobe.crypto.MD5Stream;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.graphics.codec.PNGEncoder;
	import mx.utils.Base64Encoder;
	
	import spinnerFolder.SpinnerPopUp;
	import spinnerFolder.SpinnerPopUpManager;
	import spinnerFolder.SpinnerPopupMessages;

	public class ProductXMLCreator extends EventDispatcher
	{
		// states ...
		private static const STATE_PRODUCT_XML_CREATING					: String = "stateProductXMLCreating";
		private static const STATE_PAGES_GENERATING						: String = "statePagesGenerating";
		private static const STATE_NEXT_PAGE_GENERATING_START			: String = "stateNextPageGeneratingStart";
		private static const STATE_PAGE_GENERATING_COMPLETE				: String = "statePageGeneratingComplete";
		private static const STATE_LAST_PAGE_GENERATED					: String = "stateLastPageGenerated";
		
		private static const STATE_NEXT_PAGE_RESOURCE_GENERATING_START	: String = "stateNextPageResourceGeneratingStart";
		private static const STATE_PAGE_RESOURCE_GENERATING_COMPLETE	: String = "statePageResourceGeneratingComplete";
		private static const STATE_LAST_PAGE_RESOURCE_GENERATED			: String = "stateLastPageResourceGenerated";
		
		private static const STATE_XML_CREATION_COMPLETE				: String = "stateXMLCreationComplete";
		// ... states
		
		public static const EVENT_ON_XML_CREATION_COMPLETE	: String = "eventXMLCreationComplete";
		
		private const guidResourseRegExp	: RegExp = /\b[A-F0-9]{8}(?:-[A-F0-9]{4}){3}-[A-Z0-9]{12}\.[A-Z]{3}\b/gim;
		private const imgTagRegExp			: RegExp = /<[ ]*img[^>]*[ ]*\/[ ]*>/g;
				
		private var sqlProxy	: SQLProxy = new SQLProxy();
		
		private var _productXML			: XML;
		
		private var html_wysiwyg		: HTML_WYSIWYG;
		
		private var pagesObj		: Object;
		private var pagesXML		: XML;
		private var pagesCounter	: Number = 0;
		
		private var tocXML				: XML;
		private var pageXML				: XML;
		private var pageResourcesArr	: Array;
		private var pageResourcesXML	: XML;
		private var pageResourceXML		: XML;
		private var pageResourcesCounter: Number = 0;
		private var pageContentForXml	: String;
		
		private var currentPageObj		: Object;
		private var pageContent			: String;
		
		private var productName			: String;
		private var productTitle		: String;
		private var treeData			: *;
		
		private var appendPage			: Boolean = true;
		private var spinnerManager		: SpinnerPopUpManager = SpinnerPopUpManager.getInstance();
		
		private var curState			: String;
		
		private var curPageMsg			: String = "";
		private var curPageResourceMsg	: String = "";
		
		public function ProductXMLCreator()
		{
			curState = STATE_PRODUCT_XML_CREATING;
		}
		
		public function get productXML():XML
		{
			return _productXML;
		}
		
		public function set productXML(value:XML):void
		{
			_productXML = value;
		}

		
		public function generateProductXML(aProductName:String, aProductTitle:String, aTreeData:*, htmlWysiwyg:HTML_WYSIWYG):void
		{
			html_wysiwyg = htmlWysiwyg;
			
			productName = aProductName;
			productTitle = aProductTitle;
			treeData = aTreeData;
			
			spinnerManager.addEventListener(SpinnerPopUpManager.EVENT_SPINNER_WINDOW_ADDED, onSpinnerAdded);
			spinnerManager.showSpinner();
			
		}
		
		private function onSpinnerAdded(evt:Event):void
		{
			spinnerManager.removeEventListener(SpinnerPopUpManager.EVENT_SPINNER_WINDOW_ADDED, onSpinnerAdded);
			
			curState = STATE_PRODUCT_XML_CREATING;
			
			Application.application.addEventListener(Event.ENTER_FRAME, onAppEnterFrame);
		}
		
		private function onAppEnterFrame(aEvent : Event):void
		{
			switch (curState)
			{
				case STATE_PRODUCT_XML_CREATING : 
				{
					spinnerManager.setSpinnerText(SpinnerPopupMessages.MSG_PRODUCT_XML_CREATING);
					spinnerManager.setSpinnerResourceText("");
					
					createXML();
					break;
				}
					
				case STATE_PAGES_GENERATING : 
				{
					spinnerManager.setSpinnerText(SpinnerPopupMessages.MSG_PAGES_GENERATING);
					
					generatePages();
					break;
				}
				case STATE_NEXT_PAGE_GENERATING_START : 
				{
					if (pagesCounter < pagesObj.length)
					{
						curPageMsg = SpinnerPopupMessages.MSG_PAGE_GENERATING;
						
						curPageMsg = curPageMsg.replace(SpinnerPopupMessages.TEMPLATE_CUR_PAGE, (pagesCounter+1));
						curPageMsg = curPageMsg.replace(SpinnerPopupMessages.TEMPLATE_TOTAL_PAGES, pagesObj.length);
						
						spinnerManager.setSpinnerText(curPageMsg);
					}
					
					generateNextPage();
					break;
				}
				
				case STATE_NEXT_PAGE_RESOURCE_GENERATING_START : 
				{
					/*if (pageResourcesCounter < pageResourcesArr.length)
					{
						curPageResourceMsg = SpinnerPopupMessages.MSG_RESOURCE_CREATING;
						
						curPageResourceMsg = curPageResourceMsg.replace(SpinnerPopupMessages.TEMPLATE_CUR_RESOURCE, (pageResourcesCounter+1));
						curPageResourceMsg = curPageResourceMsg.replace(SpinnerPopupMessages.TEMPLATE_TOTAL_RESOURCES, pageResourcesArr.length);
						
						spinnerManager.setSpinnerResourceText(curPageResourceMsg);
					}*/
					
					generateNextPageResource();
					break;
				}
				case STATE_PAGE_RESOURCE_GENERATING_COMPLETE : 
				{
					onPageResourceGenerated();
					break;
				}
				case STATE_LAST_PAGE_RESOURCE_GENERATED : 
				{
					spinnerManager.setSpinnerResourceText("");
					
					onLastPageResourceGenerated();
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
					
				case STATE_XML_CREATION_COMPLETE : 
				{
					spinnerManager.setSpinnerText(SpinnerPopupMessages.MSG_PRODUCT_XML_CREATION_COMPLETE);
					
					Application.application.removeEventListener(Event.ENTER_FRAME, onAppEnterFrame);
					
					setTimeout(onXMLCreationComplete, 1000);
					break;
				}
			}
		}
			
		private function createXML():void
		{
			productXML  = new XML("<product/>");
			
			productXML.name = productName;
			productXML.version = sqlProxy.upVersion(productName, "en_US"); // get Version
			productXML.title = productTitle;
			productXML.description = "";
			productXML.language = "en_US";
			
			// generate toc ...
			tocXML      = new XML("<toc/>");
			var tocString : String = resetToc(treeData);
			var regExp : RegExp    = /isBranch="true"/gim;
			
			tocXML.appendChild(XML(tocString.replace(regExp,' ')));
			productXML.appendChild(tocXML);
			// ... generate toc
			
			//generatePages();
			curState = STATE_PAGES_GENERATING;
		}
		
		private function generatePages() : void
		{
			pagesCounter = 0;
			pagesObj = {};
			pagesXML = null;
			
			pagesObj = sqlProxy.getProductsPages(productName, "en_US");
			pagesXML = new XML("<pages/>");
			
			// generate pages ...
			if (!pagesObj || pagesObj.length <= 0) 
			{
				curState = STATE_LAST_PAGE_GENERATED;
				return;
			
			}
			
			curState = STATE_NEXT_PAGE_GENERATING_START;
		}
		
		private function generateNextPage():void
		{
			if (pagesCounter >= pagesObj.length)
			{
				pagesCounter = 0;
				
				curState = STATE_LAST_PAGE_GENERATED;
				return;
			}
			
			currentPageObj = pagesObj[pagesCounter];
			
			appendPage = true;
			
			if (tocXML.toString().indexOf(currentPageObj["name"]) == -1) // page doesn't exist in toc 
			{
				appendPage = false;

				curState = STATE_PAGE_GENERATING_COMPLETE;
				return;
			}
			
			pageContent = currentPageObj["content"];
			
			if (html_wysiwyg)
			{
				html_wysiwyg.addEventListener(HTML_WYSIWYG.EVENT_WYSIWYG_IMAGES_WIDTH_SETTED, onImageMaxWidthChecked);
				html_wysiwyg.resetImagesWidth(XML(pageContent));
				return;
			}
			
			onImageMaxWidthChecked(null);

		}
		
		private function onImageMaxWidthChecked(aEvent : Event):void
		{
			if (aEvent)
				html_wysiwyg.removeEventListener(HTML_WYSIWYG.EVENT_WYSIWYG_IMAGES_WIDTH_SETTED, onImageMaxWidthChecked);
			
			pageContent = html_wysiwyg.xmlContent.toString();
			
			var pageContentWithToc	: String;
			
			pageContentWithToc = VdomHelpEditor.getPageContentWithToc(pageContent, 
																		Boolean(currentPageObj["useToc"]),
																		getPageChildren(currentPageObj["name"])
																		);
			
			pageContentForXml = resetLinksToResourcesAndPages(pageContentWithToc);
			
			pageXML = new XML("<page/>");
			
			pageXML.name = currentPageObj[ "name" ];
			pageXML.version = currentPageObj[ "version" ];
			pageXML.title = currentPageObj[ "title" ];
			pageXML.description = currentPageObj[ "description" ];
			
			var content : XML = XML("<content/>");
			
			pageXML.appendChild(content);
			
			// get resources ...	
			pageResourcesXML = new XML("<resources/>");
			
			pageResourcesArr  = pageContent.match(guidResourseRegExp);
			
			if (!pageResourcesArr || pageResourcesArr.length <= 0) {
				curState = STATE_LAST_PAGE_RESOURCE_GENERATED;
				return;			
			}
			
			curState = STATE_NEXT_PAGE_RESOURCE_GENERATING_START;
			// ... get resources
		}
		
		private function onPageGenerated():void
		{
			if (appendPage)
				pagesXML.appendChild(pageXML);
			
			pagesCounter ++;
			pageResourcesCounter = 0;
			
			curState = STATE_NEXT_PAGE_GENERATING_START;
		}
		
		private function onLastPageGenerated():void
		{
			productXML.appendChild(pagesXML);
			productXML.normalize();
			
			curState = STATE_XML_CREATION_COMPLETE;
		}
		
		private function onXMLCreationComplete():void
		{
			spinnerManager.addEventListener(SpinnerPopUpManager.EVENT_SPINNER_WINDOW_HIDE, spinnerHideHandler);
			setTimeout(spinnerManager.hideSpinner, 50);
		}
		
		private function spinnerHideHandler(evt:Event):void
		{
			spinnerManager.removeEventListener(SpinnerPopUpManager.EVENT_SPINNER_WINDOW_HIDE, spinnerHideHandler);
			
			this.dispatchEvent(new Event(EVENT_ON_XML_CREATION_COMPLETE));
		}
		
		private function generateNextPageResource():void
		{
			if (pageResourcesCounter >= pageResourcesArr.length)
			{
				curState = STATE_LAST_PAGE_RESOURCE_GENERATED;
				return;
			}
			
			var currentResource : String = pageResourcesArr[pageResourcesCounter];
			
			if (currentResource.indexOf(".htm") != -1) 
			{
				curState = STATE_PAGE_RESOURCE_GENERATING_COMPLETE;
				return;
			}
			
			pageResourceXML = new XML("<resource/>");
			
			pageResourceXML.@id = currentResource.substr(0,36);
			pageResourceXML.@type = currentResource.substr(37,3);
			
			getResourceCDATA(currentResource);
			
		}
		
		private function onPageResourceGenerated():void
		{
			var curResourceId : String = String(pageResourceXML.@id);
			var resourcesListByID : XMLList = pageResourcesXML.resource.(@id == curResourceId);
			
			if (pageResourcesXML.resource.length() == 0 || resourcesListByID.length() == 0)
				pageResourcesXML.appendChild(pageResourceXML);
			
			pageResourcesCounter ++;
			
			curState = STATE_NEXT_PAGE_RESOURCE_GENERATING_START;
		}
		
		private function onLastPageResourceGenerated ():void
		{
			pageResourcesCounter = 0;
			
			pageXML.content.appendChild( XML("<![CDATA[" + appendHighlightScriptToPageContent(pageContentForXml) + "]"+ "]>"));
			pageXML.appendChild(pageResourcesXML);
			
			curState = STATE_PAGE_GENERATING_COMPLETE;
		}
		
		private function appendHighlightScriptToPageContent(pageContent : String) : String
		{
			if (!pageContent)
				return pageContent.toString();
			
			var pageBodyEndWithHighkightAllScript : String = HtmlPageProperties.highlightAllTemplate.concat("\n</body>");
			
			return pageContent.replace("</body>",pageBodyEndWithHighkightAllScript);
		}
		
		private function resetToc(tocObject:Object) : String
		{
			var strToc	: String = "";
			var xmlToc	: XML;
			
			try {
				xmlToc = XML (tocObject);
			}
			catch (e:Error) {
				strToc = tocObject.toString();
				return strToc;
			}
			
			
			xmlToc.@name = "#Page(" + xmlToc.@name + ")";
			
			changePageName(xmlToc);
			
			strToc = xmlToc.toXMLString();
			
			return strToc;
			
			function changePageName(xml:XML):void
			{
				for each(var page:XML in xml.children())
				{
					page.@name = "#Page(" + page.@name + ")";
					changePageName(page);
				}
			}
		}
		
		private function getPageChildren(pageName:String) : XMLList
		{
			var xmlToc : XML = new XML(treeData);
			if (xmlToc.@name == pageName) {
				return xmlToc.children();
			}
			return xmlToc..page.(@name == pageName).children();
		}
		
		private function getImagePropertiesForCurrentResource () : ImageProperties
		{
			var imageProperties : ImageProperties = new ImageProperties();
			
			var xmlContent : XML = XML(pageContentForXml);
			var resourcesList	: XMLList	= xmlContent..img; 
			
			if (resourcesList.length() == 0 || pageResourcesCounter >= resourcesList.length())
			{
				return imageProperties;
			}
			
			var imgTag : XML = xmlContent..img[pageResourcesCounter];
				
			if ( String(imgTag.@width) != "" && !isNaN(Number(imgTag.@width)) )
				imageProperties.width = Number(imgTag.@width);
						
			if ( String(imgTag.@height) != "" && !isNaN(Number(imgTag.@height)) )
				imageProperties.height = Number(imgTag.@height);
			
			if (String(imgTag.@style) != "")
			{
				imageProperties.width = HTML_WYSIWYG.getSizeFromStyle(String(imgTag.@style).toLowerCase(), HTML_WYSIWYG.TYPE_WIDTH); 
				imageProperties.height = HTML_WYSIWYG.getSizeFromStyle(String(imgTag.@style).toLowerCase(), HTML_WYSIWYG.TYPE_HEIGHT);
			}

			return imageProperties;
		}
		
		
		
		private function getResourceCDATA(fileName:String) : void
		{
			var imageProperties : ImageProperties = getImagePropertiesForCurrentResource();
			var imageWidth	: Number = imageProperties.width;
			var imageHeight : Number = imageProperties.height;
			
			var resourceType : String = fileName.substr(37,3);
			
			var newFileName	: String;
			
			var fileStream	: FileStream;
			var location	: File;
			
			newFileName = fileName;
			
			location   = File.applicationStorageDirectory.resolvePath("resources/"+fileName);
			fileStream = new FileStream();
			
			var originalByteArray : ByteArray    = new ByteArray();
			var base64 : Base64Encoder = new Base64Encoder();
			
			if (!location.exists)
			{
				source = base64.toString();
				onResourceDataGenerated(fileName, newFileName, source);
				return;
			}
				
			fileStream.open( location, FileMode.READ);
			fileStream.readBytes(originalByteArray);
			fileStream.close();
			
			base64.encodeBytes(originalByteArray);
			
			var source : String = "";
			
			if (imageWidth <= 0 && imageHeight <= 0)
			{
				source = base64.toString();
				onResourceDataGenerated(fileName, newFileName, source);
				return;
			} 
			
			// image width and height are declared 
			var loader : Loader = new Loader();
			loader.loadBytes( originalByteArray );
			
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, contentLoaderInfoCompleteHandler );
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, contentLoaderInfoErrorHandler );
			loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, contentLoaderInfoErrorHandler );
			
			function contentLoaderInfoErrorHandler (evt:Event) : void 
			{
				source = base64.toString();
				onResourceDataGenerated(fileName, newFileName, source);
				return;
			}
			
			function contentLoaderInfoCompleteHandler (evt:Event) : void 
			{
				var loaderInfo : LoaderInfo = evt.target as LoaderInfo;
				
				var originalBitmapData	: BitmapData;
				var originalBitmap		: Bitmap;
				var resultBitmapData	: BitmapData;
				
				var encoder : PNGEncoder = new PNGEncoder();
				var matrix : Matrix = new Matrix();

				var newWidth	: Number;
				var newHeight	: Number;
				
				var ratioX		: Number = 1;
				var ratioY		: Number = 1;
				
				try
				{
					originalBitmapData = new BitmapData( loaderInfo.width, loaderInfo.height, false, 0xFFFFFF );
					originalBitmapData.draw( loaderInfo.loader, null, null, null, null, true );
					
					originalBitmap = new Bitmap( originalBitmapData, PixelSnapping.AUTO, true );
				}
				catch ( e : Error )
				{
					source = base64.toString();
					onResourceDataGenerated(fileName, newFileName, source);
					return;
				}
				
				// scale
				ratioX = (imageWidth <= 0) ?  1 : imageWidth / originalBitmap.width;
				ratioY = (imageHeight <= 0) ? ratioX : imageHeight / originalBitmap.height;
				
				if (ratioX == 1)
				{
					newWidth = originalBitmap.width;
				} else
				{
					newWidth = ( int( originalBitmap.width * ratioX ) > 0 ) ? int( originalBitmap.width * ratioX ) : 1;
				}
				
				if (ratioY == 1)
				{
					newHeight = originalBitmap.height;
				} else 
				{
					newHeight = ( int( originalBitmap.height * ratioY ) > 0 ) ? int( originalBitmap.height * ratioY ) : 1;
				}
				
				try
				{
					resultBitmapData = new BitmapData( newWidth, newHeight, false );
					originalBitmap.smoothing = true;
				}
				catch ( e : Error )
				{
					source = base64.toString();
					onResourceDataGenerated(fileName, newFileName, source);
					return;
				}
				
				
				matrix.scale( ratioX, ratioY );
				resultBitmapData.draw( originalBitmap.bitmapData, matrix, null, null, null, true );
				
				var resultByteArray : ByteArray = encoder.encode(resultBitmapData);
				base64.reset();
				base64.encodeBytes(resultByteArray);
				
				source = base64.toString();
				
				var uid			: String;
				var md5Stream	: MD5Stream;
				
				md5Stream = new MD5Stream();
				uid = md5Stream.complete(resultByteArray);
				
				newFileName = VdomHelpEditor.convertToUIDFormat(uid) + resourceType;
				onResourceDataGenerated(fileName, newFileName, source);
			}
			
		}
		
		private function onResourceDataGenerated(oldFileName:String, newFileName:String, source:String):void
		{
			if (oldFileName != newFileName)
			{
				pageResourceXML.@id = newFileName.substr(0,36);
				
				var oldResourceSrc : String = "#Res(" + oldFileName.substr(0, 36) + ")";
				var newResourceSrc : String = "#Res(" + newFileName.substr(0, 36) + ")";
				
				// rename resource in page content
				var xmlContent		: XML		= XML(pageContentForXml);
				var resourcesList	: XMLList	= xmlContent..img; 
				
				if (resourcesList.length() == 0 || pageResourcesCounter >= resourcesList.length())
				{
					curState = STATE_PAGE_RESOURCE_GENERATING_COMPLETE;
					return;
				}
				
				var imgTag : XML = xmlContent..img[pageResourcesCounter];
				imgTag.@src = newResourceSrc;
				pageContentForXml = xmlContent.toString();
			
			}
			
			pageResourceXML.appendChild(XML("<![CDATA[" + source +"]"+ "]>"));
			
			curState = STATE_PAGE_RESOURCE_GENERATING_COMPLETE;
		}
		
		private function resetLinksToResourcesAndPages(aPageContent:String) : String
		{
			var patternRes		: RegExp;
			var patternGUID		: RegExp;
			var patternPageLink	: RegExp;
			var arrMatchRes		: Array;
			var resourceGUID	: String;
			var pageGUID		: String;
			var aPageNewContent	: String;
			
			aPageNewContent = aPageContent;
			
			patternRes = /"[ ]*(app-storage:\/resources)[^"]+"/g;
			patternGUID = /\b[A-F0-9]{8}(?:-[A-F0-9]{4}){3}-[A-Z0-9]{12}\b/gim;
			patternPageLink = /<[ ]*a[ ]*href[ ]*=[ ]*"[^"]+"/g;
			
			arrMatchRes = aPageContent.match(patternRes);
			
			// reset resources
			for each ( var strRes : String in arrMatchRes )
			{
				resourceGUID = "";
				if (strRes.search(patternGUID) != -1)
				{
					resourceGUID = strRes.substr(strRes.search(patternGUID), 36);  
				}
				
				var newResource : String = "\"#Res(" + resourceGUID + ")\"";
				
				aPageNewContent = aPageNewContent.replace(strRes, newResource);
			}
			
			arrMatchRes = [];
			
			// reset links to pages
			arrMatchRes = aPageNewContent.match(patternPageLink);
			
			for each ( var strPageLink : String in arrMatchRes )
			{
				pageGUID = "";
				if (strPageLink.search(patternGUID) != -1)
				{
					pageGUID = strPageLink.substr(strPageLink.search(patternGUID), 36);
					if (!pageExistsInDB(pageGUID)) {
						continue;
					}
					
					function pageExistsInDB(pageName:String) : Boolean 
					{
						if (sqlProxy.getPage(productName, "en_US", pageName)) 
							return true;
						return false;
					}
				}
				
				var newPageLink : String = "<a href=\"#Page(" + pageGUID + ")\"";
				
				aPageNewContent = aPageNewContent.replace(strPageLink, newPageLink);
			}
			
			return aPageNewContent;
		}

	}
}