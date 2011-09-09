package
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import mx.controls.Alert;
	import mx.utils.Base64Encoder;

	public class ProductXMLCreator extends EventDispatcher
	{
		public static const EVENT_ON_XML_CREATION_COMPLETE	: String = "onXMLCreationComplete";
		
		private var sqlProxy	: SQLProxy = new SQLProxy();
		
		private var _productXML	: XML;
		
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

		
		public function generateProductXML(productName:String, productTitle:String, treeData:*):void
		{
			productXML  = new XML("<product/>");
			
			productXML.name = productName;
			productXML.version = sqlProxy.upVersion(productName, "en_US"); // get Version
			productXML.title = productTitle;
			productXML.description = "";
			productXML.language = "en_US";
			
			var result : Object = sqlProxy.getProductsPages(productName, "en_US");
			
			// generate toc ...
			var tocXML : XML       = new XML("<toc/>");
			var tocString : String = resetToc(treeData);
			var regExp : RegExp    = /isBranch="true"/gim;
			
			tocXML.appendChild(XML(tocString.replace(regExp,' ')));
			productXML.appendChild(tocXML);
			// ... generate toc
			
			// generate pages ...
			var pages				: XML		= new XML("<pages/>");
			var length 				: Number	= Number(result.length);
			var guidResourseRegExp	: RegExp	= /\b[A-F0-9]{8}(?:-[A-F0-9]{4}){3}-[A-Z0-9]{12}\.[A-Z]{3}\b/gim;
			
			for ( var i : String in result )
			{
				var pageContent			: String;
				var pageContectWithToc	: String;
				var pageContentToXml	: String;
				
				pageContent = result[i]["content"];
				
				pageContectWithToc = VdomHelpEditor.getPageContentWithToc(result[i]["content"], 
																		  Boolean(result[i]["useToc"]),
																		  getPageChildren(result[i]["name"], treeData));
				
				pageContentToXml = resetPageContent(pageContectWithToc,	productName );
				
				var pageXML : XML        = new XML("<page/>");
				
				pageXML.name = result[ i ][ "name" ];
				pageXML.version = result[ i ][ "version" ];
				pageXML.title = result[ i ][ "title" ];
				pageXML.description = result[ i ][ "description" ];
				
				var content : XML = XML("<content/>");
				
				content.appendChild( XML("<![CDATA[" + 
					pageContentToXml +
					"]"+ "]>"));
				
				pageXML.appendChild(content);
				
				// get resources ...		
				var pagesResources : Array = pageContent.match(guidResourseRegExp);
				var resources : XML        = new XML("<resources/>");
				
				for ( var j : String in pagesResources )
				{
					if (pagesResources[ j ].indexOf(".htm") != -1) {
						continue;
					}
					var resource : XML        = new XML("<resource/>");
					var resourceName : String = pagesResources[ j ];
					
					resource.@id = resourceName.substr(0,36);
					resource.@type = resourceName.substr(37,3);
					resource.appendChild(getResoucesCDATA(resourceName));
					resources.appendChild(resource);
				}
				
				pageXML.appendChild(resources);
				// ... get resources
				
				pages.appendChild(pageXML);
				
			}
			// ... generate pages
			
			productXML.appendChild(pages);
			productXML.normalize();
			
			this.dispatchEvent(new Event(EVENT_ON_XML_CREATION_COMPLETE));
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
		
		private function getPageChildren(pageName:String, treeData:*) : XMLList
		{
			var xmlToc : XML = new XML(treeData);
			if (xmlToc.@name == pageName) {
				return xmlToc.children();
			}
			return xmlToc..page.(@name == pageName).children();
		}
		
		private function getResoucesCDATA(fileName:String) : XML
		{
			var location : File         = File.applicationStorageDirectory.resolvePath("resources/"+fileName);
			var fileStream : FileStream = new FileStream();
			//					var location : File = new File(docsDir.url +"/"+ fileName + ".xml");
			
			try
			{
				var byteArr : ByteArray    = new ByteArray();
				var base64 : Base64Encoder = new Base64Encoder();
				
				fileStream.open( location, FileMode.READ);
				fileStream.readBytes(byteArr);
				fileStream.close();
				
				base64.encodeBytes(byteArr);
				var sourse : String = base64.toString();
			}
			catch ( error : Error )
			{
			}
			
			return XML("<![CDATA[" + sourse +"]"+ "]>");
		}
		
		private function resetPageContent(aPageContent:String, productName:String) : String
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