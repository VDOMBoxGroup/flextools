package net.vdombox.ide.model.vo
{

	public class ApplicationVO
	{
		public function ApplicationVO( application : XML )
		{
			var dummy : * = ""; // FIXME remove dummy
		}

		private var _id : String
		private var _name : String
		private var _description : String
		private var _serverVersion : String
		private var _iconID : String
		private var _indexPageID : String
		private var _numberOfPage : int
		private var _numberOfObjects : int
		private var _scriptingLanguage : String

		public function get id() : String
		{
			return _id;
		}

		public function get name() : String
		{
			return _name;
		}

		public function get description() : String
		{
			return _description;
		}

		public function get serverVersion() : String
		{
			return _serverVersion;
		}

		public function get iconID() : String
		{
			return _iconID;
		}

		public function get indexPageID() : String
		{
			return _indexPageID;
		}

		public function get numberOfPage() : int
		{
			return _numberOfPage;
		}

		public function get numberOfObjects() : int
		{
			return _numberOfObjects;
		}

		public function get scriptingLanguage() : String
		{
			return _scriptingLanguage;
		}
	}
}