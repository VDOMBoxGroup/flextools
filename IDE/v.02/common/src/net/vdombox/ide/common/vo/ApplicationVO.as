package net.vdombox.ide.common.vo
{	
	/**
	 * The ApplicationVO is Visual Object of Application.
	 * The application consists of:
	 *  <pre>
	 *  - Information (),
	 *  - Top Lavel Containers (PageVO),
	 *  - Events (ApplicationEventsVO),
	 *  - Server Actions (ServerActionVO), 
	 *  - Resources (ResourcesVO),
	 *  - Databases (?),
	 *  - Languages (?),
	 *  - Libraries (LibraryVO),
	 *  - Structure of Top Lavel Containers (StructureObjectVO),
	 *  - E2vdom (?). 
	 *  </pre>
	 */
	[Bindable]
	public class ApplicationVO
	{
		public function ApplicationVO( id : String )
		{	
			_id = id;
		}

		private var _id 				: String
		private var _name				: String
		private var _description 		: String
		private var _serverVersion 		: String
		private var _iconID 			: String
		private var _indexPageID 		: String
		private var _numberOfPages 		: int
		private var _numberOfObjects 	: int
		private var _scriptingLanguage	: String

		public function get id() : String
		{
			return _id;
		}
		
		public function get name() : String
		{
			return _name;
		}
		
		public function set name( value : String ) : void
		{
			
		}
		
		public function get description() : String
		{
			return _description;
		}
		
		public function set description( value : String ) : void
		{
			
		}
		
		public function get serverVersion() : String
		{
			return _serverVersion;
		}

		public function get iconID() : String
		{
			return _iconID;
		}
		
		public function set iconID( value : String ) : void
		{
			
		}
		
		public function get indexPageID() : String
		{
			return _indexPageID;
		}

		public function set indexPageID( value : String ) : void
		{
			
		}
		
		public function get numberOfPages() : int
		{
			return _numberOfPages;
		}

		public function set numberOfPages( value : int ) : void
		{
			
		}
		
		public function get numberOfObjects() : int
		{
			return _numberOfObjects;
		}

		public function set numberOfObjects( value : int ) : void
		{
			
		}
		
		public function get scriptingLanguage() : String
		{
			return _scriptingLanguage;
		}
		
		public function set scriptingLanguage( value : String ) : void
		{
			
		}
		
		public function setInformation( information : XML ) : void
		{
			_name				= information.Name[ 0 ];
			name 				= information.Name[ 0 ];
			_description 		= information.Description[ 0 ];
			description 		= information.Description[ 0 ];
			_serverVersion 		= information.ServerVersion[ 0 ];
			_iconID 			= information.Icon[ 0 ];
			iconID				= information.Icon[ 0 ];
			_indexPageID 		= information.Index[ 0 ];
			indexPageID 		= information.Index[ 0 ];
			_numberOfPages 		= information.Numberofpages[ 0 ];
			numberOfPages		= information.Numberofpages[ 0 ];
			_numberOfObjects 	= information.Numberofobjects[ 0 ];
			numberOfObjects 	= information.Numberofobjects[ 0 ];
			_scriptingLanguage	= information.ScriptingLanguage[ 0 ];
			scriptingLanguage 	= information.ScriptingLanguage[ 0 ];
		}
	}
}