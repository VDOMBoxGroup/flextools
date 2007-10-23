package vdom.components.editor.containers {

import mx.containers.Accordion;
import mx.containers.VBox;

import vdom.components.editor.containers.typesClasses.Type;
import mx.collections.ArrayCollection;
	
public class Types extends Accordion {
	
	public function Types()	{
		
		super();
	}
	
	public function set dataProvider(typesXML:XML):void {
		
		var cat:Object = {};
		
		for each (var num:XML in typesXML.Type) {
			
			if(!cat[num.Information.Category]) {
				
				cat[num.Information.Category] = new VBox();
			}
			
			cat[num.Information.Category].label = num.Information.Category;
			cat[num.Information.Category].setStyle('horizontalAlign', 'center');
			cat[num.Information.Category].percentWidth = 100;
			
			var et:Type = new Type(num.Information.ID, num.Information.EditorIcon, num.Information.Name);
			
			et.setStyle('horizontalAlign', 'center');
			et.percentWidth = 100;
			cat[num.Information.Category].addChild(et); 
		}
		
		for each(var vb:VBox in cat) {
			vb.horizontalScrollPolicy = 'off';
			addChild(vb); 
		}
	}
}
}