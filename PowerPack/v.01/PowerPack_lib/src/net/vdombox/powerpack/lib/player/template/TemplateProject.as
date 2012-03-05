package net.vdombox.powerpack.lib.player.template
{
	import flash.events.EventDispatcher;
	
	import mx.utils.UIDUtil;
	
	import net.vdombox.powerpack.lib.extendedapi.utils.Utils;
	import net.vdombox.powerpack.lib.player.gen.structs.GraphStruct;
	
	public class TemplateProject extends EventDispatcher
	{
		public static const DEFAULT_NAME			: String = 'installer';
		public static const DEFAULT_INSTALLER_ID	: String = 'installer';
		
		[Bindable]
		public var key : String;
		
		[Bindable]
		public var initialGraphName : String = "";
		
		public var id : String; // GUID
		
		public function TemplateProject()
		{
			id = UIDUtil.createUID();
		}
		
		//
		//	modified
		//
		private var _modified : Boolean;
		
		public function set modified( value : Boolean ) : void
		{
			if ( _modified != value )
			{
				_modified = value;
			}
		}
		
		[Bindable]
		public function get modified() : Boolean
		{
			return _modified;
		}
		
		//
		//	ID
		//
		private var _installerId : String;
		
		public function set installerId ( value : String ) : void
		{
			if (!value)
				value = DEFAULT_INSTALLER_ID;
			
			if ( _installerId != value )
			{
				modified = true;
				_installerId = value;
			}
		}
		
		[Bindable]
		public function get installerId () : String
		{
			return Utils.getStringOrDefault( _installerId, DEFAULT_INSTALLER_ID );
		}
		
		//
		//	name
		//
		private var _name : String;
		
		public function set name( value : String ) : void
		{
			if (!value)
				value = DEFAULT_NAME;
			
			if ( _name != value )
			{
				modified = true;
				_name = value;
			}
		}
		
		[Bindable("nameChanged")]
		public function get name() : String
		{
			return Utils.getStringOrDefault( _name, DEFAULT_NAME );
		}
		
		//
		//	description
		//
		private var _description : String;
		
		public function set description( value : String ) : void
		{
			if ( _description != value )
			{
				modified = true;
				_description = value;
			}
		}
		
		[Bindable]
		public function get description() : String
		{
			return Utils.getStringOrDefault( _description, '' );
		}
		
		//----------------------------------
		//  picture
		//----------------------------------
		private var _picture : String;
		
		public function set picture( value : String ) : void
		{
			if ( _picture != value )
			{
				modified = true;
				_picture = value;
			}
		}
		
		[Bindable]
		public function get picture() : String
		{
			return Utils.getStringOrDefault( _picture, '' );
		}
		
		public function toXML () : XML
		{
			var projectXML : XML = <project id={id}/>;
			
			projectXML.appendChild(<name>{name}</name>);
			projectXML.appendChild(<installerId>{installerId}</installerId>);
			projectXML.appendChild(<description>{description}</description>);
			projectXML.appendChild(<picture>{picture}</picture>);
			projectXML.appendChild(<initialGraph name={initialGraphName}/>);
			
			return projectXML;
		}
		
		public function fillFromXML (projectXML : XML) : void
		{
			id					= projectXML.@id;
			name				= projectXML.name;
			installerId			= projectXML.installerId;
			description			= projectXML.description;
			picture				= projectXML.picture;
			initialGraphName	= projectXML.initialGraph.@name;
			
		}
		
		// for template xml that supports only 1 project (version <= 1.2.3.7939)
		public function fillParamsFromEntireTemplateXML (xml : XML) : void 
		{
			name			= xml.name;
			installerId		= xml.id;
			description		= xml.description;
			picture			= xml.picture;
		}
		
		public function validateInitGraph(removedGraphName : String, firstGraphName : String = ""):void
		{
			if (initialGraphName == removedGraphName)
				initialGraphName = firstGraphName;
		}
		
		
	}
}