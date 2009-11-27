package net.vdombox.ide.core.controller
{	
	import net.vdombox.ide.core.model.LocaleProxy;
	import net.vdombox.ide.core.model.ModulesProxy;
	import net.vdombox.ide.core.model.PipesProxy;
	import net.vdombox.ide.core.model.ServerProxy;
	import net.vdombox.ide.core.model.SettingsProxy;
	import net.vdombox.ide.core.model.SharedObjectProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ModelPrepCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			facade.registerProxy( new SettingsProxy() );
			facade.registerProxy( new ServerProxy() );
			facade.registerProxy( new SharedObjectProxy() );
			facade.registerProxy( new LocaleProxy() );
			facade.registerProxy( new ModulesProxy() );
			facade.registerProxy( new PipesProxy() );
		}
	}
}