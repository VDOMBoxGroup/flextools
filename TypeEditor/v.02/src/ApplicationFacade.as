/* 
 create by 2010 Kotlova Elena
 Class ApplicationFacade need for register main command and 
 to listen Notification of users forms
 */
package 
{	
	import controller.StartupCommand;
	
	import org.puremvc.as3.patterns.facade.Facade;

    public class ApplicationFacade extends Facade
    {
		public static const STARTUP:String 		   = "startup";
		public static const LOAD_XML_FILES:String = "loadXMLFiles";				
		
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
			registerCommand( STARTUP,   StartupCommand );
//			registerCommand( LOAD_FILE, OpenFileCommand );			
		}
		
		public function startup( app:FilesLoading ):void
		{
			sendNotification( STARTUP, app );
		}
    }
}
