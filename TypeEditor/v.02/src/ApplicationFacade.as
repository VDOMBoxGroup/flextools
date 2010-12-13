/*
   create by 2010 Kotlova Elena
   Class ApplicationFacade need for register main command and
   to listen Notification of users forms
 */
package 
{	
	import net.vdombox.object_editor.controller.FillController;
	import net.vdombox.object_editor.controller.OpenDirectoryCommand;
	import net.vdombox.object_editor.controller.OpenObjectCommand;
	import net.vdombox.object_editor.controller.SaveAsObjectTypeCommand;
	import net.vdombox.object_editor.controller.SaveObjectTypeCommand;
	import net.vdombox.object_editor.controller.StartupCommand;
	
	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.facade.*;
	import org.puremvc.as3.patterns.facade.Facade;
	import org.puremvc.as3.patterns.proxy.*;

	public class ApplicationFacade extends Facade
	{
		public static const STARTUP					:String	= "startup";
		public static const LOAD_XML_FILES			:String = "loadXMLFiles";	
		public static const OPEN_OBJECT				:String = "openObject";
		public static const NEW_NAVIGATOR_CONTENT	:String = "NewNavigatorContent";
		public static const REMOVE_ALL_OBJECT		:String	= "RemoveAllObjects";
		public static const PARSE_XML_FILES			:String	= "ParseXMLFiles";
		public static const OBJECT_COMPLIT			:String	= "ObjectComplit";
		public static const OBJECT_EXIST			:String	= "objectExist";
		public static const SAVE_OBJECT_TYPE		:String	= "saveObjectType";
		public static const SAVE_AS_OBJECT_TYPE		:String	= "saveAsObjectType";

		public static function getInstance() : ApplicationFacade 
		{
			if ( instance == null )
			{
				instance = new ApplicationFacade( );
			}
			return instance as ApplicationFacade;
		}

		override protected function initializeController( ) : void 
		{
			super.initializeController(); 
			registerCommand( STARTUP,			StartupCommand );
			registerCommand( LOAD_XML_FILES,  	OpenDirectoryCommand );	
			registerCommand( PARSE_XML_FILES, 	FillController );
			registerCommand( OPEN_OBJECT, 		OpenObjectCommand );
			registerCommand( SAVE_OBJECT_TYPE, 	SaveObjectTypeCommand );
			registerCommand( SAVE_AS_OBJECT_TYPE,SaveAsObjectTypeCommand );
		}

		public function startup( app:ObjectEditor2 ):void
		{
			sendNotification( STARTUP, app );
		}
	}
}


