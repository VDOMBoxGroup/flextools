package net.vdombox.ide.core.model.vo
{
	import mx.utils.ObjectUtil;

	public class ModulesCategoryVO
	{
		public function ModulesCategoryVO( name : String, localizedName : String )
		{
			 _name = name;
			 _localizedName = localizedName;
		}
		
		private var _name : String;
		
		private var _localizedName : String;
		
		public function get name() : String
		{
			return _name;
		}
		
		public function get localizedName() : String
		{
			return _localizedName;
		}
	}
}