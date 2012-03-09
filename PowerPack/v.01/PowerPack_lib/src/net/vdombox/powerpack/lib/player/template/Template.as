package net.vdombox.powerpack.lib.player.template
{

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayCollection;
	import mx.utils.Base64Decoder;
	import mx.utils.Base64Encoder;
	import mx.utils.StringUtil;
	import mx.utils.UIDUtil;
	
	import net.vdombox.powerpack.lib.extendedapi.utils.Utils;
	import net.vdombox.powerpack.lib.player.managers.ContextManager;
	import net.vdombox.powerpack.lib.player.managers.LanguageManager;
	import net.vdombox.powerpack.lib.player.popup.AlertPopup;
	import net.vdombox.powerpack.lib.player.utils.CryptUtils;

/**
 *
 *	<template ID=''>
 *		 <name/>
 *		 <description/>
 *		 <picture/>
 *		 <encoded> or <structure>
 *			 <graph name='' initial='' category=''>
 *				 <states>
 *					 <state name='' type='' category='' enabled='' breakpoint='' x='' y=''>
 *						 <text/>
 *					 </state>
 *					 ...
 *				 </states>
 *
 *				 <transitions>
 *					 <transition name='' highlighted='' enabled='' source='' destination=''>
 *						 <label/>
 *					 </transition>
 *					 ...
 *				 </transitions>
 *			 </graph>
 *			 ...
 *			<categories>
 *				<category name=''/>
 *				...
 *			</categories>
 *
 *			<resources>
 *				<resource category='' ID='' type='' name=''/>
 *				...
 *			</resources>
 *		 </encoded> or </structure>
 *	 </template>
 *
 */

	public class Template extends EventDispatcher
	{
		public static const TYPE_APPLICATION : String = "application";
		public static const TYPE_MODULE : String = "module";
	
		public static const TPL_EXTENSION : String = 'xml';
	
		public static var tplFilter : FileFilter = new FileFilter(
				StringUtil.substitute( "{0} ({1})", LanguageManager.sentences['template'], "*." + TPL_EXTENSION ),
				"*." + TPL_EXTENSION );
	
		public static var allFilter : FileFilter = new FileFilter(
				StringUtil.substitute( "{0} ({1})", LanguageManager.sentences['all'], "*.*" ),
				"*.*" );
	
		public static var defaultCaptions : Object = {
		};
	
		private static var _classConstructed : Boolean = classConstruct();
		

		public static function get classConstructed() : Boolean
		{
			return _classConstructed;
		}
	
		// Define a static method.
		private static function classConstruct() : Boolean
		{
			LanguageManager.setSentences( defaultCaptions );
	
			return true;
		}
	
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
	
		/**
		 *	Constructor
		 */
		public function Template( templateXML : XML = null )
		{
			xml = new XML( <template/> );
			xml.@ID = UIDUtil.createUID();
	
			if ( templateXML && isValidTpl( templateXML ) )
			{
				xml = templateXML.copy();
				if ( !Utils.getStringOrDefault( xml.@ID, '' ) )
					xml.@ID = UIDUtil.createUID();
	
				processOpened();
				return;
			}
			else if ( !templateXML )
			{
				modified = true;
				_completelyOpened = true;
			}
		}
	
		//--------------------------------------------------------------------------
		//
		//  Destructor
		//
		//--------------------------------------------------------------------------
	
		/**
		 *	Destructor
		 */
		public function dispose() : void
		{
			_xmlStructure = null;
			xml = null;
		}
	
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
	
		/**
		 *
		 * template file (XML)
		 */
	
		protected var _completelyOpened : Boolean;
	
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
	
		//----------------------------------
		//  modified
		//----------------------------------
	
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
	
		//----------------------------------
		//  xml
		//----------------------------------
	
		protected var _xml : XML;
	
		public function set xml (value : XML) : void
		{
			_xml = value;
			
			convertXMLToProjects(_xml);
			
			clearOldProjectVariant();
		}
		
		protected function clearOldProjectVariant () : void
		{
			if (!xml) return;
				
			delete xml["name"];
			delete xml.id;
			delete xml.description;
			delete xml.picture;
		}
		
		public function get xml() : XML
		{
			return _xml;
		}
	
		//----------------------------------
		//  xmlStructure
		//----------------------------------
	
		protected var _xmlStructure : XML;
	
		public function set xmlStructure( value : XML ) : void
		{
			if ( _xmlStructure != value )
			{
				modified = true;
				_xmlStructure = value;
			}
		}
	
		[Bindable]
		public function get xmlStructure() : XML
		{
			return _xmlStructure;
		}
		
		//----------------------------------
		//  ID
		//----------------------------------
	
		public function set ID( value : String ) : void
		{
			if ( _xml.@ID != value )
			{
				modified = true;
				_xml.@ID = value;
			}
		}
	
		[Bindable]
		public function get ID() : String
		{
			if (!_xml)
				return "";
			
			if ( !_xml.hasOwnProperty( '@ID' ) )
				_xml.@ID = UIDUtil.createUID();
	
			return _xml.@ID;
		}
	
		//----------------------------------
		//  isEncoded
		//----------------------------------
	
		public function get isEncoded() : Boolean
		{
			if (!_xml)
				return false;
			
			return _xml.hasOwnProperty( 'encoded' );
		}
	
		//--------------------------------------------------------------------------
		//
		//  Class methods
		//
		//--------------------------------------------------------------------------
	
		protected function isValidTpl( xmlData : XML ) : Boolean
		{
			if ( xmlData.name() != 'template' )
				return false;
	
			if ( !xmlData.hasOwnProperty( 'encoded' ) && !xmlData.hasOwnProperty( 'structure' ) )
				return false;
	
			return true;
		}
	
	
		
		public function processOpened() : void
		{
			if ( !_xml.hasOwnProperty( 'encoded' ) && !_xml.hasOwnProperty( 'structure' ) )
				return;
	
			decode();
	
			if ( !isEncoded )
				_completelyOpened = true;
		}
	
		protected function encode() : void
		{
			delete _xml.encoded;
			delete _xml.structure;
	
			var structData : XML = _xmlStructure ? _xmlStructure : new XML( <structure/> );
	
			if ( selectedProject.key )
			{
				var bytes : ByteArray = CryptUtils.encrypt( structData.toXMLString(), selectedProject.key );
	
				var encoder : Base64Encoder = new Base64Encoder();
				
				encoder.encodeBytes( bytes );
				
				_xml.encoded = encoder.flush();
			}
			else
				_xml.structure = structData;
	
		}
		
		public function fillProjects () : void
		{
			_xml.projects = convertProjectsToXML();
			
			_xml.selectedProject = selectedProjectToXML();
		}
	
		public function decode() : void
		{
			_xmlStructure = null;
	
			if ( isEncoded && _xml.hasOwnProperty( 'structure' ) )
				delete _xml.structure;
	
			if ( isEncoded && selectedProject.key )
			{
				try
				{
					var strEncoded : String = XML( _xml.encoded[0] ).toString();
					var strDecoded : String;
	
					var decoder : Base64Decoder = new Base64Decoder();
					decoder.decode( strEncoded );
					
					var bytes : ByteArray = decoder.flush();
	
					bytes = CryptUtils.decrypt( bytes, selectedProject.key );
					bytes.position = 0;
					
					strDecoded = bytes.readUTFBytes( bytes.length );
					
					_xmlStructure = XML( strDecoded );
	
					if ( _xmlStructure )
					{
						if ( _xmlStructure.name().localName == 'structure' )
							delete _xml.encoded;
						else
							_xmlStructure = null;
					}
				}
				catch ( e : * )
				{
					_xmlStructure = null;
				}
			}
			else if ( _xml.hasOwnProperty( 'structure' ) )
			{
				_xmlStructure = _xml.structure[0];
				delete _xml.structure;
			}
		}
		
		protected function showError(errorText : String) : void
		{
			AlertPopup.show( errorText,  LanguageManager.sentences['error']);
		}
		
		protected function get key () : String
		{
			if (!selectedProject)
				return "";
			
			return selectedProject.key;
		}
		
		protected function set key (tplKey : String) : void
		{
			selectedProject.key = tplKey;
		}
		
		[Bindable]
		public var graphs	: ArrayCollection = new ArrayCollection();
		
		//
		// projects 
		//
		[Bindable]
		public var projects	: ArrayCollection = new ArrayCollection();
		
		[Bindable]
		public var selectedProjectIndex	: int = 0;
		
		[Bindable]
		public function get selectedProject () : TemplateProject
		{
			if (!correctSelectedProjectIndex || !projects || projects.length == 0)
				return null;
			
			return projects[selectedProjectIndex];
		}
		
		public function set selectedProject (project : TemplateProject) : void
		{
			var index : int = 0;
			for each (var tplProject : TemplateProject in projects)
			{
				if (tplProject.id == project.id)
				{
					selectedProjectIndex = index;
					
					modified = true;
					break;
				}
				
				index ++;
			}
		}
		
		public function setSelectedProjectById (selProjectId : String) : void
		{
			if (!projects || projects.length == 0)
				return;
			
			if (!selProjectId)
				selectedProject = projects[0];
			
			for each (var project : TemplateProject in projects)
			{
				if (project.id == selProjectId)
				{
					selectedProject = project;
					return;
				}
			}
			
			selectedProject = projects[0];
			
		}
		
		private function validateSelectedProjectIndex() : void
		{
			if (!correctSelectedProjectIndex)
				selectedProjectIndex = 0;
		}
		
		private function get correctSelectedProjectIndex () : Boolean
		{
			if (isNaN(selectedProjectIndex) || selectedProjectIndex < 0)
				return false;
			
			if (projects && selectedProjectIndex >= projects.length)
				return false;
			
			return true;
		}
		
		public function createNewProject () : TemplateProject
		{
			var newProject : TemplateProject = new TemplateProject();
			
			projects.addItem( newProject );
			
			modified = true;
			
			return newProject;
		}
		
		public function deleteProject (project : TemplateProject) : void
		{
			if (!projects)
				return;
			
			var projectIndex : int = getProjectIndex(project);
			
			if (projectIndex == -1)
				return;
			
			projects.removeItemAt(projectIndex);
			
			modified = true;
			
			if (projectIndex > selectedProjectIndex)
				return;
			
			var newIndex : int = selectedProjectIndex - 1;
			newIndex = newIndex < 0 ? 0 : newIndex;
			
			selectedProjectIndex = newIndex;
			
			validateSelectedProjectIndex();
		}
		
		private function getProjectIndex(project : TemplateProject) : int
		{
			var index : Number = 0;
			for each (var tplProject : TemplateProject in projects)
			{
				if (tplProject.id == project.id)
					return index;
					
				index ++;
			}
			
			trace ("getProjectIndex: -1");
			return -1;
		}
		
		
		public function convertProjectsToXML () : XML
		{
			var projectsXML : XML = <projects/>;
			
			for each (var project : TemplateProject in projects)
			{
				projectsXML.appendChild(project.toXML());
			}
			
			return projectsXML;
		}
		
		public function selectedProjectToXML () : XML
		{
			if (!selectedProject)
				return <selectedProject />;
			
			return <selectedProject id={selectedProject.id}/>;
		}
		
		public function convertXMLToProjects (xml:XML) : void
		{
			clearProjects();
			
			var templateProject : TemplateProject;
			
			if (!xml)
			{
				templateProject = createNewProject();
				selectedProject = templateProject;
				return;
			}
			
			
			for each (var projectXML : XML in xml.projects.project)
			{
				templateProject = createNewProject();
				
				templateProject.fillFromXML(projectXML);
				setSelectedProjectById(xml.selectedProject.@id);
			}
			
			if (!projects || projects.length == 0)
			{
				templateProject = createNewProject();
				
				if (xml.name[0])
					templateProject.fillParamsFromEntireTemplateXML(xml);
				
				selectedProject = templateProject;
			}
			
		}
		
		public function clearProjects () : void
		{
			for each (var project : TemplateProject in projects)
				project = null;
			
			projects.removeAll();
			
			selectedProjectIndex = 0;
		}
		
		public function updateProjectsInitGraphName(oldGraphName : String, newGraphName : String = ""):void
		{
			for each (var project : TemplateProject in projects)
			{
				project.updateInitGraphName(oldGraphName, newGraphName);
			}
		}
		
	}
}