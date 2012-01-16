package net.vdombox.ide.modules.dataBase.view
{
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.modules.dataBase.ApplicationFacade;
	import net.vdombox.ide.modules.dataBase.events.TableElementEvent;
	import net.vdombox.ide.modules.dataBase.view.components.BaseVisualEditor;
	import net.vdombox.ide.modules.dataBase.view.components.TableElement;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class BaseVisualEditorMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "BaseVisualEditorMediator";
		
		public function BaseVisualEditorMediator( viewComponent : Object = null )
		{
			var instanceName : String = NAME + viewComponent.editorID;
			
			super( instanceName, viewComponent );
		}
		
		private function get baseVisualEditor() : BaseVisualEditor
		{
			return viewComponent as BaseVisualEditor;
		}
		
		override public function onRegister() : void
		{
			addHandlers();
			sendNotification( ApplicationFacade.GET_OBJECTS, baseVisualEditor.objectVO );
		}
		
		override public function onRemove() : void
		{
			removeHandlers();
			
			clearMediators();
		}
		
		private function clearMediators() : void
		{
			var count : int = baseVisualEditor.contentGroup.numElements;
			
			for ( var i : int = 0; i < count; i++ )
			{
				var tableElement : TableElement = baseVisualEditor.contentGroup.getElementAt( i ) as TableElement;
				facade.removeMediator( TableElementMediator.NAME + tableElement.objectID );
			}
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.OBJECTS_GETTED );
			interests.push( ApplicationFacade.TABLE_CREATED );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			
			if ( body.pageVO.id != baseVisualEditor.objectVO.id )
				return;
			
			switch ( name )
			{
				case ApplicationFacade.OBJECTS_GETTED:
				{
					clearMediators();
					baseVisualEditor.contentGroup.removeAllElements();
					
					for each ( var objectVO : ObjectVO in body.objects )
					{
						var tableElement : TableElement = new TableElement( objectVO );
						baseVisualEditor.contentGroup.addElement( tableElement ); 
						
					}
					break;
				}
					
				case ApplicationFacade.TABLE_CREATED:
				{
					sendNotification( ApplicationFacade.GET_OBJECTS, baseVisualEditor.objectVO );
					break;
				}
			}
		}
		
		private function addHandlers() : void
		{
			baseVisualEditor.addEventListener( TableElementEvent.CREATION_COMPLETE, setMediatorForTable, true );
			baseVisualEditor.addEventListener( TableElementEvent.SAVE, saveTable, true );
		}
		
		private function removeHandlers() : void
		{
			baseVisualEditor.removeEventListener( TableElementEvent.CREATION_COMPLETE, setMediatorForTable, true );
			baseVisualEditor.removeEventListener( TableElementEvent.SAVE, saveTable, true );
		}
		
		private function setMediatorForTable( event : TableElementEvent ) : void
		{
			facade.registerMediator( new TableElementMediator( event.target ) );
		}
		
		private function saveTable( event : TableElementEvent ) : void
		{
			sendNotification( ApplicationFacade.UPDATE_ATTRIBUTES, event.value );
		}
		
		
	}
}