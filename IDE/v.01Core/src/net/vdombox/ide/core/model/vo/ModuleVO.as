package net.vdombox.ide.core.model.vo
{
	import net.vdombox.ide.common.VIModule;

	public class ModuleVO
	{
		public function ModuleVO( name : String, category : String)
		{
			_name = name;
			_category = category;
		}

		private var _body : VIModule;

		private var _category : String;

		private var _name : String;

		public function get body() : VIModule
		{
			return _body;
		}

		public function set body( value : VIModule ) : void
		{
			_body = value;
		}

		public function get category() : String
		{
			return _category;
		}

		public function get name() : String
		{
			return _name;
		}
	}
}