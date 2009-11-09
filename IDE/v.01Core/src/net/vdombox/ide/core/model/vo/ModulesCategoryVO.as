package net.vdombox.ide.core.model.vo
{
	import mx.utils.ObjectUtil;

	public class ModulesCategoryVO
	{
		public function ModulesCategoryVO( name : String, localizedName : String, modules : Array )
		{
			 _name = name;
			 _localizedName = localizedName;
			 _modules = modules;
		}
		
		private var _name : String;
		
		private var _localizedName : String;
		
		private var _modules : Array;
		
		public function get name() : String
		{
			return _name;
		}
		
		public function get localizedName() : String
		{
			return _localizedName;
		}
		
		public function get modules() : Array
		{
			return ObjectUtil.copy( _modules ) as Array;
		}
	}
}