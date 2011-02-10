package net.vdombox.object_editor.controller
{
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.mediators.ApplicationMediator;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;


	public class RestartObjectCommand extends SimpleCommand 
	{
		override public function execute( note:INotification ) :void
		{
			var objTypeVO:ObjectTypeVO = note.getBody()["ObjTypeVO"];
			var objID:String = objTypeVO.id;
			objTypeVO = null;
			facade.removeMediator(note.getBody()["MediatorName"]);
			
			facade.sendNotification( ApplicationFacade.OPEN_OBJECT, note.getBody()["Item"] );	
			facade.sendNotification( ApplicationMediator.REOPEN_TAB, {"ViewInd"	:note.getBody()["ViewInd"], 
																	"SelectTab"	:note.getBody()["SelectTab"]} );	
		}
	}
}