package spinnerFolder
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.managers.PopUpManager;
	
	public class SpinnerPopUpManager extends UIComponent
	{
		public static const EVENT_SPINNER_WINDOW_ADDED	: String = "onSpinnerWindowAdded";
		public static const EVENT_SPINNER_WINDOW_HIDE	: String = "onSpinnerWindowHide";
		
		private static var _instance	: SpinnerPopUpManager;
		
		private var spinnerWindow		: SpinnerPopUp;
		private var spinnerParent		: DisplayObject;
		
		public function SpinnerPopUpManager()
		{
			if ( !_instance )
			{
				super();
				this.setFocus();
			}
			else
			{
				throw new Error( "Singleton can only be accessed through Soap.anyFunction()" );
			}
			
		}
		
		public static function getInstance() : SpinnerPopUpManager
		{
			if (!_instance)
			{
				_instance = new SpinnerPopUpManager();
			}
			
			return _instance;
		}
		
		public function showSpinner ():void
		{
			if (spinnerWindow)
				return;
			
			setSpinnerText("");
			
			spinnerWindow = new SpinnerPopUp();
			
			spinnerParent = Application.application.systemManager;
				
			spinnerWindow.width =  spinnerParent.width;
			spinnerWindow.height = spinnerParent.height;
			
			spinnerWindow.addEventListener(EVENT_SPINNER_WINDOW_ADDED, this.dispatchEvent);
			
			PopUpManager.addPopUp(spinnerWindow, spinnerParent, true);
		}
		
		public function setSpinnerText (txt : String) : void 
		{
			if (spinnerWindow)
				spinnerWindow.setSpinnerText(txt);
		}
		
		public function setSpinnerResourceText (txt : String) : void 
		{
			if (spinnerWindow)
				spinnerWindow.setSpinnerResourceText(txt);
		}
		
		public function hideSpinner ():void
		{
			if (spinnerWindow)
			{
				spinnerWindow.addEventListener(EVENT_SPINNER_WINDOW_HIDE, spinnerHideHandler);
				spinnerWindow.startOutroAnimation();
				
				return;
			}
			
			this.dispatchEvent(new Event(EVENT_SPINNER_WINDOW_HIDE));
		}
		
		private function spinnerHideHandler(evt:Event):void
		{
			spinnerWindow.removeEventListener(EVENT_SPINNER_WINDOW_HIDE, spinnerHideHandler);
			
			PopUpManager.removePopUp(spinnerWindow);
			spinnerWindow = null;
			
			this.dispatchEvent(evt);
		}
		
		
	}
}