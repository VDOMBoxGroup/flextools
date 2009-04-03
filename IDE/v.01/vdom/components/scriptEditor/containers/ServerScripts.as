package vdom.components.scriptEditor.containers
{
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.collections.XMLListCollection;
	import mx.controls.List;
	import mx.events.ListEvent;
	import mx.utils.UIDUtil;
	
	import vdom.containers.ClosablePanel;
	import vdom.events.DataManagerEvent;
	import vdom.events.ServerScriptsEvent;
	import vdom.managers.DataManager;
	import vdom.utils.IconUtils;

	[Event( name="scriptChanged", type = "vdom.events.ServerScriptsEvent" )]

	public class ServerScripts extends ClosablePanel
	{

		public function ServerScripts()
		{
			super();
			tree = new List();
			tree.iconFunction = getIcon;
			tree.percentWidth = 100;
			tree.percentHeight = 100;
			tree.labelField = "@Name";
			tree.setStyle( "borderColor", "0xFFFFFF" );

			tree.addEventListener( ListEvent.CHANGE, tree_changeHandler );

			addChild( tree );
		}

		[Embed( source="/assets/scriptEditor/python.png" )]
		private var python : Class;

		[Embed( source="/assets/scriptEditor/vbscript.png" )]
		private var vscript : Class;

		private var dataManager : DataManager = DataManager.getInstance();

		private var masResourceID : Array = new Array();

		public var tree : List;
		private var curContainerID : String;

		private var dataXML : XMLListCollection;
		private var xmlToServer : XML;
		
		private var _scriptLanguage : String
		
		public function get scriptLanguage() : String
		{
			return _scriptLanguage;
		}  
		
		public function set scriptLanguage( value : String ) :void
		{
			_scriptLanguage = value;
		}
		
		public function set dataProvider( str : String ) : void
		{
			tree.dataProvider = null;
			curContainerID = str;
			dataManager.addEventListener( DataManagerEvent.GET_SERVER_ACTIONS_COMPLETE,
										  getServerActionsHandler );
			dataManager.getServerActions( str );
		}

		public function set addScript( xml : XML ) : void
		{
			xml.@ID = UIDUtil.createUID();

			dataXML.addItem( xml );

			var sort : Sort = new Sort();
			sort.fields = [ new SortField( "@label" ) ];
			dataXML.sort = sort;
			dataXML.refresh();

			var temp : XML = new XML( xml.toXMLString() );

			xmlToServer.appendChild( temp );

			tree.dataProvider = dataXML;
			tree.validateNow();

			tree.selectedItem = xml;
			tree.validateNow();
			dispatchEvent( new ServerScriptsEvent( ServerScriptsEvent.SCRIPT_CHANGED ) );
		}

		public function get dataEnabled() : Object
		{
			return tree.selectedItem;
		}

		public function get script() : String
		{
			if ( !tree.selectedItem )
				return "";

			var ID : String = tree.selectedItem.@ID;

			if ( ID == "" )
				return null;

			if ( !xmlToServer.Action[ 0 ] )
				return null;

			return xmlToServer.Action.( @ID == ID )[ 0 ].toString();
		}

		public function set script( str : String ) : void
		{
			if ( tree.selectedItem )
			{
				var ID : String = tree.selectedItem.@ID;
				var tempXML : XML = xmlToServer.Action.( @ID == ID )[ 0 ];
				var xml : XML = new XML( "<Action/>" );
				xml.@ID = tempXML.@ID;
				xml.@Name = tempXML.@Name;
				xml.@Top = tempXML.@Top;
				xml.@Left = tempXML.@Left;
				xml.@State = tempXML.@State;
				xml.appendChild( XML( "<![CDATA[" + str + "]" + "]>" ) );

				delete xmlToServer.Action.( @ID == ID )[ 0 ];
				xmlToServer.appendChild( xml );

				dataManager.setServerActions( xmlToServer, curContainerID );
			}
		}

		public function deleteScript() : void
		{
			var ID : String = tree.selectedItem.@ID;

			if ( tree.selectedIndex < 0 || dataXML.length < 2 )
			{
				return;
			}

			delete dataXML.removeItemAt( tree.selectedIndex );
			delete xmlToServer.Action.( @ID == ID )[ 0 ];

			if ( dataXML.toXMLString() != "<Actions/>" )
			{

				tree.dataProvider = dataXML;
				tree.validateNow();

				tree.selectedIndex = 0;
				tree.validateNow();

				dispatchEvent( new ServerScriptsEvent( ServerScriptsEvent.SCRIPT_CHANGED ) );
			}
			else
			{
				tree.dataProvider = null;
			}
		}

		private function createData( xmlToTree : XML ) : void
		{
			xmlToServer = new XML( "<ServerActions/>" );
			dataXML = new XMLListCollection();

			var continer : XML;

			if ( xmlToTree.Container.( @ID == dataManager.currentObjectId )[ 0 ] )
			{
				continer = new XML( xmlToTree.Container.( @ID == dataManager.currentObjectId )[ 0 ].toXMLString() );

				var object : XML = dataManager.getObject( dataManager.currentObjectId );
			}
			else
			{
				continer = new XML( xmlToTree.toXMLString() );
			}

			var tempXML : XML;
			if ( continer.toString() != "" )
			{
				for each ( var actID : XML in continer.children() )
				{
					tempXML = 
						<Action/>
						;
					tempXML.@label = actID.@Name;
					tempXML.@Name = actID.@Name;
					tempXML.@ID = actID.@ID;

					dataXML.addItem( tempXML );
					xmlToServer.appendChild( actID );
				}

				var sort : Sort = new Sort();
				sort.fields = [ new SortField( "@label" ) ];
				dataXML.sort = sort;
				dataXML.refresh();

				tree.dataProvider = dataXML;
				tree.validateNow();

				tree.selectedIndex = 0;
			}
			else
			{
				tree.dataProvider = null;
			}
			dispatchEvent( new ServerScriptsEvent( ServerScriptsEvent.SCRIPT_CHANGED ) );
		}

		private function getIcon( value : Object ) : Class
		{
//			var xmlData : XML = XML( value );
//
//			if ( xmlData.@Language.toXMLString() == "python" )
//				return python;
//
//			if ( xmlData.@Language.toXMLString() == "vscript" )
//				return vscript;
//
//			var data : Object = { typeId : xmlData.@Type, resourceId : xmlData.@resourceID }
//
//			return IconUtils.getClass( this, data, 16, 16 );
			
			if( _scriptLanguage == "python" )
				return python;
			else
				return vscript;
		}

		private function getSourceID( ID : String ) : String
		{
			if ( masResourceID[ ID ] )
				return masResourceID[ ID ];

			var xml : XML = dataManager.getTypeByTypeId( ID );
			var str : String = xml.Information.StructureIcon;

			masResourceID[ ID ] = str.substr( 5, 36 );

			return masResourceID[ ID ];
		}

		private function getServerActionsHandler( dmEvt : DataManagerEvent ) : void
		{

			dataManager.removeEventListener( DataManagerEvent.GET_SERVER_ACTIONS_COMPLETE,
											 getServerActionsHandler );
			createData( dmEvt.result );
		}

		private function tree_changeHandler( lsEvt : ListEvent ) : void
		{
			dispatchEvent( new ServerScriptsEvent( ServerScriptsEvent.SCRIPT_CHANGED ) );
		}
	}
}