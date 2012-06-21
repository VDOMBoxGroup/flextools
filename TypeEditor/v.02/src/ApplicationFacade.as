/*
   Class ApplicationFacade need for register main command and
   to listen Notification of users forms
*/
package 
{		
	import net.vdombox.object_editor.controller.ConnectToServerCommand;
	import net.vdombox.object_editor.controller.CreateXMLFileCommand;
	import net.vdombox.object_editor.controller.FillAccordionCommand;
	import net.vdombox.object_editor.controller.NewObjectTypePathCommand;
	import net.vdombox.object_editor.controller.OpenDirectoryCommand;
	import net.vdombox.object_editor.controller.OpenObjectCommand;
	import net.vdombox.object_editor.controller.PreinitializeCommand;
	import net.vdombox.object_editor.controller.RestartObjectCommand;
	import net.vdombox.object_editor.controller.SaveObjectTypeCommand;
	import net.vdombox.object_editor.controller.ShowErrorCommand;
	import net.vdombox.object_editor.controller.StartupCommand;
	import net.vdombox.object_editor.controller.UploadTypeToServerCommand;
	
	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.facade.*;
	import org.puremvc.as3.patterns.facade.Facade;
	import org.puremvc.as3.patterns.proxy.*;

	public class ApplicationFacade extends Facade
	{		
		public static const SERVER_CONNECTION_ERROR		:String	= "serverConnectionError";
		public static const SERVER_LOGIN_ERROR			:String	= "serverLoginError";
		public static const SERVER_LOGIN_OK				:String	= "serverLoginOk";
		
		
		public static const CHANGE_CURRENT_LANGUAGE		:String	= "changeCurrentLanguage";
		public static const CRAETE_XML_FILE				:String = "createXmlFile";
		public static const LOAD_XML_FILES				:String = "loadXMLFiles";
		public static const NEW_NAVIGATOR_CONTENT		:String = "newNavigatorContent";		
		public static const OPEN_OBJECT					:String = "openObject";
		public static const PARSE_XML_FILES				:String	= "parseXMLFiles";
		public static const PREINITIALIZE				:String	= "preinitialize";
		public static const RESTART_OBJECT				:String	= "restartObject";
		public static const SAVE_AS_OBJECT_TYPE			:String	= "saveAsObjectType";
		public static const SAVE_OBJECT_TYPE			:String	= "saveObjectType";	
		public static const STARTUP						:String	= "startup";	
		
		public static const CONNECT_TO_SERVER			:String	= "connectToServer";	
		public static const UPLOAD_TYPE_TO_SERVER		:String	= "uploadTypeToServer";	

		public static function getInstance() : ApplicationFacade 
		{
			if (instance == null)
				instance = new ApplicationFacade( );
			return instance as ApplicationFacade;
		}

		/**
		 * Registreted Commands on Notification.
		**/
		override protected function initializeController( ) : void 
		{
			super.initializeController(); 
			
			
			registerCommand( SERVER_CONNECTION_ERROR,	ShowErrorCommand );
			registerCommand( SERVER_LOGIN_ERROR,		ShowErrorCommand );
			registerCommand( STARTUP,					StartupCommand );
			registerCommand( CRAETE_XML_FILE,			CreateXMLFileCommand );
			registerCommand( LOAD_XML_FILES,			OpenDirectoryCommand );			
			registerCommand( PARSE_XML_FILES,			FillAccordionCommand );
			registerCommand( PREINITIALIZE,				PreinitializeCommand );
			registerCommand( OPEN_OBJECT,				OpenObjectCommand );
			registerCommand( SAVE_OBJECT_TYPE,			SaveObjectTypeCommand );
			registerCommand( SAVE_AS_OBJECT_TYPE,		NewObjectTypePathCommand );
			registerCommand( RESTART_OBJECT,			RestartObjectCommand );
			registerCommand( CONNECT_TO_SERVER,			ConnectToServerCommand );
			registerCommand( UPLOAD_TYPE_TO_SERVER,		UploadTypeToServerCommand );
		}
		
		public function preinitialize( app:TypeEditor ):void
		{
			sendNotification( PREINITIALIZE, app );
		}

		public function startup( app:TypeEditor ):void
		{
			sendNotification( STARTUP, app );
		}		
	}
}


