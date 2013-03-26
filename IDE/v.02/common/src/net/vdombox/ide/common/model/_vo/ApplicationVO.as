//------------------------------------------------------------------------------
//
//   Copyright 2011 
//   VDOMBOX Resaerch  
//   All rights reserved. 
//
//------------------------------------------------------------------------------

package net.vdombox.ide.common.model._vo
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

		private var _active				: String;
		private var _description 		: String;
		private var _iconID 			: String;
		private var _id 				: String;
		private var _indexPageID 		: String;
		private var _name				: String;
		private var _numberOfObjects 	: int;
		private var _numberOfPages 		: int;
		private var _scriptingLanguage	: String;
		private var _serverVersion 		: String;
		private var _version 			: String;
		private var _hosts				: Array;

		public function get hosts():Array
		{
			return _hosts;
		}

		public function set hosts(value:Array):void
		{
			_hosts = value;
		}

		public function get active():String
		{
			return _active;
		}

		public function set active(value:String):void
		{
			_active = value;
		}
		
		public function get description() : String
		{
			return _description;
		}

		public function get iconID() : String
		{
			return _iconID;
		}

		public function get id() : String
		{
			return _id;
		}
		
		public function get indexPageID() : String
		{
			return _indexPageID;
		}
		
		public function set indexPageID(index:String):void
		{
			_indexPageID = index;
		}
		
		public function get name() : String
		{
			return _name;
		}

		public function get numberOfObjects() : int
		{
			return _numberOfObjects;
		}

		public function get numberOfPages() : int
		{
			return _numberOfPages;
		}

		public function get scriptingLanguage() : String
		{
			return _scriptingLanguage;
		}
		
		public function get serverVersion() : String
		{
			return _serverVersion;
		}
		
		public function get version() : String
		{
			return _version;
		}
		
		public function setInformation( information : XML ) : void
		{
			_name				= information.Name[ 0 ];
			_description 		= information.Description[ 0 ];
			_serverVersion 		= information.ServerVersion[ 0 ];
			_iconID 			= information.Icon[ 0 ];
			_indexPageID 		= information.Index[ 0 ];
			_numberOfPages 		= information.Numberofpages[ 0 ];
			_numberOfObjects 	= information.Numberofobjects[ 0 ];
			_scriptingLanguage	= information.ScriptingLanguage[ 0 ];
			_active				= information.Active[ 0 ];
			_version			= information.Version[ 0 ];
			
			hosts = new Array();
			
			for each( var xml : XML in information.Hosts..Host )
			{
				hosts.push( xml.toString() );
			}
		}
	}
}