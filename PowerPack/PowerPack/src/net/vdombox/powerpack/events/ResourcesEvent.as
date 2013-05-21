package net.vdombox.powerpack.events
{
	import flash.events.Event;
	
	public class ResourcesEvent extends Event
	{
		public static const COMPLETE : String = "complete";
		public static const CANCEL : String = "cancel";
		public static const ERROR : String = "error";
		public static const CHANGED : String = "changed";

		public var resourceID : String = "";
		public var errorMsg : String = "";

		public function ResourcesEvent (type:String, resourceID : String = "", errorMsg : String = "", bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);

			this.resourceID = resourceID;
			this.errorMsg = errorMsg;
		}
		
		override public function clone() : Event
		{
			return new ResourcesEvent( type, resourceID, errorMsg, bubbles,  cancelable );
		}
	}
}