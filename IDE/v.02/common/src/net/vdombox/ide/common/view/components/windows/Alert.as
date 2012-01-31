package net.vdombox.ide.common.view.components.windows
{
	import flash.desktop.Icon;
	import flash.display.Sprite;
	import flash.events.EventPhase;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.binding.utils.BindingUtils;
	import mx.controls.Button;
	import mx.core.FlexGlobals;
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.managers.ISystemManager;
	import mx.managers.PopUpManager;
	
	import net.vdombox.components.VDOMButton;
	import net.vdombox.ide.common.view.skins.windows.AlertSkin;
	
	import spark.components.Label;
	import spark.components.TitleWindow;
	import net.vdombox.ide.common.view.AlertButton;

	public class Alert extends TitleWindow
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
		public static var yesLabel : String = "Yes";
		
		[Bindable]
		public static var noLabel : String = "No";
		
		[Bindable]
		private static var _visibleNoButton : Boolean = false;
		
		public static const YES:uint = 0x0004;
		
		public static const NO:uint = 0x0008;
		
		private static var instance : Alert;
		
		public function getNoLabel() : String
		{
			return noLabel;
		}
		
		public function getYesLabel() : String
		{
			return yesLabel;
		}
		
		public function getVisibleNoButton() : Boolean
		{
			return _visibleNoButton;
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
		
		public static function Show( label:String = "",
						      buttonView : uint = 0x0256, 
							  parent:Object = null, 
							  closeHandler:Function = null): net.vdombox.ide.common.view.components.windows.Alert
		{
			if (!parent) 
				return null;
			
			if (buttonView == AlertButton.OK_No)
				_visibleNoButton = true;
			
			var alert : Alert = Alert.getInstance();
			
			
			alert.text = label;
			
			if (closeHandler != null)
				alert.addEventListener(CloseEvent.CLOSE, closeHandler);
			
			alert.addEventListener(FlexEvent.CREATION_COMPLETE, static_creationCompleteHandler);
			alert.addEventListener(CloseEvent.CLOSE, removeAlert);
			alert.addEventListener(KeyboardEvent.KEY_DOWN, keysHandler);
			PopUpManager.addPopUp( alert, parent as UIComponent, true);
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
				PopUpManager.centerPopUp(IFlexDisplayObject(alert));
			}
		}
		
		private static function removeAlert(event : CloseEvent) : void
		{
			var alert : Alert = Alert.getInstance();
			mx.managers.PopUpManager.removePopUp(alert);
			instance = null;
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
		
		public function btnClickHandler(type : uint) : void
		{
			var alert : Alert = Alert.getInstance();
			alert.visible = false;
			
			var closeEvent:CloseEvent = new CloseEvent(CloseEvent.CLOSE);
			closeEvent.detail = type;
			alert.dispatchEvent(closeEvent);
		}

	}
}