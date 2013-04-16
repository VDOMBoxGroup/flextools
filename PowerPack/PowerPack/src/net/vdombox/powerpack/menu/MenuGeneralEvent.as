package net.vdombox.powerpack.menu
{
	import flash.events.Event;
	
	import mx.controls.Menu;
	import mx.controls.MenuBar;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.events.MenuEvent;
	
	public class MenuGeneralEvent extends MenuEvent
	{
		public static const MENU_FILE_STATE_CHANGED		: String = "menuFileStateChanged";
		public static const MENU_TEMPLATE_STATE_CHANGED	: String = "menuTemplateStateChanged";
		public static const MENU_RUN_STATE_CHANGED		: String = "menuRunStateChanged";
		
		
		public function MenuGeneralEvent (type:String, bubbles:Boolean=false, cancelable:Boolean=true, menuBar:MenuBar=null, menu:Menu=null, item:Object=null, itemRenderer:IListItemRenderer=null, label:String=null, index:int=-1)
		{
			super(type, bubbles, cancelable, menuBar, menu, item, itemRenderer, label, index);
		}
		
		override public function clone():Event
		{
			return new MenuGeneralEvent(type, bubbles, cancelable, menuBar, menu, item, itemRenderer, label, index);
		}
		
	}
}