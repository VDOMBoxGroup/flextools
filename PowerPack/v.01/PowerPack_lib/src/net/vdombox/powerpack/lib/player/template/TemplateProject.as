package net.vdombox.powerpack.lib.player.template
{
	import flash.events.EventDispatcher;
	
	import mx.utils.UIDUtil;
	
	import net.vdombox.powerpack.lib.extendedapi.utils.Utils;
	import net.vdombox.powerpack.lib.player.gen.structs.GraphStruct;
	
	public class TemplateProject extends EventDispatcher
	{
		public static const DEFAULT_NAME			: String = "newProject";
		public static const DEFAULT_INSTALLER_ID	: String = "newProject";
		
		[Bindable]
		public var key : String;
		
		public var id : String; // GUID
		
		public function TemplateProject()
		{
			id = UIDUtil.createUID();
		}
		
		private var _initialGraphName : String;
		
		public function set initialGraphName(value : String) : void
		{
			if (!value)
				value = DEFAULT_NAME;
			
			if ( _initialGraphName != value )
			{
				modified = true;
				_initialGraphName = value;
			}
		}
		
		[Bindable]
		public function get initialGraphName () : String
		{
			return Utils.getStringOrDefault( _initialGraphName, Template.DEFAULT_GRAPH_NAME );
		}
		
		//
		//	modified
		//
		protected var _modified : Boolean;
		
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
		
		//
		//	license
		//
		private var _license : String;
		
		public function set license( value : String ) : void
		{
			if ( _license != value )
			{
				modified = true;
				_license = value;
			}
		}
		
		[Bindable]
		public function get license() : String
		{
			return Utils.getStringOrDefault( _license, '' );
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
			projectXML.appendChild(<license><en_US>{license}</en_US></license>);
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
			license				= projectXML.license.en_US;
			picture				= projectXML.picture;
			initialGraphName	= projectXML.initialGraph.@name;
			
		}
		
		// for template xml that supports only 1 project (version <= 1.2.3.7939)
		public function fillParamsFromEntireTemplateXML (templateXml : XML) : void 
		{
			name				= templateXml.name;
			installerId			= templateXml.id;
			description			= templateXml.description;
			picture				= templateXml.picture;
			
			setInitialGraphNameFromTemplateStructure(templateXml);
		}
		
		// for template xml that supports only 1 project (version <= 1.2.3.7939)
		private function setInitialGraphNameFromTemplateStructure (templateXml : XML) : void
		{
			initialGraphName = Template.DEFAULT_GRAPH_NAME;
			
			var graphs : XMLList = templateXml.structure.graph;
			for each (var graphXML : XML in graphs)
			{
				if (graphXML.@initial == "true")
				{
					initialGraphName = graphXML.@name;
					break;
				}
			}
			
			if (!initialGraphName && graphs.length() > 0)
				initialGraphName = graphs[0].@name;
			
		}
		
		public function updateInitGraphName(oldGraphName : String, newGraphName : String = ""):void
		{
			if (!oldGraphName || initialGraphName == oldGraphName)
				initialGraphName = newGraphName;
		}
		
		
	}
}