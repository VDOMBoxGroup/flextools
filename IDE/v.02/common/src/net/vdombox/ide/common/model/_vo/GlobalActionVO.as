package net.vdombox.ide.common.model._vo
{
	import net.vdombox.ide.common.view.components.VDOMImage;

	public class GlobalActionVO extends LibraryVO
	{
		private var _scriptsGroupName : String;
		private var _displayName : String;
		
		public function GlobalActionVO(name:String, displayName : String, scriptsGroupName : String, applicationVO:ApplicationVO)
		{
			super(name, applicationVO);
			_displayName = displayName;
			_scriptsGroupName = scriptsGroupName;
		}
		
		public function get displayName():String
		{
			return _displayName;
		}
		
		public function get scriptsGroupName():String
		{
			return _scriptsGroupName;
		}
		
		public override function get icon() : Class
		{
			return VDOMImage.GlobalActionIcon;
		}

	}
}