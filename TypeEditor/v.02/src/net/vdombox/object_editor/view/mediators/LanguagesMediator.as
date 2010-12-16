package net.vdombox.object_editor.view.mediators
{
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
	import net.vdombox.object_editor.model.vo.AttributeVO;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.essence.Languages;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class LanguagesMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "LanguagesMediator";
		private var objectTypeVO:ObjectTypeVO;
		
		public function LanguagesMediator( viewComponent:Object, objTypeVO:ObjectTypeVO ) 
		{			
			super( NAME+objTypeVO.id, viewComponent );
			this.objectTypeVO = objTypeVO;	
			view.addEventListener( FlexEvent.SHOW, showLanguages );
		}
		
		private function showLanguages(event: FlexEvent): void
		{			
			view.languagesDataGrid.dataProvider = objectTypeVO.languages;
			view.validateNow();
		}
		
		protected function compliteLanguages( ):void
		{			
			//to mediator
//				this.enabled = true;
//				prentXML = xml;
//				arLanguages = new ArrayCollection();
				
				/*var cols:Array = new Array();
				var dataGridColumn: DataGridColumn = new DataGridColumn("ID");
				dataGridColumn.width = 50;
//				dataGridColumn.editable = true;
				dataGridColumn.setStyle("fontWeight", "bold");
				cols.push(dataGridColumn);
				
				var data:ArrayCollection = objectTypeVO.languages;// xml.Languages[0];
				if (data != null)  // data = new XML("<Languages/>");
				
				for each(var attributeVO:AttributeVO in data)
				{	
					if (child.name() == "Language")
					{
						dataGridColumn = new DataGridColumn(child[0].@Code);
						cols.push(dataGridColumn);
					}
				}
				languages.columns = cols;
				
				arLanguages.removeAll();*/		
		}		
		
		protected function get view():Languages
		{
			return viewComponent as Languages;
		}
	}
}