package net.vdombox.ide.common.view.components.windows
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.core.Window;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import net.vdombox.ide.common.view.components.windows.resourceBrowserWindow.SpinningSmoothImage;
	import net.vdombox.ide.common.view.skins.windows.SpinnerPopupSkin;
	
	import spark.components.Label;
	import spark.components.TitleWindow;
	
	
	public class SpinnerPopup extends TitleWindow
	{
		[SkinPart( required="true" )]
		public var spinner : SpinningSmoothImage;
		
		[SkinPart( required="true" )]
		public var spinnerLabel : Label;
		
		private var spinnerText : String = "";
		private var removePopup	: Boolean;
		
		
		public function SpinnerPopup(txt : String = null)
		{
			super();
			
			spinnerText = txt;
			
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
			addEventListener(FlexEvent.CREATION_COMPLETE, createComleatHandler, false, 0, true);
		}
		
		private function createComleatHandler(event : FlexEvent):void
		{
			PopUpManager.centerPopUp( this );
			
			spinnerLabel.text = spinnerText;
			spinner.rotateImage();
		}
		
	
		
		public function close():void
		{
			spinner.stopRotateImage();
			
			removeHandlers();
			
			removePopup = true;
			invalidateDisplayList();
		}
		
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (removePopup)
			{
				removePopup = false;
				PopUpManager.removePopUp(this);
			}
		}
		
		private function removeHandlers():void
		{
			removeEventListener( KeyboardEvent.KEY_DOWN, onKeyBtnDown );

			removeEventListener(FlexEvent.CREATION_COMPLETE, createComleatHandler);
		}
		
		
		
		private function onKeyBtnDown( event: KeyboardEvent = null ) : void
		{
			if ( event != null )
				if ( event.charCode != Keyboard.ESCAPE )
					return;
			//
			event.stopImmediatePropagation();
			close();
		}	
	}
}