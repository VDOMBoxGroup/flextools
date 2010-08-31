package net.vdombox.ide.common.components
{
	import net.vdombox.ide.common.skins.WorkAreaButtonSkin;
	
	import spark.components.Button;
	
	public class WorkAreaButton extends Button
	{
		public function WorkAreaButton()
		{
			super();
			
			setStyle( "skinClass", WorkAreaButtonSkin );
		}
		
		[Bindable]
		public var icon : Object;
		
		private var _highlighted : Boolean;
		
		public function get highlighted() : Boolean
		{
			return _highlighted;
		}
		
		public function set highlighted( value : Boolean ) : void
		{
			_highlighted = value;
			
			invalidateSkinState();
		}
		
		override protected function getCurrentSkinState():String
		{
			if (!_highlighted)
				return super.getCurrentSkinState();
			else
				return super.getCurrentSkinState() + "AndHighlighted";
		}
	}
}