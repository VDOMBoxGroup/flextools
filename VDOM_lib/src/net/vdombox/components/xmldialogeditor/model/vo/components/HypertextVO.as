package net.vdombox.components.xmldialogeditor.model.vo.components
{
	import mx.collections.ArrayCollection;
	
	import net.vdombox.components.xmldialogeditor.model.vo.components.base.ComponentText;
	
	import org.osmf.elements.HTMLElement;
	
	public class HypertextVO extends ComponentText
	{
		public function HypertextVO(value:XML)
		{
			super(value);
		}

		public override function get attributes() : ArrayCollection
		{
			
			var _attributes : ArrayCollection = new ArrayCollection();
			
			_attributes.addItem( id );
			_attributes.addItem( visible );
			_attributes.addItem( toolTip );
			_attributes.addItem( text );
			
			return _attributes;
		}
		
		public override function toXML() : XML
		{
			var xml : XML = new XML();
			xml = <Hypertext>
				
			<Properties>
				<Property name="text">{ text.value }</Property>
				<Property name="toolTip">{ toolTip.value }</Property>
			</Properties>
			
			</Hypertext>;			
			
			xml.@id = id.value;
			xml.@visible = visible.value;
			
			return xml;
		}
	}
}