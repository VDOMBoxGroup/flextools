package 
{
	import flash.events.Event;

	public class HelpEvent extends Event
	{
		public static const INSTALL_FILE_LOADED:String = 'installFileLoaded';
		public static const INSTALL_FILE_LOADED_ERROR:String = 'installFileLoadedError';
		public static const UPDATE_DISPLAY_LIST:String = 'updateDisplayList';
		
		public var dataEvent:Object;
		
		public function HelpEvent(type:String, dataEvent:Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		
		{
			super(type, bubbles, cancelable);
			this.dataEvent = dataEvent;
		}
		
	}
}