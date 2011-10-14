//------------------------------------------------------------------------------
//
//   Copyright 2011 
//   VDOMBOX Resaerch  
//   All rights reserved. 
//
//------------------------------------------------------------------------------

package net.vdombox.ide.core.controller
{
	import mx.core.UIComponent;
	import net.vdombox.ide.core.model.ModulesProxy;
	import net.vdombox.ide.core.view.ApplicationManagerWindowMediator;
	import net.vdombox.ide.core.view.components.ApplicationManagerWindow;
	import net.vdombox.ide.core.view.components.MainWindow;
	import net.vdombox.ide.core.view.skins.ApplicationManagerWindowSkin;
	import net.vdombox.ide.core.view.skins.MainWindowSkin;
	import net.vdombox.utils.WindowManager;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	import spark.components.Button;

	/**
	 *  registred on ApplicationFacade.OPEN_APPLICATION_MANAGER command
	 *  for show ApplicationManagerWindow 
	 * @author andreev ap
	 */
	public class OpenApplicationManagerCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var applicationManagerWindowMediator : ApplicationManagerWindowMediator = facade.retrieveMediator( ApplicationManagerWindowMediator.NAME ) as ApplicationManagerWindowMediator;
			// if already opened do nothing
			if ( applicationManagerWindowMediator )
				return;

			// craeting  a ApplicationManagerWindow
			var applicationManagerWindow : ApplicationManagerWindow = new ApplicationManagerWindow();
			applicationManagerWindowMediator = new ApplicationManagerWindowMediator( applicationManagerWindow );
			facade.registerMediator( applicationManagerWindowMediator );

			// popup Window
			var mainWindowSkin : MainWindowSkin = notification.getBody() as MainWindowSkin;
			WindowManager.getInstance().addWindow( applicationManagerWindow, mainWindowSkin, true );
		}
	}
}
