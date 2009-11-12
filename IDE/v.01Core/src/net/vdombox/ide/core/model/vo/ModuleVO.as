package net.vdombox.ide.core.model.vo
{
	import net.vdombox.ide.common.VIModule;

	public class ModuleVO
	{
		public function ModuleVO( category : String, path : String )
		{
			_category = category;
			_path = path;
		}

		private var _body : VIModule;

		private var _category : String;

		private var _path : String;

		public function get body() : VIModule
		{
			return _body;
		}

		public function get category() : String
		{
			return _category;
		}

		public function get moduleID() : String
		{
			if ( _body )
				return _body.moduleID;
			else
				return "";
		}

		public function get path() : String
		{
			return _path;
		}

		public function setBody( value : VIModule ) : void
		{
			_body = value;
		}
	}
}