package net.vdombox.ide.modules.wysiwyg.view.components.windows.resourceBrowserWindow
{
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.controls.Image;
	import mx.managers.PopUpManager;
	
	import net.vdombox.ide.modules.wysiwyg.view.skins.ResourcePreviewWindowSkin;
	
	import spark.components.Label;
	import spark.components.TitleWindow;
	
	public class ResourcePreviewWindow extends TitleWindow
	{
		[SkinPart( required="true" )]
		public var resourceImage : Image;
		
		[SkinPart( required="true" )]
		public var loadingImage : Image;
		
		[SkinPart( required="true" )]
		public var resourceName : Label;
		
		[SkinPart( required="true" )]
		public var resourceId : Label;
		
		[SkinPart( required="true" )]
		public var resourceType : Label;
		
		[SkinPart( required="true" )]
		public var resourceDimentions : Label;
		
		public function ResourcePreviewWindow()
		{
			super();
		}
		
		override public function stylesInitialized():void {
			super.stylesInitialized();
			this.setStyle( "skinClass", ResourcePreviewWindowSkin );
		}
		
		
		public function closePreviewWindow():void
		{
			this.dispatchEvent(new Event(Event.CLOSE));
		}
		
		public function setType (_type:String) : void 
		{
			resourceType.text = _type.toUpperCase();
		}
		
		public function setId (_id:String) : void 
		{
			resourceId.text = _id;
			resourceId.toolTip = resourceId.text
		}
		
		public function setName(_name:String):void
		{
			resourceName.text = _name;
			resourceName.toolTip = resourceName.text;
		}
		
		public function setDimentions (_width:Number, _height:Number) : void 
		{
			resourceDimentions.text = _width.toString() +"x"+ _height.toString() +" px";
		}
		
		public function copyResourceID() : void {
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, resourceId.text);
		}
		
	}
}