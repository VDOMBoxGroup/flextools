package net.vdombox.helpeditor.controller.events
{
	import flash.events.Event;
	
	public class PagesSyncronizationEvent extends Event
	{
		public static const SELECTION_CHANGED	: String = "selectionChanged";
		public static const GET_CUR_SYNC_GROUP_NAME	: String = "getCurrentSyncronizationGroupName";
		
		
		public function PagesSyncronizationEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new PagesSyncronizationEvent(type, bubbles, cancelable);
		}
	}
}