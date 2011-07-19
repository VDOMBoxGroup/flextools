package net.vdombox.ide.modules.wysiwyg.view.components.windows
{
	import spark.components.TitleWindow;

	public class MultilineResourceSelectorWindow
	{
		
		import net.vdombox.ide.modules.wysiwyg.view.skins.MultilineResourceSelectorWindowSkin;
		
		public function MultilineResourceSelectorWindow() extends TitleWindow
		{
			super();
		}
		
		override public function stylesInitialized():void 
		{
			super.stylesInitialized();
			this.setStyle( "skinClass", MultilineResourceSelectorWindowSkin );
		}
		
	}
}