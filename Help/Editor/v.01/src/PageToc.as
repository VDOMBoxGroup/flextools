package
{
	import mx.utils.UIDUtil;

	public class PageToc
	{
		public static const TOC_CLASS_FOR_STYLES	: String = "contents";
		public static const TOC_BY_HEADERS_CLASS	: String = "tocByHeaders"; 
		public static const TOC_BY_PAGES_CLASS		: String = "tocByPages";
		
		public static const ANCOR_CLASS				: String = "ancor";
		
		private var _tocType	:String = TOC_BY_HEADERS_CLASS;
		private var _tocXML		: XML;
		private var _anchors	: Object;
		
		public function PageToc(value:*=null)
		{
			XML.ignoreWhitespace = true;
			XML.ignoreComments = true;
			
			if (!value) value = "<ul/>";
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
			if (value.indexOf(" ") >= 0) {
				value = value.split(" ")[0];
			}
			_tocType = value;
			tocXML.@["class"] = _tocType + " " + TOC_CLASS_FOR_STYLES;
		}
		
		public function clearTocContent():void
		{
			for each (var child:XML in tocXML.children()) {
				delete child.parent().children()[child.childIndex()];
			}
			anchors = {};
		}
		
		public function generateTocContent(sourcePageContent:XML, childPages:XMLList, useAnchors:Boolean = true):void
		{
			var tocLink		: String;
			var anchorUID	: String;
			
			if (tocType == TOC_BY_PAGES_CLASS) { // toc by pages
				if (!childPages) {
					return;
				}
				for each (var childPage:XML in childPages) {
					tocLink = "<li><a href=\"" + childPage.@name + "\">" + childPage.@title + "</a></li>"; 
					tocXML.appendChild(new XML(tocLink));
				}
			} else { // toc by headers
				if (!sourcePageContent) 
					return;
				
				var i:uint = 0;
				for each (var xmlHeader2:XML in sourcePageContent.body.h2) {
					anchorUID = UIDUtil.createUID();
					tocLink = "<li><a href=\"#" + anchorUID + "\">" + xmlHeader2.text().toString() + "</a></li>";
					
					tocXML.appendChild(new XML(tocLink));
					addHeaderAnchor(i, anchorUID, useAnchors);
					
					i++;
				}
			}
		}
		
		private function addHeaderAnchor(headerIndex:int, anchorUID:String, useAnchors:Boolean = true):void
		{
			var link	: String;
			var xml		:XML;
			
			xml = <a class={ANCOR_CLASS} name={anchorUID}>&#160;</a>;
				
			anchors[headerIndex] = xml;
		}

	}
}