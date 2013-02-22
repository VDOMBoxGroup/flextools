package net.vdombox.components.xmldialogeditor.utils
{
	import mx.collections.ArrayCollection;
	
	import spark.collections.Sort;

	public class SortUtil
	{
		public function SortUtil()
		{
		}
		
		public static function sortByText( array : ArrayCollection ) : void
		{
			var sort : Sort = new Sort();
			sort.compareFunction = sortFunctionByText
			array.sort = sort;
			array.refresh();
		}
		
		public static function sortByID( array : ArrayCollection ) : void
		{
			var sort : Sort = new Sort();
			sort.compareFunction = sortFunctionById;
			array.sort = sort;
			array.refresh();
		}
		
		private static function sortFunctionByText(a:Object, b:Object, array:Array = null):int
		{
			var aString : String = a.value.value.toLowerCase();
			var bString : String = b.value.value.toLowerCase();
			
			if( aString < bString )
				return -1;
			else if( aString > bString )
				return 1;
			else
				return 0;
			return -1;
		}
		
		private static function sortFunctionById(a:Object, b:Object, array:Array = null):int
		{
			var aString : String = a.id.value.toLowerCase();
			var bString : String = b.id.value.toLowerCase();
			
			if( aString < bString )
				return -1;
			else if( aString > bString )
				return 1;
			else
				return 0;
			return -1;
		}
	}
}