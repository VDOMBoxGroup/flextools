package vdom.components.eventEditor
{
	import mx.controls.Tree;

	public class TreeEvents extends DragTree
	{
		public function TreeEvents()
		{
			super();
		}
		
		/* <Event Name='onmousedown'/>
                <Event Name='onmouseup'/>
                <Event Name='onmouseover'/>
                <Event Name='onmousemove'/>
                <Event Name='onmouseout'/>
                <Event Name='ondrag'/>
                <Event Name='ondragend'/>
                <Event Name='onclick'/>
                <Event Name='onselectstart'/>
                <Event Name='ondblclick'/>
                <Event Name='Crtl+C'/>
                <Event Name='Crtl+V'/>
*/
		override public function set dataProvider(value:Object):void
		{
			var dataXML:XML = <event> 
				<Event label='onmousedown'/>
                <Event label='onmouseup'/>
                <Event label='onmouseover'/>
                <Event label='onmousemove'/>
                <Event label='onmouseout'/>
                <Event label='ondrag'/>
                <Event label='ondragend'/>
                <Event label='onclick'/>
                <Event label='onselectstart'/>
                <Event label='ondblclick'/>
                <Event label='Crtl+C'/>
                <Event label='Crtl+V'/>
                </event>; 
		  
			super.dataProvider = dataXML;
		}
		
	}
}