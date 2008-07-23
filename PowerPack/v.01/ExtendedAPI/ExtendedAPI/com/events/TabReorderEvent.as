package ExtendedAPI.com.events
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.events.IndexChangedEvent;
	
	/**
	 *  This is basically an IndexChangedEvent. But different.
	 * 
	 *  @see mx.core.Container
	 */
	public class TabReorderEvent extends IndexChangedEvent
	{
		public function TabReorderEvent(type:String, bubbles:Boolean = false,
									  cancelable:Boolean = false,
									  relatedObject:DisplayObject = null,
									  oldIndex:Number = -1,
									  newIndex:Number = -1,
                                      triggerEvent:Event = null)
		{
			super(type, bubbles, cancelable, relatedObject, oldIndex, newIndex, triggerEvent);
		}
		
		override public function clone():Event {
			return new TabReorderEvent(type, bubbles, cancelable, relatedObject, oldIndex, newIndex, triggerEvent);
		}
	}
}