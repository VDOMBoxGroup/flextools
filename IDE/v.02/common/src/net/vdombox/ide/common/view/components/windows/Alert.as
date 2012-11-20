package net.vdombox.ide.common.view.components.windows
{
	import flash.display.NativeWindowSystemChrome;
	import flash.events.Event;
	import flash.events.EventPhase;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.events.PopUpWindowEvent;
	import net.vdombox.ide.common.view.components.button.AlertButton;
	import net.vdombox.ide.common.view.components.button.VDOMButton;
	import net.vdombox.ide.common.view.skins.windows.AlertSkin;
	import net.vdombox.utils.WindowManager;
	
	import spark.components.Label;
	import spark.components.TextArea;
	import spark.components.Window;

	public class Alert extends Window
	{
		
		[SkinPart( required="true" )]
		public var noButton : VDOMButton;
		
		[SkinPart( required="true" )]
		public var yesButton : VDOMButton; 
		
		[SkinPart( required="true" )]
		public var lbltext : Label;
		
		[Bindable]
		public var text : String;
		
		[Bindable]
		private static var _yesLabel : String = "Yes";
		
		[Bindable]
		private static var _noLabel : String = "No";
		
		[Bindable]
		private static var _cancelLabel : String = "Cancel";
		
		[Bindable]
		private static var _yesImage : Class = null;
		
		[Bindable]
		private static var _noImage : Class = null;
		
		[Bindable]
		private static var _cancelImage : Class = null;
		
		[Bindable]
		private static var _visibleTypeButton : String = "ok";
		
		public static const YES:uint = 0x0004;
		
		public static const NO:uint = 0x0008;
		
		public static const CANCEL:uint = 0x0016;
		
		private static var instance : Alert;
		
		public static function setPatametrs( yesLabel : String = "Yes", noLabel : String = "No", yesImage : Class = null, noImage : Class  = null, cancelImage : Class  = null ) : void
		{
			_yesLabel = yesLabel;
			_noLabel = noLabel;
			_yesImage = yesImage;
			_noImage = noImage;
			_cancelImage = cancelImage;
		}
		
		public function getNoLabel() : String
		{
			return _noLabel;
		}
		
		public function getYesLabel() : String
		{
			return _yesLabel;
		}
		
		public function getCancelLabel() : String
		{
			return _cancelLabel;
		}
		
		public function getNoImage() : Class
		{
			return _noImage;
		}
		
		public function getYesImage() : Class
		{
			return _yesImage;
		}
		
		public function getCancelImage() : Class
		{
			return _cancelImage;
		}
		
		public function getVisibleTypeButton() : String
		{
			return _visibleTypeButton;
		}
		
		
		public static function getInstance() : Alert
		{
			if ( !instance )
				instance = new Alert();
			
			return instance;
		}
		
		public function Alert()
		{
				if ( !instance )
				{
					super();
					
					minWidth = 400;
					minHeight = 160;
					maxHeight = 160;
					maxWidth = 400;
					systemChrome = NativeWindowSystemChrome.NONE;
					transparent = true;
					
					this.setFocus();
				}
				else
				{
					throw new Error( "Singleton and can only be accessed through Soap.anyFunction()" );
				}
			
		}
		
		override public function stylesInitialized():void {
			super.stylesInitialized();
			this.setStyle( "skinClass", AlertSkin );
		}
		
		public static function Show( title : String = "",
							  label:String = "",
						      buttonView : uint = 0x0256, 
							  parent:Object = null, 
							  closeHandler:Function = null): net.vdombox.ide.common.view.components.windows.Alert
		{
			if (!parent) 
				return null;
			
			if(buttonView == AlertButton.OK_No)
				_visibleTypeButton = "okNo";
			else if(buttonView == AlertButton.OK_No_Cancel)
				_visibleTypeButton = "okNoCancel";
			else
				_visibleTypeButton = "ok";
			
			var alert : Alert = Alert.getInstance();
			
			alert.title = title;
			alert.text = label;
			
			if (closeHandler != null)
				alert.addEventListener(PopUpWindowEvent.CLOSE, closeHandler);
			
			alert.addEventListener(FlexEvent.CREATION_COMPLETE, static_creationCompleteHandler);
			alert.addEventListener(PopUpWindowEvent.CLOSE, removeAlert);
			alert.addEventListener(Event.CLOSE, clearAlert);
			alert.addEventListener(KeyboardEvent.KEY_DOWN, keysHandler);
			//PopUpManager.addPopUp( alert, parent as UIComponent, true);
			WindowManager.getInstance().addWindow( alert, parent as UIComponent, true );
			return alert;
		}
		
		private static function keysHandler ( event : KeyboardEvent ) : void
		{
			if ( event.keyCode == Keyboard.ESCAPE )
				removeAlert( null );
		}
		
		
		private static function static_creationCompleteHandler(event:FlexEvent):void
		{
			if (event.target is IFlexDisplayObject && event.eventPhase == EventPhase.AT_TARGET)
			{
				var alert:Alert = Alert(event.target);
				alert.removeEventListener(FlexEvent.CREATION_COMPLETE, static_creationCompleteHandler);
				
				alert.setActualSize(alert.getExplicitOrMeasuredWidth(),
					alert.getExplicitOrMeasuredHeight());
			}
		}
		
		private static function removeAlert(event : PopUpWindowEvent) : void
		{
			var alert : Alert = Alert.getInstance();
			
			WindowManager.getInstance().removeWindow( alert );
			
			clearAlert();
		}
		
		private static function clearAlert(event : Event = null) : void
		{
			var alert : Alert = Alert.getInstance();
			alert.removeEventListener( Event.CLOSE, clearAlert );
			alert.removeEventListener(PopUpWindowEvent.CLOSE, removeAlert);
			alert.removeEventListener(KeyboardEvent.KEY_DOWN, keysHandler);
			
			instance = null;
			
			_yesLabel = "Yes";
			_noLabel = "No";
			_cancelLabel = "Cancel";
			_yesImage = null;
			_noImage = null;
			_cancelImage = null;
		}
		
		
			
		public function keyNoPush(event : KeyboardEvent) : void
		{
			if (event.keyCode == Keyboard.ENTER)
				btnClickHandler(Alert.NO);
		}
		
		public function keyYesPush(event : KeyboardEvent) : void
		{
			if (event.keyCode == Keyboard.ENTER)
				btnClickHandler(Alert.YES);
		}
		
		public function keyCancelPush(event : KeyboardEvent) : void
		{
			if (event.keyCode == Keyboard.ENTER)
				btnClickHandler(Alert.CANCEL);
		}
		
		public function btnClickHandler(type : uint) : void
		{
			var alert : Alert = Alert.getInstance();
			alert.visible = false;
			
			var popUpWindowEvent:PopUpWindowEvent = new PopUpWindowEvent(PopUpWindowEvent.CLOSE);
			popUpWindowEvent.detail = type;
			alert.dispatchEvent(popUpWindowEvent);
		}

	}
}