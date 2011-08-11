package net.vdombox.ide.modules.wysiwyg.view.components.windows
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import net.vdombox.ide.modules.wysiwyg.view.skins.SpinnerPopupSkin;
	
	import spark.components.TitleWindow;
	
	
	public class SpinnerPopup extends TitleWindow
	{
		public function SpinnerPopup()
		{
			super();
			
			addHandlers();
		}
	
		override public function stylesInitialized():void 
		{
			super.stylesInitialized();
			this.setStyle( "skinClass",  SpinnerPopupSkin);
		}
		
		override public function validateDisplayList():void
		{
			setFocus();
			
			super.validateDisplayList();
		}
		
		private function addHandlers():void
		{
			addEventListener( KeyboardEvent.KEY_DOWN, onKeyBtnDown, false, 0, true );
			addEventListener(CloseEvent.CLOSE, closeHandler, false, 0, true);
			addEventListener(FlexEvent.CREATION_COMPLETE, createComleatHandler, false, 0, true);
			
		}
		
		private function createComleatHandler(event : FlexEvent):void
		{
			PopUpManager.centerPopUp( this );
		}
		
		private function closeHandler( event : CloseEvent):void
		{
			trace ("[SpinnerPopup] closeHandler");
			removeHandlers();
			PopUpManager.removePopUp(this);
		}
		
		private function removeHandlers():void
		{
			removeEventListener( KeyboardEvent.KEY_DOWN, onKeyBtnDown );
			removeEventListener(CloseEvent.CLOSE, closeHandler);
			removeEventListener(FlexEvent.CREATION_COMPLETE, createComleatHandler);
		}
		
		
		
		private function onKeyBtnDown( event: KeyboardEvent = null ) : void
		{
			if ( event != null )
				if ( event.charCode != Keyboard.ESCAPE )
					return;
			//
			event.stopImmediatePropagation();
			dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
		}	
	}
}