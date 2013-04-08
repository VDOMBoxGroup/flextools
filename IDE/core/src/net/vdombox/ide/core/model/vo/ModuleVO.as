package net.vdombox.ide.core.model.vo
{
	import net.vdombox.ide.common.VIModule;

	/**
	 * @flowerModelElementId _DDP4IEomEeC-JfVEe_-0Aw
	 */
	public class ModuleVO
	{
		private var _module : VIModule;

		private var _path : String;

		public function ModuleVO( path : String )
		{
			_path = path;
		}

		public function get module() : VIModule
		{
			return _module;
		}


		public function get moduleID() : String
		{
			if ( _module )
				return _module.moduleID;
			else
				return "";
		}

		public function get moduleName() : String
		{
			if ( _module )
				return _module.moduleName;
			else
				return "";
		}

		public function get path() : String
		{
			return _path;
		}

		public function setModule( value : VIModule ) : void
		{
			_module = value;
		}
	}
}