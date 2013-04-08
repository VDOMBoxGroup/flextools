package net.vdombox.helpeditor.controller.events
{
	import flash.events.Event;
	
	public class ProductXMLCreatorEvent extends Event
	{
		public static const EVENT_ON_XML_CREATION_COMPLETE	: String = "xmlCreationComplete";
		public static const EVENT_ON_XML_CREATION_ERROR		: String = "xmlCreationError";
		
		public var message : String = "";
		
		public function ProductXMLCreatorEvent(type:String, message:String=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.message = message;
		}
		
		override public function clone():Event
		{
			return new ProductXMLCreatorEvent(type, message, bubbles, cancelable);
		}
		
	}
}