package vdom.events
{
	import flash.events.Event;

	public class DataManagerEvent extends Event
	{

		// Public constructor.
		public function DataManagerEvent( type : String, result : * = null, isEnabled : Boolean = false,
										  objectId : String = null, key : String = "" )
		{
			// Call the constructor of the superclass.
			super( type );

			// Set the new property.
			this.isEnabled = isEnabled;
			this.objectId = objectId;
			this.result = result;
			this.key = key;
		}

		// Define static constant.
		public static const INIT_COMPLETE : String = "initComplete";

		public static const CREATE_APPLICATION_COMPLETE : String = "createApplicationComplete";
		public static const LOAD_APPLICATION_COMPLETE : String = "loadApplicationComplete";
		public static const SET_APPLICATION_INFO_COMPLETE : String = "setApplicationInfoComplete";

		public static const GET_APPLICATION_EVENTS_COMPLETE : String = "getApplicationEventsComplete";
		public static const SET_APPLICATION_EVENTS_COMPLETE : String = "setApplicationEventsComplete";

		public static const GET_APPLICATION_STRUCTURE_COMPLETE : String = "getApplicationStructureComplete";
		public static const SET_APPLICATION_STRUCTURE_COMPLETE : String = "setApplicationStructureComplete";

		public static const LOAD_TYPES_COMPLETE : String = "loadTypesComplete";

		public static const GET_OBJECT_XML_SCRIPT_COMPLETE : String = "getObjectXMLScriptComplete";
		public static const SET_OBJECT_XML_SCRIPT_COMPLETE : String = "setObjectXMLScriptComplete";

		public static const CREATE_OBJECT_COMPLETE : String = "createObjectComplete";
		public static const DELETE_OBJECT_COMPLETE : String = "deleteObjectComplete";

		public static const GET_SCRIPT_COMPLETE : String = "getScriptComplete";
		public static const SET_SCRIPT_COMPLETE : String = "setScriptComplete";

		public static const GET_SERVER_ACTIONS_COMPLETE : String = "getServerActionsComplete";
		public static const SET_SERVER_ACTIONS_COMPLETE : String = "setServerActionsComplete";

		public static const MODIFY_RESOURCE_COMPLETE : String = "modifyResourceComplete";

		public static const SEARCH_COMPLETE : String = "searchComplete";

		public static const UPDATE_ATTRIBUTES_BEGIN : String = "updateAttributesBegin";
		public static const UPDATE_ATTRIBUTES_COMPLETE : String = "updateAttributesComplete";

		public static const PAGE_CHANGED : String = "pageChanged";
		public static const OBJECT_CHANGED : String = "objectChanged";

		public static const GET_LIBRARIES_COMPLETE : String = "getLibrariesComplete";
		public static const SET_LIBRARY_COMPLETE : String = "setLibraryComplete";

		public static const CLOSE : String = "close";

		// Define a public variable to hold the state of the enable property.
		public var isEnabled : Boolean;
		public var objectId : String;
		public var result : XML;
		public var key : String;

		// Override the inherited clone() method.
		override public function clone() : Event
		{
			return new DataManagerEvent( type, isEnabled );
		}
	}
}