package net.vdombox.ide.core.model.vo
{	
	public class ApplicationVO
	{
		public function ApplicationVO( application : XML )
		{	
			if( !application )
				return;
			
			var information : XML = application.Information[ 0 ];
			
			if( !information )
				return;
			
			_id = information.Id[ 0 ];
			_name = information.Name[ 0 ];
			_description = information.Description[ 0 ];
			_serverVersion = information.ServerVersion[ 0 ];
			_iconID = information.Icon[ 0 ];
			_indexPageID = information.Index[ 0 ];
			_numberOfPages = information.Numberofpages[ 0 ];
			_numberOfObjects = information.Numberofobjects[ 0 ];
			_scriptingLanguage = information.ScriptingLanguage[ 0 ];
		}

		private var _id : String
		private var _name : String
		private var _description : String
		private var _serverVersion : String
		private var _iconID : String
		private var _indexPageID : String
		private var _numberOfPages : int
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

		public function get numberOfPages() : int
		{
			return _numberOfPages;
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