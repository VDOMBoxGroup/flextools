package net.vdombox.ide.common.view.components.button
{
	import net.vdombox.ide.common.view.skins.button.ToolsetButtonSkin;
	
	import spark.components.ToggleButton;
	
	public class ToolsetButton extends ToggleButton
	{
		public function ToolsetButton()
		{
			super();
			
			setStyle( "skinClass", net.vdombox.ide.common.view.skins.button.ToolsetButtonSkin );
		}
		
		[Bindable]
		public var icon : Object;
	}
}