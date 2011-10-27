package net.vdombox.ide.core.view.components
{
	import flash.display.NativeWindowSystemChrome;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayList;
	import mx.utils.ObjectUtil;
	
	import net.vdombox.ide.core.events.IconChooserEvent;
	import net.vdombox.ide.core.model.vo.GalleryItemVO;
	import net.vdombox.ide.core.view.skins.ApplicationsIconsChoosWindowSkin;
	
	import spark.components.Button;
	import spark.components.List;
	import spark.components.Window;
	

	public class ApplicationsIconsChoosWindow extends Window
	{
		[SkinPart( required="true" )]
		public var iconsList : List;
		
		[SkinPart( required="true" )]
		public var btnOK : Button;
		
		public function ApplicationsIconsChoosWindow()
		{
			width = 550;
			height = 340;
			minWidth = 550;
			minHeight = 340;
			maxWidth = 550;
			maxHeight = 340;
			systemChrome = NativeWindowSystemChrome.NONE;
			transparent = true;
		}
		
		public function get imageSource():ByteArray
		{
			var galleryItemVO : GalleryItemVO = iconsList.selectedItem as GalleryItemVO;
			
			return ObjectUtil.copy( galleryItemVO.content ) as ByteArray;
		}
		override public function stylesInitialized():void {
			super.stylesInitialized();
			this.setStyle( "skinClass", ApplicationsIconsChoosWindowSkin );
		}

		public function selectIcon() : void
		{
			dispatchEvent( new IconChooserEvent( IconChooserEvent.SELECT_ICON ) );
			close();
		}
		
		public function closeWindow() : void
		{
			dispatchEvent( new IconChooserEvent( IconChooserEvent.CLOSE_ICON_LIST ) );
		}
		
		public function set dataProvider ( value : Array ) : void
		{
			iconsList.dataProvider = new ArrayList( value );
		}
	}
}