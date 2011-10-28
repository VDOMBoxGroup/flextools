//------------------------------------------------------------------------------
//
//   Copyright 2011 
//   VDOMBOX Resaerch  
//   All rights reserved. 
//
//------------------------------------------------------------------------------

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
		
		[SkinPart( required="true" )]
		public var canselBt : Button;
		
		[SkinPart( required="true" )]
		public var addImageBt : Button;
		
		[SkinPart( required="true" )]
		public var selectBt : Button;
		
		[SkinPart( required="true" )]
		public var iconsList : List;
		
		
		
		public function set dataProvider ( value : Array ) : void
		{
			iconsList.dataProvider = new ArrayList( value );
		}
		
		public function get imageSource():ByteArray
		{
			var galleryItemVO : GalleryItemVO = iconsList.selectedItem as GalleryItemVO;
			
			return ObjectUtil.copy( galleryItemVO.content ) as ByteArray;
		}

		public function selectIcon() : void
		{
			if (iconsList.selectedItem)
				dispatchEvent( new IconChooserEvent( IconChooserEvent.SELECT_ICON ) );
			close();
		}
		override public function stylesInitialized():void {
			super.stylesInitialized();
			this.setStyle( "skinClass", ApplicationsIconsChoosWindowSkin );
		}
	}
}