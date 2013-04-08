package net.vdombox.ide.common.view.components.tabnavigator
{
	import net.vdombox.ide.common.view.skins.button.TabBarCloseButtonSkin;

	import spark.components.Button;

	public class TabBarCloseButton extends Button
	{
		public function TabBarCloseButton()
		{
			super();
		}

		override public function stylesInitialized() : void
		{

			super.stylesInitialized();
			this.setStyle( "skinClass", TabBarCloseButtonSkin );

		}

		override public function set visible( value : Boolean ) : void
		{
			width = value ? skin.minWidth : 1;

			super.visible = value;
		}
	}
}
