package net.vdombox.object_editor.controller
{	
	import net.vdombox.object_editor.model.proxy.ItemProxy;
	
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class GetImgResourseID extends SimpleCommand implements ICommand 
	{		
		override public function execute(note:INotification):void
		{
			var information:XML = note.getBody() as XML;
			var iconValue:String  = information.Icon.toString();
			var phraseRE:RegExp = /^(?:#Res\(([-a-zA-Z0-9]*)\))|(?:([-a-zA-Z0-9]*))/;
			
			var imgResourseID:String = "";
			var matchResult : Array = iconValue.match( phraseRE );
			if (matchResult)
			{
				imgResourseID = matchResult[1];
//				trace("imgResourseID: "+imgResourseID);
			}
//			return imgResourseID;
			var itemProxy:ItemProxy = facade.retrieveProxy(ItemProxy.NAME) as ItemProxy;
//			facade.sendNotification();
		}
	}
}