package net.vdombox.components.xmldialogeditor.model.vo.components
{
	import mx.collections.ArrayCollection;
	
	import net.vdombox.components.xmldialogeditor.model.vo.components.base.ComponentText;
	
	public class LabelVO extends ComponentText
	{
		public function LabelVO(value:XML)
		{
			super(value);
			
			name = "Label";
		}
		
		public override function get attributes() : ArrayCollection
		{
			var _attributes : ArrayCollection = new ArrayCollection();
			
			_attributes.addItem( id );
			_attributes.addItem( visible );
			_attributes.addItem( enabled );
			_attributes.addItem( toolTip );
			_attributes.addItem( className );
			_attributes.addItem( width );
			_attributes.addItem( text );
			
			return _attributes;
		}
		
		public override function toXML() : XML
		{
			var xml : XML = new XML();
			xml = <Label>
				
			<Properties>
				<Property name="text">{ text.value }</Property>
				<Property name="toolTip">{ toolTip.value }</Property>
			</Properties>
			
			</Label>;			
			
			xml.@id = id.value;
			xml.@visible = visible.value;
			xml.@enabled = enabled.value;
			xml.@width = width.value;
			xml.@['class'] = className.value;
			
			return xml;
		}
	}
}