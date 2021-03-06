package net.vdombox.ide.common.view.components.windows.resourceBrowserWindow
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.display.NativeWindowSystemChrome;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.net.FileReference;
	import flash.ui.Keyboard;

	import mx.binding.utils.BindingUtils;
	import mx.controls.Image;
	import mx.events.FlexEvent;

	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.common.view.skins.windows.ResourcePreviewWindowSkin;

	import spark.components.Label;
	import spark.components.TextInput;
	import spark.components.Window;

	public class ResourcePreviewWindow extends Window
	{

		[SkinPart( required = "true" )]
		public var resourceImage : Image;

		[SkinPart( required = "true" )]
		public var loadingImage : SpinningSmoothImage;

		[SkinPart( required = "true" )]
		public var resourceName : Label;

		[SkinPart( required = "true" )]
		public var resourceId : TextInput;

		[SkinPart( required = "true" )]
		public var resourceType : Label;

		[SkinPart( required = "true" )]
		public var resourceDimentions : Label;

		private var _resourceVO : ResourceVO;

		public function ResourcePreviewWindow()
		{
			super();

			systemChrome = NativeWindowSystemChrome.NONE;
			transparent = true;

			width = 700;
			height = 500;

			minWidth = 600;
			minHeight = 450;

			maximize();
			addHandlers();
		}

		public function set resourceVO( resourceVO : ResourceVO ) : void
		{
			_resourceVO = resourceVO;
		}

		override public function validateProperties() : void
		{
			super.validateProperties();

			if ( _resourceVO )
			{
				resourceName.text = _resourceVO.name;
				resourceName.toolTip = _resourceVO.name;

				resourceId.text = _resourceVO.id;
				resourceId.toolTip = _resourceVO.id;

				resourceType.text = _resourceVO.type.toUpperCase();
			}

		}

		override public function validateDisplayList() : void
		{
			setFocus();

			super.validateDisplayList();
		}

		override public function stylesInitialized() : void
		{
			super.stylesInitialized();
			this.setStyle( "skinClass", ResourcePreviewWindowSkin );
		}

		private function addHandlers() : void
		{
			addEventListener( KeyboardEvent.KEY_DOWN, onKeyBtnDown, false, 0, true );

			addEventListener( Event.CLOSE, closeHandler, false, 0, true );

			addEventListener( FlexEvent.CREATION_COMPLETE, createComleatHandler, false, 0, true );
		}

		private function createComleatHandler( event : FlexEvent ) : void
		{
			loadingImage.rotateImage();
		}


		private function closeHandler( event : Event ) : void
		{
			loadingImage.stopRotateImage();

			removeHandlers();
		}

		private function removeHandlers() : void
		{
			removeEventListener( KeyboardEvent.KEY_DOWN, onKeyBtnDown );

			removeEventListener( Event.CLOSE, closeHandler );

			removeEventListener( FlexEvent.CREATION_COMPLETE, createComleatHandler );
		}



		private function onKeyBtnDown( event : KeyboardEvent ) : void
		{
			if ( event.charCode == Keyboard.ESCAPE )
			{
				close();

				event.stopImmediatePropagation();
			}
		}

		public function setDimentions( _width : Number, _height : Number, _isViewable : Boolean = true ) : void
		{
			resourceDimentions.text = _isViewable ? _width.toString() + "x" + _height.toString() + " px" : "";
		}

		public function copyResourceID() : void
		{
			Clipboard.generalClipboard.clear();
			Clipboard.generalClipboard.setData( ClipboardFormats.TEXT_FORMAT, resourceId.text );
		}

		public function getResourceButton() : void
		{
			if ( !_resourceVO )
			{

				return;
			}


			if ( !_resourceVO.data )
			{
				BindingUtils.bindSetter( dataChanged, _resourceVO, "data", true, true );
					//dispatchEvent( new WorkAreaEvent ( WorkAreaEvent.LOAD_RESOURCE ) );
			}
			else
				saveResource( _resourceVO );
		}

		private function dataChanged( value : Object ) : void
		{
			if ( _resourceVO.data )
				saveResource( _resourceVO );
		}

		private function saveResource( value : ResourceVO ) : void
		{
			var fileUpload : FileReference = new FileReference();
			fileUpload.save( value.data, value.name );
		}

	}
}
