package
{
	
	import com.adobe.crypto.MD5Stream;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.graphics.codec.PNGEncoder;
	import mx.utils.Base64Encoder;

	public class ProductXMLCreator extends EventDispatcher
	{
		public static const EVENT_ON_XML_CREATION_COMPLETE	: String = "onXMLCreationComplete";
		
		private const guidResourseRegExp	: RegExp = /\b[A-F0-9]{8}(?:-[A-F0-9]{4}){3}-[A-Z0-9]{12}\.[A-Z]{3}\b/gim;
		private const imgTagRegExp			: RegExp = /<[ ]*img[^>]*[ ]*\/[ ]*>/g;
		
		private const WIDTH_TYPE			: Number = 0;
		private const HEIGHT_TYPE			: Number = 1;
		
		private var sqlProxy	: SQLProxy = new SQLProxy();
		
		private var _productXML			: XML;
		
		private var pagesObj		: Object;
		private var pagesXML		: XML;
		private var pagesCounter	: Number = 0;
		
		private var pageXML				: XML;
		private var pageResourcesArr	: Array;
		private var pageResourcesXML	: XML;
		private var pageResourceXML		: XML;
		private var pageResourcesCounter: Number = 0;
		private var pageContentForXml	: String;
		
		private var pageContent			: String;
		
		private var productName			: String;
		private var productTitle		: String;
		private var treeData			: *;
		
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

		
		public function generateProductXML(aProductName:String, aProductTitle:String, aTreeData:*):void
		{
			productName = aProductName;
			productTitle = aProductTitle;
			treeData = aTreeData;
			
			productXML  = new XML("<product/>");
			
			productXML.name = productName;
			productXML.version = sqlProxy.upVersion(productName, "en_US"); // get Version
			productXML.title = productTitle;
			productXML.description = "";
			productXML.language = "en_US";
			
			// generate toc ...
			var tocXML : XML       = new XML("<toc/>");
			var tocString : String = resetToc(treeData);
			var regExp : RegExp    = /isBranch="true"/gim;
			
			tocXML.appendChild(XML(tocString.replace(regExp,' ')));
			productXML.appendChild(tocXML);
			// ... generate toc
			
			generatePages();
			
		}
			
		private function generatePages() : void
		{
			pagesCounter = 0;
			pagesObj = {};
			pagesXML = null;
			
			pagesObj = sqlProxy.getProductsPages(productName, "en_US");
			pagesXML	= new XML("<pages/>");
			
			// generate pages ...
			if (!pagesObj || pagesObj.length <= 0) {
				
				onLastPageGenerated();
				return;
			
			}
				
			generateNextPage();
			
		}
		
		private function generateNextPage():void
		{
			if (pagesCounter >= pagesObj.length)
			{
				pagesCounter = 0;
				onLastPageGenerated(); 
				return;
			}
			
			var currentPageObj : Object = pagesObj[pagesCounter];
				
			var pageContectWithToc	: String;
				
			pageContent = currentPageObj["content"];
				
			pageContectWithToc = VdomHelpEditor.getPageContentWithToc(currentPageObj["content"], 
																	  Boolean(currentPageObj["useToc"]),
																	  getPageChildren(currentPageObj["name"])
																	  );
			
			pageContentForXml = resetLinksToResourcesAndPages(pageContectWithToc);
			
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
				onLastPageResourceGenerated();
				return;			
			}
			
			generateNextPageResource();
			// ... get resources
			
				
		}
		
		private function onPageGenerated():void
		{
			pagesXML.appendChild(pageXML);
			
			pagesCounter ++;
			
			generateNextPage();
		}
		
		private function onLastPageGenerated():void
		{
			productXML.appendChild(pagesXML);
			productXML.normalize();
			
			this.dispatchEvent(new Event(EVENT_ON_XML_CREATION_COMPLETE));
		}
		
		private function generateNextPageResource():void
		{
			if (pageResourcesCounter >= pageResourcesArr.length)
			{
				pageResourcesCounter = 0;
				onLastPageResourceGenerated(); 
				return;
			}
			
			var currentResource : String = pageResourcesArr[pageResourcesCounter];
			
			if (currentResource.indexOf(".htm") != -1) 
			{
				onPageResourceGenerated();
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
			
			generateNextPageResource();
		}
		
		private function onLastPageResourceGenerated ():void
		{
			pageXML.content.appendChild( XML("<![CDATA[" + pageContentForXml + "]"+ "]>"));
			pageXML.appendChild(pageResourcesXML);
			
			onPageGenerated();
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
				imageProperties.width = getSizeFromStyle(String(imgTag.@style).toLowerCase(), WIDTH_TYPE); 
				imageProperties.height = getSizeFromStyle(String(imgTag.@style).toLowerCase(), HEIGHT_TYPE);
			}

			return imageProperties;
		}
		
		private function getSizeFromStyle(strStyle:String, type : Number = WIDTH_TYPE) : Number
		{
			var strWidth : String = "width";
			var strHeight : String = "height";
			var regExpDigitVal	: RegExp = /[\d]+/i;
			
			var firstInd : int;
			var sizeStr : String;
			var sizeNumber : Number = -1;
			
			var str : String = type == WIDTH_TYPE ? strWidth : strHeight;
			
			firstInd = strStyle.search(str);
			
			if (firstInd != -1) 
				sizeStr = strStyle.substring(firstInd);
			
			try {
				sizeNumber = Number(sizeStr.match(regExpDigitVal)[0]);
			} catch (e:Error)
			{
				sizeNumber = -1;
			}
			
			return sizeNumber;
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
					originalBitmapData.draw( loaderInfo.loader );
					
					originalBitmap = new Bitmap( originalBitmapData );
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
				resultBitmapData.draw( originalBitmap.bitmapData, matrix );
				
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
					onPageResourceGenerated();
					return;
				}
				
				var imgTag : XML = xmlContent..img[pageResourcesCounter];
				imgTag.@src = newResourceSrc;
				pageContentForXml = xmlContent.toString();
			
			}
			
			pageResourceXML.appendChild(XML("<![CDATA[" + source +"]"+ "]>"));
			
			onPageResourceGenerated();
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