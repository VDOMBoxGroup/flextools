package net.vdombox.powerpack.lib.player.template
{

	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.FileFilter;
	import flash.utils.ByteArray;
	
	import mx.binding.utils.BindingUtils;
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
				xmlStructure = emptyStructure;
				
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
			xmlStructure = null;
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
			
			if (_xml != null)
				version = _xml.version;

			storeAllNodes();
			storeAllArrows();
			
			convertXMLToProjects(_xml);
			
			clearOldProjectVariant();
			
			BindingUtils.bindSetter(selectedProjectChangeHandler, selectedProject, 'modified');
		}
		
		public function get xml() : XML
		{
			return _xml;
		}
		
		public static var XML_NODES_NAMES	: Array = [];
		public static var XML_ARROWS_NAMES	: Array = [];
		
		private function storeAllNodes () : void
		{
			XML_NODES_NAMES = [];
			
			if (!xml)
				return;
			
			for each (var stateNode : XML in xml..state)
				XML_NODES_NAMES.push( Utils.getStringOrDefault( stateNode.@name, "" ) );
			
		}
		
		private function storeAllArrows () : void
		{
			XML_ARROWS_NAMES = [];
			
			if (!xml)
				return;
			
			for each (var arrow : XML in xml..transition)
				XML_ARROWS_NAMES.push( Utils.getStringOrDefault( arrow.@name, "" ) );
		}
		
		private function selectedProjectChangeHandler (object:Object) : void 
		{
			modified = object as Boolean;
		}
		
		protected function clearOldProjectVariant () : void
		{
			if (!xml) return;
				
			delete xml["name"];
			delete xml.id;
			delete xml.description;
			delete xml.picture;
		}
		
		public static const VERSION_FORMAT : RegExp = /^(\d{1,3}\.){2}\d+$/;
		public static const MIN_VERSION : String = "1.3.1";
		private var _version : String = "";
		
		public function set version (value : String) : void
		{
			if (!VERSION_FORMAT.test(value))
				return;
			
			if (_version != value)
			{
				modified = true;
				
				_version = value;
				xml.version = version;
			}
		}
		
		public function get version () : String
		{
			if (!VERSION_FORMAT.test(_version))
				return MIN_VERSION;
			
			return Utils.getStringOrDefault( _version, MIN_VERSION )
		}
		
		public function increaseVersion () : void
		{
			var versionNumbers : Array = version.split(".");
			var versionNewLastNumber : int = int(versionNumbers[2]) + 1;
			
			version = versionNumbers[0] + "." + versionNumbers[1] + "." + versionNewLastNumber;
		}
		
		//----------------------------------
		//  xmlStructure
		//----------------------------------
	
		private function get emptyStructure () : XML
		{
			var emptyStructureXml : XML = 
				<structure>
					<categories/>
					<resources/> 
				</structure>;
			
			return emptyStructureXml;
		}

		
		public static const DEFAULT_CATEGORY_NAME	: String = "Main";
		public static const DEFAULT_GRAPH_NAME		: String = "defaultGraph";
		public static const DEFAULT_NODE_NAME		: String = "defaultNode";
		
		private function get defaultStructure () : XML
		{
			var defStructureXml : XML = 
				<structure>
					<categories>
						<category name={DEFAULT_CATEGORY_NAME} /> 
					</categories>
					<graph name={DEFAULT_GRAPH_NAME} category={DEFAULT_CATEGORY_NAME}>
						<states>
							<state name={DEFAULT_NODE_NAME} type="Initial" category="Normal" enabled="true" breakpoint="false" x="50" y="50">
								<text>State</text> 
							</state>
						</states>
						<transitions /> 
					</graph>
					<resources /> 
				</structure>;
			
			return defStructureXml;
		}
		
		private var _xmlStructure : XML;
	
		public function set xmlStructure( value : XML ) : void
		{
			if ( _xmlStructure != value )
			{
				modified = true;
				_xmlStructure = value;
			}
			
			if (xmlStructure && !xmlStructure.graph[0])
			{
				xmlStructure = defaultStructure;
				modified = true;
				
				if (selectedProject)
					selectedProject.initialGraphName = DEFAULT_GRAPH_NAME;
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
	
			var structData : XML = xmlStructure ? xmlStructure : new XML( <structure/> );
	
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
			
			_xml.selectedProjectID = selectedProject ? selectedProject.id : "";
		}
	
		public function decode() : void
		{
			xmlStructure = null;
	
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
					
					xmlStructure = XML( strDecoded );
	
					if ( xmlStructure )
					{
						if ( xmlStructure.name().localName == 'structure' )
							delete _xml.encoded;
						else
							xmlStructure = null;
					}
				}
				catch ( e : * )
				{
					xmlStructure = null;
				}
			}
			else if ( _xml.hasOwnProperty( 'structure' ) )
			{
				xmlStructure = _xml.structure[0];
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
		
		//
		// projects 
		//
		[Bindable]
		public var projects	: ArrayCollection = new ArrayCollection();
		
		private var _selectedProjectIndex	: int = 0;
		
		public function set selectedProjectIndex (value : int) : void
		{
			if (_selectedProjectIndex != value)
			{	
				_selectedProjectIndex = value;
				modified = true;
			}
		}
		
		[Bindable]
		public function get selectedProjectIndex ()	: int
		{
			return _selectedProjectIndex;
		}
		
		public function set selectedProject (project : TemplateProject) : void
		{
			var index : int = 0;
			for each (var tplProject : TemplateProject in projects)
			{
				if (tplProject.id == project.id)
				{
					if (selectedProjectIndex != index)
						modified = true;
					
					selectedProjectIndex = index;
					break;
				}
				
				index ++;
			}

		}
		
		[Bindable]
		public function get selectedProject () : TemplateProject
		{
			if (!correctSelectedProjectIndex || !projects || projects.length == 0)
				return null;
			
			return projects[selectedProjectIndex];
		}
		
		public function setSelectedProjectById (selProjectId : String) : void
		{
			if (!projects || projects.length == 0)
				return;
			
			if (selectedProject && selProjectId && selectedProject.id == selProjectId)
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
		
		public function isInitialGraphForAnyProject (graphName : String) : Boolean
		{
			for each (var project : TemplateProject in projects)
			{
				if (project.initialGraphName == graphName)
					return true;
			}
			
			return false;
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
			var xml : XML = <selectedProjectID/>
			
			if (selectedProject)
				xml.appendChild( selectedProject.id ); 
			
			return xml;
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
			}
			
			var selProjectId : String = xml.selectedProjectID;
			
			if (!projects || projects.length == 0)
			{
				templateProject = createNewProject();
				
				if (xml.name[0])
					templateProject.fillParamsFromEntireTemplateXML(xml);
				
				selProjectId = templateProject.id;
			} 
			
			setSelectedProjectById(selProjectId);
			
		}
		
		public function clearProjects () : void
		{
			for each (var project : TemplateProject in projects)
				project = null;
			
			projects.removeAll();
			
			//selectedProjectIndex = 0;
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