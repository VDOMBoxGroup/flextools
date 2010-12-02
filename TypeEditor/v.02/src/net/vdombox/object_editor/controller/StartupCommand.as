/*
  Class StartupCommand register the Proxies and AplicationMediators
*/
package controller
{   
    import org.puremvc.as3.interfaces.*;
    import org.puremvc.as3.patterns.command.*;
    
    import view.ApplicationMediator;

    /**
     * A MacroCommand executed when the application starts.
     *
       * @see org.puremvc.as3.demos.flex.cafetownsend.controller.ModelPrepCommand ModelPrepCommand 
       * @see org.puremvc.as3.demos.flex.cafetownsend.controller.ViewPrepCommand ViewPrepCommand 
     */
    public class StartupCommand extends SimpleCommand implements ICommand
    {
		// Register the Proxies and AplicationMediators
		override public function execute(note:INotification):void    {
			// Create and register proxy
//			facade.registerProxy(new OpenFileProxy());
//			facade.registerProxy(new SaveFileProxy());
//			facade.registerMediator( new ApplicationMediator( note.getBody() ) );			
		}                
    }
}
