/* 
 create by 2010 Kotlova Elena
 Class ApplicationFacade need for register main command and 
 to listen Notification of users forms
 */
package 
{	
	import net.vdombox.object_editor.controller.OpenDirectoryCommand;
	import net.vdombox.object_editor.controller.StartupCommand;
	
	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.facade.*;
	import org.puremvc.as3.patterns.facade.Facade;
	import org.puremvc.as3.patterns.proxy.*;
	
    public class ApplicationFacade extends Facade
    {
		public static const STARTUP:String		  			= "startup";
		public static const LOAD_XML_FILES:String 			= "loadXMLFiles";	
		public static const OPEN_OBJECT:String 	  			= "openObject";
		public static const NEW_NAVIGATOR_CONTENT:String 	= "NewNavigatorContent";
		
		
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
			registerCommand( STARTUP, StartupCommand );
			registerCommand( LOAD_XML_FILES, OpenDirectoryCommand );			
		}
		
		public function startup( app:ObjectEditor2 ):void
		{
			sendNotification( STARTUP, app );
		}
    }
}
