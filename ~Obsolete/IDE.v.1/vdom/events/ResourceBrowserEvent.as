package vdom.events
{
	import flash.events.Event;

	public class ResourceBrowserEvent extends Event
	{
		public static const RESOURCE_SELECTED:String = 'resource_selected';
		public static const RESOURCE_CANCELED:String = 'resource_canceled';
		
		public var resourceID:String;
		public var resourceName:String;
		
		public function ResourceBrowserEvent(type:String, resourceID:String = "", resourceName:String = "", bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.resourceID = resourceID;
			this.resourceName = resourceName;
		}		
	}
}