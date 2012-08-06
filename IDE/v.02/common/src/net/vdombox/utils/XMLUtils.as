package net.vdombox.utils
{
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.collections.XMLListCollection;

	public class XMLUtils
	{		
		public static function sortElementsInXML( xml : XML, sortField : SortField ) : void
		{
			var objects : XMLList = xml.children();
			
			for ( var i : int = 0; i < objects.length(); i++ )
			{
				if ( objects[i].children() )
					sortElementsInXML( objects[i], sortField );
			}
			
			var sort:Sort = new Sort();
			
			sort.fields = [ sortField ];
			
			var xcoll:XMLListCollection = new XMLListCollection(xml.children());
			xcoll.sort = sort;
			xcoll.refresh();
			xml.setChildren(xcoll.copy());
		}
		
		public static function sortElementsInXMLList( xmlList : XMLList, sortField : SortField ) : XMLList
		{	
			var xcoll:XMLListCollection = new XMLListCollection(xmlList);
			
			var sort:Sort = new Sort();
			
			sort.fields = [ sortField ];
			
			xcoll.sort = sort;
			xcoll.refresh();
			xmlList = xcoll.copy();
			
			for ( var i : int = 0; i < xmlList.length(); i++ )
			{
				if ( xmlList[i].children() )
					sortElementsInXML( xmlList[i], sortField );
			}
			
			return xmlList;
		}
	}
}