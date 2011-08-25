package net.vdombox.ide.modules.wysiwyg.view.components.windows.resourceBrowserWindow
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.NativeWindowSystemChrome;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.controls.Image;
	import mx.core.FlexSprite;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.wysiwyg.view.skins.ResourcePreviewWindowSkin;
	import net.vdombox.utils.WindowManager;
	
	import spark.components.Label;
	import spark.components.TitleWindow;
	import spark.components.Window;
	
	public class ResourcePreviewWindow extends Window
	{
		public static var CLOSE 							: String = "closeWindow";
		
		[SkinPart( required="true" )]
		public var resourceImage : Image;
		
		[SkinPart( required="true" )]
		public var loadingImage : SpinningSmoothImage;
		
		[SkinPart( required="true" )]
		public var resourceName : Label;
		
		[SkinPart( required="true" )]
		public var resourceId : Label;
		
		[SkinPart( required="true" )]
		public var resourceType : Label;
		
		[SkinPart( required="true" )]
		public var resourceDimentions : Label;
		
		private var _resourceVO : ResourceVO;
		
		public function ResourcePreviewWindow()
		{
			super();
			
			systemChrome	= NativeWindowSystemChrome.NONE;
			transparent 	= true;
			
			width = 700;
			height = 500;
			
			minWidth = 600;
			minHeight = 450;
			
			maximize();
			addHandlers();	
		}
		
		public function set resourceVO( resourceVO:ResourceVO ):void
		{
			_resourceVO = resourceVO;
		}
		
		override public function validateProperties():void
		{
			super.validateProperties();
			
			if(_resourceVO)
			{
				resourceName.text = _resourceVO.name;
				resourceName.toolTip = _resourceVO.name; 
				
				resourceId.text = _resourceVO.id;
				resourceId.toolTip = _resourceVO.id;
				
				resourceType.text =  _resourceVO.type.toUpperCase();
			}
			
		}
		
		override public function validateDisplayList():void
		{
			setFocus();
			
			super.validateDisplayList();
		}
		
		override public function stylesInitialized():void 
		{
			super.stylesInitialized();
			this.setStyle( "skinClass", ResourcePreviewWindowSkin );
		}
		
		private function addHandlers():void
		{
			addEventListener( KeyboardEvent.KEY_DOWN, onKeyBtnDown, false, 0, true );
			addEventListener(CLOSE, closeHandler, false, 0, true);
			addEventListener(FlexEvent.CREATION_COMPLETE, createComleatHandler, false, 0, true);
			
		}
		
		private function createComleatHandler(event : FlexEvent):void
		{
			loadingImage.rotateImage();
		}
		
		
		private function closeHandler( event : CloseEvent):void
		{
			loadingImage.stopRotateImage();
			
			removeHandlers();
			
			WindowManager.getInstance().removeWindow(this);
		}
		
		private function removeHandlers():void
		{
			removeEventListener( KeyboardEvent.KEY_DOWN, onKeyBtnDown );
			removeEventListener(CLOSE, closeHandler);
			removeEventListener(FlexEvent.CREATION_COMPLETE, createComleatHandler);
		}
		
		
		
		private function onKeyBtnDown( event: KeyboardEvent = null ) : void
		{
			if ( event != null )
				if ( event.charCode != Keyboard.ESCAPE )
					return;
			//
			event.stopImmediatePropagation();
			dispatchEvent(new CloseEvent(CLOSE));
		}	
			
		public function closePreviewWindow():void
		{
			dispatchEvent(new CloseEvent(CLOSE));
			
		}
		
		
		
		public function setDimentions (_width:Number, _height:Number, _isViewable:Boolean = true) : void 
		{
			resourceDimentions.text = _isViewable ? _width.toString() +"x"+ _height.toString() +" px" : "";
		}
		
		public function copyResourceID() : void {
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, resourceId.text);
		}
		
	}
}