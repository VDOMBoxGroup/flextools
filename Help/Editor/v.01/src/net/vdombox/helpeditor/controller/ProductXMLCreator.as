package net.vdombox.helpeditor.controller
{
	
	import com.adobe.crypto.MD5Stream;
	import com.adobe.utils.StringUtil;
	
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
	
	import net.vdombox.helpeditor.model.HtmlPageProperties;
	import net.vdombox.helpeditor.model.ImageProperties;
	import net.vdombox.helpeditor.model.proxy.SQLProxy;
	import net.vdombox.helpeditor.model.SpinnerPopupMessages;
	import net.vdombox.helpeditor.utils.PageUtils;
	import net.vdombox.helpeditor.utils.ResourceUtils;
	import net.vdombox.helpeditor.utils.Utils;
	import net.vdombox.helpeditor.view.components.wysiwyg.HTML_WYSIWYG;
	import net.vdombox.helpeditor.view.spinner.SpinnerPopUp;

	public class ProductXMLCreator extends EventDispatcher
	{
		// states ...
		private static const STATE_PRODUCT_XML_CREATING					: String = "stateProductXMLCreating";
		
		private static const STATE_TOC_GENERATING						: String = "stateProductTocCreating";
		
		private static const STATE_PAGES_GENERATING						: String = "statePagesGenerating";
		private static const STATE_NEXT_PAGE_GENERATING_START			: String = "stateNextPageGeneratingStart";
		private static const STATE_NEXT_PAGE_CHECK_IMAGES_WIDTH			: String = "stateNextPageCheckImagesWidth";
		private static const STATE_NEXT_PAGE_IMAGES_WIDTH_CHECKING		: String = "stateNextPageImagesWidthChecking";
		private static const STATE_NEXT_PAGE_IMAGES_WIDTH_CHECKED		: String = "stateNextPageImagesWidthChecked";
		private static const STATE_PAGE_GENERATING_COMPLETE				: String = "statePageGeneratingComplete";
		private static const STATE_LAST_PAGE_GENERATED					: String = "stateLastPageGenerated";
		
		private static const STATE_PAGE_RESOURCES_GENERATING_START				: String = "statePageResourcesGeneratingStart";
		private static const STATE_PAGE_NEXT_RESOURCE_GENERATING_START			: String = "statePageNextResourceGeneratingStart";
		private static const STATE_PAGE_NEXT_RESOURCE_GENERATING_IN_PROGRESS	: String = "statePageNextResourceGeneratingInProgress";
		private static const STATE_PAGE_NEXT_RESOURCE_GENERATING_COMPLETE		: String = "statePageNextResourceGeneratingComplete";
		private static const STATE_PAGE_LAST_RESOURCE_GENERATING_COMPLETE		: String = "statePageLastResourceGenerated";
		
		private static const STATE_XML_CREATION_COMPLETE				: String = "stateXMLCreationComplete";
		// ... states
		
		public static const EVENT_ON_XML_CREATION_COMPLETE	: String = "eventXMLCreationComplete";
		
		private const guidResourseRegExp	: RegExp = /\b[A-F0-9]{8}(?:-[A-F0-9]{4}){3}-[A-Z0-9]{12}\.[A-Z]+\b/gim;
				
		private var sqlProxy	: SQLProxy = new SQLProxy();
		
		private var _productXML			: XML;
		
		private var html_wysiwyg		: HTML_WYSIWYG;
		
		private var pagesObj		: Object;
		private var pagesXML		: XML;
		private var pagesCounter	: Number = 0;
		
		private var productTocXML				: XML;
		private var pageXML				: XML;
		
		private var pageResources		: XMLList;
		private var currentResource		: XML;
		private var pageResourcesXML	: XML;
		private var pageResourceXML		: XML;
		private var pageResourcesCounter: Number = 0;
		
		private var currentPageObj		: Object;
		private var pageContent			: String;
		private var pageContentXML		: XML;
		
		private var productName			: String;
		private var productTitle		: String;
		private var productLanguage		: String;
		private var treeData			: *;
		
		private var appendPage			: Boolean = true;
		private var appendPageRes		: Boolean = true;
		
		private var spinnerManager		: SpinnerPopUpManager = SpinnerPopUpManager.getInstance();
		
		private var curState			: String;
		
		private var curPageMsg			: String = "";
		private var curPageResourceMsg	: String = "";
		
		public function ProductXMLCreator()
		{
		}
		
		public function get productXML():XML
		{
			return _productXML;
		}
		
		public function set productXML(value:XML):void
		{
			_productXML = value;
		}

		
		public function generateProductXML(aProductName:String, aProductTitle:String, aProductLang:String, aTreeData:*, htmlWysiwyg:HTML_WYSIWYG):void
		{
			html_wysiwyg = htmlWysiwyg;
			
			productName = aProductName;
			productTitle = aProductTitle;
			productLanguage = aProductLang;
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
					
					createProductXML();
					break;
				}
				
				case STATE_TOC_GENERATING : 
				{
					addProductToc();
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
					
				case STATE_NEXT_PAGE_CHECK_IMAGES_WIDTH : 
				{
					checkAndResetPageImagesWidth();
					break;
				}
					
				case STATE_NEXT_PAGE_IMAGES_WIDTH_CHECKED : 
				{
					startGeneratingPageContent();
					break;
				}
				
				case STATE_PAGE_RESOURCES_GENERATING_START : 
				{
					startGeneratingPageResources();
					break;
				}
					
				case STATE_PAGE_NEXT_RESOURCE_GENERATING_START : 
				{
					generateNextPageResource();
					break;
				}
				case STATE_PAGE_NEXT_RESOURCE_GENERATING_IN_PROGRESS :
				{
					break;
				}
				case STATE_PAGE_NEXT_RESOURCE_GENERATING_COMPLETE : 
				{
					onPageResourceGenerationComplete();
					break;
				}
				case STATE_PAGE_LAST_RESOURCE_GENERATING_COMPLETE : 
				{
					spinnerManager.setSpinnerResourceText("");
					
					onPageLastResourceGenerated();
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
			
		private function createProductXML():void
		{
			productXML  = new XML("<product/>");
			
			productXML.name = productName;
			productXML.version = sqlProxy.upVersion(productName, productLanguage); // get Version
			productXML.title = productTitle;
			productXML.description = "";
			productXML.language = productLanguage;
			
			curState = STATE_TOC_GENERATING;
		}
		
		private function addProductToc () : void
		{
			productTocXML      = new XML("<toc/>");
			
			var toc : XML = sqlProxy.getToc(productName) as XML;
			
			if (!toc || !toc.children() || toc.children().length() == 0)
			{
				curState = STATE_XML_CREATION_COMPLETE;
				return;
			}
			
			productTocXML.appendChild(toc);
			
			for each (var page : XML in productTocXML..page)
			{
				page.@name = "#Page(" + page.@name + ")";
			}
			
			productXML.appendChild(productTocXML);
			
			curState = STATE_PAGES_GENERATING;
		}
		
		private function generatePages() : void
		{
			pagesCounter = 0;
			pagesObj = {};
			pagesXML = null;
			
			pagesObj = sqlProxy.getProductsPages(productName, productLanguage);
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
			
			if (productTocXML.toString().indexOf(currentPageObj["name"]) == -1) // page doesn't exist in toc 
			{
				appendPage = false;

				curState = STATE_PAGE_GENERATING_COMPLETE;
				return;
			}
			
			pageContent = currentPageObj["content"];
			pageContent = Utils.clearASCII(pageContent);
			
			if (html_wysiwyg)
			{
				curState = STATE_NEXT_PAGE_CHECK_IMAGES_WIDTH;
				return;
			}
			
			curState = STATE_NEXT_PAGE_IMAGES_WIDTH_CHECKED;
		}
		
		private function checkAndResetPageImagesWidth () : void
		{
			curState = STATE_NEXT_PAGE_IMAGES_WIDTH_CHECKING;
			
			html_wysiwyg.addEventListener(HTML_WYSIWYG.EVENT_WYSIWYG_IMAGES_WIDTH_SETTED, imagesWidthChecked);
			html_wysiwyg.resetImagesWidth(pageContent);
			
			function imagesWidthChecked (event : Event) : void
			{
				if (html_wysiwyg && html_wysiwyg.hasEventListener(HTML_WYSIWYG.EVENT_WYSIWYG_IMAGES_WIDTH_SETTED))
					html_wysiwyg.removeEventListener(HTML_WYSIWYG.EVENT_WYSIWYG_IMAGES_WIDTH_SETTED, imagesWidthChecked);
				
				curState = STATE_NEXT_PAGE_IMAGES_WIDTH_CHECKED;
			}
		}
		
		private function startGeneratingPageContent() : void
		{
			pageContent = html_wysiwyg.pageContent;
			
			pageContentXML = new XML(pageContent);
			
			pageXML = new XML("<page/>");
			
			pageXML.name = currentPageObj[ "name" ];
			pageXML.version = currentPageObj[ "version" ];
			pageXML.title = currentPageObj[ "title" ];
			pageXML.description = currentPageObj[ "description" ];
			
			var content : XML = XML("<content/>");
			
			pageXML.appendChild(content);
			
			curState = STATE_PAGE_RESOURCES_GENERATING_START;
		}
		
		private function startGeneratingPageResources () : void
		{
			pageResourcesXML = new XML("<resources/>");
			
			pageResources = pageContentXML..img;
			
			if (!pageResources || pageResources.length() <= 0) {
				curState = STATE_PAGE_LAST_RESOURCE_GENERATING_COMPLETE;
				return;			
			}
			
			curState = STATE_PAGE_NEXT_RESOURCE_GENERATING_START;
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
			if (pageResourcesCounter >= pageResources.length())
			{
				curState = STATE_PAGE_LAST_RESOURCE_GENERATING_COMPLETE;
				return;
			}
			
			appendPageRes = true;
			
			currentResource = pageResources[pageResourcesCounter];
			pageResourceXML = null;
			
			if (!ResourceUtils.correctResourceType(currentResourceType)) 
			{
				appendPageRes = false;
				
				curState = STATE_PAGE_NEXT_RESOURCE_GENERATING_COMPLETE;
				return;
			}
			
			getResourceCDATA();
			
		}
		
		private function get currentResourceGUID () : String
		{
			var resourceSrc : String = String(currentResource.@src);
			
			var patternGUID : RegExp = /\b[A-F0-9]{8}(?:-[A-F0-9]{4}){3}-[A-Z0-9]{12}\b/gim;
			
			var resourceGUIDStartIndex : int = resourceSrc.search(patternGUID);
			
			if (resourceGUIDStartIndex == -1)
				return "";
			
			return resourceSrc.substr(resourceGUIDStartIndex, 36);
		}
		
		private function get currentResourceType () : String
		{
			var resourceSrc : String = String(currentResource.@src);
			
			var lastDotIndex : int = resourceSrc.indexOf(".");
			if (lastDotIndex == -1)
				return "";
			
			return resourceSrc.substr(lastDotIndex+1);
		}
		
		private function onPageResourceGenerationComplete():void
		{
			if (appendPage && pageResourceXML && currentResourceGUID != "")
			{
				var resourcesListByID : XMLList = pageResourcesXML.resource.(@id == currentResourceGUID);
				
				if (pageResourcesXML.resource.length() == 0 || resourcesListByID.length() == 0)
				{
					pageResourceXML.@id = currentResourceGUID;
					pageResourceXML.@type = currentResourceType;
					
					pageResourcesXML.appendChild(pageResourceXML);
					
					currentResource.@src = "#Res(" + currentResourceGUID + ")";
				}
			}
			
			pageResourcesCounter ++;
			
			curState = STATE_PAGE_NEXT_RESOURCE_GENERATING_START;
		}
		
		private function onPageLastResourceGenerated ():void
		{
			pageResourcesCounter = 0;
			pageResources = null;
			
			pageContent = VdomHelpEditor.getPageContentWithToc( pageContentXML.toString(), 
																		Boolean(currentPageObj["useToc"]),
																		getPageChildren(currentPageObj["name"]) );
			
			pageContent = PageUtils.getInstance().replaceTemplatesLinksByTemplateContent(pageContent);
			
			pageContentXML = new XML(pageContent);
			
			resetLinksToPages();
			
			pageContent = pageContentXML.toString();
			
			appendHighlightScriptToPageContent();
			
			pageXML.content.appendChild( XML("<![CDATA[" + pageContent + "]"+ "]>"));
			pageXML.appendChild(pageResourcesXML);
			
			curState = STATE_PAGE_GENERATING_COMPLETE;
		}
		
		private function appendHighlightScriptToPageContent() : void
		{
			if (!pageContent)
				return;
			
			if (pageContent.indexOf(HtmlPageProperties.highlightAllTemplate) >= 0)
				pageContent = pageContent.replace(HtmlPageProperties.highlightAllTemplate, "");
			
			if (pageContent.indexOf(HtmlPageProperties.jsCoreFileName) == -1)
				return; 
				
			var pageBodyEndWithHighkightAllScript : String = HtmlPageProperties.highlightAllTemplate.concat("\n</body>");
 
			pageContent = pageContent.replace("</body>",pageBodyEndWithHighkightAllScript);
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
			
			if (pageResources.length() == 0 || pageResourcesCounter >= pageResources.length())
			{
				return imageProperties;
			}
			
			if ( String(currentResource.@width) != "" && !isNaN(Number(currentResource.@width)) )
				imageProperties.width = Number(currentResource.@width);
						
			if ( String(currentResource.@height) != "" && !isNaN(Number(currentResource.@height)) )
				imageProperties.height = Number(currentResource.@height);
			
			if (String(currentResource.@style) != "")
			{
				imageProperties.width = Utils.getSizeFromStyle(String(currentResource.@style).toLowerCase(), Utils.TYPE_WIDTH); 
				imageProperties.height = Utils.getSizeFromStyle(String(currentResource.@style).toLowerCase(), Utils.TYPE_HEIGHT);
			}

			return imageProperties;
		}
		
		
		
		private function getResourceCDATA() : void
		{
			curState = STATE_PAGE_NEXT_RESOURCE_GENERATING_IN_PROGRESS;
			
			var fileName : String = currentResourceGUID + "." + currentResourceType;
			
			var imageProperties : ImageProperties = getImagePropertiesForCurrentResource();
			var imageWidth	: Number = imageProperties.width;
			var imageHeight : Number = imageProperties.height;
			
			var fileStream	: FileStream;
			var location	: File;
			
			location   = File.applicationStorageDirectory.resolvePath("resources/"+fileName);
			fileStream = new FileStream();
			
			var originalByteArray : ByteArray    = new ByteArray();
			var base64 : Base64Encoder = new Base64Encoder();
			
			if (!location.exists)
			{
				source = "";
				onResourceDataGenerated(source);
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
				onResourceDataGenerated(source);
				return;
			} 
			
			// image width and height are declared 
			if (!originalByteArray || originalByteArray.length == 0)
			{
				source = base64.toString();
				onResourceDataGenerated(source);
				return;
			}
			
			var loader : Loader = new Loader();
			loader.loadBytes( originalByteArray );
			
			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, contentLoaderInfoCompleteHandler );
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, contentLoaderInfoErrorHandler );
			loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, contentLoaderInfoErrorHandler );
			
			function contentLoaderInfoErrorHandler (evt:Event) : void 
			{
				source = base64.toString();
				onResourceDataGenerated(source);
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
					onResourceDataGenerated(source);
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
					onResourceDataGenerated(source);
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
				
				currentResource.@src = ResourceUtils.convertToUIDFormat(uid) + "." + currentResourceType;
				onResourceDataGenerated(source);
			}
			
		}
		
		private function onResourceDataGenerated (source : String) : void
		{
			if (!source)
			{
				appendPageRes = false;
				
				curState = STATE_PAGE_NEXT_RESOURCE_GENERATING_COMPLETE;
				return;
			}
			
			pageResourceXML = new XML("<resource/>");
			
			pageResourceXML.appendChild(XML("<![CDATA[" + source +"]"+ "]>"));
			
			curState = STATE_PAGE_NEXT_RESOURCE_GENERATING_COMPLETE;
		}
		
		private function isGUID (value : String) : Boolean
		{
			if (!value)
				return false;
			
			var patternGUID		: RegExp = /\b[A-F0-9]{8}(?:-[A-F0-9]{4}){3}-[A-Z0-9]{12}\b/gim;;
			
			return (value.search(patternGUID) == 0) && (value.length == 36);
		}
		
		private function resetLinksToPages() : void
		{
			
			var arrMatchRes		: Array;
			var resourceGUID	: String;
			var pageGUID		: String;
			
			var href : String = "";
			for each (var link : XML in pageContentXML..a)
			{
				href = StringUtil.trim(link.@href);
				
				if (isGUID(href))
					link.@href = "#Page(" + href + ")";
			}
			
		}
		
	}
}