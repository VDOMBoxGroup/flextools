package
{
	import flash.events.Event;
	
	public class ProductsUpdatorEvent extends Event
	{
		public static const UPDATE_ERROR					: String = "UPDATE_ERROR"; 
		public static const UPDATE_COMPLETE					: String = "UPDATE_COMPLETE";
		public static const UPDATE_NOT_REQUIED				: String = "UPDATE_NOT_REQUIED";
		public static const UPDATE_PRODUCTS_SELECTION_ERROR	: String = "UPDATE_PRODUCTS_SELECTION_ERROR";
		
		public function ProductsUpdatorEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new ProductsUpdatorEvent(type, bubbles, cancelable);
		}
		
		
	}
}