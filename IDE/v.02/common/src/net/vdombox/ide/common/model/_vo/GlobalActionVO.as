package net.vdombox.ide.common.model._vo
{
	public class GlobalActionVO extends LibraryVO
	{
		private var _scriptsGroupName : String;
		
		public function GlobalActionVO(name:String, scriptsGroupName : String, applicationVO:ApplicationVO)
		{
			super(name, applicationVO);
			_scriptsGroupName = scriptsGroupName;
		}
		
		public function get scriptsGroupName():String
		{
			return _scriptsGroupName;
		}

	}
}