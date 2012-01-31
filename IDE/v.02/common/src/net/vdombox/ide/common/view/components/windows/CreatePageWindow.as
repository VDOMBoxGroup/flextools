package net.vdombox.ide.common.view.components.windows
{
	
	import flash.display.NativeWindowSystemChrome;
	
	import mx.collections.ArrayList;
	
	import net.vdombox.ide.common.view.skins.windows.CreatePageWindowSkin;
	import net.vdombox.ide.common.model.vo.TypeVO;
	
	import spark.components.Button;
	import spark.components.List;
	import spark.components.Window;

	public class CreatePageWindow extends Window
	{
		[SkinPart( required="true" )]
		public var pageTypeList : List;
		
		[Bindable]
		public var _pagesDataProvider : ArrayList;
		
		public function set pagesDataProvider( value : Array ) : void
		{
			_pagesDataProvider = new ArrayList( value );
		}
		
		
		public function get selectedPageType() : TypeVO
		{
			return pageTypeList.selectedItem as TypeVO;
		}
		
		public function CreatePageWindow()
		{
			super();
			
			systemChrome	= NativeWindowSystemChrome.NONE;
			transparent 	= true;
			
			width = 400;
			height = 432;
			
			minWidth = 400;
			minHeight = 432;
			
			this.setFocus();
		}
		
		override public function stylesInitialized():void {
			super.stylesInitialized();
			this.setStyle( "skinClass", CreatePageWindowSkin );
		}
	}
}