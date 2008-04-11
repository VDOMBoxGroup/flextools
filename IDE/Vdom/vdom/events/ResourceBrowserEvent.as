package vdom.events
{
	import flash.events.Event;

	public class ResourceBrowserEvent extends Event
	{
		public static const RESOURCE_SELECTED:String = 'resource_selected';
		
		public var resourceID:String;
		
		public function ResourceBrowserEvent(type:String, resourceID:String = "", bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.resourceID = resourceID;
		}		
	}
}