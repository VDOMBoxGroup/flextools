package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.modules.wysiwyg.view.BodyMediator;
	import net.vdombox.ide.modules.wysiwyg.view.WysiwygMediator;
	import net.vdombox.ide.modules.wysiwyg.view.components.main.Body;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	/**
	 * The CreateBodyCommand creating body of Wysiwyg
	 * @author Alexey Andreev
	 *
	 */
	public class CreateBodyCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Body;
			var bodyMediator : BodyMediator;

			var wysiwygMediator : WysiwygMediator = facade.retrieveMediator( WysiwygMediator.NAME ) as WysiwygMediator;

			if ( facade.hasMediator( BodyMediator.NAME ) )
			{
				bodyMediator = facade.retrieveMediator( BodyMediator.NAME ) as BodyMediator;
				body = bodyMediator.body;
			}
			else
			{
				body = new Body();
				facade.registerMediator( new BodyMediator( body ) )
			}

			body.moduleFactory = wysiwygMediator.wysiwyg.moduleFactory;
			facade.sendNotification( Notifications.EXPORT_BODY, body );
			facade.sendNotification( Notifications.MODULE_SELECTED );
		}
	}
}
