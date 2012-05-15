package net.vdombox.helpeditor.controller.events
{
	import flash.events.Event;
	
	public class PagesSyncronizationEvent extends Event
	{
		public static const SELECTION_CHANGED	: String = "selectionChanged";
		
		
		public var pageName		: String = "";
		public var pageSelected	: Boolean;
		
		public function PagesSyncronizationEvent(type:String, pageName:String="", pageSelected:Boolean=false, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.pageName = pageName;
			this.pageSelected = pageSelected;
		}
		
		override public function clone():Event
		{
			return new PagesSyncronizationEvent(type, pageName, pageSelected, bubbles, cancelable);
		}
	}
}