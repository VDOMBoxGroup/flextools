package
{
	import mx.utils.UIDUtil;

	public class PageToc
	{
		public static const TOC_BY_HEADERS_CLASS	: String = "tocByHeaders"; 
		public static const TOC_BY_PAGES_CLASS		: String = "tocByPages";
		
		private var _tocType	:String = TOC_BY_HEADERS_CLASS;
		private var _tocXML		: XML;
		private var _anchors	: Object;
		
		public function PageToc(value:*=null)
		{
			if (!value) value = "<div/>";
			tocXML = new XML(value);
			
			anchors = {};
		}
		
		public function get anchors():Object
		{
			return _anchors;
		}

		public function set anchors(value:Object):void
		{
			_anchors = value;
		}

		public function get tocXML():XML
		{
			return _tocXML;
		}

		public function set tocXML(value:XML):void
		{
			_tocXML = value;
		}

		public function get tocType():String
		{
			return _tocType;
		}
		
		public function get tocHasContent():Boolean
		{
			if (!tocXML) 
				return false;
			return tocXML.children().length() > 0;
		}

		public function set tocType(value:String):void
		{
			_tocType = value;
			tocXML.@["class"] = _tocType;
		}
		
		public function clearTocContent():void
		{
			for each (var child:XML in tocXML.children()) {
				delete child.parent().children()[child.childIndex()];
			}
			anchors = {};
		}
		
		public function generateTocContent(sourcePageContent:XML, childPages:XMLList):void
		{
			var tocLink		: String;
			var anchorUID	: String;
			
			if (tocType == TOC_BY_PAGES_CLASS) { // toc by pages
				if (!childPages) {
					return;
				}
				for each (var childPage:XML in childPages) {
					tocLink = "<p><a href=\"" + childPage.@name + "\">" + childPage.@title + "</a></p>"; 
					tocXML.appendChild(new XML(tocLink));
				}
			} else { // toc by headers
				if (!sourcePageContent) 
					return;
				
				var i:uint = 0;
				for each (var xmlHeader2:XML in sourcePageContent.body.h2) {
					anchorUID = UIDUtil.createUID();
					tocLink = "<p><a href=\"#" + anchorUID + "\">" + xmlHeader2.text().toString() + "</a></p>";
					
					tocXML.appendChild(new XML(tocLink));
					addHeaderAnchor(i, anchorUID);
					
					i++;
				}
			}
		}
		
		private function addHeaderAnchor(headerIndex:int, anchorUID:String):void
		{
			var link		: String = "<a class=\""+TOC_BY_HEADERS_CLASS+"\" name=\""+anchorUID+"\">&nbsp;</a>";
			
			anchors[headerIndex] = new XML(link);
		}

	}
}