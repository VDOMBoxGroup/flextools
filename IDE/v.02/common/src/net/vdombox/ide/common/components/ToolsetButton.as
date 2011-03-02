package net.vdombox.ide.common.components
{
	import net.vdombox.ide.common.skins.ToolsetButtonSkin;
	
	import spark.components.ToggleButton;
	
	public class ToolsetButton extends ToggleButton
	{
		public function ToolsetButton()
		{
			super();
			
			setStyle( "skinClass", net.vdombox.ide.common.skins.ToolsetButtonSkin );
		}
		
		[Bindable]
		public var icon : Object;
	}
}