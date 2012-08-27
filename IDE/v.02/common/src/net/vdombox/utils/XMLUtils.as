package net.vdombox.utils
{
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.collections.XMLListCollection;

	public class XMLUtils
	{		
		public static function sortElementsInXML( xml : XML, sortFields : Array ) : void
		{
			var objects : XMLList = xml.children();
			
			for ( var i : int = 0; i < objects.length(); i++ )
			{
				if ( objects[i].children() )
					sortElementsInXML( objects[i], sortFields );
			}
			
			var sort:Sort = new Sort();
			
			sort.fields = sortFields;
			
			var xcoll:XMLListCollection = new XMLListCollection(xml.children());
			xcoll.sort = sort;
			xcoll.refresh();
			xml.setChildren(xcoll.copy());
		}
		
		public static function sortElementsInXMLList( xmlList : XMLList, sortFields : Array ) : XMLList
		{	
			var xcoll:XMLListCollection = new XMLListCollection(xmlList);
			
			var sort:Sort = new Sort();
			
			sort.fields = sortFields;
			
			xcoll.sort = sort;
			xcoll.refresh();
			xmlList = xcoll.copy();
			
			for ( var i : int = 0; i < xmlList.length(); i++ )
			{
				if ( xmlList[i].children() )
					sortElementsInXML( xmlList[i], sortFields );
			}
			
			return xmlList;
		}
	}
}